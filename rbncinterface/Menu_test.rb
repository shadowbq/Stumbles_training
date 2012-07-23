require ("Menu")

myMenuList = MenuList.new(["a", "b", "c", "d"])
myNcursesMenu = Menu.new

puts "initial menu:"
myNcursesMenu.printMenu myMenuList

puts "\nnext once:"
myMenuList.next
myNcursesMenu.printMenu myMenuList

puts "\nprev once:"
myMenuList.prev
myNcursesMenu.printMenu myMenuList

puts "\nNext 6 times (should loop): "
6.times { myMenuList.next }
myNcursesMenu.printMenu myMenuList

puts "\nadd couple options"
myMenuList.addChoice("e").addChoice("f")
myNcursesMenu.printMenu myMenuList

puts "\nTest choice 'b' "
p myMenuList.isChoice?("b")

puts "\nTest choice 'z' "
p myMenuList.isChoice?("z")

puts "\nDelete choice 'b' "
myMenuList.delChoice("b")
myNcursesMenu.printMenu myMenuList

begin
	puts "\nSet illegal choice 'b' "
	myMenuList.currentSelected="b"
	rescue ArgumentError
		puts "\nRescue illegal choice, change to 'a' "
		myMenuList.currentSelected="a"
end	
myNcursesMenu.printMenu myMenuList

begin
	puts "\nDelete Current Choice 'a' "
	myMenuList.delChoice("a")
	
	rescue ArgumentError
		puts "\nRescue illegal choice, change to 'a' "
		myMenuList.first
end	
myNcursesMenu.printMenu myMenuList

