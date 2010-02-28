#!/usr/local/bin/ruby
#
#  Created by Conrad Winchester on 2007-02-06.
#  Copyright (c) 2007. All rights reserved.
#
require 'rubygems'
require 'webrick'
require 'CategoryServlet'
require 'CollectionServlet'
require 'ItemServlet'
require 'TagCollectionServlet'
require 'SearchCollectionServlet'
require 'AddImageTagServlet'
require 'LatestCollectionServlet'
require 'GetTagsServlet'

include WEBrick

s = HTTPServer.new( :Port => 3366, :MaxClients => 256)
# , :ServerType => WEBrick::Daemon )

s.mount('/',HTTPServlet::FileHandler, '.')
s.mount('/category',CategoryServlet)
s.mount('/collection',CollectionServlet)
s.mount('/item',ItemServlet)
s.mount('/preview',ItemServlet)
s.mount('/latest',LatestCollectionServlet)
s.mount('/tag',TagCollectionServlet)
s.mount('/search',SearchCollectionServlet)
s.mount('/addTagToImage',AddImageTagServlet)
s.mount('/tags',GetTagsServlet)

['TERM','INT'].each do |signal|
  trap(signal) { s.shutdown }
end

s.start
