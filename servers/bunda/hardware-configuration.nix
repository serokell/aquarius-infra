{ config, lib, pkgs, inputs, ... }:
{
  imports = [ "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix" ];
  boot.loader.grub.device = "/dev/sda";
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
}
