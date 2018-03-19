#!/bin/bash
# Workdir Buildbot Devops Example -- 2016 -- kansukse@gmail.com
# Build ve derlemeler için gerekli otomasyon Debian deb package repo servisini kurar
# ÖNEMLİ!! ilk kez çalıştırıyorsan şu komutu bir kez çalıştırmayı unutma:
# gpg --no-default-keyring --keyring /usr/share/keyrings/debian-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import
# wget -O - https://www.mongodb.org/static/pgp/server-3.4.asc | gpg --no-default-keyring --keyring trustedkeys.gpg --import
# wget -O - http://apt.numeezy.fr/numeezy.asc | gpg --no-default-keyring --keyring trustedkeys.gpg --import
# wget -O - https://raw.github.com/ceph/ceph/master/keys/release.asc | gpg --no-default-keyring --keyring trustedkeys.gpg --import

# Debian gerekli repolar
echo -e "# Main Testing Repos:
deb [arch=amd64,i386] http://ftp.de.debian.org/debian/ testing main contrib non-free
deb-src http://ftp.de.debian.org/debian/ testing main contrib non-free

deb [arch=amd64,i386] http://security.debian.org/ testing/updates main contrib non-free
deb-src http://security.debian.org/ testing/updates main contrib non-free

# Stable Repos
deb [arch=amd64,i386] http://ftp.de.debian.org/debian/ stable main contrib non-free
deb-src http://ftp.de.debian.org/debian/ stable main contrib non-free

# Unstable Repos
deb [arch=amd64,i386] http://ftp.de.debian.org/debian/ unstable main contrib non-free
deb-src http://ftp.de.debian.org/debian/ unstable main contrib non-free

# Experimental Repos
deb [arch=amd64,i386] http://ftp.de.debian.org/debian/ experimental main contrib non-free
deb-src http://ftp.de.debian.org/debian/ experimental main contrib non-free

# Jessie Repos
deb [arch=amd64,i386] http://ftp.de.debian.org/debian/ jessie main contrib non-free
deb-src http://ftp.de.debian.org/debian/ jessie main contrib non-free

# Wheezy Repos
deb [arch=amd64,i386] http://ftp.de.debian.org/debian/ wheezy main contrib non-free
deb-src http://ftp.de.debian.org/debian/ wheezy main contrib non-free
"| 
sudo tee /etc/apt/sources.list > /dev/null

wget -q -O - https://www.mongodb.org/static/pgp/server-3.4.asc | sudo apt-key add -

# Testing harici tüm repoları pinliyoruz.
echo -e "Package: *
Pin: release a=stable
Pin-Priority: 50" | sudo tee /etc/apt/preferences.d/stable > /dev/null

echo -e "Package: *
Pin: release a=unstable
Pin-Priority: 50" | sudo tee /etc/apt/preferences.d/unstable > /dev/null

echo -e "Package: *
Pin: release a=experimental
Pin-Priority: 50" | sudo tee /etc/apt/preferences.d/experimental > /dev/null

echo -e "Package: *
Pin: release a=jessie
Pin-Priority: 50" | sudo tee /etc/apt/preferences.d/jessie > /dev/null

echo -e "Package: *
Pin: release a=wheezy
Pin-Priority: 50" | sudo tee /etc/apt/preferences.d/wheezy > /dev/null

sudo apt-get update

# System Globals
ifglobals=$(cat ~/.bashrc |grep "# Buildbot Debrepo Globals:"|wc -l)
if [ "$ifglobals" == "0"  ];then
	echo "Globaller export edilmemiş. Şimdi export ediliyor."
	debrepodir=$BUILDBOTDIR/deb
	echo -e "# Buildbot Debrepo Globals:
	export DEBREPODIR=$debrepodir
	export DEBLISTDIR=$BUILDBOTDIR/tmp/deblists
	export STRETCH=$debrepodir/public/dists/stretch
	export STRETCHDIST=$debrepodir/public/dists/stretch/main
	export STRETCHPOOL=$debrepodir/public/pool/main/stretch
	export STRETCHCACHE=$BUILDBOTDIR/tmp/debcache
	export STORREPODIR=$BUILDBOTDIR/tmp/stor
	export DH_VIRTUALENV_INSTALL_ROOT=/usr/lib/storbox/
	" >> ~/.bashrc
	source ~/.bashrc
fi

bash bashsource.sh
source ~/bashsource

#########################################################

DATE=$(date +%y%m%d-%H%M)
CFILES="bot/debrepo-cron"

ln -sf $BASE/gpg/bot ~/.gnupg
ln -sf $BASE/repos/aptly.conf ~/.aptly.conf

sudo chown -R $(whoami):$(whoami) $BASE/gpg/bot ~/.gnupg
sudo chmod 700 -R $BASE/gpg/bot ~/.gnupg

# bu satır eski versiyonları nasıl sileceğimizi henüş bulamadığımız için
rm -rf $DEBREPODIR

mkdir -p $STRETCHCACHE $DEBREPODIR $DEBLISTDIR $STORREPODIR

#sudo apt-get install -fy --force-yes apt-transport-https dpkg-dev aptly

snaplist=""
IFS=$'\n'
for r in `./repoindex.py`;do

	echo "___________________________________________________"
	echo $r
	mirname=`echo $r|awk -F "===" '{print $1}'`
        repo=`echo $r|awk -F "===" '{print $2}'`
	packages=`echo $r|awk -F "===" '{print $3}'`
	packages=`echo $packages| sed "s/:amd64//g"`
	echo "--------------$mirname"
	echo "--------------$repo"
	echo "--------------$packages"
	ifmain=$(aptly mirror list -raw |grep $mirname|wc -l)
	if [ $ifmain == "0"  ];then
		echo $repo | xargs aptly mirror create  -architectures="amd64" -filter="$packages" $mirname 
	else
        	echo "mirror 'debian-main' editing.."
        	aptly mirror edit -filter="$packages" $mirname
	fi

	aptly mirror update -max-tries=10 $mirname
	aptly snapshot create $mirname-$DATE from mirror $mirname
	snaplist="$snaplist $mirname-$DATE"
	sleep 1
done

echo $snaplist|xargs aptly snapshot merge main-$DATE

#stor
ifstor=$(aptly repo list -raw |grep stor|wc -l)
if [ $ifstor == "0"  ];then
        aptly repo create -architectures="amd64" -distribution=stretch -component=stor stor
else
        echo "repo stor already added."
fi

ifrepostor=$(aptly repo list -raw |grep stor|wc -l)
if [ $ifrepostor == "0"  ];then
        aptly repo add stor $STORREPODIR
else
        echo "repo stor already added."
        aptly repo add stor $STORREPODIR
fi

aptly snapshot create stor-$DATE from repo stor

#publish
ifpublish=$(aptly publish list -raw |wc -l)

if [ "$ifpublish" == "1" ];then
        aptly publish drop stretch
fi

aptly publish snapshot -distribution="bot" -component=main,stor main-$DATE stor-$DATE

gpg --export --armor > $DEBREPODIR/public/Storbox.asc
#drop snapshots
list=$(aptly snapshot list -raw)
for l in $list;do aptly snapshot drop $l;done

sudo apt-get install -fy --force-yes install nginx
sudo rm /etc/nginx/sites-enabled/default
sudo ln -sf $BASE/bot/nginx/debrepo/default /etc/nginx/sites-enabled/default
sudo service nginx restart

exit 0
