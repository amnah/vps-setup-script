#!/bin/bash


# ------------ config -----------------
# set up email for logwatch
email=""

# user
username=""
password=""

# public key for putting into .ssh/authorized_keys
pubkey="" # "ssh-rsa AAAAB3NzaC1................"

# mariadb root password
mariadbPassword="z" # change this to something more secure

# ssh port
sshPort="22"



# setup
doSetup=true
doWebServer=true
doVnc=false

downloadPath="https://raw.github.com/amnah/vps-setup-script/master/"

# ------------ end config -----------------



if $doSetup ; then
    # fix resolv.conf if you need to
    #echo -e "nameserver 8.8.8.8\nnameserver 4.2.2.2" > /etc/resolv.conf

    # update and upgrade
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

    # nano + other apps for add-apt-repository cmd
    # http://stackoverflow.com/a/16032073
    apt-get -y install nano python-software-properties software-properties-common

    # update time
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
    apt-get -y install ntp
    service ntp restart

    # set up .bashrc for root (for sudo -i)
    mv ~/.bashrc ~/.bashrc.bak
    wget ${downloadPath}files/.bashrc -O ~/.bashrc
    chmod 644 ~/.bashrc

    # prevent root login
    sed -i "s/Port 22/Port $sshPort/g" /etc/ssh/sshd_config
    sed -i "s/PermitRootLogin yes/#PermitRootLogin yes/g" /etc/ssh/sshd_config
    echo -e "\n\nPermitRootLogin no\nPasswordAuthentication no\n#AllowUsers username@(your-ip) username@(another-ip-if-any)" >> /etc/ssh/sshd_config

    # create user and set up .bashrc + ssh
    adduser --disabled-password --gecos "" $username
    echo $username:$password | /usr/sbin/chpasswd
    adduser $username sudo
    mv /home/$username/.bashrc /home/$username/.bashrc.bak
    cp ~/.bashrc /home/$username/.bashrc
    mkdir /home/$username/.ssh
    echo "$pubkey" > /home/$username/.ssh/authorized_keys
    chmod 700 /home/$username/.ssh
    chmod 600 /home/$username/.ssh/authorized_keys
    chown -R $username.$username /home/$username
    service ssh restart

    # fail2ban and logwatch
    apt-get -y install fail2ban logwatch
    sed -i "s/--output mail/--output mail --mailto $email --detail high/g" /etc/cron.daily/00logwatch
    service fail2ban restart

    # empty out mail file
    cat /dev/null > /var/mail/root
fi

if $doWebServer ; then
    # git php nginx mysql
    # http://www.howtoforge.com/installing-nginx-with-php5-and-php-fpm-and-mysql-support-lemp-on-ubuntu-12.04-lts
    export LANG=C.UTF-8
    add-apt-repository -y ppa:git-core/ppa
    add-apt-repository -y ppa:ondrej/php5-5.6
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main'
    apt-get update
    apt-get -y purge apache2* libapache2*
    apt-get -y install git redis-server curl nginx php5 php5-cli php5-fpm php5-mysql php5-gd php5-imagick php5-mcrypt php5-redis php-apc php5-curl
    DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server mariadb-client
    mysqladmin -u root password $mariadbPassword

    # fix up some configs
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini

    # set up nginx
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
    rm /etc/nginx/sites-enabled/default
    wget ${downloadPath}files/nginx.conf -O /etc/nginx/nginx.conf
    wget ${downloadPath}files/sites-available/_baseApps -O /etc/nginx/sites-available/_baseApps

    # set up data dir
    mkdir -p /data/sites /data/logs
    ln -s /etc/nginx/nginx.conf /data/nginx.conf
    ln -s /etc/nginx/sites-available/ /data
    ln -s /etc/nginx/sites-enabled/ /data
    ln -s /etc/nginx/sites-available/_baseApps /etc/nginx/sites-enabled/_baseApps
    wget ${downloadPath}files/example.site -O /data/example.site

    # download and install/move phpMyAdmin
    # note: file gets named "download"
    wget http://sourceforge.net/projects/phpmyadmin/files/latest/download
    unzip -q download
    rm -f download
    mv phpMyAdmin* /data
    ln -s /data/phpMyAdmin* /data/phpMyAdmin
    wget ${downloadPath}files/config.inc.php -O /data/phpMyAdmin/config.inc.php

    # setup default + phpMyAdmin logs in nginx
    mkdir /data/logs/_
    mkdir /data/logs/phpMyAdmin
    touch /data/logs/_/access.log
    touch /data/logs/_/error.log
    touch /data/logs/phpMyAdmin/access.log
    touch /data/logs/phpMyAdmin/error.log

    # add logrotate to site logs and change rotation settings
    sed -i "s/*.log/*.log \/data\/logs\/*\/*.log/g" /etc/logrotate.d/nginx
    sed -i "s/daily/size=50M/g" /etc/logrotate.d/nginx
    sed -i "s/daily/size=50M/g" /etc/logrotate.d/mysql-server
    sed -i "s/rotate 7/rotate 52/g" /etc/logrotate.d/mysql-server

    # add nginx configurations for fail2ban
    # http://snippets.aktagon.com/snippets/554-how-to-secure-an-nginx-server-with-fail2ban
    wget ${downloadPath}files/filter.d/proxy.conf -O /etc/fail2ban/filter.d/proxy.conf
    wget ${downloadPath}files/filter.d/nginx-auth.conf -O /etc/fail2ban/filter.d/nginx-auth.conf
    wget ${downloadPath}files/filter.d/nginx-login.conf -O /etc/fail2ban/filter.d/nginx-login.conf
    wget ${downloadPath}files/filter.d/nginx-noscript.conf -O /etc/fail2ban/filter.d/nginx-noscript.conf
    wget ${downloadPath}files/filter.d/nginx-dos.conf -O /etc/fail2ban/filter.d/nginx-dos.conf
    wget ${downloadPath}files/jail.local.tmp -O /etc/fail2ban/jail.local.tmp

    # combine the tmp jail.local.tmp into the preconfigured jail.conf
    cat /etc/fail2ban/jail.conf /etc/fail2ban/jail.local.tmp > /etc/fail2ban/jail.local
    rm /etc/fail2ban/jail.local.tmp

    # restart nginx services
    service php5-fpm restart
    service nginx restart

    # change owner and permissions
    chown -R www-data.www-data /data/sites
    find /data/sites -type d -print0 | xargs -0 chmod 0755
    #find /data/sites -type f -print0 | xargs -0 chmod 0644 # not needed because there are no files in there

    # clean up and download site.sh and backup.sh
    wget ${downloadPath}site.sh
    wget ${downloadPath}backup.sh
    chmod 700 site.sh backup.sh

    # display message about site.sh
    echo -e "------------------------------------------"
    echo -e "Now go! Modify and run:\n"
    echo -e "   ./site.sh"

fi

if $doVnc ; then
    # install tightvnc and xfce
    apt-get -y install tightvncserver xfce4 xfce4-goodies

    # update scripts
    mkdir ~/.vnc
    wget ${downloadPath}files/xstartup  -O ~/.vnc/xstartup
    sed -i "s/#alias vnc/alias vnc/g" ~/.bashrc

    # display message about vnc
    echo -e "------------------------------------------"
    echo -e "Set up a vnc password:\n"
    echo -e "   echo 'password' | vncpasswd -f > ~/.vnc/passwd"
fi

# chmod script so it can't run again
chmod 400 setup.sh

# display finished message
echo -e "------------------------------------------"
echo -e "setup.sh finished"
echo -e "------------------------------------------"