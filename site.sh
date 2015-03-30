#!/bin/bash


# ------------ config -----------------
# set up site name
site="" # "mydomain.com"

# ------------ end config -----------------



# create folders and files
mkdir /data/sites/$site
mkdir /data/logs/$site
touch /data/logs/$site/access.log
touch /data/logs/$site/error.log
echo "hello world" > /data/sites/$site/index.php

# copy server block
cp /data/example.site /etc/nginx/sites-available/$site
sed -i "s/example.site/${site}/g" /etc/nginx/sites-available/$site
sed -i "s/example\\\.site/${site/./\\\\\.}/g" /etc/nginx/sites-available/$site # wooo that's a lot of backslashes
ln -s /etc/nginx/sites-available/$site /etc/nginx/sites-enabled/

# change owner and permissions
chown -R www-data.www-data /data/sites/$site
find /data/sites/$site -type d -print0 | xargs -0 chmod 0755
find /data/sites/$site -type f -print0 | xargs -0 chmod 0644

# reload nginx 
service nginx reload



# echo
echo -e "------------------------------------------"
echo -e "You are now LIVE!\n"
echo -e "   $site"
echo -e "------------------------------------------"
echo -e "site.sh finished"
echo -e "------------------------------------------"
