lib: {
  sops = rec {
    # Functions used to detect if a secret is defined or not
    # VERY IMPORTANT - set sops.defaultSopsFile to an EMPTY file
    # It works by checking if the file is empty

    # sopsConfig: the entire sops config (config.sops)
    # secret: name of the secret

    # isAnyDefault checks if secrets are using the default SOPS file, returns true if any of them are.
    isAnyDefault = sopsConfig: builtins.any (x: x.value.sopsFile == sopsConfig.defaultSopsFile) (lib.attrsToList sopsConfig.secrets);

    # isDefault checks if the secret sepecified is using the default SOPS file.
    isDefault = sopsConfig: secret: sopsConfig.secrets.${secret}.sopsFile == sopsConfig.defaultSopsFile;

    # defaultIsEmpty should always be true, or else this method would not be accurate.
    defaultIsEmpty = sopsConfig: builtins.readFile sopsConfig.defaultSopsFile == "";

    # mkWarning checks if the secret is defined, and if so, passes the secret.
    # If it detects that the secret is undefined, then it will print a warning,
    # and then passes a placeholder.
    mkWarning = sopsConfig: secret: warning: placeholder:
      if isDefault sopsConfig secret
      then lib.warn warning placeholder
      else sopsConfig.secrets.${secret}.path;
  };
}
