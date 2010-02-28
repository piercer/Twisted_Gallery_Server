from twisted.web import server
from twisted.enterprise import adbapi
from twisted.application import internet
from GalleryRoot import GalleryRoot

class FWGServer(internet.TCPServer):
    def __init__(self,config):
        dbhost = config.get('Database','host')
        dbuser = config.get('Database','user')
        dbpasswd = config.get('Database','password')
        dbsocket = config.get('Database','socket')
        database = config.get('Database','database')
        port = config.getint('Server','port')
        cp = adbapi.ConnectionPool("MySQLdb",host=dbhost,user=dbuser,passwd=dbpasswd,db=database,unix_socket=dbsocket,cp_reconnect=True)
        site = server.Site(GalleryRoot(cp,config))
        internet.TCPServer.__init__(self, port, site)
