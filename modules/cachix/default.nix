{
  config,
  lib,
  ...
}:
let
  cfg = config.nabu;
in
{
  options.nabu.cachix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://nixpkgs-for-nabu.cachix.org";
    };
    key = lib.mkOption {
      type = lib.types.str;
      default = "nixpkgs-for-nabu.cachix.org-1:OAXPmcIw5ewZYJK9QDLRNJZYy05/uBsNoZIKW7BiKAQ=";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.cachix.enable) {
    nix.settings = {
      substituters = [ cfg.cachix.url ];
      trusted-public-keys = [ cfg.cachix.key ];
    };
  };
}
