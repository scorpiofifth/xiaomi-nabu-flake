let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  make-disk-image = import ./make-disk-image.nix;
  evalConfig = import <nixpkgs/nixos/lib/eval-config.nix>;
in
make-disk-image {
  inherit pkgs lib;
  inherit
    (evalConfig {
      modules = [
        {
          # this is `raw-efi` config from `nixos/modules/image/images`
          boot.loader.systemd-boot.enable = lib.mkDefault true;
          boot.growPartition = lib.mkDefault true;
          fileSystems = {
            "/" = {
              device = "/dev/disk/by-label/nixos";
              autoResize = true;
              fsType = "ext4";
            };
            "/boot" = {
              device = "/dev/disk/by-label/ESP";
              fsType = "vfat";
            };
          };
          system.nixos.tags = [ "raw" ] ++ [ "efi" ];
          image.extension = "img";
        }
      ];
    })
    config
    ;
  format = "raw";
  onlyNixStore = false;
  partitionTableType = "efi";
  installBootLoader = false;
  touchEFIVars = false;
  diskSize = "auto";
  additionalSpace = "0M";
  copyChannel = false;
  memSize = 2048;
}
