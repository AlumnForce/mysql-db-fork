#!/usr/bin/env bash
# see mysql-fork.sh for documentation

TARGET_DB=$1

MYSQL=/usr/bin/mysql

echo "mysql-fork> discarding tablespaces of $TARGET_DB"

run_parallel_query() {
   echo "$1" | "$MYSQL" "$TARGET_DB"
}

export MYSQL
export TARGET_DB
export -f run_parallel_query

echo "
SELECT CONCAT('ALTER TABLE ', '$TARGET_DB', '.', table_name, ' DISCARD TABLESPACE;') as alter_table_query
FROM information_schema.tables
WHERE table_schema = '$TARGET_DB' AND engine='InnoDB';
"|"$MYSQL" --skip-column-names|parallel --no-notice run_parallel_query
