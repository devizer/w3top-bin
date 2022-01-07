
function get_openssl_system_version() {
  local ret="$(openssl version 2>/dev/null | awk '{print $2}')"; ret=""
  if [[ -z "$ret" ]]; then
    if [[ -n "$(command -v apt-get)" ]]; then
      ret="$(apt-cache show openssl | grep -E '^Version:' | awk '{print $2}' | sort -V -r)"
    fi
    if [[ -n "$(command -v dnf)" ]]; then
      ret="$(dnf list openssl | grep -E '^openssl' | awk '{print $2}' | awk -F":" '{print $2}')"
    elif [[ -n "$(command -v yum)" ]]; then
      ret="$(yum list openssl | grep -E '^openssl' | awk 'NR==1 {print $2}')"
    fi
  fi
  echo $ret
}

function install_opensll_111() {
  OPENSSL_HOME=${OPENSSL_HOME:-/opt/openssl}

  command -v apt-get 1>/dev/null &&
     (apt-get update -q; apt-get install build-essential make autoconf libtool zlib1g-dev curl wget -y -q)
  if [[ "$(command -v dnf)" != "" ]]; then
     (dnf install gcc make autoconf libtool perl zlib-devel curl wget -y -q)
  fi

  url=https://www.openssl.org/source/openssl-1.1.1m.tar.gz
  file=$(basename $url)
  work=~/build/open-ssl-1.1.1m
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

