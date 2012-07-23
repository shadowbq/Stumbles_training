require 'vr/vruby'
require 'vr/vrcontrol'
require 'vr/vrcomctl'
require 'vr/vrtwopane'
 
require 'nqxml/treeparser'
 
# The values of these constants were lifted from <winuser.h>
MB_OK              = 0x00000000
MB_ICONEXCLAMATION = 0x00000030
MB_ICONINFORMATION = 0x00000040
 
class XMLViewerForm < VRForm
 
  include VRMenuUseable
  include VRHorizTwoPane
 
  def construct
    # Set caption for application main window
    self.caption = "XML Viewer"
 
    # Create the menu bar
    @menu = newMenu()
    @menu.set([ ["&File", [ ["&Open...", "open"], ["Quit",  "quit"] ] ],
                ["&Help", [ ["About...", "about"] ] ]
              ])
    setMenu(@menu)
 
    # Tree view appears on the left
    addPanedControl(VRTreeview, "treeview", "")
 
    # List view appears on the right
    addPanedControl(VRListview, "listview", "")
    @listview.addColumn("Attribute Name", 150)
    @listview.addColumn("Attribute Value", 150)
  end
 
  def populateTreeList(docRootNode, treeRootItem)
    entity = docRootNode.entity
    if entity.instance_of?(NQXML::Tag)
      treeItem = @treeview.addItem(treeRootItem, entity.to_s)
      @entities[treeItem] = entity
      docRootNode.children.each do |node|
        populateTreeList(node, treeItem)
      end
    elsif entity.instance_of?(NQXML::Text) &&
          entity.to_s.strip.length != 0
      treeItem = @treeview.addItem(treeRootItem, entity.to_s)
      @entities[treeItem] = entity
    end
  end
 
  def loadDocument(filename)
    @document = nil
    begin
      @document = NQXML::TreeParser.new(File.new(filename)).document
    rescue NQXML::ParserError => ex
      messageBox("Couldn't parse XML document", "Error",
        MB_OK|MB_ICONEXCLAMATION)
    end
    if @document
      @treeview.clearItems()
      @entities = {}
      populateTreeList(@document.rootNode, @treeview.root)
    end
  end
 
  def open_clicked
    filters = [["All Files (*.*)", "*.*"],
               ["XML Documents (*.xml)", "*.xml"]]
    filename = openFilenameDialog(filters)
    loadDocument(filename) if filename
  end
 
  def quit_clicked
    exit
  end
 
  def about_clicked
    messageBox("VRuby XML Viewer Example", "About XMLView",
      MB_OK|MB_ICONINFORMATION)
  end
 
  def treeview_selchanged(hItem, lParam)
    entity = @entities[hItem]
    if entity and entity.kind_of?(NQXML::NamedAttributes)
      keys = entity.attrs.keys.sort
      @listview.clearItems
      keys.each_index { |row|
        @listview.addItem([ keys[row], entity.attrs[keys[row]] ])
      }
    end
  end
end
 
mainWindow = VRLocalScreen.newform(nil, nil, XMLViewerForm)
mainWindow.create
mainWindow.show
 
# Start the message loop
VRLocalScreen.messageloop