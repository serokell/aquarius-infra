{ config, pkgs, lib, ...}:
let
  vs = config.vault-secrets.secrets;

  credentialsTemplate = pkgs.writeText "credentials-template" ''
    [wasabi]
    aws_access_key_id=$WASABI_ACCESS_KEY_ID
    aws_secret_access_key=$WASABI_SECRET_ACCESS_KEY

    [backblaze]
    aws_access_key_id=$BACKBLAZE_ACCESS_KEY_ID
    aws_secret_access_key=$BACKBLAZE_SECRET_ACCESS_KEY
  '';

in
{
  nix.binaryCaches = [
    "s3://serokell-private-nix-cache?endpoint=s3.us-west-000.backblazeb2.com&profile=backblaze-cache-read"
  ];

  vault-secrets.secrets.nix.services = [];

  vault-secrets.secrets.upload-daemon.extraScript = ''
    source "$secretsPath/environment"
    export $(cut -d= -f1 "$secretsPath/environment")
    ${pkgs.envsubst}/bin/envsubst -no-unset -i ${credentialsTemplate} -o $secretsPath/aws_credentials
  '';

  services.upload-daemon = {
    enable = true;
    targets =
      let commonOptions = "&narinfo-compression=bzip2&compression=xz&parallel-compression=1";
      in [
        "s3://serokell-private-cache?endpoint=s3.eu-central-1.wasabisys.com&profile=wasabi${commonOptions}"
        "s3://serokell-private-nix-cache?endpoint=s3.us-west-000.backblazeb2.com&profile=backblaze${commonOptions}"
      ];
    prometheusPort = 8082;
    post-build-hook = {
      enable = true;
      secretKey = "${vs.nix}/key";
    };
  };

  systemd.services.upload-daemon.serviceConfig.Environment = [
    "AWS_SHARED_CREDENTIALS_FILE=${vs.upload-daemon}/aws_credentials"
  ];
}
