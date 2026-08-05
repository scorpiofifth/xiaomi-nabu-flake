# xiaomi-nabu-flake

[Chinese](README.zh.md)

A Nix flake for Xiaomi Pad 5 (nabu), providing the following packages:

- alsa-ucm-conf-xiaomi-nabu
- linux-firmware-xiaomi-nabu
- linux-nabu

Package creation is based on [rodriguezst/arch-repo](https://github.com/rodriguezst/arch-repo).

Built and pushed to the `nixpkgs-for-nabu.cachix.org` cache by GitHub Actions. To use the cache, add the following to your `configuration.nix`:

```nix
{
  nix.settings = {
    substituters = [ "https://nixpkgs-for-nabu.cachix.org" ];
    trusted-public-keys = [
      "nixpkgs-for-nabu.cachix.org-1:OAXPmcIw5ewZYJK9QDLRNJZYy05/uBsNoZIKW7BiKAQ="
    ];
  };
}
```

> [!NOTE]
> Do not change the nixpkgs version in `flake.nix`; otherwise the cache will miss and the entire kernel will need to be rebuilt.
