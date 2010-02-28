#!/usr/bin/env ruby
#
#  Created by Conrad Winchester on 2007-02-06.
#  Copyright (c) 2007. All rights reserved.
#
require 'rubygems'
require 'webrick'
require 'cgi'

require 'db_handler.rb'

include WEBrick

class GetTagsServlet < HTTPServlet::AbstractServlet

  def do_GET(request,response)
    response.status=200
    response["Content-Type"]='text/xml'
    response.body=getData()
  end

  def getData()
    begin

      dbh=DBHandler.new
      tags=dbh.query("call getTags()")

      data="<response type='tagdata'>\n<tagdata>\n"

      tags.each do |row|

        data << "\t\t<tag id='#{row[0]}'>\n"
        data << "\t\t\t<name><![CDATA[#{row[1]}]]></name>\n"
        data << "\t\t\t<count>#{row[2]}</count>\n"
        data << "\t\t</tag>\n"

      end
      data << "</tagdata>\n</response>\n"
      tags.free

    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
      dbh.close if dbh
    end
    
    data
    
  end
  
  alias :do_POST :do_GET

end
