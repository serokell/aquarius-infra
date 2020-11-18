{ config, pkgs, inputs, ... }:
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./builders.nix

    inputs.upload-daemon.nixosModules.upload-daemon
    ./upload-daemon.nix

    ./local-chain-tezos-node.nix
    ./chain.nix

    ./backups.nix

    ./buildkite.nix

    ./gitlab.nix
  ];


  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  };

  networking.hostName = "albali";

  # The mdadm RAID1s were created with 'mdadm --create ... --homehost=hetzner',
  # but the hostname for each machine may be different, and mdadm's HOMEHOST
  # setting defaults to '<system>' (using the system hostname).
  # This results mdadm considering such disks as "foreign" as opposed to
  # "local", and showing them as e.g. '/dev/md/hetzner:root0'
  # instead of '/dev/md/root0'.
  # This is mdadm's protection against accidentally putting a RAID disk
  # into the wrong machine and corrupting data by accidental sync, see
  # https://bugzilla.redhat.com/show_bug.cgi?id=606481#c14 and onward.
  # We set the HOMEHOST manually go get the short '/dev/md' names,
  # and so that things look and are configured the same on all such
  # machines irrespective of host names.
  # We do not worry about plugging disks into the wrong machine because
  # we will never exchange disks between machines.
  environment.etc."mdadm.conf".text = ''
    HOMEHOST hetzner
  '';
  # The RAIDs are assembled in stage1, so we need to make the config
  # available there.
  boot.initrd.mdadmConf = config.environment.etc."mdadm.conf".text;

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.interfaces."enp35s0".ipv4.addresses = [{
    address = "135.181.117.245";
    prefixLength = 24;
  }];
  networking.interfaces."enp35s0".ipv6.addresses = [{
    address = "2a01:4f9:4b:1dca::1";
    prefixLength = 64;
  }];
  networking.defaultGateway = "135.181.117.193";
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp35s0";
  };
  networking.nameservers = [ "8.8.8.8" ];
}
