# Contributing

Thanks for your interest in improving this project.

## Development

This repo holds the Docker Compose deployment for the seedbox to Plex stack.
Validate the compose file before opening a pull request:

```sh
cp .env.example .env   # fill in dummy values
docker compose config -q
```

Then run the smoke test. It starts the stack with dummy config and checks it:

```sh
tests/smoke.sh
```

## Tests

New behavior comes with a test. Extend `tests/smoke.sh` when a change adds a
route, a service or a proxy rule. A bug fix adds a check that fails without it.

## Commit messages

This project follows [Conventional Commits](https://www.conventionalcommits.org/):
`type: subject`, imperative mood, lowercase first letter, no trailing period,
subject under 50 characters. Types: `feat`, `fix`, `docs`, `style`, `refactor`,
`perf`, `test`, `build`, `ci`, `chore`.

## Style

- American spelling.
- One idea per sentence, active voice.
- Keep changes minimal and focused on the task.
- Do not use em dashes.

## Before opening a pull request

- Validate the compose file, run `tests/smoke.sh`, and make sure CI is green.
- Sign your commits. The `main` branch accepts verified signatures only.
- Pull requests are merged with squash merge.
