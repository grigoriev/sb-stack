# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This repository has no releases. `main` is the deployed state.

## [Unreleased]

### Security

- Audit the workflows with actionlint and zizmor in a new `lint` job.
- Lint the caddy Dockerfile with Hadolint and `trivy config` in the `lint` job.
- Add the OpenSSF Scorecard workflow and its README badge.
- Limit the token permissions of the workflows.
- Stop persisting the checkout credentials.
- Let Renovate pin GitHub Actions by commit digest.

### Added

- Smoke test `tests/smoke.sh` and a `smoke` CI job: start the stack with dummy config, check the UI, the API and the token check.
- CHANGELOG.md, and Verify, Contributing and Disclaimer sections in the README.
- OpenSSF Best Practices badge in the README (project 14807, passing).

### Changed

- Align the repository with the shared baseline: the `lint` job runs ShellCheck on
  `tests/smoke.sh`, a new push to a pull request cancels its older CI run, every job has
  a time limit, and SECURITY.md, CONTRIBUTING.md and .editorconfig follow the templates.
- Use a neutral example host in the README `ssh-keyscan` step.
- Renovate takes its common rules from the shared preset `github>grigoriev/renovate-config`, which also turns on OSV vulnerability alerts.

### Fixed

- Run CI once per commit on a Renovate branch: drop `renovate/**` from the push trigger.
