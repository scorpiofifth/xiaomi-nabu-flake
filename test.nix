let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  make-disk-image = import ./make.nix;
  evalConfig = import <nixpkgs/nixos/lib/eval-config.nix>;
in
make-disk-image {
  inherit pkgs lib;
  inherit
    (evalConfig {
      modules = [
        {
          boot.loader.external = {
            # WARN: remember to build uki!!!
            enable = true;
            installHook = pkgs.writeShellScript "no-bootloader" "";
          };
          fileSystems = {
            "/" = {
              device = "/dev/disk/by-partlabel/linux";
              autoResize = true;
              fsType = "ext4";
            };
            "/boot" = {
              device = "/dev/disk/by-partlabel/esp";
              fsType = "vfat";
            };
          };

        }
      ];
    })
    config
    ;
}
