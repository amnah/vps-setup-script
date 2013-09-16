#!/bin/sh


# ------------ config -----------------
# set up email for logwatch
email=""

# public key for putting into .ssh/authorized_keys
pubkey=""

# date
#now=`date +%F_%H%M%S`
# ------------ config -----------------





# fix resolv.conf for some reason
sudo echo -e "nameserver 8.8.8.8\nnameserver 4.2.2.2" > /etc/resolv.conf 

# update
# python-software-properties needed for add-apt-repository
sudo apt-get update 
sudo apt-get -y upgrade 
sudo apt-get -y install python-software-properties nano

# update time
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
sudo apt-get -y install ntp
service ntp restart

# prevent root login with password (ssh keys only)
mkdir ~/.ssh && 
touch ~/.ssh/authorized_keys
echo "$pubkey" > ~/.ssh/authorized_keys
chmod 700 ~/.ssh 
chmod 600 ~/.ssh/authorized_keys 
chown -R root.root .ssh
echo -e "\n\nPermitRootLogin no\nPasswordAuthentication no\n#AllowUsers username@(your-ip) username@(another-ip-if-any)" >> /etc/ssh/sshd_config 
sed -i 's/Port 22/Port 5522/g' /etc/ssh/sshd_config
service ssh restart

# fail2ban and logwatch
sudo apt-get -y install fail2ban logwatch
sed -i "s/--output mail/--output mail --mailto $email --detail high/g" /etc/cron.daily/00logwatch

# stop apache2
service apache2 stop
update-rc.d -f apache2 remove

# git php nginx mysql
# http://www.howtoforge.com/installing-nginx-with-php5-and-php-fpm-and-mysql-support-lemp-on-ubuntu-12.04-lts
sudo add-apt-repository ppa:git-core/ppa 
sudo add-apt-repository ppa:ondrej/php5 
sudo apt-get update
sudo apt-get -y install git mysql-server mysql-client nginx php5-fpm php5-mysql php5-gd php5-imagick php5-mcrypt php5-memcache php-apc php5-curl curl 
#sudo apt-get -y install php5-suhosin php5-intl php-pear php5-imap php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
#nano /etc/php5/cli/conf.d/ming.ini # change "#" to ";"

# fix mail
rm /var/mail/root 
touch /var/mail/root 
chmod 600 /var/mail/root 
chown root.mail /var/mail/root