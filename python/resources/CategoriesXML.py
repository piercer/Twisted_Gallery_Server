from DeferredXML import DeferredXML

class CategoriesXML(DeferredXML):

	def __init__(self, id, db):
		DeferredXML.__init__(self, db)
		self.id = id


	def getXML(self, cursor):

		cursor.callproc('getCategoryHeirarchy')
		row = cursor.fetchone()

		topcat = self.getCategoryNode(row)
		self.addChildren(topcat,row[1],cursor)

		response = self.createElement('response')
		response.setAttribute('type', 'categories')
		self.appendChild(response)
		response.appendChild(topcat)


	def addChildren(self,parent,depth,cursor):
		row = cursor.fetchone()
		while row:
			newDepth = row[1]
			if newDepth == depth+1:
				category = self.getCategoryNode(row)
				parent.appendChild(category)
				self.addChildren(category,newDepth,cursor)
				row = cursor.fetchone()
			else:
				cursor.scroll(-1)
				row = None


	def getCategoryNode(self,row):
		category = self.createElement('node')
		category.setAttribute('id', str(row[0]))
		category.setAttribute('name', row[2])
		return category
