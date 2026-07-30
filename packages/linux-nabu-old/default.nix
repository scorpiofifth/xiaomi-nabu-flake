{
  bc,
  bison,
  buildPackages,
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
    for patch in $(ls ${./patches}/*.patch | sort); do
      echo "patchPhase: $(basename $patch)"
      patch -Np1 < "$patch"
    done
  '';

  configurePhase = ''
    echo "-3" > localversion.10-pkgrel
    echo "-nabu" > localversion.20-pkgname
    cp ${./kernel.config} ./.config
    make \
      ARCH=arm64 \
      CROSS_COMPILE=${stdenv.cc.targetPrefix} \
      HOSTCC=${buildPackages.stdenv.cc}/bin/cc \
      olddefconfig
  '';

  buildPhase = ''
    make \
      ARCH=arm64 \
      CROSS_COMPILE=${stdenv.cc.targetPrefix} \
      HOSTCC=${buildPackages.stdenv.cc}/bin/cc \
      prepare
    make \
      ARCH=arm64 \
      CROSS_COMPILE=${stdenv.cc.targetPrefix} \
      HOSTCC=${buildPackages.stdenv.cc}/bin/cc \
      -s kernelrelease > version
    make \
      ARCH=arm64 \
      CROSS_COMPILE=${stdenv.cc.targetPrefix} \
      HOSTCC=${buildPackages.stdenv.cc}/bin/cc \
      -j$(nproc) Image Image.gz modules
    make \
      ARCH=arm64 \
      CROSS_COMPILE=${stdenv.cc.targetPrefix} \
      HOSTCC=${buildPackages.stdenv.cc}/bin/cc \
      -j$(nproc) DTC_FLAGS="-@" dtbs
  '';

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  dontFixup = true;

  meta = with lib; {
    description = "The Linux Kernel - AArch64 Xiaomi Pad 5";
    homepage = "https://www.kernel.org/";
    license = licenses.gpl2;
    platforms = platforms.aarch64;
  };
}
