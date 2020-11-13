{ config, pkgs, lib, ... }:
let vs = config.vault-secrets.secrets;
in {
  vault-secrets.secrets.buildkite-agent-public.user = "buildkite-agent-public";
  services.buildkite-agents.public = {
    runtimePackages = with pkgs; [
      bash
      xz
      nix
      gnutar
      bzip2
      gzip
      cachix
      vault-bin
      jq
      procps
      podman
    ];
    hooks = {
      environment = "source ${./scripts/vault-env-hook}";
      pre-exit = "source ${./scripts/vault-exit-hook}";
    };
    tokenPath = "${vs.buildkite-agent-public}/token";
    tags.system = pkgs.stdenv.system;
  };
  systemd.services.buildkite-agent-public = {
    serviceConfig.EnvironmentFile = "/root/service.env.d/buildkite-public";
    preStart = lib.mkAfter ''
      mkdir -p $HOME/cd
      chmod og+x $HOME $HOME/cd
      chmod o+r $HOME/cd
    '';
  };

  vault-secrets.secrets.buildkite-agent-private.user =
    "buildkite-agent-private";
  services.buildkite-agents.private = {
    runtimePackages = with pkgs; [
      bash
      xz
      nix
      gnutar
      bzip2
      gzip
      vault-bin
      jq
      procps
    ];
    hooks = {
      environment = "source ${./scripts/vault-env-hook}";
      pre-exit = "source ${./scripts/vault-exit-hook}";
    };
    tokenPath = "${vs.buildkite-agent-private}/token";
    tags.system = pkgs.stdenv.system;
    # This runner has the necessary SSH key to clone private Serokell repos
    tags.private = "true";
    tags.nix = "true";
  };

  systemd.services.buildkite-agent-private = {
    serviceConfig.EnvironmentFile = "/root/service.env.d/buildkite-private";
    preStart = lib.mkAfter ''
      mkdir -p $HOME/cd
      chmod o+x $HOME $HOME/cd
      chmod o+r $HOME/cd
    '';
  };

  # use a separate buildkite agent for scheduled jobs, so they will not stall regular jobs
  vault-secrets.secrets.buildkite-agent-public-sched.user =
    "buildkite-agent-public-sched";
  services.buildkite-agents.public-sched = {
    runtimePackages = with pkgs; [
      bash
      xz
      nix
      gnutar
      bzip2
      gzip
      cachix
      vault-bin
      jq
      procps
    ];
    hooks = {
      environment = "source ${./scripts/vault-env-hook}";
      pre-exit = "source ${./scripts/vault-exit-hook}";
    };
    tokenPath = "${vs.buildkite-agent-public-sched}/token";
    tags.system = pkgs.stdenv.system;
    tags.queue = "scheduled";
  };
  systemd.services.buildkite-agent-public-sched = {
    serviceConfig.EnvironmentFile =
      "/root/service.env.d/buildkite-public-sched";
  };

  security.sudo.extraRules = [{
    users = [ "buildkite-agent-private" "buildkite-agent-public" ];
    commands = [
      {
        command = "/run/current-system/sw/bin/systemctl restart *";
        options = [ "NOPASSWD" ];
      }

      {
        command = "/run/current-system/sw/bin/systemctl start *";
        options = [ "NOPASSWD" ];
      }
      {
        command =
          "/usr/bin/env -u SUDO_USER /run/current-system/sw/bin/nixos-rebuild switch";
        options = [ "NOPASSWD" ];
      }
    ];
  }];

}
