{ config, pkgs, lib, ...}:
let
  vs = config.vault-secrets.secrets;
  cache = "s3://serokell-private-cache?endpoint=s3.eu-central-1.wasabisys.com&narinfo-compression=bzip2&compression=xz&parallel-compression=1";
in
{
  vault-secrets.secrets.nix.services = [];

  # contains AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for wasabi
  vault-secrets.secrets.upload-daemon = {};

  services.upload-daemon = {
    enable = true;
    target = cache;
    prometheusPort = 8082;
    post-build-hook = {
      enable = true;
      secretKey = "${vs.nix}/key";
    };
  };

  systemd.services.upload-daemon.serviceConfig.EnvironmentFile = "${vs.upload-daemon}/environment";
}
