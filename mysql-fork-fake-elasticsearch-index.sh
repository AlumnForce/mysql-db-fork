#!/usr/bin/env bash

TARGET_DB=$1

MYSQL=/usr/bin/mysql

echo "mysql-fork> set random elasticsearch index"

echo "UPDATE config SET value = CONCAT(value, '_fork_', LEFT(UUID(), 8)) where path = 'fullsearch.indexname';"|"$MYSQL" "$TARGET_DB"
