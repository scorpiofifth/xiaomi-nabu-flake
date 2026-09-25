# see: https://github.com/Kumar-Jy/nabu-pkgs/blob/main/packages/linux-nabu-614/PKGBUILD
{
  linuxConfig,
  linuxKernel,
  fetchFromGitHub,
  ...
}:
let
  version = "6.14.11";
  src = fetchFromGitHub {
    owner = "Kumar-Jy";
    repo = "linux-nabu";
    rev = "6.14";
    hash = "sha256-ARwwC+bR2tYI9/osdKd4B749yz/BwE5eDCY0u6tpiH4=";
  };
in
linuxKernel.manualConfig {
  inherit src version;

  pname = "linux-nabu-kumar-jy";

  configfile = linuxConfig {
    inherit src version;
    makeTarget = "defconfig";
  };

  target = "Image";
  buildDTBs = true;

  # NOTE: it is important to enable for building image
  features = {
    efiBootStub = true;
    netfilterRPFilter = true;
  };
}
