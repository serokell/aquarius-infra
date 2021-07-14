{ config, pkgs, lib, inputs, ... }: {
  vault-secrets.secrets.update-daemon = {
    secretsAreBase64 = true;
  };

  services.update-daemon = {
    enable = true;
    secretFile = "${config.vault-secrets.secrets.update-daemon}/environment";
    agentSetup = ''
      export PATH="$PATH":${lib.makeBinPath [ pkgs.openssh ]}
      if [[ -z "''${SSH_AGENT_PID:-}" ]] ; then
        echo "Starting an ephemeral ssh-agent" >&2;
        eval "$(ssh-agent -s)"
      fi
      cat ${config.vault-secrets.secrets.update-daemon}/private_ssh_key | env SSH_ASKPASS="$(command -v false)" ssh-add -
      mkdir -p "$HOME/.local/share/nix"
      echo '"flake-registry":{"https://github.com/serokell/flake-registry/raw/master/flake-registry.json":true}' > "$HOME/.local/share/nix/trusted-settings.json"
    '';
    repos = {
      github = {
        serokell = {
          aquarius-infra = {};
          gemini-infra = {};
          pegasus-infra = {};
          bootes-infra = {};
          cetus-infra = {};
          common-infra = {};
          deploy-rs = {};
          edna = {};
          gemini-infra = {};
          ment_licence = {};
          nix-pandoc = {};
          pegasus-infra = {};
          pont = {};
          pont-sync = {};
          proton-assurance-initial = {
            default_branch = "main";
          };
          sagittarius-infra = {};
          serokell-infra = {};
          serokell-website = {};
          swampwalk = {};
          systemd-nix = {};
          templates = {};
          test-task-gen-check = {};
          tezos-infra = {};
          update-daemon = {};
          vault-secrets = {};
        };
        stakerdao = {
          bridge-web = {};
        };
      };
    };
    settings = {
      author.email = "operations+update@serokell.io";
      extra_body = "CC @serokell/operations";
    };
  };
}
