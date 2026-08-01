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
  # TODO: check it out
  networking.networkmanager.ensureProfiles.profiles."CMCC-H6Rf" = {
    connection = {
      id = "CMCC-H6Rf";
      interface-name = "wld0";
      timestamp = "1785579130";
      type = "wifi";
      uuid = "b310532e-bc38-4756-b388-f026f721ca94";
    };
    ipv4 = {
      address1 = "192.168.100.166/24";
      gateway = "192.168.100.1";
      method = "manual";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
    proxy = { };
    wifi = {
      mode = "infrastructure";
      ssid = "CMCC-H6Rf";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "XUAan4Um";
    };
  };
}
