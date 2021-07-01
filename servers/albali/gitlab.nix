{ config, pkgs, lib, ... }@args:
let
  vs = config.vault-secrets.secrets;
  gitlab = import ../../common/gitlab.nix args;
in rec {
  vault-secrets.secrets.gitlab-runner = { };
  services.gitlab-runner = {
    enable = true;
    concurrent = 4;
    services = {
      # https://gitlab.com/morley-framework
      morley-shell = gitlab.shellRunner "${vs.gitlab-runner}/REG_TOKEN_MORLEY_SHELL" {};

      # https://gitlab.com/serokell
      shell = gitlab.shellRunner "${vs.gitlab-runner}/REG_TOKEN_SHELL" {
        runUntagged = false;
      };

      # https://gitlab.com/tezosagora
      agora-shell = gitlab.shellRunner "${vs.gitlab-runner}/REG_TOKEN_AGORA_SHELL" {};

      # https://gitlab.com/indigo-lang
      indigo-lang = gitlab.shellRunner "${vs.gitlab-runner}/REG_TOKEN_INDIGO_LANG" {};

      # https://gitlab.com/tezos-kiln
      tezos-kiln = gitlab.shellRunner "${vs.gitlab-runner}/REG_TOKEN_KILN_SHELL" {};
    };
  };

  environment.systemPackages = [ pkgs.git ];
}
