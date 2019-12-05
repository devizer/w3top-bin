#!/usr/bin/env bash

function pg_11_on_centos_6()
{
  yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-6-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  yum install -y postgresql11 postgresql11-server sudo 

  service postgresql-11 initdb
  service postgresql-11 start
  # chkconfig postgresql-11 on

  # allow access using login/password to to local apps only
  echo '
local  all  all                ident
host   all  all  127.0.0.1/32  md5
host   all  all  ::1/128       md5
' | sudo tee /var/lib/pgsql/11/data/pg_hba.conf

  sudo service postgresql-11 restart
  sudo -u postgres psql -q -t -c "Select Version();"

  sudo -u postgres psql -c "CREATE ROLE admin WITH SUPERUSER LOGIN PASSWORD 'pass';"
  PGPASSWORD=pass psql -t -h localhost -p 5432 -U admin -q -c "select version();" -d postgres
  echo Ver: $(eval 'PGPASSWORD=pass psql -t -h localhost -p 5432 -U admin -q -c "select version();" -d postgres')

  # create empty DB w3top and postgres user w3top with access to w3top DB only.
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

  # check permissions to w3top DB for w3top user
  PGPASSWORD=pass psql -t -h localhost -p 5432 -U w3top -q -c "select 'Hello, ' || current_user;" -d w3top
  export MYSQL_DATABASE=
  export PGSQL_DATABASE="Host=localhost;Port=5432;Database=w3top;Username=w3top;Password=pass;Timeout=15;Pooling=false;"
}

