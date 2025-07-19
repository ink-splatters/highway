{
  imports = [
    ./toolchain/default.nix
  ];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    packages.libhwy = config.optimize {
      drv = pkgs.callPackage ./libhwy.nix {nativeBuildInputs = config.toolchain.packages;};
    };
  };
}
