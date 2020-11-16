{ config, pkgs, lib, ... }@args:
let
  inherit (lib) mkMerge mapAttrsToList;
  buildkite = import ../../common/buildkite.nix args;
in
  mkMerge (mapAttrsToList buildkite.mkBuildkite {
    docker = {
      runtimePackages = [ pkgs.docker ];
      tags.queue = "docker";
    };
  })
