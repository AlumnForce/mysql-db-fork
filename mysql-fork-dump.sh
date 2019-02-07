#!/usr/bin/env bash

echo "mysql-fork> Starting backup dumps"

timestamp=$(date +%s)

bash /opt/scripts/mysql-fork-dump-physical.sh "$timestamp"
bash /opt/scripts/mysql-fork-dump-structure.sh "$timestamp"

ln -snf "/backup/$timestamp" /backup/current

bash /opt/scripts/mysql-fork-dump-purge-expired.sh