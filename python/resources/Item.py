import os.path
from twisted.web import resource, server, http
import Image
import re

from FWGException import FWGException

class Item(resource.Resource):
    
    sizeMatch = re.compile('(\d+)X(\d+)')
    
    def __init__(self, id, db, config):
        resource.Resource.__init__(self)
        self.db = db
        self.id = id
        self.size = None
        self.im = None
        self.config = config
        self.errorCode = http.OK
        self.contentType = 'image/jpeg'
    
    def getImage(self, cursor):
        cursor.callproc('getItemDetails', [self.id])

        if cursor.rowcount>0:
            row = cursor.fetchone()
            imageFile = self.config.get('Server','gallery_root')+row[1]
            if os.path.isfile(imageFile):
                self.im = Image.open(imageFile)
                if imageFile.lower().endswith('gif'):
                    self.contentType = 'image/gif'
                if self.size:
                    self.im.thumbnail(self.size)
            else:
                cursor.nextset()
                self.errorCode = http.NOT_FOUND
                raise FWGException("Image file not found")
        else:
            cursor.nextset()
            self.errorCode = http.NOT_FOUND
            raise FWGException("Item not found")


    def writeImage(self, result, request):
        request.setHeader('content-type', self.contentType)
        if self.im:
            if self.contentType == 'image/jpeg':
                self.im.save(request,"JPEG")
            elif self.contentType == 'image/gif':
                self.im.save(request,"GIF")
        request.finish()

    def writeError(self, failure, request):        
        request.setResponseCode(self.errorCode)
        request.write("Error fetching item: %s" % failure.getErrorMessage())
        request.finish()
    
    def render_GET(self, request):
        process=self.db.runInteraction(self.getImage)
        process.addCallback(self.writeImage, request)
        process.addErrback(self.writeError, request)
        return server.NOT_DONE_YET
    
    def getChild(self, path, request):
        match = Item.sizeMatch.match(path)
        if match:
            self.size = int(match.group(1)), int(match.group(2))
        return self
