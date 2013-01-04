require 'rubygems'
require 'nokogiri'

doc = Nokogiri::HTML(File.open('./bar.html')) do |config|
  config.nonet.noblanks.noerror.noent.nowarning
end

#puts doc.xpath("//td[@class='bar']").text.gsub("\n\n\n","\n\n")
puts doc.xpath("//p").text.gsub("\n\n\n","\n\n")