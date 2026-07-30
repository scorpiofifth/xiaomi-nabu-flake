{
  pkgs,
  lib,
  flakes,
  config,
  ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # TODO: check it out
  # fileSystems."/" = lib.mkForce {
  #   device = "/dev/disk/by-label/linux";
  #   fsType = "ext4";
  # };

  # TODO: check it out
  # fileSystems."/boot" = lib.mkForce {
  #   device = "/dev/disk/by-label/esp";
  #   fsType = "vfat";
  #   options = [
  #     "fmask=0077"
  #     "dmask=0077"
  #   ];
  # };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor flakes.self.packages.aarch64-linux.linux-nabu;
    kernelParams = [ "acpi=off" ];
    initrd.availableKernelModules = lib.mkForce [
      # NOTE: following are what the kernel actually has
      # "efivarfs"
      # "ext2"
      # "ext4"
      # "mmc_block"
      # "autofs"
      # "hid_generic"
      # "usbhid"
      # "sd_mod"
      # "xhci_hcd"
      # "xhci_pci"
      # "ehci_hcd"
      # "ehci_pci"

      # NOTE: following comes from alarm: `mkinitcpio -M`
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

  hardware = {
    deviceTree.enable = true;
    firmware = [
      pkgs.linux-firmware
      flakes.self.packages.aarch64-linux.linux-firmware-xiaomi-nabu
    ];
  };

  environment.systemPackages = with pkgs; [
    tqftpserv
    rmtfs
  ];

  warnings = [
    # "This warning is for debugging."
    # default: "ahci ata_piix autofs efivarfs ehci_hcd ehci_pci ext2 ext4 hid_apple hid_cherry hid_corsair hid_generic hid_lenovo hid_logitech_dj hid_logitech_hidpp hid_microsoft hid_roccat mmc_block nvme ohci_hcd ohci_pci pata_marvell sata_nv sata_sis sata_uli sata_via sd_mod sr_mod tpm-crb tpm-tis uhci_hcd usbhid xhci_hcd xhci_pci"
    # (toString config.boot.initrd.availableKernelModules)
    # (toString config.boot.kernelPackages.kernel.buildDTBs)
  ];
}
