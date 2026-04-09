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
HEADER

for rule in "$@"; do
  lport=${rule%%:*}
  rest=${rule#*:}
  host=${rest%%:*}
  rport=${rest#*:}

  cat >> "$cfg" <<EOF

frontend svc_${lport}
  bind *:${lport}
  default_backend be_${lport}

backend be_${lport}
  server s1 ${host}:${rport} check
EOF
done

exec haproxy -W -db -f "$cfg"
