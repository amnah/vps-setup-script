#!/bin/bash


# ------------ config -----------------
# set up site name
# "mydomain.com"
site=""

# ------------ end config -----------------



# create folders and files
mkdir /var/www/$site
echo "hello world" > /var/www/$site/index.php
sudo mkdir /var/log/nginx/$site
sudo touch /var/log/nginx/$site/access.log
sudo touch /var/log/nginx/$site/error.log

# copy server block
sudo cp example.site /etc/nginx/sites-available/$site
sudo sed -i "s/example.site/${site}/g" /etc/nginx/sites-available/$site
sudo sed -i "s/example\\\.site/${site/./\\\\\.}/g" /etc/nginx/sites-available/$site # wooo that's a lot of backslashes
sudo ln -s /etc/nginx/sites-available/$site /etc/nginx/sites-enabled/

# reload nginx
sudo service nginx reload



# echo
echo -e "------------------------------------------"
echo -e "You are now LIVE!\n"
echo -e "   $site"
echo -e "------------------------------------------"
echo -e "site.sh finished"
echo -e "------------------------------------------"
