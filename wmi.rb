require 'win32ole'

puts "what is the computer name that you want to use??? "
cpuName = gets
cpuName.chomp!

mgmt = WIN32OLE.connect("winmgmts:\\\\#{cpuName}")
mgmt.InstancesOf("Win32_ComputerSystem") .each\
      { |item| puts item.name + "\n" + item.Manufacturer + " - " + item.Model}
mgmt.InstancesOf("Win32_SystemEnclosure").each{ |dev| puts dev.SerialNumber}
mgmt.InstancesOf("Win32_ComputerSystem") .each\
      {|item| puts item.AdminPasswordStatus}