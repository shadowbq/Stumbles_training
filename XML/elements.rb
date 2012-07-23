#!/usr/local/bin/ruby -w

# prints a list of all the unique elements in an XML document

require 'rexml/parsers/sax2parser'
parser = REXML::Parsers::SAX2Parser.new( File.new( 'full.xml' ) )

elementNames = Array.new
parser.listen( :start_element ) do |uri, localname, qname, attributes|
  elementNames.push(localname)
  elementNames.push(qname)
  elementNames.uniq!
end
parser.parse
puts elementNames
