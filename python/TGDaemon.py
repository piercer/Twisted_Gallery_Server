from twisted.application import service
from ConfigParser import ConfigParser
from resources.FWGServer import TGServer

config = ConfigParser()
config.read(['server.ini'])

application = service.Application("TGServer")
service = TGServer(config)
service.setServiceParent(application)
