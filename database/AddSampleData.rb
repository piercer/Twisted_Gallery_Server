#
#  Created by Conrad on 2007-09-12.
#  Copyright (c) 2007. All rights reserved.
#
require 'rubygems'
require 'mysql'
require 'exifr'

def clearResults(dbh)
  more_results=true;
  begin
    while more_results
      rs=dbh.use_result
      rs.each { |row| }
      dbh.next_result
    end
  rescue Mysql::Error => e
    more_results=false
  end
end

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
          dbh.query("call addCategory('#{entry}',#{parentID},null,'','','','','','')")
          result=dbh.use_result
          catID=result.fetch_row()[0]
          result.free
          dbh.next_result
          traverseCategories(catID,newPath,dbh,baseDir)
        else
          dbh.query("call addCollection(#{parentID},now(),'#{entry}')")
          result=dbh.use_result
          colID=result.fetch_row()[0]
          result.free
          dbh.next_result
          Dir.chdir(newPath)
          images=Dir.glob("*.{jpg,jpeg}")
          relativePath=/#{baseDir}(.*)/.match(newPath)[1]
          isPreview=1;
          images.each do |image|
            exif=EXIFR::JPEG.new("#{newPath}/#{image}")
            if exif.exif?
              edate=exif.date_time.to_s
              data=/... (...) (..) (..:..:..) ..... (....)/.match(edate)
              itemDate="#{data[4]}-#{months[data[1]]}-#{data[2]} #{data[3]}"
            else
              itemDate=nil
            end
            dbh.query("call addCollectionItem(#{colID},1,'#{itemDate}',null,'image/jpeg','#{relativePath}/#{image}',#{isPreview})")
            result=dbh.use_result
            itemID=result.fetch_row()[0]
            result.free
            dbh.next_result
            if exif.exif?
              dbh.query("call addMetaForItem(#{itemID},'Camera','#{exif.model}')")
              clearResults(dbh)
              dbh.query("call addMetaForItem(#{itemID},'Exposure','#{exif.exposure_time.to_s}')")
              clearResults(dbh)
              dbh.query("call addMetaForItem(#{itemID},'Focal Length','#{exif.focal_length.to_f}mm')")
              clearResults(dbh)
              dbh.query("call addMetaForItem(#{itemID},'Aperture','f#{exif.f_number.to_f}')")
              clearResults(dbh)
              dbh.query("call addMetaForItem(#{itemID},'Width','#{exif.height}')")
              clearResults(dbh)
              dbh.query("call addMetaForItem(#{itemID},'Height','#{exif.width}')")
              clearResults(dbh)
            end
            isPreview=0
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

dbh=Mysql.init
dbh.query_with_result=false
dbh.real_connect("127.0.0.1", "root", "valium10", "fairweatherpunk",3306,nil,Mysql::CLIENT_MULTI_RESULTS)

dirPath=File.expand_path('./SampleImages/');
basePath=File.expand_path('./');
categoryName=File.basename(dirPath)
parentID=1;

dbh.query("call addServer('FWP Test Server','http://localhost:3306/','#{basePath}','t')")

dbh.query("call addCategory('#{categoryName}',#{parentID},null,'','','','','','')")
result=dbh.use_result
catID=result.fetch_row()[0]
result.free
dbh.next_result

traverseCategories(catID,dirPath,dbh,basePath)
dbh.close
