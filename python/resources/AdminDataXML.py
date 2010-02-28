from DeferredXML import DeferredXML

class AdminDataXML(DeferredXML):

	def __init__(self, db, request):
		DeferredXML.__init__(self, db)
		self.request = request

	def getXML(self, cursor):

		cursor.callproc('getCategoryHeirarchy')
		row = cursor.fetchone()

		categories = self.createElement('categories')
		topcat = self.getCategoryNode(row)
		self.addChildren(topcat,row[1],cursor)
		categories.appendChild(topcat)
		cursor.nextset()
		
		meta_data = self.createElement('meta_data')
		meta = self.request.args['meta']
		
		for meta_name in meta:
			meta_node = self.createElement('meta')
			meta_node.setAttribute('name', meta_name)
			cursor.callproc('getMetaValues',[meta_name])
			for row in cursor:
				meta_node.appendChild(self.getCDATANode('value',row[1]))
			meta_data.appendChild(meta_node)
			cursor.nextset()

		response = self.createElement('response')
		response.setAttribute('type', 'admin_data')
		self.appendChild(response)
		response.appendChild(categories)
		response.appendChild(meta_data)


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
