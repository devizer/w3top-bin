#!/usr/bin/env bash
set -e
set -u

if [[ $(uname -m) == armv7* ]]; then 
  rid=linux-arm; 
elif [[ $(uname -m) == aarch64 ]]; then 
  rid=linux-arm64; 
elif [[ $(uname -m) == x86_64 ]]; then 
  rid=linux-x64; 
fi; 
if [[ $(uname -s) == Darwin ]]; then 
  rid=osx-x64;
  echo Error: OS X binaries are not pre-compiled
  exit 1; 
fi;
if [ ! -e /etc/os-release ] && [ -e /etc/redhat-release ]; then
  local redhatRelease=$(</etc/redhat-release)
  if [[ $redhatRelease == "CentOS release 6."* || $redhatRelease == "Red Hat Enterprise Linux Server release 6."* ]]; then
    rid=rhel.6-x64;
  fi
fi
echo "The current OS architecture: $rid"

file=w3top-$rid.tar.gz
url=https://raw.githubusercontent.com/devizer/w3top-bin/master/public/$file

HTTP_PORT="${HTTP_PORT:-5050}"
RESPONSE_COMPRESSION="${RESPONSE_COMPRESSION:-True}"
INSTALL_DIR="${INSTALL_DIR:-/opt/w3top}"

# if initialization script then HOME is absent
if [[ -z "${HOME:-}" ]]; then copy=/tmp/$file; else copy=$HOME/$file; fi

echo "W3Top installation parameters:
    HTTP_PORT: $HTTP_PORT
    INSTALL_DIR: $INSTALL_DIR
    RESPONSE_COMPRESSION: $RESPONSE_COMPRESSION
    download url: $url
    temp download file: $copy
"

mkdir -p "$(dirname $copy)"
wget --no-check-certificate -O "$copy" "$url"  || curl -kSL -o "$copy" "$url"

sudo mkdir -p "$INSTALL_DIR"
sudo rm -rf "$INSTALL_DIR/*"
pushd "$INSTALL_DIR" >/dev/null
if [[ ! -z "$(command -v pv)" ]]; then
  pv "$copy" | sudo tar xzf -
else
  sudo tar xzf "$copy"
fi
sudo rm -f "$copy"
bash install-systemd-service.sh
popd >/dev/null
