{
  description = "NixOS systems for the build cluster";

  inputs = {
    nixpkgs.url = "github:serokell/nixpkgs";
    serokell-nix.url = "github:serokell/serokell.nix";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    upload-daemon.url = "github:serokell/upload-daemon";
    update-daemon.url = "github:serokell/update-daemon";
    tezos-packaging = {
      url = "github:serokell/tezos-packaging";
      flake = false;
    };
    vault-secrets.url = "github:serokell/vault-secrets";
    nix-master.url = "github:nixos/nix";
  };

  outputs =
    { self, nixpkgs, serokell-nix, deploy-rs, vault-secrets, ... }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem filterAttrs const recursiveUpdate;
      inherit (builtins) readDir mapAttrs;
      system = "x86_64-linux";
      servers = mapAttrs (path: _: import (./servers + "/${path}"))
        (filterAttrs (_: t: t == "directory") (readDir ./servers));
      mkSystem = config:
        nixosSystem {
          inherit system;
          modules = [ config ./common.nix ];
          specialArgs.inputs = inputs;
        };

      deployChecks =
        mapAttrs (_: lib: lib.deployChecks self.deploy) deploy-rs.lib;

      terraformFor = pkgs:
        pkgs.terraform.withPlugins (p: with p; [ aws hcloud vault ]);

      checks = mapAttrs (_: pkgs:
        let pkgs' = pkgs.extend serokell-nix.overlay;
        in {
          trailing-whitespace = pkgs'.build.checkTrailingWhitespace ./.;
          terraform = pkgs.runCommand "terraform-check" {
            src = ./terraform;
            buildInputs = [ (terraformFor pkgs) ];
          } ''
            cp -r $src ./terraform
            terraform init -backend=false terraform
            terraform validate terraform
            touch $out
          '';
        }) nixpkgs.legacyPackages;
    in {
      nixosConfigurations = mapAttrs (const mkSystem) servers;

      deploy = {
        magicRollback = true;
        autoRollback = true;
        sshOpts = [ "-p" "17788" ];

        nodes = mapAttrs (_: nixosConfig: {
          hostname =
            "${nixosConfig.config.networking.hostName}.${nixosConfig.config.networking.domain}";

          profiles.system.user = "root";
          profiles.system.path =
            deploy-rs.lib.${system}.activate.nixos nixosConfig;
        }) self.nixosConfigurations;
      };

      devShell = mapAttrs (system: deploy:
        let
          pkgs = serokell-nix.lib.pkgsWith nixpkgs.legacyPackages.${system} [
            serokell-nix.overlay
            vault-secrets.overlay
          ];
        in pkgs.mkShell {
          VAULT_ADDR = "https://vault.serokell.org:8200";
          SSH_OPTS = "${builtins.concatStringsSep " " self.deploy.sshOpts}";
          buildInputs = [
            deploy-rs.packages.${system}.deploy-rs
            pkgs.vault
            (pkgs.vault-push-approle-envs self)
            (pkgs.vault-push-approles self (final: prev: {
              # Generates a policy based on secret definition
              mkPolicy = { approleName, name, vaultPrefix, ... }@params:
                let
                  # Match only the buildkite approles
                  m =
                    builtins.match "aquarius-[a-z]*-buildkite-agent-(.*)" approleName;
                  # Figure out the buildkite namespace: if the (.*) in the match above is
                  # private, then the namespace is serokell-private, and it's serokell otherwise
                  # Note that the head here is safe since we only use this when m is not null
                  namespace = "serokell"
                    + pkgs.lib.optionalString (builtins.head m == "private")
                    "-private";
                in
                # Always get the "default" policy,
                pkgs.lib.recursiveUpdate (prev.mkPolicy params)
                # and merge it with a custom buildkite policy when the approle is a "buildkite" one
                (pkgs.lib.optionalAttrs (!isNull m) {
                  path = {
                    "buildkite/metadata/${namespace}/*".capabilities =
                      [ "list" ];
                    "buildkite/+/${namespace}/*".capabilities =
                      [ "create" "read" "update" "delete" ];
                  };
                });
            }))
            (terraformFor pkgs)
            pkgs.nixUnstable
          ];
        }) deploy-rs.defaultPackage;

      checks = recursiveUpdate deployChecks checks;
    };
}
