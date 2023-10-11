#!/usr/bin/env bash

function install_dependencies() {
  if [[ "$(command -v curl)" == "" ]]; then 
    if [[ "$(command -v apt-get)" != "" ]]; then
      apt-get -y -qq install curl
    else
      echo ERROR: Unable to install curl
    fi
  fi
}

function prepare_centos_8() {
  echo "Resetting CentOS 8 Repo"
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
  yum makecache -q || yum makecache -q || yum makecache -q
}


function wait_for_http() {
  u="$1"; t=30; 
  printf "Waiting for [$u] during $t seconds ..."
  while [ $t -ge 0 ]; do 
    t=$((t-1)); 
    e1=249;
    if [[ "$(command -v curl)" != "" ]]; then curl --connect-timeout 3 -skf "$u" >/dev/null; e1=$?; fi
    if [[ "$e1" -ne 0 ]]; then
      if [[ "$(command -v wget)" != "" ]]; then wget -q -nv -t 1 -T 3 "$u" >/dev/null; e1=$?; fi
    fi
    if [ "$e1" -eq 249 ]; then printf "MISSING wget|curl\n"; return; fi
    if [ "$e1" -eq 0 ]; then printf " OK\n"; return; fi; 
    printf ".";
    sleep 1;
    done
  printf " FAIL\n";
}

function debian_prepare() {
  source /etc/os-release
  if [[ $ID == debian ]] && [[ $VERSION_ID == 8 ]]; then
    rm -f /etc/apt/sources.list.d/backports* || true
    echo '
deb http://deb.debian.org/debian jessie main
deb http://security.debian.org jessie/updates main
' > /dev/null # /etc/apt/sources.list, TOO COMPLEX. Extracted to adjust_os_repo()
    fi
  
  apt-get update -qq && apt-get install -y -qq sudo wget curl procps
  Say "Upgrading Debian|Ubuntu";
  apt-get upgrade -y -qq
  Say "Upgrade completed";
}

function install_w3top() {
  script=https://raw.githubusercontent.com/devizer/test-and-build/master/install-build-tools-bundle.sh; (wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash >/dev/null
  Say "Installing dotnet dependencies"
  url=https://raw.githubusercontent.com/devizer/glist/master/install-dotnet-dependencies.sh; (wget -q -nv --no-check-certificate -O - $url 2>/dev/null || curl -ksSL $url) | UPDATE_REPOS=true bash -e && echo "Successfully installed .NET Core Dependencies"

  sslver=$(get_openssl_system_version)
  Say "SYSTEM OPENSSL VERSION: [$sslver]"
  if [[ "$sslver" == 3* ]]; then 
    export OPENSSL_HOME=/opt/openssl
    Say "Building openssl 1.1 to [$OPENSSL_HOME]"
    install_openssl_111
    export APP_LD_LIBRARY_PATH=$OPENSSL_HOME/lib
  fi

  test -f ~/w3top.env && source ~/w3top.env

  export HTTP_PORT=5050
  export RESPONSE_COMPRESSION=True
  export INSTALL_DIR=/opt/w3top
  export DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=1
  script=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
  (wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
  wait_for_http "http://localhost:5050"
  Say "LOGS from Container"
  if [[ -f /etc/systemd/system/w3top.service ]]; then sudo journalctl -u w3top.service | head -999; else cat /tmp/w3top.log; fi
}

function opensuse_prepare()
{
  # opensuse/tumbleweed, opensuse/leap:15, opensuse/leap:42
  echo '
gpgcheck = off
repo_gpgcheck = off
pkg_gpgcheck = off
' >> /etc/zypp/zypp.conf

  zypper -n in -y curl sudo tar gzip || true
  zypper -n in -y insserv-compat || true
  sudo --version | head -1
}

function alpine_prepare() {
  script=https://raw.githubusercontent.com/devizer/test-and-build/master/install-build-tools-bundle.sh; (wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
  Say "Installing base utils"
  apk add --no-cache --no-progress curl tar sudo bzip2 bash openssl wget
  Say "Done"
}

function centos_curl_only() {
  yum install -y -q tar sudo
  yum remove -y -q wget
  yum install -y -q curl
}

function centos_wget_only() {
  yum install -y -q tar sudo
  yum remove -y -q curl
  yum install -y -q wget
}

function gentoo_prepare() {
  cmd='emerge --quiet --sync'; 
  time (eval $cmd || eval $cmd || eval $cmd); 
  cmd='emerge --quiet-build --quiet-fail sudo'
  time (eval $cmd || eval $cmd || eval $cmd); 
}

function fedora_prepare() {
  dnf install -y libstdc++ sudo tar -q
  dnf install sudo -q || dnf install sudo -q
  printf "\n\nINSTALLED:\n"
  dnf history userinstalled || true
}

