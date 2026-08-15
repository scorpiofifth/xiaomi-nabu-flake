{
  config,
  lib,
  pkgs,
  nabupkgs,
  ...
}:
let
  cfg = config.nabu;
in
{
  options.nabu.kernel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = nabupkgs.linux-nabu;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.kernel.enable) {
    hardware.deviceTree.name = "qcom/sm8150-xiaomi-nabu.dtb";
    boot = {
      kernelPackages = (pkgs.linuxPackagesFor cfg.kernel.package);
      initrd.availableKernelModules = lib.mkForce [
        "arm_smmu"
        "ath10k_snoc"
        "clk_rpmh"
        "cmd_db"
        "dwc3"
        "dwc3_qcom_legacy"
        "efi_pstore"
        "ext4"
        "fastrpc"
        "fsa4480"
        "gcc_sm8150"
        "gpi"
        "gpio_keys"
        "gpio_wcd934x"
        "hci_uart"
        "hid_generic"
        "hid_multitouch"
        "joydev"
        "kgdboc"
        "ktz8866"
        "leds_qcom_flash"
        "ln8000_charger"
        "nt36523_ts"
        "nvmem_qcom_spmi_sdam"
        "panel_novatek_nt36523"
        "pm8941_pwrkey"
        "q6adm"
        "q6afe"
        "q6afe_clocks"
        "q6afe_dai"
        "q6asm"
        "q6asm_dai"
        "q6core"
        "q6routing"
        "qcom_cpufreq_hw"
        "qcom_edac"
        "qcom_fg"
        "qcom_geni_serial"
        "qcom_hwspinlock"
        "qcom_pd_mapper"
        "qcom_pdc"
        "qcom_q6v5_pas"
        "qcom_rpmh_regulator"
        "qcom_scm"
        "qcom_spmi_adc5"
        "qcom_stats"
        "qcom_tsens"
        "qcom_usb_vbus_regulator"
        "qcom_wdt"
        "qnoc_sm8150"
        "qrtr_smd"
        "ramoops"
        "rpmsg_ctrl"
        "rtc_pm8xxx"
        "sd_mod"
        "slim_qcom_ngd_ctrl"
        "snd_soc_cs35l41_i2c"
        "snd_soc_sm8150"
        "snd_soc_wcd934x"
        "socinfo"
        "soundwire_qcom"
        "spmi_pmic_arb"
        "usbhid"
        "wcd934x"
        "xhci_hcd"
        "xhci_plat_hcd"
      ];
    };
  };
}
