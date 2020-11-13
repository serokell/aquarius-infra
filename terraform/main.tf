terraform {
  backend "s3" {
    bucket = "serokell-aquarius-tfstate"
    dynamodb_table = "serokell-aquarius-tfstate-lock"
    encrypt = true
    key    = "aquarius/terraform.tfstate"
    region = "eu-west-2"
  }
  ## Prevent unwanted updates
  required_version = "~> 0.12.29" # Use nix-shell or nix develop
}

resource "aws_route53_zone" "aquarius_serokell_team" {
  name = "aquarius.serokell.team"
}

## Albali
resource "aws_route53_record" "albali_aquarius_serokell_team_ipv4" {
  zone_id = aws_route53_zone.aquarius_serokell_team.zone_id
  name    = "albali.aquarius.serokell.team"
  type    = "A"
  ttl     = "60"
  records = ["135.181.117.245"]
}

resource "aws_route53_record" "albali_aquarius_serokell_team_ipv6" {
  zone_id = aws_route53_zone.aquarius_serokell_team.zone_id
  name    = "albali.aquarius.serokell.team"
  type    = "AAAA"
  ttl     = "60"
  records = ["2a01:4f9:4b:1dca::1"]
}

output "aquarius_ns" {value = [ aws_route53_zone.aquarius_serokell_team.name_servers ]}
