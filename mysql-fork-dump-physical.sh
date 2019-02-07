#!/usr/bin/env bash

timestamp="$1"

MYSQL=/usr/bin/mysql
SOURCE_REGEX='^db_....\$'

echo "mysql-fork> 1/3 creating physical backup for all bases"

mkdir -p /backup;

echo "Generating a list of database to backup"
# ensure this file is deleted because mysql does not allow overwrite
rm /tmp/list_databases.txt 2>/dev/null || true
echo "select schema_name from information_schema.schemata where SCHEMA_NAME RLIKE '$SOURCE_REGEX' INTO OUTFILE '/tmp/list_databases.txt';"|"$MYSQL"

cat /tmp/list_databases.txt

# La meilleure performance a été trouvée avec le nb de CPU pour parallel & compress-threads, le chunk-size par défaut
mariabackup -uroot --parallel=$(nproc) --compress-threads=$(nproc) --compress --databases-file="/tmp/list_databases.txt" --backup --target-dir="/backup/$timestamp";

rm /tmp/list_databases.txt

# benchs sur s5
# time mariabackup -uroot --parallel=16 --compress --backup --target-dir="/backup/tmp2";
# real    4m11.548s
# user    3m19.148s
# sys     1m52.028s
#
# time mariabackup -uroot --parallel=4 --compress --backup --target-dir="/backup/tmp3";
# real    4m27.095s
# user    3m22.692s
# sys     1m54.992s
#
# time mariabackup -uroot --compress-threads=16 --compress --backup --target-dir="/backup/tmp4";
# real    3m25.085s
# user    3m17.204s
# sys     0m56.796s
#
# time mariabackup -uroot --compress-threads=16 --compress-chunk-size=5M --compress --backup --target-dir="/backup/tmp4";
# real    4m47.281s
# user    2m59.948s
# sys     0m53.144s
#
# time mariabackup -uroot --compress-threads=4 --compress --backup --target-dir="/backup/tmp4";
# real    4m11.865s
# user    3m22.200s
# sys     1m11.632s
#
# time mariabackup -uroot --compress-threads=10 --compress --backup --target-dir="/backup/tmp6";
# real    3m36.912s
# user    3m21.988s
# sys     1m2.336s
#
# time mariabackup -uroot --compress-threads=16 --compress --backup --target-dir="/backup/tmp7";
# real    3m25.085s
# user    3m17.204s
# sys     0m56.796s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress  --backup --target-dir="/backup/tmp7";
# real    1m42.629s
# user    3m21.056s
# sys     1m6.952s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress --compress-chunk-size=5M --backup --target-dir="/backup/tmp7";
# real    2m29.942s
# user    2m53.728s
# sys     0m56.176s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress --compress-chunk-size=1M --backup --target-dir="/backup/tmp8";
# real    1m36.857s
# user    2m49.992s
# sys     0m49.596s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress --compress-chunk-size=512K --backup --target-dir="/backup/tmp8";
# real    1m36.303s
# user    2m55.820s
# sys     0m50.324s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress --compress-chunk-size=32K --backup --target-dir="/backup/tmp";
# real    1m40.056s
# user    3m17.736s
# sys     1m21.772s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress --compress-chunk-size=2M --backup --target-dir="/backup/tmp8";
# real    1m41.968s
# user    2m29.208s
# sys     0m47.784s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress --compress-chunk-size=128K --backup --target-dir="/backup/tmp3";
# real    1m35.231s
# user    3m4.632s
# sys     0m57.080s
#
# time mariabackup -uroot --parallel=16 --compress-threads=16 --compress --compress-chunk-size=16K --backup --target-dir="/backup/tmp4";
# real    1m41.009s
# user    3m24.884s
# sys     1m47.040s
