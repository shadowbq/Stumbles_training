=begin
require 'fox16'

include Fox

application = FXApp.new("Hello", "FoxTest")
main = FXMainWindow.new(application, "Hello", nil, nil, DECOR_ALL)
FXButton.new(main, "&Hello, World!", nil, application, FXApp::ID_QUIT)
application.create()
main.show(PLACEMENT_SCREEN)
application.run()
=end
require 'fox16'

include Fox

theApp = FXApp.new

theMainWindow = FXMainWindow.new(theApp, "Hello")
theButton = FXButton.new(theMainWindow, "Hello, World!")
theButton.connect(SEL_COMMAND) do |sender, selector, data|
  exit
end
theButton.tipText = "Push Me!"

FXToolTip.new(theApp)
theApp.create

theMainWindow.show(PLACEMENT_SCREEN)

theApp.run