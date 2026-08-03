{
  pkgs,
  lib,
  # The NixOS configuration to be installed onto the disk image.
  config,
  # The size of the disk, in MiB (1024*1024 bytes).
  diskSize ? 5120,
  # This will be undersized slightly, as this is actually the offset of
  # the end of the partition. Generally it will be 1MiB smaller.
  bootSize ? "256M",
  # Filesystem label
  label ? "nixos",
  ...
}:
pkgs.mkShell rec {
  binPath = lib.makeBinPath (
    with pkgs;
    [
      config.system.build.nixos-install
      dosfstools
      e2fsprogs
      gptfdisk
      lkl
      nix
      nixos-enter
      parted
      systemdMinimal
      util-linux
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

  closureInfo = pkgs.closureInfo {
    rootPaths = [
      configBuild
      channelSources
    ];
  };

  configBuild = config.system.build.toplevel;

  inherit bootSize diskSize label;

  shellHook = ''
    export PATH=$binPath:$PATH
    export HOME=$TMPDIR
    export NIX_STATE_DIR=$TMPDIR/state
  '';
}
