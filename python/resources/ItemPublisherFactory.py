from twisted.web import resource
from DeferredXML import DeferredXML
from FWGException import FWGException
from ItemPublisher import ItemPublisher

class ItemPublisherFactory(resource.Resource):
    
    def __init__(self, db):
        resource.Resource.__init__(self)
        self.db = db

    def getChild(self, path, request):
        if path.isdigit():
            return ItemPublisher(path,self.db)
        else:
            pass


