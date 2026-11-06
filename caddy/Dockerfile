# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:d4eb070c36154bd2d4c94b40359a03c6168346d5af5404963c74691ab77fb63f AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:ae5e525ca6773b0a4ce579c774cb39b3147e1576084139229517bdbcfe3ed812
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
