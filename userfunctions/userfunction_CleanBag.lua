--=== V 2.5 ===--

-- sell prize = value which drops all below it
-- rarity = / 0 = white / 1 = green / 2 = blue / 3 = purple / 4 = orange / 5 = gold
-- drop true/false = if allready learned recipes should be dropped
function CleanBag(sellprize, rarity, drop, logg)
	inventory:update();
	
	-- custom database for user added items to trow out
	local forcedrop = {
		"Unknown Gift",
		"Lost Gift",
		"Sled Fragment",
	}
	
	-- custom database for user added items to keep
	local forcekeep = {
		"Link Rune",
	}
	
	if sellprize == nil then sellprize = 750 end;
	if rarity == nil then rarity = 1 end;
	if drop == nil then drop = false end;
	if logg == nil then logg = true end;
	
	for i, item in pairs(inventory.BagSlot) do
		if item.SlotNumber >= settings.profile.options.INV_AUTOSELL_FROMSLOT + 60 and
		settings.profile.options.INV_AUTOSELL_TOSLOT + 60 >= item.SlotNumber then
			
			local keep, deleted
			for k,v in pairs(forcedrop) do
				if v == item.Name then --item.Name instead of "Lost Gift"
					printf("Forcefully Deleting Item:  "..item.Name.."\n");
					item:delete();
					deleted = true
					break -- stops looking through rest of table
				end
			end
			for k,v in pairs(forcekeep) do
				if v == item.Name then --item.Name instead of "Link Rune"
					keep = true
					break -- stops looking through rest of table
				end
			end   
			if not keep and not deleted then
				-- all the other delete item checks here
				if (item:isType("Weapons") or item:isType("Armor")) and sellprize > item.Worth and item.Quality < rarity then
					printf("Deleting Item:  "..item.Name.."\n");
					if logg == true then
						logInfo("CleanBag", "" ..player.Name.. ": Deleted: " ..item.Name.. "." , true)
					end
					item:delete();
				elseif item:isType("Recipes") then
					if RoMScript("GetCraftItemInfo("..item.Id..")") == nil and item.Quality < rarity then -- Don't have it
						printf("Learning recipe:  "..item.Name.."\n");
						if logg == true then
							logInfo("LearnRecipe", "" ..player.Name.. ": Learning recipe:  " ..item.Name.. "." , true);
						end
						item:use();
						yrest(5000);
					else
						if drop == true and item.Quality < rarity then
							printf("Deleting Recipe:  "..item.Name.."\n");
							if logg == true then
								logInfo("LearnRecipe", "" ..player.Name.. ": Deleting recipe:  " ..item.Name.. "." , true);
							end
							item:delete();
						end
					end
				elseif item:isType("Monster Cards") then
					if not haveCard(item.Id) then
						printf("Using card:  "..item.Name.."\n");
						if logg == true then
							logInfo("UseCard", "" ..player.Name.. ": Using card:  " ..item.Name.. "." , true);
						end
						item:use();
						yrest(5000);
					end
				elseif item:isType("Potions") and item.RequiredLvl < player.Level - 10 then
					if not string.find(item.Name, "Phirius") then
						item:delete();
					end
				elseif item:isType("Runes") or item:isType("Production Runes") then
					item:delete();
				end
			end
		end
	end
end

-- _filename: the file name of the log file
-- _msg: the message to be logged
-- _logtime: true for logging time stamp
-- _subfolder: String with name of subfolder if data is to be stored in a subfolder of rom\logs\

--=== _logtype ===-- 
--"new" overwrites existing log file with new info
--"add" add to new line at end of file (this is default if not specified)

function logInfo(_filename,_msg,_logtime,_subfolder,_logtype)
	local file, err, filename
	if type(_msg) ~= "string" or type(_filename) ~= "string" then 
		cprintf(cli.red,"Incorrect usage of logInfo function\n") 
		return
	end	
	if type(_subfolder) == "string" then
		if not (isDirectory(getExecutionPath() .. "/logs/" .. _subfolder)) then
			os.execute("mkdir \"" .. string.gsub(getExecutionPath(), "/+", "\\") .. "\\logs\\".._subfolder.."\"")
		end
		_filename = _subfolder.."/".._filename
	end
	filename = getExecutionPath() .. "/logs/".._filename..".txt"
	if type(_logtype) == "string" and string.find(_logtype,"new") then
		file, err = io.open(filename, "w")
	else
		file, err = io.open(filename, "a+")
	end
	if( not file ) then
		cprintf(cli.red,err.."\n")
		return
	end
	if _logtime == true then file:write(os.date().." ") end
	file:write(_msg.."\n")
	file:close()
end

function haveCard(idorname)
   if type(idorname) == "string" and type(tonumber(idorname)) ~= "number" then
      idorname = "\""..idorname.."\""
   end
   return RoMScript("} for x=0,15 do "..
      "local cc=LuaFunc_GetCardMaxCount(x) "..
      "if cc~=nil and cc>0 then "..
         "for y=1,cc do "..
            "local i,f,n=LuaFunc_GetCardInfo(x,y-1) "..
            "if i=="..idorname.." or n=="..idorname.." then "..
               "a={f==1} "..
            "end "..
         "end "..
      "end "..
   "end z={")
end