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
