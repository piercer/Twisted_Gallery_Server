from DeferredXML import DeferredXML
import re
from FWGException import FWGException
from twisted.web import http

class CollectionXML(DeferredXML):
    
    def __init__(self, id, db):
        DeferredXML.__init__(self, db)
        self.id = id
    
    def getXML(self, cursor):

        metamatch = re.compile('\{##(.*?)##(.*?)##\}')
        tagmatch = re.compile('\{##(.*?)##\}')

        cursor.callproc('getCollectionItems', [self.id])
        
        if cursor.rowcount>0:
            collection=self.createElement("collection")

            row = cursor.fetchone()
            collection.setAttribute('id', self.id)
            collection.setAttribute('num_pics', str(row[1]))
            collection.appendChild(self.getTextNode('name', row[0]))
        
            cursor.nextset()
            parents=self.createElement('parents')
            for row in cursor:
                parent=self.createElement('parent')
                parent.setAttribute('id', str(row[0]))
                parent.appendChild(self.getTextNode('name', row[1]))
                parents.appendChild(parent)
            
            cursor.nextset()
            items=self.createElement('items')
            for row in cursor:
                
                item = self.createElement('item')
                item.setAttribute('id', str(row[0]))
                item.setAttribute('published', str(row[1]))
                item.appendChild(self.getTextNode('type', row[2]))
                item.appendChild(self.getTextNode('server', row[3]))

                if row[4]:
                    item.appendChild(self.getTextNode('date', str(row[4])))

                metaData=self.createElement('metadata')
                if row[5]:
                    for name, value in metamatch.findall(row[5]):
                        meta=self.createElement('meta')
                        meta.appendChild(self.getTextNode('name', name))
                        meta.appendChild(self.getTextNode('value', value))
                        metaData.appendChild(meta)
        
                tags=self.createElement('tags')
                if row[6]:
                    for name in tagmatch.findall(row[6]):
                        tags.appendChild(self.getTextNode('tag', name))
        
                item.appendChild(metaData)
                item.appendChild(tags)
                items.appendChild(item)
        
            response = self.createElement('response')
            response.setAttribute('type', 'collection')
            self.appendChild(response)
            response.appendChild(collection)
            collection.appendChild(parents)
            collection.appendChild(items)

        else:
            self.errorCode = http.NOT_FOUND
            raise FWGException('Collection not found')

