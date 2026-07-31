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
          fileSystems."/" = {
            device = "/dev/vda";
            fsType = "ext4";
            autoFormat = true;
          };
          boot.loader.grub.devices = [ "/dev/vda" ];
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
