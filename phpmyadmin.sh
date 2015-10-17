#!/bin/bash


# ------------ config -----------------
# set url to phpMyAdmin
# note that you need to use the zip version!
url="http://sourceforge.net/projects/phpmyadmin/files/latest/download"
# ------------ config -----------------

# copy old config and delete folder
sudo cp -f /var/www/phpMyAdmin/config.inc.php .
sudo rm -rf /var/www/phpMyAdmin-*

# download and unzip
sudo rm download
sudo wget $url
sudo unzip -q download
sudo rm download

# move folder and set up symbolic link
sudo mv phpMyAdmin-* /var/www/
sudo rm -f /var/www/phpMyAdmin
sudo ln -s /var/www/phpMyAdmin-*/ /var/www/phpMyAdmin

# move config in
sudo mv config.inc.php /var/www/phpMyAdmin/

# update permissions
sudo chown -R www-data.www-data /var/www/phpMyAdmin-*/
sudo find /var/www/phpMyAdmin-*/ -type d -print0 | xargs -0 chmod 0755
sudo find /var/www/phpMyAdmin-*/ -type f -print0 | xargs -0 chmod 0644

# echo
echo -e "------------------------------------------"
echo -e "phpMyAdmin updated\n"
echo -e "$url \n"
echo -e "------------------------------------------"
echo -e "phpmyadmin.sh finished"
echo -e "------------------------------------------"
