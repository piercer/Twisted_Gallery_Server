from DeferredPostHandler import DeferredPostHandler
from twisted.web import http
from FWGException import FWGException

class CategoryAdminHandler(DeferredPostHandler):
    
    def __init__(self, task, db, config):
        DeferredPostHandler.__init__(self,db)
        self.config = config
        self.task = task
        self.errorCode = http.OK
    
    def processForm(self, cursor, request):
        if self.task == 'add':
            self.addCategory(cursor, request)
        
        elif self.task == 'delete':
            self.deleteCategory(cursor, request)
        
        else:
            self.errorCode = DeferredPostHandler.NOT_IMPLEMENTED
            raise FWGException("Unsupported Task")

    def addCategory(self, cursor, request):
        if self.isValidAddRequest(request):
            categoryTitle = request.args['title'][0]
            parentId = int(request.args['parent'][0])
            description = ''
            information = ''
            contact = ''
            website = ''

            if 'description' in request.args:
                description = request.args['description'][0]
            if 'information' in request.args:
                information = request.args['information'][0]
            if 'contact' in request.args:
                contact = request.args['contact'][0]
            if 'website' in request.args:
                website = request.args['website'][0]

            cursor.callproc('addCategory', [categoryTitle, parentId, None, description, information, contact, website, '', '', 1])
            categoryId = cursor.fetchone()[0]
            cursor.nextset()

            response = self.createElement('response')
            response.setAttribute('type', 'success')
            message = self.createElement('category')
            message.setAttribute('id',str(categoryId))
            response.appendChild(message)
            self.appendChild(response)
        else:
            self.errorCode = DeferredPostHandler.BAD_REQUEST
            raise FWGException("Missing Parameter")
    
    def deleteCategory(self, cursor, request):
        print 'Delete Collection'
    
    def isValidAddRequest(self, request):
        return 'title' in request.args and 'parent' in request.args

