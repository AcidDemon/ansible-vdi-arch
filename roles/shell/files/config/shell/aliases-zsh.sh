typeset -a _nocorrect_cmds=(
  git gh rg fd eza bat jq fzf
  ssh scp sftp rsync curl wget
  kubectl k9s helm docker podman
  ifconfig wg ipmitool
  virsh qemu-system-x86_64 qemu-img
  gpg gpg2 pass age sops openssl
  hyprctl swaymsg grimblast hyprpicker mullvad
)

for c in $_nocorrect_cmds; do
  alias $c="nocorrect $c"
done
unset _nocorrect_cmds
