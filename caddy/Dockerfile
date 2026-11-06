# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:ccd8bdb5d7b25c78962bac46b7daaabfb0a354d0decf7d752e1b69caf46d9b85 AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:f6228111e5fafa1a5238258d0858e103f10599b8d1659a146e7726681a002bb9
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
