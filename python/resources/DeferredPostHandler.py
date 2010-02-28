from xml.dom import minidom
from twisted.web import server, resource

from FWGException import FWGException

class DeferredPostHandler(resource.Resource,minidom.Document):

    NOT_IMPLEMENTED = 501
    BAD_REQUEST = 400

    def __init__(self, dbConnection):
        resource.Resource.__init__(self)
        minidom.Document.__init__(self)
        self.db = dbConnection

    def getTextNode(self, name, text):
        node=self.createElement(name)
        node.appendChild(self.createTextNode(text))
        return node

    def getCDATANode(self, name, text):
        node=self.createElement(name)
        node.appendChild(self.createCDATASection(text))
        return node
	
    def writeError(self, failure, request, *args, **kw):
        failure.trap(FWGException)
        request.setResponseCode(self.errorCode)
        request.write("Error handling request: %s" % failure.getErrorMessage())
        request.finish()

    def writeResult(self, result, request, *args, **kw):
        self.writexml(request)
        request.finish()

    def render_POST(self, request):
        process=self.db.runInteraction(self.processForm,request)
        process.addCallback(self.writeResult, request)
        process.addErrback(self.writeError, request)
        return server.NOT_DONE_YET

    def render_GET(self, request):
        process=self.db.runInteraction(self.processForm,request)
        process.addCallbacks(self.writeResult, self.writeError, [request], {}, [request], {})
        return server.NOT_DONE_YET
