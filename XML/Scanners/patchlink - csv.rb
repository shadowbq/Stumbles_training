#!/usr/local/bin/ruby -w

require "csv"
csv = CSV::parse(File.open("full.csv", 'r') {|f| f.read })
fields = csv.shift
puts fields.size

#CSV::Reader.parse ( File.open('full.csv', 'rb') ) do |row|
#  row.each do |array|
#    puts array.size
#  end
#end
