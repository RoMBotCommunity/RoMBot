
	function message (msg, stopScript, cancelScript, color)
		if color==nil then 
			if stopScript then 				color = cli.lightgreen
			elseif cancelScript then	color = cli.red
			else											color = cli.lightblue
			end
		end
		addMessage (msg);
		cprintf(color, msg.."\n");
		if stopScript==true then
			addMessage ('going to sleep mode');
			player:sleep ()
		elseif cancelScript==true then
			addMessage ('cancel script');
			error ('canceled', 0)
		end
	end

	function saveReport (info, filename)
		if info~=nil then
			info = __WPL.FileName..' - '..getPlayerName ()..' - '..info
			if filename==nil then
				filename = getPlayerName ()..'.log'
			end
			logInfo (filename, info, true)
			message (info)
		end
	end

	function getPlayerName (acc, char, filename)
		if acc and char then
			filename			= filename or getExecutionPath () .. '/cache/names.dat'
			local saved		= table.load (filename) or {}
			if type (saved)=='table' then
				if type (saved[acc])=='table' and saved[acc][char] then
					return saved[acc][char]
				end
			end
			if acc~=getAcc () or char~=getChar () then
				return nil
			end
		end
		return asciiToUtf8_umlauts (convert_utf8_ascii (player.Name))
	end
	
	function savePlayerName (acc, char, name, filename)
    if not acc and not char then
      acc             = acc or getAcc ()
      char            = char or getChar ()
    end
    name              = name or getPlayerName (acc, char)
		filename					= filename or getExecutionPath () .. '/cache/names.dat'
		local saved				= table.load (filename) or {}
		saved[acc]				= saved[acc] or {}
		saved[acc][char]	= name
		table.save (saved, filename)
	end

	function killStupidNewbiePet ()
		if player:findNearestNameOrId (113199) then  -- search vicinity for Newbie Pet
			inventory:update ()
			local newbEgg = inventory:findItem (207051) -- Newbie Pet Egg
			if newbEgg~=nil then
				newbEgg:use ()
				inventory:deleteItemInSlot (newbEgg.SlotNumber)
			end
		end
	end
