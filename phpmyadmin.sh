#!/bin/bash


# ------------ config -----------------
# set url to phpMyAdmin
# note that you need to use the zip version!
url="http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.0.6/phpMyAdmin-4.0.6-all-languages.zip/download"
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
ln -sf /data/phpMyAdmin-*/ /data/phpMyAdmin

# move config in
mv config.inc.php /data/phpMyAdmin/

# echo
echo -e "------------------------------------------"
echo -e "phpMyAdmin updated\n"
echo -e "$url \n"
echo -e "Remove backup folder if successful\n"
echo -e "rm -rf /data/bak.phpMyAdmin/"
echo -e "------------------------------------------"
echo -e "phpMyAdmin.sh finished"
echo -e "------------------------------------------"
