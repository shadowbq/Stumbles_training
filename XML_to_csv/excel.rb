require 'win32ole'
require 'optparse'

opts = OptionParser.new
opts.banner = "Usage: excel.rb [options]"

opts.on("-x", "--xml VAL", "XML input file to convert")    {|val| puts "-x #{val}" }
opts.on("-c", "--csv VAL", "CSV output file to saveas..")    {|val| puts "-c #{val}" }
opts.separator "Common options:"
opts.on_tail("-h", "--help", "Show this message") do
  puts opts
  exit
end
opts.on_tail("--version", "Show version") do
  puts OptionParser::Version.join('.')
  exit
end

#my_argv = [ "--xml","1234", "-c", "fred", "wilma" ]
rest = opts.parse(*ARGV)
#puts "Remainder = #{rest.join(', ')}"
#puts opts.to_s
=begin
def xml_to_csv(in_file, out_file)
  excel = WIN32OLE.new('Excel.Application')
     # excel['Visible'] = true
     excel.workbooks.openxml({'Filename'=>in_file, 'LoadOption'=>2})
     excel.DisplayAlerts = 0  #Hide last warning message
     excel.ActiveWorkbook.SaveAs({'Filename'=>out_file, 'FileFormat'=>24, 'CreateBackup'=>'False'})
     excel.Quit

end
xml_to_csv(*ARGV)
=end