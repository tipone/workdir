#!/bin/bash
# Devops Project -- 2016 kansukse@gmail.com
# BuildBot Master süreçlerini ayarlar çalışır hale getirir. Debian Jessie üstünde çalışır.
# Fix for python3 2020

buildbotdir=/BUILDBOT
mastername=master
builddir=$buildbotdir/sandbox
gitdir=$buildbotdir/git
tmpdir=$buildbotdir/tmp
base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
pypath="\"\${PYTHONPATH}:$base/bot\""
sudo apt-get update
sudo apt-get dist-upgrade -fy
sudo apt-get install -fy python3-dev python3-pip git sudo libffi-dev libssl-dev postgresql-client


# Projecet PYTHONPATH
ifpypath=$(cat ~/.bashrc |grep $pypath|wc -l)
if [ "$ifpypath" == "0"  ];then
	echo "PYTHONPATH Eklenmemiş. Ekleniyor."
	echo -e "# Buildbot PYTHONPATH
	export PYTHONPATH=$pypath
        " >> ~/.bashrc
        source ~/.bashrc
fi

# System Globals
ifglobals=$(cat ~/.bashrc |grep "# Buildbot Master Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	echo -e "# Buildbot Master Globals:
	export BUILDBOTDIR=$buildbotdir
	export GITDIR=$gitdir
	export MASTERNAME=$mastername
	export BUILDDIR=$builddir
	export BASE=$base
	export PGPASSWORD=postgresql_password
	" >> ~/.bashrc
	source ~/.bashrc
fi
mkdir -p $gitdir $tmpdir
ln -sf $base/checker.sh $tmpdir/checker.sh
sudo  cp -f $base/checker-cron /etc/cron.d/checker-cron
sudo  cp -f $base/master-cron /etc/cron.d/master-cron


# tüm repoları burda çek.

if [ ! -d $builddir ];then
	sudo pip3 install virtualenv
	virtualenv $builddir
else
	echo "[info]virtualenv already installed and configured.."
fi

source $builddir/bin/activate

if [ -f $builddir/$mastername/state.sqlite  ];then
	buildbot upgrade-master $builddir/$mastername
fi

if [ ! -f $builddir/$mastername/buildbot.tac ];then
	pip3 install buildbot buildbot-www buildbot-worker buildbot-waterfall-view buildbot-console-view buildbot-grid_view pyopenssl service_identity
	buildbot create-master $builddir/$mastername
	ln -s $base/bot/lib $builddir/$mastername/lib
	ln -s $base/bot/master.cfg $builddir/$mastername/master.cfg
	sudo service cron restart
else
	echo "[info]sqlalchey and buildbot-master already installed and configured.."
fi
if [ ! -f $builddir/$mastername/twistd.pid ];then
	buildbot start $builddir/$mastername
	echo "[warning]builbot-master is not running.. Try starting.."
else
	buildbot reconfig $builddir/$mastername
	echo "[info]buildbot-master reconfig.. "
fi

bash bot/scripts/bashsource.sh
source ~/bashsource

