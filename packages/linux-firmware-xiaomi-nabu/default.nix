# see: https://github.com/nabu-alarm/linux-firmware-xiaomi-nabu/blob/main/PKGBUILD
{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "linux-firmware-xiaomi-nabu";
  version = "25.04.26";

  src = fetchurl {
    url = "https://gitlab.postmarketos.org/panpanpanpan/nabu-firmware/-/archive/d15fc36a670ef186ca32cdbc3e940ab18bcc2505/nabu-firmware-d15fc36a670ef186ca32cdbc3e940ab18bcc2505.tar.gz";
    hash = "sha256-DrxvWX+JJHLL5FgHjsvOuSxRUM2LstLXQNmNDJflei4=";
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p "$out/lib/firmware/novatek"
    mkdir -p "$out/lib/firmware/qcom/sm8150/xiaomi/nabu"
    mkdir -p "$out/share/qcom/sm8150/xiaomi"

    cp novatek_nt36523_fw.bin "$out/lib/firmware/novatek"
    cp a630_sqe.fw a640_gmu.bin "$out/lib/firmware/qcom"
    cp a640_zap.mbn adsp.mbn cdsp.mbn \
      venus.mbn wlanmdsp.mbn slpi_nb.mbn \
      modom.mbn modemuw.jsn \
      "$out/lib/firmware/qcom/sm8150/xiaomi/nabu"
    cp -r hexagonfs/ "$out/share/qcom/sm8150/xiaomi/nabu"
  '';
})
