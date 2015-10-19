#!/bin/bash


# ------------ config -----------------
# setup
doSetup=true
doWebServer=true
doVnc=false

# set email for logwatch (will not install logwatch if empty)
#email=""

# set fail2ban
installFail2Ban=true

# user
username="ubuntu"
password="z"

# public key for putting into .ssh/authorized_keys
# "ssh-rsa AAAAB3NzaC1................"
pubkey=""

# mariadb root password
mariadbPassword="z"

# ssh port
sshPort="22"

# download path (via wget)
# ensure / at end
downloadPath="https://raw.githubusercontent.com/amnah/vps-setup-script/master/"

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

    # logwatch
    if [ -n "$email" ]; then
        apt-get -y install logwatch
        sed -i "s/--output mail/--output mail --mailto $email --detail high/g" /etc/cron.daily/00logwatch
    fi

    # empty out mail file
    cat /dev/null > /var/mail/root
fi

if $doWebServer ; then
    # git php nginx mysql
    # http://www.howtoforge.com/installing-nginx-with-php5-and-php-fpm-and-mysql-support-lemp-on-ubuntu-12.04-lts
    export LANG=C.UTF-8
    apt-get -y purge apache2* libapache2*
    add-apt-repository -y ppa:nginx/stable
    add-apt-repository -y ppa:git-core/ppa
    add-apt-repository -y ppa:ondrej/php5-5.6
    add-apt-repository -y ppa:chris-lea/redis-server
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main'
    apt-get update
    apt-get -y install unzip git redis-server memcached curl nginx php5 php5-cli php5-fpm php5-mysql php5-gd php5-imagick php5-mcrypt php5-redis php5-memcached php5-curl php-apc
    DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server mariadb-client
    mysqladmin -u root password $mariadbPassword

    # fix up some configs
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
    sed -i "s/;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/g" /etc/php5/fpm/php.ini

    # set up nginx
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
    rm /etc/nginx/sites-enabled/default
    wget ${downloadPath}files/nginx.conf -O /etc/nginx/nginx.conf
    wget ${downloadPath}files/sites-available/_baseApps -O /etc/nginx/sites-available/_baseApps

    # set up data dir
    mkdir -p /data
    mkdir -p /var/www
    ln -s /var/www /data/
    ln -s /etc/nginx/nginx.conf /data/
    ln -s /etc/nginx/sites-available /data/
    ln -s /etc/nginx/sites-enabled /data/
    ln -s /etc/nginx/sites-available/_baseApps /etc/nginx/sites-enabled/
    ln -s /var/log/nginx /data/log
    mkdir /etc/nginx/ssl
    ln -s /etc/nginx/ssl /data/

    # set up nginx logs
    mkdir /var/log/nginx/_
    mkdir /var/log/nginx/phpMyAdmin
    touch /var/log/nginx/_/access.log
    touch /var/log/nginx/_/error.log
    touch /var/log/nginx/phpMyAdmin/access.log
    touch /var/log/nginx/phpMyAdmin/error.log

    # add logrotate to site logs and change rotation settings
    sed -i "s/*.log/*.log \/var\/log\/nginx\/*\/*.log/g" /etc/logrotate.d/nginx
    sed -i "s/daily/size=50M/g" /etc/logrotate.d/nginx
    sed -i "s/daily/size=50M/g" /etc/logrotate.d/mysql-server
    sed -i "s/rotate 7/rotate 52/g" /etc/logrotate.d/mysql-server

    # add nginx configurations for fail2ban
    # http://snippets.aktagon.com/snippets/554-how-to-secure-an-nginx-server-with-fail2ban
    if $installFail2Ban ; then
        apt-get -y install fail2ban
        wget ${downloadPath}files/filter.d/proxy.conf -O /etc/fail2ban/filter.d/proxy.conf
        wget ${downloadPath}files/filter.d/nginx-auth.conf -O /etc/fail2ban/filter.d/nginx-auth.conf
        wget ${downloadPath}files/filter.d/nginx-login.conf -O /etc/fail2ban/filter.d/nginx-login.conf
        wget ${downloadPath}files/filter.d/nginx-noscript.conf -O /etc/fail2ban/filter.d/nginx-noscript.conf
        #wget ${downloadPath}files/filter.d/nginx-dos.conf -O /etc/fail2ban/filter.d/nginx-dos.conf
        wget ${downloadPath}files/jail.local.tmp -O /etc/fail2ban/jail.local.tmp

        # combine the tmp jail.local.tmp into the preconfigured jail.conf
        cat /etc/fail2ban/jail.conf /etc/fail2ban/jail.local.tmp > /etc/fail2ban/jail.local
        rm /etc/fail2ban/jail.local.tmp
        service fail2ban restart
    fi

    # restart nginx services
    service php5-fpm restart
    service nginx restart

    # change owner and permissions
    chown -R www-data.www-data /var/www
    adduser $username www-data    # add user to www-data group
    adduser $username adm         # add user to adm group (for accessing /var/log)
    find /var/www -type d -print0 | xargs -0 chmod 0775
    #find /var/www -type f -print0 | xargs -0 chmod 0664 # not needed because there are no files in there

    # download backup and site scripts
    wget ${downloadPath}backup.sh
    chmod 700 backup.sh
    wget ${downloadPath}site.sh -O /home/$username/site.sh
    wget ${downloadPath}phpmyadmin.sh -O /home/$username/phpmyadmin.sh
    wget ${downloadPath}startNode.sh -O /home/$username/startNode.sh
    wget ${downloadPath}files/example.site -O /home/$username/example.site
    wget ${downloadPath}files/config.inc.php -O /home/$username/config.inc.php
    chown $username.$username /home/$username/site.sh /home/$username/phpmyadmin.sh
    chmod 700 /home/$username/site.sh /home/$username/phpmyadmin.sh

    # display message about site.sh
    echo -e "------------------------------------------"
    echo -e "Now log into your '$username' account and modify/run : \n"
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

# chmod this script so it can't run again
chmod 400 setup.sh

# display finished message
echo -e "------------------------------------------"
echo -e "setup.sh finished"
echo -e "------------------------------------------"