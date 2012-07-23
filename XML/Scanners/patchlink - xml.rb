#!/usr/local/bin/ruby -w

require "rexml/document"
file = File.new( "full.xml" )
document = REXML::Document.new file
document.root.elements.each do |element|
  puts element.name
end

#cves = Array.new
#puts host.attributes["hostname"]
#host.elements.each("port/alert") do |alert|
#  alert.elements.each("desc") do |description|
#    if description.text.match(/CVE-\d{4}-\d{4}/)
#      #puts $&
#      cves.push($&)
#    end
#  end
#end
#puts cves.uniq.sort
#puts "\n"
