# / AArch64 Xiaomi Pad 5
# Maintainer: rodriguezst <git@rodriguezst.es>

buildarch=8

pkgbase=linux-nabu
pkgver=6.16.0
_kernelname=${pkgbase#linux}
_desc="AArch64 Xiaomi Pad 5"
_srcname="linux-${pkgver/%.0/}"
_dtbfile='qcom/sm8150-xiaomi-nabu.dtb'
pkgrel=3
arch=('aarch64')
url="http://www.kernel.org/"
license=('GPL2')
makedepends=('xmlto' 'docbook-xsl' 'kmod' 'inetutils' 'bc' 'git' 'uboot-tools' 'dtc' 'python3' 'systemd-ukify' 'sbsigntools')
options=('!strip')
source=("http://www.kernel.org/pub/linux/kernel/v6.x/${_srcname}.tar.xz"
        'config'
        '0001-SM8150-Add-uart13-node.patch'
        '0002-SM8150-Add-device-tree-for-Xiaomi-Pad-5.patch'
        '0003-drm-Add-drm-notifier-support.patch'
        '0004-drm-dsi-emit-panel-turn-on-off-signal-to-touchscreen.patch'
        '0005-Input-Add-nt36523-touchscreen-driver.patch'
        '0006-nt36xxx-Fix-module-autoload.patch'
        '0007-NABU-Added-novatek-touchscreen-node.patch'
        '0008-drm-panel-nt36523-Add-Xiaomi-Pad-5-CSOT-panel.patch'
        '0009-NABU-Enable-gpu-dsi0-and-dsi1.-Added-panel-and-backl.patch'
        '0010-SM8150-Add-apr-nodes.patch'
        '0011-ASoC-qcom-SM8150-Add-machine-driver.patch'
        '0012-NABU-Add-sound-nodes.patch'
        '0013-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch'
        '0014-power-qcom_fg-Add-initial-pm8150b-support.patch'
        '0015-arm64-dts-qcom-pm8150b-Add-fuel-gauge.patch'
        '0016-NABU-Add-pmic-fg-and-battery-nodes.patch'
        '0017-SM8150-Add-slimbus-nodes.patch'
        '0018-arm64-dts-add-wcd9340-device-tree-binding-for-sm8150.patch'
        '0019-ASoC-qcom-SM8150-Add-slimbus-audio-support-Also-adde.patch'
        '0020-ASoC-qcom-sm8150-Fix-compilation-in-v6.7.0.patch'
        '0021-NABU-Add-wcd9340-and-microphone-dais.patch'
        '0022-drm-msm-dsi-change-sync-mode-to-sync-on-DSI0-rather-.patch'
        '0023-drm-panel-nt36523-enable-prepare_prev_first.patch'
        '0024-input-nt36xxx-Enable-pen-support.patch'
        '0025-drm-panel-nt36523-Enable-120fps-for-nabu-csot.patch'
        '0026-NABU-Add-pm8150b-type-c-node-and-enable-otg.patch'
        '0027-NABU-Add-fsa4480-node.patch'
        '0028-NABU-Enable-secondary-usb-and-keyboard-MCU.patch'
        '0029-input-nt36523-Remove-fw-boot-delay.-Should-be-fine-b.patch'
        '0030-NABU-Add-flash-led-node.patch'
        '0031-NABU-Add-ln8000-fast-charge-IC-for-testing.-If-it-sa.patch'
        '0032-NABU-Add-hall-sensor-for-magnetic-cover-detection.-H.patch'
        '0033-NABU-DISABLED-Set-panel-rotation.-https-gitlab.com-s.patch'
        '0034-NABU-Remove-framebuffer-initialized-by-XBL-https-git.patch'
        '0035-NABU-Remove-deprecated-usb_1_role_switch_out-node.patch'
        '0036-of-property-fix-remote-endpoint-parse.patch'
        '0037-drivers-gpu-drm-drm_notifier.c-add-include-drm-drm_n.patch'
        '0038-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch'
        '0039-arch-arm64-boot-dts-qcom-sm8150-xiaomi-nabu.dts-add-.patch'
        '0040-arch-arm64-boot-dts-qcom-sm8150.dtsi-change-reset-na.patch'
        '0041-NABU-enable-rtc.patch'
        '0042-NABU-disable-Sensor-Low-Power-Island.patch'
        '0043-NABU-enable-ln8000-charger-driver.patch'
        '0044-clk-qcom-gcc-change-halt_check-for-gcc_ufs_phy_tx-rx.patch'
        '0045-clk-qcom-clk-regmap-Add-udelay-in-clk_enable_regmap-.patch'
        '0046-nt36xxx-add-pen-input-resolution.patch'
        '0047-arch-arm64-boot-dts-qcom-sm8150-add-ufs-dependecy-on.patch'
        '0048-arch-arm64-boot-dts-qcom-sm8150-disable-broken-crypt.patch'
        '0049-nt36xxx-Change-pen-resolution-This-is-done-to-be-abl.patch'
        'linux.preset')
sha256sums=('1a4be2fe6b5246aa4ac8987a8a4af34c42a8dd7d08b46ab48516bcc1befbcd83'
            '0c8a138e76654e854b08d3731a115d0a9d95b75f38fa65925f00979f0d4b0960'
            'e908a73e29d22ad994676c0b1e1234a3bb0441e51c675c8535143a4213adc527'
            '1e3bb4f3cb6c235df26d079c5fc71050f406d9f06d51c65c48ff93f481a10dae'
            'f3b6845f35cd70031c02bba888ef682ded3e1c5c21bcc58d0d7346922633a64b'
            '48b3105ab374a38e06511f0482f7b6308dbed4898fa5f351b055379fdc8c0b9d'
            '618b4a9853f00c121b8d2f1ebd4550acf7d1631db7a7ed9499ff05864182e458'
            '36389bfefa41221bdfb66a200b7fb57fb97e73394b126f0413e3f02b2f2ba541'
            '9a6660f645e454ff0c2cf29494abc2a037f75ff4d8d9e6caf163704b267021e6'
            'c0c1f0a43ac0fe52976c5c1291287cd8e12f0539f98eac70c96bf6b31b825a77'
            '4b417873759c08786edd604e74abc3c4e0be530a29f44fe11c19ca61585b9aeb'
            '3fb03d44cb145018b15754674423af587a3ff8d5310b88b4851ea6437f1d3813'
            '44417bc5f672f4716205afb4ee1861631968999275951aedd183c2174d5d8ed4'
            '708dc480a8b19c316d77d90bd1f3818e7b3a403ba3e9f95c079558a6a3fbd25d'
            '838836d767cc40f7a500bcaf5f7d91dc16525866f2fcb82184341334599b09f5'
            'a715c29e82f03fddb01f34f0dc57673e9a972054b68e6232140035805448d16b'
            'e6f2a3e545b598d4d3cc116f05c00ccad4f12c6bfea825968059d751cbc71c63'
            'c30968a620e30c91e15659d0cc49cec1e4db3e379eb6c94d277b4b4a44ccd38f'
            '61b8277bbc02676ac831ebfe6a270e705c4c05107cb63c414b3b57ac89c4963b'
            '8082fff704cf3d6534d08c2d0fa503d1fe113d5e7796a6f53a7ff58c9e19e32a'
            '4bd409acfbdcfaba1f0d9ac76abf5d20fed26210bac791fd423b534f4588bc28'
            '3407c75331be2e3f40f63720965409684b87a9e7768a22078fdbf7f809097582'
            'd75e637d10b9e5e84543dfd373413cf6297fbcfe3740cc64934f74a89bba732e'
            '1c3426a4c781cf11b746554f40992ca97c23e319283c01dc73f90c5957831995'
            'ba8285cfd7247b6f5817d3bbdb2433fbff64bf6d95a51678838daf100b880b4d'
            'f2d407c9b716ed6719d80989a9c0dbbbdbaf24986174d62f9135ecbdb72ed57f'
            'f8f7e41ceea31c1f6df9c63f918f6202947692d3a36880af6bb36acd22a1ed37'
            'aa0b393a98c7471babb905bf838089134b5fd2edf8fa6f8f5ad1dd4c7933c9ee'
            '04d83ecb4faa2658a5c206c3e5a3c3f57a344b8aa9fa88b1d9429d2e45bc7133'
            '1cd0d485258b5489c52b5a05a7f5bb22a4350590ee9526e021b7a45408e10bec'
            '71d33d92bcead0345450499d8f7ce9d4e3ffb82e7dc99be940ec45bde59dd96f'
            'ca5c0cd266077f70fd2f2f88786376f1b760aabbcd38de1c7d841d3e57d230b7'
            'e74813b755257dc1da077a9705046cfa60ad36d9f9f10b5966859ffd104f5e46'
            '56d411fd681f8f919b36ec6a0f2bc1c0088fd7973c27870ab1bf8a7d44aab3f6'
            '96b7c5d7e12a4c5e520e30e6da93812ed8d9a0e244b0746a6220ff53aa03d9d2'
            '62b3345745bbc03ae795115a1c28341e2ca4f6acb6db349aeae1d005bc71462f'
            'c60c7ccf7c6089c0fc74b43d0a15426e1eae0bda96ac8209c0f80acd99d53108'
            '2a3e8eba6044bf8f93247bf7198af6265375c9fc04c7fd2f78d1cbaebcc086fa'
            '1fb02e7177ab0e904a282da8919a42af8db72473f054340da68d348221d477db'
            'b4ea35f189c3e160b5f326ea2ffbe0c346a0ff56661fa33a7ea8b854382ce802'
            '67b17cc5684310f665b2526a562eb47c5a9472a7a5c7285d6551e771cdda0f0e'
            'afd38ea3f9e836418990e23c1402bd33164319c5d1a013eae437ab1041f42062'
            '2ebd671af37040e590b6504be5a8c565a44120f2d34933a1cfad015a7975d147'
            'a9d9af0dcb7b21db0bf23783ca1dad3060063a245eeddd310b7ee6d9fb7a24ea'
            'fc5c62d6edd1131c9ed5e6decbe88e546e0d8a3af0477916d799d2603cd5becf'
            '53a07f8f057a57a53d98b9a3abe07d1afbc103b94dab0488f0a1c3d5155ad562'
            'f0635a1e96167151a7272be0a4fbac60c6ca0f552672f2463ae4c152b362740c'
            '43c297e52f1da1852cd96e18162d20a69c1d439074f54d42c8240457fb97e3a1'
            'ce16dbc5ff5a8ae4456dd3feaf69205c138f7eebdd55b974101a4cc9a122e935'
            '756c9921e2303c734f6a6f5273c0742f1648977e6427f479d989f16d7544daae'
            '37e6dbed716c012379175633ee58dc5eb13fed225d81a4055876e19c42b329b8'
            '4521b5fc8964affe10f14c5bfa3ca9d12011c986f1f07d9d150d0726308fb9a1')

prepare() {
  cd $_srcname

  echo "Setting version..."
  echo "-$pkgrel" > localversion.10-pkgrel
  echo "${pkgbase#linux}" > localversion.20-pkgname

  # add upstream patch
  if [[ -f ../patch-${pkgver} ]]; then
    git apply --whitespace=nowarn ../patch-${pkgver}
  fi

  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    [[ $src = *.patch ]] || continue
    msg2 "Applying patch: $src..."
    patch -Np1 < "../$src" # || true
  done

  cat "${srcdir}/config" > ./.config
  make olddefconfig
}

build() {
  cd ${_srcname}

  # get kernel version
  make prepare
  make -s kernelrelease > version

  # build!
  unset LDFLAGS
  make ${MAKEFLAGS} Image Image.gz modules
  # Generate device tree blobs with symbols to support applying device tree overlays in U-Boot
  make ${MAKEFLAGS} DTC_FLAGS="-@" dtbs
}

_package_common() {
  echo "Installing boot image and dtbs..."
  install -Dm644 arch/arm64/boot/Image "${pkgdir}/boot/vmlinux-${kernver}"
  install -Dm644 arch/arm64/boot/Image.gz "${pkgdir}/boot/vmlinuz-${kernver}"
  install -Dm644 arch/arm64/boot/dts/${_dtbfile} "${pkgdir}/boot/dtb-${kernver}"

  echo "Installing modules..."
  make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 DEPMOD=/doesnt/exist modules_install

  # remove build link
  rm "$pkgdir/usr/lib/modules/$kernver/build"
}

_package() {
  pkgdesc="The Linux Kernel and modules - ${_desc}"
  depends=('coreutils' 'linux-firmware' 'kmod' 'mkinitcpio>=0.7')
  optdepends=('wireless-regdb: to set the correct wireless channels of your country')
  provides=("linux=${pkgver}" "KSMBD-MODULE" "WIREGUARD-MODULE")
  conflicts=('linux')
  install=${pkgname}.install

  cd $_srcname
  local kernver="$(<version)"

  _package_common

  # sed expression for following substitutions
  local _subst="
    s|%PKGBASE%|${pkgbase}|g
    s|%KERNVER%|${kernver}|g
  "

  # install mkinitcpio preset file
  sed "${_subst}" ../linux.preset |
    install -Dm644 /dev/stdin "${pkgdir}/etc/mkinitcpio.d/${pkgbase}.preset"

  # rather than use another hook (90-linux.hook) rely on mkinitcpio's 90-mkinitcpio-install.hook
  # which avoids a double run of mkinitcpio that can occur
  install -d "${pkgdir}/usr/lib/initcpio/"
  echo "dummy file to trigger mkinitcpio to run" > "${pkgdir}/usr/lib/initcpio/$(<version)"
}

_package-uki() {
  pkgdesc="The Linux Kernel and modules - ${_desc} (UKI)"
  depends=('coreutils' 'linux-firmware' 'kmod')
  optdepends=('wireless-regdb: to set the correct wireless channels of your country')
  provides=("linux=${pkgver}" "KSMBD-MODULE" "WIREGUARD-MODULE")
  conflicts=('linux')
  #install=${pkgname}.install

  cd $_srcname
  local kernver="$(<version)"

  _package_common

  if [[ ! -f "$SB_SIGN_KEY" || ! -f "$SB_SIGN_CERT" ]]; then
    error "**********************************************"
    error "To build UKI version, you MUST provide:"
    error "1. SB_SIGN_KEY:    Path to private key"
    error "2. SB_SIGN_CERT:   Path to certificate"
    error "Set these via environment variables:"
    error "   export SB_SIGN_KEY=/path/to/key"
    error "   export SB_SIGN_CERT=/path/to/cert"
    error "**********************************************"
    exit 1
  fi

  # Set cmdline parameters
  local cmdline_quiet="quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3 vt.global_cursor_default=0"
  local cmdline_root="root=PARTLABEL=linux rw"
  local cmdline_console="console=tty0"
  local cmdline_other="systemd.gpt_auto=no cryptomgr.notests"

  # Generate and sign UKI
  mkdir -p "${pkgdir}/boot/efi/EFI/arch"
  ukify build \
    --linux="${pkgdir}/boot/vmlinux-${kernver}" \
    --cmdline="${cmdline_console} ${cmdline_root} ${cmdline_quiet} ${cmdline_other}" \
    --uname="${kernver}" \
    --devicetree="${pkgdir}/boot/dtb-${kernver}" \
    --os-release="Arch Linux ARM" \
    --secureboot-private-key="$SB_SIGN_KEY" \
    --secureboot-certificate="$SB_SIGN_CERT" \
    --output="${pkgdir}/boot/efi/EFI/arch/uki-${kernver}.efi"
}

_package-headers() {
  pkgdesc="Header files and scripts for building modules for linux kernel - ${_desc}"
  provides=("linux-headers=${pkgver}")
  conflicts=('linux-headers')

  cd $_srcname
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  echo "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/arm64" -m644 arch/arm64/Makefile
  cp -t "$builddir" -a scripts

  # add xfs and shmem for aufs building
  mkdir -p "$builddir"/{fs/xfs,mm}

  echo "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/arm64" -a arch/arm64/include
  install -Dt "$builddir/arch/arm64/kernel" -m644 arch/arm64/kernel/asm-offsets.s
  mkdir -p "$builddir/arch/arm"
  cp -t "$builddir/arch/arm" -a arch/arm/include

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

  # https://bugs.archlinux.org/task/13146
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # https://bugs.archlinux.org/task/20402
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h

  # https://bugs.archlinux.org/task/71392
  install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

  echo "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  echo "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */arm64/ || $arch == */arm/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  echo "Removing documentation..."
  rm -r "$builddir/Documentation"

  echo "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  echo "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  echo "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -bi "$file")" in
      application/x-sharedlib\;*)      # Libraries (.so)
        strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  echo "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

pkgname=("${pkgbase}" "${pkgbase}-headers" "${pkgbase}-uki")
for _p in ${pkgname[@]}; do
  eval "package_${_p}() {
    _package${_p#${pkgbase}}
  }"
done
