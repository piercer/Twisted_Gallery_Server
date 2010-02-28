#!/usr/bin/env python
from ConfigParser import ConfigParser

from twisted.web import server
from twisted.internet import reactor
from ReconnectingConnectionPool import ReconnectingConnectionPool
from resources.GalleryRoot import GalleryRoot

config = ConfigParser()
config.read(['server.ini'])

dbhost = config.get('Database','host')
dbuser = config.get('Database','user')
dbpasswd = config.get('Database','password')
dbsocket = config.get('Database','socket')
database = config.get('Database','database')
port = config.getint('Server','port')

cp = ReconnectingConnectionPool("MySQLdb",host=dbhost,user=dbuser,passwd=dbpasswd,db=database,unix_socket=dbsocket,cp_reconnect=True)
site = server.Site(GalleryRoot(cp,config))
reactor.listenTCP(port, site)
reactor.run()
