#!/bin/bash


# ------------ config -----------------
# set up site name
site=""

# ------------ config -----------------





# create folders and files
mkdir /data/sites/$site
mkdir /data/logs/$site
touch /data/logs/$site/access.log
touch /data/logs/$site/error.log
echo "hello" > /data/sites/$site/index.php

# copy server block
cp /etc/nginx/sites-available/example.site /etc/nginx/sites-available/$site
sed -i s/example.site/$site/g /etc/nginx/sites-available/$site
ln -s /etc/nginx/sites-available/$site /etc/nginx/sites-enabled/

# change owner and permissions
chown -R www-data.www-data /data/sites/$site
chmod 0644 /data/sites/$site
find /data/sites/$site -type d -print0 | xargs -0 chmod 0755

# reload nginx 
service nginx reload



# echo
echo -e "------------------------------------------"
echo -e "You are now LIVE!\n"
echo -e "$site"
echo -e "------------------------------------------"
echo -e "setup-site.sh finished"
echo -e "------------------------------------------"
