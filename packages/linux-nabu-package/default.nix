{
  lib,
  stdenv,
  kmod,
  rsync,
}:

let
  kernelSrc = builtins.storePath "/nix/store/f4my72g0skilh6496w9p34000dw853kf-linux-nabu-6.16.0";
  modDirVersion = "6.16.0-3-nabu-ARCH";
  version = "6.16.0";

  readConfig =
    configfile:
    let
      matchLine =
        line:
        let
          match = builtins.match "(CONFIG_[^=]+)=([ym])" line;
        in
        lib.optional (match != null) {
          name = builtins.elemAt match 0;
          value = builtins.elemAt match 1;
        };
    in
    lib.listToAttrs (lib.concatMap matchLine (lib.splitString "\n" (builtins.readFile configfile)));

  configContents = readConfig "${kernelSrc}/.config";

  config =
    let
      attrName = attr: "CONFIG_" + attr;
    in
    {
      isSet = attr: builtins.hasAttr (attrName attr) configContents;
      getValue =
        attr: if config.isSet attr then builtins.getAttr (attrName attr) configContents else null;
      isYes = attr: (config.getValue attr) == "y";
      isNo = attr: (config.getValue attr) == "n";
      isModule = attr: (config.getValue attr) == "m";
      isEnabled = attr: (config.isModule attr) || (config.isYes attr);
      isDisabled = attr: (!(config.isSet attr)) || (config.isNo attr);
    };
in
stdenv.mkDerivation {
  pname = "linux-nabu";
  inherit version;

  outputs = [
    "out"
    "dev"
    "modules"
  ];

  src = kernelSrc;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheckForBrokenSymlinks = true;

  nativeBuildInputs = [
    kmod
    rsync
  ];

  installPhase = ''
    runHook preInstall

    # out: kernel image + System.map
    mkdir -p $out
    cp ${kernelSrc}/arch/arm64/boot/Image $out/
    cp ${kernelSrc}/System.map $out/

    # modules: install .ko files
    mkdir -p $modules/lib/modules/${modDirVersion}/kernel
    cd ${kernelSrc}
    find . -name '*.ko' -type f -print0 | while IFS= read -r -d $'\0' f; do
      relpath="''${f#./}"
      dest="$modules/lib/modules/${modDirVersion}/kernel/$relpath"
      mkdir -p "$(dirname "$dest")"
      cp "$f" "$dest"
    done
    cp modules.order $modules/lib/modules/${modDirVersion}/
    cp modules.builtin $modules/lib/modules/${modDirVersion}/
    cp modules.builtin.modinfo $modules/lib/modules/${modDirVersion}/
    cp Module.symvers $modules/lib/modules/${modDirVersion}/
    depmod -b $modules -F ${kernelSrc}/System.map ${modDirVersion}
    rm -f $modules/lib/modules/${modDirVersion}/build

    # dev: vmlinux + build/source trees
    mkdir -p $dev
    cp ${kernelSrc}/vmlinux $dev/

    # source tree (exclude intermediate build artifacts)
    mkdir -p $dev/lib/modules/${modDirVersion}/source
    rsync -a --prune-empty-dirs \
      --exclude='/.tmp_*' \
      --exclude='/.*.cmd' \
      --exclude='/*.o' \
      --exclude='/*.a' \
      --exclude='/*.ko' \
      --exclude='/build/' \
      ${kernelSrc}/ $dev/lib/modules/${modDirVersion}/source/

    # build -> source symlink (kernel is built in-tree, so source = build)
    ln -s source $dev/lib/modules/${modDirVersion}/build

    runHook postInstall
  '';

  passthru = rec {
    inherit
      version
      modDirVersion
      config
      stdenv
      ;
    moduleBuildDependencies = [ ];
    commonMakeFlags = [ "ARCH=arm64" ];
    baseVersion = lib.head (lib.splitString "-rc" version);
    kernelOlder = lib.versionOlder baseVersion;
    kernelAtLeast = lib.versionAtLeast baseVersion;
    isLTS = false;
    isZen = false;
    features = { };
    target = "Image";
    buildDTBs = false;
    configfile = "${kernelSrc}/.config";
    kernelPatches = [ ];
    withRust = false;
  };

  meta = {
    description = "Linux kernel for Xiaomi Mi Pad 5 (nabu)";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
