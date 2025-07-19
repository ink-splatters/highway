{
  gtest,
  lib,
  stdenv,
  nativeBuildInputs,
  ...
}: let
  inherit (lib) getDev getLib optionals;
  libExt = stdenv.hostPlatform.extensions.library;
in
  stdenv.mkDerivation rec {
    pname = "libhwy";
    version = "unstable";

    src = ../.;

    inherit nativeBuildInputs;

    # Required for case-insensitive filesystems ("BUILD" exists)
    dontUseCmakeBuildDir = true;

    # TODO: enable testing
    doCheck = false;

    cmakeFlags =
      [
        "-GNinja"
        "-DCMAKE_INSTALL_LIBDIR=lib"
        "-DCMAKE_INSTALL_INCLUDEDIR=include"
      ]
      ++ optionals doCheck [
        "-DHWY_SYSTEM_GTEST:BOOL=ON"
        "-DGTEST_INCLUDE_DIR=${getDev gtest}/include"
        "-DGTEST_LIBRARY=${getLib gtest}/lib/libgtest${libExt}"
        "-DGTEST_MAIN_LIBRARY=${getLib gtest}/lib/libgtest_main${libExt}"
      ];

    meta = with lib; {
      description = "Performance-portable, length-agnostic SIMD with runtime dispatch";
      homepage = "https://github.com/google/highway";
      license = with licenses; [
        asl20
        bsd3
      ];
      platforms = platforms.unix;
      maintainers = with maintainers; [zhaofengli];
    };
  }
