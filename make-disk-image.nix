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

  # The files and directories to be placed in the target file system.
  # This is a list of attribute sets {source, target, mode, user, group} where
  # `source' is the file system object (regular file or directory) to be
  # grafted in the file system at path `target', `mode' is a string containing
  # the permissions that will be set (ex. "755"), `user' and `group' are the
  # user and group name that will be set as owner of the files.
  # `mode', `user', and `group' are optional.
  # When setting one of `user' or `group', the other needs to be set too.
  contents ? [ ],

  # Whether to invoke `switch-to-configuration boot` during image creation
  installBootLoader ? true,

  # Whether to output have EFIVARS available in $out/efi-vars.fd and use it during disk creation
  touchEFIVars ? false,

  # OVMF firmware derivation
  OVMF ? pkgs.OVMF.fd,

  # EFI firmware
  efiFirmware ? OVMF.firmware,

  # EFI variables
  efiVariables ? OVMF.variables,

  # Filesystem label
  label ? "nixos",

  # The initial NixOS configuration file to be copied to
  # /etc/nixos/configuration.nix.
  configFile ? null,

  # Shell code executed after the VM has finished.
  postVM ? "",

  # Guest memory size in MiB (1024*1024 bytes)
  memSize ? 1024,

  name ? "nixos-disk-image",

  # Disk image filename, without any extensions (e.g. `image_1`).
  baseName ? "nixos",

  # Whether to fix:
  #   - GPT Disk Unique Identifier (diskGUID)
  #   - GPT Partition Unique Identifier: depends on the layout, root partition UUID can be controlled through `rootGPUID` option
  #   - GPT Partition Type Identifier: fixed according to the layout, e.g. ESP partition, etc. through `parted` invocation.
  #   - Filesystem Unique Identifier when fsType = ext4 for *root partition*.
  # BIOS/MBR support is "best effort" at the moment.
  # Boot partitions may not be deterministic.
  deterministic ? true,

  # GPT Partition Unique Identifier for root partition.
  rootGPUID ? "F222513B-DED1-49FA-B591-20CE86A2FE7F",

  rootFSUID ? rootGPUID,

  # Additional store paths to copy to the image's store.
  additionalPaths ? [ ],
}:

# We use -E offset=X below, which is only supported by e2fsprogs
# Either both or none of {user,group} need to be set
assert (
  lib.assertMsg (lib.all (
    attrs: ((attrs.user or null) == null) == ((attrs.group or null) == null)
  ) contents) "Contents of the disk image should set none of {user, group} or both at the same time."
);

let
  filename = "${baseName}.img";

  rootPartition = "2";

  useEFIBoot = touchEFIVars;

  nixpkgs = lib.cleanSource pkgs.path;

  # FIXME: merge with channel.nix / make-channel.nix.
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
      rsync
      util-linux
      parted
      e2fsprogs
      lkl
      config.system.build.nixos-install
      nixos-enter
      nix
      systemdMinimal
    ]
    ++ lib.optional deterministic gptfdisk
    ++ stdenv.initialPath
  );

  # I'm preserving the line below because I'm going to search for it across nixpkgs to consolidate
  # image building logic. The comment right below this now appears in 4 different places in nixpkgs :)
  # !!! should use XML.
  sources = map (x: x.source) contents;
  targets = map (x: x.target) contents;
  modes = map (x: x.mode or "''") contents;
  users = map (x: x.user or "''") contents;
  groups = map (x: x.group or "''") contents;

  basePaths = [
    config.system.build.toplevel
    channelSources
  ];

  additionalPaths' = lib.subtractLists basePaths additionalPaths;

  closureInfo = pkgs.closureInfo {
    rootPaths = basePaths ++ additionalPaths';
  };

  blockSize = toString (4 * 1024); # ext4fs block size (not block device sector size)

  prepareImage = ''
    export PATH=${binPath}

    # Yes, mkfs.ext4 takes different units in different contexts. Fun.
    sectorsToKilobytes() {
      echo $(( ( "$1" * 512 ) / 1024 ))
    }

    sectorsToBytes() {
      echo $(( "$1" * 512  ))
    }

    # Given lines of numbers, adds them together
    sum_lines() {
      local acc=0
      while read -r number; do
        acc=$((acc+number))
      done
      echo "$acc"
    }

    mebibyte=$(( 1024 * 1024 ))

    # Approximative percentage of reserved space in an ext4 fs over 512MiB.
    # 0.05208587646484375
    #  × 1000, integer part: 52
    compute_fudge() {
      echo $(( $1 * 52 / 1000 ))
    }

    round_to_nearest() {
      echo $(( ( $1 / $2 + 1) * $2 ))
    }

    mkdir $out

    root="$PWD/root"
    mkdir -p $root

    # Copy arbitrary other files into the image
    # Semi-shamelessly copied from make-etc.sh.
    set -f
    sources_=(${lib.concatStringsSep " " sources})
    targets_=(${lib.concatStringsSep " " targets})
    modes_=(${lib.concatStringsSep " " modes})
    set +f

    for ((i = 0; i < ''${#targets_[@]}; i++)); do
      source="''${sources_[$i]}"
      target="''${targets_[$i]}"
      mode="''${modes_[$i]}"

      if [ -n "$mode" ]; then
        rsync_chmod_flags="--chmod=$mode"
      else
        rsync_chmod_flags=""
      fi
      # Unfortunately cptofs only supports modes, not ownership, so we can't use
      # rsync's --chown option. Instead, we change the ownerships in the
      # VM script with chown.
      rsync_flags="-a --no-o --no-g $rsync_chmod_flags"
      if [[ "$source" =~ '*' ]]; then
        # If the source name contains '*', perform globbing.
        mkdir -p $root/$target
        for fn in $source; do
          rsync $rsync_flags "$fn" $root/$target/
        done
      else
        mkdir -p $root/$(dirname $target)
        if [ -e $root/$target ]; then
          echo "duplicate entry $target -> $source"
          exit 1
        elif [ -d $source ]; then
          # Append a slash to the end of source to get rsync to copy the
          # directory _to_ the target instead of _inside_ the target.
          # (See `man rsync`'s note on a trailing slash.)
          rsync $rsync_flags $source/ $root/$target
        else
          rsync $rsync_flags $source $root/$target
        fi
      fi
    done

    export HOME=$TMPDIR

    # Provide a Nix database so that nixos-install can copy closures.
    export NIX_STATE_DIR=$TMPDIR/state
    nix-store --load-db < ${closureInfo}/registration

    chmod 755 "$TMPDIR"
    echo "running nixos-install..."
    nixos-install --root $root --no-bootloader --no-root-passwd \
      --system ${config.system.build.toplevel} \
      --channel ${channelSources} \
      --substituters ""

    ${lib.optionalString (additionalPaths' != [ ]) ''
      nix --extra-experimental-features nix-command copy --to $root --no-check-sigs ${lib.concatStringsSep " " additionalPaths'}
    ''}

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
    ${lib.optionalString deterministic ''
      sgdisk \
      --disk-guid=97FD5997-D90B-4AA3-8D16-C1723AEA73C \
      --partition-guid=1:1C06F03B-704E-4657-B9CD-681A087A2FDC \
      --partition-guid=2:${rootGPUID} \
      $diskImage
    ''}

    # Get start & length of the root partition in sectors to $START and $SECTORS.
      eval $(partx $diskImage -o START,SECTORS --nr ${rootPartition} --pairs)

    mkfs.ext4 -b ${blockSize} -F -L ${label} $diskImage -E offset=$(sectorsToBytes $START) $(sectorsToKilobytes $SECTORS)K

    echo "copying staging root to image..."
    cptofs -p "-P ${rootPartition}" \
           -t ext4 \
           -i $diskImage \
           $root/* / ||
      (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)
  '';

  moveImage = ''
    mv $diskImage $out/${filename}
    diskImage=$out/${filename}
  '';

  createEFIVars = ''
    efiVars=$out/efi-vars.fd
    cp ${efiVariables} $efiVars
    chmod 0644 $efiVars
  '';

  createHydraBuildProducts = ''
    mkdir -p $out/nix-support
    echo "file raw-image $out/${filename}" >> $out/nix-support/hydra-build-products
  '';
in
# buildImage
pkgs.vmTools.runInLinuxVM (
  pkgs.runCommand name
    {
      preVM = prepareImage + lib.optionalString touchEFIVars createEFIVars;
      buildInputs = with pkgs; [
        util-linux
        e2fsprogs
        dosfstools
      ];
      postVM = moveImage + createHydraBuildProducts + postVM;
      QEMU_OPTS = lib.concatStringsSep " " (
        lib.optional useEFIBoot "-drive if=pflash,format=raw,unit=0,readonly=on,file=${efiFirmware}"
        ++ lib.optionals touchEFIVars [
          "-drive if=pflash,format=raw,unit=1,file=$efiVars"
        ]
        ++ lib.optionals (OVMF.systemManagementModeRequired or false) [
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

      rootDisk="/dev/vda${rootPartition}"

      # It is necessary to set root filesystem unique identifier in advance, otherwise
      # bootloader might get the wrong one and fail to boot.
      # At the end, we reset again because we want deterministic timestamps.
      ${lib.optionalString deterministic ''
        tune2fs -T now ${lib.optionalString deterministic "-U ${rootFSUID}"} -c 0 -i 0 $rootDisk
      ''}
      # make systemd-boot find ESP without udev
      mkdir /dev/block
      ln -s /dev/vda1 /dev/block/254:1

      mountPoint=/mnt
      mkdir $mountPoint
      mount $rootDisk $mountPoint

      # Create the ESP and mount it. Unlike e2fsprogs, mkfs.vfat doesn't support an
      # '-E offset=X' option, so we can't do this outside the VM.
      mkdir -p /mnt/boot
      mkfs.vfat -n ESP /dev/vda1
      mount /dev/vda1 /mnt/boot

      ${lib.optionalString touchEFIVars "mount -t efivarfs efivarfs /sys/firmware/efi/efivars"}

      # Install a configuration.nix
      mkdir -p /mnt/etc/nixos
      ${lib.optionalString (configFile != null) ''
        cp ${configFile} /mnt/etc/nixos/configuration.nix
      ''}

      ${lib.optionalString installBootLoader ''
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
        ${
          let
            limine = config.boot.loader.limine;
          in
          lib.optionalString (limine.enable && limine.biosSupport && limine.biosDevice != "/dev/vda") ''
            mkdir -p "$(dirname ${limine.biosDevice})"
            ln -s /dev/vda ${limine.biosDevice}
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
      ''}

      # Set the ownerships of the contents. The modes are set in preVM.
      # No globbing on targets, so no need to set -f
      targets_=(${lib.concatStringsSep " " targets})
      users_=(${lib.concatStringsSep " " users})
      groups_=(${lib.concatStringsSep " " groups})
      for ((i = 0; i < ''${#targets_[@]}; i++)); do
        target="''${targets_[$i]}"
        user="''${users_[$i]}"
        group="''${groups_[$i]}"
        if [ -n "$user$group" ]; then
          # We have to nixos-enter since we need to use the user and group of the VM
          nixos-enter --root $mountPoint -- chown -R "$user:$group" "$target"
        fi
      done

      umount -R /mnt

      # Make sure resize2fs works. Note that resize2fs has stricter criteria for resizing than a normal
      # mount, so the `-c 0` and `-i 0` don't affect it. Setting it to `now` doesn't produce deterministic
      # output, of course, but we can fix that when/if we start making images deterministic.
      # In deterministic mode, this is fixed to 1970-01-01 (UNIX timestamp 0).
      # This two-step approach is necessary otherwise `tune2fs` will want a fresher filesystem to perform
      # some changes.
      tune2fs -T now ${lib.optionalString deterministic "-U ${rootFSUID}"} -c 0 -i 0 $rootDisk
      ${lib.optionalString deterministic "tune2fs -f -T 19700101 $rootDisk"}
    ''
)
