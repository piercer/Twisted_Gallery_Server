#
#  Created by Conrad on 2007-09-12.
#  Copyright (c) 2007. All rights reserved.
#
require 'rubygems'
require 'mysql2'
require 'exifr'

def traverseCategories(parentID,dir,dbh,baseDir)
  months=Hash.new
  months['Jan']=1;
  months['Feb']=2;
  months['Mar']=3;
  months['Apr']=4;
  months['May']=5;
  months['Jun']=6;
  months['Jul']=7;
  months['Aug']=8;
  months['Sep']=9;
  months['Oct']=10;
  months['Nov']=11;
  months['Dec']=12;
  Dir.foreach(dir) do |entry|
    if (entry!='.'&&entry!='..'&&entry!='.svn'&&entry!='tmp')
      newPath="#{dir}/#{entry}"
      if (File.directory?(newPath))
        #
        # Check for subdirectories
        #
        if (hasSubDirectories(newPath))
          result=dbh.query("call addCategory('#{entry}',#{parentID},null,'','','','','','',0)")
          catID=result.first["LAST_INSERT_ID()"]
          dbh.next_result
          traverseCategories(catID,newPath,dbh,baseDir)
        else
          result=dbh.query("call addCollection(#{parentID},now(),'#{entry}')")
          colID=result.first["LAST_INSERT_ID()"]
          dbh.next_result
          Dir.chdir(newPath)
          images=Dir.glob("*.{jpg,jpeg}")
          relativePath=/#{baseDir}(.*)/.match(newPath)[1]
          isPreview=1;
          iItem=0;
          images.each do |image|
            exif=EXIFR::JPEG.new("#{newPath}/#{image}")
            if exif.exif?
              edate=exif.date_time.to_s
              data=/... (...) (..) (..:..:..) ..... (....)/.match(edate)
              itemDate="#{data[4]}-#{months[data[1]]}-#{data[2]} #{data[3]}"
            else
              itemDate=nil
            end
            result=dbh.query("call addCollectionItem(#{colID},1,'#{itemDate}',null,'image/jpeg','#{relativePath}/#{image}',#{iItem},#{isPreview})")
            itemID=result.first["item_id"]
            dbh.next_result
            if exif.exif?
              dbh.query("call addMetaForItem(#{itemID},'Camera','#{exif.model}')")
              dbh.query("call addMetaForItem(#{itemID},'Exposure','#{exif.exposure_time.to_s}')")
              dbh.query("call addMetaForItem(#{itemID},'Focal Length','#{exif.focal_length.to_f}mm')")
              dbh.query("call addMetaForItem(#{itemID},'Aperture','f#{exif.f_number.to_f}')")
              dbh.query("call addMetaForItem(#{itemID},'Width','#{exif.height}')")
              dbh.query("call addMetaForItem(#{itemID},'Height','#{exif.width}')")
            end
            isPreview=0
            iItem+=1;
          end
        end
      end
    end
  end
end

def hasSubDirectories(dir)
  result=false
  #
  # Check for subdirectories
  #
  if (File.directory?(dir))
    Dir.foreach(dir) do |entry|
      newPath="#{dir}/#{entry}"
      if (entry!='.'&&entry!='..'&&entry!='.svn'&&entry!='tmp'&&File.directory?(newPath)) 
        result=true
      end
    end
  end
  result
end

dbh = Mysql2::Client.new(:host => "localhost", :username => "tgsuser", :database => "twistedgallery", :flags => Mysql2::Client::MULTI_STATEMENTS )

dirPath=File.expand_path('./SampleImages/');
basePath=File.expand_path('./');
categoryName=File.basename(dirPath)
parentID=1;

dbh.query("call addServer('TG Test Server','http://localhost:3306/','#{basePath}','t')")

result=dbh.query("call addCategory('#{categoryName}',#{parentID},null,'','','','','','',0)")
catID=result.first["LAST_INSERT_ID()"]
dbh.next_result

traverseCategories(catID,dirPath,dbh,basePath)
dbh.close
