{
  config,
  lib,
  ...
}:
let
  cfg = config.nabu;
in
{
  options.nabu.firstboot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    rootLabel = lib.mkOption {
      type = lib.types.str;
      default = "linux";
    };
    espLabel = lib.mkOption {
      type = lib.types.str;
      default = "esp";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.firstboot.enable) {
    boot.growPartition = true;
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-partlabel/${cfg.firstboot.rootLabel}";
        fsType = "ext4";
        autoResize = true;
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/${cfg.firstboot.espLabel}";
        fsType = "vfat";
      };
    };
  };
}
