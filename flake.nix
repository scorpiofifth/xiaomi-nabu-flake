{
  description = "A flake for Xiaomi Pad 5(nabu)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { nixpkgs }@flakes:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux = {
        default = flakes.self.packages.aarch64-linux.linux-nabu;
        linux-nabu = pkgs.callPackage ./packages/linux-nabu;
      };
    };
}
