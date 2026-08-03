{
  pkgs,
  lib,
  config,
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
in
pkgs.runCommand "nixos-rootfs" { } ''
  chmod 755 "$TMPDIR"

  export PATH=${binPath}
  export HOME=$TMPDIR
  export NIX_STATE_DIR=$TMPDIR/state

  tmpRoot="$TMPDIR/root"
  diskImage="$TMPDIR/nixos.img"

  mkdir -p $out $tmpRoot

  nix-store --load-db <${
    pkgs.closureInfo {
      rootPaths = [
        config.system.build.toplevel
        channelSources
      ];
    }
  }/registration

  nixos-install \
    --root $tmpRoot \
    --no-bootloader \
    --no-root-passwd \
    --system ${config.system.build.toplevel} \
    --channel ${channelSources} \
    --substituters ""

  truncate -s 5G $diskImage
  mkfs.ext4 $diskImage 

  cptofs -p -t ext4 -i $diskImage $tmpRoot/* /
  e2fsck -f $diskImage -y
  resize2fs $diskImage -M

  mv $diskImage $out
''
