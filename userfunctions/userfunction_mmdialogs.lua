--==<<                                             >>==--
--==<<           Celesterias mm-dialogs            >>==--
--==<<         by Celesteria - version 1.2         >>==--
--==<<                                             >>==--
--==<< a set of functions for simple dialogs in mm >>==--
--==<<                                             >>==--

	------------------------------------------------------------------------------------
	-- examples:
	--		local flag	= UMMD_chooseFlag ('do you want to use home runes to change class?', false)
	--		local num		= UMMD_chooseNumber (0, inventory:itemTotalCount (??????), 'how many ??????')
	--		local num		= UMMD_chooseClass (68, 'class to accept demonstration battle')
	--		local key		= UMMD_chooseList ({ ['l']='left, ['r']='right', ['d']='down', ['u']='up'}, 'which direction?')
	------------------------------------------------------------------------------------
	
	local function getInput ()
		keyboardBufferClear()
		io.stdin:flush()
		return io.stdin:read ()
	end
	
	function UMMD_chooseFlag (text, default)
	------------------------------------------------------------------------------------
	-- ask for yes or no
	--
	-- arguments
	-- 		text		- [optional] text to display
	--		default	- [optional] default value (boolean)
	-- returns
	--		true/false
	------------------------------------------------------------------------------------
		local str = '['..(default~=false and 'Y' or 'y')..'/'..(default==false and 'N' or 'n')..']'
		repeat
			if text~=nil then cprintf (cli.lightblue,"\n"..tostring(text).."\n") end
			printf (str.."  ->> ")
			temp = tostring (getInput ())
			if temp:lower ()=="y" or (default~=false and temp=='') then return true end
			if temp:lower ()=="n" or (default==false and temp=='') then return false end
		until true
	end

	function UMMD_chooseNumber (min, max, text)
	------------------------------------------------------------------------------------
	-- ask for a number between min and max
	--
	-- arguments
	-- 		min			- [required] lowvalue
	-- 		max			- [required] highvalue
	-- 		text		- [optional] text to display
	-- returns
	--		number
	------------------------------------------------------------------------------------
		repeat
			if text~=nil then cprintf (cli.lightblue, tostring(text).."\n") end
			printf ('['..tostring(min)..' - '..tostring(max)..']  ->> ')
			temp = tonumber (getInput ())
		until temp~=nil and temp>=min and temp<=max
		return temp
	end

	function UMMD_chooseList (list, text)
	------------------------------------------------------------------------------------
	-- ask for an entry of a given list
	--
	-- arguments
	-- 		list		- [required] a list of options (option format: key="text")
	-- 		text		- [optional] text to display
	-- returns
	--		key of the list
	------------------------------------------------------------------------------------
		local temp	= nil
		local l2		= {}
		for key,txt in pairs (list) do
			table.insert (l2, string.format ('  [%s] - %s\n', tostring (key), tostring (txt)))
		end
		table.sort (l2)
		while not list[temp] and not list[tostring(temp)] and not list[tonumber(temp)] do
			if text~=nil then cprintf (cli.lightblue,'\n'..tostring(text)..'\n') end
			for _,txt in ipairs (l2) do
				printf (txt)
			end
			printf ("  ->> ")
			temp = getInput ()
		end
		return temp
	end
	
	function UMMD_chooseClass (minLevel, text)
	------------------------------------------------------------------------------------
	-- ask for one of the available classes of the player
	--
	-- arguments
	-- 		minLevel	- [optional] level of the class must be at least this level
	-- 		text			- [optional] text to display
	-- returns
	--		classID
	------------------------------------------------------------------------------------
		minLevel		= minLevel or 999
		local list	= {}
		local count	= RoMScript ("GetClassCount ()")
		for i=1,count do
			local class, token, level, currExp, maxExp, xpDebt = RoMScript ("GetPlayerClassInfo ("..i..")");
			if class and level>=minLevel then
				list[''..(i-1)] = string.format ('%s (%d)', class, level)
			end
		end
		return tonumber (UMMD_chooseList (list, text))
	end
	
