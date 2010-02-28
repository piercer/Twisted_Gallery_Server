from DeferredXML import DeferredXML

class TagsXML(DeferredXML):
    
    def __init__(self, db):
        DeferredXML.__init__(self, db)
    
    def getXML(self, cursor):

        cursor.callproc('getTags')
        
        tags=self.createElement('tags')        
        for row in cursor:
            tag = self.createElement('tag')
            tag.setAttribute('id', str(row[0]))
            tag.appendChild(self.getCDATANode('name', row[1]))
            tag.appendChild(self.getTextNode('count', row[2]))
            tags.appendChild(tag)

        response = self.createElement('response')
        response.setAttribute('type', 'tagdata')
        self.appendChild(response)
        response.appendChild(tags)


