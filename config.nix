{ ... }:
{
  system.stateVersion = "26.11";

  users.users.root.password = "root";
  users.users.nix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nix";
  };

  # TODO: enable it for tests
  boot.initrd.systemd.emergencyAccess = true;
  systemd.enableEmergencyMode = true;
}
