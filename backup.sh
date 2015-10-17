#!/bin/bash
# *************************************************************
# file: mysqldump.sh
# date: 2007-07-04 00:22
# author: (c) by Marko Schulz - <info@tuxnet24.de>
# description: Get a mysqldump of all mysql databases.
# *************************************************************

# name of database user ( must have LOCK_TABLES rights )
dbUsername='xxx'

# password of database user
dbPassword='yyy'

# path to backup directory
backupDir="~/dumps"

# *************************************************************

# calculate current date ( YYYY-MM-DD ) and backup file
date=$( date +%Y%m%d-%H%M%S )
filename="$date.tar.gz"
backupFile="$backupDir/$filename"

# create backup directory if it doesn't exist
[ ! -d "$backupDir" ] && mkdir -p $backupDir

# delete old sql dumps
sqlDir="/data/sql"
[ ! -d "$sqlDir" ] && mkdir -p $sqlDir
rf -rf $sqlDir/*

# loop all databases
for db in $( mysql -u $dbUsername --password=$dbPassword -Bse "show databases" ); do

    if [[ "$db" != "mysql" ]] && [[ "$db" != "test" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
        # get mysqldump of current database...
        sqlFile="$sqlDir/$db.sql.gz"
        echo "Dumping $db into $sqlFile ..."
        mysqldump -u $dbUsername --password=$dbPassword --opt --databases $db | gzip -9 > $sqlFile
    fi

done

tar -czhpf $backupFile /data --exclude "vendor" --exclude "vendor2" --exclude "/data/phpMyAdmin*" --exclude "f.amnah.net" \
        --exclude "web/assets/*" --exclude "node_modules"

#./dropbox_uploader.sh upload $backupFile $filename
