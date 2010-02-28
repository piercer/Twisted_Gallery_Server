#!/usr/bin/env python

from twisted.web import resource
from TagsXML import TagsXML

class TagsFactory(resource.Resource):
    
    def __init__(self, db):
        resource.Resource.__init__(self)
        self.db = db
    
    def getChild(self, path, request):
        return TagsXML(self.db)

