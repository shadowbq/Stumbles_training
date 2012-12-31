class MenuList
	 attr_accessor :currentSelected
	
	def currentSelected=(choice)
		unless isChoice?(choice)
			raise ArgumentError, "Is not a valid choice in the Menu."
		end
		@currentSelected = choice
	end
	
	def first
		@list.first
	end
	
	def last
		@list.last
	end
	
	def initialize(list)
		@list = list
		@currentSelected=@list.first
	end

	def addChoice(choice)
		@list.push(choice)
		self
	end
	
	def delChoice(choice)
		if isChoice?(choice)
			@list.delete(choice)
			if @currentSelected == choice
				@currentSelected = @list.first
			end	
		end
		self
	end
	
	def isChoice?(choice)
		@list.include?(choice)
	end
	
	def next
		if isChoice?(@currentSelected)
			if @currentSelected == @list.last
				@currentSelected = @list.first
			else	
				@currentSelected=@list[@list.index(@currentSelected)+1]
			end	
		else
			@currentSelected = @list.first
		end	
	end

	def prev
		if isChoice?(@currentSelected)
			if @currentSelected == @list.first 
				@currentSelected = @list.last
			else
				@currentSelected=@list[@list.index(@currentSelected)-1]
			end
		else
			@currentSelected = @list.first
		end		
	end	

	def each
		@list.each do |element|
			yield element
		end
	end
end

