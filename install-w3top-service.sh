#!/usr/bin/env bash
set -e
set -u

if [[ $(uname -m) == armv7* ]]; then
  rid=linux-arm;
elif [[ $(uname -m) == aarch64 ]] || [[ $(uname -m) == armv8* ]]; then
  rid=linux-arm64;
elif [[ $(uname -m) == x86_64 ]] || [[ $(uname -m) == amd64 ]]; then
  rid=linux-x64;
fi;
if [[ $(uname -s) == Darwin ]]; then
  rid=osx-x64;
  echo Error: OS X binaries are not pre-compiled
  exit 1;
fi;
if [ -e /etc/os-release ]; then
  . /etc/os-release
  if [[ "${ID:-}" == "alpine" ]]; then
    rid=linux-musl-x64;
  fi
elif [ -e /etc/redhat-release ]; then
  redhatRelease=$(</etc/redhat-release)
  if [[ $redhatRelease == "CentOS release 6."* || $redhatRelease == "Red Hat Enterprise Linux Server release 6."* ]]; then
    rid=rhel.6-x64;
  fi
fi
echo "The OS architecture: $rid"

url_version=https://raw.githubusercontent.com/devizer/w3top-bin/master/public/version.txt
version=$(wget -q -nv --no-check-certificate -O - $url_version 2>/dev/null || curl -ksfL $url_version 2>/dev/null || echo "unknown")
url_primary=https://dl.bintray.com/devizer/W3-Top/$version/w3top-$rid.tar.gz
url_sha256="${url_primary}.sha256"
sha256=$(wget -q -nv --no-check-certificate -O - $url_sha256 2>/dev/null || curl -ksfL $url_sha256 2>/dev/null || echo "unknown")

file=w3top-$rid.tar.gz
url_secondary=https://raw.githubusercontent.com/devizer/w3top-bin/master/public/$file

HTTP_PORT="${HTTP_PORT:-5050}"
RESPONSE_COMPRESSION="${RESPONSE_COMPRESSION:-True}"
INSTALL_DIR="${INSTALL_DIR:-/opt/w3top}"

# if initialization script then HOME is absent
if [[ -z "${HOME:-}" ]]; then copy=/tmp/$file; else copy=$HOME/$file; fi

echo "W3Top installation parameters:
    HTTP_PORT: $HTTP_PORT
    INSTALL_DIR: $INSTALL_DIR
    RESPONSE_COMPRESSION: $RESPONSE_COMPRESSION
Internal installer variables:
    version per metadata (optional): $version
    primary download url: $url_primary
    secondary download url: $url_secondary
    sha256 hash: $sha256
    temp download file: $copy
"

mkdir -p "$(dirname $copy)"
ok="false"
for url in $url_primary $url_secondary; do
  wget --no-check-certificate -O "$copy" "$url"  || curl -kfSL -o "$copy" "$url" || continue;
  if [[ "$url" == "$url_primary" ]]; then 
    echo "Checking integrity of $(basename $url_primary) ..."
    if echo "$sha256 $copy" | sha256sum -c - ; then ok=true; break; fi
  else ok=true; fi;
done

if [[ $ok != true ]]; then echo Error downloading $(basename "$url_primary"); exit 1; fi

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
