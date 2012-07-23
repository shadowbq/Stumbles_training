#
# xml_to_csv (ruby 1.8)
#
# - XML to CSV file transformation via windows32 ole and excel api controls
#
require 'win32ole'
require 'optparse'

version = "1.0.1"
safe=false

opts = OptionParser.new do |opts|
  opts.banner = "Usage: xml_to_csv.rb [options] "
  
  opts.on("-x", "--xml VAL", "XML input file to convert.")    {|XML_IN|}
  opts.on("-c", "--csv VAL", "CSV output file to saveas..")  {|CSV_OUT|}
  opts.on("-s", "--[no-]safe", "Enable or disable file overwrite.", "default: (disabled)") {|value| safe = value}
  opts.separator "Common options:"
  opts.on_tail("-h", "-?", "--help", "Show this message") {puts opts; exit}
  opts.on_tail("--version", "Show version") {puts "xml_to_csv.rb - version: " + version; exit}
  opts.parse!
end 

def exists?(symbol)
  eval "#{symbol}"
rescue
  false
end

unless exists? :XML_IN
  print "XML input File: "
  XML_IN = STDIN.gets.chomp
end

unless exists? :CSV_OUT
  print "CSV output File: "
  CSV_OUT = STDIN.gets.chomp
end

def xml_to_csv(in_file, out_file,safe)
  excel = WIN32OLE.new('Excel.Application')
     # excel['Visible'] = true
     excel.workbooks.openxml({'Filename'=>in_file, 'LoadOption'=>2})
     if not safe
      excel.DisplayAlerts = 0  #Hide last warning message
     end 
     excel.ActiveWorkbook.SaveAs({'Filename'=>out_file, 'FileFormat'=>24, 'CreateBackup'=>'False'})
     excel.DisplayAlerts = 0
     excel.Quit
end

xml_to_csv(XML_IN,CSV_OUT, safe)
