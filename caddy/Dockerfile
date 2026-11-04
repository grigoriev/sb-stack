# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:769c49615cfd4275ff9176b5752ecca3b97448028f73a2a469219db26b536205 AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:70b3180738b46cd88e49b300d790ae448a0aca3f58edef0f000bb57d619a9ab3
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
