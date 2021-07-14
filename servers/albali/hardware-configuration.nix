## Copied verbatim from the server.

## Regenerate with `nixos-generate-config --show-hardware-config`

{ config, lib, pkgs, inputs, ... }:

{
  imports = [ "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix" ];

  boot.initrd.availableKernelModules = [ "ahci" "nvme" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a2cf47df-3d01-4465-ae28-7df9dd68b3d1";
    fsType = "ext4";
  };

  swapDevices = [ ];

  # Make a lot of build users, because nix-build will fail when they are exhausted.
  # There is a fix to wait for users to be available instead of failing, but it's not in stable yet:
  # https://github.com/NixOS/nix/pull/3564
  nix.nrBuildUsers = 128;
  nix.maxJobs = 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
