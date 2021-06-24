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
    '';
    repos = {
      github = {
        serokell = {
          aquarius-infra = {};
          gemini-infra = {};
          pegasus-infra = {};
        };
      };
    };
    settings = {
      author.email = "operations+update@serokell.io";
      extra_body = "CC @serokell/operations";
    };
  };
}
