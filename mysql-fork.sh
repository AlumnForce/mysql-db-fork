#!/usr/bin/env bash

SOURCE_DB=$1
TARGET_DB=$2
# database fork using mariabackup + mysqldump
# How it works
# First we need a physical backup of the whole database using mariabackup + a logical backup with mysqldump
# It is not possible to import live a backup of a database, to do so anyway we
# First import the database and tables with NO DATA, NO PROCEDURES, NO FOREIGN KEYS
# Then we tell mysql to discard the files associated to theses tables with DROP TABLESPACE
# Then we copy a backup of these tables inside mysql's folder
# Then we tell mysql to reattach to these files
# Then we import the rest, foreign keys and procedures

# before call this script you need to have a valid backup
#bash /opt/scripts/mysql-fork-dump-physical.sh
#bash /opt/scripts/mysql-fork-dump-structure.sh

echo "mysql-fork> forking $SOURCE_DB into $TARGET_DB"
# target only
time bash /opt/scripts/mysql-fork-create-database.sh "$TARGET_DB"
time bash /opt/scripts/mysql-fork-import-schema.sh "$SOURCE_DB" "$TARGET_DB"
time bash /opt/scripts/mysql-fork-discard-tablespace.sh "$TARGET_DB"
time bash /opt/scripts/mysql-fork-copy-tablespace.sh "$SOURCE_DB" "$TARGET_DB"
time bash /opt/scripts/mysql-fork-import-tablespace.sh "$TARGET_DB"
time bash /opt/scripts/mysql-fork-import-others.sh "$SOURCE_DB" "$TARGET_DB"
# post tasks
time bash /opt/scripts/mysql-fork-create-user.sh "$TARGET_DB"
time bash /opt/scripts/mysql-fork-fake-elasticsearch-index.sh "$TARGET_DB"
time bash /opt/scripts/mysql-fork-update-misc-config.sh "$TARGET_DB"