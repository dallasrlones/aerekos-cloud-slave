#!/usr/bin/env bash
set -eu -o pipefail

detect_darwin_specs() {
  local hostname os_version arch total_mem cpu_model cpu_cores

  hostname=$(hostname -s 2>/dev/null || echo "unknown")
  os_version=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
  arch=$(uname -m 2>/dev/null || echo "unknown")
  
  # Get total memory in GB
  total_mem=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.2f", $1/1024/1024/1024}' || echo "0")
  
  # Get CPU info
  cpu_model=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "unknown")
  cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "0")

  cat <<EOF
{
  "hostname": "$hostname",
  "os": "darwin",
  "os_version": "$os_version",
  "architecture": "$arch",
  "memory_gb": $total_mem,
  "cpu": {
    "model": "$cpu_model",
    "cores": $cpu_cores
  }
}
EOF
}

detect_linux_specs() {
  local hostname os_name os_version arch total_mem cpu_model cpu_cores

  hostname=$(hostname -s 2>/dev/null || echo "unknown")
  
  # Try to get OS info from /etc/os-release
  if [ -f /etc/os-release ]; then
    os_name=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"' 2>/dev/null || echo "Linux")
    os_version=$(grep '^VERSION_ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' 2>/dev/null || grep '^VERSION=' /etc/os-release | cut -d'=' -f2 | tr -d '"' 2>/dev/null || echo "unknown")
  else
    os_name="Linux"
    os_version=$(uname -r 2>/dev/null || echo "unknown")
  fi
  
  arch=$(uname -m 2>/dev/null || echo "unknown")
  
  # Get total memory in GB
  if [ -f /proc/meminfo ]; then
    total_mem=$(awk '/MemTotal:/ {printf "%.2f", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "0")
  else
    total_mem="0"
  fi
  
  # Get CPU info
  if [ -f /proc/cpuinfo ]; then
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d':' -f2 | xargs 2>/dev/null || echo "unknown")
    cpu_cores=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "0")
  else
    cpu_model="unknown"
    cpu_cores="0"
  fi

  cat <<EOF
{
  "hostname": "$hostname",
  "os": "linux",
  "os_name": "$os_name",
  "os_version": "$os_version",
  "architecture": "$arch",
  "memory_gb": $total_mem,
  "cpu": {
    "model": "$cpu_model",
    "cores": $cpu_cores
  }
}
EOF
}

detect_windows_specs() {
  local hostname os_version arch total_mem cpu_model cpu_cores

  # Best-effort PowerShell call (only when run from mingw/cygwin with pwsh available)
  if command -v powershell >/dev/null 2>&1; then
    hostname=$(powershell -NoProfile -Command "hostname" 2>/dev/null | tr -d '\r' || echo "unknown")
    os_version=$(powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Version" 2>/dev/null | tr -d '\r' || echo "unknown")
    arch=$(powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).OSArchitecture" 2>/dev/null | tr -d '\r' || echo "unknown")
    total_mem=$(powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB" 2>/dev/null | tr -d '\r' || echo "0")
    cpu_model=$(powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name" 2>/dev/null | tr -d '\r' || echo "unknown")
    cpu_cores=$(powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors" 2>/dev/null | tr -d '\r' || echo "0")
  else
    hostname="unknown"
    os_version="unknown"
    arch="unknown"
    total_mem="0"
    cpu_model="unknown"
    cpu_cores="0"
  fi

  cat <<EOF
{
  "hostname": "$hostname",
  "os": "windows",
  "os_version": "$os_version",
  "architecture": "$arch",
  "memory_gb": $total_mem,
  "cpu": {
    "model": "$cpu_model",
    "cores": $cpu_cores
  }
}
EOF
}

main() {
  case "$(uname -s)" in
    Darwin)
      detect_darwin_specs
      ;;
    Linux)
      detect_linux_specs
      ;;
    MINGW*|MSYS*|CYGWIN*)
      detect_windows_specs
      ;;
    *)
      echo '{"hostname":"unknown","os":"unknown","os_version":"unknown","architecture":"unknown","memory_gb":0,"cpu":{"model":"unknown","cores":0}}'
      ;;
  esac
}

main

