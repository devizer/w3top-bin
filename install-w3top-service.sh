#!/usr/bin/env bash
set -e
set -u
set -o pipefail

function say() { 
   NC='\033[0m' Color_Green='\033[1;32m' Color_Red='\033[1;31m' Color_Yellow='\033[1;33m'; 
   local var="Color_${1:-}"
   local color="${!var}"
   shift 
   printf "${color:-}$*${NC}\n";
}

function find_decompressor() {
  COMPRESSOR_EXT=""
  COMPRESSOR_EXTRACT=""
  if [[ -n "${GCC_FORCE_GZIP_PRIORITY:-}" ]]; then
    if [[ "$(command -v gzip)" != "" ]]; then
      COMPRESSOR_EXT=gz
      COMPRESSOR_EXTRACT="gzip -f -d"
    elif [[ "$(command -v xz)" != "" ]]; then
      COMPRESSOR_EXT=xz
      COMPRESSOR_EXTRACT="xz -f -d"
    fi
  else
    if [[ "$(command -v xz)" != "" ]]; then
      COMPRESSOR_EXT=xz
      COMPRESSOR_EXTRACT="xz -f -d"
    elif [[ "$(command -v gzip)" != "" ]]; then
      COMPRESSOR_EXT=gz
      COMPRESSOR_EXTRACT="gzip -f -d"
    fi
  fi
}

function download_file_fialover() {
  local file="$1"
  shift
  for url in "$@"; do
    # DEBUG: echo -e "\nTRY: [$url] for [$file]"
    local err=0;
    download_file "$url" "$file" || err=$?
    # DEBUG: say Green "Download status for [$url] is [$err]"
    if [ "$err" -eq 0 ]; then return; fi
  done
  return 55;
}

try_count=0
function download_file() {
  local url="$1"
  local file="$2";
  local progress1="" progress2="" progress3="" 
  if [[ "$DOWNLOAD_SHOW_PROGRESS" != "True" ]] || [[ ! -t 1 ]]; then
    progress1="-q -nv"       # wget
    progress2="-s"           # curl
    progress3="--quiet=true" # aria2c
  fi
  rm -f "$file" 2>/dev/null || rm -f "$file" 2>/dev/null || rm -f "$file"
  local try1=""
  if [[ -z "${SKIP_ARIA:-}" ]] && [[ "$(command -v aria2c)" != "" ]]; then
    [[ -n "${try1:-}" ]] && try1="$try1 || "
    try1="aria2c $progress3 --allow-overwrite=true --check-certificate=false -s 9 -x 9 -k 1M -j 9 -d '$(dirname "$file")' -o '$(basename "$file")' '$url'"
  fi
  if [[ -z "${SKIP_CURL:-}" ]] && [[ "$(command -v curl)" != "" ]]; then
    [[ -n "${try1:-}" ]] && try1="$try1 || "
    try1="${try1:-} curl $progress2 -f -kSL -o '$file' '$url'"
  fi
  if [[ -z "${SKIP_WGET:-}" ]] && [[ "$(command -v wget)" != "" ]]; then
    [[ -n "${try1:-}" ]] && try1="$try1 || "
    try1="${try1:-} wget $progress1 --no-check-certificate -O '$file' '$url'"
  fi
  if [[ "${try1:-}" == "" ]]; then
    echo "error: niether curl, wget or aria2c is available"
    exit 42;
  fi
  local i=0;
  rm -f "$file" 2>/dev/null || true
  for i in 1 2 3; do
    try_count=$((try_count+1))
    if [[ "${try_count}" -gt 1 ]]; then
      say Red "Try #${try_count} to download $url"
    fi
     local err=""
     # say Green "$try1"
     eval $try1 || err=1
     if [[ -z "$err" ]]; then return; fi
  done
  return 55;
}

machine="$(uname -m || true)"; machine="${machine:-unknown}"
rid=unknown
if [[ "$machine" == armv7* ]]; then
  rid=linux-arm;
elif [[ "$machine" == aarch64 || "$machine" == armv8* || "$machine" == arm64* ]]; then
  rid=linux-arm64;
elif [[ "$machine" == x86_64 || "$machine" == amd64 ]]; then
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


find_decompressor

file="w3top-$rid.tar.${COMPRESSOR_EXT}"
url_version=https://raw.githubusercontent.com/devizer/w3top-bin/master/public/version.txt
# TODO: download version using download_file
# version=$(wget -q -nv --no-check-certificate -O - $url_version 2>/dev/null || curl -ksfL $url_version 2>/dev/null || echo "unknown")
tmp=$"${TMPDIR:-/tmp}"
export DOWNLOAD_SHOW_PROGRESS=""
download_file "$url_version" "${tmp}/${file}-version"
version="$(cat "${tmp}/${file}-version")"
url_primary=https://github.com/devizer/KernelManagementLab/releases/download/v$version/$file
url_secondary=https://dl.bintray.com/devizer/W3-Top/$version/w3top-$rid.tar.gz
url_sha256="${url_primary}.sha256"
# TODO: download sha256 using download_file
# sha256=$(wget -q -nv --no-check-certificate -O - $url_sha256 2>/dev/null || curl -ksfL $url_sha256 2>/dev/null || echo "unknown")
download_file "$url_sha256" "${tmp}/${file}-hash"
sha256="$(cat "${tmp}/${file}-hash")"

url_tertiary=https://raw.githubusercontent.com/devizer/w3top-bin/master/public/$file

url_4=https://sourceforge.net/projects/w3top/files/$version/w3top-rhel.6-x64.tar.xz.sha256/download
url_5="https://master.dl.sourceforge.net/project/w3top/$version/w3top-rhel.6-x64.tar.xz.sha256?viasf=1"

[[ -n "${SKIP_URL_1:-}" ]] && url_primary=""
[[ -n "${SKIP_URL_2:-}" ]] && url_tertiary=""
[[ -n "${SKIP_URL_3:-}" ]] && url_4=""
[[ -n "${SKIP_URL_4:-}" ]] && url_5=""

TMPDIR="${TMPDIR:-/tmp}"
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
    OS architecture: $rid
    version per metadata (optional): $version
    download url #1: $url_primary
    download url #2: $url_tertiary
    download url #3: $url_4
    download url #4: $url_5
    sha256 hash: $sha256
    temp download file: $copy
"

mkdir -p "$(dirname $copy)"
ok="false"
for url in "$url_primary" "$url_tertiary" "$url_4" "$url_5"; do
  if [[ -z "$url" ]]; then continue; fi
  export DOWNLOAD_SHOW_PROGRESS=True
  rm -f "$copy" || true
  err=""; download_file "${url}" "$copy" || err=1
  if [[ -n "$err" ]]; then continue; fi
  actual_hash="$(sha256sum "$copy" | awk '{print $1}')"
  if [[ "${actual_hash:-}" != "$sha256" ]]; then
    say Red "SHA256 mismatch. Actual is ${actual_hash:-}"
    continue;
  else
    say Green "SHA256 hash is correct. Extracting $copy to [$INSTALL_DIR]"
    ok=true
    break;
  fi
done

if [[ $ok != true ]]; then echo Error downloading $(basename "$url_primary"); exit 1; fi

sudo mkdir -p "$INSTALL_DIR"
sudo rm -rf "$INSTALL_DIR/*"
pushd "$INSTALL_DIR" >/dev/null
if [[ ! -z "$(command -v pv)" ]]; then
  pv "$copy" | eval $COMPRESSOR_EXTRACT | sudo tar xf - 2>&1 | { grep -v "implausibly old time stamp" || true; } | { grep -v "in the future" || true; }
else
  cat "$copy" | eval $COMPRESSOR_EXTRACT | sudo tar xf - 2>&1 | { grep -v "implausibly old time stamp" || true; } | { grep -v "in the future" || true; }
fi
sudo rm -f "$copy"
bash install-systemd-service.sh
popd >/dev/null
