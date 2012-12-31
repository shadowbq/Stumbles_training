# Simple logger prints messages
# received on UDP port 12121
require 'optparse'
require 'socket'

version = "0.1"

=begin
opts = OptionParser.new do |opts|
  opts.banner = "Usage: netsed.rb [options] "
  
  opts.on("-p", "--proto VAL", "TCP or UDP protocol.", "TCP")    {|PROTO|}
  opts.on("-l", "--lport VAL", "Local port to bind to..", "10000")  {|LPORT|}
  opts.on("-r", "--rhost VAL", "Remote Host", "127.0.0.1") {|RHOST| safe = value}
  opts.on("-d", "--rport VAL", "Remote prot to connect to..", "10001") {|RPORT| safe = value}
  opts.separator "Common options:"
  opts.on_tail("-h", "-?", "--help", "Show this message") {puts opts; exit}
  opts.on_tail("--version", "Show version") {puts "xml_to_csv.rb - version: " + version; exit}
  opts.parse!
end 

def exists?(symbol)
  eval "#{symbol}"
rescue
  false
end

unless exists? :PROTO
  print "PROTO: "
  PROTO = STDIN.gets.chomp
end

unless exists? :LPORT
  print "LPORT: "
  LPORT = STDIN.gets.chomp
end


#def socket_create(PROTO, LPORT, RHOST, RPORT)
=end
class ChatServer
	def initialize( port )
		@descriptors = Array::new
		@serverSocket = TCPServer.new( "", port )
		@serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
		printf("Chatserver started on port %d\n", port)
		@descriptors.push( @serverSocket )
	end # initialize
	
	def run
		while 1
			res = select( @descriptors, nil, nil, nil )
			if res != nil then
				# Iterate through the tagged read descriptors
				for sock in res[0]
					# Received a connect to the server (listening) socket
					if sock == @serverSocket then
						accept_new_connection
					else
						# Received something on a client socket
						if sock.eof? then
							str = sprintf("Client left %s:%s\n", sock.peeraddr[2], sock.peeraddr[1])
							broadcast_string( str, sock )
							sock.close
							@descriptors.delete(sock)
						else
							str = sprintf("[%s|%s]: %s", sock.peeraddr[2], sock.peeraddr[1], sock.gets())
							broadcast_string( str, sock )
						end
					end
				end
			end
		end
	end
	
	private
	
	def broadcast_string( str, omit_sock )
		@descriptors.each do |clisock|
			if clisock != @serverSocket && clisock != omit_sock
				clisock.write(str)
			end
		end
		print(str)
	end # broadcast_string
	
	def accept_new_connection
		newsock = @serverSocket.accept
		@descriptors.push( newsock )
		newsock.write("You're connected to the Ruby chatserver\n")
		str = sprintf("Client joined %s:%s\n",
		newsock.peeraddr[2], newsock.peeraddr[1])
		broadcast_string( str, newsock )
	end # accept_new_connection

end #server

def socket_create()
=begin
	socket = UDPSocket.new
	socket.bind("127.0.0.1", 16000)
	loop do
		msg, sender = socket.recvfrom(100)
		host = sender[3]
		puts "#{Time.now}: #{host} '#{msg}'"
	end
=end
	servSock = TCPServer::new( "", 16000 )
	newsock = servSock.accept
	newsock.write("You're connected to the Ruby chatserver\n")
	loop do
		newsock.puts newsock.recv(100)
		#msg, sender = servSock.recvfrom(100)
		#host = sender[3]
		#puts "#{Time.now}"
	end

	servSock::close
end

#socket_create(PROTO, LPORT, RHOST, RPORT)
#socket_create()
myChatServer = ChatServer.new( 16000 )
myChatServer.run