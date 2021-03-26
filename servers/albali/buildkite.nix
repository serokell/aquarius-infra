{ config, pkgs, lib, ... }@args:
let
  inherit (lib) mkMerge mapAttrsToList;
  buildkite = import ../../common/buildkite.nix args;
in
  mkMerge (mapAttrsToList buildkite.mkBuildkite {
    # Concurrent runners
    public = { count = 8; };
    private = { count = 8; tags.private = "true"; };
  })
