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
  nixpkgs = lib.cleanSource pkgs.path;
  channelSources = pkgs.runCommand "nixos-${config.system.nixos.version}" { } ''
    mkdir -p $out
    cp -prd ${nixpkgs.outPath} $out/nixos
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
    echo "copying staging root to image..."
    cptofs -p -P 2 \
           -t ext4 \
           -i $diskImage \
           $root/* / ||
      (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)
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

      mount $rootDisk $mountPoint

      # Create the ESP and mount it. Unlike e2fsprogs, mkfs.vfat doesn't support an
      # '-E offset=X' option, so we can't do this outside the VM.
      mkdir -p $mountPoint/boot
      mkfs.vfat -n ESP $espDisk
      mount $espDisk $mountPoint/boot

      # Install a configuration.nix
      mkdir -p $mountPoint/etc/nixos
      ${lib.optionalString (configFile != null) ''
        cp ${configFile} $mountPoint/etc/nixos/configuration.nix
      ''}

      # In this throwaway resource, we only have /dev/vda, but the actual VM may refer to another disk for bootloader, e.g. /dev/vdb
      # Use this option to create a symlink from vda to any arbitrary device you want.
      ${lib.optionalString (config.boot.loader.grub.enable) (
        lib.concatMapStringsSep " " (
          device:
          lib.optionalString (device != "/dev/vda") ''
            mkdir -p "$(dirname ${device})"
            ln -s /dev/vda ${device}
          ''
        ) config.boot.loader.grub.devices
      )}
      ${lib.optionalString
        (
          config.boot.loader.limine.enable
          && config.boot.loader.limine.biosSupport
          && config.boot.loader.limine.biosDevice != "/dev/vda"
        )
        ''
          mkdir -p "$(dirname ${config.boot.loader.limine.biosDevice})"
          ln -s /dev/vda ${config.boot.loader.limine.biosDevice}
        ''
      }

      # Set up core system link, bootloader (sd-boot, GRUB, uboot, etc.), etc.
      # NOTE: systemd-boot-builder.py calls nix-env --list-generations which
      # clobbers $HOME/.nix-defexpr/channels/nixos This would cause a  folder
      # /homeless-shelter to show up in the final image which  in turn breaks
      # nix builds in the target image if sandboxing is turned off (through
      # __noChroot for example).
      export HOME=$TMPDIR
      NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root $mountPoint -- /nix/var/nix/profiles/system/bin/switch-to-configuration boot
      umount -R $mountPoint

      # Make sure resize2fs works. Note that resize2fs has stricter criteria for resizing than a normal
      # mount, so the `-c 0` and `-i 0` don't affect it. Setting it to `now` doesn't produce deterministic
      # output, of course, but we can fix that when/if we start making images deterministic.
      # In deterministic mode, this is fixed to 1970-01-01 (UNIX timestamp 0).
      # This two-step approach is necessary otherwise `tune2fs` will want a fresher filesystem to perform
      # some changes.
      tune2fs -T now -U ${rootFSUID} -c 0 -i 0 $rootDisk
      tune2fs -f -T 19700101 $rootDisk
    ''
)
