{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./buildkite.nix
    ./gitlab.nix
  ];

  boot.cleanTmpDir = true;
  networking.hostName = "bunda";

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
