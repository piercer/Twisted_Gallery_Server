#!/usr/bin/env python

from twisted.web import resource
from ImageUploadHandler import ImageUploadHandler

class ImageUploadHandlerFactory(resource.Resource):
    
    def __init__(self, db, config):
        resource.Resource.__init__(self)
        self.db = db
        self.config = config
        
    def getChild(self, path, request):
        return ImageUploadHandler(self.db, self.config)
