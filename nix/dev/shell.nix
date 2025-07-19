{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) pre-commit toolchain;
  in {
    devShells.default = pkgs.mkShell {
      nativeBuildInputs =
        pre-commit.settings.enabledPackages
        ++ toolchain.packages;
      shellHook = pre-commit.installationScript;
    };
  };
}
