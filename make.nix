{
  pkgs,
  lib,

  # The NixOS configuration to be installed onto the disk image.
  config,
  # The size of the disk, in MiB (1024*1024 bytes).
  diskSize ? "4096",
  # This will be undersized slightly, as this is actually the offset of
  # the end of the partition. Generally it will be 1MiB smaller.
  bootSize ? "256M",
  # OVMF firmware derivation
  OVMF ? pkgs.OVMF.fd,
  # Filesystem label
  label ? "nixos",
  # The initial NixOS configuration file to be copied to
  # /etc/nixos/configuration.nix.
  configFile ? null,
  # Guest memory size in MiB (1024*1024 bytes)
  memSize ? 1024,
  # Disk image filename, without any extensions (e.g. `image_1`).
  baseName ? "nixos",
  # GPT Partition Unique Identifier for root partition.
  rootGPUID ? "F222513B-DED1-49FA-B591-20CE86A2FE7F",
  rootFSUID ? rootGPUID,
  ...
}:
let
  binPath = lib.makeBinPath (
    with pkgs;
    [
      util-linux
      parted
      e2fsprogs
      lkl
      config.system.build.nixos-install
      nixos-enter
      nix
      gptfdisk
      systemdMinimal
    ]
    ++ stdenv.initialPath
  );
  channelSources = pkgs.runCommand "nixos-${config.system.nixos.version}" { } ''
    mkdir -p $out
    cp -prd ${(lib.cleanSource pkgs.path).outPath} $out/nixos
    chmod -R u+w $out/nixos
    if [ ! -e $out/nixos/nixpkgs ]; then
      ln -s . $out/nixos/nixpkgs
    fi
    rm -rf $out/nixos/.git
    echo -n ${config.system.nixos.versionSuffix} > $out/nixos/.version-suffix
  '';
in
pkgs.runCommand "nixos-disk-image" { } ''
  mebibyte=$(( 1024 * 1024 ))
  round_to_nearest() { 
    echo $(( ( $1 / $2 + 1) * $2 )) 
  }

  export PATH=${binPath}:$PATH
  export HOME=$TMPDIR
  export NIX_STATE_DIR=$TMPDIR/state

  root="$PWD/root"
  diskImage=nixos.img
  bootSize=$(round_to_nearest $(numfmt --from=iec '${bootSize}') $mebibyte)
  bootSizeMiB=$(( bootSize / 1024 / 1024 ))MiB

  mkdir $out
  mkdir -p $root
  chmod 755 "$TMPDIR"

  echo "loading nix-store database..."
  nix-store --load-db < ${
    pkgs.closureInfo {
      rootPaths = [
        config.system.build.toplevel
        channelSources
      ];
    }
  }/registration

  echo "running nixos-install..."
  nixos-install --root $root --no-bootloader --no-root-passwd \
    --system ${config.system.build.toplevel} \
    --channel ${channelSources} \
    --substituters ""

  echo "creating img..."
  truncate -s ${toString diskSize}M $diskImage
  mkfs.ext4 $diskImage
  mountPoint="$TMPDIR/mnt"
  mount -o loop $diskImage $mountPoint
  mkdir -p $mountPoint/boot 
  mount -o size=512M,mode=0755 -t tmpfs none $mountPoint/boot
  exit 1


  # echo "creating diskImage..."
  # truncate -s ${toString diskSize}M $diskImage
  # parted --script $diskImage -- \
  #   mklabel gpt \
  #   mkpart ESP fat32 8MiB $bootSizeMiB \
  #   set 1 boot on \
  #   align-check optimal 1 \
  #   mkpart primary ext4 $bootSizeMiB 100% \
  #   align-check optimal 2 \
  #   print
  # sgdisk \
  #   --disk-guid=97FD5997-D90B-4AA3-8D16-C1723AEA73C \
  #   --partition-guid=1:1C06F03B-704E-4657-B9CD-681A087A2FDC \
  #   --partition-guid=2:${rootGPUID} \
  #   $diskImage
  # eval $(partx $diskImage -o START,SECTORS --nr 2 --pairs)
  # mkfs.ext4 -b 4096 -F -L ${label} $diskImage -E offset=$(( $START * 512 )) $(( ( $SECTORS * 512 ) / 1024 ))K

  echo "copying staging root to image..."
  cptofs -p -P 2 \
     -t ext4 \
     -i $diskImage \
     $root/* / ||
    (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)

  echo "patching diskImage..."
  loDevice=$(losetup -fP --show $diskImage)
  echo $loDevice
  espDisk="$loDevice/p1"
  rootDisk="$loDevice/p2"
  mountPoint="$TMPDIR/mnt"

  mkfs.vfat -n ESP $espDisk
  tune2fs -T now -U ${rootFSUID} -c 0 -i 0 $rootDisk
  mkdir -p $mountPoint
  mount $rootDisk $mountPoint
  mkdir -p $mountPoint/boot
  mount $espDisk $mountPoint/boot
  mkdir -p $mountPoint/etc/nixos
  ${lib.optionalString (configFile != null) ''
    cp ${configFile} $mountPoint/etc/nixos/configuration.nix
  ''}

  echo "installing bootloader..."
  NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root $mountPoint -- /nix/var/nix/profiles/system/bin/switch-to-configuration boot

  echo "finishing..."
  umount -R $mountPoint
  tune2fs -T now -U ${rootFSUID} -c 0 -i 0 $rootDisk
  tune2fs -f -T 19700101 $rootDisk

  mv $diskImage $out/${baseName}.img
''
