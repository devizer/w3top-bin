### W3-Top &nbsp;&nbsp;&nbsp; [![Build Status](https://travis-ci.org/devizer/w3top-bin.svg?branch=master)](https://travis-ci.org/devizer/w3top-bin)
W3-Top isn't grafana, htop, atop, iotop or gnome-system-monitor. It's all together with a web interface and built-in benchmarks.

Here is a build tool for w3top, an HTTP-based monitoring and benchmarking tool based on KernelManagementJam

Live demo: on the throttled single-core Xeon with 592M RAM, on the Orange PI board

### Supported OS are provided by dotnet core 
- Debian 8 & 9, Ubuntu 14.04 ... 19.04 and derivatives
- CentOS 6 & 7, Fedora 27 ... 30, RedHat 7 and derivatives
- OpenSUSE 42 & 15, SLES 12 & 15

Supported architectures: x64, armv7 (32-bit) and aarch64 (arm 64-bit)

Alpine Linux and legacy RedHat 6 are also supported but corresponding binaries are not precompiled. It should be compiled from sources with correct runtime identifier: [Install from source](https://github.com/devizer/KernelManagementLab#install-from-source).

The script below doesn't support RedHat 6 and Alpine Linux

### [Re]Installation of precompiled binaries
Short instruction: extract 
[w3top-linux-x64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-x64.tar.gz),
[w3top-linux-arm.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm.tar.gz) or 
[w3top-linux-arm64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm64.tar.gz) archive 
and run `./Universe.W3Top` or install SystemD service using `install-systemd-service.sh`

Shorter option:
```
export HTTP_PORT=5050
export RESPONSE_COMPRESSION=True
export INSTALL_DIR=/opt/w3top
script=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
(wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
```

### Prerequisites and requirements
Official .net core prerequisites: https://docs.microsoft.com/en-us/dotnet/core/linux-prerequisites

Unofficial one-line installer of them using builtin package manager (zypper, yum, dnf or apt):
```bash
script=https://raw.githubusercontent.com/devizer/glist/master/install-dotnet-dependencies.sh; 
(wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
```

As of now app needs 60Mb of RAM on arm 32-bit and 100Mb of RAM on x64/arm64.
Installer above needs common command line tools: bash, tar, gzip, and wget|curl.

### History
[WHATSNEW.md](https://github.com/devizer/KernelManagementLab/blob/master/WHATSNEW.md)

### Uninstall
```bash
sudo systemctl disable w3top.service
sudo rm -f /etc/systemd/system/w3top.service 
sudo rm -rf /opt/w3top
```

### Logs and Troubleshooting
```bash
journalctl -u w3top.service
```
