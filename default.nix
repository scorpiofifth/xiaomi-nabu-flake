{
  lib,
  fetchurl,
  buildLinux,
}:
let
  kernelVersion = "6.16";
  kernelRelease = "6.16.0";
in
buildLinux {
  version = kernelRelease;
  modDirVersion = kernelRelease;

  src = fetchurl {
    url = "https://www.kernel.org/pub/linux/kernel/v6.x/linux-${kernelVersion}.tar.xz";
    sha256 = "1a4be2fe6b5246aa4ac8987a8a4af34c42a8dd7d08b46ab48516bcc1befbcd83";
  };

  kernelPatches = [
    {
      name = "sm8150-uart13";
      patch = ./patches/0001-SM8150-Add-uart13-node.patch;
    }
    {
      name = "sm8150-dts-nabu";
      patch = ./patches/0002-SM8150-Add-device-tree-for-Xiaomi-Pad-5.patch;
    }
    {
      name = "drm-notifier";
      patch = ./patches/0003-drm-Add-drm-notifier-support.patch;
    }
    {
      name = "drm-dsi-touchscreen";
      patch = ./patches/0004-drm-dsi-emit-panel-turn-on-off-signal-to-touchscreen.patch;
    }
    {
      name = "nt36523-touchscreen";
      patch = ./patches/0005-Input-Add-nt36523-touchscreen-driver.patch;
    }
    {
      name = "nt36xxx-autoload";
      patch = ./patches/0006-nt36xxx-Fix-module-autoload.patch;
    }
    {
      name = "nabu-novatek-node";
      patch = ./patches/0007-NABU-Added-novatek-touchscreen-node.patch;
    }
    {
      name = "nt36523-csot-panel";
      patch = ./patches/0008-drm-panel-nt36523-Add-Xiaomi-Pad-5-CSOT-panel.patch;
    }
    {
      name = "nabu-gpu-dsi";
      patch = ./patches/0009-NABU-Enable-gpu-dsi0-and-dsi1.-Added-panel-and-backl.patch;
    }
    {
      name = "sm8150-apr-nodes";
      patch = ./patches/0010-SM8150-Add-apr-nodes.patch;
    }
    {
      name = "asoc-sm8150-machine";
      patch = ./patches/0011-ASoC-qcom-SM8150-Add-machine-driver.patch;
    }
    {
      name = "nabu-sound-nodes";
      patch = ./patches/0012-NABU-Add-sound-nodes.patch;
    }
    {
      name = "qcom-fuel-gauge";
      patch = ./patches/0013-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch;
    }
    {
      name = "qcom-fg-pm8150b";
      patch = ./patches/0014-power-qcom_fg-Add-initial-pm8150b-support.patch;
    }
    {
      name = "pm8150b-fg-dts";
      patch = ./patches/0015-arm64-dts-qcom-pm8150b-Add-fuel-gauge.patch;
    }
    {
      name = "nabu-pmic-fg";
      patch = ./patches/0016-NABU-Add-pmic-fg-and-battery-nodes.patch;
    }
    {
      name = "sm8150-slimbus";
      patch = ./patches/0017-SM8150-Add-slimbus-nodes.patch;
    }
    {
      name = "wcd9340-sm8150";
      patch = ./patches/0018-arm64-dts-add-wcd9340-device-tree-binding-for-sm8150.patch;
    }
    {
      name = "asoc-sm8150-slimbus";
      patch = ./patches/0019-ASoC-qcom-SM8150-Add-slimbus-audio-support-Also-adde.patch;
    }
    {
      name = "asoc-sm8150-fix-v6.7";
      patch = ./patches/0020-ASoC-qcom-sm8150-Fix-compilation-in-v6.7.0.patch;
    }
    {
      name = "nabu-wcd9340-dais";
      patch = ./patches/0021-NABU-Add-wcd9340-and-microphone-dais.patch;
    }
    {
      name = "drm-msm-dsi-sync";
      patch = ./patches/0022-drm-msm-dsi-change-sync-mode-to-sync-on-DSI0-rather-.patch;
    }
    {
      name = "nt36523-prepare-first";
      patch = ./patches/0023-drm-panel-nt36523-enable-prepare_prev_first.patch;
    }
    {
      name = "nt36xxx-pen";
      patch = ./patches/0024-input-nt36xxx-Enable-pen-support.patch;
    }
    {
      name = "nt36523-120fps";
      patch = ./patches/0025-drm-panel-nt36523-Enable-120fps-for-nabu-csot.patch;
    }
    {
      name = "nabu-type-c-otg";
      patch = ./patches/0026-NABU-Add-pm8150b-type-c-node-and-enable-otg.patch;
    }
    {
      name = "nabu-fsa4480";
      patch = ./patches/0027-NABU-Add-fsa4480-node.patch;
    }
    {
      name = "nabu-secondary-usb";
      patch = ./patches/0028-NABU-Enable-secondary-usb-and-keyboard-MCU.patch;
    }
    {
      name = "nt36523-no-fw-delay";
      patch = ./patches/0029-input-nt36523-Remove-fw-boot-delay.-Should-be-fine-b.patch;
    }
    {
      name = "nabu-flash-led";
      patch = ./patches/0030-NABU-Add-flash-led-node.patch;
    }
    {
      name = "nabu-ln8000-charge";
      patch = ./patches/0031-NABU-Add-ln8000-fast-charge-IC-for-testing.-If-it-sa.patch;
    }
    {
      name = "nabu-hall-sensor";
      patch = ./patches/0032-NABU-Add-hall-sensor-for-magnetic-cover-detection.-H.patch;
    }
    {
      name = "nabu-panel-rotation";
      patch = ./patches/0033-NABU-DISABLED-Set-panel-rotation.-https-gitlab.com-s.patch;
    }
    {
      name = "nabu-remove-fb";
      patch = ./patches/0034-NABU-Remove-framebuffer-initialized-by-XBL-https-git.patch;
    }
    {
      name = "nabu-remove-usb-role";
      patch = ./patches/0035-NABU-Remove-deprecated-usb_1_role_switch_out-node.patch;
    }
    {
      name = "of-fix-remote-endpoint";
      patch = ./patches/0036-of-property-fix-remote-endpoint-parse.patch;
    }
    {
      name = "drm-notifier-include";
      patch = ./patches/0037-drivers-gpu-drm-drm_notifier.c-add-include-drm-drm_n.patch;
    }
    {
      name = "nabu-ts-pinctrl";
      patch = ./patches/0038-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch;
    }
    {
      name = "nabu-ts-vendor";
      patch = ./patches/0039-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch;
    }
    {
      name = "sm8150-reset-names";
      patch = ./patches/0040-arch-arm64-boot-dts-qcom-sm8150.dtsi-change-reset-na.patch;
    }
    {
      name = "nabu-rtc";
      patch = ./patches/0041-NABU-enable-rtc.patch;
    }
    {
      name = "nabu-disable-slpi";
      patch = ./patches/0042-NABU-disable-Sensor-Low-Power-Island.patch;
    }
    {
      name = "nabu-enable-ln8000";
      patch = ./patches/0043-NABU-enable-ln8000-charger-driver.patch;
    }
    {
      name = "gcc-ufs-halt-check";
      patch = ./patches/0044-clk-qcom-gcc-change-halt_check-for-gcc_ufs_phy_tx-rx.patch;
    }
    {
      name = "clk-regmap-udelay";
      patch = ./patches/0045-clk-qcom-clk-regmap-Add-udelay-in-clk_enable_regmap-.patch;
    }
    {
      name = "nt36xxx-pen-resolution";
      patch = ./patches/0046-nt36xxx-add-pen-input-resolution.patch;
    }
    {
      name = "sm8150-ufs-dependency";
      patch = ./patches/0047-arch-arm64-boot-dts-qcom-sm8150-add-ufs-dependecy-on.patch;
    }
    {
      name = "sm8150-disable-crypto";
      patch = ./patches/0048-arch-arm64-boot-dts-qcom-sm8150-disable-broken-crypt.patch;
    }
    {
      name = "nt36xxx-pen-resolution2";
      patch = ./patches/0049-nt36xxx-Change-pen-resolution-This-is-done-to-be-abl.patch;
    }
  ];

  makeFlags = [ "-s" ];

  configfile = ./kernel/config;

  extraLocalVersion = "-3-nabu";

  extraMeta = with lib; {
    description = "Linux kernel and modules for Xiaomi Pad 5 (nabu)";
    homepage = "https://www.kernel.org/";
    license = licenses.gpl2;
    platforms = platforms.aarch64;
  };

  postBuild = ''
    make $makeFlags DTC_FLAGS="-@" dtbs
  '';

  installTargets = [
    "Image"
    "Image.gz"
    "modules"
  ];
}
