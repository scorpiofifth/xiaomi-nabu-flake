{ lib, flakes, ... }:
{
  system.stateVersion = "26.11";
  nixpkgs.hostPlatform.system = "aarch64-linux";

  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/linux";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/esp";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # boot.kernelPackages = flakes.self.packages.aarch64-linux.linux-nabu;
}
