#!/bin/bash
# Workdir Buildbot Devops Example -- 2017 -- kansukse@gmail.com
# storbox paketini derler
bash bashsource.sh
source ~/bashsource
echo $GITDIR/

DATE=$(date +%y%m%d-%H%M)
sudo apt-get install -fy --force-yes python-virtualenv dh-virtualenv

# geçiçi satırlar.. changelog scripti bittiğinde çıkartılacaktır.
#sudo service nginx stop
#rm -rf /BUILDBOT/deb /BUILDBOT/tmp/stor/*
cp $BASE/bot/doc/debrepo/changelogs/storbox-server-change $GITDIR/storbox/debian/changelog
git pull
./gitchangelog.sh $GITDIR/storbox/
cd $GITDIR/storbox/
dpkg-buildpackage -b -rfakeroot -us -uc
rm $STORREPODIR/*
mv ../storbox*.deb $STORREPODIR/
cp $GITDIR/storbox/debian/changelog $BASE/bot/doc/debrepo/changelogs/storbox-server-change
cd $BASE
git add bot/doc/debrepo/changelogs/storbox-server-change
git commit -m "Support #23 Build storbox auto commit."
git push
