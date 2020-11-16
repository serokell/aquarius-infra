{ config, pkgs, lib, ... }:
let
  inherit (lib) mkMerge mapAttrsToList recursiveUpdate;

  vs = config.vault-secrets.secrets;

  mkBuildkite = name: extraConfig: {
    vault-secrets.secrets."buildkite-agent-${name}".user =
      "buildkite-agent-${name}";
    systemd.services."buildkite-agent-${name}".serviceConfig.EnvironmentFile =
      "/root/service.env.d/buildkite-${name}";
    services.buildkite-agents.${name} = (recursiveUpdate {
      runtimePackages = with pkgs; [
        bash
        bzip2
        cachix
        gnutar
        gzip
        jq
        nix
        procps
        vault-bin
        xz
      ];
      hooks = {
        environment = "source ${./scripts/vault-env-hook}";
        pre-exit = "source ${./scripts/vault-exit-hook}";
      };
      tokenPath = "${vs."buildkite-agent-${name}"}/token";
      tags = {
        system = pkgs.stdenv.system;
      };
    } extraConfig);
  };
in
  mkMerge (mapAttrsToList mkBuildkite {
    public = {};
    private = { tags.private = "true"; };
    public-sched = { tags.queue = "scheduled"; };
  })
