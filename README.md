### W3-Top
W3-Top isn't grafana, htop, atop, iotop or gnome-system-monitor. It's all together with a web interface and built-in benchmarks.

Here is a build tool for w3top, an HTTP-based monitoring and benchmarking tool based on KernelManagementJam

Live demo: on the throttled Xeon with 592M RAM, on the Orange PI board

### Supported OS are provided by dotnet core 
- Debian 8 & 9, Ubuntu 14.04 ... 19.04
- OpenSUSE 42 & 15, SLES 12 & 15
- CentOS 6 & 7, Fedora 24 ... 30, RedHat 7

Supported architectures: x64, armv7 (32-bit) and aarch64 (arm 64-bit)

Alpine Linux and legacy RedHat 6 are also supported but it should be compiled from sources with correct runtime identifier: https://github.com/devizer/KernelManagementLab#install-from-source.
The script below doesn't support RedHat 6 and Alpine Linux

### [Re]Installation of precompiled binaries
Short instruction: extract 
[w3top-linux-x64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-x64.tar.gz),
[w3top-linux-arm.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm.tar.gz) or 
[w3top-linux-arm64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm64.tar.gz) archive 
and run `./Universe.W3Top` or install SystemD service using `install-systemd-service.sh`

Shorter option:
```
HTTP_PORT=5050
RESPONSE_COMPRESSION=True
INSTALL_DIR=/opt/w3top
url=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
(wget -q -nv --no-check-certificate -O - $url 2>/dev/null || curl -ksSL $url) | bash
```

### Prerequisites and requirements
Official .net core prerequisites: https://docs.microsoft.com/en-us/dotnet/core/linux-prerequisites

Unofficial one-line installer of them using builtin package manager (zypper, yum, dnf or apt):
```bash
url=https://raw.githubusercontent.com/devizer/glist/master/install-dotnet-dependencies.sh; 
(wget -q -nv --no-check-certificate -O - $url 2>/dev/null || curl -ksSL $url) | bash
```

As of now app needs 60Mb of RAM on arm 32-bit and 100Mb of RAM on x64/arm64.
Installer above needs common command line tools: bash, bzip and wget|curl.

### History
https://github.com/devizer/KernelManagementLab/blob/master/WHATSNEW.md

### Unininstall
```bash
sudo systemctl disable w3top.service
sudo rm -f /etc/systemd/system/w3top.service 
sudo rm -rf /opt/w3top
```

### Troubleshooting
```bash
journalctl -u w3top.service
```
