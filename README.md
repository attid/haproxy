# haproxy

A lightweight wrapper around [haproxy:3.3](https://hub.docker.com/_/haproxy) for simple TCP proxying.

Instead of writing frontend/backend blocks manually, just pass rules as arguments in the format `listen_port:host:backend_port`.

## Format

```
listen_port:host:backend_port
```

- **listen_port** — port HAProxy listens on inside the container
- **host** — backend container hostname (Docker service name)
- **backend_port** — port on the backend container to forward traffic to

## Usage

```yaml
services:
  haproxy:
    image: ghcr.io/attid/haproxy:latest
    restart: unless-stopped
    command:
      - 30000:simon:30000
      - 8088:dozzle:8080
    ports:
      - "1.1.1.1:30000:30000"
      - "1.1.1.1:8088:8088"
    networks:
      gateway:

networks:
  gateway:
    external: true
```

To add a new service — just 2 lines:

```yaml
    command:
      - 9090:prometheus:9090  # new
    ports:
      - "1.1.1.1:9090:9090"  # new
```
