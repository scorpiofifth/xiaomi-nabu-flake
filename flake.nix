{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }@flakes:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in
    {
      devShells.${system}.default = (
        import ./image-builder/shell.nix {
          inherit pkgs lib;
          config = self.nixosConfigurations.default.config;
        }
      );
      packages.${system} = {
        default = self.packages.${system}.image;
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
          sfpkgs = flakes.self.packages.${system};
        };
        modules = [
          ./nixos/configuration.nix
          ./nixos/hardware-configuration.nix
        ];
      };
    };
}
