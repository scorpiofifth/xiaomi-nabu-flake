{ ... }:
{
  system.stateVersion = "26.11";

  users.users.root.password = "root";

  networking = {
    enableIPv6 = false;
    firewall.enable = false;
    networkmanager.enable = true;
  };

  services.openssh.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
