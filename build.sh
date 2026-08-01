# shellcheck disable=SC2154

# WARNING: this script should be run by nix shells

# NOTE: it seemd that all operations with
# sudo can't use app from nixpkgs
# so you should use `sudo "$(which command)"`
# cuz it use app from PATH

set -euo pipefail

round_to_nearest() {
  echo $((($1 / $2 + 1) * $2))
}

diskImage="$TMPDIR/nixos.img"
mebibyte="$((1024 * 1024))"
bootSize="$(round_to_nearest "$(numfmt --from=iec "$bootSize")" $mebibyte)"
bootSizeMiB="$((bootSize / 1024 / 1024))MiB"

sudo rm -rf "$out"
mkdir -p "$out"
chmod 755 "$TMPDIR"

echo "::group::create and setup image"
truncate -s "${diskSize}M" "$diskImage"
parted --script "$diskImage" -- \
  mklabel gpt \
  mkpart ESP fat32 8MiB "$bootSizeMiB" \
  set 1 boot on \
  align-check optimal 1 \
  mkpart primary ext4 "$bootSizeMiB" 100% \
  align-check optimal 2 \
  print
echo "::endgroup::"

loDevice=$(sudo losetup -fP --show "$diskImage")
espDisk="${loDevice}p1"
rootDisk="${loDevice}p2"
mountPoint="$TMPDIR/mnt"

echo "::group::mount partition"
sudo mkfs.vfat -n ESP "$espDisk"
sudo mkfs.ext4 -b 4096 -F -L "$label" "$rootDisk"
sudo ln -s "$espDisk" "/dev/block/254:1" # fix systemd-boot error
echo "mounting rootDisk..."
sudo mount --mkdir "$rootDisk" "$mountPoint"
echo "mounting espDisk..."
sudo mount --mkdir "$espDisk" "$mountPoint"/boot
echo "::endgroup::"

echo "::group::nixos-install"
nix-store --load-db <"${closureInfo}/registration"
sudo env "PATH=$PATH" nixos-install \
  --channel "$channelSources" \
  --no-bootloader \
  --no-root-passwd \
  --root "$mountPoint" \
  --substituters "" \
  --system "$configBuild"
echo "::endgroup::"

echo "::group::nixos-enter"
NIXOS_INSTALL_BOOTLOADER=1 sudo env "PATH=$PATH" nixos-enter \
  --root "$mountPoint" \
  -- /nix/var/nix/profiles/system/bin/switch-to-configuration boot
echo "::endgroup::"

echo "::group::inject config files"
sudo mkdir -p "$mountPoint"/etc/nixos
sudo cp "$configFile" "$mountPoint/etc/nixos/configuration.nix"
sudo cp "$hardwareFile" "$mountPoint/etc/nixos/hardware-configuration.nix"
echo "::endgroup::"

echo "::group::collect efi files"
mkdir -p "$out/efi"
sudo cp -r "$mountPoint"/boot/* "$out/efi"
echo "::endgroup::"

echo "::group::umount"
sudo umount -R "$mountPoint"
sudo rm "/dev/block/254:1"
echo "::endgroup::"

echo "::group::copy the images"
sudo dd if="$espDisk" of="$TMPDIR/esp.img"
sudo dd if="$rootDisk" of="$TMPDIR/rootfs.img"
sudo "$(which e2fsck)" -f "$TMPDIR/rootfs.img" -y
sudo "$(which resize2fs)" "$TMPDIR/rootfs.img" -M
mv "$diskImage" "$TMPDIR/esp.img" "$TMPDIR/rootfs.img" "$out"
echo "::endgroup::"
