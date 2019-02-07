#!/usr/bin/env bash
# see mysql-fork.sh for documentation

TIMESTAMP="$1"
BACKUP_DIR="/backup/${TIMESTAMP}/dumps"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
SOURCE_REGEX='^db_....\$'

mkdir -p "$BACKUP_DIR"

start_sql() {
cat <<'END_HEREDOC'
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
END_HEREDOC
}


end_sql() {
cat <<'END_HEREDOC'
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
END_HEREDOC
}


#https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed
remove_foreign_keys() {
    sed -r 's/CONSTRAINT `[a-zA-Z_0-9]*` FOREIGN KEY .`[a-zA-Z_0-9]*`(, `[a-zA-Z_0-9]*`)*. REFERENCES `[a-zA-Z_0-9]*` .`[a-zA-Z_0-9]*`(, `[a-zA-Z_0-9]*`)*.( [A-Z ]+){0,1}//'|sed 's/\s,//'|sed -e ':a' -e 'N' -e '$!ba' -e 's/[)],\n\s\s\s/)\n/g'
}

extract_foreign_keys() {
    table=''
    egrep '^CREATE TABLE|^  CONSTRAINT'|while read line; do
    if [[ "$line" == "CREATE TABLE"* ]]; then
        table=$(echo "$line" | sed -r "s/CREATE TABLE \`(.+)\` ./\1/")
    else
        #remove trailing comma
        line=$(echo "$line"|sed 's/,$//')
        echo "ALTER TABLE \`$table\` ADD $line ;"
    fi
    done
}

databases=`"$MYSQL" --skip-column-names -e "select schema_name from information_schema.schemata where SCHEMA_NAME RLIKE '$SOURCE_REGEX';"`

echo "mysql-fork> 2/3 dumping structure into $BACKUP_DIR"

#TODO PERF ne pas faire 2 mysqldump, faire qu'un dump et extraire les foreign key et procedures dans un autre ficher
# pigz a été testé à la place de gzip mais pas de gain a été constaté, surement parce que les fichiers étaient trop
# petits pour gagner quoi que ce soit avec de la parallélisation

for db in $databases; do
    echo dumping "$db-schema"
    "$MYSQLDUMP" --no-create-db --force --opt --skip-add-drop-table --skip-triggers --skip-comments --no-data "$db" > /tmp/tmp_fork_dump_schema
    cat /tmp/tmp_fork_dump_schema | remove_foreign_keys | gzip --fast > "$BACKUP_DIR/$db-schema.gz"
    echo dumping "$db-foreign-keys"
    cat /tmp/tmp_fork_dump_schema | extract_foreign_keys | (start_sql && cat; end_sql) | gzip --fast > "$BACKUP_DIR/$db-foreign-keys.gz"
    echo dumping "$db-procedures"
    "$MYSQLDUMP" --routines --no-create-db --no-create-info --no-data "$db" | gzip --fast > "$BACKUP_DIR/$db-procedures.gz"
done

rm /tmp/tmp_fork_dump_schema
