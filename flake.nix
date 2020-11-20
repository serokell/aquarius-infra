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
    tezos-packaging = {
      url = "github:serokell/tezos-packaging";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, serokell-nix, deploy-rs, ... }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem filterAttrs const recursiveUpdate;
      inherit (builtins) readDir mapAttrs;
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system}.extend serokell-nix.overlay;

      terraform = pkgs.terraform.withPlugins (p: with p; [ aws ]);

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

      checks.${system} = {
        trailing-whitespace = pkgs.build.checkTrailingWhitespace ./.;
        terraform = pkgs.runCommand "terraform-check" {
          src = ./terraform;
          buildInputs = [ terraform ];
        } ''
          cp -r $src ./terraform
          terraform init -backend=false terraform
          terraform validate terraform
          touch $out
        '';
      };

      vault-push-approles = pkgs.vault-push-approles self (final: prev: {
        mkPolicy = { approleName, ... }@params:
          if !isNull (builtins.match ".*buildkite.*" approleName) then {
            path = (prev.mkPolicy params).path ++ (let
              namespace = "serokell${
                  nixpkgs.lib.optionalString
                  (!isNull (builtins.match ".*private.*" approleName))
                  "-private"
                }";
            in [
              {
                "buildkite/metadata/${namespace}/*" = [{ capabilities = [ "list" ]; }];
              }
              {
                "buildkite/+/${namespace}/*" = [{ capabilities = [ "read" ]; }];
              }
            ]);
          } else
            prev.mkPolicy params;
      });
    in {
      nixosConfigurations = mapAttrs (const mkSystem) servers;

      deploy.magicRollback = true;
      deploy.autoRollback = true;

      apps.${system}.vault-push-approles = {
        program = "${vault-push-approles}/bin/vault-push-approles";
        type = "app";
      };

      deploy.nodes = mapAttrs (_: nixosConfig: {
        hostname =
          "${nixosConfig.config.networking.hostName}.${nixosConfig.config.networking.domain}";
        sshOpts = [ "-p" "17788" ];

        profiles.system.user = "root";
        profiles.system.path = deploy-rs.lib.${system}.setActivate
          nixosConfig.config.system.build.toplevel
          "$PROFILE/bin/switch-to-configuration switch";
      }) self.nixosConfigurations;

      devShell.${system} = pkgs.mkShell {
        buildInputs = [
          deploy-rs.defaultPackage.${system}
          terraform
          vault-push-approles
          pkgs.nixUnstable
        ];
      };

      checks = recursiveUpdate deployChecks checks;
    };
}
