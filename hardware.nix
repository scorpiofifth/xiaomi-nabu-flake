{
  pkgs,
  lib,
  flakes,
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
      "efivarfs"
      "ext2"
      "ext4"
      "mmc_block"
      "autofs"
      "hid_generic"
      "usbhid"
      "sd_mod"
      "xhci_hcd"
      "xhci_pci"
      "ehci_hcd"
      "ehci_pci"
    ];
  };

  hardware.firmware = [
    pkgs.linux-firmware
    flakes.self.packages.aarch64-linux.linux-firmware-xiaomi-nabu
  ];

  environment.systemPackages = with pkgs; [
    tqftpserv
    rmtfs
  ];

  warnings = [
    # "This warning is for debugging."
    # default: "ahci ata_piix autofs efivarfs ehci_hcd ehci_pci ext2 ext4 hid_apple hid_cherry hid_corsair hid_generic hid_lenovo hid_logitech_dj hid_logitech_hidpp hid_microsoft hid_roccat mmc_block nvme ohci_hcd ohci_pci pata_marvell sata_nv sata_sis sata_uli sata_via sd_mod sr_mod tpm-crb tpm-tis uhci_hcd usbhid xhci_hcd xhci_pci"
    # (toString config.boot.initrd.availableKernelModules)
  ];
}
