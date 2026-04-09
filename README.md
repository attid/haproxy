# haproxy

Обёртка над [haproxy:3.3](https://hub.docker.com/_/haproxy) для простого TCP-проксирования.

Вместо ручного написания frontend/backend — передаёшь правила аргументами в формате `listen_port:host:port`.

## Использование

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

Добавить новый сервис — 2 строки:

```yaml
    command:
      - 9090:prometheus:9090  # новый
    ports:
      - "1.1.1.1:9090:9090"  # новый
```
