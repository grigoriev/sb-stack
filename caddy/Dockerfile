# Caddy with the IONOS DNS provider for DNS-01 ACME challenges.
FROM caddy:2-builder@sha256:da86330f46775cf80844de8fc2c51cd3e9d59fc4946faa715070f9216421f5af AS builder
RUN xcaddy build --with github.com/caddy-dns/ionos

FROM caddy:2-alpine@sha256:78bd35025c7ba85961dd149ae670315129954e77abe2383ac47c89106b35ade9
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
