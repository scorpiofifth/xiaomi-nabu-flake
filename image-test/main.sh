# shellcheck disable=SC2154

set -euo pipefail

round_to_nearest() {
  echo $((($1 / $2 + 1) * $2))
}

root="$TMPDIR/root"
diskImage=nixos.img
mebibyte=$((1024 * 1024))
bootSize=$(round_to_nearest "$(numfmt --from=iec "$bootSize")" $mebibyte)
bootSizeMiB=$((bootSize / 1024 / 1024))MiB

mkdir -p "$out"
mkdir -p "$root"
chmod 755 "$TMPDIR"

echo "running nixos-install..."
nix-store --load-db <"$closureInfo"/registration
nixos-install --root "$root" --no-bootloader --no-root-passwd \
  --system "$configBuild" \
  --channel "$channelSources" \
  --substituters ""

echo "creating img..."
sudo truncate -s "${diskSize}M" $diskImage
sudo parted --script $diskImage -- \
  mklabel gpt \
  mkpart ESP fat32 8MiB $bootSizeMiB \
  set 1 boot on \
  align-check optimal 1 \
  mkpart primary ext4 $bootSizeMiB 100% \
  align-check optimal 2 \
  print
sudo sgdisk \
  --disk-guid=97FD5997-D90B-4AA3-8D16-C1723AEA73C \
  --partition-guid=1:1C06F03B-704E-4657-B9CD-681A087A2FDC \
  --partition-guid=2:"$rootGPUID" \
  $diskImage

# Get start & length of the root partition in sectors to $START and $SECTORS.
eval "$(partx $diskImage -o START,SECTORS --nr 2 --pairs)"
sudo mkfs.ext4 -b 4096 -F -L "$label" $diskImage -E offset=$((START * 512)) $(((SECTORS * 512) / 1024))K
echo "$START" "$SECTORS"
echo "copying staging root to image..."
sudo cptofs -p -P 2 \
  -t ext4 \
  -i $diskImage \
  "$root"/* / ||
  (
    echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."
    exit 1
  )

echo "patching diskImage..."
loDevice=$(sudo losetup -fP --show $diskImage)
echo "$loDevice"
espDisk="${loDevice}p1"
rootDisk="${loDevice}p2"
mountPoint="$TMPDIR/mnt"

mkdir -p "$mountPoint"
sudo ln -s "$espDisk" /dev/block/254:1
sudo tune2fs -T now -U "$rootFSUID" -c 0 -i 0 "$rootDisk"
echo "mounting rootDisk..."
sudo mount "$rootDisk" "$mountPoint"
mkdir -p "$mountPoint"/boot
sudo mkfs.vfat -n ESP "$espDisk"
echo "mounting espDisk..."
sudo mount "$espDisk" "$mountPoint"/boot

# TODO: translate
# Install a configuration.nix
# ${lib.optionalString (configFile != null) ''
# mkdir -p $mountPoint/etc/nixos
# cp ${configFile} $mountPoint/etc/nixos/configuration.nix
# ''}

echo "running nixos-enter for 'switch-to-configuration boot'..."
NIXOS_INSTALL_BOOTLOADER=1 nixos-enter \
  --root "$mountPoint" \
  -- /nix/var/nix/profiles/system/bin/switch-to-configuration boot

sudo umount -R "$mountPoint"
sudo rm /dev/block/254:1

sudo tune2fs -T now -U "$rootFSUID" -c 0 -i 0 "$rootDisk"
sudo tune2fs -f -T 19700101 "$rootDisk"

mv $diskImage "$out"/"$baseName".img
