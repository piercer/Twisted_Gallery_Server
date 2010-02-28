from twisted.web import resource
from CollectionXML import CollectionXML
from CollectionAdminHandler import CollectionAdminHandler

class CollectionFactory(resource.Resource):
    
    def __init__(self, db, config):
        resource.Resource.__init__(self)
        self.db = db
        self.config = config
    
    def getChild(self, path, request):
        if path.isdigit():
            return CollectionXML(path, self.db)
        else:
            return CollectionAdminHandler(path, self.db, self.config)




