#!/bin/bash
# *************************************************************
# file: mysqldump.sh
# date: 2007-07-04 00:22
# author: (c) by Marko Schulz - <info@tuxnet24.de>
# description: Get a mysqldump of all mysql databases.
# *************************************************************

# name of database user ( must have LOCK_TABLES rights )...
dbUsername="xxx"

# password of database user...
dbPassword="yyy"

# path to backup directory...
dbBackup="/data/dumps"

# *************************************************************

# get current date ( YYYY-MM-DD )...
date=$( date +%Y-%m-%d )

# get full dir
fullDir="$dbBackup/$date"

# create backup directory if not exists...
[ ! -d "$fullDir" ]  && mkdir -p $fullDir

# delete all old mysqldumps...
find $fullDir -type f -name '*.sql.gz' -exec rm -rf {} ';' >/dev/null 2>&1

# loop all databases...
for db in $( mysql -u $dbUsername --password=$dbPassword -Bse "show databases" ); do
    if [[ "$db" != "mysql" ]] && [[ "$db" != "test" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
        # get mysqldump of current database...
        echo "Dumping $db into $fullDir ..."
        mysqldump -u $dbUsername --password=$dbPassword --opt --databases $db | gzip -9 >${fullDir}/${db}.sql.gz
    fi
done

# tar everything
tar -czhpf data.tar.gz /data --exclude "vendor" --exclude "/data/phpMyAdmin*"