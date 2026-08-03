# see: https://github.com/nabu-alarm/alsa-ucm-conf-xiaomi-nabu/blob/main/PKGBUILD
# inspired by "https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/al/alsa-ucm-conf-asahi/package.nix"
{
  stdenvNoCC,
  nix-update-script,
  symlinkJoin,
  alsa-ucm-conf,
}:
let
  alsa-ucm-conf-xiaomi-nabu = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "alsa-ucm-conf-xiaomi-nabu";
    version = "1.0";

    src = ./alsa-ucm-conf-xiaomi-nabu.tgz;

    installPhase = ''
      cd usr && find share/alsa/ucm2 -type f -exec install -Dm644 "{}" "$out/share/alsa/{}" \;
    '';

    passthru.updateScript = nix-update-script { };
  });
in
symlinkJoin {
  inherit (alsa-ucm-conf-xiaomi-nabu)
    pname
    version
    src
    passthru
    ;
  paths = [
    alsa-ucm-conf
    alsa-ucm-conf-xiaomi-nabu
  ];
}
