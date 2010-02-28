from DeferredXML import DeferredXML

class ItemUnpublisher(DeferredXML):
    
    def __init__(self, id, db):
        DeferredXML.__init__(self, db)
        self.id = id
    
    def getXML(self, cursor):
        cursor.callproc('unpublishItem', [self.id])
        response = self.createElement('response')
        response.setAttribute('type', 'success')
        self.appendChild(response)
