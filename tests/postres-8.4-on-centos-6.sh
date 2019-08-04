#!/usr/bin/env bash

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
sudo service postgresql start
sleep 8
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
  echo "Exec sql [$sql]"
  sudo -u postgres psql -q -t -c "$sql"
  popd >/dev/null
done

PGPASSWORD=pass psql -t -h localhost -p 5432 -U w3top -q -c "select 'Hello, ' || current_user;" -d w3top
export MYSQL_DATABASE=
export PGSQL_DATABASE="Host=localhost;Port=5432;Database=w3top;Username=w3top;Password=pass;Timeout=15;Pooling=false;"
}

