#!/usr/bin/env bash
set -eu -o pipefail

detect_darwin() {
  local intf
  intf=$(route get default 2>/dev/null | awk '/interface:/{print $2}') || true
  if [ -n "$intf" ]; then
    ipconfig getifaddr "$intf" 2>/dev/null || true
  fi
}

detect_linux() {
  # prefer `ip route get` to get the source IP
  local out ip
  out=$(ip route get 1.1.1.1 2>/dev/null || true)
  ip=$(printf "%s" "$out" | awk '/src/ {for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')
  if [ -n "$ip" ]; then
    printf "%s" "$ip"
    return
  fi

  # fallback to hostname -I
  ip=$(hostname -I 2>/dev/null | awk '{print $1}') || true
  if [ -n "$ip" ]; then
    printf "%s" "$ip"
    return
  fi
}

detect_windows() {
  # best-effort PowerShell call (only when run from mingw/cygwin with pwsh available)
  powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.InterfaceAlias -notmatch 'vEthernet|Loopback' } | Select-Object -First 1 -ExpandProperty IPAddress" 2>/dev/null || true
}

main() {
  case "$(uname -s)" in
    Darwin)
      detect_darwin
      ;;
    Linux)
      detect_linux
      ;;
    *)
      detect_windows
      ;;
  esac
}

main
