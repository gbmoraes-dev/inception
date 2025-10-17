#!/bin/sh

set -e

DATADIR="/var/lib/mysql"

if [ -d "$DATADIR/$MYSQL_DATABASE" ]; then
  echo "MariaDB database already exists. Starting server..."
  exec mariadbd --user=mysql --console
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
  echo "ERROR: Missing one or more required environment variables." >&2
  exit 1
fi

echo "First time setup: Initializing MariaDB database..."

mariadb-install-db --user=mysql --datadir="$DATADIR" --basedir=/usr --force

chown -R mysql:mysql "$DATADIR"

mariadbd --user=mysql --bootstrap << EOF

USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER 'healthchecker'@'localhost' IDENTIFIED BY 'hc_password';
GRANT USAGE ON *.* TO 'healthchecker'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Database initialized successfully."

echo "Starting MariaDB server..."
exec mariadbd --user=mysql --console
