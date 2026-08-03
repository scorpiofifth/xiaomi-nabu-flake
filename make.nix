{
  pkgs,
  lib,
  config,
}:
let
  binPath = lib.makeBinPath (
    with pkgs;
    [
      config.system.build.nixos-install
      e2fsprogs
      gptfdisk
      lkl
      nix
      nixos-enter
      systemdMinimal
      util-linux
    ]
    ++ stdenv.initialPath
  );

  configBuild = config.system.build.toplevel;

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

  closureInfo = pkgs.closureInfo {
    rootPaths = [
      configBuild
      channelSources
    ];
  };
in
pkgs.runCommand "nixos-rootfs" { } ''
  chmod 755 "$TMPDIR"

  export PATH=${binPath}
  export HOME=$TMPDIR
  export NIX_STATE_DIR=$TMPDIR/state

  tmpRoot="$TMPDIR/root"
  diskImage="$TMPDIR/rootfs.img"

  mkdir -p $out $tmpRoot

  nix-store --load-db <${closureInfo}/registration
  nixos-install \
    --root $tmpRoot \
    --no-bootloader \
    --no-root-passwd \
    --system ${configBuild} \
    --channel ${channelSources} \
    --substituters ""

  truncate -s 5G $diskImage
  mkfs.ext4 $diskImage 

  cptofs -p -t ext4 -i $diskImage $tmpRoot/* /

  e2fsck -f $diskImage -y
  resize2fs $diskImage -M

  mv $diskImage $out
''
