from DeferredXML import DeferredXML
from FWGException import FWGException
from twisted.web import http

class CategoryXML(DeferredXML):
    
    def __init__(self, id, db):
        DeferredXML.__init__(self, db)
        self.id = id
    
    def getXML(self, cursor):
        cursor.callproc('getCategoryDetails', [self.id])

        if cursor.rowcount>0:
            category=self.createElement("category")
            category.setAttribute('id', str(self.id))
        
            parents=self.createElement('parents')
            for row in cursor:
                parent=self.createElement('parent')
                parent.setAttribute('id', str(row[0]))
                parent.appendChild(self.getTextNode('name', row[1]))
                parents.appendChild(parent)
                
            children=self.createElement('children')
            cursor.nextset()
            for row in cursor:
                child = self.createElement('child')
                child.setAttribute('type', 'category')
                child.setAttribute('id', str(row[0]))
                child.setAttribute('num_gal', str(row[3]))
                child.setAttribute('num_pic', str(row[4]))
                child.appendChild(self.getCDATANode('name', row[1]))
                child.appendChild(self.getCDATANode('description', row[2]))
                preview = self.createElement('preview')
                preview.setAttribute('id', str(row[6]))
                preview.appendChild(self.getCDATANode('server', row[5]))
                preview.appendChild(self.getCDATANode('type', row[7]))
                child.appendChild(preview)
                children.appendChild(child)

            cursor.nextset()
            for row in cursor:
                child = self.createElement('child')
                child.setAttribute('type', 'collection')
                child.setAttribute('id', str(row[0]))
                child.setAttribute('num_pic', str(row[2]))
                child.appendChild(self.getCDATANode('name', row[1]))
                preview = self.createElement('preview')
                preview.setAttribute('id', str(row[4]))
                preview.appendChild(self.getCDATANode('server', row[3]))
                preview.appendChild(self.getCDATANode('type', row[5]))
                child.appendChild(preview)
                children.appendChild(child)
        
            response = self.createElement('response')
            response.setAttribute('type', 'category')
            self.appendChild(response)
            response.appendChild(category)
            category.appendChild(parents)
            category.appendChild(children)

        else:
            self.errorCode = http.NOT_FOUND
            raise FWGException('Can not find category')

