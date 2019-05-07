### W3-Top
W3-Top isn't grafana, htop, atop, iotop or gnome-system-monitor. It's all together with web interface and built-in benchmarks. 

Here is a build tools for w3top, an http-based monitoring and bench-marking tool based on KernelManagementJam

### Supported OS are provided by dotnet core 
- Debian 8 & 9, Ubuntu 14.04 ... 19.04
- OpenSUSE 42 & 15, SLES 12 & 15
- CentOS 6 & 7, Fedora 24 ... 30, RedHat 7

Supported architectures: x64, armv7 (32-bit) and aarch64 (arm 64-bit)

Alpine Linux and legacy RedHat 6 are also supported but it should be compiled from sources: https://github.com/devizer/KernelManagementLab.
The script below doesn't yet support RedHat 6 and Alpine Linux

### Installation of precompiled binaries
Short instruction: extract 
[w3top-linux-x64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-x64.tar.gz),
[w3top-linux-arm.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm.tar.gz) or 
[w3top-linux-arm64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm64.tar.gz) archive 
and run "./Universe.W3Top" or install SystemD service using `install-systemd-service.sh`

Shorter option:
```
HTTP_PORT=5050
RESPONSE_COMPRESSION=True
INSTALL_DIR=/opt/w3top
url=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh; 
(wget -q -nv --no-check-certificate -O - $url 2>/dev/null || curl -ksSL $url) | bash
```
