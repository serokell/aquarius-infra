{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.serokell-nix.nixosModules.hetzner-cloud
    ./buildkite.nix
    ./gitlab.nix
  ];

  boot.cleanTmpDir = true;
  networking.hostName = "bunda";

  hetzner.ipv6Address = "2a01:4f8:1c17:74fb::1";

  users.users.buildkite-agent-docker.extraGroups = [ "docker" ];
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    logLevel = "warn";
    autoPrune = {
      enable = true;
      dates = "daily";
    };
  };
}
