#!/usr/bin/env bash
# see mysql-fork.sh for documentation

SOURCE_DB=$1
TARGET_DB=$2

BACKUP_DIR="/backup/current/dumps"

MYSQL=/usr/bin/mysql

echo "mysql-fork> importing schema $TARGET_DB"
zcat "$BACKUP_DIR/$SOURCE_DB-schema.gz"|"$MYSQL" "$TARGET_DB"