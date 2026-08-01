{ ... }:
{
  system.stateVersion = "26.11";
  users.users.root.password = "root";
  boot.initrd.systemd.emergencyAccess = true;
}
