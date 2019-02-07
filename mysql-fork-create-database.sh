#!/usr/bin/env bash
# see mysql-fork.sh for documentation

TARGET_DB=$1

MYSQL=/usr/bin/mysql

echo "mysql-fork> creating database $TARGET_DB"
echo "Trying to remove existing database"
"$MYSQL" -e "drop database if exists $TARGET_DB;"
echo "Removing potential residues from failed forks in database directory"
rm -rf "/var/lib/mysql/${TARGET_DB}/"*
echo "Remove database (second time)"
"$MYSQL" -e "drop database if exists $TARGET_DB;"
echo "Creating database $TARGET_DB"
"$MYSQL" -e "create database $TARGET_DB"