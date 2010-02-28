#
#  Created by Conrad Winchester on 2007-02-06.
#  Copyright (c) 2007. All rights reserved.
#
#require 'rubygems'
require 'webrick'
require 'mysql'
require 'cgi'
require 'RMagick'

require 'db_handler.rb'

include WEBrick
include Magick

class ItemServlet < HTTPServlet::AbstractServlet

  def do_GET(request,response)
    
    type=/^\/(.*?)\//.match(request.path)[1]
    preview=(type=='preview')
  
    if (preview)
      id=/(\d+)\/(.*?)$/.match(request.path)
      data=/(\d+)X(\d+)/.match(id[2])
      width=data[1].to_i
      height=data[2].to_i
    else
      id=/(\d+)$/.match(request.path)
    end
    
    if (!id)
      response.status=400
    else
      item=getItem(id[1])
      if (preview)
        scaleX=1;
        scaleY=1;
        scaleX=width.to_f/item.columns if (item.columns>width)
  			scaleY=height.to_f/item.rows if (item.rows>height)
  			scale=scaleY;
  			scale=scaleX if (scaleX<scaleY)
        item=item.thumbnail!(scale)
      end
      response.status=200
      response["Content-Type"]='image/jpeg'
      response.body=item.to_blob
    end

  end

  def getItem(cid)
    begin
  
      img=nil
      
      dbh=DBHandler.new
      item=dbh.query("call getItemDetails(#{cid})")

      item.each do |row|
        file=row[1]
        img=Magick::Image.read('/Volumes/Backups/www/galleries/'+file).first
      end
      img
      
    rescue Mysql::Error => e
      data << "Error: #{e.errstr}"
    ensure
      dbh.close if dbh
    end
    
  end

end
