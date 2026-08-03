{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    flakes@{ self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in
    {
      devShells.${system}.default = (
        import ./image-builder {
          inherit pkgs lib;
          config = self.nixosConfigurations.default.config;
        }
      );
      packages.${system} = {
        default = self.packages.${system}.image;
        new = (import ./make.nix) {
          inherit pkgs lib;
          config = self.nixosConfigurations.default.config;
        };
        linux-nabu = pkgs.callPackage ./packages/linux-nabu { };
        alsa-ucm-conf-xiaomi-nabu = pkgs.callPackage ./packages/alsa-ucm-conf-xiaomi-nabu { };
        linux-firmware-xiaomi-nabu = pkgs.callPackage ./packages/linux-firmware-xiaomi-nabu { };
      };
      # NOTE: this NixOS config is designed for build the installer
      # which should be as small as possible, after that re-build
      # the system on the target deviece
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit flakes;
          vars = import ./vars.nix;
        };
        modules = [ ./image-builder/nixos/configuration.nix ];
      };
    };
}
