module EXCEL_CONST
require 'win32ole'

   excel = WIN32OLE.new('Excel.Application')
   #WIN32OLE.const_load(excel, EXCEL_CONST)
   #puts EXCEL_CONST::XlTop # => -4160
   #puts EXCEL_CONST::CONSTANTS['_xlDialogChartSourceData'] # => 541

   WIN32OLE.const_load(excel)
   puts WIN32OLE::CONSTANTS['_xlDialogChartSourceData'] # 
   

  WIN32OLE.const_load(excel, EXCEL_CONST)
  puts EXCEL_CONST::XlXmlLoadImportToList
  puts EXCEL_CONST::XlCSVMSDOS
  
    #excel.workbooks.openxml({"Filename"=>"F:\test.xml", "LoadOption"=>"xlXmlLoadImportToList"})
   #book = excel.workbooks.add
   #sheet = book.worksheets(1)
   #sheet.setproperty('Cells', 1, 2, 10) # => The B1 cell value is 10.

#excel = WIN32OLE.new('Excel.Application')
#excel.visible = true
#book = excel.Workbooks.Add
#sheet1 = book.Worksheets(1)
#book.Worksheets.Add({'Before'=>sheet1, 'Count' => 2}) # ???Hash???
end