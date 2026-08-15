{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        linux-nabu = pkgs.callPackage ./packages/linux-nabu { };
        alsa-ucm-conf-xiaomi-nabu = pkgs.callPackage ./packages/alsa-ucm-conf-xiaomi-nabu { };
        linux-firmware-xiaomi-nabu = pkgs.callPackage ./packages/linux-firmware-xiaomi-nabu { };
      };
      nixosModules.default = {
        imports = [ ./modules ];
        _module.args.nabupkgs = self.packages.${system};
      };
    };
}
