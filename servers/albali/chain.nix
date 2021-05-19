{ config, lib, pkgs, ... }: {
  services.local-chains.chains.florencenet = {
    rpcPort = 8734;
    baseProtocol = "009-PsFLoren";
    moneybagSecretKeys = [
      # tz1NpbW6KL2B9ELL2CEbUj1jZKHNpoC2hYdS
      # morley
      "unencrypted:edsk42cYfuawC5i3PmuS3Lq73pAzgrJyVNcv9CXQspM2dG4M9QMpeS"
      # tz1Znvao83anTh654Uu44Kb9atTp5yTK93A8
      # tezos-btg
      "unencrypted:edsk4JeHGnXM5nz2cyW9R5xTpM1Wk6ZgZF2j6k8h235akhSPbnEEnz"
      # tz1Vona7MnADxXVFugpHohxSTFmah5Aj5xBM
      # tezos-btc
      "unencrypted:edsk3D3Gx5q6mVL4jCAuFCoekWjM6hzrmSA3MCtDUnMAjxmxJ2rtes"
      # tz1VPPpDoFYFJckEqR9J3UCz5crMHhsYrLw9
      # globacap
      "unencrypted:edsk3AvAoPS5jFov49aWBQ9oVtCPwNSne2CriHvkFxfeCg4Srr5bak"
      # tz1Z5FmSqASb3shGVNKW1jwiqPFh9vPCjDgc
      # stablecoin
      "unencrypted:edsk3GjD83F7oj2LrnRGYQer99Fj69U2QLyjWGiJ4UoBZNQwS38J4v"
      # tz1NPyRFPPPaJY83uv3z7i6aUwxpy7w8KEHr
      # NBIT
      "unencrypted:edsk3j638szdew1MNywcm8Rz2nNWhN3nnZ4LJJXjrkCnktESBFG3yt"
      # tz1d9h3tviTEqmbjG4ioWjBLpJj7VrRQA4Gs
      # morley-ledgers
      "unencrypted:edsk2rfX5hrPC1zQHhqRPPxQ8SL4c4RZMBc7D64J5jitiR9aeuf62v"
      # tz1bcWsBeXUQ1e7Xz4iXEpTDN1tvRyb2GM9f
      # baseDAO
      "unencrypted:edsk3nAQ3uCP7vc2ccLhhWNNncgFfWQ5HgTyPawepQ8DURRRfzVQzB"
      # tz1dbxZCZYi23zMWLLYPF2fW83YYNJBYQYnw
      # morley-multisig
      "unencrypted:edsk2mThb5CZVy2jKhjReNHD3BXeN4UvCDJcvccsaMrZ4NMiRHeCxN"

      # Keys below are unassigned, feel free to use them
      # tz1fDbuARxQapX6yP6k8QAGRUichBABDSh9T
      "unencrypted:edsk2pSdHRGcASgMdieWEKMnsA36vexLDJtJEfnv2AHVD8Fv1TQoD6"
    ];
  };
}
