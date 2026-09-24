# Contributing

Issues and pull requests are welcome.

This repo holds the Docker Compose deployment for the seedbox to Plex stack. `main` is the
deployed state.

## Build and test

```sh
cp .env.example .env       # fill in dummy values
docker compose config -q   # validate the compose file
tests/smoke.sh             # start the stack with dummy config and check it
```

CI runs ShellCheck, Hadolint, actionlint, zizmor, `trivy config`, the compose validation and the
smoke test for every pull request.

New behavior comes with a test. Extend `tests/smoke.sh` when a change adds a route, a service or a
proxy rule. A bug fix adds a check that fails without it.

## Pull requests

1. Branch from the default branch as `type/description`, for example `fix/empty-title`.
2. Keep one change per pull request.
3. Write commit messages as [Conventional Commits](https://www.conventionalcommits.org/) without a
   scope: `feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...`, `test: ...`, `build: ...`,
   `ci: ...`, `chore: ...`.
4. Sign your commits. The default branch accepts verified signatures only.
5. Add an entry under `## [Unreleased]` in `CHANGELOG.md`. Update the README when behavior or
   configuration changes.

Pull requests are squash-merged once all required checks are green.

## Releases

This repository has no releases. Renovate opens a pull request for each new image tag. After the
merge the host pulls `main` and recreates the stack, see "Updating" in the README.
