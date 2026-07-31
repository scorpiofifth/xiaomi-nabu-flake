#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p e2fsprogs dosfstools

set -euo pipefail

TMPDIR="/tmp/installer"

sudo rm -rf $TMPDIR
mkdir -p $TMPDIR

echo "::group::Create image"
truncate -s 4G $TMPDIR/rootfs.img
mkfs.ext4 $TMPDIR/rootfs.img
echo "::endgroup::"

echo "::group::Mount image"
mkdir -p $TMPDIR/mnt
sudo mount -o loop $TMPDIR/rootfs.img $TMPDIR/mnt
sudo mkdir -p $TMPDIR/mnt/boot
sudo mount -o size=512M,mode=0755 -t tmpfs none $TMPDIR/mnt/boot
echo "::endgroup::"

nixos-install --root $root --no-bootloader --no-root-passwd \
        --system ${config.system.build.toplevel} \
        --channel ${channelSources} \
        --substituters ""


sudo umount -R $TMPDIR/mnt
