#!/usr/bin/env bash

function mysql_51_on_centos_6() {
  prepare_centos
  yum install -y tar sudo
  sudo yum install -y mysql-server mysql
  sudo chkconfig mysqld on
  sudo /etc/init.d/mysqld start
  user=root; password=secret
  sudo mysqladmin -u $user password "$password"

  # Create empty database w3top ... 
  # w3top relies on default DB's charset and collation
  mysql -u $user -p"$password" -e "DROP DATABASE w3top;" 2>/dev/null || true
  mysql -u $user -p"$password" -e "CREATE DATABASE w3top CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

  # ... and grant access to it for user w3top identified by password D0tN3t;42
  mysql -u $user -p"$password" -e "DROP USER 'w3top'@'localhost';" 2>/dev/null  || true
  mysql -u $user -p"$password" -e "CREATE USER 'w3top'@'localhost' IDENTIFIED BY 'D0tN3t;42'; GRANT ALL PRIVILEGES ON w3top.* TO 'w3top'@'localhost' WITH GRANT OPTION;"
  Say "MY SQL VERSION:"
  mysql -u w3top -p'D0tN3t;42' -e "SHOW VARIABLES LIKE \"%version%\";" w3top
  
  echo "export MYSQL_DATABASE='Server=localhost;Database=w3top;Port=3306;Uid=w3top;Pwd=\"D0tN3t;42\";Connect Timeout=20;Pooling=false;'" > ~/w3top.env
  source ~/w3top.env
}

