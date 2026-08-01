# Post Install

- rotate the screen
- connect wifi
- ssh connection
- root: `nixos-generate-config`

> [!NOTE]
> when using `nixos-rebuil swith`, remember to run:
>
> ```bash
> nix build ~/NixOS#nixosConfigurations.XiaomiNabu.config.system.build.uki --impure
> sudo cp result/nixos.efi /boot/efi/nixos-uki
> 
> ```
