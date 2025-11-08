#!/usr/bin/env bash
set -eu -o pipefail

# Detect host IP using existing script
HERE="$(cd "$(dirname "$0")" && pwd)"
DETECT_IP="$HERE/detect-host-ip.sh"
DETECT_SPECS="$HERE/detect-device-specs.sh"

if [ ! -x "$DETECT_IP" ]; then
  echo "Making $DETECT_IP executable"
  chmod +x "$DETECT_IP" || true
fi

if [ ! -x "$DETECT_SPECS" ]; then
  echo "Making $DETECT_SPECS executable"
  chmod +x "$DETECT_SPECS" || true
fi

HOST_IP=$("$DETECT_IP")
if [ -z "$HOST_IP" ]; then
  echo "Could not detect host IP" >&2
  exit 1
fi

DEVICE_SPECS=$("$DETECT_SPECS")
if [ -z "$DEVICE_SPECS" ]; then
  echo "Could not detect device specs" >&2
  exit 1
fi

# Convert multiline JSON to single line for env file
DEVICE_SPECS_ONELINE=$(echo "$DEVICE_SPECS" | tr -d '\n' | tr -d ' ')

TMPFILE=$(mktemp /tmp/aerekos.env.XXXX)
printf 'HOST_IP=%s\n' "$HOST_IP" > "$TMPFILE"
printf 'DEVICE_SPECS=%s\n' "$DEVICE_SPECS_ONELINE" >> "$TMPFILE"
echo "Starting docker compose with HOST_IP=$HOST_IP"
echo "Device specs: $DEVICE_SPECS"
docker compose --env-file "$TMPFILE" up --build
RET=$?
rm -f "$TMPFILE"
exit $RET
