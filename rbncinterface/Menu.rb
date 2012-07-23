require ("MenuList")

class Menu
	
	def initialize
	end
	
	def loadOptions
=begin
		add_default?
			@menu.setCurrent("c")
		add_numbers?
		add_cancle?
		axis? #default (verticle, horizontal)
=end
	end
		
	def printMenu(menu)
		menu.each do |item|
			if item == menu.currentSelected
				puts ("*" + item)
			else	
				puts (item)
			end
		end	
	end
	
	def returnValue(rValue)
		if rValue == cancle
			err = 1
		end
	end

=begin	
	def showMenu #Main loop
		begin
			case(user_input)
				when Ncurses::KEY_UP
					currentSelected = @menu.next
					
				when Ncurses::KEY_DOWN
					currentSelected = @menu.prev
					
				when 10 #Carriage-Return
				
				when Escape #Cancle
					returnValue(cancle)
			end 	
		end while true
		
	end
=end
	
end 

