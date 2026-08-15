{ lib, ... }:
{
  imports = [
    ./firmware
    ./firstboot
    ./kernel
    ./sound
  ];

  options.nabu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
