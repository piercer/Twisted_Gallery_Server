from twisted.web import resource
from CategoryXML import CategoryXML
from CategoryAdminHandler import CategoryAdminHandler 

class CategoryFactory(resource.Resource):
    
    def __init__(self, db, config):
        resource.Resource.__init__(self)
        self.db = db
        self.config = config
    
    def getChild(self, path, request):
        if path.isdigit():
            return CategoryXML(path, self.db)
        else:
            return CategoryAdminHandler(path, self.db, self.config)

