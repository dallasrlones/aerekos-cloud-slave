#!/usr/bin/env bash
set -eu -o pipefail

# Detect host IP using existing script
HERE="$(cd "$(dirname "$0")" && pwd)"
DETECT="$HERE/detect-host-ip.sh"
if [ ! -x "$DETECT" ]; then
  echo "Making $DETECT executable"
  chmod +x "$DETECT" || true
fi

HOST_IP=$("$DETECT")
if [ -z "$HOST_IP" ]; then
  echo "Could not detect host IP" >&2
  exit 1
fi

TMPFILE=$(mktemp /tmp/aerekos.env.XXXX)
printf 'HOST_IP=%s\n' "$HOST_IP" > "$TMPFILE"
echo "Starting docker compose with HOST_IP=$HOST_IP (envfile: $TMPFILE)"
docker compose --env-file "$TMPFILE" up --build
RET=$?
rm -f "$TMPFILE"
exit $RET
