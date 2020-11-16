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

resource "hcloud_ssh_key" "rvem" {
  name = "rvem"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEmUvzbwZM3179iOQPGiXF/Xwhyh5wxfvzbGX9HP5WIQIKkMwoLstt0OaHR+U8YoxhrHK0YiZ99CH3waACoLn+xd/8xBitL0zQaHuvrol8Y2G4H5ig8T3D/w3m88OzoQkwdibDL8Rtxuu0XlEpIXi526LAiK5p/UWL+xHacVNXQlEyPZDzWfLQpmyB36GcADYK4pXMqri/0x+7WAauUlK8Qb0fYF1dVyGNNqqLV3bop4dtNvchQ8kQFqLhT/E3yHek5fLx9Mo3OyJsGoma4x4vF+B5AC0dqpUbmljIJhX+rXdtwo/9g+SlGrJ5LV57ktPSASpTeo7BSv4rf0Uv8kT7zJXMQEPcNzN6Xh7wNVMN8lLsoyQwHJQcK/GmTw6I+ywJnnO+1Ku+mEB1qm6hX3JU7+u6a7CB7IuFUE23qM41RSwMhCma84wIZd3lu0O7j3YiUTinSdyT4QJxIEOtZ1iNNyoHOibrJaRxjVQGmQvoOe/A/+odecu7aHKo4JqjTaG6yTWmkDZyCwIsRCh2jTRhJ+Vy6cYJediMk2tYjKZWGQKP79tqiOkiHUDglU3n6wwrn1EDDV7aGg2gW3vLV46/LSm9oEVmvLAfuiPWyJCI/TJ9VZ1037HdIklPsmLGnx0yDwTUUjwtD9lA9fBfyXE1RENO0B/aQByRgn/GL+PJRQ== rvembox@gmail.com"
}

# TODO: add dns record for new server
resource "hcloud_server" "bunda" {
  name = "node1"
  image = "ubuntu-20.04"
  server_type = "cx31"
  ssh_keys = [ hcloud_ssh_key.rvem.id ]
  # Install NixOS 20.03
  user_data = <<EOF
    #cloud-config

    runcmd:
      - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-20.03 bash 2>&1 | tee /tmp/infect.log
EOF
}

output "aquarius_ns" {value = [ aws_route53_zone.aquarius_serokell_team.name_servers ]}
