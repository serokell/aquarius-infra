{ config, pkgs, lib, ... }@args:
let
  vs = config.vault-secrets.secrets;
  gitlab = import ../../common/gitlab.nix args;
in rec {
  vault-secrets.secrets.gitlab-runner = { };
  services.gitlab-runner = {
    enable = true;
    concurrent = 2;
    services = {
      # https://gitlab.com/morley-framework
      morley-shell = gitlab.shellRunner "${vs.gitlab-runner}/REG_TOKEN_MORLEY_SHELL"
        { runUntagged = false;
          tagList = [ "nix-with-docker" ];
        };

      # https://gitlab.com/serokell
      shell = gitlab.shellRunner "${vs.gitlab-runner}/REG_TOKEN_SHELL"
        { runUntagged = false;
          tagList = [ "nix-with-docker" ];
        };
    };
  };

  environment.systemPackages = [ pkgs.git ];
}
