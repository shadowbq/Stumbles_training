#!/usr/local/bin/ruby -w

require "rexml/document"
require 'rexml/xpath'

file = File.new( "full.xml" )
document = REXML::Document.new file
#REXML::XPath.each( document, "//Nodes/Node/NicCards") do |element|
#  element.elements.each { |child| puts child.attributes["IpAddress"] }
#  puts "\n"
#end

document.root.elements.each("Nodes/Node/NicCards/NIC") do |element|
  puts element.attributes["IpAddress"]
  puts "\n"
end

#parser = REXML::Parsers::SAX2Parser.new( File.new( 'full.xml' ) )
#elementNames = Array.new
#parser.listen( :start_element ) do |uri, localname, qname, attributes|
#  elementNames.push(localname)
#  elementNames.push(qname)
#  elementNames.uniq!
#end
#parser.parse
#puts elementNames

