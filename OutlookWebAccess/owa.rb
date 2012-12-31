require 'rubygems'
require 'mechanize'
require 'logger'
require 'highline/import'
require 'htmlentities'
require 'ansi/code'

class Mail
  attr_accessor :from, :subject, :date, :kind
  
  
  def initialize(from, subject,date,kind)
    coder = HTMLEntities.new
    @from = coder.decode(from)
    @subject = coder.decode(subject)
    @date = coder.decode(date)
    @kind = kind
  end
  
  def to_s
    "#{@date} ## #{@kind} // #{@from} -- #{@subject}"
  end
  
  def to_pretty
    printf "%-30s %-25s %-30s %s", ANSI.blue + "#{@date}", ANSI.blue + "#{@kind}", ANSI.red + "#{@from}", ANSI.yellow + "#{@subject}" + ANSI.reset 
  end
  
  def self.pretty_columns_header
    printf "%-30s %-20s %-25s %s\n", ANSI.green + "Date", "Type", "From", "Subject" + ANSI.reset
    printf "%s\n", ANSI.green + "----------------------------------------------------------------------------------------------------" + ANSI.reset
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
    

    # Parse Owa Email Lines
    owamaillines = fragment.xpath("/html/body/form/table/tr/td/table[4]/tr")
    puts "owamaillines Size: #{owamaillines.size}" unless DEBUG==FALSE

    owamaillines.xpath("//tr/td[7]/font/a/font/b").children.each { |child|  
      subjects << "#{child}"
    } 
    owamaillines.xpath("//tr/td[6]/font/a/font/b").children.each { |child|  
      froms << "#{child}"
    }
    owamaillines.xpath("//tr/td[8]/font/a/font/b").children.each { |child|  
      dates << "#{child}"
    }  
    owamaillines.xpath("//tr/td[3]/font/a/font/b/img[@src]").each { |child|  
       if child.attributes["src"].to_s.include?('/icon-msg-unread.gif')
         kindsof << "unread mail"
       elsif child.attributes["src"].to_s.include?('/icon-mtgreq.gif')
         kindsof << "unread meeting"
       else
         kindsof << "other"
       end
    }  
    
    puts "froms size #{froms.size}" unless DEBUG == FALSE
    puts "subjects size #{subjects.size}" unless DEBUG == FALSE
    puts "dates size #{dates.size}" unless DEBUG == FALSE
    puts "kinds size #{kindsof.size}" unless DEBUG == FALSE
    
    # Map Arrays to Class structure
    while subjects.size > 0 do
      mymail << Mail.new(froms.pop, subjects.pop, dates.pop, kindsof.pop)
    end
  
    puts "return checking mymail #{mymail.class} : #{mymail.size}" unless DEBUG==FALSE
  
    mymail.reverse
    
  end

end 


def main
  
  url = ask("Enter your exchange url ['https://foo.bar.com/Exchange']:")
  username = ask("Enter your username: ")
  domain = ask("Enter your domain: ")
  password = ask("Enter your password: ") {|q| q.echo = "*" }
  
  mailbox = "#{username}"
  
  inbox = "#{url}/#{mailbox}/Inbox/?Cmd=contents&Page=1&View=Unread%20Messages"

  @reader = OwaReader.new(mailbox, url, inbox)
  @mymail = @reader.retrieve(username, domain, password)

  Mail.pretty_columns_header 
  @mymail.each do |mail|
     puts mail.to_pretty
  end

  puts "unread meetings: #{@mymail.select{|mail| mail.kind == "unread meeting"}.size}"
  puts "unread emails: #{@mymail.select{|mail| mail.kind == "unread mail"}.size}"
 

end

def offlinetest
  
  File.open("./test/email.-.-.com.html") do |f|
    @fragment = Nokogiri::HTML(f)
  end
  
  @reader = OwaReader.new()
  @mymail = @reader.mailbuilder(@fragment)

  Mail.pretty_columns_header 
  @mymail.each do |mail|
     puts mail.to_pretty
  end
  
  puts "unread meetings: #{@mymail.select{|mail| mail.kind == "unread meeting"}.size}"
  puts "unread emails: #{@mymail.select{|mail| mail.kind == "unread mail"}.size}"
 
 
end

main

#offlinetest
