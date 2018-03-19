#!/usr/bin/python
# Need to install 'apt-get install python-pymongo'
# DeleteDB in the MongoDBServer
# Ridvan Gundogmus - ridvan.gundogmus@ekinokssoftware.com

import os, pymongo

client = pymongo.MongoClient('mongo-server-ip-or-hostname', 27017)
client.drop_database('storpackages')

