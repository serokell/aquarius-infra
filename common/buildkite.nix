{ config, pkgs, lib, inputs, ... }:
let
  inherit (lib) mkMerge range;
  inherit (builtins) map;

  vs = config.vault-secrets.secrets;
in {
  mkBuildkite = name: extraConfig: {
    vault-secrets.secrets."buildkite-agent-${name}" = {
      user = "buildkite-agent-${name}";
      services = let
        c = extraConfig.count or 1;
      in map (n: "buildkite-agent-${name}-${toString n}") (range 1 c);
    };

    services.buildkite-agents.${name} = (mkMerge [
      {
        runtimePackages = with pkgs; [
          bash
          bzip2
          cachix
          gnupg
          gnutar
          gzip
          jq
          nix
          procps
          vault-bin
          xz
          (pkgs.writeScriptBin "nix-unstable" ''
            #!${pkgs.stdenv.shell}
            ${inputs.nix-master.packages.${pkgs.system}.nix}/bin/nix "$@"
          '')
        ];
        extraServiceConfig.EnvironmentFile = "/root/service.env.d/buildkite-${name}";
        hooks = {
          environment = "source ${./scripts/vault-env-hook}";
          pre-exit = "source ${./scripts/vault-exit-hook}";
        };
        tokenPath = "${vs."buildkite-agent-${name}"}/token";
        tags = {
          system = pkgs.stdenv.system;
        };
      }
      extraConfig
    ]);
  };
}
