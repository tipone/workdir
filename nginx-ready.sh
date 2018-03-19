#!/bin/bash
# Devops Project -- 2016 kansukse@gmail.com
# Nginx Reverse Proxy süreçlerini kurar, ayarlar, upgrade eder, çaşıtırır. Debian Jessie üstünde çalışır.

sudo apt-get update
sudo apt-get dist-upgrade -fy --force-yes

# Nginx Globals
ifglobals=$(cat ~/.bashrc |grep "# Nginx Reverse Proxy Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Nginx Reverse Proxy Globals:
	export NGINXDIR=/BUILDBOT/workdir/bot/nginx/

	" >> ~/.bashrc
	source ~/.bashrc
	cd $BUILDBOTDIR/tmp
	rm -rf $BUILDBOTDIR/tmp/nginx*
	rm -rf /usr/local/nginx
	sudo apt-get install -fy --force-yes debhelper dh-systemd dh-exec libldap2-dev apache2-utils liblua5.1-dev daemon dbconfig-common libgd-dev libgeoip-dev libhiredis-dev libluajit-5.1-dev libmhash-dev libpam0g-dev libpcre3-dev libperl-dev libssl-dev libxslt1-dev quilt zlib1g-dev
	wget http://nginx.org/download/nginx-1.13.3.tar.gz
	tar xvfz nginx-1.13.3.tar.gz
	git clone https://github.com/kvspb/nginx-auth-ldap.git
	cd nginx-1.13.3
	./configure --add-module=../nginx-auth-ldap/
	make;sudo make install
	sudo mkdir -p /usr/local/nginx/sites-enabled/ /usr/local/nginx/sites-available/ /usr/local/nginx/conf.d/
	cd $BASE
fi

bash bot/scripts/bashsource.sh
source ~/bashsource
sudo mkdir -p /usr/local/nginx/sites-enabled/ /usr/local/nginx/sites-available/ /usr/local/nginx/conf.d/
sudo rm -r /var/www/html/*
sudo rm /usr/local/nginx/conf/nginx.conf
sudo cp $NGINXDIR/nginx.conf /usr/local/nginx/conf/
sudo cp -r $NGINXDIR/www/* /var/www/html/
sudo rm /usr/local/nginx/sites-enabled/* 
sudo cp $NGINXDIR/conf/* /usr/local/nginx/conf.d/
sudo cp $NGINXDIR/default /usr/local/nginx/sites-enabled/

#sudo service nginx restart
sudo pkill nginx
sudo /usr/local/nginx/sbin/nginx
