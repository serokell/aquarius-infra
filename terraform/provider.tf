#variable "hcloud_token" {}

provider  "aws" {
  version = "~> 2.15"
  region = "eu-west-2"
}

provider "hcloud" {
  version = "~> 1.16.0"
  token = <TODO: fetch token from vault>
}
