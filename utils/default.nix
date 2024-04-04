lib: {
  sops = {
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
  };
}