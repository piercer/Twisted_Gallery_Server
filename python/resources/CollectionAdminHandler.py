from DeferredPostHandler import DeferredPostHandler
from twisted.web import http
from FWGException import FWGException
import os.path

import datetime

class CollectionAdminHandler(DeferredPostHandler):

    def __init__(self, task, db, config):
        DeferredPostHandler.__init__(self,db)
        self.config = config
        self.task = task
        self.errorCode = http.OK

    def processForm(self, cursor, request):

        if self.task == 'add':
            self.addCollection(cursor, request)

        elif self.task == 'delete':
            self.deleteCollection(cursor, request)
            
        else:
            self.errorCode = DeferredPostHandler.NOT_IMPLEMENTED
            raise FWGException("Unsupported Task")

    def addCollection(self, cursor, request):
        if self.isValidAddRequest(request):
            collectionTitle = request.args['title'][0]
            categoryId = int(request.args['category'][0])

            if 'date' in request.args:
                collectionDate = datetime.datetime.strptime(request.args['date'][0],'%a %b %d %H:%M:%S %Y UTC')
            else:
                collectionDate = datetime.date.today()
            cursor.callproc('addCollection', [categoryId, collectionDate, collectionTitle])
            collectionId = cursor.fetchone()[0]
            cursor.nextset()

            baseDir = self.config.get('Server','gallery_root')
            dirName = "collection-"+str(collectionId)
            if not os.path.isdir(baseDir+dirName):
                os.mkdir(baseDir+dirName)

            response = self.createElement('response')
            response.setAttribute('type', 'success')
            message = self.createElement('collection')
            message.setAttribute('id',str(collectionId))
            response.appendChild(message)
            self.appendChild(response)
        else:
            self.errorCode = DeferredPostHandler.BAD_REQUEST
            raise FWGException("Missing Parameter")


    def deleteCollection(self, cursor, request):
        print 'Delete Collection'

    def isValidAddRequest(self, request):
        return 'title' in request.args and 'category' in request.args

