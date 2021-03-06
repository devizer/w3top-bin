#!/usr/bin/env bash

function install_dependencies() {
  if [[ "$(command -v curl)" == "" ]]; then 
    if [[ "$(command -v apt)" != "" ]]; then
      apt-get -y install curl
    else
      echo ERROR: Unable to install curl
    fi
  fi
}

function install_w3top() {
  export HTTP_PORT=5050
  export RESPONSE_COMPRESSION=True
  export INSTALL_DIR=/opt/w3top
  script=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
  (wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
  sleep 6
  echo "LOGS"
  if [[ -f /etc/systemd/system/w3top.service ]]; then sudo journalctl -u w3top.service | head -999; else cat /tmp/w3top.log; fi
}

function opensuse_prepare()
{
  # opensuse/tumbleweed, opensuse/leap:15, opensuse/leap:42
  zypper in -y curl sudo tar gzip insserv-compat
}

function alpine_prepare() {
  apk add --no-cache curl tar sudo bzip2 bash
  script=https://raw.githubusercontent.com/devizer/test-and-build/master/install-build-tools-bundle.sh; (wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
  Say "Installing base utils"
  apk add --no-cache curl tar sudo bzip2 bash
  Say "Done"
}

function centos_curl_only() {
  yum install -y tar sudo
  yum remove -y wget
  yum install -y curl
}

function centos_wget_only() {
  yum install -y tar sudo
  yum remove -y curl
  yum install -y wget
}

function debian_prepare() {
  source /etc/os-release
  if [[ $ID == debian ]] && [[ $VERSION_ID == 8 ]]; then
    rm -f /etc/apt/sources.list.d/backports* || true
    echo '
deb http://deb.debian.org/debian jessie main
deb http://security.debian.org jessie/updates main
' > /etc/apt/sources.list
    fi
  apt-get update -qq && apt-get install -y -qq sudo wget curl procps
}

function fedora_prepare() {
  dnf install -y libstdc++ sudo
}

