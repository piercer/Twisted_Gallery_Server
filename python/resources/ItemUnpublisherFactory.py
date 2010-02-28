from twisted.web import resource
from DeferredXML import DeferredXML
from FWGException import FWGException
from ItemUnpublisher import ItemUnpublisher

class ItemUnpublisherFactory(resource.Resource):
    
    def __init__(self, db):
        resource.Resource.__init__(self)
        self.db = db

    def getChild(self, path, request):
        if path.isdigit():
            return ItemUnpublisher(path,self.db)
        else:
            pass
