#!/bin/bash
# Devops Project -- 2016 kansukse@gmail.com
# Nginx Reverse Proxy süreçlerini kurar, ayarlar, upgrade eder, çaşıtırır. Debian Jessie üstünde çalışır.

sudo apt-get update
sudo apt-get dist-upgrade -fy --force-yes
sudo apt-get install -fy --force-yes nginx

# Nginx Globals
ifglobals=$(cat ~/.bashrc |grep "# Nginx Reverse Proxy Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Nginx Reverse Proxy Globals:
	export NGINXDIR=/BUILDBOT/workdir/bot/nginx/

	" >> ~/.bashrc
	source ~/.bashrc
fi

bash bot/scripts/bashsource.sh
source ~/bashsource

sudo rm -r /var/www/html/*
sudo cp -r $NGINXDIR/www/* /var/www/html/
sudo rm /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*
sudo cp $NGINXDIR/conf/* /etc/nginx/conf.d/
sudo cp $NGINXDIR/default /etc/nginx/sites-enabled/

sudo service nginx restart
