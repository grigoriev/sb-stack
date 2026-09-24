# Security policy

## Reporting a vulnerability

Report a vulnerability privately through GitHub:
https://github.com/grigoriev/sb-stack/security/advisories/new
(the **Security** tab, **Report a vulnerability**). Do not open a public issue for it.

We answer within a week. The fix goes to `main`, and its CHANGELOG entry names it.

## Supported versions

This repository has no releases. Only `main`, the deployed state, gets fixes.

## Scope

The Compose file, the Caddyfile, the caddy Dockerfile, the tests and the workflows belong to this
repository.

Vulnerabilities in upstream software (Caddy and its IONOS DNS plugin, the base images, and the
[sb-ctrl](https://github.com/grigoriev/sb-ctrl) and
[sb-ctrl-ui](https://github.com/grigoriev/sb-ctrl-ui) images) belong to the upstream project.
Tell us as well if this project is affected, so we can update it when the upstream fix is out.
