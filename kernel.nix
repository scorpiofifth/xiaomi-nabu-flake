{
  bc,
  bison,
  cpio,
  dtc,
  elfutils,
  fetchurl,
  flex,
  gzip,
  kmod,
  lib,
  lz4,
  openssl,
  pahole,
  perl,
  python3,
  stdenv,
  ubootTools,
  xz,
  zlib,
}:
stdenv.mkDerivation {
  pname = "linux-nabu";
  version = "6.16.0";

  src = fetchurl {
    url = "https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.16.tar.xz";
    sha256 = "1a4be2fe6b5246aa4ac8987a8a4af34c42a8dd7d08b46ab48516bcc1befbcd83";
  };

  nativeBuildInputs = [
    bc
    bison
    cpio
    dtc
    elfutils
    flex
    gzip
    kmod
    lz4
    openssl
    pahole
    perl
    python3
    ubootTools
    xz
    zlib
  ];

  patchPhase = ''
    # NOTE: it was to turn the log smaller
    echo "::endgroup::"

    for patch in $(ls ${./patches}/*.patch | sort); do
      echo "::group:: patchPhase: $(basename $patch)"
      patch -Np1 < "$patch"
      echo "::endgroup::"
    done
  '';

  configurePhase = ''
    echo "::group:: configurePhase"
    echo "-3" > localversion.10-pkgrel
    echo "-nabu" > localversion.20-pkgname
    cp ${./kernel/config} ./.config
    make olddefconfig
    echo "::endgroup::"
  '';

  buildPhase = ''
    echo "::group:: buildPhase"
    make prepare
    make -s kernelrelease > version
    make -j$(nproc) Image Image.gz modules
    make -j$(nproc) DTC_FLAGS="-@" dtbs
    echo "::endgroup::"
  '';

  enableParallelBuilding = true;

  # dontInstall = true;
  installPhase = ''
    echo "::group:: installPhase"
    mkdir -p $out
    cp -r . $out/
    # mkdir -p $out/boot
    # cp arch/arm64/boot/Image $out/boot/
    # cp arch/arm64/boot/Image.gz $out/boot/
    # find . -name "*.dtb" -exec cp {} $out/boot/ \;
    # cp -r arch/arm64/boot/dts $out/boot/
    # cp .config $out/
    # cp version $out/
    echo "::endgroup::"
  '';

  dontFixup = true;

  meta = with lib; {
    description = "The Linux Kernel - AArch64 Xiaomi Pad 5";
    homepage = "https://www.kernel.org/";
    license = licenses.gpl2;
    platforms = platforms.aarch64;
  };
}
