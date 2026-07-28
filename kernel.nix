{
  lib,
  stdenv,
  fetchurl,
  flex,
  bison,
  perl,
  bc,
  openssl,
  elfutils,
  pahole,
  dtc,
  ubootTools,
  kmod,
  cpio,
  gzip,
  lz4,
  xz,
  zlib,

  python3,
}:
stdenv.mkDerivation {
  pname = "linux-nabu";
  version = "6.16.0";

  src = fetchurl {
    url = "https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.16.tar.xz";
    sha256 = "1a4be2fe6b5246aa4ac8987a8a4af34c42a8dd7d08b46ab48516bcc1befbcd83";
  };

  nativeBuildInputs = [
    # AI suggest
    flex
    bison
    perl
    bc
    openssl
    elfutils
    pahole
    dtc
    ubootTools
    kmod
    cpio
    gzip
    lz4
    xz
    zlib

    # Error suggest
    python3
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

  meta = with lib; {
    description = "The Linux Kernel - AArch64 Xiaomi Pad 5";
    homepage = "https://www.kernel.org/";
    license = licenses.gpl2;
    platforms = platforms.aarch64;
  };
}
