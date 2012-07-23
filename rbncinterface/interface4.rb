#!/usr/bin/env ruby
require "rubygems"
require "ncurses"

class Window
	def initialize
		createWindow
	end
	
	def createWindow
		@window = Ncurses::WINDOW.new(10, 70, 12, 1);
		@window.bkgd(Ncurses.COLOR_PAIR(2))
		@window.refresh
	end
	
	def setTitle(title="Window Title")
		@window.box(0,0)
		@window.mvprintw(0,1,title)
		@window.mvprintw(1,2,"")
		@window.refresh
	end
	
	def write(out)
		@window.printw(out)
		#@window.printw(@window::methods.to_s)
		@window.refresh
	end
	
	def showMenu(out, highlight)
		x = 2;
		y = 2;
		@window.mvprintw(1, 2, "")
		Ncurses.keypad(@window, true)
		out.each do |element|
			if element == highlight 
				@window.wattron(Ncurses::A_BOLD)
				@window.printw(element)
				@window.wattroff(Ncurses::A_BOLD)
			else
				@window.printw(element)
			end	
		end
		@window.refresh
	end
	
	def refresh
		@window.refresh
	end
end

class Screen
	def initialize
		createScreen
		setDefaultColors
		refresh
	end
	
	def createScreen
		@screen = Ncurses.initscr
		Ncurses.cbreak #Line buffering disabled. pass on everything
		Ncurses.nl
		Ncurses.noecho
		Ncurses.keypad(@screen, true)
	end
	
	def setDefaultColors
		if (Ncurses.has_colors?)
		    bg = Ncurses::COLOR_BLACK
		    Ncurses.start_color
		    if (Ncurses.respond_to?("use_default_colors"))
		      if (Ncurses.use_default_colors == Ncurses::OK)
		        bg = -1
		      end
		    end
		    Ncurses.init_pair(1, Ncurses::COLOR_BLUE, bg)
		    Ncurses.init_pair(2, Ncurses::COLOR_CYAN, bg)
			Ncurses.init_pair(3, Ncurses::COLOR_RED, bg)
		  end
		@screen.bkgd(Ncurses.COLOR_PAIR(1))
		
	end
	
	def write(out)
		@screen.printw(out)
		@screen.refresh
	end
	
	def refresh
		@screen.refresh
	end
end


class Interface
	def initialize()
		@screen = Screen.new
		@window = Window.new
	end
	
	def test
		#@screen.write("one")
		#@screen.refresh
		@window.setTitle
		@screen.write("Use arrow keys to go up and down, Press enter to select a choice")
		
		@menu1=["Choice 1", "Choice 2", "Choice 3", "Exit"]
		
		@window.showMenu(@menu1,@menu1[0])
		
		@screen.write("!!")
		
	end
end

#-- Main
begin
	myinterface=Interface.new
	myinterface.test
	
	sleep(0.5)
	
ensure
	# put the screen back in its normal state
	Ncurses.echo()
	Ncurses.nocbreak()
	Ncurses.nl()
	Ncurses.endwin()
end