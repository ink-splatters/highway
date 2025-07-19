{inputs, ...}: {
  imports = [
    inputs.git-hooks.flakeModule
    ./shell.nix
    ./pre-commit.nix
    ../toolchain/default.nix
  ];

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}
