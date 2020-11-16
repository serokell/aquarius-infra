{ config, pkgs, lib, ... }@args:
let
  inherit (lib) mkMerge mapAttrsToList;
  buildkite = import ../../common/buildkite.nix args;
in
  mkMerge (mapAttrsToList buildkite.mkBuildkite {
    public = {};
    private = { tags.private = "true"; };
    public-sched = { tags.queue = "scheduled"; };
  })
