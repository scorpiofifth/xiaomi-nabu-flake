{ pkgs, ... }:
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

  #TODO: move followings out cuz it makes the
  # image larger than it should
  console.keyMap = "colemak";
  time.timeZone = "Asia/Shanghai";
  environment.systemPackages = with pkgs; [
    fastfetch
    git
    neovim
  ];
}
