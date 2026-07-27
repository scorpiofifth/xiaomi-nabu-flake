{
  lib,
  fetchurl,
  fetchpatch,
  buildLinux,
  ...
}@args:

let
  # ============================================================
  # 基本版本信息（对应 PKGBUILD 中的变量）
  # ============================================================
  version = "6.16.0";
  modDirVersion = version;
  pkgrel = "3";
  kernelName = "nabu"; # ${pkgbase#linux}

  # ============================================================
  # 补丁来源仓库（请替换为实际地址）
  # 可能是: https://gitlab.com/rodriguezst/linux-nabu
  # 或者:   https://aur.archlinux.org/cgit/aur.git/plain/?h=linux-nabu
  # ============================================================
  repoBase = "https://gitlab.com/rodriguezst/linux-nabu/-/raw/master";

  # ============================================================
  # 辅助函数：批量生成 fetchpatch 列表
  # ============================================================
  mkPatch =
    { name, sha256 }:
    fetchpatch {
      inherit name sha256;
      url = "${repoBase}/patches/${name}";
    };

  # ============================================================
  # 所有 49 个补丁（名称和 sha256 直接来自 PKGBUILD）
  # ============================================================
  patches = [
    (mkPatch {
      name = "0001-SM8150-Add-uart13-node.patch";
      sha256 = "e908a73e29d22ad994676c0b1e1234a3bb0441e51c675c8535143a4213adc527";
    })
    (mkPatch {
      name = "0002-SM8150-Add-device-tree-for-Xiaomi-Pad-5.patch";
      sha256 = "1e3bb4f3cb6c235df26d079c5fc71050f406d9f06d51c65c48ff93f481a10dae";
    })
    (mkPatch {
      name = "0003-drm-Add-drm-notifier-support.patch";
      sha256 = "f3b6845f35cd70031c02bba888ef682ded3e1c5c21bcc58d0d7346922633a64b";
    })
    (mkPatch {
      name = "0004-drm-dsi-emit-panel-turn-on-off-signal-to-touchscreen.patch";
      sha256 = "48b3105ab374a38e06511f0482f7b6308dbed4898fa5f351b055379fdc8c0b9d";
    })
    (mkPatch {
      name = "0005-Input-Add-nt36523-touchscreen-driver.patch";
      sha256 = "618b4a9853f00c121b8d2f1ebd4550acf7d1631db7a7ed9499ff05864182e458";
    })
    (mkPatch {
      name = "0006-nt36xxx-Fix-module-autoload.patch";
      sha256 = "36389bfefa41221bdfb66a200b7fb57fb97e73394b126f0413e3f02b2f2ba541";
    })
    (mkPatch {
      name = "0007-NABU-Added-novatek-touchscreen-node.patch";
      sha256 = "9a6660f645e454ff0c2cf29494abc2a037f75ff4d8d9e6caf163704b267021e6";
    })
    (mkPatch {
      name = "0008-drm-panel-nt36523-Add-Xiaomi-Pad-5-CSOT-panel.patch";
      sha256 = "c0c1f0a43ac0fe52976c5c1291287cd8e12f0539f98eac70c96bf6b31b825a77";
    })
    (mkPatch {
      name = "0009-NABU-Enable-gpu-dsi0-and-dsi1.-Added-panel-and-backl.patch";
      sha256 = "4b417873759c08786edd604e74abc3c4e0be530a29f44fe11c19ca61585b9aeb";
    })
    (mkPatch {
      name = "0010-SM8150-Add-apr-nodes.patch";
      sha256 = "3fb03d44cb145018b15754674423af587a3ff8d5310b88b4851ea6437f1d3813";
    })
    (mkPatch {
      name = "0011-ASoC-qcom-SM8150-Add-machine-driver.patch";
      sha256 = "44417bc5f672f4716205afb4ee1861631968999275951aedd183c2174d5d8ed4";
    })
    (mkPatch {
      name = "0012-NABU-Add-sound-nodes.patch";
      sha256 = "708dc480a8b19c316d77d90bd1f3818e7b3a403ba3e9f95c079558a6a3fbd25d";
    })
    (mkPatch {
      name = "0013-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch";
      sha256 = "838836d767cc40f7a500bcaf5f7d91dc16525866f2fcb82184341334599b09f5";
    })
    (mkPatch {
      name = "0014-power-qcom_fg-Add-initial-pm8150b-support.patch";
      sha256 = "a715c29e82f03fddb01f34f0dc57673e9a972054b68e6232140035805448d16b";
    })
    (mkPatch {
      name = "0015-arm64-dts-qcom-pm8150b-Add-fuel-gauge.patch";
      sha256 = "e6f2a3e545b598d4d3cc116f05c00ccad4f12c6bfea825968059d751cbc71c63";
    })
    (mkPatch {
      name = "0016-NABU-Add-pmic-fg-and-battery-nodes.patch";
      sha256 = "c30968a620e30c91e15659d0cc49cec1e4db3e379eb6c94d277b4b4a44ccd38f";
    })
    (mkPatch {
      name = "0017-SM8150-Add-slimbus-nodes.patch";
      sha256 = "61b8277bbc02676ac831ebfe6a270e705c4c05107cb63c414b3b57ac89c4963b";
    })
    (mkPatch {
      name = "0018-arm64-dts-add-wcd9340-device-tree-binding-for-sm8150.patch";
      sha256 = "8082fff704cf3d6534d08c2d0fa503d1fe113d5e7796a6f53a7ff58c9e19e32a";
    })
    (mkPatch {
      name = "0019-ASoC-qcom-SM8150-Add-slimbus-audio-support-Also-adde.patch";
      sha256 = "4bd409acfbdcfaba1f0d9ac76abf5d20fed26210bac791fd423b534f4588bc28";
    })
    (mkPatch {
      name = "0020-ASoC-qcom-sm8150-Fix-compilation-in-v6.7.0.patch";
      sha256 = "3407c75331be2e3f40f63720965409684b87a9e7768a22078fdbf7f809097582";
    })
    (mkPatch {
      name = "0021-NABU-Add-wcd9340-and-microphone-dais.patch";
      sha256 = "d75e637d10b9e5e84543dfd373413cf6297fbcfe3740cc64934f74a89bba732e";
    })
    (mkPatch {
      name = "0022-drm-msm-dsi-change-sync-mode-to-sync-on-DSI0-rather-.patch";
      sha256 = "1c3426a4c781cf11b746554f40992ca97c23e319283c01dc73f90c5957831995";
    })
    (mkPatch {
      name = "0023-drm-panel-nt36523-enable-prepare_prev_first.patch";
      sha256 = "ba8285cfd7247b6f5817d3bbdb2433fbff64bf6d95a51678838daf100b880b4d";
    })
    (mkPatch {
      name = "0024-input-nt36xxx-Enable-pen-support.patch";
      sha256 = "f2d407c9b716ed6719d80989a9c0dbbbdbaf24986174d62f9135ecbdb72ed57f";
    })
    (mkPatch {
      name = "0025-drm-panel-nt36523-Enable-120fps-for-nabu-csot.patch";
      sha256 = "f8f7e41ceea31c1f6df9c63f918f6202947692d3a36880af6bb36acd22a1ed37";
    })
    (mkPatch {
      name = "0026-NABU-Add-pm8150b-type-c-node-and-enable-otg.patch";
      sha256 = "aa0b393a98c7471babb905bf838089134b5fd2edf8fa6f8f5ad1dd4c7933c9ee";
    })
    (mkPatch {
      name = "0027-NABU-Add-fsa4480-node.patch";
      sha256 = "04d83ecb4faa2658a5c206c3e5a3c3f57a344b8aa9fa88b1d9429d2e45bc7133";
    })
    (mkPatch {
      name = "0028-NABU-Enable-secondary-usb-and-keyboard-MCU.patch";
      sha256 = "1cd0d485258b5489c52b5a05a7f5bb22a4350590ee9526e021b7a45408e10bec";
    })
    (mkPatch {
      name = "0029-input-nt36523-Remove-fw-boot-delay.-Should-be-fine-b.patch";
      sha256 = "71d33d92bcead0345450499d8f7ce9d4e3ffb82e7dc99be940ec45bde59dd96f";
    })
    (mkPatch {
      name = "0030-NABU-Add-flash-led-node.patch";
      sha256 = "ca5c0cd266077f70fd2f2f88786376f1b760aabbcd38de1c7d841d3e57d230b7";
    })
    (mkPatch {
      name = "0031-NABU-Add-ln8000-fast-charge-IC-for-testing.-If-it-sa.patch";
      sha256 = "e74813b755257dc1da077a9705046cfa60ad36d9f9f10b5966859ffd104f5e46";
    })
    (mkPatch {
      name = "0032-NABU-Add-hall-sensor-for-magnetic-cover-detection.-H.patch";
      sha256 = "56d411fd681f8f919b36ec6a0f2bc1c0088fd7973c27870ab1bf8a7d44aab3f6";
    })
    (mkPatch {
      name = "0033-NABU-DISABLED-Set-panel-rotation.-https-gitlab.com-s.patch";
      sha256 = "96b7c5d7e12a4c5e520e30e6da93812ed8d9a0e244b0746a6220ff53aa03d9d2";
    })
    (mkPatch {
      name = "0034-NABU-Remove-framebuffer-initialized-by-XBL-https-git.patch";
      sha256 = "62b3345745bbc03ae795115a1c28341e2ca4f6acb6db349aeae1d005bc71462f";
    })
    (mkPatch {
      name = "0035-NABU-Remove-deprecated-usb_1_role_switch_out-node.patch";
      sha256 = "c60c7ccf7c6089c0fc74b43d0a15426e1eae0bda96ac8209c0f80acd99d53108";
    })
    (mkPatch {
      name = "0036-of-property-fix-remote-endpoint-parse.patch";
      sha256 = "2a3e8eba6044bf8f93247bf7198af6265375c9fc04c7fd2f78d1cbaebcc086fa";
    })
    (mkPatch {
      name = "0037-drivers-gpu-drm-drm_notifier.c-add-include-drm-drm_n.patch";
      sha256 = "1fb02e7177ab0e904a282da8919a42af8db72473f054340da68d348221d477db";
    })
    (mkPatch {
      name = "0038-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch";
      sha256 = "b4ea35f189c3e160b5f326ea2ffbe0c346a0ff56661fa33a7ea8b854382ce802";
    })
    (mkPatch {
      name = "0039-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch";
      sha256 = "67b17cc5684310f665b2526a562eb47c5a9472a7a5c7285d6551e771cdda0f0e";
    })
    (mkPatch {
      name = "0040-arch-arm64-boot-dts-qcom-sm8150.dtsi-change-reset-na.patch";
      sha256 = "afd38ea3f9e836418990e23c1402bd33164319c5d1a013eae437ab1041f42062";
    })
    (mkPatch {
      name = "0041-NABU-enable-rtc.patch";
      sha256 = "2ebd671af37040e590b6504be5a8c565a44120f2d34933a1cfad015a7975d147";
    })
    (mkPatch {
      name = "0042-NABU-disable-Sensor-Low-Power-Island.patch";
      sha256 = "a9d9af0dcb7b21db0bf23783ca1dad3060063a245eeddd310b7ee6d9fb7a24ea";
    })
    (mkPatch {
      name = "0043-NABU-enable-ln8000-charger-driver.patch";
      sha256 = "fc5c62d6edd1131c9ed5e6decbe88e546e0d8a3af0477916d799d2603cd5becf";
    })
    (mkPatch {
      name = "0044-clk-qcom-gcc-change-halt_check-for-gcc_ufs_phy_tx-rx.patch";
      sha256 = "53a07f8f057a57a53d98b9a3abe07d1afbc103b94dab0488f0a1c3d5155ad562";
    })
    (mkPatch {
      name = "0045-clk-qcom-clk-regmap-Add-udelay-in-clk_enable_regmap-.patch";
      sha256 = "f0635a1e96167151a7272be0a4fbac60c6ca0f552672f2463ae4c152b362740c";
    })
    (mkPatch {
      name = "0046-nt36xxx-add-pen-input-resolution.patch";
      sha256 = "43c297e52f1da1852cd96e18162d20a69c1d439074f54d42c8240457fb97e3a1";
    })
    (mkPatch {
      name = "0047-arch-arm64-boot-dts-qcom-sm8150-add-ufs-dependecy-on.patch";
      sha256 = "ce16dbc5ff5a8ae4456dd3feaf69205c138f7eebdd55b974101a4cc9a122e935";
    })
    (mkPatch {
      name = "0048-arch-arm64-boot-dts-qcom-sm8150-disable-broken-crypt.patch";
      sha256 = "756c9921e2303c734f6a6f5273c0742f1648977e6427f479d989f16d7544daae";
    })
    (mkPatch {
      name = "0049-nt36xxx-Change-pen-resolution-This-is-done-to-be-abl.patch";
      sha256 = "37e6dbed716c012379175633ee58dc5eb13fed225d81a4055876e19c42b329b8";
    })
  ];

in

# ============================================================
# 使用 buildLinux 构建内核
# ============================================================
buildLinux (
  args
  // {
    inherit version modDirVersion;

    # ----------------------------------------------------------
    # 源码（对应 PKGBUILD 中的 source 第一项）
    # ----------------------------------------------------------
    src = fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.16.tar.xz";
      sha256 = "1a4be2fe6b5246aa4ac8987a8a4af34c42a8dd7d08b46ab48516bcc1befbcd83";
    };

    # ----------------------------------------------------------
    # 内核配置文件（对应 PKGBUILD 中的 'config' 文件）
    # ----------------------------------------------------------
    manualConfig = fetchurl {
      url = "${repoBase}/config";
      sha256 = "0c8a138e76654e854b08d3731a115d0a9d95b75f38fa65925f00979f0d4b0960";
    };

    # ----------------------------------------------------------
    # 补丁列表
    # ----------------------------------------------------------
    kernelPatches = map (p: {
      name = p.name;
      patch = p;
    }) patches;

    # ----------------------------------------------------------
    # 额外的 make 参数
    # DTC_FLAGS="-@" 用于在 DTB 中保留符号表，
    # 以支持 U-Boot 中应用 device tree overlay
    # ----------------------------------------------------------
    makeFlags = [
      "DTC_FLAGS=-@"
    ];

    # ----------------------------------------------------------
    # 设置 localversion（对应 PKGBUILD 中的 prepare() 函数）
    # 最终内核版本字符串: 6.16.0-3-nabu
    # ----------------------------------------------------------
    postPatch = ''
      echo "-${pkgrel}" > localversion.10-pkgrel
      echo "-${kernelName}" > localversion.20-pkgname
    '';

    # ----------------------------------------------------------
    # 构建目标（对应 PKGBUILD 中的 build() 函数）
    # buildLinux 对 aarch64 默认构建 Image Image.gz modules dtbs
    # 这里显式声明以确保一致性
    # ----------------------------------------------------------
    # 注意: buildLinux 内部已处理这些，无需额外覆盖
    # 如果需要自定义，可以取消注释以下内容:
    # buildTargets = [ "Image" "Image.gz" "modules" "dtbs" ];

    # ----------------------------------------------------------
    # 安装后的额外处理
    # ----------------------------------------------------------
    postInstall = ''
      # 确保 DTB 被正确安装到输出目录
      # buildLinux 通常已经处理了这一步，但我们可以验证
      if [ -f "$buildRoot/arch/arm64/boot/dts/qcom/sm8150-xiaomi-nabu.dtb" ]; then
        install -Dm644 \
          "$buildRoot/arch/arm64/boot/dts/qcom/sm8150-xiaomi-nabu.dtb" \
          "$out/dtb/qcom/sm8150-xiaomi-nabu.dtb"
      fi
    '';

    # ----------------------------------------------------------
    # 元信息
    # ----------------------------------------------------------
    meta = with lib; {
      description = "Linux kernel for Xiaomi Pad 5 (nabu) - SM8150";
      homepage = "https://www.kernel.org/";
      license = licenses.gpl2Only;
      platforms = [ "aarch64-linux" ];
      maintainers = [ ];
    };
  }
)
