{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    trashy
  ];

  programs.bash = {
    undistractMe = {
      enable = true;
      playSound = true;
      timeout = 90;
    };
  };

  environment.shellAliases = {
    rm = "echo -e 'warning: use of rm discouraged. Either use trashy or bypass this warning using \\\\rm'";
  };
}