{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    trashy
  ];

  environment.shellAliases = {
    rm = "echo -e 'warning: use of rm discouraged. Either use trashy or bypass this warning using \\\\rm'";
  };
}
