from DeferredPostHandler import DeferredPostHandler
from FWGException import FWGException


import datetime

class ItemAdminHandler(DeferredPostHandler):

    def __init__(self, task, db, config):
        DeferredPostHandler.__init__(self,db)
        self.config = config
        self.task = task


    def processForm(self, cursor, request):

        if self.task == 'add':
            self.addItem(cursor, request)

        elif self.task == 'delete':
            self.deleteItem(cursor, request)

        else:
            self.errorCode = DeferredPostHandler.NOT_IMPLEMENTED
            raise FWGException("Unsupported Task")


    def addItem(self, cursor, request):
        if self.isValidAddRequest(request):
            baseDir = self.config.get('Server','gallery_root')
            collectionId = int(request.args['collection'][0])
            itemOrder = int(request.args['order'][0])
            dirName = "collection-"+str(collectionId)

            fileName = request.args['file'][0]
            imagePath = dirName+"/"+fileName
            bitmap = request.args['image'][0]
            fileName = baseDir+imagePath
            file = open(fileName, 'wb')
            file.write(bitmap)
            file.close()
            if 'date' in request.args:
                imageDate = datetime.datetime.strptime(request.args['date'][0],'%a %b %d %H:%M:%S %Y UTC')
            else:
                imageDate = datetime.date.today()
            cursor.callproc('addCollectionItem',[collectionId, 1, imageDate, imageDate, "image/jpeg", imagePath, itemOrder, 0])
            itemId = cursor.fetchone()[0]
            cursor.nextset()
            self.addMeta(request,'Title',itemId,cursor)
            self.addMeta(request,'Photographer',itemId,cursor)
            self.addMeta(request,'Club',itemId,cursor)
            self.addMeta(request,'Venue',itemId,cursor)
        else:
            self.errorCode = DeferredPostHandler.BAD_REQUEST
            raise FWGException("Missing Parameter")

    def addMeta(self,request,metaName,itemId,cursor):
        if metaName in request.args:
            metaValue = request.args[metaName][0]
            cursor.callproc('addMetaForItem',[itemId,metaName,metaValue])
            cursor.nextset();

    def isValidAddRequest(self, request):
        return 'collection' in request.args and 'file' in request.args and 'image' in request.args and 'order' in request.args

    def deleteItem(self, cursor, request):
        pass

