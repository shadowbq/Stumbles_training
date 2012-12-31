#!/usr/bin/env ruby
require "rubygems"
require "ncurses"

class Interface
	def initialize()
		createScreen
		createWindow
	end
	
	def createScreen
		@screen = Ncurses.initscr
		Ncurses.cbreak
		Ncurses.nl
		Ncurses.noecho
		Ncurses.keypad(@screen, true)
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
	
	def createWindow
		@window = Ncurses::WINDOW.new(10, 30, 12, 1);
		@window.bkgd(Ncurses.COLOR_PAIR(3))
		@window.box(0, 0)
		@window.printw("Window Title")
		@window.mvprintw(2,2,"")
		@window.refresh
	end
	
	def windowHi
		@window.printw("Hi window")
		@window.refresh
	end
	
	def screenHi
		@screen.printw("Hi Screen")
		@screen.refresh
		sleep(1.5)
		
	end
	
end

#-- Main
begin
	myinterface=Interface.new
	myinterface.windowHi
ensure
	# put the screen back in its normal state
	Ncurses.echo()
	Ncurses.nocbreak()
	Ncurses.nl()
	Ncurses.endwin()
end