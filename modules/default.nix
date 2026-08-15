{
  config,
  lib,
  ...
}:
let
  cfg = config.nabu;
in
{
  imports = [
    ./sound
  ];

  config = lib.mkIf cfg.enable {
  };

  options.nabu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable the basic components, such as kernel and boot setup.
      '';
    };
  };
}
