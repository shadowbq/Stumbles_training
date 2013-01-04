#!/usr/bin/env ruby
require "rubygems"
require "ncurses"

begin
scr = Ncurses.initscr
Ncurses.cbreak()
Ncurses.nl()
Ncurses.noecho()
Ncurses.keypad(scr, true)

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
scr.bkgd(Ncurses.COLOR_PAIR(1))
Ncurses.mvaddstr(4, 19, "Hello, world!")
Ncurses.mvprintw(5, 10, "Value 1: ")
Ncurses.printw("Value 2")

scr.refresh()
if Ncurses.getch == Ncurses::KEY_UP
	Ncurses.printw("Up Key Pressed!")
else
	Ncurses.printw("~")
end

scr.bkgd(Ncurses.COLOR_PAIR(2))
scr.refresh()
ch = scr.getch()

Ncurses.attron(Ncurses::A_BOLD)
Ncurses.printw(ch.chr)
Ncurses.attroff(Ncurses::A_BOLD)
scr.refresh()
#sleep(2.5)


revolvewin = Ncurses::WINDOW.new(10, 10, 12, 1);
revolvewin.bkgd(Ncurses.COLOR_PAIR(3))
revolvewin.box(0, 0)
revolvewin.printw("Hiddie ho")
revolvewin.mvprintw(2,2,"")
revolvewin.refresh

Ncurses.refresh

  begin
    case(scr.getch())
    when 'q'[0], 'Q'[0]
      Ncurses.curs_set(1)
      Ncurses.endwin()
      exit
    when 's'[0]
      Ncurses.stdscr.nodelay(false)
    when ' '[0]
      Ncurses.stdscr.nodelay(true)
    when Ncurses::KEY_UP
      revolvewin.printw("Up!")
    end
	scr.printw(".")
    #sleep(0.050)
    scr.refresh
	revolvewin.refresh
  end while true


 
ensure
  # put the screen back in its normal state
  Ncurses.echo()
  Ncurses.nocbreak()
  Ncurses.nl()
  Ncurses.endwin()
end


