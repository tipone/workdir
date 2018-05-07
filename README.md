# workdir
This repo is not ready for install or use. 

# Install sudo and git packages
apt-get install sudo git

# Give hostname and edit /etc/hosts for host IP
echo "master" |tee /etc/hostname |xargs hostname
echo -e "127.0.0.1 localhost \n192.168.122.190	 master" |tee /etc/hosts

# Add Buildbot user
adduser bot

# Create Buildbot dierctory and give necessery privileges to buildbot user.
mkdir /BUILDBOT
chown -R bot:bot /BUILDBOT/

# Arrange buildbot user as passwordless sudoer user. 
nano /etc/sudoers

# Add this line
bot	ALL=NOPASSWD:   ALL

# Yo can use another user.
su bot
cd /BUILDBOT

# Clone repo.
git clone https://github.com/tipone/workdir.git
cd /BUILDBOT/workdir

# Run redmine-ready.sh
./redmine-ready.sh

# Create master
./buildmaster-ready.sh

# Create Worker.

./buildworker-ready.sh
