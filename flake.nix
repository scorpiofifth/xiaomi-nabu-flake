{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:scorpiofifth/nixpkgs?ref=master";
  outputs =
    { self, nixpkgs }@flakes:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux = {
        default = self.packages.aarch64-linux.image;
        linux-nabu = pkgs.callPackage ./packages/linux-nabu { };
        alsa-ucm-conf-xiaomi-nabu = pkgs.callPackage ./packages/alsa-ucm-conf-xiaomi-nabu { };
        linux-firmware-xiaomi-nabu = pkgs.callPackage ./packages/linux-firmware-xiaomi-nabu { };
        image = (
          (nixpkgs.lib.nixosSystem {
            specialArgs = { inherit flakes; };
            modules = [
              ./config.nix
              ./hardware.nix
            ];
          }).config.system.build.images.raw-efi
        );
      };
    };
}
