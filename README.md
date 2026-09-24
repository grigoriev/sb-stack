# sb-stack

[![CI](https://github.com/grigoriev/sb-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/grigoriev/sb-stack/actions/workflows/ci.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/grigoriev/sb-stack/badge)](https://scorecard.dev/viewer/?uri=github.com/grigoriev/sb-stack)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/14807/badge)](https://www.bestpractices.dev/projects/14807)
[![Docker Compose](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](docker-compose.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

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
   ssh-keyscan seedbox.example.org > secrets/ssh/known_hosts
   chmod 600 secrets/ssh/id_ed25519
   ```

5. Start the stack:

   ```sh
   docker compose up -d --build
   ```

6. Open `https://<DOMAIN>/`. In the UI settings set the API URL to `/api` and
   paste the bearer token from `config.toml`.

## Updating

`sb-ctrl` and `sb-ctrl-ui` run prebuilt images from GHCR, pinned to a version
tag. Each repo publishes a new tag on release, and Renovate opens a PR here to
bump the tag. After merging, pull and recreate:

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

## Verify the images

The `sb-ctrl` and `sb-ctrl-ui` images carry a signed build provenance and an
SPDX SBOM attestation from their next release on. Check one before a deploy:

```sh
gh attestation verify oci://ghcr.io/grigoriev/sb-ctrl:<tag> --owner grigoriev
```

## Tests

`tests/smoke.sh` starts the real stack with dummy config and checks that it serves.
CI runs it in the `smoke` job on every pull request.

```sh
tests/smoke.sh
```

It needs Docker with Compose 2.24 or later, and curl. The script does this:

1. Writes a throwaway `.env` and `config.toml` to a temp dir. No seedbox and no real secrets.
2. Builds caddy and starts the stack as project `sb-stack-smoke`, on `https://localhost:8443`.
3. Replaces the IONOS DNS-01 block of the Caddyfile with Caddy's internal CA. No ACME.
4. Checks the UI index page, `/api/health`, and that `/api` rejects a missing or wrong token.
5. Validates the deployed Caddyfile, unchanged, with the built caddy image.
6. Removes the containers and volumes, and prints the logs on failure.

The separate project name keeps a deployment in the same checkout untouched. Set
`SMOKE_PORT` if port 8443 is taken. The sb-ctrl images are amd64 only. On an ARM
machine, run `DOCKER_DEFAULT_PLATFORM=linux/amd64 tests/smoke.sh`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Disclaimer

This software is provided "as is", without warranty of any kind, as the LICENSE states. Use
it at your own risk. Sergey Grigoriev is not liable for damage from its use, as far as the law
allows. It is published free of charge, outside of any commercial offering, with no
obligation to support it. Security reports are welcome, see [SECURITY.md](SECURITY.md).

## License

MIT License - see [LICENSE](LICENSE) for details.
