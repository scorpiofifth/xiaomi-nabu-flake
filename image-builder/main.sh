# shellcheck disable=SC2154

# NOTE: it seemd that all operations with
# sudo can't use app from nixpkgs
# so you should use `sudo "$(which command)"`
# cuz it use app from PATH
set -euo pipefail

round_to_nearest() {
  echo $((($1 / $2 + 1) * $2))
}

root="$TMPDIR/root"
diskImage="$TMPDIR/nixos.img"
mebibyte="$((1024 * 1024))"
bootSize="$(round_to_nearest "$(numfmt --from=iec "$bootSize")" $mebibyte)"
bootSizeMiB="$((bootSize / 1024 / 1024))MiB"

mkdir -p "$out"
mkdir -p "$root"
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
sgdisk \
  --disk-guid=97FD5997-D90B-4AA3-8D16-C1723AEA73C \
  --partition-guid=1:1C06F03B-704E-4657-B9CD-681A087A2FDC \
  --partition-guid=2:"$rootGPUID" \
  "$diskImage"
eval "$(partx "$diskImage" -o START,SECTORS --nr 2 --pairs)"
echo "var debugger:"
echo "START: $START"
echo "SECTORS:$SECTORS"
mkfs.ext4 -b 4096 -F -L "$label" "$diskImage" -E offset=$((START * 512)) $(((SECTORS * 512) / 1024))K
echo "::endgroup::"

echo "::group::nixos-install"
nix-store --load-db <"${closureInfo}/registration"
nixos-install \
  --channel "$channelSources" \
  --no-bootloader \
  --no-root-passwd \
  --root "$root" \
  --substituters "" \
  --system "$configBuild"
echo "::endgroup::"

echo "::group::copy staging root to image"
cptofs -p -P 2 \
  -t ext4 \
  -i "$diskImage" \
  "$root"/* / ||
  (
    echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."
    exit 1
  )
echo "::endgroup::"

echo "patching diskImage..."
loDevice=$(sudo losetup -fP --show "$diskImage")
echo "$loDevice"
espDisk="${loDevice}p1"
rootDisk="${loDevice}p2"
mountPoint="$TMPDIR/mnt"

echo "::group::mount partition"
sudo mkdir -p "$mountPoint"
sudo ln -s "$espDisk" "/dev/block/254:1"
sudo "$(which tune2fs)" -T now -U "$rootFSUID" -c 0 -i 0 "$rootDisk"
echo "mounting rootDisk..."
sudo mount "$rootDisk" "$mountPoint"
sudo mkdir -p "$mountPoint"/boot
sudo mkfs.vfat -n ESP "$espDisk"
echo "mounting espDisk..."
sudo mount "$espDisk" "$mountPoint"/boot
echo "::endgroup::"

echo "::group::nixos-enter"
NIXOS_INSTALL_BOOTLOADER=1 sudo "$(which nixos-enter)" \
  --root "$mountPoint" \
  -- /nix/var/nix/profiles/system/bin/switch-to-configuration boot
echo "::endgroup::"

echo "::group::collect efi files"
mkdir -p "$out/efi"
sudo cp -r "$mountPoint"/boot/* "$out/efi"
echo "::endgroup::"

sudo umount -R "$mountPoint"
sudo rm "/dev/block/254:1"

sudo "$(which tune2fs)" -T now -U "$rootFSUID" -c 0 -i 0 "$rootDisk"
sudo "$(which tune2fs)" -f -T 19700101 "$rootDisk"

echo "::group::copy the images"
sudo dd if="$espDisk" of="$TMPDIR/esp.img"
sudo dd if="$rootDisk" of="$TMPDIR/rootfs.img"
sudo "$(which e2fsck)" -f "$TMPDIR/rootfs.img" -y
sudo "$(which resize2fs)" "$TMPDIR/rootfs.img" -M
mv "$diskImage" "$TMPDIR/esp.img" "$TMPDIR/rootfs.img" "$out"
echo "::endgroup::"
