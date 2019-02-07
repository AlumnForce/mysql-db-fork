#!/usr/bin/env bash

TARGET_DB=$1
PASSWORD=$1

echo "mysql-fork> deleting database and user $TARGET_DB"

MYSQL=/usr/bin/mysql

# Killing all process from user
# http://dbadiaries.com/how-to-kill-all-mysql-processes-for-a-specific-user/

# ensure this file is deleted because mysql does not allow overwrite
rm /tmp/kill_process.txt 2>/dev/null || true
echo "SELECT CONCAT('KILL ',id,';') AS run_this FROM information_schema.processlist WHERE user='${TARGET_DB}' INTO OUTFILE '/tmp/kill_process.txt';"|"$MYSQL"
echo "SOURCE /tmp/kill_process.txt"|"$MYSQL"
rm /tmp/kill_process.txt

# NOTE: IF EXISTS mariadb > 10.1.3
# https://mariadb.com/kb/en/library/drop-user/#if-exists
echo "DROP USER IF EXISTS ${TARGET_DB}"|"$MYSQL"
echo "DROP DATABASE IF EXISTS ${TARGET_DB}"|"$MYSQL"

if [ -d "/var/lib/mysql/${TARGET_DB}" ]
then
    echo "Oops, directory still exists after drop database. Manual deletion of resting files."
    rm -rf "/var/lib/mysql/${TARGET_DB}/"*

    echo "DROP DATABASE IF EXISTS ${TARGET_DB}"|"$MYSQL"
fi