#!/usr/bin/env python

from twisted.web import resource
from CategoriesXML import CategoriesXML

class CategoriesFactory(resource.Resource):
    
    def __init__(self, db):
        resource.Resource.__init__(self)
        self.db = db
    
    def getChild(self, path, request):
        return CategoriesXML(path, self.db)

