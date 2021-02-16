{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.services.local-chains;
  nodeConfigFile =
    builtins.toFile "node-config.json" (builtins.toJSON cfg.nodeConfig);
  chainParametersFile = chain-config: builtins.toFile "parameters.json" (builtins.toJSON
    (chain-config.chainParameters //
     { bootstrap_accounts = [[
         chain-config.bakerKeys.publicKey
         (toString (chain-config.moneybagInitialBalance * (builtins.length chain-config.moneybagSecretKeys + 1)))
       ]] ++ chain-config.bootstrapAccounts;
     }
    ));
  pkgs-with-tezos = (import "${inputs.tezos-packaging}/nix/build/pkgs.nix" { });
  tezos-client =
    "${pkgs-with-tezos.ocamlPackages.tezos-client}/bin/tezos-client";
  tezos-node = "${pkgs-with-tezos.ocamlPackages.tezos-node}/bin/tezos-node";
  tezos-bakers = {
    "007-PsDELPH1" =
      "${pkgs-with-tezos.ocamlPackages.tezos-baker-007-PsDELPH1}/bin/tezos-baker-007-PsDELPH1";
    "008-PtEdoTez" =
      "${pkgs-with-tezos.ocamlPackages.tezos-baker-008-PtEdoTez}/bin/tezos-baker-008-PtEdoTez";
    "008-PtEdo2Zk" =
      "${pkgs-with-tezos.ocamlPackages.tezos-baker-008-PtEdo2Zk}/bin/tezos-baker-008-PtEdo2Zk";
  };
  full-protocols-names = {
    "007-PsDELPH1" = "PsDELPH1Kxsxt8f9eWbxQeRxkjfbxoqM52jvs5Y5fBxWWh4ifpo";
    "008-PtEdoTez" = "PtEdoTezd3RHSC31mpxxo1npxFjoWWcFgQtxapi51Z8TLu6v6Uq";
    "008-PtEdo2Zk" = "PtEdo2ZkT9oKpimTah6x2embF25oss54njMuPzkJTEi5RqfdZFA";
  };
  nodeConfigs = {
    "007-PsDELPH1" = genesisPubkey:
      { network = {
          chain_name = "TEZOS_DELPHINET_2020-09-04T07:08:53Z";
          default_bootstrap_peers = [ ];
          genesis = {
            block = "BLockGenesisGenesisGenesisGenesisGenesis355e8bjkYPv";
            protocol = "PtYuensgYBb3G3x1hLLbCmcav8ue8Kyd2khADcL5LsT5R1hcXex";
            timestamp = "2020-09-04T07:08:53Z";
          };
          genesis_parameters = {
            values = {
              genesis_pubkey =
                genesisPubkey;
            };
          };
          incompatible_chain_name = "INCOMPATIBLE";
          old_chain_name = "TEZOS_DELPHINET_2020-09-04T07:08:53Z";
          sandboxed_chain_name = "SANDBOXED_TEZOS";
        };
        p2p = { };
      };
    "008-PtEdoTez" = genesisPubkey:
      { network = {
          chain_name = "TEZOS_EDONET_2020-11-30T12:00:00Z";
          default_bootstrap_peers = [ ];
          genesis = {
            block = "BLockGenesisGenesisGenesisGenesisGenesis2431bbUwV2a";
            protocol = "PtYuensgYBb3G3x1hLLbCmcav8ue8Kyd2khADcL5LsT5R1hcXex";
            timestamp = "2020-09-04T07:08:53Z";
          };
          genesis_parameters = {
            values = {
              genesis_pubkey =
                genesisPubkey;
            };
          };
          incompatible_chain_name = "INCOMPATIBLE";
          old_chain_name = "TEZOS_EDONET_2020-11-30T12:00:00Z";
          sandboxed_chain_name = "SANDBOXED_TEZOS";
        };
        p2p = { };
      };
    "008-PtEdo2Zk" = genesisPubkey:
      { network = {
          chain_name = "TEZOS_EDONET_2020-11-30T12:00:00Z";
          default_bootstrap_peers = [ ];
          genesis = {
            block = "BLockGenesisGenesisGenesisGenesisGenesisdae8bZxCCxh";
            protocol = "PtYuensgYBb3G3x1hLLbCmcav8ue8Kyd2khADcL5LsT5R1hcXex";
            timestamp = "2021-02-11T14:00:00Z";
          };
          genesis_parameters = {
            values = {
              genesis_pubkey =
                genesisPubkey;
            };
          };
          incompatible_chain_name = "INCOMPATIBLE";
          old_chain_name = "TEZOS_EDO2NET_2021-02-11T14:00:00Z";
          sandboxed_chain_name = "SANDBOXED_TEZOS";
        };
        p2p = { };
      };
  };
  tezos-client-args = chain-name: chain-config:
    ''--endpoint http://127.0.0.1:${toString chain-config.rpcPort} -d "/var/lib/local-chain-${chain-name}/client"'';
  localChainOptions = types.submodule ({...}: {
    options = {
      rpcPort = mkOption {
        type = types.int;
        default = 8734;
        example = 8734;
        description = ''
          Tezos node RPC port.
        '';
      };

      resetTime = mkOption {
        type = types.str;
        default = "1d";
        example = "1d";
        description = ''
          Period with which local chain node will restart.
        '';
      };

      # There is no sensitive information in this secret key
      genesisKeys = mkOption {
        type = types.attrsOf types.str;
        default = {
          publicKey =
            "edpkvP4vq1PjEmfgfsiWpnQmojx4GYhW5hPHPfomWtmjdUULxRDjRt";
          secretKey =
            "unencrypted:edsk3efmvuZ9dbhjRCEvfH47Ad3LmrZZgCadfYT6wmTgnN2E6XaEYh";
        };
      };

      # There is no sensitive information in this secret key
      bakerKeys = mkOption {
        type = types.attrsOf types.str;
        default = {
          publicKey =
            "edpkubXzL1rs3dQAGEdTyevfxLw3pBCTF53CdWKdJJYiBFwC1xZSct";
          secretKey =
            "unencrypted:edsk47wWUSCHRDC1Hxtg7yxXzocwDjBJJRqTKnoP7htAifSpzwkg8K";
        };
        description = ''
          Baker account keys.
        '';
      };

      bootstrapAccounts = mkOption {
        type = types.listOf (types.listOf types.str);
        description = "List of bootstrap accounts with their initial balances";
        default = [];
      };

      moneybagSecretKeys = mkOption {
        type = types.listOf types.str;
        description = ''
          List of moneybag accounts secret keys, these accounts will have baker
          as a delegate.
        '';
        default = [];
      };

      moneybagInitialBalance = mkOption {
        type = types.int;
        description = "Initial balance for moneybag accounts";
        default = 4000000000000;
      };

      chainParameters = mkOption rec {
        type = types.attrs;
        description = "Attribute set of chain parameters";
        default = {
          baking_reward_per_endorsement = [ "200000" ];
          block_security_deposit = "512000000";
          blocks_per_commitment = 4;
          blocks_per_cycle = 8;
          blocks_per_roll_snapshot = 4;
          blocks_per_voting_period = 64;
          cost_per_byte = "1000";
          delay_per_missing_endorsement = "1";
          endorsement_reward = [ "2000000" ];
          endorsement_security_deposit = "64000000";
          endorsers_per_block = 32;
          hard_gas_limit_per_block = "10400000";
          hard_gas_limit_per_operation = "1040000";
          hard_storage_limit_per_operation = "60000";
          initial_endorsers = 1;
          michelson_maximum_type_size = 1000;
          min_proposal_quorum = 500;
          origination_size = 257;
          preserved_cycles = 2;
          proof_of_work_threshold = "-1";
          quorum_max = 7000;
          quorum_min = 2000;
          seed_nonce_revelation_tip = "125000";
          test_chain_duration = "1966080";
          time_between_blocks = [ "1" "2" ];
          tokens_per_roll = "8000000000";
        };
        apply = lib.recursiveUpdate default;
      };

      baseProtocol = mkOption {
        type = types.str;
        description =
          "Base protocol for local-chain, only '007-PsDELPH1' and '008-PtEdo2Zk' are supported";
        example = "008-PtEdo2Zk";
      };
    };
  });
in {
  options.services.local-chains = rec {
    chains = mkOption {
      type = types.attrsOf localChainOptions;
      description = "Local chain configuration";
      default = {};
    };
  };

  config = {
    users = lib.mkMerge (flip mapAttrsToList cfg.chains (chain-name: chain-config: {
      groups."local-chain-${chain-name}" = {};
      users."local-chain-${chain-name}" = { group = "local-chain-${chain-name}"; };
    }));
    systemd = lib.mkMerge (flip mapAttrsToList cfg.chains (chain-name: chain-config: {
      services."local-chain-${chain-name}-tezos-baker" = rec {
        wantedBy = [ "multi-user.target" ];
        requires = [ "network.target" "local-chain-${chain-name}-tezos-node.service" ];
        after = requires;
        description = "Tezos baker daemon for baking blocks in local chain.";
        path = with pkgs; [ curl jq watch ];
        environment = { TEZOS_LOG = "* -> warning"; TERM = "xterm"; TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER = "Y"; };
        script = ''
          ${tezos-bakers."${chain-config.baseProtocol}"} -A 127.0.0.1 -P ${
            toString chain-config.rpcPort
          } -d "/var/lib/local-chain-${chain-name}/client" run with local node "/var/lib/local-chain-${chain-name}/node" baker &
          systemd-notify --ready
          while true; do
            watch -g "curl --silent http://127.0.0.1:${toString chain-config.rpcPort}/chains/main/blocks/head/header | jq .level" > /dev/null
            systemd-notify WATCHDOG=1
          done
        '';
        /*
          Transfer tzs to moneybags and set their delegates to baker.
          Purpose of this service is to transfer some amount of money
          to the moneybag accounts along with delegating them to the baker account.
          Such an approach gives some degree of confidence that baker will always
          be capable of baking new blocks since it will be the only delegated account
          with huge amount of money.
        */
        postStart = ''
          for sk in ${escapeShellArgs chain-config.moneybagSecretKeys}; do
            ${tezos-client} ${tezos-client-args chain-name chain-config} import secret key moneybag "$sk" --force
            # Check whether address was delegated previously, if it was, then it already should have money
            # and already have delegated his baking rights
            if [[ $(${tezos-client} ${tezos-client-args chain-name chain-config} get delegate for moneybag) == "none" ]]; then
              ${tezos-client} ${tezos-client-args chain-name chain-config} transfer ${
                toString (chain-config.moneybagInitialBalance / 1000000)
              } from baker to moneybag --burn-cap 0.257
              ${tezos-client} ${tezos-client-args chain-name chain-config} set delegate for moneybag to baker
            fi
          done
        '';
        serviceConfig = {
          TimeoutStartSec = "120";
          User = "local-chain-${chain-name}";
          Restart = "always";
          RestartSec = "10";
          Type = "notify";
          WatchdogSec = "100";
          NotifyAccess = "all";
        };
      };
      services."local-chain-${chain-name}-tezos-node" = rec {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "Tezos node running local chain with short block periods.";

        path = with pkgs; [ curl ];
        environment = {
          TEZOS_LOG = "* -> warning";
          TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER = "Y";
        };
        script = ''
          tezos_client_dir="$STATE_DIRECTORY/client"
          tezos_node_dir="$STATE_DIRECTORY/node"
          # Nuke old files in order to prevent massive disk space consumption
          rm -rf "$tezos_client_dir"
          rm -rf "$tezos_node_dir"
          mkdir -p "$tezos_client_dir"
          mkdir -p "$tezos_node_dir"
          ${tezos-client} -d "$tezos_client_dir" --mode mockup import secret key genesis ${chain-config.genesisKeys.secretKey}
          ${tezos-client} -d "$tezos_client_dir" --mode mockup import secret key baker ${chain-config.bakerKeys.secretKey}
          cp ${
            builtins.toFile "node-config.json"
            (builtins.toJSON (nodeConfigs."${chain-config.baseProtocol}"
              chain-config.genesisKeys.publicKey)
            )
          } "$tezos_node_dir"/config.json
          ${tezos-node} identity generate 1 --data-dir "$tezos_node_dir"
          ${tezos-node} run --data-dir "$tezos_node_dir" --rpc-addr 127.0.0.1:${
            toString chain-config.rpcPort
          } \
            --bootstrap-threshold 0 --no-bootstrap-peers
        '';
        # Activate protocol once node is up
        postStart = ''
          until $(curl --output /dev/null --silent --fail http://127.0.0.1:${
            toString chain-config.rpcPort
          }/chains/main/blocks/head); do
            sleep 2
          done
          ${tezos-client} --block genesis ${tezos-client-args chain-name chain-config} \
              activate protocol ${full-protocols-names."${chain-config.baseProtocol}"} with fitness 24 \
              and key genesis and parameters ${chainParametersFile chain-config}
        '';
        serviceConfig = {
          User = "local-chain-${chain-name}";
          StateDirectory = "local-chain-${chain-name}";
        };
      };
      # Service for restarting local-chain
      services."local-chain-${chain-name}-restart" = rec {
        description = "Restart local-chain-${chain-name}";
        script = ''
          systemctl restart local-chain-${chain-name}-tezos-node.service
        '';
        serviceConfig = { Type = "oneshot"; };
      };
      timers."local-chain-${chain-name}-restart" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnActiveSec = chain-config.resetTime;
          OnUnitActiveSec = chain-config.resetTime;
        };
      };
    }));
  };
 }
