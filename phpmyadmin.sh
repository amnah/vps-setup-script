#!/bin/bash


# ------------ config -----------------
# set url to phpMyAdmin
# note that you need to use the zip version!
url="http://sourceforge.net/projects/phpmyadmin/files/latest/download"
# ------------ config -----------------

# copy old config and delete folder
cp /data/phpMyAdmin/config.inc.php .
mv /data/phpMyAdmin-*/ /data/bak.phpMyAdmin/

# download and unzip
mv download download.bak # just in case
wget $url
unzip -q download
rm download

# move folder and set up symbolic link
mv phpMyAdmin-* /data/
rm -f /data/phpMyAdmin
ln -s /data/phpMyAdmin-*/ /data/phpMyAdmin

# move config in
mv config.inc.php /data/phpMyAdmin/

# update permissions
chown -R www-data.www-data /data/phpMyAdmin-*/
find /data/phpMyAdmin-*/ -type d -print0 | xargs -0 chmod 0755
find /data/phpMyAdmin-*/ -type f -print0 | xargs -0 chmod 0644

# echo
echo -e "------------------------------------------"
echo -e "phpMyAdmin updated\n"
echo -e "$url \n"
echo -e "Remove backup folder and download file if successful\n"
echo -e "   rm -rf /data/bak.phpMyAdmin/ download.bak"
echo -e "------------------------------------------"
echo -e "phpmyadmin.sh finished"
echo -e "------------------------------------------"
