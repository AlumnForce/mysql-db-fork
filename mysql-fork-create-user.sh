#!/usr/bin/env bash

TARGET_DB=$1
PASSWORD=$1

echo "mysql-fork> creating user $TARGET_DB with all privileges for database $TARGET_DB"

MYSQL=/usr/bin/mysql

echo "GRANT USAGE ON *.* TO '${TARGET_DB}'@'%' IDENTIFIED BY '${PASSWORD}'"|"$MYSQL"
echo "GRANT ALL PRIVILEGES ON \`${TARGET_DB}\`.* TO '${TARGET_DB}'@'%'"|"$MYSQL"
echo "FLUSH PRIVILEGES"|"$MYSQL"