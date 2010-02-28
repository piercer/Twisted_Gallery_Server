#!/usr/bin/env ruby
#
#  Created by Conrad Winchester on 2007-02-06.
#  Copyright (c) 2007. All rights reserved.
#
require 'rubygems'
require 'webrick'
require 'mysql'
require 'cgi'

require 'db_handler.rb'

include WEBrick

class CollectionServlet < HTTPServlet::AbstractServlet

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
      details=dbh.query("call getCollectionItems(#{cid})")

      row=details.fetch_row()
      data="<response type='collection'>\n<collection id='#{cid}' num_pics='#{row[1]}'>\n"
      data << "\t<name><![CDATA[#{row[0]}]]></name>\n"
      
      details.free
      
      parents=dbh.next_result
      data << "\t<parents>\n"
      parents.each do |row| 
        data << "\t\t<parent id='#{row[0]}'>\n"
        data << "\t\t\t<name><![CDATA[#{row[1]}]]></name>\n"
        data << "\t\t</parent>\n"
      end
      data << "\t</parents>\n"

      items   = dbh.next_result
      data << "\t<items>\n"      
      items.each do |row|
        
        rawMeta=row[3]
        metaData=""
        if (rawMeta!=nil)
          metaData="\t\t\t<meta_data>\n"
          rawMeta.scan(/\{##(.*?)##(.*?)##\}/) do |name,value|
            metaData << "\t\t\t\t<meta>\n"
            metaData << "\t\t\t\t\t<name><![CDATA[#{name}]]></name>\n"
            metaData << "\t\t\t\t\t<value><![CDATA[#{value}]]></value>\n"
            metaData << "\t\t\t\t</meta>\n"
          end
          metaData << "\t\t\t</meta_data>\n"
        end

        rawTags=row[4]
        tagData=""
        if (rawTags!=nil)
          tagData="\t\t\t<tags>\n"
          rawTags.scan(/\{##(.*?)##\}/) { |name| tagData << "\t\t\t\t<tag><name><![CDATA[#{name}]]></name></tag>\n" }
          tagData << "\t\t\t</tags>\n"
        end

        data << "\t\t<item id='#{row[0]}'>\n"
        data << "\t\t\t<type>#{row[1]}</type>\n"
        data << "\t\t\t<server>#{row[2]}</server>\n"
        data << metaData
        data << tagData
        data << "\t\t</item>\n"
        
      end
      data << "\t</items>\n"
      data << "</collection>\n</response>\n"

    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
      dbh.close if dbh
    end
    
    data
    
  end
  
  def getDataForMeta(metaName,metaValue)
    begin
      
      dbh=DBHandler.new
      items=dbh.query("call getItemsWithMeta('#{metaName}','#{metaValue}')")

      data="<response type='collection'>\n<collection meta_name='#{metaName}' meta_value='#{metaValue}'>\n"
      
      data << "\t<items>\n"
      items.each do |row|
        
        rawMeta=row[3]
        metaData=""
        if (rawMeta!=nil)
          metaData="\t\t\t<meta_data>\n"
          rawMeta.scan(/\{##(.*?)##(.*?)##\}/) do |name,value|
            metaData << "\t\t\t\t<meta>\n"
            metaData << "\t\t\t\t\t<name><![CDATA[#{name}]]></name>\n"
            metaData << "\t\t\t\t\t<value><![CDATA[#{value}]]></value>\n"
            metaData << "\t\t\t\t</meta>\n"
          end
          metaData << "\t\t\t</meta_data>\n"
        end

        rawTags=row[4]
        tagData=""
        if (rawTags!=nil)
          tagData="\t\t\t<tags>\n"
          rawTags.scan(/\{##(.*?)##\}/) { |name| tagData << "\t\t\t\t<tag><name><![CDATA[#{name}]]></name></tag>\n" }
          tagData << "\t\t\t</tags>\n"
        end

        data << "\t\t<item id='#{row[0]}'>\n"
        data << "\t\t\t<type>#{row[1]}</type>\n"
        data << "\t\t\t<server>#{row[2]}</server>\n"
        data << metaData
        data << tagData
        data << "\t\t</item>\n"
        
      end
      data << "\t</items>\n"
      data << "</collection>\n</response>\n"

    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
      dbh.close if dbh
    end
    
    data
    
  end  
  
  alias :do_POST :do_GET

end
