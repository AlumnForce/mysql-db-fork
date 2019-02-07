#!/usr/bin/env bash
# see mysql-fork.sh for documentation

SOURCE_DB=$1
TARGET_DB=$2

BACKUP_DIR="/backup/current/dumps"

MYSQL=/usr/bin/mysql

echo "mysql-fork> importing foreign keys $TARGET_DB"
zcat "$BACKUP_DIR/$SOURCE_DB-foreign-keys.gz"|"$MYSQL" "$TARGET_DB"

echo "mysql-fork> importing procedures $TARGET_DB"
zcat "$BACKUP_DIR/$SOURCE_DB-procedures.gz"|sed -e "s/DEFINER=.[a-z_0-9]*./DEFINER=\`$TARGET_DB\`/g"|"$MYSQL" "$TARGET_DB"
