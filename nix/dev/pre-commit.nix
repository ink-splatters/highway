{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    pre-commit = {
      check.enable = true;

      settings.hooks = {
        deadnix.enable = true;
        # TODO: cpp tools
        # markdownlint = {
        #   enable = true;
        #   settings.configuration = {
        #     MD013.line_length = 130;
        #   };
        # };
        nil.enable = true;
        alejandra.enable = true;
        statix.enable = true;
      };
    };

    apps.install-hooks = {
      type = "app";
      program = toString (pkgs.writeShellScript "install-hooks" ''
        ${config.pre-commit.installationScript}
        echo Done!
      '');
      meta.description = "install pre-commit hooks";
    };
  };
}
