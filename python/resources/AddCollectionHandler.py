#!/usr/bin/env python
from DeferredPostHandler import DeferredPostHandler

class AddCollectionHandler(DeferredPostHandler):

    def __init__(self, id, db):
        DeferredPostHandler.__init__(self,db)
        self.id = id

    def processForm(self,cursor):
        print "ProcessForm Called!"
