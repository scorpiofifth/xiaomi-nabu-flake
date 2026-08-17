{
  config,
  lib,

  nabuOverlays,
  ...
}:
let
  cfg = config.nabu;
in
{
  options.nabu.overlays = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    source = lib.mkOption {
      type = lib.types.listOf (
        lib.mkOptionType {
          name = "nixpkgs-overlay";
          description = "nixpkgs overlay";
          check = lib.isFunction;
          merge = lib.mergeOneOption;
        }
      );
      default = nabuOverlays;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.overlays.enable) {
    nixpkgs.overlays = cfg.overlays.source;
  };
}
