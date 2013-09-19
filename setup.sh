#!/bin/bash


# ------------ config -----------------
# set up email for logwatch
email=""

# public key for putting into .ssh/authorized_keys
pubkey=""

# mysql root password
# get ready to input it, it will pop up

# date
#now=`date +%F_%H%M%S`
# ------------ config -----------------





# fix resolv.conf for some reason
echo -e "nameserver 8.8.8.8\nnameserver 4.2.2.2" > /etc/resolv.conf 

# update and 
sudo apt-get update 
sudo apt-get -y upgrade 

# nano + other apps for add-apt-repository cmd
# http://stackoverflow.com/a/16032073
sudo apt-get -y install nano python-software-properties software-properties-common

# update time
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
sudo apt-get -y install ntp
service ntp restart

# bashrc
mv ~/.bashrc ~/.bashrc.bak
wget https://raw.github.com/amnah/vps-setup-script/master/files/.bashrc
mv .bashrc ~/.bashrc
chmod 644 ~/.bashrc

# prevent root login with password (ssh keys only)
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
echo "$pubkey" > ~/.ssh/authorized_keys
chmod 700 ~/.ssh 
chmod 600 ~/.ssh/authorized_keys 
chown -R root.root .ssh
echo -e "\n\nPermitRootLogin no\nPasswordAuthentication no\n#AllowUsers username@(your-ip) username@(another-ip-if-any)" >> /etc/ssh/sshd_config
sed -i "s/Port 22/Port 5522/g" /etc/ssh/sshd_config

# fail2ban and logwatch
sudo apt-get -y install fail2ban logwatch
sed -i "s/--output mail/--output mail --mailto $email --detail high/g" /etc/cron.daily/00logwatch

# git php nginx mysql
# http://www.howtoforge.com/installing-nginx-with-php5-and-php-fpm-and-mysql-support-lemp-on-ubuntu-12.04-lts
sudo add-apt-repository -y ppa:git-core/ppa 
sudo apt-get update
sudo apt-get -y install git php5 php5-cli mysql-server mysql-client nginx php5-fpm php5-mysql php5-gd php5-imagick php5-mcrypt php5-memcache php-apc php5-curl curl 
#sudo apt-get -y install php5-suhosin php5-intl php-pear php5-imap php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
#nano /etc/php5/cli/conf.d/ming.ini # change "#" to ";"

# fix up some configs
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini

# set up nginx
rm /etc/nginx/sites-enabled/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
wget https://raw.github.com/amnah/vps-setup-script/master/files/nginx.conf  -O /etc/nginx/nginx.conf
wget https://raw.github.com/amnah/vps-setup-script/master/files/sites-available/_baseApps -O /etc/nginx/sites-available/_baseApps
wget https://raw.github.com/amnah/vps-setup-script/master/files/sites-available/_common -O /etc/nginx/sites-available/_common


# set up data dir
mkdir /data && mkdir /data/sites && mkdir /data/logs
ln -s /etc/nginx/nginx.conf /data/nginx.conf
ln -s /etc/nginx/sites-available/ /data
ln -s /etc/nginx/sites-enabled/ /data
ln -s /etc/nginx/sites-available/_baseApps /etc/nginx/sites-enabled/_baseApps
wget https://raw.github.com/amnah/vps-setup-script/master/files/example.site -O /data/example.site

# download and install/move phpMyAdmin
# note: file gets named "download"
wget http://sourceforge.net/projects/phpmyadmin/files/latest/download
unzip -q download 
rm -f download
mv phpMyAdmin* /data
ln -s /data/phpMyAdmin* /data/phpMyAdmin
wget https://raw.github.com/amnah/vps-setup-script/master/files/config.inc.php -O /data/phpMyAdmin/config.inc.php

# setup default + phpMyAdmin logs in nginx
mkdir /data/logs/_
touch /data/logs/_/access.log
touch /data/logs/_/error.log
mkdir /data/logs/phpMyAdmin
touch /data/logs/phpMyAdmin/access.log
touch /data/logs/phpMyAdmin/error.log

# empty out mail file
cat /dev/null > /var/mail/root

# add logrotate to site logs
sed -i "s/*.log/*.log \/data\/logs\/*\/*.log/g" /etc/logrotate.d/nginx

# add fail2ban configurations
# http://snippets.aktagon.com/snippets/554-how-to-secure-an-nginx-server-with-fail2ban
wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/proxy.conf -O /etc/fail2ban/filter.d/proxy.conf
wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-auth.conf -O /etc/fail2ban/filter.d/nginx-auth.conf
wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-login.conf -O /etc/fail2ban/filter.d/nginx-login.conf
wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-noscript.conf -O /etc/fail2ban/filter.d/nginx-noscript.conf
wget https://raw.github.com/amnah/vps-setup-script/master/files/filter.d/nginx-dos.conf -O /etc/fail2ban/filter.d/nginx-dos.conf
wget https://raw.github.com/amnah/vps-setup-script/master/files/jail.local.tmp -O /etc/fail2ban/jail.local.tmp
cat /etc/fail2ban/jail.conf /etc/fail2ban/jail.local.tmp > /etc/fail2ban/jail.local
rm /etc/fail2ban/jail.local.tmp

# update services
service fail2ban restart
service apache2 stop
update-rc.d -f apache2 remove
service ssh restart
service apache2 stop # just in case
service php5-fpm reload
service nginx restart

# change owner and permissions
chown -R www-data.www-data /data/sites
find /data/sites -type d -print0 | xargs -0 chmod 0755
#find /data/sites -type f -print0 | xargs -0 chmod 0644 # NOPE dont need this

# clean up and download site.sh
chmod 400 setup.sh
wget https://raw.github.com/amnah/vps-setup-script/master/site.sh
chmod 700 site.sh

# echo
echo -e "------------------------------------------"
echo -e "Now go! Modify and run:\n"
echo -e "./site.sh"
echo -e "------------------------------------------"
echo -e "setup.sh finished"
echo -e "------------------------------------------"
