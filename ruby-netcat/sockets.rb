#!/usr/local/bin/ruby -w

require 'socket'


regex = /[aeiou]/
replacement = "*"
myinput = "moo"

Thread.new do
        while 1
	            trap("HUP") do
	            puts "CAUGHT HUP"
				puts "HAI!:"
				puts myinput
				#input = "smile"
				myinput = STDIN.gets.chomp
				#input.chomp			
				puts input
                        #regex = /[bcdfgh]/
                        #replacement = "!"
                end
        end
end


socket = TCPServer::new("0.0.0.0", 15000)
socket = socket.accept
#socketOut = TCPSocket::new("localhost", 16000)

loop do
	#socketOut.puts socket.gets.gsub(/[aeiou]/, '*')
	#socket.puts socket.gets.gsub(/[aeiou]/, '*')
	socket.puts socket.gets.gsub(regex, replacement)
end
