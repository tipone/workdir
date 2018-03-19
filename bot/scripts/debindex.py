#!/usr/bin/python
# Need to install 'sudo apt-get install python-pymongo'
# Save packages that installed to the MongoDBServer
# Rıdvan Gündoğmuş
import os
import pymongo
import logging
# logging levels:
# 1 - ERROR
# 2 - INFO
# 3 - DEBUG
mongodbip = '172.16.25.33'
mongodbport = 27017
LOGLEVEL = 3
if str(LOGLEVEL) is str(1):
	logging.basicConfig(filename='/BUILDBOT/tmp/debindexlog.log', format='%(asctime)s:%(levelname)s:%(message)s', datefmt='%d/%m/%Y %I:%M:%S %p', level=logging.ERROR)
elif str(LOGLEVEL) is str(2):
	logging.basicConfig(filename='/BUILDBOT/tmp/debindexlog.log', format='%(asctime)s:%(levelname)s:%(message)-8s [%(filename)s:%(lineno)d]', datefmt='%d/%m/%Y %I:%M:%S %p', level=logging.INFO)
elif str(LOGLEVEL) is str(3):
	logging.basicConfig(filename='/BUILDBOT/tmp/debindexlog.log', format='%(asctime)s:%(levelname)s:%(message)s', datefmt='%d/%m/%Y %I:%M:%S %p', level=logging.DEBUG)
os.system('echo \'/BUILDBOT/tmp/debindexlog.log uzerinden takip edebilirsiniz.\'')
# Collect package name and version from local host and modify
logging.debug("Paketlerin okutulmasi basladi.")
try:
	logging.info("Paketler depodan okunuyor.")
	packagescollection = 'dpkg -l | grep \'^ii\'| awk \'{print $2 " " $3}\''
	packageresults = os.popen(packagescollection).read().splitlines()
except Exception:
	logging.error(str("Paketleri okuma sirasinda hata olustu."))
# Connect to the MongoDB Server
# change ip   in /etc/
logging.debug("Baglanti baslatiliyor.")
try:
	logging.info("MongoDB Server'a baglanti kuruluyor.")
	client = pymongo.MongoClient(mongodbip, mongodbport)
	db = client["storpackages"]
	collection = db["repository"]
	logging.info("MongoDB Server'a baglanti kuruldu.")
except Exception:
	logging.error("MongoDB'ye "+ str(mongodbip) +" ip veya " + str(mongodbport) +" port uzerinden baglanti saglanamiyor.")
	# Upsert = Update or insert package to the collection of mongodb
for packagestr in packageresults:
	logging.debug("Paket bilgileri aliniyor.")
	try:
		pack_name = packagestr.split(" ").__getitem__(0)
		logging.info(pack_name + " paketi ozelliklerine ayriliyor.")
		pack_version = packagestr.split(" ").__getitem__(1)
		originq = "apt-cache policy %s |grep -A1 '\*\*\*'|grep -v '\*\*\*'"%pack_name
		origin = os.popen(originq).read().lstrip().split(" ")
		origins = origin[2].split("/")
		repo_url = origin.__getitem__(1)
		package_release = "/".join(origins[:-1])
		package_repo = origins.__getitem__(-1)
		logging.debug("paket-repo: %s %s %s %s"%(repo_url, package_release, package_repo, pack_name))
		package_url = "%s %s %s"%(repo_url,package_release,package_repo)
	except Exception:
		logging.error("repolarda artik bulunmayan paket es geciliyor: %s %s"%(packagestr,origin))
	logging.debug("MongoDB guncelleniyor.")
	try:
		#collection.update({"package_name": pack_name}, {"package_name": pack_name, "package_version": pack_version}, upsert=True)
		logging.debug("MongoDB uzerindeki paket bilgileri guncelleniyor.")
		collection.update({"package_name": pack_name}, {"package_name": pack_name, "package_version": pack_version, "package_url": package_url, "package_release": package_release, "package_repo": package_repo}, upsert=True)
	except Exception:
		logging.error("MongoDB'ye "+ str(mongodbip) +" ip veya " + str(mongodbport) +" port uzerinden baglanti saglanamiyor.")
