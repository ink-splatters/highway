{
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    options = {
      optimize = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
      };
      toolchain = lib.mkOption {
        type = lib.types.attrs;
      };
    };

    config = {
      optimize = pkgs.callPackage ./optimize.nix {};

      toolchain = let
        inherit (pkgs.llvmPackages_latest) stdenv clang bintools;
      in {
        inherit stdenv;
        packages = with pkgs;
          [
            cmake
            ninja
          ]
          ++ [
            clang
            bintools
          ];
      };
    };
  };
}
