
function downgrade_open_ssl_3() {
  sslver=$(get_openssl_system_version)
  Say "SYSTEM OPENSSL VERSION: [$sslver]"
  if [[ "$sslver" == 3* ]]; then 
    export OPENSSL_HOME="${OPENSSL_HOME:-/opt/openssl}"
    Say "Building openssl 1.1 to [$OPENSSL_HOME]"
    install_openssl_111
    export APP_LD_LIBRARY_PATH=$OPENSSL_HOME/lib
  fi
}

function get_openssl_system_version() {
  local ret="$(openssl version 2>/dev/null | awk '{print $2}')"; ret=""
  if [[ -z "$ret" ]]; then
    if [[ -n "$(command -v apt-get)" ]]; then
      ret="$(apt-cache show openssl | grep -E '^Version:' | awk '{print $2}' | sort -V -r)"
    fi
    if [[ -n "$(command -v dnf)" ]]; then
      ret="$(dnf list openssl | grep -E '^openssl' | awk '{print $2}' | awk -F":" 'NR==1 {print $NF}')"
    elif [[ -n "$(command -v yum)" ]]; then
      ret="$(yum list openssl | grep -E '^openssl' | awk '{print $2}' | awk -F":" 'NR==1 {print $NF}')"
    fi
    if [[ -n "$(command -v zypper)" ]]; then
      ret="$(zypper info openssl | grep -E '^Version(\ *):' | awk -F':' '{v=$2; gsub(/ /,"", v); print v}' | sort -V -r)"
    fi
  fi
  echo $ret
}

function install_openssl_111() {
  OPENSSL_HOME=${OPENSSL_HOME:-/opt/openssl}
  OPENSSL_VERSION="${OPENSSL_VERSION:-1.1.1m}"

  command -v apt-get 1>/dev/null &&
     (apt-get update -q; apt-get install build-essential make autoconf libtool zlib1g-dev curl wget -y -q)
  if [[ "$(command -v dnf)" != "" ]]; then
     (dnf install gcc make autoconf libtool perl zlib-devel curl wget -y -q)
  fi
  if [[ "$(command -v zypper)" != "" ]]; then
     zypper -n in -y gcc make autoconf libtool perl zlib-devel curl tar gzip wget
  fi

  url=https://www.openssl.org/source/openssl-1.1.1m.tar.gz
  file=$(basename $url)
  TRANSIENT_BUILDS="${TRANSIENT_BUILDS:-$HOME/build}"
  work=$TRANSIENT_BUILDS/build/open-ssl-1.1
  mkdir -p $work
  pushd $work
  curl -kSL -o _$file $url || curl -kSL -o _$file $url
  tar xzf _$file
  cd open*

  ./config --prefix=$OPENSSL_HOME --openssldir=$OPENSSL_HOME
  time make -j
  # make test
  make install
  popd
  rm -rf $work
}

