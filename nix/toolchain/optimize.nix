{
  cmake,
  lib,
  llvmPackages_latest,
  ninja,
}: {
  /*
  drv,
  */
  enableNative ? true,
  disableHardening ? true,
  buildInputsExtra ? [],
  nativeBuildInputsExtra ? [],
  cmakeFlagsExtra ? [],
  makeFlagsExtra ? [],
  preConfigureExtra ? "",
  preBuildExtra ? "",
  compileFlags ? "-O3 -Wall -mcpu=native -flto=thin -pipe",
  ldFlags ? "-flto=thin -fuse-ld=lld -Wl,-dead_strip",
  ...
} @ args: let
  inherit (llvmPackages_latest) stdenv clang bintools;
  inherit (lib) concatStringsSep elem optionals optionalString;
  inherit (builtins) hasAttr;

  drv =
    if hasAttr "stdenv" args.drv.override.__functionArgs
    then args.drv.override {inherit stdenv;}
    else args.drv;
in
  drv.overrideAttrs (_oa: let
    has = name: hasAttr name _oa;
    hasIn = el: lst: has lst && elem el _oa."${lst}";

    parentAttr = lst: optionals (has lst) _oa."${lst}";
    parentStrAttr = str: optionalString (has str) _oa."${str}";

    BI = "buildInputs";

    NBI = "nativeBuildInputs";
    hasInNBI = elem: hasIn elem NBI;

    MF = "makeFlags";
    CMF = "cmakeFlags";
    PCFG = "preConfigure";
    PB = "preBuild";
    CF = "CFLAGS";
    CXXF = "CXXFLAGS";
    CPPF = "CPPFLAGS";
    LDF = "LDFLAGS";

    hasCMake = hasInNBI cmake;
    hasNinja = hasInNBI ninja;
    hasClang = hasInNBI clang;
    hasBintools = hasInNBI bintools;

    isCMake = hasCMake;
    isMake = !isCMake && ((has MF) || makeFlagsExtra != []);

    isPlain = !isCMake && !isMake;
    compileFlagsIfPlain = optionalString isPlain compileFlags;
  in {
    buildInputs = parentAttr BI ++ buildInputsExtra;

    nativeBuildInputs =
      parentAttr NBI
      ++ nativeBuildInputsExtra
      ++ optionals (isCMake && !hasNinja) [ninja]
      ++ optionals (!hasClang) [clang]
      ++ optionals (!hasBintools) [bintools];

    hardeningDisable = optionals disableHardening ["all"];

    cmakeFlags = parentAttr CMF ++ cmakeFlagsExtra;
    makeFlags = parentAttr MF ++ makeFlagsExtra;

    CFLAGS = concatStringsSep " " [compileFlagsIfPlain (parentStrAttr CF)];
    CXXFLAGS = concatStringsSep " " [compileFlagsIfPlain (parentStrAttr CXXF)];
    CPPFLAGS = concatStringsSep " " [compileFlagsIfPlain (parentStrAttr CPPF)];
    LDFLAGS = concatStringsSep " " [compileFlagsIfPlain (parentStrAttr LDF)];

    preConfigure =
      parentStrAttr PCFG
      + ''
        ${preConfigureExtra}
      ''
      + optionalString isCMake ''
        cmakeFlagsArray+=(
          "-DCMAKE_C_FLAGS=${compileFlags}"
          "-DCMAKE_CXX_FLAGS=${compileFlags}"
          "-DCMAKE_EXE_LINKER_FLAGS=${ldFlags}"
        )
      '';

    preBuild =
      parentStrAttr PB
      + ''
        ${preBuildExtra}
      ''
      + optionalString isMake ''
        makeFlagsArray+=(
          "CFLAGS=${compileFlags}"
          "CXXFLAGS=${compileFlags}"
          "CPPFLAGS=${compileFlags}"
          "LDFLAGS=${ldFlags}"
        )
      '';

    NIX_ENFORCE_NO_NATIVE = !enableNative;

    enableParallelBuilding = true;
  })
