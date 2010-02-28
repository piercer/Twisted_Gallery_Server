#!/usr/bin/env python

from twisted.web import resource
from AddCollectionHandler import AddCollectionHandler


class AddCollectionFactory(resource.Resource):
    
    def __init__(self, db):
        resource.Resource.__init__(self)
        self.db = db
    
    def getChild(self, path, request):
        return AddCollectionHandler(path, self.db)
