set -eu; set -o pipefail
function try_install() {
  export HTTP_HOST=0.0.0.0 HTTP_PORT=5050
  export RESPONSE_COMPRESSION=True
  export INSTALL_DIR=/opt/w3top
  script=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
  (wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
}
sudo systemctl disable w3top.service 2>/dev/null || true
for GCC_FORCE_GZIP_PRIORITY in True ""; do
  export GCC_FORCE_GZIP_PRIORITY;
  export SKIP_ARIA=True SKIP_CURL=True SKIP_WGET="";   try_install
  export SKIP_ARIA=True SKIP_CURL=""   SKIP_WGET=True; try_install
  export SKIP_ARIA=""   SKIP_CURL=True SKIP_WGET=TRUE; try_install
done
Say "COMPLETE SUCCESS"
