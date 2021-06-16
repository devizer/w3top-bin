### W3-Top &nbsp;&nbsp;&nbsp;[![W3Top Stable Version](https://img.shields.io/github/v/release/devizer/KernelManagementLab?label=Stable)](https://github.com/devizer/w3top-bin/blob/master/README.md#reinstallation-of-precompiled-binaries)

W3-Top isn't grafana, fio, sysbench, Crystal Disk Mark, htop, atop, iotop or gnome-system-monitor. It's all together with a web interface and built-in benchmarks.

Here is a build tool for w3top, an HTTP-based monitoring and benchmarking tool based on KernelManagementJam

Live demo: on the throttled single-core Xeon with 592M RAM, on the Orange PI board

### Supported OS are provided by dotnet core
- Debian 8, 9, 10 & 11, Ubuntu 14.04 ... 21.04 and derivatives
- Fedora 26 ... 32, CentOS/RedHat 6, 7 & 8 and derivatives (including Amazon Linux V1 and V2)
- OpenSUSE 42, 15 & Tumbleweed, SLES 12 & 15
- Alpine Linux 3.7+
- Generic Linux with libc.so version 2.17+ and GLIBCXX version 3.4.20+ (for example Gentoo and Arch)

Supported architectures: x64, armv7 (32-bit) and aarch64 (arm 64-bit). ArmV6 (Raspberry PI 1st and Raspberry PI Zero) is not supported.

### Supported exotic browsers
- Builtin Safari on iOS 9.2+
- Builtin Chrome on Android 5.1+
- IE 11, a builtin browser on Windows Server
- Firefox ESR 52 and Chrome 49, the latest browsers for Windows XP/2003

Pay attention, that these browsers are not perfect as the latest versions in performance. It is supposed that these ancient browsers should not be used on daily basis.

### [Re]Installation of precompiled binaries
Short instruction: extract 
[w3top-linux-x64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-x64.tar.gz),
[w3top-linux-arm.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm.tar.gz), 
[w3top-linux-arm64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-arm64.tar.gz), 
[w3top-linux-musl-x64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-linux-musl-x64.tar.gz) or
[w3top-rhel.6-x64.tar.gz](https://raw.githubusercontent.com/devizer/w3top-bin/master/public/w3top-rhel.6-x64.tar.gz) archive 
and run `./Universe.W3Top` or install SystemD service using `install-systemd-service.sh`


Shorter option:
```
export HTTP_PORT=5050
export RESPONSE_COMPRESSION=True
export INSTALL_DIR=/opt/w3top
script=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
(wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
```

This configures storage for benchmark and metrics history using sqlite3 database.
In addition, Postgres 8.4+, mysql 5.1+ and MS Sql Server are also supported. It is enough to export corresponding DATABASE-variable for script above:

```
# either mysql db
export MYSQL_DATABASE='Server=localhost;Database=w3top;Port=3306;Uid=w3top;Pwd="D0tN3t;42";Connect Timeout=20;'
# or postresql db
export PGSQL_DATABASE="Host=localhost;Port=5432;Database=w3top;Username=w3top;Password=pass;Timeout=15;"
# or MS Sql Server db
export MSSQL_DATABASE="Server=localhost,1433;Database=w3top;User=w3top;Password=pass;"
```

Examples of local-only accessed db configurations for w3top are prepared for 
[MySQL 5.1](https://raw.githubusercontent.com/devizer/w3top-bin/master/tests/mysql-5.1-on-centos-6.sh), 
[Postgres SQL 8.4](https://raw.githubusercontent.com/devizer/w3top-bin/master/tests/postres-8.4-on-centos-6.sh), 
[Postgres SQL 11](https://raw.githubusercontent.com/devizer/w3top-bin/master/tests/postres-11-on-centos-6.sh) 
on centos 6. By the way this scripts are used by CI auto-tests


### Prerequisites and requirements
Official .Net Core prerequisites: https://docs.microsoft.com/en-us/dotnet/core/linux-prerequisites

Unofficial one-line installer of them using built-in package manager (zypper, yum, dnf, apk or apt):
```bash
script=https://raw.githubusercontent.com/devizer/glist/master/install-dotnet-dependencies.sh;
(wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
```

As of now w3top service needs 60Mb of RAM on 32-bit arm and 100Mb of RAM on x64/arm64.
The Installer above needs common command line tools: `sudo`, `bash`, `tar`, `gzip`, `sha256sum` and `wget` | `curl`.

### History and Screenshots
[WHATSNEW.md](https://github.com/devizer/KernelManagementLab/blob/master/WHATSNEW.md)

### Uninstall
```bash
sudo systemctl disable w3top.service
sudo rm -f /etc/systemd/system/w3top.service 
sudo rm -rf /opt/w3top
```

### Logs and Troubleshooting
```bash
journalctl -u w3top.service || cat /tmp/w3top.log
```

For disk benchmark it is recommended to install latest fio and libaio. w3top comes with precompiled binaries of fio for all the supported architectures (x64, arm32 and arm64), but system fio takes precedence. 
After upgrading system fio or system libaio fio metadata cache should be flushed: ``rm -rf ~/.cache/fio; systemctl restart w3top``

### Compile from source
Compile from [source](https://github.com/devizer/KernelManagementLab#install-from-source).
