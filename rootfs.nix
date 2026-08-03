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
      lkl
      nix
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
  export PATH=${binPath}
  export HOME="$TMPDIR"
  export NIX_STATE_DIR="$TMPDIR/state"

  chmod 755 "$TMPDIR"
  mkdir -p "$out" "$TMPDIR/install-root"

  nix-store --load-db <"${closureInfo}/registration"
  nixos-install \
    --channel "${channelSources}" \
    --no-bootloader \
    --no-root-passwd \
    --root "$TMPDIR/install-root" \
    --substituters "" \
    --system "${configBuild}"

  truncate -s 5G "$out/rootfs.img"
  mkfs.ext4 "$out/rootfs.img" 

  cptofs -p -t ext4 -i "$out/rootfs.img" "$tmpRoot"/* /

  e2fsck -f "$out/rootfs.img" -y
  resize2fs "$out/rootfs.img" -M
''
