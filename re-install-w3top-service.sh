echo '#!/usr/bin/env bash
export HTTP_PORT=5050
export RESPONSE_COMPRESSION=True
export INSTALL_DIR=/opt/w3top
script=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
sudo rm -rf /root/.cache/fio;
(wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
sudo journalctl -fu w3top
' | sudo tee /usr/local/bin/re-install-w3top-service
sudo chmod +x /usr/local/bin/re-install-w3top-service

