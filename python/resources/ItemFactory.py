from twisted.web import resource
from Item import Item
from ItemAdminHandler import ItemAdminHandler
from ItemPublisherFactory import ItemPublisherFactory
from ItemUnpublisherFactory import ItemUnpublisherFactory

class ItemFactory(resource.Resource):
    
    def __init__(self, db, config):
        resource.Resource.__init__(self)
        self.db = db
        self.config = config
        self.putChild('publish',ItemPublisherFactory(db))
        self.putChild('unpublish',ItemUnpublisherFactory(db))

    def getChild(self, path, request):
        if path.isdigit():
            return Item(path, self.db, self.config)
        else:
            return ItemAdminHandler(path, self.db, self.config)


