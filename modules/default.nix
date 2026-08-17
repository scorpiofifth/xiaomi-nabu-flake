{ lib, ... }:
{
  imports = [
    ./cachix
    ./firmware
    ./firstboot
    ./kernel
    ./overlays
    ./sound
  ];

  options.nabu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
