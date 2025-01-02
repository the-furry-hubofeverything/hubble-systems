{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    trash-cli
  ];

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  environment.shellAliases = {
    rm = "echo -e 'warning: use of rm discouraged. Either use trash-put or bypass this warning using \\\\rm'";
  };
}
