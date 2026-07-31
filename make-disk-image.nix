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

  # OVMF firmware derivation
  OVMF ? pkgs.OVMF.fd,

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
      gptfdisk
      systemdMinimal
    ]
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
    sgdisk \
      --disk-guid=97FD5997-D90B-4AA3-8D16-C1723AEA73C \
      --partition-guid=1:1C06F03B-704E-4657-B9CD-681A087A2FDC \
      --partition-guid=2:${rootGPUID} \
      $diskImage

    # Get start & length of the root partition in sectors to $START and $SECTORS.
    eval $(partx $diskImage -o START,SECTORS --nr 2 --pairs)

    mkfs.ext4 -b 4096 -F -L ${label} $diskImage -E offset=$(sectorsToBytes $START) $(sectorsToKilobytes $SECTORS)K

    echo "copying staging root to image..."
    cptofs -p -P 2 \
           -t ext4 \
           -i $diskImage \
           $root/* / ||
      (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)
  '';

  moveImage = ''
    mv $diskImage $out/${baseName}.img
    diskImage=$out/${baseName}.img
  '';
in
# buildImage
pkgs.vmTools.runInLinuxVM (
  pkgs.runCommand name
    {
      buildInputs = with pkgs; [
        util-linux
        e2fsprogs
        dosfstools
      ];
      preVM = prepareImage;
      postVM = moveImage + postVM;
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

      # It is necessary to set root filesystem unique identifier in advance, otherwise
      # bootloader might get the wrong one and fail to boot.
      # At the end, we reset again because we want deterministic timestamps.
      tune2fs -T now -U ${rootFSUID} -c 0 -i 0 $rootDisk

      # make systemd-boot find ESP without udev
      mkdir /dev/block
      ln -s $espDisk /dev/block/254:1

      mkdir $mountPoint
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
