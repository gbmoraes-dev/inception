#!/bin/sh

set -e

if [ -f "/var/lib/mysql/.initialized" ]; then
  echo "MariaDB already initialized. Starting server..."
  exec mariadbd --user=mysql --console
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
  echo "ERROR: One or more environment variables (MYSQL_...) are not defined." >&2
  exit 1
fi

echo "Configuring MariaDB for the first time..."

mariadbd --user=mysql --bootstrap << EOF

USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS '$MYSQL_DATABASE';
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
FLUSH PRIVILEGES;
EOF

touch /var/lib/mysql/.initialized

echo "MariaDB configured successfully."

echo "Starting MariaDB server..."
exec mariadbd --user=mysql --console
