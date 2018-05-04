#!/bin/bash
# Devops Project -- 2016 kansukse@gmail.com
# Apache2 Reverse Proxy süreçlerini kurar, ayarlar, upgrade eder, çaşıtırır. Debian Jessie üstünde çalışır.

sudo apt-get update
sudo apt-get dist-upgrade -fy --force-yes 

# Apache2 Globals
ifglobals=$(cat ~/.bashrc |grep "# Apache2 Reverse Proxy Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
#	./nginx-ready.sh
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Apache2 Reverse Proxy Globals:
	export A2DIR=/BUILDBOT/workdir/bot/apache2/

	" >> ~/.bashrc
	source ~/.bashrc

	sudo apt-get install -fy --force-yes redmine redmine-mysql apache2 libapache2-mod-passenger mariadb-server mariadb-client
	sudo cp /usr/share/doc/redmine/examples/apache2-passenger-host.conf /etc/apache2/sites-available/redmine.conf
	sudo rm /etc/apache2/sites-enabled/000-default.conf
	sudo a2enmod passenger
	sudo a2ensite redmine.conf
fi

bash bot/scripts/bashsource.sh
source ~/bashsource
sudo service apache2 restart
