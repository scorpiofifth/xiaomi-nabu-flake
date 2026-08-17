{
  config,
  lib,
  pkgs,

  nabuPkgs,
  ...
}:
let
  cfg = config.nabu;
in
{
  options.nabu.firmware = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = nabuPkgs.linux-firmware-xiaomi-nabu;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.firmware.enable) {
    hardware.firmware = lib.mkForce [
      cfg.firmware.package
      pkgs.linux-firmware
    ];
    # make sure that the firmware will be loaded first of all
    boot.initrd.extraFirmwarePaths = [
      "novatek/novatek_nt36523_fw.bin"
      "qca/crbtfw32.tlv"
      "qca/crnv32.bin"
      "qcom/a630_sqe.fw"
      "qcom/a640_gmu.bin"
      "qcom/sm8150/xiaomi/nabu/a640_zap.mbn"
      "qcom/sm8150/xiaomi/nabu/adsp.mbn"
      "qcom/sm8150/xiaomi/nabu/cdsp.mbn"
    ];
    # it is mainly for wifi device
    systemd.services = {
      qrtr-ns = {
        description = "QIPCRTR Name Service";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.qrtr}/bin/qrtr-ns -f 1";
          Restart = "always";
        };
      };
      rmtfs = {
        description = "Qualcomm remotefs service";
        before = [ "NetworkManager.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.rmtfs}/bin/rmtfs -r -P -s";
          RestartSec = 1;
          Restart = "always";
        };
      };
      tqftpserv = {
        description = "QRTR TFTP service";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.tqftpserv}/bin/tqftpserv";
          Restart = "always";
        };
      };
    };
  };
}
