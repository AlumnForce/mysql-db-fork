<a href="https://www.alumnforce.com/">
    <p align="center">
        <img title="AlumnForce" src="alumnforce-logo.png" />
    </p>
</a>

# MariaDB database forking

This repository hosts a collection of scripts can that can be used to create very quickly database clones without expensive mysqldumps / restores.


How it works
------------

<p align="center">
    <img title="MySQL database forking" src="MySQL-database-forking.png" />
</p>




Requirements (on the same machine)
----------------------------------

- mariadb or mysql on linux
- mysqldump
- mariabackup (or xtrabackup for mysql) 
- [qpress](http://www.quicklz.com/)
- [GNU parallel](https://www.gnu.org/software/parallel/)
- mariadb > 10.1.3 or mysql >= 5.7
- databases with innodb tables only
- source databases names must have a common pattern that can be matched with a regex (ex db_xxxx)

How to use these scripts
------------------------

Put all the scripts in /opt/scripts.
Edit the scripts to suit your needs.

Important variable :
`SOURCE_REGEX` in `mysql-fork-dump-structure.sh` and `mysql-fork-dump-physical.sh`. Set it to a regex that matches the names of the source databases you want to fork.



The command `mysql` should be callable without requiring a password. If a password is required, configure a `.my.cnf`.

Run periodically `mysql-fork-dump.sh` to update the latest snapshot. It is because the databases are snapshoted in advance that creating a fork is so fast.

Run `mysql-fork.sh $SOURCE_DB $TARGET_DB` to create a new fork database with name `$TARGET_DB` from the latest snapshot of `$SOURCE_DB`.

