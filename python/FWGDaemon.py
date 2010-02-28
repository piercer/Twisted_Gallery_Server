from twisted.application import service
from ConfigParser import ConfigParser
from resources.FWGServer import FWGServer

config = ConfigParser()
config.read(['server.ini'])

application = service.Application("FWGServer")
service = FWGServer(config)
service.setServiceParent(application)
