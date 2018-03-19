#!/bin/bash
# Devops Project -- 2016 kansukse@gmail.com
# Maven kurar, ayarlar, upgrade eder, çaşıtırır. Debian Jessie üstünde çalışır.

echo "deb http://http.debian.net/debian jessie-backports main"|sudo tee /etc/apt/sources.list.d/backports.list
sudo apt-get update
sudo apt-get dist-upgrade -fy --force-yes
sudo apt install -fy --force-yes -t jessie-backports openjdk-8-jre-headless ca-certificates-java openjdk-8-jre openjdk-8-jdk 
sudo apt-get install -fy --force-yes unzip maven
ln -s /BUILDBOT/workdir/repos/settings.xml ~/.m2/settings.xml

# Sonarqube Globals
ifglobals=$(cat ~/.bashrc |grep "# Maven Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Maven Globals:
	export MAVENDIR=/BUILDBOT/maven/

	" >> ~/.bashrc
	source ~/.bashrc
fi

bash bot/scripts/bashsource.sh
source ~/bashsource

if [ ! -d "$MAVENDIR" ]; then
  echo "Maven not installed. Installing..."
  kill $(ps aux|grep site:run|awk '{print $2}'|head -1)
  sudo echo -e "main is org.apache.maven.cli.MavenCli from plexus.core
set maven.home default /BUILDBOT/maven
[plexus.core]
optionally /BUILDBOT/maven/lib/ext/*.jar
load       /BUILDBOT/maven/lib/*.jar
  " /etc/maven/m2.conf 
	mkdir -p $MAVENDIR/lib
	cd $MAVENDIR
	cp /usr/share/maven/lib/* $MAVENDIR/lib
    mvn -B archetype:generate \
		-DarchetypeGroupId=org.apache.maven.archetypes \
		-DgroupId=com.mycompany.app \
		-DartifactId=my-app
	cd my-app
	mvn compile
	mvn test
	mvn package
	mvn install
	mvn site
fi

#kill $(ps aux|grep site:run|awk '{print $2}'|head -1)
#sudo cp $BASE/maven-cron /etc/cron.d/
#cd $MAVENDIR/my-app; mvn site:run &
cd $BASE
