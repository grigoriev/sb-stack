# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:9dd8970b7948356f54512caf6a448c55eff6c4a9fd9106d980423248bdfd65cb AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:d44355d3c2149dc580ce2cac735955d1c08d3d00882c30489c241aa51a5c10d9
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
