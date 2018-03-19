#!/usr/bin/python
# Need to install 'apt-get install python-pymongo'
# Save packages that installed to the MongoDBServer
# Ridvan Gundogmus - ridvan.gundogmus@ekinokssoftware.com

import os, pymongo, logging
from pprint import pprint
def collectionofpackages():
    # Collect package name and version from local host and modify
    packagesCollection = 'dpkg -l | grep \'^ii\'| awk \'{print $2 " " $3}\''
    packageresults = os.popen(packagesCollection).read().splitlines()
    # Connect to the MongoDB Server
    # change ip   in /etc/mongodb.conf and here.
    client = pymongo.MongoClient('mongo-server-ip-or-hostname', 27017)
    db = client["storpackages"]
    collection = db["repository"]

    # Upsert = Update or insert package to the collection of mongodb
    for packagestr in packageresults:
	try:
	        pack_name = packagestr.split(" ").__getitem__(0)
	        pack_version = packagestr.split(" ").__getitem__(1)
		originq = "apt-cache policy %s |grep -A1 '\*\*\*'|grep -v '\*\*\*'"%pack_name
		origin = os.popen(originq).read().lstrip().split(" ")
		origins = origin[2].split("/")
		repo_url = origin.__getitem__(1)
		package_release = origins.__getitem__(0)
		package_repo = origins.__getitem__(1)
		package_url = "%s %s %s"%(repo_url,package_release,package_repo)
#		print "================ duzgun liste:"
#		pprint(packagestr)
#		print origin
	except:
		print "================ repolarda artik bulunmayan paket es geciliyor:"
		pprint(packagestr)
		print origin
    	try:
        #               collection.update({"package_name": pack_name}, {"package_name": pack_name, "package_version": pack_version}, upsert=True)

        	collection.update({"package_name": pack_name}, {"package_name": pack_name, "package_version": pack_version, "package_url": package_url, "package_release": package_release, "package_repo": package_repo}, upsert=True)
    	except:
        	print ("Document already exists.")


collectionofpackages()
