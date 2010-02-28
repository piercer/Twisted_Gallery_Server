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

class LatestCollectionServlet < HTTPServlet::AbstractServlet

  def do_GET(request,response)
 
    n=/(\d+)$/.match(request.path)
    n=n[1].to_i|10
    n=50 unless n<50
    response.status=200
    response["Content-Type"]='text/xml'
    response.body=getData(n)
    
  end

  def getData(n)
    begin

      dbh=DBHandler.new
      collections=dbh.query("SELECT c.id, c.name, ca.name, c.num_items, s.base_url, i.id, t.name FROM fwp_collections c, fwp_items i, fwp_servers s, fwp_item_types t,fwp_categories ca WHERE c.preview=i.id AND i.type=t.id AND s.id=i.server_id AND ca.id=c.category_id ORDER BY c.col_date DESC LIMIT #{n}")

      data="<response type='category'>\n<category type='latest'>\n"
      data << "\t<children>\n"
      
      collections.each do |row|
        data << "\t\t<child type='collection' id='#{row[0]}' num_pic='#{row[3]}'>\n"
        data << "\t\t\t<name><![CDATA[#{row[1]}]]></name>\n"
        data << "\t\t\t<category><![CDATA[#{row[2]}]]></category>\n"
        data << "\t\t\t<preview id='#{row[5]}'>\n"
        data << "\t\t\t\t<base><![CDATA[#{row[4]}]]></base>\n"
        data << "\t\t\t\t<type><![CDATA[#{row[6]}]]></type>\n"
        data << "\t\t\t</preview>\n"
        data << "\t\t</child>\n"
      end      
      data << "\t</children>\n"
      data << "</category>\n</response>\n"

    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
      dbh.close if dbh
    end
    
    data
    
  end
  
  alias :do_POST :do_GET

end
