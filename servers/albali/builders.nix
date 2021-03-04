{ config, pkgs, lib, ... }: {
  nix = {
    distributedBuilds = true;
    buildMachines = [{
      hostName = "df181.macincloud.com";
      system = "x86_64-darwin";
      sshUser = "admin";
      sshKey = "${config.vault-secrets.secrets.mac-builder}/ssh_key";
      maxJobs = 8;
    }];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  vault-secrets.secrets.mac-builder = { services = [ "nix-daemon" ]; };
}
