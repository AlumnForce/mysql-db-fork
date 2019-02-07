#!/usr/bin/env bash

echo "mysql-fork> 3/3 purging expired database backups"

find /backup -maxdepth 1 -mindepth 1 -not -regex "/backup/current" -not -regex $(readlink -f /backup/current) -exec rm -r "{}" \;