#
#  Created by Conrad Winchester on 2007-02-06.
#  Copyright (c) 2007. All rights reserved.
#
# Deals with 
#   /category/n
#   /category/where/meta_name/meta_value
#
require 'rubygems'
require 'webrick'
require 'cgi'

require 'db_handler.rb'

include WEBrick

class CategoryServlet < HTTPServlet::AbstractServlet

  def do_GET(request,response)
    
    id=/(\d+)$/.match(request.path)
    meta=/where\/(.+)\/(.+)$/.match(request.path)
    if id and !meta
      response.status=200
      response["Content-Type"]='text/xml'
      response.body=getData(id[1])
    elsif meta
      response.status=200
      response["Content-Type"]='text/xml'
      metaName=meta[1]
      metaValue=meta[2]
      response.body=getDataForMeta(metaName,metaValue)
    else
      response.status=400
    end
    
  end

  def getData(cid)
    begin
    
      dbh=DBHandler.new
      parents=dbh.query("call getCategoryDetails(#{cid})")

      data="<response type='category'>\n<category id='#{cid}'>\n"

      data << "\t<parents>\n"
      parents.each do |row| 
        data << "\t\t<parent id='#{row[0]}'>\n"
        data << "\t\t\t<name><![CDATA[#{row[1]}]]></name>\n"
        data << "\t\t</parent>\n"
      end
      data << "\t</parents>\n"

      children=dbh.next_result

      data << "\t<children>\n"
      children.each do |row| 
        data << "\t\t<child type='category' id='#{row[0]}' num_gal='#{row[3]}' num_pic='#{row[4]}'>\n"
        data << "\t\t\t<name><![CDATA[#{row[1]}]]></name>\n"
  			data << "\t\t\t<description><![CDATA[#{row[2]}]]></description>\n"
  			data << "\t\t\t<preview id='#{row[6]}'>\n"
  			data << "\t\t\t\t<base><![CDATA[#{row[5]}]]></base>\n"
  			data << "\t\t\t\t<type><![CDATA[#{row[7]}]]></type>\n"
  			data << "\t\t\t</preview>\n"
        data << "\t\t</child>\n"
  		end
  		
    	galleries = dbh.next_result
    	 
      galleries.each do |row|
        data << "\t\t<child type='collection' id='#{row[0]}' num_pic='#{row[2]}'>\n"
        data << "\t\t\t<name><![CDATA[#{row[1]}]]></name>\n"
  			data << "\t\t\t<preview id='#{row[4]}'>\n"
  			data << "\t\t\t\t<base><![CDATA[#{row[3]}]]></base>\n"
  			data << "\t\t\t\t<type><![CDATA[#{row[5]}]]></type>\n"
  			data << "\t\t\t</preview>\n"
        data << "\t\t</child>\n"
      end
      data << "\t</children>\n"

      data << "</category>\n</response>"

      dbh.clear

    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
      dbh.close if dbh
    end
    
    data
    
  end

  def getDataForMeta(metaName,metaValue)
    begin
    
      puts "Getting category where '#{metaName}'='#{metaValue}'"
    
      dbh=DBHandler.new
      collections=dbh.query("call getCollectionsWithMeta('#{metaName}','#{metaValue}')")

      data="<response type='category'>\n<category meta_name='#{metaName}' meta_value='#{metaValue}'>\n"

      data << "\t<children>\n"
      collections.each do |row|
        data << "\t\t<child type='collection' id='#{row[0]}' num_pic='#{row[2]}'>\n"
        data << "\t\t\t<name><![CDATA[#{row[1]}]]></name>\n"
        data << "\t\t\t<preview id='#{row[4]}'>\n"
        data << "\t\t\t\t<base><![CDATA[#{row[3]}]]></base>\n"
        data << "\t\t\t\t<type><![CDATA[#{row[5]}]]></type>\n"
        data << "\t\t\t</preview>\n"
        data << "\t\t</child>\n"
      end
      data << "\t</children>\n"

      data << "</category>\n</response>"

    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
      dbh.close if dbh
    end
    
    data
    
  end


end
