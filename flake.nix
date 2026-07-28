{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          crossSystem =
            if system == "x86_64-linux" then nixpkgs.lib.systems.examples.aarch64-multiplatform else null;
        };
    in
    {
      packages = forAllSystems (system: {
        default = self.packages.${system}.linux-nabu;
        linux-nabu = (pkgsFor system).callPackage ./packages/linux-nabu { };
        image = self.nixosConfigurations.image.config.system.build.images.raw-efi;
      });
      nixosConfigurations.image = nixpkgs.lib.nixosSystem { modules = [ ./image.nix ]; };
    };
}
