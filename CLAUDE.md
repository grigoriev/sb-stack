# CLAUDE.md

This file guides Claude Code when it works on or reviews this repository.

## Project Overview

sb-stack is the Docker Compose deployment of the seedbox to Plex stack. It runs on the host
`lemming`. `main` is the deployed state. The repo holds configuration, docs and CI only. It has
no application code and no releases.

A change must never alter what the host runs without intent. Treat every edit to
`docker-compose.yml`, `Caddyfile` or `caddy/Dockerfile` as a deployment change.

## Tech Stack

- **Docker Compose** with three services on one `internal` network:
  - `sb-ctrl`: REST API and transfer agent, image `ghcr.io/grigoriev/sb-ctrl:<version>`
  - `sb-ctrl-ui`: static UI, image `ghcr.io/grigoriev/sb-ctrl-ui:<version>`
  - `caddy`: TLS and reverse proxy, built locally with the IONOS DNS plugin
- **TLS**: Let's Encrypt over DNS-01. The host is VPN-only, so HTTP-01 fails
- **Tests**: `tests/smoke.sh`, bash and curl, needs Compose 2.24 or later

## Common Commands

```sh
cp .env.example .env       # fill in dummy values
docker compose config -q   # validate the compose file
tests/smoke.sh             # start the stack with dummy config and check it
```

On an ARM machine, run `DOCKER_DEFAULT_PLATFORM=linux/amd64 tests/smoke.sh`. Deploy on the host:

```sh
docker compose pull
docker compose up -d
```

## Architecture

- `docker-compose.yml`: the three services, their mounts and ports
- `Caddyfile`: `{$DOMAIN}` serves the UI at `/` and proxies `/api/*` to `sb-ctrl:8765`
- `caddy/Dockerfile`: `xcaddy build --with github.com/caddy-dns/ionos`
- `.env.example`: `DOMAIN`, `ACME_EMAIL`, `IONOS_API_KEY`, `MEDIA_ROOT`
- `config/config.toml`, `secrets/ssh/`: host-only, git-ignored, mounted read-only into `sb-ctrl`
- `tests/docker-compose.smoke.yml`: test override. It swaps env, config and Caddyfile for throwaway copies
- `tests/smoke.sh`: runs the stack as project `sb-stack-smoke` with Caddy's internal CA

`sb-ctrl` runs as root. It mounts the host `/etc/passwd` and `/etc/group` read-only, so owner names
resolve to host ids. `MEDIA_ROOT` holds staging and the Plex libraries on one filesystem.

## Code Style

- Comment each service and each non-obvious setting with the reason
- Keep the Caddyfile tab-indented. `tests/smoke.sh` finds the `tls` block by its tabs
- Scripts use `set -euo pipefail` and pass ShellCheck
- Name placeholders with `example.com`, `example.org` or `.invalid` hosts

## Review Focus

Flag these in a pull request:

- Any change to what the host runs that the PR title and description do not state
- An image tag bump that skips a version or does not match a published release
- A secret, token, key, real domain, real host path or email in a tracked file
- A tracked `.env`, `config/config.toml` or file under `secrets/ssh/`, or a `.gitignore` rule removed
- A third-party image without a digest pin. The own `ghcr.io/grigoriev/*` images use plain tags on
  purpose (`pinDigests: false` in `renovate.json`). Do not flag those
- A new published port, or a service reachable outside the `internal` network except `caddy`
- A mount that turns read-only into read-write, or a new host mount
- A change to `env_file`. Only `caddy` reads `.env`. Giving it to `sb-ctrl` would expose
  `IONOS_API_KEY` to a service that does not need it
- A routing change in the `Caddyfile` without a matching check in `tests/smoke.sh`
- An edit to `tests/docker-compose.smoke.yml` that could apply to a deployment
- A new `.trivyignore` entry without a reason comment
- No `## [Unreleased]` entry in `CHANGELOG.md`, or README not updated for a behavior change
- Workflow changes without SHA-pinned actions, `persist-credentials: false`, or `timeout-minutes`

## CI/CD and Release

- `ci.yml`: `lint` (ShellCheck, Hadolint, actionlint, zizmor, `trivy config`), `validate`
  (`docker compose config -q`) and `smoke` (`tests/smoke.sh`) on each pull request
- `scorecard.yml`: OpenSSF Scorecard, weekly and on push to `main`
- No releases. Renovate opens a pull request for each new image tag or base digest
- After a merge the host pulls `main` and recreates the stack by hand. No workflow deploys

Commit, branch and pull request rules are in `CONTRIBUTING.md`.
