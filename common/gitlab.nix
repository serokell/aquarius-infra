{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate;
in {
  shellRunner = registrationTokenFile: extraConfig: (recursiveUpdate {
    executor = "shell";
    tagList = [ "shell-executor" "nix" ];
    runUntagged = true;

    registrationConfigFile = pkgs.writeText "gitlab-registration.sh" ''
      CI_SERVER_URL="https://gitlab.com/"
      REGISTRATION_TOKEN=$(cat ${lib.escapeShellArg registrationTokenFile})
    '';

    # gitlab-runner may reuse an existing checkout, but it will fail to clean
    # it up if it contains non-writable directories (e.g. copied from the nix
    # store by the previous job). This script makes all directories writable.
    # Upstream issue: https://gitlab.com/gitlab-org/gitlab-runner/-/issues/164
    preCloneScript = pkgs.writeShellScript "make-directories-writable.sh" ''
      if [ -d "$CI_PROJECT_DIR" ]; then
      # ignoring .git, find directories with 'w' bit unset and set the bit
      find "$CI_PROJECT_DIR" \
      -path "$CI_PROJECT_DIR/.git" -prune \
      -o "(" -type d -a -not -perm -u=w ")" -exec chmod --verbose u+w {} ";"
      fi
      '';
  } extraConfig);
}
