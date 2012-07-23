#!/usr/local/bin/ruby -w

require "rexml/document"
file = File.new( "nessus-09.14.07-cred_full.xml" )
document = REXML::Document.new file



#cves = Array.new
#REXML::XPath.each( document, "//desc") do |description|
#  description.text.scan(/CVE-\d{4}-\d{4}/) do |match|
#    cves.push(match.to_s)
#  end
#end
#puts cves.uniq.sort

# get unique CVEs by host
document.root.elements.each("host") do |host|
  cves = Array.new
  puts host.attributes["hostname"]
  host.elements.each("port/alert") do |alert|
    alert.elements.each("desc") do |description|
      description.text.scan(/CVE-\d{4}-\d{4}/) do |match|
        cves.push(match.to_s)
      end
    end
  end
  puts cves.uniq.sort
  puts "\n"
end

# the lonely kids...
# (this is a cheap hack to get this to work for one host right now)
document.root.elements.each("host/general") do |general|
  cves = Array.new
  general.elements.each("alert") do |alert|
    alert.elements.each("desc") do |description|
      description.text.scan(/CVE-\d{4}-\d{4}/) do |match|
        cves.push(match.to_s)
      end
    end
  end
  puts cves.uniq.sort
  puts "\n"
end
