### Local

echo "#storbox 
deb [arch=amd64] http://stordeb/ stretch main stor
"|tee -a /etc/apt/sources.list.d/storbox

wget -q http://stordeb/Storbox.asc -O- |sudo apt-key add -

### World Wide

echo "#storbox 
deb [arch=amd64] http://stordeb.botsoftware.com/ stretch main stor
"|tee -a /etc/apt/sources.list.d/storbox

wget -q http://stordeb.botsoftware.com/Storbox.asc -O- |sudo apt-key add -
