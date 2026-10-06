# ansible-vdi-arch

Turns a cloud VPS that only offers stock Debian/Ubuntu images into an Arch Linux
(CachyOS repos optional) desktop you reach with NoMachine over WireGuard. The root
disk is LUKS2 and you unlock it over SSH from the initrd. The whole install runs
from Ansible, so rebuilding the box is one command.

## How the install works

No custom ISO is needed. The same trick nixos-anywhere uses does the job:

1. Ansible logs into the provider image and kexecs into a NixOS RAM system
   ([nixos-images](https://github.com/nix-community/nixos-images) kexec installer,
   built locally from `kexec/flake.nix` with python3, cryptsetup and nft added).
   The kexec script carries over root's and the sudo user's SSH keys, the SSH host
   keys and the live network config (static addresses, routes and DHCP), so the
   RAM system comes up on the same IP with the same host key.
2. From RAM it wipes the disk: 1 MiB BIOS boot partition, 1 GiB ESP mounted as
   `/boot`, and the rest as LUKS2 with ext4 inside.
3. It downloads the official `archlinux-bootstrap` tarball, checks its signature
   against the Arch release key kept in `playbooks/files/` (Pierre Schmitz,
   `3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C`), unpacks it into RAM and runs
   `pacstrap` from there, so pacman, keyring and pacstrap are Arch's own.
4. It writes the config, installs GRUB for both BIOS (`i386-pc`) and UEFI
   (`--removable`, no NVRAM entry), builds the initramfs and reboots.
5. The initramfs brings up the uplink, a WireGuard interface and nftables, then
   starts dropbear on the WireGuard address. Ansible connects through the tunnel
   and types the passphrase.
6. `site.yml` then sets up MATE, NoMachine and your software groups over WireGuard.

## What is reachable

From the internet, only the WireGuard UDP port is reachable, and only from
`allowed_cidrs`. That holds both in the initrd and in the running system, since
nftables is loaded inside the initramfs before the network comes up.

| Service | Where it listens |
|---|---|
| WireGuard, UDP `wg.port` | public, `allowed_cidrs` only |
| initrd unlock SSH (dropbear, TCP 2222) | `wg.initrd_address`, through the tunnel |
| sshd (TCP 22, key only, `AllowUsers user`) | `wg.address`, through the tunnel |
| NoMachine (TCP 4000, NX key auth only, UDP off) | `wg.address`, through the tunnel |

The initrd has its own WireGuard key and address. Everything in the initramfs sits
unencrypted on `/boot`, so a leaked disk snapshot exposes the initrd's key but not
the running system's. Your client therefore needs two peers with the same endpoint:

```ini
[Peer]   # running system
PublicKey = <wg pubkey of vault_wg_private_key>
AllowedIPs = 10.66.0.1/32
Endpoint = <public_ip>:51820

[Peer]   # initrd (unlock)
PublicKey = <wg pubkey of vault_wg_initrd_private_key>
AllowedIPs = 10.66.0.2/32
Endpoint = <public_ip>:51820
```

## LUKS

The format parameters match the NixOS disko module in nixfiles: luks2,
aes-xts-plain64, 512-bit key, sha512, argon2id, 3000 ms iteration time. Discards
and the no-read/no-write workqueue flags are written into the LUKS2 header with
`--persistent`, so the initrd needs no extra options. The install prints the
resulting header values. On small VPS plans, cryptsetup caps argon2 memory and
threads by RAM and CPU count, and the install log shows what it settled on.

The initrd uses Arch's systemd hooks (`sd-encrypt`) plus `sd-network`,
`sd-nftables` and `sd-dropbear` from
[mkinitcpio-systemd-extras](https://github.com/wolegis/mkinitcpio-systemd-extras)
v0.10.3, vendored under `roles/system/files/initcpio/` (GPL-3.0, see the LICENSE
there). The busybox `netconf`/`dropbear`/`encryptssh` hooks are unmaintained and
don't work with the systemd initramfs, so they aren't used.

## Requirements

- A controller with Nix (it builds the kexec image) and Ansible with
  `ansible-galaxy collection install -r requirements.yml`.
- The WireGuard tunnel on the controller, since unlock and day-2 runs go through it.
- A VPS with KVM, at least 2 GB RAM (4 GB is comfortable for a desktop) and
  Secure Boot off. Kernel lockdown blocks kexec of the installer, and the unsigned
  GRUB wouldn't boot anyway. The play checks for this. Providers with IMA
  appraisal (Azure Trusted Launch and similar) can't kexec either.
- The NoMachine server tarball in `files/`. See below.

## NoMachine licensing

NoMachine 10 dropped the free edition. Old free downloads now redirect to the
homepage, so the tarball has to come from somewhere you control:

- the last free version, `nomachine_9.6.3_1_x86_64.tar.gz` (sha256 is in
  `main.yml`), which no longer gets security fixes. Here it is only reachable
  through WireGuard by your own peers, which limits the exposure.
- Personal Edition 10.x (paid per server per year): set `nomachine_tarball`,
  `nomachine_sha256` and `vault_nomachine_license`. It won't run without a
  licence file, not even for the trial: the evaluation licence comes from
  nomachine.com/enterprise/enterprise-evaluation. It phones home to
  `license.nomachine.com:443` every couple of days and binds to the server UUID,
  so detach the licence (`nxserver --subscriptiondel`) before rebuilding the VPS.

The NoMachine client needs a private key file for NX key auth, so a smartcard SSH
key won't work there. Put a dedicated key in `nomachine_authorized_keys`.

NoMachine runs its own X display (`CreateDisplay 1`) because a VPS has no GPU or
monitor. That display is X11 only in these editions, and so is xorgxrdp, which is
why `desktop` offers X11 sessions only: `mate` (default), `kde` or `qtile` (tiling). GNOME has no
X11 session anymore, and KDE drops its own with Plasma 6.8, so `kde` only works
until Arch ships that release.

## Setup

```sh
cp inventory/group_vars/all/vault.yml.example inventory/group_vars/all/vault.yml
$EDITOR inventory/group_vars/all/vault.yml        # passphrase, user password, wg keys
ansible-vault encrypt inventory/group_vars/all/vault.yml
$EDITOR inventory/hosts.yml                       # public_ip, install_user
$EDITOR inventory/group_vars/all/main.yml         # allowed_cidrs, wg peers, keys, groups
cp /path/to/nomachine_9.6.3_1_x86_64.tar.gz files/
```

WireGuard keys: `nix shell nixpkgs#wireguard-tools -c wg genkey`.

## Running it

```sh
ansible-playbook playbooks/install.yml -e wipe=true --ask-vault-pass   # wipe + install + unlock + site
ansible-playbook playbooks/unlock.yml --ask-vault-pass                 # after every reboot
ansible-playbook site.yml --ask-vault-pass                             # day-2 changes
```

To unlock by hand: `ssh -t -p 2222 root@10.66.0.2`, then type the passphrase.

If an install dies after the kexec step, the box sits in the RAM installer. Re-run
with `-e install_user=root` and it starts over from partitioning.

To rebuild a box this repo already installed, go in over WireGuard (public SSH is
closed): `-e install_user=acid -e install_via=10.66.0.1`. The RAM installer then
answers on the public IP with the Arch host key, so drop the old entry first with
`ssh-keygen -R <public_ip>` (add `-f` if your ssh config sets UserKnownHostsFile). Plays 1 and 2 check host keys because the passphrase
and keys cross the internet there.

Extra software lives under `software` in `main.yml`: packages grouped by category,
each set to `true` (install), `false` (leave alone) or `absent` (uninstall,
with dependencies nothing else needs). Flip
a switch and run `site.yml`. Names are pacman packages; with CachyOS on, the
`[cachyos]` repo carries a lot of AUR software too (`vesktop-bin`, `paru`). Tools
with no package at all (ffuf, nuclei) are listed under `upstream_binaries` in
`roles/apps/defaults/main.yml`: a pinned release URL plus its sha256, installed
to `/usr/local/bin`, switched on in `software` like the rest. `flatpaks` does the
same for Flathub apps (needs `flatpak: true`). Units listed under `services` with `true` get enabled
and started (`tor` for proxychains, by default). `tor_launchers` adds menu entries
like "Telegram (via Tor)". Normal apps start through proxychains. Chromium/Electron
apps (Signal, Element, Vesktop) abort under proxychains, so they get Chromium's
`--proxy-server=socks5://127.0.0.1:9050` instead, which also sends DNS through Tor.
That only covers Chromium's network stack: Signal runs its chat connection in its
own Rust library, which this switch may not reach, so check before relying on it.
The apps are single-instance, so the Tor entry only counts if the app isn't
already running (quit it from the tray first).

## CachyOS

`cachyos: v3` puts the `[cachyos-v3]`, `[cachyos-core-v3]`, `[cachyos-extra-v3]`
and `[cachyos]` repos in front of Arch's, and installs CachyOS's pacman fork
(stock pacman can't expand `$arch_v3` in their mirrorlists). The install refuses
to proceed if the CPU lacks the level. A VPS that later migrates to a host without
it won't boot, initrd included, so stay at `v3` or use `generic` (CachyOS kernel
and packages built for plain x86_64). `off` gives plain Arch. `linux-lts` stays
installed as a fallback boot entry.

## Testing on Proxmox

`tests/proxmox.yml` clones the Debian 13 cloud template (VMID 9001) into two
throwaway VMs. `vdi-test` plays the VPS (OVMF; `-e bios=seabios` tests the BIOS
path). `wg-client` is a WireGuard peer, and the controller reaches the tunnel
through it with `ProxyJump`, so the workstation needs no WireGuard of its own.
Test secrets go in `tests/secrets.yml` (gitignored).

```sh
ansible-playbook -i inventory/test.yml tests/proxmox.yml -e @tests/secrets.yml
ansible-playbook -i inventory/test.yml playbooks/install.yml -e @tests/secrets.yml -e wipe=true
ansible-playbook -i inventory/test.yml tests/proxmox.yml -e destroy=true
```

## Tested

On the local Proxmox (Debian 13 cloud image clone, 6 GB, CPU type host):

- UEFI (OVMF without enrolled keys): kexec from Debian, install, initrd unlock
  over WireGuard, `site.yml`. From the LAN, 22, 2222 and 4000 are filtered in the
  initrd and in the running system; only UDP 51820 is allowed in.
- BIOS (SeaBIOS): cold boot of the same install through the `i386-pc` GRUB, and a
  full reinstall kexec'd from the running Arch system (with the resume path after
  a stop in the RAM installer).
- NoMachine 9.6.3 creates its display after every boot and MATE runs on it.
  A second `site.yml` run changes nothing. Not tested yet: an actual NoMachine
  client login with the NX key, and Personal Edition with a licence.

## Known limits

- During the install window the RAM installer's sshd listens on port 22 to
  everyone (root, keys only), just like the provider image did before it.
- The provider can read `/boot` and the VM's memory, so it can get the initrd keys
  and the passphrase. LUKS here protects against leaked snapshots and recycled
  disks, not against a hostile hypervisor.
- The installed system sets up its network from what the RAM installer restored
  (MAC-matched systemd-networkd units, LLDP and mDNS stripped). Check the
  `.network` file under `/etc/systemd/network` if a provider does something unusual.
- If NoMachine dies, there is still SSH over WireGuard. A broken WireGuard config
  leaves only the provider's console.
