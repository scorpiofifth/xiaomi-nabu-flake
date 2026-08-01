{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "26.11";

  users.users.root.password = "root";

  networking = {
    enableIPv6 = false;
    firewall.enable = false;
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  #TODO: move followings out cuz it makes the
  # image larger than it should
  console.keyMap = "colemak";
  time.timeZone = "Asia/Shanghai";
  environment.systemPackages = [
    pkgs.fish
    (pkgs.writeShellApplication {
      name = "rotate-screen";
      text = "echo 1 >/sys/class/graphics/fbcon/rotate_all";
    })
    (pkgs.writeShellApplication {
      name = "connect-wifi";
      runtimeInputs = [ pkgs.networkmanager ];
      text = ''
        nmcli device wifi list
        nmcli device wifi connect "CMCC-H6Rf" password "XUAan4Um"
        sudo nmcli connection modify "CMCC-H6Rf" \
                ipv4.method manual \
                ipv4.addresses 192.168.100.166/24 \
                ipv4.gateway 192.168.100.1
        sudo nmcli connection down "CMCC-H6Rf" &&
                sudo nmcli connection up "CMCC-H6Rf"
      '';
    })
  ];
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://nixpkgs-for-nabu.cachix.org"
    ];
    trusted-public-keys = [
      "nixpkgs-for-nabu.cachix.org-1:OAXPmcIw5ewZYJK9QDLRNJZYy05/uBsNoZIKW7BiKAQ="
    ];
  };
}
