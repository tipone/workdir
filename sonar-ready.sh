#!/bin/bash
# Devops Project -- 2016 kansukse@gmail.com
# Sonarqube kurar, ayarlar, upgrade eder, çaşıtırır. Debian Jessie üstünde çalışır.

echo "deb http://http.debian.net/debian jessie-backports main" |sudo tee /etc/apt/sources.list.d/backports.list
sudo apt-get update
sudo apt-get dist-upgrade -fy --force-yes
sudo apt install -fy --force-yes -t jessie-backports openjdk-8-jre-headless ca-certificates-java openjdk-8-jre openjdk-8-jdk 
sudo apt-get install -fy --force-yes unzip

# Sonarqube Globals
ifglobals=$(cat ~/.bashrc |grep "# Sonarqube Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Sonarqube Globals:
	export SONARDIR=/BUILDBOT/sonarqube/
	export SONARBIN=$SONARDIR/bin/linux-x86-64/sonar.sh
	export SONARRUNNER=/BUILDBOT/sonar-runner/

	" >> ~/.bashrc
	source ~/.bashrc
fi

bash bot/scripts/bashsource.sh
source ~/bashsource

if [ ! -d "$SONARDIR" ]; then
  echo "Sonarqube not installed. Please download, extract and rename as sonarcube it."
  sudo apt-get install postgresql
fi

$SONARBIN stop

sudo cp $BASE/sonar-cron /etc/cron.d/
sed -i "s,.*sonar.web.context=.*,sonar.web.context=/sonarqube,g" $SONARDIR/conf/sonar.properties

$SONARBIN start



