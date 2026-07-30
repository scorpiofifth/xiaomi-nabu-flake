{
  linuxKernel,
  fetchurl,
  ...
}:
linuxKernel.manualConfig {
  pname = "linux-nabu";
  version = "6.16.0";
  modDirVersion = "6.16.0-ARCH";

  configfile = ./kernel.config;

  src = fetchurl {
    url = "https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.16.tar.xz";
    sha256 = "1a4be2fe6b5246aa4ac8987a8a4af34c42a8dd7d08b46ab48516bcc1befbcd83";
  };

  target = "Image";
  buildDTBs = true;

  kernelPatches = [
    {
      name = "0001-SM8150-Add-uart13-node.patch";
      patch = ./patches/0001-SM8150-Add-uart13-node.patch;
    }
    {
      name = "0002-SM8150-Add-device-tree-for-Xiaomi-Pad-5.patch";
      patch = ./patches/0002-SM8150-Add-device-tree-for-Xiaomi-Pad-5.patch;
    }
    {
      name = "0003-drm-Add-drm-notifier-support.patch";
      patch = ./patches/0003-drm-Add-drm-notifier-support.patch;
    }
    {
      name = "0004-drm-dsi-emit-panel-turn-on-off-signal-to-touchscreen.patch";
      patch = ./patches/0004-drm-dsi-emit-panel-turn-on-off-signal-to-touchscreen.patch;
    }
    {
      name = "0005-Input-Add-nt36523-touchscreen-driver.patch";
      patch = ./patches/0005-Input-Add-nt36523-touchscreen-driver.patch;
    }
    {
      name = "0006-nt36xxx-Fix-module-autoload.patch";
      patch = ./patches/0006-nt36xxx-Fix-module-autoload.patch;
    }
    {
      name = "0007-NABU-Added-novatek-touchscreen-node.patch";
      patch = ./patches/0007-NABU-Added-novatek-touchscreen-node.patch;
    }
    {
      name = "0008-drm-panel-nt36523-Add-Xiaomi-Pad-5-CSOT-panel.patch";
      patch = ./patches/0008-drm-panel-nt36523-Add-Xiaomi-Pad-5-CSOT-panel.patch;
    }
    {
      name = "0009-NABU-Enable-gpu-dsi0-and-dsi1.-Added-panel-and-backl.patch";
      patch = ./patches/0009-NABU-Enable-gpu-dsi0-and-dsi1.-Added-panel-and-backl.patch;
    }
    {
      name = "0010-SM8150-Add-apr-nodes.patch";
      patch = ./patches/0010-SM8150-Add-apr-nodes.patch;
    }
    {
      name = "0011-ASoC-qcom-SM8150-Add-machine-driver.patch";
      patch = ./patches/0011-ASoC-qcom-SM8150-Add-machine-driver.patch;
    }
    {
      name = "0012-NABU-Add-sound-nodes.patch";
      patch = ./patches/0012-NABU-Add-sound-nodes.patch;
    }
    {
      name = "0013-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch";
      patch = ./patches/0013-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch;
    }
    {
      name = "0014-power-qcom_fg-Add-initial-pm8150b-support.patch";
      patch = ./patches/0014-power-qcom_fg-Add-initial-pm8150b-support.patch;
    }
    {
      name = "0015-arm64-dts-qcom-pm8150b-Add-fuel-gauge.patch";
      patch = ./patches/0015-arm64-dts-qcom-pm8150b-Add-fuel-gauge.patch;
    }
    {
      name = "0016-NABU-Add-pmic-fg-and-battery-nodes.patch";
      patch = ./patches/0016-NABU-Add-pmic-fg-and-battery-nodes.patch;
    }
    {
      name = "0017-SM8150-Add-slimbus-nodes.patch";
      patch = ./patches/0017-SM8150-Add-slimbus-nodes.patch;
    }
    {
      name = "0018-arm64-dts-add-wcd9340-device-tree-binding-for-sm8150.patch";
      patch = ./patches/0018-arm64-dts-add-wcd9340-device-tree-binding-for-sm8150.patch;
    }
    {
      name = "0019-ASoC-qcom-SM8150-Add-slimbus-audio-support-Also-adde.patch";
      patch = ./patches/0019-ASoC-qcom-SM8150-Add-slimbus-audio-support-Also-adde.patch;
    }
    {
      name = "0020-ASoC-qcom-sm8150-Fix-compilation-in-v6.7.0.patch";
      patch = ./patches/0020-ASoC-qcom-sm8150-Fix-compilation-in-v6.7.0.patch;
    }
    {
      name = "0021-NABU-Add-wcd9340-and-microphone-dais.patch";
      patch = ./patches/0021-NABU-Add-wcd9340-and-microphone-dais.patch;
    }
    {
      name = "0022-drm-msm-dsi-change-sync-mode-to-sync-on-DSI0-rather-.patch";
      patch = ./patches/0022-drm-msm-dsi-change-sync-mode-to-sync-on-DSI0-rather-.patch;
    }
    {
      name = "0023-drm-panel-nt36523-enable-prepare_prev_first.patch";
      patch = ./patches/0023-drm-panel-nt36523-enable-prepare_prev_first.patch;
    }
    {
      name = "0024-input-nt36xxx-Enable-pen-support.patch";
      patch = ./patches/0024-input-nt36xxx-Enable-pen-support.patch;
    }
    {
      name = "0025-drm-panel-nt36523-Enable-120fps-for-nabu-csot.patch";
      patch = ./patches/0025-drm-panel-nt36523-Enable-120fps-for-nabu-csot.patch;
    }
    {
      name = "0026-NABU-Add-pm8150b-type-c-node-and-enable-otg.patch";
      patch = ./patches/0026-NABU-Add-pm8150b-type-c-node-and-enable-otg.patch;
    }
    {
      name = "0027-NABU-Add-fsa4480-node.patch";
      patch = ./patches/0027-NABU-Add-fsa4480-node.patch;
    }
    {
      name = "0028-NABU-Enable-secondary-usb-and-keyboard-MCU.patch";
      patch = ./patches/0028-NABU-Enable-secondary-usb-and-keyboard-MCU.patch;
    }
    {
      name = "0029-input-nt36523-Remove-fw-boot-delay.-Should-be-fine-b.patch";
      patch = ./patches/0029-input-nt36523-Remove-fw-boot-delay.-Should-be-fine-b.patch;
    }
    {
      name = "0030-NABU-Add-flash-led-node.patch";
      patch = ./patches/0030-NABU-Add-flash-led-node.patch;
    }
    {
      name = "0031-NABU-Add-ln8000-fast-charge-IC-for-testing.-If-it-sa.patch";
      patch = ./patches/0031-NABU-Add-ln8000-fast-charge-IC-for-testing.-If-it-sa.patch;
    }
    {
      name = "0032-NABU-Add-hall-sensor-for-magnetic-cover-detection.-H.patch";
      patch = ./patches/0032-NABU-Add-hall-sensor-for-magnetic-cover-detection.-H.patch;
    }
    {
      name = "0033-NABU-DISABLED-Set-panel-rotation.-https-gitlab.com-s.patch";
      patch = ./patches/0033-NABU-DISABLED-Set-panel-rotation.-https-gitlab.com-s.patch;
    }
    {
      name = "0034-NABU-Remove-framebuffer-initialized-by-XBL-https-git.patch";
      patch = ./patches/0034-NABU-Remove-framebuffer-initialized-by-XBL-https-git.patch;
    }
    {
      name = "0035-NABU-Remove-deprecated-usb_1_role_switch_out-node.patch";
      patch = ./patches/0035-NABU-Remove-deprecated-usb_1_role_switch_out-node.patch;
    }
    {
      name = "0036-of-property-fix-remote-endpoint-parse.patch";
      patch = ./patches/0036-of-property-fix-remote-endpoint-parse.patch;
    }
    {
      name = "0037-drivers-gpu-drm-drm_notifier.c-add-include-drm-drm_n.patch";
      patch = ./patches/0037-drivers-gpu-drm-drm_notifier.c-add-include-drm-drm_n.patch;
    }
    {
      name = "0038-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch";
      patch = ./patches/0038-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch;
    }
    {
      name = "0039-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch";
      patch = ./patches/0039-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch;
    }
    {
      name = "0040-arch-arm64-boot-dts-qcom-sm8150.dtsi-change-reset-na.patch";
      patch = ./patches/0040-arch-arm64-boot-dts-qcom-sm8150.dtsi-change-reset-na.patch;
    }
    {
      name = "0041-NABU-enable-rtc.patch";
      patch = ./patches/0041-NABU-enable-rtc.patch;
    }
    {
      name = "0042-NABU-disable-Sensor-Low-Power-Island.patch";
      patch = ./patches/0042-NABU-disable-Sensor-Low-Power-Island.patch;
    }
    {
      name = "0043-NABU-enable-ln8000-charger-driver.patch";
      patch = ./patches/0043-NABU-enable-ln8000-charger-driver.patch;
    }
    {
      name = "0044-clk-qcom-gcc-change-halt_check-for-gcc_ufs_phy_tx-rx.patch";
      patch = ./patches/0044-clk-qcom-gcc-change-halt_check-for-gcc_ufs_phy_tx-rx.patch;
    }
    {
      name = "0045-clk-qcom-clk-regmap-Add-udelay-in-clk_enable_regmap-.patch";
      patch = ./patches/0045-clk-qcom-clk-regmap-Add-udelay-in-clk_enable_regmap-.patch;
    }
    {
      name = "0046-nt36xxx-add-pen-input-resolution.patch";
      patch = ./patches/0046-nt36xxx-add-pen-input-resolution.patch;
    }
    {
      name = "0047-arch-arm64-boot-dts-qcom-sm8150-add-ufs-dependecy-on.patch";
      patch = ./patches/0047-arch-arm64-boot-dts-qcom-sm8150-add-ufs-dependecy-on.patch;
    }
    {
      name = "0048-arch-arm64-boot-dts-qcom-sm8150-disable-broken-crypt.patch";
      patch = ./patches/0048-arch-arm64-boot-dts-qcom-sm8150-disable-broken-crypt.patch;
    }
    {
      name = "0049-nt36xxx-Change-pen-resolution-This-is-done-to-be-abl.patch";
      patch = ./patches/0049-nt36xxx-Change-pen-resolution-This-is-done-to-be-abl.patch;
    }
  ];
}
