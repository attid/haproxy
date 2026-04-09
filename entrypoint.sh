#!/bin/sh
set -e

cfg=/tmp/haproxy.cfg

cat > "$cfg" <<'HEADER'
global
  log stdout format raw local0

defaults
  log global
  mode tcp
  timeout connect 5s
  timeout client 1m
  timeout server 1m

resolvers docker
  nameserver dns 127.0.0.11:53
  resolve_retries 3
  timeout resolve 1s
  timeout retry 1s
  hold valid 10s
HEADER

for rule in "$@"; do
  # validate format: port:host:port
  case "$rule" in
    *:*:*) ;;
    *) echo "ERROR: invalid rule '$rule', expected listen_port:host:backend_port" >&2; exit 1 ;;
  esac

  lport=${rule%%:*}
  rest=${rule#*:}
  host=${rest%%:*}
  rport=${rest#*:}

  # check ports are numbers
  case "$lport$rport" in
    *[!0-9]*) echo "ERROR: ports must be numeric in '$rule'" >&2; exit 1 ;;
  esac

  # check host is not empty
  if [ -z "$host" ]; then
    echo "ERROR: empty host in '$rule'" >&2; exit 1
  fi

  cat >> "$cfg" <<EOF

frontend svc_${lport}
  bind *:${lport}
  default_backend be_${lport}

backend be_${lport}
  server s1 ${host}:${rport} check resolvers docker init-addr last,libc,none
EOF
done

exec haproxy -W -db -f "$cfg"
