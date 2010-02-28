#!/usr/bin/env python
from DeferredPostHandler import DeferredPostHandler
import uuid
import os
import datetime

class ImageUploadHandler(DeferredPostHandler):

    def __init__(self, db, config):
        DeferredPostHandler.__init__(self,db)
        self.config = config

    def processForm(self, cursor, request):
        
        baseDir = self.config.get('Server','gallery_root')
        dirName = "Upload-"+str(uuid.uuid4())
        os.mkdir(baseDir+dirName)
        
        collectionTitle = request.args['title'][0]
        categoryId = int(request.args['categoryId'][0])
        
        if 'Date' in request.args:
            collectionDate = datetime.datetime.strptime(request.args['Date'][0],'%a %b %d %H:%M:%S %Y UTC')
        else:
            collectionDate = datetime.date.today()
        cursor.callproc('addCollection', [categoryId, collectionDate, collectionTitle])
        collectionID = cursor.fetchone()[0]
        cursor.nextset()
        
        iImage = 0
        sImage = str(iImage)
        while 'file'+sImage in request.args:
            fileName = request.args['file'+sImage][0]
            imagePath = dirName+"/"+fileName
            if 'image'+sImage in request.args:
                bitmap = request.args['image'+sImage][0]
                fileName = baseDir+imagePath
                file = open(fileName, 'wb')
                file.write(bitmap)
                file.close()
                if 'Date'+sImage in request.args:
                    imageDate = datetime.datetime.strptime(request.args['Date'+sImage][0],'%a %b %d %H:%M:%S %Y UTC')
                else:
                    imageDate = datetime.date.today()
                cursor.callproc('addCollectionItem',[collectionID, 1, imageDate, imageDate, "image/jpeg", imagePath, 0])
                itemID = cursor.fetchone()[0]
                cursor.nextset()
                self.addMeta(request,'Title',itemID,sImage,cursor)
                self.addMeta(request,'Photographer',itemID,sImage,cursor)
                self.addMeta(request,'Club',itemID,sImage,cursor)
                self.addMeta(request,'Venue',itemID,sImage,cursor)
                iImage = iImage+1
                sImage = str(iImage)

    def addMeta(self,request,metaName,itemID,sImage,cursor):
        if metaName+sImage in request.args:
            metaValue = request.args[metaName+sImage][0]
            cursor.callproc('addMetaForItem',[itemID,metaName,metaValue])
            cursor.nextset();

