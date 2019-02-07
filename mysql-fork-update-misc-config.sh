#!/usr/bin/env bash

TARGET_DB=$1

MYSQL=/usr/bin/mysql

echo "mysql-fork> updating misc site settings"

echo "UPDATE config SET value = CONCAT('FORK ', value) where path = 'meta.title';"|"$MYSQL" "$TARGET_DB"
echo "UPDATE config SET value = CONCAT('FORK ', value) where path = 'site.title';"|"$MYSQL" "$TARGET_DB"

# Unlock potential locks
echo "UPDATE cron_schedule SET status = 'success' WHERE status = 'running';"|"$MYSQL" "$TARGET_DB"
echo "UPDATE newsletter SET status = 5 WHERE status = 2;"|"$MYSQL" "$TARGET_DB"