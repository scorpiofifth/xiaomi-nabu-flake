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
}:
let
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
  prepareImage = ''
    export PATH=${binPath}

    mebibyte=$(( 1024 * 1024 ))

    round_to_nearest() {
      echo $(( ( $1 / $2 + 1) * $2 ))
    }
    mkdir $out
    root="$PWD/root"
    mkdir -p $root
    export HOME=$TMPDIR

    # Provide a Nix database so that nixos-install can copy closures.
    export NIX_STATE_DIR=$TMPDIR/state
    nix-store --load-db < ${
      pkgs.closureInfo {
        rootPaths = [
          config.system.build.toplevel
          channelSources
        ];
      }
    }/registration
    chmod 755 "$TMPDIR"
    echo "running nixos-install..."
    nixos-install --root $root --no-bootloader --no-root-passwd \
      --system ${config.system.build.toplevel} \
      --channel ${channelSources} \
      --substituters ""
    diskImage=nixos.raw
    bootSize=$(round_to_nearest $(numfmt --from=iec '${bootSize}') $mebibyte)
    bootSizeMiB=$(( bootSize / 1024 / 1024 ))MiB
    truncate -s ${toString diskSize}M $diskImage
    parted --script $diskImage -- \
      mklabel gpt \
      mkpart ESP fat32 8MiB $bootSizeMiB \
      set 1 boot on \
      align-check optimal 1 \
      mkpart primary ext4 $bootSizeMiB 100% \
      align-check optimal 2 \
      print
    sgdisk \
      --disk-guid=97FD5997-D90B-4AA3-8D16-C1723AEA73C \
      --partition-guid=1:1C06F03B-704E-4657-B9CD-681A087A2FDC \
      --partition-guid=2:${rootGPUID} \
      $diskImage

    # Get start & length of the root partition in sectors to $START and $SECTORS.
    eval $(partx $diskImage -o START,SECTORS --nr 2 --pairs)
    mkfs.ext4 -b 4096 -F -L ${label} $diskImage -E offset=$(( $START * 512 )) $(( ( $SECTORS * 512 ) / 1024 ))K
    echo $START $SECTORS
    echo "copying staging root to image..."
    # cptofs -p -P 2 \
    #        -t ext4 \
    #        -i $diskImage \
    #        $root/* / ||
    #   (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)
    eval $(sfdisk -d $diskImage | sed -n 's/.*'"''${PART}"' :.*start= *\([0-9]*\).*size= *\([0-9]*\).*/S=\1 N=\2/p')
    echo $S $N
    dd if=$diskImage of="$TMPDIR/part.img" bs=512 skip=$S count=$N
    mke2fs -t ext4 -d $root "$TMPDIR/part.img"
    dd if="$TMPDIR/part.img" of=$diskImage bs=512 seek=$S conv=notrunc
  '';
in
# buildImage
pkgs.vmTools.runInLinuxVM (
  pkgs.runCommand "nixos-disk-image"
    {
      buildInputs = with pkgs; [
        util-linux
        e2fsprogs
        dosfstools
      ];
      preVM = prepareImage;
      postVM = "mv $diskImage $out/${baseName}.img";
      QEMU_OPTS = lib.concatStringsSep " " (
        lib.optionals (OVMF.systemManagementModeRequired or false) [
          "-machine"
          "q35,smm=on"
          "-global"
          "driver=cfi.pflash01,property=secure,value=on"
        ]
      );
      inherit memSize;
    }
    ''
      export PATH=${binPath}:$PATH
      export HOME=$TMPDIR

      espDisk="/dev/vda1"
      rootDisk="/dev/vda2"
      mountPoint=/mnt

      # make systemd-boot find ESP without udev
      mkdir /dev/block
      ln -s $espDisk /dev/block/254:1
      mkdir $mountPoint

      # It is necessary to set root filesystem unique identifier in advance, otherwise
      # bootloader might get the wrong one and fail to boot.
      # At the end, we reset again because we want deterministic timestamps.
      tune2fs -T now -U ${rootFSUID} -c 0 -i 0 $rootDisk

      echo "mounting rootDisk..."
      mount $rootDisk $mountPoint

      # Create the ESP and mount it. Unlike e2fsprogs, mkfs.vfat doesn't support an
      # '-E offset=X' option, so we can't do this outside the VM.
      mkdir -p $mountPoint/boot
      mkfs.vfat -n ESP $espDisk
      echo "mounting espDisk..."
      mount $espDisk $mountPoint/boot

      # Install a configuration.nix
      ${lib.optionalString (configFile != null) ''
        mkdir -p $mountPoint/etc/nixos
        cp ${configFile} $mountPoint/etc/nixos/configuration.nix
      ''}

      # Set up core system link, bootloader (sd-boot, GRUB, uboot, etc.), etc.
      # NOTE: systemd-boot-builder.py calls nix-env --list-generations which
      # clobbers $HOME/.nix-defexpr/channels/nixos This would cause a  folder
      # /homeless-shelter to show up in the final image which  in turn breaks
      # nix builds in the target image if sandboxing is turned off (through
      # __noChroot for example).
      echo "running nixos-enter for `switch-to-configuration boot`..."
      NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root $mountPoint -- /nix/var/nix/profiles/system/bin/switch-to-configuration boot

      umount -R $mountPoint

      # Make sure resize2fs works. Note that resize2fs has stricter criteria for resizing than a normal
      # mount, so the `-c 0` and `-i 0` don't affect it. Setting it to `now` doesn't produce deterministic
      # output, of course, but we can fix that when/if we start making images deterministic.
      # In deterministic mode, this is fixed to 1970-01-01 (UNIX timestamp 0).
      # This two-step approach is necessary otherwise `tune2fs` will want a fresher filesystem to perform
      # some changes.
      tune2fs -f -T 19700101 -U "${rootFSUID}" -c 0 -i 0 $rootDisk
    ''
)
