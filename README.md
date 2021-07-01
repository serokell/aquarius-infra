# ♒ Aquarius: Build Cluster

![Aquarius Constellation](https://upload.wikimedia.org/wikipedia/commons/0/0f/AquariusCC.jpg)

_Image credit: Till Credner, CC BY-SA 3.0_

Serokell's build servers.

TODO: Add more servers, add primary/secondary servers to ensure consistency and lack of unneded builds.

## Servers

| Name   | Function             | IP              |
|:------:|:--------------------:|:---------------:|
| Albali | Primary build server | 135.181.117.245 |

<!-- Don't forget to add the servers on https://www.notion.so/serokell/Server-Naming-Scheme-c189819000164fb090377c75e4ce7da6 -->

## What's where

Servers: manually provisioned on Hetzner

DNS records: [./terraform](./terraform)

NixOS configurations: [./servers](./servers), a directory per server

## Deployment

### NixOS

Server configurations are described in `./servers`.

To deploy all the servers, enter a shell (with `nix develop` or `nix-shell`)
and run `deploy`.

You may wish to read `deploy --help` to understand how to use the tool.

### Secrets

Secrets are stored in Vault. Serokell employees with Admin-level access
need to generate approle credentials and push them to servers in order
for services to work after redeployment. Example of how to do so:

```
$ # Enter a shell with dependencies and variables set
$ nix develop # or nix-shell
$ # Authenticate to vault
$ vault login # You may need to specify the login method
$ # Generate and push approles with accompanying security policies to Vault
$ vault-push-approles
<interaction omitted>
$ # Fetch approle credentials from Vault and push them to the server
$ vault-push-approle-envs
<interaction omitted>
```
