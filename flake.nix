{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = self.overlays.default;
      };
    in
    {
      overlays.default = import ./overlays;
      packages.${system} = {
        upower = pkgs.upower;
        linux-nabu = pkgs.callPackage ./packages/linux-nabu { };
        alsa-ucm-conf-xiaomi-nabu = pkgs.callPackage ./packages/alsa-ucm-conf-xiaomi-nabu { };
        linux-firmware-xiaomi-nabu = pkgs.callPackage ./packages/linux-firmware-xiaomi-nabu { };
      };
      nixosModules.default = {
        imports = [ ./modules ];
        _module.args = {
          nabuPkgs = self.packages.${system};
          nabuOverlays = self.overlays;
        };
      };
    };
}
