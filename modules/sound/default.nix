{
  config,
  lib,

  nabuPkgs,
  ...
}:
let
  cfg = config.nabu;
in
{
  options.nabu.sound = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = nabuPkgs.alsa-ucm-conf-xiaomi-nabu;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.sound.enable) {
    security.rtkit.enable = true;
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
    };

    environment.variables.ALSA_CONFIG_UCM2 = "${cfg.sound.package}/share/alsa/ucm2";

    systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 =
      config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
      config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.services.pipewire.environment.ALSA_CONFIG_UCM2 =
      config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
      config.environment.variables.ALSA_CONFIG_UCM2;
  };
}
