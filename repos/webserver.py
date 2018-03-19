#!/bin/bash
# Devops project -- 2016 -- kansukse@gmail.com 
# Basit Python Web sunucu
import os
import posixpath
import urllib
import BaseHTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler

ROUTES = (
    ['',       '/BUILDBOT/repos'],
) 

class RequestHandler(SimpleHTTPRequestHandler):
    
    def translate_path(self, path):
        """translate path given routes"""
        root = os.getcwd()
        for pattern, rootdir in ROUTES:
            if path.startswith(pattern):
                path = path[len(pattern):] 
                root = rootdir
                break
        path = path.split('?',1)[0]
        path = path.split('#',1)[0]
        path = posixpath.normpath(urllib.unquote(path))
        words = path.split('/')
        words = filter(None, words)
        
        path = root
        for word in words:
            drive, word = os.path.splitdrive(word)
            head, word = os.path.split(word)
            if word in (os.curdir, os.pardir):
                continue
            path = os.path.join(path, word)

        return path

if __name__ == '__main__':
    httpd=BaseHTTPServer.HTTPServer(("0.0.0.0",8081),RequestHandler)
    httpd.serve_forever()
