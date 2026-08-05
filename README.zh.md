# xiaomi-nabu-flake

[English](README.md)

适用于小米平板 5（nabu）的 Nix flake，提供以下软件包：

- alsa-ucm-conf-xiaomi-nabu
- linux-firmware-xiaomi-nabu
- linux-nabu

所有包的制作参考 [rodriguezst/arch-repo](https://github.com/rodriguezst/arch-repo)。

由 GitHub Actions 构建并推送至 `nixpkgs-for-nabu.cachix.org` 缓存。如需使用缓存，在 `configuration.nix` 中添加：

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
> 请勿在 flake.nix 中更改 nixpkgs 版本，否则缓存将无法命中，需重新编译整个内核。
