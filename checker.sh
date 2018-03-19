#!/bin/bash
# Workdir Software -- 2016 kansukse@gmail.com
#source ~/.bashrc

. /BUILDBOT/sandbox/bin/activate
cd /BUILDBOT/tmp/
touch wstatus mstatus rstatus sstatus mastatus
while true
do
masterstat=$(cat mstatus)
workerstat=$(cat wstatus)
reposstat=$(cat rstatus)
sonarstat=$(cat sstatus)
mavenstat=$(cat mastatus)

if [ "restart-master" == "$masterstat" ];then
	echo "ok-master-$(date)">mstatus
	buildbot restart /BUILDBOT/sandbox/master &
fi

if [ "restart-worker" == "$workerstat" ];then
        echo "ok-worker-$(date)">wstatus
        buildbot-worker restart /BUILDBOT/sandbox/$(hostname -s)-worker &
fi

if [ "restart-repos" == "$reposstat" ];then
        echo "ok-repos-$(date)">rstatus
        python /BUILDBOT/workdir/repos/webserver.py &
fi

if [ "restart-sonar" == "$sonarstat" ];then
        echo "ok-sonar-$(date)">sstatus
	/BUILDBOT/sonarqube/bin/linux-x86-64/sonar.sh restart &
fi

if [ "restart-maven" == "$mavenstat" ];then
	echo "ok-maven-$(date)">mastatus
	kill $(ps aux|grep site:run|awk '{print $2}'|head -1)
	cd /BUILDBOT/maven/my-app/;mvn site:run >>~/log &
	sleep 30
	cd /BUILDBOT/tmp/
fi

sleep 10

done
