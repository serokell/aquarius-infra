provider  "aws" {
  version = "~> 3.20"
  region = "eu-west-2"
}

provider "vault" {
  address = "https://vault.serokell.org:8200/"
  version = "~> 2.2"
}

data "vault_generic_secret" "hcloud_token" {
  path = "kv/sys/hetzner/cloud-token"
}

provider "hcloud" {
  version = "~> 1.26.0"
  token = data.vault_generic_secret.hcloud_token.data["token"]
}
