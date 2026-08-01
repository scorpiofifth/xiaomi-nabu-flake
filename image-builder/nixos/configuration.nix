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
    fish
  ];
  users.users.nix = {
    password = "nix";
    ignoreShellProgramCheck = true;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];

}
