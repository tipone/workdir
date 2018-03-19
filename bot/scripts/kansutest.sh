#!/bin/bash
# Workdir Buildbot Devops Example -- 2017 -- kansukse@gmail.com
# storbox paketini kurar
bash bashsource.sh
source ~/bashsource
DATE=$(date +%y%m%d-%H%M)

# Debian gerekli repolar
echo -e "# Main Storbox Repos
deb http://stordeb/ bot main stor"| 
sudo tee /etc/apt/sources.list > /dev/null

# Stor (stretch) harici tüm repoları pinliyoruz.

wget -q http://stordeb/Storbox.asc -O- |sudo apt-key add -
rm /etc/apt/sources.list.d/*
sudo apt-get update
sudo apt-get clean
sudo apt-get purge -fy --assume-yes storbox-server storbox-common
sudo apt-get autoremove -fy --assume-yes
dpkg --get-selections|grep deinstall|xargs sudo dpkg -P
sudo rm -rf /usr/lib/storbox/ 
sudo rm -rf /usr/lib/storbox/
sudo rm -rf /var/log/storbox/
sudo apt-get install -fy --assume-yes storbox-server
