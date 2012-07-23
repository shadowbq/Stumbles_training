#OWA Ruby connector
domain = "domain"
username = "#{domain}\foo"
password = "secret"

require 'net/https'


#site = Net::HTTP.new("www.site.com", 80)
site = Net::HTTP.new("webmail.site.com", 443)
site.use_ssl = true

response = site.get2("/exchange/logon.asp",'Authorization' => 'Basic' + ["#{username}:#{password}"].pack('m').strip)
#response = site.get("/")
puts "Code = #{response.code}"
puts "Message = #{response.message}"
response = site.get("/exchange/LogonFrm.asp?isnewwindow=0&mailbox=#{username}")
puts "Code = #{response.code}"
puts "Message = #{response.message}"