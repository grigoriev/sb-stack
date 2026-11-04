# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:c4cd20eaa0b69112fd5d4f721ffc9671687e1d5d0b155c8620cf7546dbef94c0 AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:70b3180738b46cd88e49b300d790ae448a0aca3f58edef0f000bb57d619a9ab3
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
