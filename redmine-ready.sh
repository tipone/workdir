#!/bin/bash
# Devops Project -- 2016 kansukse@gmail.com
# Apache2 Reverse Proxy süreçlerini kurar, ayarlar, upgrade eder, çaşıtırır. Debian Jessie üstünde çalışır.

sudo apt-get update
sudo apt-get dist-upgrade -fy --force-yes 

# Apache2 Globals
ifglobals=$(cat ~/.bashrc |grep "# Apache2 Reverse Proxy Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Apache2 Reverse Proxy Globals:
	export A2DIR=/BUILDBOT/workdir/bot/apache2/

	" >> ~/.bashrc
	source ~/.bashrc

	sudo apt-get install -fy --force-yes redmine-mysql apache2 libapache2-mod-passenger mariadb-server mariadb-client
	a2enmod passenger
	a2ensite redmine.conf
fi

bash bot/scripts/bashsource.sh
source ~/bashsource
sudo mkdir -p /usr/local/apache2/sites-enabled/ /usr/local/apache2/sites-available/ /usr/local/apache2/conf.d/
sudo rm -r /var/www/html/*
sudo rm /usr/local/apache2/conf/apache2.conf
sudo cp $NGINXDIR/apache2.conf /usr/local/apache2/conf/
sudo cp -r $NGINXDIR/www/* /var/www/html/
sudo rm /usr/local/apache2/sites-enabled/* 
sudo cp $NGINXDIR/conf/* /usr/local/apache2/conf.d/
sudo cp $NGINXDIR/default /usr/local/apache2/sites-enabled/

#sudo service apache2 restart
sudo pkill apache2
sudo /usr/local/apache2/sbin/apache2
