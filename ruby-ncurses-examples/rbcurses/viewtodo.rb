require 'logger'
require 'rbcurse'
require 'rbcurse/core/widgets/rcombo'
require 'rbcurse/extras/widgets/rtable'
require 'rbcurse/extras/include/tableextended' 
require 'rbcurse/core/widgets/keylabelprinter'
require 'rbcurse/core/widgets/applicationheader'
require 'rbcurse/core/include/action'
require 'rbcurse/extras/widgets/rcomboedit'
require 'sqlite3'


class Array

  def insert_blank
    self.insert(0,"")
  end

end

class Table
  # so we can increase and decrease column width using keys
  include TableExtended
end

module ViewTodo
  class TodoList
    
    attr_accessor :sortfield
    
    def initialize(file)
      @sortfield = "Sno"
      @file = file
      @db = SQLite3::Database.new(@file)
    end
    
    
    def statuses(addblank=false)
      c = fetch("SELECT DISTINCT Status FROM todo")
      c.flatten!
      c.insert_blank if addblank
      return c
    end
    
    def modules(addblank=false)
      c = fetch("SELECT DISTINCT Module FROM todo")
      c.flatten!
      c.insert_blank if addblank
      return c
    end
    
    def categories(addblank=false)
      c = fetch("SELECT DISTINCT Category FROM todo")
      c.flatten!
      c.insert_blank if addblank
      return c
    end
    
    def columns(addblank=false)
      c = %w[Sno Category Module Priority Task Status Timestamp]
      c.insert_blank if addblank
      return c
    end
    
    def records(categ="%")
      fetch("select * from todo where Category like '#{categ}' order by #{@sortfield} asc ")
    end
    
    def delete(sno)
      fetch("delete from todo where Sno = '#{sno}' ")
    end
    
    def set_tasks_for_category(categ, data)
      d = {}
      data.each do |row|
        #key = row.delete_at 0
        key = row.first
        d[key] ||= []
        d[key] << row[1..-1]
      end
      @todomap[categ]=d
      $log.debug " NEW DATA #{categ}: #{data}"
    end
    
    def dump
      f = "#{@file}"
      self.to_text
    end
    
    private
    
    def fetch command
      @columns, *rows = @db.execute2(command)
      @content = rows
      return nil if @content.nil? or @content[0].nil?
      @datatypes = @content[0].types #if @datatypes.nil?
      @command = command
      return @content
    end
    
    def to_text
      d = []
      self.categories.each do |categ|
        records(categ).each do |record|
          n = record.dup
          n.insert 0, categ
          d << n
        end
      end
      return d
    end
    
  end # class
  
  class TodoApp
    
    def initialize
      @window = VER::Window.root_window
      @form = Form.new @window
      @sort_dir = true
      @todo = ViewTodo::TodoList.new "todo.db"
    end
    
    def run
      #Non Lazy Initiation of todo
      todo = @todo
      
      title = "TODO APP"
      @header = ApplicationHeader.new(@form, title, {:text2=>"Some Text", :text_center=>"Task View"})

      #Non Lazy Initiation of status_row
      status_row = RubyCurses::Label.new(@form, {'text' => "", :row => Ncurses.LINES-4, :col => 0, :display_length=>60})
      @status_row = status_row
      
      # setting ENTER across all objects on a form
      @form.bind(:ENTER) {|f| status_row.text = f.help_text unless f.help_text.nil? }
      
      #@window.printstring 0,(Ncurses.COLS-title.length)/2,title, $datacolor
      
      #Setting Default Dimensions for Row/Column Positions
      r = 1
      c = 1
      table_height = 18 # -3 for visble_rows
      table_width = Ncurses.COLS-5 #110
            
      button_row = Ncurses.LINES-5 # Set Up Lines from the Bottom
      
      # Category:
      categ = ComboBoxEdit.new @form do
        name "categ"
        row r
        col 15
        display_length 10
        editable false
        list todo.categories(true)
        list_config 'color' => 'black', 'bgcolor'=>'magenta', 'max_visible_items' => 7
        set_label Label.new @form, {'text' => "Category:", 'color'=>'cyan','col'=>1, "mnemonic"=>"a"}
        #list_config 'height' => 4
        help_text "Select a category <SPACE> and <TAB> out. KEY_UP, KEY_DOWN, M-Down" 
      end
      
      # Filter on:
      col_combo = ComboBoxEdit.new @form do
        name "col_combo"
        row r
        col 45
        display_length 15
        editable false
        list todo.columns(true)
        list_config 'color' => 'black', 'bgcolor'=>'magenta', 'max_visible_items' => 7
        set_label Label.new @form, {'text' => "Filter on:", 'color'=>'cyan',"mnemonic"=>"F"}
        help_text "Select a column field to filter on"
      end
      
      #Pattern:
      col_value = Field.new @form do
        name "col_value"
        row r+1
        col 45
        bgcolor 'cyan'
        color 'white'
        display_length 15
        set_label Label.new @form, {'text' => "Pattern:", 'color'=>'cyan',:bgcolor => 'black',"mnemonic"=>"P"}
        help_text "Pattern/Regex filter"
      end
      
      # [Filter]
      b_filter = Button.new @form do
        text "Fi&lter"
        row r
        col 70
        help_text "Filter on selected filter column and value"
        #bind(:ENTER) { status_row.text "New button adds a new row below current " }
      end
      
      # Sort on:
      sort_combo = ComboBoxEdit.new @form do
        name "sort_combo"
        row r
        col 92
        display_length 15
        editable false
        list todo.columns(true)
        list_config 'color' => 'black', 'bgcolor'=>'magenta', 'max_visible_items' => 7
        set_label Label.new @form, {'text' => "Sort on:", 'color'=>'cyan',"mnemonic"=>"S"}
        #list_config 'height' => 7
        help_text "Select a column field to sort on"
      end
      
      
      ## PRESET FILTER of TODO
      data = todo.records
      @data = data
      
      atable = Table.new @form do
        name   "tasktable" 
        row  r+2
        col  c
        width table_width
        height table_height
        #show_selector true
        selected_color :green
        selected_bgcolor :blue
        #title "A Table"
        #title_attrib (Ncurses::A_REVERSE | Ncurses::A_BOLD)
        cell_editing_allowed false
        set_data data, todo.columns
      end
      
      @atable = atable
      ########################################################################
      # Table Column Model 
      # column widths 
      ########################################################################
      
      tcm = atable.get_table_column_model
      
      if Ncurses.COLS < 110 then  
        
        tcm.column(0).width 3
        tcm.column(1).width 8
        tcm.column(2).width 8
        tcm.column(3).width 5
        tcm.column(4).width 50
        tcm.column(5).width 8
        tcm.column(6).width 20
      else
        # Hard Coded Columns
        hc_columns = 3 + 8 + 8 + 8 + 8 + 20
        tcm.column(0).width 3 # SNO
        tcm.column(1).width 8 # Category
        tcm.column(2).width 8 # Module
        tcm.column(3).width 8 # Priority
        tcm.column(4).width Ncurses.COLS - 15 - hc_columns # Task
        tcm.column(5).width 8 # Status
        tcm.column(6).width 20 # Timestamp
      end
      
      
      ########################################################################
      ## NCurses Command Bindings (callbacks)
      ########################################################################
      
      #Runs if a Changed state is observered in Category pulldown
      categ.bind(:CHANGED) do |category_field| 
        $log.debug "Category Selection Changed."
        data = todo.records(category_field.selected_item)
        @data = data
        atable.table_model.data = data
      end
      
      #Runs if a Sort is selected
      sort_combo.bind(:CHANGED) do |sort_field| 
        filter_reset = ""
        todo.sortfield = sort_field.selected_item
        
        #Still figuring out Filter Resets
        if data.size < todo.records.size
          filter_reset = "(Filter Reset Required)"
        end
        
        data = todo.records
        @data = data
        atable.table_model.data = data
        
        status_row.text "Sorted on #{sort_field.selected_item}. #{filter_reset}"
      end
      
      #Runs if a filter is populated
      b_filter.command { 
        filter_reset = ""
        if data.nil? or data.size == 0
          data = todo.records
          filter_reset = "(Filter Reset Required)"
        end
        
        
        # REFACTOR - This should be a SQL Match not a string REGEX 
        d = data.select {|row| row[col_combo.selected_index-1].to_s.match(col_value.getvalue) }

        if  d.nil? or d.size == 0
          atable.table_model.data = [[nil, nil, nil, nil,nil, nil, nil]]
        else
          atable.table_model.data = d
        end

        status_row.text "Filter returned #{d.size} records. #{filter_reset}"
      }
      
      ########################################################################
      ## NCurses Command Key Bindings (callbacks)
      ########################################################################

      # Non Lazy Initiation of Self
      app = self
      
      ## Key bindings for atable
      atable.configure() do

        bind_key(?+) {
          atable.increase_column
        }
        bind_key(?-) {
          atable.decrease_column
        }
        bind_key(?{) {
          atable.goto_top
        }
        bind_key(?}) {
          atable.goto_bottom
        }
        bind_key(?[) {
          atable.scroll_backward
        }
        bind_key(?]) {
          atable.scroll_forward
        }
        
        bind_key(?|) {
          atable.scroll_forward
        }
        
        bind_key(?:, app) {|ncursetable,todoapp| 
          app.show_email(ncursetable,todoapp)
        }

        bind_key(?>) {
          colcount = tcm.column_count-1
          #atable.move_column sel_col.value, sel_col.value+1 unless sel_col.value == colcount
          col = atable.focussed_col
          atable.move_column col, col+1 unless col == colcount
        }
        
        bind_key(?<) {
          col = atable.focussed_col
          atable.move_column col, col-1 unless col == 0
          #atable.move_column sel_col.value, sel_col.value-1 unless sel_col.value == 0
        }
        
        bind_key(?\\, app) {|ncursetable, todoapp| 
          $log.debug " BIND... #{ncursetable.class}, #{todoapp.class}" 
          app.make_popup atable
        }
        
      end

      atable.bind(:TABLE_TRAVERSAL_EVENT){|e| @header.text_right "Row #{e.newrow+1} of #{atable.row_count}" }
      
      create_table_actions atable, todo, data, categ.getvalue
      ## We use Action to create a button: to test out ampersand with MI and Button
      new_act = @new_act

      
      ########################################################################
      ## Print Bottom Key Labels 
      ########################################################################
      
      @klp = RubyCurses::KeyLabelPrinter.new(@form, app_key_labels)
      @klp.set_key_labels(table_key_labels, :table)
      
      atable.bind(:ENTER){ 
        @klp.mode :table 
      }
      atable.bind(:LEAVE){ 
        @klp.mode :normal 
      }

      ########################################################################
      ##  Begin NCURSES Watch Program Loop
      ########################################################################
      
      @form.repaint
      @window.wrefresh
      
      Ncurses::Panel.update_panels
      begin
        while((ch = @window.getchar()) != ?\C-q.getbyte(0) )
          colcount = tcm.column_count-1
          s = keycode_tos ch
          #status_row.text = "Pressed #{ch} , #{s}"
          @form.handle_key(ch)

          @form.repaint
          @window.wrefresh
        end
      ensure
        @window.destroy if !@window.nil?
      end
      ########################################################################
      # End NCURSES Watch Program Loop
      ########################################################################
      
    end
    
    def make_popup(table)
      require 'rbcurse/extras/widgets/rpopupmenu'
      tablemenu = RubyCurses::PopupMenu.new "Table"
      
      tablemenu.add(item = RubyCurses::PMenuItem.new("&Open"))
      item.command() { @open_cmd.call }
      
      tablemenu.insert_separator 1
      
      #tablemenu.add(RubyCurses::PMenuItem.new "New",'N')
      tablemenu.add(@new_act)
      
      tablemenu.add(item = RubyCurses::PMenuItem.new("&Save"))
      item.command() { @save_cmd.call }

      item=RubyCurses::PMenuItem.new "S&elect"
      item.accelerator = "Space"
      item.command() { table.toggle_row_selection() }
      #item.enabled = false
      tablemenu.add(item)

      item=RubyCurses::PMenuItem.new "&Clr Selection"
      item.accelerator = "Alt-e"
      item.command() { table.clear_selection() }
      item.enabled = table.selected_row_count > 0 ? true : false
      tablemenu.add(item)

      item=RubyCurses::PMenuItem.new "&Delete"
      item.accelerator = "Alt-D"
      item.command() { @del_cmd.call }
      tablemenu.add(item)

      gotomenu = RubyCurses::PMenu.new "&Goto"

        item = RubyCurses::PMenuItem.new "Top"
        item.accelerator = "["
        item.command() { table.goto_top }
        gotomenu.add(item)

        item = RubyCurses::PMenuItem.new "Bottom"
        item.accelerator = "]"
        item.command() { table.goto_bottom }
        gotomenu.add(item)

        item = RubyCurses::PMenuItem.new "Prev Page"
        item.accelerator = "{"
        item.command() { table.scroll_forward }
        gotomenu.add(item)

        item = RubyCurses::PMenuItem.new "Next Page"
        item.accelerator = "}"
        item.command() { table.scroll_backward }
        gotomenu.add(item)

      tablemenu.add(gotomenu)

      tablemenu.show @atable, 0,1
    end
    
    def show_email(tab,td)
      #w = arr.max_by(&:length).length
      vh = FFI::NCurses.LINES - 10
      vw = FFI::NCurses.COLS - 20

      require 'rbcurse/core/util/viewer'
      
      arr = []
      arr << ""
      arr << "Serial Number: #{tab.get_value_at(tab.focussed_row,0)}"
      arr << "Status: #{tab.get_value_at(tab.focussed_row,5)}"
      arr << "Date Time Stamp: #{tab.get_value_at(tab.focussed_row,6)}"
      arr << ""
      arr << "Category: #{tab.get_value_at(tab.focussed_row,1)} \t\t Module:#{tab.get_value_at(tab.focussed_row,2)}"
      arr << ""
      arr << "Priority: #{tab.get_value_at(tab.focussed_row,3)}"
      arr << ""
      arr << "Task: #{tab.get_value_at(tab.focussed_row,4)}"
      arr << ""
      arr << " -- HOTKEYS -- "
      arr << " q | F10 -  Close View "
      if DEBUG
        arr << ""
        arr << " --- DEBUG MENU -------------------------------------------"
        arr << " BIND... #{tab.class}, #{td.class}" 
        arr << " Selected Row: #{tab.selected_row}"
        arr << " Focused Row:  #{tab.focussed_row}"
      end
      defarr = arr
      
      RubyCurses::Viewer.view(arr, :layout => [2, 4, vh, vw],:close_key => KEY_F10, :title => "[ Show Task ]", :print_footer => true) do |t|
        # you may configure textview further here.
        #t.suppress_borders true
        t.color = :black
        t.bgcolor = :white

        # help was provided, so default help is provided in second buffer
        t.add_content defarr, :title => ' Current Task '
        
      end
    end
    
    private
    
    ########################################################################
    ## NCurses Additional Dynamic Callbacks
    ########################################################################
    
    # Adding was done in testtodo.rb. this is view only
    def create_table_actions atable, todo, data, categ
      
      #@new_act = Action.new("New Row", "mnemonic"=>"N") { 
      @new_act = Action.new("&New Row") { 
        cc = atable.get_table_column_model.column_count
        if atable.row_count < 1
          categ = nil
          frow = 0
        else
          frow = atable.focussed_row
          categ = atable.get_value_at(frow,1)
          frow += 1
        end
        tmp = [nil, categ, "",  5, "", "TODO", Time.now]
        tm = atable.table_model
        tm.insert frow, tmp
        atable.set_focus_on frow
        @status_row.text = "Added a row. Please press Save before changing Category."
        alert("Added a row below current one. Use C-k to clear task.")
      }
      @new_act.accelerator "Alt-N"
      
      
      #refactor - Add a SQL insertion
      @save_cmd = lambda {
        todo.set_tasks_for_category categ, data
        todo.dump
      }
      
      #refactor - Add a SQL insertion
      @open_cmd = lambda {
        show_email(atable,todo)
      }
      
      #refactor - Currently just removes view of row, not database entry
      @del_cmd = lambda { 
        row = atable.focussed_row
        sno = atable.get_value_at(row,0)
        answer = confirm("Do your really want to delete id #{sno}?")
        if answer == true
          tm = atable.table_model
          todo.delete(sno)
          tm.delete_at row
          @status_row.text = "Delete #{sno} completed."
        else
          @status_row.text = "Delete cancelled."
        end
      }

    end
    

    
    def app_key_labels
      key_labels = [
        ['C-q', 'Exit'], nil,
        ['C-a', 'Category'], nil,
        ['M-f', 'Filter Field'], ['M-p', 'Pattern'],
        ['M-s', 'Sort'], ['M-i', 'Filter']
      ]
      return key_labels
    end
    
    def table_key_labels
      key_labels = [
        #['M-n','NewRow'], ['M-d','DelRow'],
        ['Space','Select'], ['\\', 'Popup Menu'],
        ['{', 'Top'], ['}', 'End'],
        ['[', 'Pg Up'], [']', 'Pg Down'],
        ['<', 'Move Column'], ['>', 'Move Column'],
        ['M-Tab','Next Field'], ['Tab','Next Column'],
        ['+','Widen'], ['-','Narrow']
      ]
      return key_labels
    end
  end
end # module

# Main Execution Loop

if $0 == __FILE__
  
  DEBUG = FALSE
  include RubyCurses
  include RubyCurses::Utils

  begin
    # Initialize curses
    VER::start_ncurses  # this is initializing colors via ColorMap.setup
    $log = Logger.new("rbc13.log")
    $log.level = Logger::DEBUG

    colors = Ncurses.COLORS

    catch(:close) do
      t = ViewTodo::TodoApp.new
      t.run
  end
  rescue => ex
  ensure
    VER::stop_ncurses
    p ex if ex
    p(ex.backtrace.join("\n")) if ex
    $log.debug( ex) if ex
    $log.debug(ex.backtrace.join("\n")) if ex
  end
end
