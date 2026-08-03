{ pkgs, vars, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = vars.systemVersion;

  users.users.${vars.username} = {
    password = vars.username;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  networking = {
    enableIPv6 = false;
    firewall.enable = false;
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  console.keyMap = vars.keymap;
  time.timeZone = vars.timezone;
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "connect-wifi";
      runtimeInputs = [ pkgs.networkmanager ];
      text = ''
        nmcli device wifi list
        nmcli device wifi connect "${vars.wifi.name}" password "${vars.wifi.XUAan4Um}"
        sudo nmcli connection modify "${vars.wifi.name}" \
                ipv4.method manual \
                ipv4.addresses ${vars.wifi.address} \
                ipv4.gateway ${vars.wifi.gateway}
        sudo nmcli connection down "${vars.wifi.name}" &&
                sudo nmcli connection up "${vars.wifi.name}"
      '';
    })
  ];
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-public-keys = [
      "nixpkgs-for-nabu.cachix.org-1:OAXPmcIw5ewZYJK9QDLRNJZYy05/uBsNoZIKW7BiKAQ="
    ];
    substituters = [
      "https://nixpkgs-for-nabu.cachix.org"
    ]
    ++ vars.nixSubstituters;
  };
}
