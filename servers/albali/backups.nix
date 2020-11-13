{ config, pkgs, lib, ... }:
let vs = config.vault-secrets.secrets;
in {

  systemd.tmpfiles.rules = [
    # https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html
    "d /var/lib/backup 0700 -"
  ];

  vault-secrets.secrets.borgbackup = {
    secretsBase64 = true;
    services = [ "borgbackup-job-albali" ];
  };
  services.borgbackup.jobs.albali = {
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${vs.borgbackup}/repo_password";
    };

    environment = {
      BORG_REMOTE_PATH = "borg1";
      BORG_RSH = "ssh -i ${vs.borgbackup}/ssh_private_key";
    };

    privateTmp = false; # need postgres socket

    exclude = [
      "**/.cabal"
      "**/.stack-work"
      "**/.stack"
      "**/.cache"
      "/var/lib/buildkite-agent*/builds"
      "/var/lib/gitlab-runner"
      "/var/lib/docker"
    ];

    readWritePaths = [ "/tmp" "/var/lib/backup" ];

    prune.keep = {
      within = "7d"; # hourly backups for the past week
      daily = 14; # daily backups for two weeks before that
      weekly = 4; # weekly backups for a month before that
      monthly = 6; # monthly backups for 6 months before that
    };

    paths = [ "/root" "/var/lib" ];

    repo = "12481@ch-s012.rsync.net:./albali";
    startAt = "hourly";
  };

  systemd.services.borgbackup-job-albali =
    lib.mkIf (builtins.hasAttr "albali" config.services.borgbackup.jobs) rec {
      unitConfig = {
        StartLimitInterval = 300;
        StartLimitBurst = 3;
      };

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 10;
      };
    };

}
