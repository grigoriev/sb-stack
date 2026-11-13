# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:6350162b3889ca32600b3c699c61572fa0eb3ad6b2a51874f19b158a7df77511 AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
