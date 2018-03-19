#!/usr/bin/python
# Need to install 'apt-get install python-pymongo'
# kansukse@gmail.com
from pprint import pprint
import os, pymongo
client = pymongo.MongoClient('ceph2', 27017)
db = client["storpackages"]
collection = db["repository"]
cursor = collection.distinct( "package_url" )

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]

for repo in cursor:
	plist = list(collection.find({ "package_url": repo }))
	pkg=[]
	for p in plist:
		pkg.append(p["package_name"])
	pkgs = list(chunks(pkg, 10))

	for c,k in enumerate(pkgs):
		packages = ''.join(map(str,repo.split(" "))).translate(None, '/:.-')
		packages += str(c) + "===" + str(repo) + "==="
		for p in k:
			packages += "Name (%s) | "%str(p)
		packages = packages[:-2]
		packages = packages[9:]
		print(packages)
