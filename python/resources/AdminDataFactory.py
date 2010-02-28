#!/usr/bin/env python

from twisted.web import resource
from AdminDataXML import AdminDataXML

class AdminDataFactory(resource.Resource):
    
    def __init__(self, db):
        resource.Resource.__init__(self)
        self.db = db
    
    def getChild(self, path, request):
        return AdminDataXML(self.db, request)

