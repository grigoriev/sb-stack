# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
