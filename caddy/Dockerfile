# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:34466183d881df9a8226caf360ff86fe50456f0971221b127dcb756cf514e1ea AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:881bbc60f9986d5ab8e7cfd6cf7e4ef3c9c0439fef2429d035d065577882f028
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
