from xml.dom import minidom
from twisted.web import server, http, resource

from FWGException import FWGException

class DeferredXML(resource.Resource, minidom.Document):

    def __init__(self, dbConnection):
        resource.Resource.__init__(self)
        minidom.Document.__init__(self)
        self.db = dbConnection
		
    def getTextNode(self, name, text):
        node = self.createElement(name)
        node.appendChild(self.createTextNode(text))
        return node

    def getCDATANode(self, name, text):
        node = self.createElement(name)
        node.appendChild(self.createCDATASection(text))
        return node

    def writeError(self, failure, request):
        failure.trap(FWGException)
        request.setResponseCode(self.errorCode)
        request.write("Error fetching page: %s" % failure.getErrorMessage())
        request.finish()

    def writeResult(self, result, request):
        self.writexml(request)
        request.finish()

    def render_GET(self, request):
        process = self.db.runInteraction(self.getXML)
        process.addCallback(self.writeResult, request)
        process.addErrback(self.writeError, request)
        return server.NOT_DONE_YET



