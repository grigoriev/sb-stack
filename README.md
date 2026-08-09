# sb-stack

![CI](https://github.com/grigoriev/sb-stack/actions/workflows/ci.yml/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Docker Compose deployment for the seedbox to Plex stack:

- **sb-ctrl** ([repo](https://github.com/grigoriev/sb-ctrl)) - REST API and transfer agent.
- **sb-ctrl-ui** ([repo](https://github.com/grigoriev/sb-ctrl-ui)) - static single-page UI.
- **caddy** - TLS termination and reverse proxy, built with the IONOS DNS plugin.

One host serves the UI at the root and the API under `/api`. Same origin, so the
browser makes no cross-origin calls.

```
browser ── https ──> caddy ─┬─ /api/* ─> sb-ctrl:8765
                            └─ /*      ─> sb-ctrl-ui:80
```

## Prerequisites

- Docker with the Compose plugin.
- A domain whose DNS zone is hosted at IONOS.
- An IONOS DNS API key. The host is VPN-only, so certificates issue over DNS-01,
  not HTTP-01.
- The staging dir and the Plex library roots on one filesystem (atomic moves).

## Setup

1. Clone this repo on the deployment host.

2. Create the environment file:

   ```sh
   cp .env.example .env
   ```

   Fill in `DOMAIN`, `ACME_EMAIL`, `IONOS_API_KEY`, and `MEDIA_ROOT`.

3. Create `config/config.toml` from the sb-ctrl
   [example](https://github.com/grigoriev/sb-ctrl/blob/main/config.example.toml).
   Apply the Docker deltas:

   - `[api] host = "0.0.0.0"` so the container is reachable.
   - `staging_root` and the `[roots]` paths under `/data` (the `MEDIA_ROOT` mount).

   Then `chmod 600 config/config.toml`.

4. Put the seedbox SSH key and a `known_hosts` entry in `secrets/ssh/`:

   ```sh
   cp ~/.ssh/id_ed25519 secrets/ssh/
   ssh-keyscan sb.g7v.io > secrets/ssh/known_hosts
   chmod 600 secrets/ssh/id_ed25519
   ```

5. Start the stack:

   ```sh
   docker compose up -d --build
   ```

6. Open `https://<DOMAIN>/`. In the UI settings set the API URL to `/api` and
   paste the bearer token from `config.toml`.

## Updating

`sb-ctrl` and `sb-ctrl-ui` run prebuilt images from GHCR, published by each repo
on release. Pull the newest and recreate:

```sh
docker compose pull
docker compose up -d
```

The `caddy` service builds locally (it bundles the IONOS DNS plugin), so the
first start needs `--build`.

## Notes

- The `sb-ctrl` container runs as root and mounts the host `/etc/passwd` and
  `/etc/group` read-only, so the perms owner and group names (for example
  `plex`) resolve to the host ids.
- The `sb-ctrl` and `sb-ctrl-ui` images are published to
  `ghcr.io/grigoriev/*` only when a GitHub Release is created in those repos.
  Cut a release there before the first deploy.
