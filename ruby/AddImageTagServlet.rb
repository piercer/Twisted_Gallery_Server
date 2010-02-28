#!/usr/bin/env ruby
#
#  Created by Conrad Winchester on 2007-02-06.
#  Copyright (c) 2007. All rights reserved.
#
require 'rubygems'
require 'webrick'
require 'mysql'
require 'cgi'
include WEBrick

class AddImageTagServlet < HTTPServlet::AbstractServlet

  def do_GET(request,response)
    response.status=200
    response["Content-Type"]='text/xml'
    response.body=getData(request.query['id'],request.query['tag'])
  end

  def getData(id,tag)
    begin

      dbh=Mysql.init
      dbh.query_with_result=false
      dbh.real_connect("127.0.0.1", "root", "", "fairweatherpunk",3306,nil,Mysql::CLIENT_MULTI_RESULTS)
      dbh.query("call addTagForItem(#{id},'#{tag}')")
      dbh.query("call getItemDetails(#{id})")

      data="<response type='imagedata'>\n<imagedata>\n"

      pictures   = dbh.use_result

      pictures.each do |row|
        
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

        data << "\t\t<image id='#{row[0]}'>\n"
        data << "\t\t\t<url><![CDATA[#{row[1]}]]></url>\n"
        data << "\t\t\t<thumb><![CDATA[#{row[2]}]]></thumb>\n"
        data << metaData
        data << tagData
        data << "\t\t</image>\n"
        
      end
      data << "</imagedata>\n</response>\n"

    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
#      dbh.close if dbh
    end
    
    data
    
  end
  
  alias :do_POST :do_GET

end
