#!/usr/bin/env ruby
require "rubygems"
require "ncurses"

class Window
	def initialize
		createWindow
	end
	
	def createWindow
		@window = Ncurses::WINDOW.new(10, 30, 12, 1);
		@window.bkgd(Ncurses.COLOR_PAIR(2))
		@window.refresh
	end
	
	def title(title="Window Title")
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
end

class Screen
	def initialize
		createScreen
		setColors
	end
	
	def createScreen
		@screen = Ncurses.initscr
		Ncurses.cbreak
		Ncurses.nl
		Ncurses.noecho
		Ncurses.keypad(@screen, true)
		
	end
	
	def setColors
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
		@screen.box(0,0)
	end
	
	def write(out)
		@screen.printw(out)
		#@screen.printw(@screen.is_a?(Ncurses::WINDOW).to_s)
		@screen.refresh
	end
end


class Interface
	def initialize()
		@screen = Screen.new
		@window = Window.new
	end
	
	def test
		@screen.write("one")
		@window.title("test")
		@window.write("two")
		@screen.write("three")
		sleep(0.5)
		@window.title
		#@window.title("new title")
		#@window.write("overwrite")
		
	end
end

#-- Main
begin
	myinterface=Interface.new
	myinterface.test
	#myinterface.windowHi
	sleep(0.5)
	
ensure
	# put the screen back in its normal state
	Ncurses.echo()
	Ncurses.nocbreak()
	Ncurses.nl()
	Ncurses.endwin()
end