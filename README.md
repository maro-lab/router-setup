## Edge router setup
Edge routers should be almost stateless and fast to setup

This repo contains a simple Traefik config that exposes a domain and its subdomains to the wide internet, while making access to *.internal.domain only possible through ZeroTier's VPN

The following variables will be requested

- Email for LetsEncrypt
- Domain
- ZeroTier's network ID
- ZeroTier's safe subnet range
- IP (or domain) of backend servers
- Cloudflare API token
