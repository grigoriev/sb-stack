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

- CHANGELOG.md, and Verify, Contributing and Disclaimer sections in the README.

### Changed

- Use a neutral example host in the README `ssh-keyscan` step.

### Fixed

- Run CI once per commit on a Renovate branch: drop `renovate/**` from the push trigger.
