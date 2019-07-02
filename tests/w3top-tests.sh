#!/usr/bin/env bash

function install_w3top() {
export HTTP_PORT=5050
export RESPONSE_COMPRESSION=True
export INSTALL_DIR=/opt/w3top
script=https://raw.githubusercontent.com/devizer/w3top-bin/master/install-w3top-service.sh
(wget -q -nv --no-check-certificate -O - $script 2>/dev/null || curl -ksSL $script) | bash
sleep 5
echo "LOGS"
if [[ -f /etc/systemd/system/w3top.service ]]; then sudo journalctl -u w3top.service; else cat /tmp/w3top.log; fi
}

function centos_curl_only() {
yum remove -y wget
yum install -y curl
}

function centos_wget_only() {
yum remove -y curl
yum install -y wget
}

function debian_prepare() {
apt-get install -y sudo wget curl
}

function mysql_51_on_centos_6() {
yum install -y tar sudo
sudo yum install -y mysql-server mysql
sudo chkconfig mysqld on
sudo /etc/init.d/mysqld start
sudo mysqladmin -u root password secret


# Create empty database w3top ... 
# w3top relies on default DB's charset and collation
user=root; password=secret
mysql -u $user -p"$password" -e "DROP DATABASE w3top;" 2>/dev/null || true
mysql -u $user -p"$password" -e "CREATE DATABASE w3top CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
# ... and grant access to it for user w3top identified by password D0tN3t;42
mysql -u $user -p"$password" -e "DROP USER 'w3top'@'localhost';" 2>/dev/null  || true
mysql -u $user -p"$password" -e "CREATE USER 'w3top'@'localhost' IDENTIFIED BY 'D0tN3t;42'; GRANT ALL PRIVILEGES ON w3top.* TO 'w3top'@'localhost' WITH GRANT OPTION;"
mysql -u w3top -p'D0tN3t;42' -e "SHOW VARIABLES LIKE \"%version%\";" w3top
export MYSQL_DATABASE='Server=localhost;Database=w3top;Port=3306;Uid=w3top;Pwd="D0tN3t;42";Connect Timeout=20;Pooling=false;'
export PGSQL_DATABASE=
}

function pg_84_on_centos_6()
{
yum install -y tar sudo
sudo yum install -y postgresql postgresql-server postgresql-contrib
sudo service postgresql initdb
echo '
local  all  all                ident
host   all  all  127.0.0.1/32  md5
host   all  all  ::1/128       md5
' | sudo tee /var/lib/pgsql/data/pg_hba.conf
sudo service postgresql restart
sudo -u postgres psql -q -t -c "Select Version();"

sudo -u postgres psql -c "CREATE ROLE admin WITH SUPERUSER LOGIN PASSWORD 'pass';"
PGPASSWORD=pass psql -t -h localhost -p 5432 -U admin -q -c "select version();" -d postgres
echo Ver: $(eval 'PGPASSWORD=pass psql -t -h localhost -p 5432 -U admin -q -c "select version();" -d postgres')

commands=( \
  "drop database if exists w3top;" \
  "drop user if exists w3top;" \
  "create database w3top;" \
  "create user w3top;" \
  "ALTER USER w3top WITH PASSWORD 'pass';" \
  "grant all on DATABASE w3top to w3top;" \
)
for sql in "${commands[@]}"; do
  pushd /tmp >/dev/null
  sudo -u postgres psql -q -t -c "$sql"
  popd >/dev/null
done

PGPASSWORD=pass psql -t -h localhost -p 5432 -U w3top -q -c "select 'Hello, ' || current_user;" -d w3top
export MYSQL_DATABASE=
export PGSQL_DATABASE="Host=localhost;Port=5432;Database=w3top;Username=w3top;Password=pass;Timeout=15;Pooling=false;"
}

# centos_curl_only && mysql_51_on_centos_6 && install_w3top
# centos_wget_only && mysql_51_on_centos_6 && install_w3top
# centos_curl_only && pg_84_on_centos_6 && install_w3top
# centos_wget_only && pg_84_on_centos_6 && install_w3top

