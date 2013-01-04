require 'rubygems'
require 'mechanize'
require 'logger'
require 'highline/import'
require 'htmlentities'
require 'ansi/code'

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
  
  def to_s
    "#{@date} ## #{@kind} // #{@from} -- #{@subject}"
  end
  
  def to_pretty
    if @kind.include?('unread')
      printf "%-30s %-25s %-35s %s", ANSI.bold + ANSI.blue + "#{@date}  ", ANSI.blue + "#{@kind}", ANSI.red + "#{@from}", ANSI.yellow + "#{@subject}" + ANSI.reset 
    else
      printf "%-30s %-25s %-35s %s", ANSI.blue + "#{@date}", ANSI.blue + "#{@kind}", ANSI.red + "#{@from}", ANSI.yellow + "#{@subject}" + ANSI.reset 
    end
    
  end
  
  def self.pretty_columns_header
    printf "%-30s %-20s %-30s %s\n", ANSI.green + "Date", "Type", "From", "Subject" + ANSI.reset
    printf "%s\n", ANSI.green + "--------------------------------------------------------------------------------------------------------------" + ANSI.reset
  end
  
end 

class OwaReader
  
  DEBUG = FALSE
  
  attr_accessor :mailbox, :url, :inbox
  
  
  def initialize(mailbox ="", url="", inbox="")

    @mechanize = Mechanize.new { |a| a.log = Logger.new('./log1.log') }
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

    mymail = Array.new
    
    @mechanize.get(@url) do |page|
      form = page.forms[0]
      form["username"] = domain + '\\' + username
      form["password"] = password
      @nextpage = form.submit
    end
      
    puts "return inbox url #{@inbox}" unless DEBUG==FALSE
      
    @mechanize.get(@inbox) do |page|
      puts "Page Body Size: #{page.body.size}" unless DEBUG==FALSE
      sleep 3;
      mymail = mailbuilder(Nokogiri::HTML(page.body))
    end
      
    puts "return checking mymail #{mymail.class} : #{mymail.size}" unless DEBUG==FALSE

    
   return mymail

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
    
    puts "froms size #{froms.size}" unless DEBUG == FALSE
    puts "subjects size #{subjects.size}" unless DEBUG == FALSE
    puts "dates size #{dates.size}" unless DEBUG == FALSE
    puts "kinds size #{kindsof.size}" unless DEBUG == FALSE
    puts "links size #{links.size}" unless DEBUG == FALSE
    
    
    # Map Arrays to Class structure
    while subjects.size > 0 do
      mymail << Mail.new(froms.pop, subjects.pop, dates.pop, kindsof.pop, links.pop)
    end
  
    mymail.sort.reverse
    
  end

end 


def main
  
  url = ask("Enter your exchange url ['https://foo.bar.com/Exchange']: ")
  username = ask("Enter your username: ")
  domain = ask("Enter your domain: ")
  password = ask("Enter your password: ") {|q| q.echo = "*" }
  
  mailbox = "#{username}"
  
  inbox = "#{url}/#{mailbox}/Inbox/?Cmd=contents&Page=1&View=Messages"
  
  @reader = OwaReader.new(mailbox, url, inbox)
  @mymail = @reader.retrieve(username, domain, password)

  Mail.pretty_columns_header 
  @mymail.each do |mail|
     puts mail.to_pretty
  end
  
  @reader.logoff

  puts "unread meetings: #{@mymail.select{|mail| mail.kind == "unread meeting"}.size}"
  puts "unread emails: #{@mymail.select{|mail| mail.kind == "unread mail"}.size}"
 

end

def offlinetest
  
  @reader = OwaReader.new()
  @mymail = @reader.mailbuilder(Nokogiri::HTML(File.open("./test/email.-.-.com.html")))

  Mail.pretty_columns_header 
  @mymail.each do |mail|
     puts mail.to_pretty
  end
  
  puts "unread meetings: #{@mymail.select{|mail| mail.kind == "unread meeting"}.size}"
  puts "unread emails: #{@mymail.select{|mail| mail.kind == "unread mail"}.size}"
 
 
end

main
