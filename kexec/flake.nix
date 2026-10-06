# RAM installer that the stock VPS image kexecs into (same image nixos-anywhere
# uses), plus python3 for Ansible, cryptsetup for luksFormat
# nft to validate the rulesets it writes, gpgv to check the Arch bootstrap.
# Build: nix build ./kexec   ->  result/vdi-kexec-x86_64-linux.tar.gz
{
  inputs.nixos-images.url = "github:nix-community/nixos-images";

  outputs = {nixos-images, ...}: let
    nixpkgs = nixos-images.inputs.nixos-stable;
  in {
    packages.x86_64-linux.default =
      (nixpkgs.legacyPackages.x86_64-linux.nixos [
        nixos-images.nixosModules.kexec-installer
        nixos-images.nixosModules.noninteractive
        ({pkgs, ...}: {
          system.kexec-installer.name = "vdi-kexec";
          environment.systemPackages = [pkgs.python3 pkgs.cryptsetup pkgs.nftables pkgs.gnupg];
        })
      ])
      .config
      .system
      .build
      .kexecInstallerTarball;
  };
}
