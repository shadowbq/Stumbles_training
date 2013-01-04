require 'rubygems'

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
require 'mechanize'
require 'highline/import'
require 'htmlentities'



module Owa
  
  class Mail
    attr_accessor :from, :subject, :date, :kind, :link
  
    def initialize(from, subject,date,kind,link)
      coder = HTMLEntities.new
      @from = coder.decode(from)
      @subject = coder.decode(subject)
    
      #Mon 12/31/2012 10:46 AM
      d=Date._strptime(coder.decode(date),"%a %m/%d/%Y %l:%M %p")
      @date = Time.utc(d[:year], d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:sec_fraction], d[:zone])
      @kind = kind
      @link = link
    end
  

    def <=>(other)
      @date <=> other.date
    end

    def to_a
      [@date, @kind, @from, @subject]
    end
    
    
  end 
  
  
  class OwaReader
  
    attr_accessor :mailbox, :url, :inbox
  
  
    def initialize(mailbox ="", url="", inbox="")

      @mechanize = Mechanize.new { |a| a.log = Logger.new('./owa-ncurses-mechanize.log') }
      @mechanize.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @mechanize.user_agent_alias = 'Windows Mozilla'
      @mechanize.keep_alive = 'enable'
    
      @mailbox = mailbox
      @url = url
      @inbox = inbox

    end
    
    def logoff
      @mechanize.get("#{@url}/#{@mailbox}/?Cmd=logoff") 
    end

    def retrieve(username, domain, password)
      
      print "loging into Exchange.. please wait"
      
      mymail = Array.new
    
      @mechanize.get(@url) do |page|
        form = page.forms[0]
        form["username"] = domain + '\\' + username
        form["password"] = password
        @nextpage = form.submit
      end
      
      print ".."
      
      @mechanize.get(@inbox) do |page|
        sleep 1;
        mymail = mailbuilder(Nokogiri::HTML(page.body))
      end
      
      print ".."
      
     return mymail

    end
    
    def openmail(link, wraplength)
      # "#{url}/#{mailbox}"
      # link "Inbox/12_xF8FF_24.EML?Cmd=open"
      
      bodytext = ""
      
      @mechanize.get("#{@url}/#{@mailbox}/#{link}") do |page|
        
        openmail =  Nokogiri::HTML(page.body) do |config|
          config.nonet.noblanks.noerror.noent.nowarning
        end

        bodytext = openmail.xpath("//table[@class='tblMsgBody']").text
        
        bodytext = bodytext.gsub("\r","")
        bodytext = bodytext.gsub("\n\n\n","\n\n")
        
        bodytext = bodytext.split("\n").collect do |line|
            line.length > wraplength ? line.gsub(/(.{1,#{wraplength}})(\s+|$)/, "\\1\n").strip : line
        end * "\n"

      end
      
      return bodytext
      
    end

    def mailbuilder(fragment)
    
      subjects = Array.new
      froms = Array.new
      dates = Array.new
      kindsof = Array.new
      mymail = Array.new
      links = Array.new

      # Parse Owa Email Lines
    
      # 'Password Warning(i)' box gets injected as a new table during some events
      # table class="trToolbar"
      # table class="tblFolderBar"
      # table id="statusbar" 
      # table class="tblHierarchy" 
      # table with no class or id is the owamaillines
    
      tableindex = 2
    
      while tableindex < 7 do
        mytable = fragment.xpath("/html/body/form/table/tr/td/table[#{tableindex}]")
      
        if mytable[0].attributes.has_key?("class")
          tableindex+= 1
          next
        end
    
        if mytable[0].attributes.has_key?("id")
          tableindex+= 1
          next
        end
      
        break
      end
    
      # Find the OWALINES!
      owamaillines = fragment.xpath("/html/body/form/table/tr/td/table[#{tableindex}]/tr")

      ["./td[7]/font/a/font/b", "./td[7]/font/a/font[not(b)]"].each do |xpathq|
        owamaillines.xpath(xpathq).children.each do |child|  
          subjects << "#{child}"
        end
      end 
    

      ["./td[6]/font/a/font/b", "./td[6]/font/a/font[not(b)]"].each do |xpathq|
        owamaillines.xpath(xpathq).children.each do |child|  
          froms << "#{child}"
        end
      end
      
      #Unread Links
      owamaillines.xpath("./td[8]/font/a/font/b").each {|element| 
          links << element.parent.parent.attributes["href"].value
          dates << "#{element.child}"
      }
      
      #Read Links
      owamaillines.xpath("./td[8]/font/a/font[not(b)]").each {|element| 
          links << element.parent.attributes["href"].value
          dates << "#{element.child}"
      }
      

      ["./td[3]/font/a/font/b/img[@src]", "./td[3]/font/a/font/img[@src]"].each do |xpathq|
        owamaillines.xpath(xpathq).each do |child|  
          if child.attributes["src"].to_s.include?('/icon-msg-unread.gif')
            kindsof << "unread mail"
          elsif child.attributes["src"].to_s.include?('/icon-mtgreq.gif')
            kindsof << "unread meeting"
          elsif child.attributes["src"].to_s.include?('/icon-msg-read.gif')
            kindsof << "read mail"
          elsif child.attributes["src"].to_s.include?('/icon-msg-reply.gif')   
            kindsof << "replied to"
          elsif child.attributes["src"].to_s.include?('/icon-msg-forward.gif')
            kindsof << "forwarded to"  
          else
            kindsof << "other"
          end
       
        end
      end

      
      # Map Arrays to Class structure
      while subjects.size > 0 do
        mymail << Mail.new(froms.pop, subjects.pop, dates.pop, kindsof.pop, links.pop)
      end
  
      mymail.sort.reverse
    
    end

  end 
  
  
  class OwaApp
    
    attr_accessor :mymail, :reader
    
    def initialize(mailbox, url, inbox, username, domain, password)
      @window = VER::Window.root_window
      @form = Form.new @window

      @reader = Owa::OwaReader.new(mailbox, url, inbox)
      @mymail = @reader.retrieve(username, domain, password)
      
    end
    
    def logoff
      @reader.logoff
    end
    
    def run
      #Non Lazy Initiation of mymail
      mymail = @mymail
      
      #binding.pry
      
      title = "OWA APP"
      
      @header = ApplicationHeader.new(@form, title, {:text2=>"NCurses Ruby OWA Mail Viewer", :text_center=>"Mail View"})

      #Non Lazy Initiation of status_row
      status_row = RubyCurses::Label.new(@form, {'text' => "", :row => Ncurses.LINES-4, :col => 0, :display_length=>60})
      @status_row = status_row
      
      # setting ENTRANCE Binding for status changes across all objects on a form
      @form.bind(:ENTER) {|f| status_row.text = f.help_text unless f.help_text.nil? }

      #Setting Default Dimensions for Row/Column Positions
      r = 1
      c = 1
      table_height = 18 # -3 for visble_rows
      table_width = Ncurses.COLS-5 #110
      
      msgtable = Table.new @form do
        name   "EMessageTable" 
        row  r+2
        col  c
        width table_width
        height table_height
        selected_color :green
        selected_bgcolor :blue
        cell_editing_allowed false
        set_data mymail.collect{|mail| mail.to_a}, %w[date kind from subject]
      end
      
      @msgtable = msgtable
      ########################################################################
      # Table Column Model 
      # column widths 
      ########################################################################
      
      tcm = msgtable.get_table_column_model
       
      # Hard Coded Columns
      hc_columns = 20 + 8 + 20 
      tcm.column(0).width 20 # Date
      tcm.column(1).width 8 # Kind
      tcm.column(2).width 20 # From
      tcm.column(3).width Ncurses.COLS - 15 - hc_columns # Subject

      ########################################################################
      ## NCurses Command Key Bindings (callbacks)
      ########################################################################

      # Non Lazy Initiation of Self
      app = self
      
      ## Key bindings for atable
      msgtable.configure() do

        bind_key(?{) {
          msgtable.goto_top
        }
        bind_key(?}) {
          msgtable.goto_bottom
        }
        bind_key(?[) {
          msgtable.scroll_backward
        }
        bind_key(?]) {
          msgtable.scroll_forward
        }
        


        bind_key(?>) {
          colcount = tcm.column_count-1
          col = msgtable.focussed_col
          msgtable.move_column col, col+1 unless col == colcount
        }
        
        bind_key(?<) {
          col = msgtable.focussed_col
          msgtable.move_column col, col-1 unless col == 0
        }
        
        bind_key(KEY_ENTER, app) {|ncursetable,emailapp| 
          app.show_email(ncursetable,emailapp)
        }
        
        bind_key(?\\, app) {|ncursetable, emailapp| 
          app.show_popup(msgtable)
        }
        
      end

      msgtable.bind(:TABLE_TRAVERSAL_EVENT){|e| @header.text_right "Row #{e.newrow+1} of #{msgtable.row_count}" }
      
      ## Enable Dynamic Bindings
      create_table_actions(msgtable, mymail)
      
      ########################################################################
      ## Print Bottom Key Labels 
      ########################################################################
      
      @klp = RubyCurses::KeyLabelPrinter.new(@form, app_key_labels)
      @klp.set_key_labels(table_key_labels, :table)
      
      msgtable.bind(:ENTER){ 
        @klp.mode :table 
      }
      msgtable.bind(:LEAVE){ 
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
    
    def show_popup(table)
      require 'rbcurse/extras/widgets/rpopupmenu'
      tablemenu = RubyCurses::PopupMenu.new "Table"
      
      tablemenu.add(item = RubyCurses::PMenuItem.new("&Open"))
      item.command() { @open_cmd.call }
      
      tablemenu.insert_separator 1
      
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
    
    def show_email(tab,emailapp)
      require 'rbcurse/core/util/viewer'
      
      vh = FFI::NCurses.LINES - 10
      vw = FFI::NCurses.COLS - 20
      
      # [@date, @kind, @from, @subject]
      arr = []
      arr << ""
      arr << "Date Time Stamp: #{tab.get_value_at(tab.focussed_row,0)}"
      arr << "Kind: #{tab.get_value_at(tab.focussed_row,1)}"
      arr << ""
      arr << "From: #{tab.get_value_at(tab.focussed_row,2)}"
      arr << ""
      arr << "Subject: #{tab.get_value_at(tab.focussed_row,3)}"
      arr << ""
      arr << "Body: "
      
      emailapp.reader.openmail(emailapp.mymail[tab.focussed_row].link, vw-8 ).lines do |line|
        arr << line
      end  
      
      arr << ""
      arr << " ------ Viewer Menu -----------"
      arr << " q | F10 -  Close View "

      defarr = arr
      
      RubyCurses::Viewer.view(arr, :layout => [2, 4, vh, vw],:close_key => KEY_F10, :title => "[ Show Email Message ]", :print_footer => true) do |t|
        # you may configure textview further here.
        #t.suppress_borders true
        t.color = :black
        t.bgcolor = :white
                
        t.add_content defarr, :title => ' Current Email '
        
      end
    end
    
    private
    
    ########################################################################
    ## NCurses Additional Dynamic Callbacks
    ########################################################################
    
    # View Only For Now
    def create_table_actions(msgtable, mymail)
      
      #refactor - Add a SQL insertion
      @open_cmd = lambda {
        show_email(msgtable,mymail)
      }
      
      #refactor - Currently just removes view of row, not database entry
      @del_cmd = lambda { 
        row = msgtable.focussed_row
        sno = msgtable.get_value_at(row,0)
        answer = confirm("Do your really want to delete id #{sno}?")
        if answer == true
          tm = msgtable.table_model
          #todo.delete(sno)
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

include RubyCurses
include RubyCurses::Utils

begin
    
  url = ask("Enter your exchange url ['https://foo.bar.com/Exchange']: ")
  username = ask("Enter your username: ")
  domain = ask("Enter your domain: ")
  password = ask("Enter your password: ") {|q| q.echo = "*" }
  
  mailbox = "#{username}"
  inbox = "#{url}/#{mailbox}/Inbox/?Cmd=contents&Page=1&View=Messages"
    
  # Initialize curses
  VER::start_ncurses  # this is initializing colors via ColorMap.setup
  $log = Logger.new("owa-ncurses.log")
  $log.level = Logger::DEBUG

  colors = Ncurses.COLORS

  catch(:close) do
    t = Owa::OwaApp.new(mailbox, url, inbox, username, domain, password)
    t.run
    t.logoff
  end
    
rescue => ex
ensure
  VER::stop_ncurses
  p ex if ex
  p(ex.backtrace.join("\n")) if ex
  $log.debug( ex) if ex
  $log.debug(ex.backtrace.join("\n")) if ex
end
