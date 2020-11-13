{ config, inputs, ... }: {
  imports = [ inputs.serokell-nix.nixosModules.serokell-users inputs.serokell-nix.nixosModules.vault-secrets ];

  networking.domain = "aquarius.serokell.team";

  vault-secrets = {
    vaultPathPrefix = "kv/sys/aquarius";
    vaultAddress = "https://vault.serokell.org:8200";
    namespace = config.networking.hostName;
  };
}
