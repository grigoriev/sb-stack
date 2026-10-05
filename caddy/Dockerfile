# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:9dd8970b7948356f54512caf6a448c55eff6c4a9fd9106d980423248bdfd65cb AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:1a81ac3d1a49b2b385a5bfafb8bd39fb40fa1d717461d825ee0d65df91a6e97b
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
