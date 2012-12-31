#!/usr/bin/env ruby
require "rubygems"
require "ncurses"
require ("MenuList")

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
		@window.refresh
	end
	
	def renderMenu(menu)
		Ncurses.keypad(@window, true)
		Ncurses.curs_set(0)
		printMenu(menu)
		while true
			case(@window.getch())
				when Ncurses::KEY_UP
					menu.next
				when Ncurses::KEY_DOWN
					menu.prev
				when 10 #Carriage-Return
					break	
			end
			printMenu(menu)
		end
		Ncurses.curs_set(1)
		refresh
		menu.currentSelected #return value of menu
	end
	
	def refresh
		@window.refresh
	end
	
	private
	
	def printMenu(menu)
		@window.mvprintw(1,2,"")
		menu.each do |item|
			if item == menu.currentSelected
				@window.attron(Ncurses::A_BOLD)
				@window.printw("\n" + item)
				@window.attroff(Ncurses::A_BOLD)
			else	
				@window.printw("\n" + item)
			end
		end
		refresh
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
		@window.setTitle
		@screen.write("Use arrow keys to go up and down, Press enter to select a choice")
		
		@myMenuList = MenuList.new(["a", "b", "c", "d"])
		@myMenuList2 = MenuList.new(["1", "2", "3", "4"])
		
		@screen.write("\n" + @window.renderMenu(@myMenuList) + ":=>" + @window.renderMenu(@myMenuList2))
		@screen.refresh
		
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