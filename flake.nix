{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }@flakes:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      lib = pkgs.lib;
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit flakes; };
        modules = [
          ./config.nix
          ./hardware.nix
          { nixpkgs.hostPlatform = "aarch64-linux"; }
          {
            # `raw-efi` config from `nixos/modules/image/images`
            boot.loader.systemd-boot.enable = lib.mkDefault true;
            boot.growPartition = lib.mkDefault true;
            fileSystems = {
              "/" = {
                label = "linux";
                autoResize = true;
                fsType = "ext4";
              };
              "/boot" = {
                label = "esp";
                fsType = "vfat";
              };
            };
          }
        ];
      };
      devShells.aarch64-linux.default = import ./image-builder/shell.nix {
        inherit pkgs lib;
        config = self.nixosConfigurations.default.config;
      };
      packages.aarch64-linux = {
        default = self.packages.aarch64-linux.image;
        linux-nabu = pkgs.callPackage ./packages/linux-nabu { };
        alsa-ucm-conf-xiaomi-nabu = pkgs.callPackage ./packages/alsa-ucm-conf-xiaomi-nabu { };
        linux-firmware-xiaomi-nabu = pkgs.callPackage ./packages/linux-firmware-xiaomi-nabu { };
        image = (import ./archive/make-disk-image.nix) {
          inherit pkgs lib;
          config = self.nixosConfigurations.default.config;
          memSize = 2048;
          diskSize = 4096;
        };
      };
    };
}
