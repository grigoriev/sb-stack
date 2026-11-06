# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:ccd8bdb5d7b25c78962bac46b7daaabfb0a354d0decf7d752e1b69caf46d9b85 AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:ae5e525ca6773b0a4ce579c774cb39b3147e1576084139229517bdbcfe3ed812
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
