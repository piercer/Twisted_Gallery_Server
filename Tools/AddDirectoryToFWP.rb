#!/usr/bin/ruby
require 'mysql'

def traverseCategories(parentID,dir,dbh)
  Dir.foreach(dir) do |entry|
    if (entry!='.'&&entry!='..')
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
          traverseCategories(catID,newPath,dbh)
        else
          dbh.query("call addCollection(#{parentID},'#{entry}')")
          result=dbh.use_result
          colID=result.fetch_row()[0]
          result.free
          dbh.next_result
          Dir.chdir(newPath)
          images=Dir.glob("*.{jpg,jpeg}")
          images.each do |image|
            dbh.query("call addCollectionItem(#{colID},1,null,'#{newPath}/#{image}','#{newPath}/#{image}')")
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
      if (entry!='.'&&entry!='..'&&File.directory?(newPath)) 
        result=true
      end
    end
  end
  result
end

dbh=Mysql.init
dbh.query_with_result=false
dbh.real_connect("127.0.0.1", "root", "", "fairweatherpunk",3306,nil,Mysql::CLIENT_MULTI_RESULTS)

dirPath=File.expand_path('/users/conrad/Pictures/');
categoryName=File.basename(dirPath)
parentID=1;
dbh.query("call addCategory('#{categoryName}',#{parentID},null,'','','','','','')")
result=dbh.use_result
catID=result.fetch_row()[0]
result.free
dbh.next_result
traverseCategories(catID,dirPath,dbh)
dbh.close
