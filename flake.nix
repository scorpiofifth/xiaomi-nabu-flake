{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:scorpiofifth/nixpkgs?ref=master";
  outputs =
    { self, nixpkgs }@flakes:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux.default = self.packages.x86_64-linux.default;
      packages.aarch64-linux.linux-nabu = self.packages.x86_64-linux.linux-nabu;
      packages.aarch64-linux.image = self.packages.x86_64-linux.image;
      packages.x86_64-linux.default = self.packages.x86_64-linux.image;
      packages.x86_64-linux.linux-nabu = pkgs.callPackage ./packages/linux-nabu { };
      packages.x86_64-linux.image = (
        (nixpkgs.lib.nixosSystem {
          specialArgs = { inherit flakes; };
          modules = [ ./config.nix ];
        }).config.system.build.images.raw-efi
      );
    };
}
