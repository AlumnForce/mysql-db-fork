#!/usr/bin/env bash
# see mysql-fork.sh for documentation

DB_SOURCE=$1
DB_TARGET=$2

cd "/backup/current/$DB_SOURCE/";

echo "mysql-fork> copying tablespace /backup/current/$DB_SOURCE/ to /var/lib/mysql/$DB_TARGET/"

# ancienne méthode rsync sur fichiers non compressés
#find . -regex '.*\.\(ibd\|cfg\)' -print0|rsync -av --files-from=- --from0 ./ "/var/lib/mysql/$DB_TARGET/";

uncompress_and_move_to_target() {
   qpress -d "$1" "/var/lib/mysql/$DB_TARGET/"
}

export DB_TARGET
export -f uncompress_and_move_to_target
find . -regex '.*\.\(ibd.qp\|cfg.qp\)'|parallel --no-notice uncompress_and_move_to_target

echo "done copying, chowning..."

chown -R mysql:mysql "/var/lib/mysql/$DB_TARGET/";