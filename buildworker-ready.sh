#!/bin/bash
# Workdir Buildbot Devops Example -- 2016 -- kansukse@gmail.com
# Build ve derlemeler için gerekli otomasyon slave`ini kurar
#preinstall
# Slave connect to which master server
masteraddr=master:9989

# please edit these two variable, slavename and slavepass
workername=`hostname -s`-worker
workerpass=pass
buildbotdir=/BUILDBOT
builddir=$buildbotdir/sandbox
gitdir=$buildbotdir/git
tmpdir=$buildbotdir/tmp
reposdir=$buildbotdir/repos
base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
workerdir=$builddir/$workername
CFILES="bot/slavewebbot-cron"

# System Globals
ifglobals=$(cat ~/.bashrc |grep "# Buildbot Worker Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Buildbot Worker Globals:
	export BUILDBOTDIR=$buildbotdir
	export GITDIR=$gitdir
	export MASTERADDR=$masteraddr
	export BUILDDIR=$builddir
	export BASE=$base
	export WORKERDIR=$workerdir
	export REPOSDIR=$reposdir
	export PGPASSWORD=postgresql_password
	" >> ~/.bashrc
	source ~/.bashrc
fi


#########################################################

if [[ $workername == worker ]]&&[[ $workerpass == pass ]];then
	echo "please edit these two variable, slavename and slavepass"
	exit 1
fi

sudo apt-get update
sudo apt-get dist-upgrade -fy
sudo apt-get install -fy python-dev python-pip git sudo postgresql-client

mkdir -p $gitdir $tmpdir $reposdir
ln -sf $base/checker.sh $tmpdir/checker.sh
sudo  cp -f $base/checker-cron /etc/cron.d/checker-cron
sudo  cp -f $base/debindexer-cron /etc/cron.d/debindexer-cron
sudo  cp -f $base/worker-cron /etc/cron.d/worker-cron
sudo  cp -f $base/repos-cron /etc/cron.d/repos-cron


# tüm repoları burda çek.

if [ ! -d $builddir ];then
	sudo pip install virtualenv
	virtualenv --no-site-packages $builddir
else
	echo "[info]virtualenv already installed and configured.."
fi

source $builddir/bin/activate

if [ ! -f $builddir/$workername/buildbot.tac ];then
	pip install buildbot-worker
	buildbot-worker create-worker $workerdir $masteraddr $workername $workerpass
# buraya worker cron starter yazılacak
#	sudo ln -s $base/bot/masterwebbot-cron /etc/cron.d/masterwebbot-cron
#	sudo service cron restart
else
	echo "[info]sqlalchey and buildbot-worker already installed and configured.."
fi
if [ ! -f $builddir/$workername/twistd.pid ];then
	buildbot-worker start $builddir/$workername
	echo "[warning]builbot-worker is not running.. Try starting.."
#else
#	buildbot-worker stop $builddir/$workername
#	if [ -f $builddir/$workername/twistd.pid  ];then
#		pid=$(cat $builddir/$worker/twistd.pid)
#		kill $pid
#	fi
#	buildbot-worker stop $builddir/$workername
#	echo "[info]buildbot-worker restarting.. "
fi

bash bot/scripts/bashsource.sh
source ~/bashsource
