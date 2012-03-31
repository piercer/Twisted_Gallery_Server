from twisted.web import resource, static

from CategoriesFactory import CategoriesFactory
from CollectionFactory import CollectionFactory
from CategoryFactory import CategoryFactory
from ItemFactory import ItemFactory
from TagsFactory import TagsFactory
from AdminDataFactory import AdminDataFactory

class GalleryRoot(resource.Resource):
        
    def __init__(self, db, config):
        resource.Resource.__init__(self)
        self.putChild('collection',CollectionFactory(db, config))
        self.putChild('category',CategoryFactory(db, config))
        self.putChild('item',ItemFactory(db, config))
        self.putChild('tags',TagsFactory(db))
        self.putChild('categories',CategoriesFactory(db))
        self.putChild('adminData',AdminDataFactory(db))
        self.putChild('crossdomain.xml',static.File('crossdomain.xml'))



