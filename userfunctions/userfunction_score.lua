-- Rate Item by Rock5 v0.01 alpha
include("../cache/itemtypestable.lua");

local STR, STA, INT, WIS, DEX, ALLATTR = 2, 3, 4, 5, 6, 7
local HP, MP, PATT, PDEF, MDEF, MATT= 8, 9, 12, 13, 14, 15
local PDAM, MDAM = 25, 191


local CLASS_EFFECT={
	[CLASS_WARRIOR] = {
		[STR] = {[PATT]=2, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=2.3},
		[INT] = {[MATT]=2, [MP]=1},
		[WIS] = {[MP]=5, [MDEF]=2.2},
		[ALLATTR] ={[PATT]=2,[HP]=5.2, [PDEF]=2.3,[MATT]=2, [MP]=6 ,[MDEF]=2.2},
		[DEX] = {},
	},
	[CLASS_SCOUT] = {
		[STR] = {[PATT]=1, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=1.8},
		[INT] = {[MATT]=2, [MP]=1},
		[WIS] = {[MP]=5, [MDEF]=2.6},
		[ALLATTR] ={ [PATT]=2, [HP]=5.2, [PDEF]=1.8,[MATT]=2, [MP]=6, [MDEF]=2.6},
		[DEX] = {[PATT]=1},
	},
	[CLASS_ROGUE] = {
		[STR] = {[PATT]=1.2, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=1.8},
		[INT] = {[MATT]=2, [MP]=1},
		[WIS] = {[MP]=5, [MDEF]=2.3},
		[ALLATTR] ={ [PATT]=2.5, [HP]=5.2, [PDEF]=1.8,[MATT]=2, [MP]=6, [MDEF]=2.6},
		[DEX] = {[PATT]=1.3},
	},
	[CLASS_MAGE] = {
		[STR] = {[PATT]=0.8, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=1.5},
		[INT] = {[MATT]=2, [MP]=1, [PATT]=0.5},
		[WIS] = {[MP]=5, [MDEF]=3},
		[ALLATTR] ={[MATT]=2, [PATT]=1.3, [HP]=5.2, [PDEF]=1.5,[MATT]=2, [MP]=6, [MDEF]= 3},
		[DEX] = {},
	},
	[CLASS_PRIEST] = {
		[STR] = {[PATT]=0.8, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=1.5},
		[INT] = {[MATT]=2, [MP]=1, [PATT]=0.5},
		[WIS] = {[MP]=5, [MDEF]=3.2},
		[ALLATTR] ={[MATT]=2, [PATT]=1.3, [HP]=5.2, [PDEF]=1.5,[MATT]=2, [MP]=6, [MDEF]= 3.2},
		[DEX] = {},
	},
	[CLASS_KNIGHT] = {
		[STR] = {[PATT]=1.5, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=3},
		[INT] = {[MATT]=2, [MP]=1, [PATT]=0.5},
		[WIS] = {[MP]=5, [MDEF]=2.4},
		[ALLATTR] ={[MATT]=2, [PATT]=2, [HP]=5.2, [PDEF]=3,[MATT]=2, [MP]=6, [MDEF]= 2.4},
		[DEX] = {},
	},
	[CLASS_DRUID] = {
		[STR] = {[PATT]=0.8, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=1.5},
		[INT] = {[MATT]=2, [MP]=1},
		[WIS] = {[MP]=5, [MDEF]=3},
		[ALLATTR] ={[MATT]=2, [PATT]=0.8, [HP]=5.2, [PDEF]=1.5,[MATT]=2, [MP]=6, [MDEF]=3},
		[DEX] = {},
	},
	[CLASS_WARDEN] = {
		[STR] = {[PATT]=1.5, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=2},
		[INT] = {[MATT]=2, [MP]=1, [PATT]=0.5},
		[WIS] = {[MP]=5, [MDEF]=2.4},
		[ALLATTR] ={[MATT]=2, [PATT]=2.5, [HP]=5.2, [PDEF]=2,[MATT]=2, [MP]=6, [MDEF]=2.4},
		[DEX] = {},
	},
	[CLASS_CHAMPION] = {
		[STR] = {[PATT]=2, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=2.3},
		[INT] = {[MATT]=2, [MP]=1},
		[WIS] = {[MP]=5, [MDEF]=2.2},
		[ALLATTR] ={[MATT]=2, [PATT]=2, [HP]=5.2, [PDEF]=2.3,[MATT]=2, [MP]=6, [MDEF]=2.2},
		[DEX] = {},
	},
	[CLASS_WARLOCK] = {
		[STR] = {[PATT]=0.8, [HP]=0.2},
		[STA] = {[HP]=5, [PDEF]=1.5},
		[INT] = {[MATT]=2, [MP]=1, [PATT]=0.5},
		[WIS] = {[MP]=5, [MDEF]=3.0},
		[ALLATTR] ={[MATT]=2, [PATT]=1.3, [HP]=5.2, [PDEF]=1.5,[MATT]=2, [MP]=6, [MDEF]=3.0},
		[DEX] = {},
	},
}
local CLASS_SCORE ={
	[CLASS_WARRIOR] = {
		[STR] = 4,
		[STA] = 3.7,
		[INT] = 0,
		[WIS] = 0,
		[DEX] = 2.5,
		[MATT] = 0,
		[PATT]= 5,
		[MDEF] = 0,
		[PDEF] = 0.25,
		[HP] = 3,
		[MP] = 0,
		[PDAM] = 5,
		[MDAM] = 0
	},
	[CLASS_SCOUT] = {
		[STR] = 3.7,
		[STA] =  3.5,
		[INT] = 0,
		[WIS] = 0,
		[DEX] = 4,
		[MATT] = 0,
		[PATT]= 5,
		[MDEF] = 0.1,
		[PDEF] = 0.2,
		[HP] = 3,
		[MP] = 0,
		[PDAM] = 5,
		[MDAM] =  0
	},
	[CLASS_ROGUE] = {
		[STR] = 0,
		[STA] =  3.5,
		[INT] = 0,
		[WIS] = 0,
		[DEX] = 4,
		[MATT] = 0,
		[PATT]= 5,
		[MDEF] = 0.1,
		[PDEF] = 0.2,
		[HP] = 3,
		[MP] = 0,
		[PDAM] = 5,
		[MDAM] = 0;
	},
	[CLASS_MAGE] = {
		[STR] = 0,
		[STA] = 3.5,
		[INT] = 4,
		[WIS] = 2,
		[DEX] = 0,
		[MATT] = 5,
		[PATT]= 0,
		[MDEF] = 0.2,
		[PDEF] = 0,
		[HP] = 3,
		[MP] = 2,
		[MDAM] = 5,
		[PDAM] = 0
	},
	[CLASS_PRIEST] = {
		[STR] = 0,
		[STA] =  4,
		[INT] = 2,
		[WIS] = 5,
		[DEX] = 0,
		[MATT] = 5,
		[PATT]= 0,
		[MDEF] = 0.2,
		[PDEF] = 0,
		[HP] = 4,
		[MP] = 0,
		[MDAM] = 5,
		[PDAM] = 0
	},
	[CLASS_KNIGHT] = {
		[STR] = 3,
		[STA] = 4,
		[INT] = 0,
		[WIS] = 2,
		[DEX] = 0,
		[MATT] = 0,
		[PATT]= 5,
		[MDEF] = 0,
		[PDEF] = 0.35,
		[HP] = 4,
		[MP] = 2,
		[PDAM] = 5,
		[MDAM] = 0;
	},
	
	
	
	-- some said only less wisdom
	[CLASS_DRUID] = {
		[STR] = 0,
		[STA] =  4,
		[INT] = 2,
		[WIS] = 4.2,
		[DEX] = 0,
		[MATT] = 5,
		[PATT]= 0,
		[MDEF] = 0.2,
		[PDEF] =  0,
		[HP] = 4,
		[MP] = 0,
		[MDAM] = 5,
		[PDAM] = 0
	},
	--played as PDD
	[CLASS_WARDEN] = {
		[STR] = 4,
		[STA] = 3.7,
		[INT] = 0,
		[WIS] = 0,
		[DEX] = 0,
		[MATT] = 0,
		[PATT]= 5,
		[MDEF] = 0,
		[PDEF] = 0.2,
		[HP] = 3,
		[MP] = 2,
		[PDAM] = 5,
		[MDAM] = 0
	},
	[CLASS_CHAMPION] = {
		[STR] = 4,
		[STA] = 3.7,
		[INT] = 0,
		[WIS] = 0,
		[DEX] = 0,
		[MATT] = 0,
		[PATT]= 5,
		[MDEF] = 0,
		[PDEF] = 0.3,
		[HP] = 3,
		[MP] = 2,
		[PDAM] = 5,
		[MDAM] = 0
	},
	[CLASS_WARLOCK] = {
		[STR] = 0,
		[STA] = 3.5,
		[INT] = 4,
		[WIS] = 2,
		[DEX] = 0,
		[MATT] = 5,
		[PATT]= 0,
		[MDEF] = 0.2,
		[PDEF] = 0,
		[HP] = 3,
		[MP] = 2,
		[MDAM] = 5,
		[PDAM] = 0
	}
}
local CLASS_ARMOR = {

	[CLASS_WARRIOR] = {
		itemtypes[1][1].Name,itemtypes[1][2].Name,itemtypes[1][3].Name
	},
	[CLASS_SCOUT] = {
		itemtypes[1][2].Name,itemtypes[1][3].Name
	},
	[CLASS_ROGUE] =  {
		itemtypes[1][2].Name,itemtypes[1][3].Name
	},
	[CLASS_MAGE] = {
		itemtypes[1][3].Name
	},
	[CLASS_PRIEST] = {
		itemtypes[1][3].Name
	},
	[CLASS_KNIGHT] = {
		itemtypes[1][0].Name, itemtypes[1][1].Name,itemtypes[1][2].Name,itemtypes[1][3].Name
	},
	[CLASS_DRUID] = {
		itemtypes[1][3].Name
	},
	[CLASS_WARDEN]  = {
		itemtypes[1][1].Name,itemtypes[1][2].Name,itemtypes[1][3].Name
	},
	[CLASS_CHAMPION] = {
		itemtypes[1][1].Name,itemtypes[1][2].Name,itemtypes[1][3].Name
	},
	[CLASS_WARLOCK] = {
		itemtypes[1][3].Name
	}
};
local CLASS_WEAPON = {
	[CLASS_WARRIOR] = {
		itemtypes[0][1].Name
	},
	[CLASS_SCOUT] = {
		itemtypes[0][5].Name,itemtypes[0][3].Name
	},
	[CLASS_ROGUE] =  {
		itemtypes[0][3].Name,itemtypes[0][0].Name
	},
	[CLASS_MAGE] = {
		itemtypes[0][4].Name
	},
	[CLASS_PRIEST] = {
		itemtypes[0][4].Name
	},
	[CLASS_KNIGHT] = {
		itemtypes[0][0].Name,itemtypes[1][5][0].Name
	},
	[CLASS_DRUID] = {
		itemtypes[0][4].Name
	},
	[CLASS_WARDEN]  = {
		itemtypes[0][0].Name
	},
	[CLASS_CHAMPION] = {
		itemtypes[0][2].Name
	},
	[CLASS_WARLOCK] = {
		itemtypes[0][4].Name
	}
}
-- I need a way to move with numbers;
local function moveTo2(item,class, position)
	item:update()

	if item.Empty or not item.Available then
		return
	end

	-- Special case for bank. Check if it's open
	if item.Location == "bank" then
		local BankClosed = memoryReadIntPtr(getProc(),addresses.bankOpenPtr, addresses.bankOpen_offset) == -1
		if BankClosed then
			return
		end
	end

	-- Cursor should be clear before starting a move
	if cursor:hasItem() then
		cursor:clear()
	end

	-- Check if itemshop item
	if (bag == "itemshop" or bag == "isbank") and not item.ItemShopItem then
		-- Item is not itemshop item. Cannot be put in itemshop bag or is bank
		return
	end

	-- Get range to move to / = getInventoryRange(bag)
	local first, last, location 
	first = position;
	last = position;
	location = class;
	if first == nil or bag == "all" then
		printf("You must specify a valid location to move the item to. You cannot use \"all\".\n")
		return
	end

	-- Check if already in bag
	if item.SlotNumber >= first and item.SlotNumber <= last and item.Location == location then
		return
	end

	-- Can't move bound items to guild bank
	if location == "guildbank" and item.Bound then
		return
	end

	-- Check if bank is open
	if location == "bank" then
		local BankClosed = memoryReadIntPtr(getProc(),addresses.bankOpenPtr, addresses.bankOpen_offset) == -1
		if BankClosed then
			return
		end
	end

	-- Get the tolocation class
	local toLocation
	if location == "inventory" then
		toLocation = inventory
	elseif location == "bank" then
		toLocation = bank
	elseif location == "equipment" then
		toLocation = equipment
	elseif location == "guildbank" then
		if #guildbank.BagSlot == 0 then guildbank:update() end
		toLocation = guildbank
	end

	-- Deal with moving to equipment first. It has special needs.
	if location == "equipment" then
		-- Check if is type equipment
		if item.ObjType ~= 0 and item.ObjType ~= 1 then
			return
		end

		if bag == "equipment" or bag == "amulets" then -- No particular slot. Just use item to equip.
			item:use()
		else
			item:pickup()
			equipment.BagSlot[first]:pickup()
		end

		return
	end

	-- Try to find a stack to merge with
	if item.MaxStack > 1 and item.ItemCount < item.MaxStack then
		for slot = first, last do
			local toItem = toLocation.BagSlot[slot]
			toItem:update()
			if toItem.Available and item.Id == toItem.Id and toItem.ItemCount < toItem.MaxStack then -- merge
				if (location == "guildbank" or item.Location == "guildbank") and location ~= item.Location then
					-- Guild bank need 2 step merge
					local tmpempty = toLocation:findItem(0,bag)
					if tmpempty then

						item:pickup()

						-- If couldn't pick up, give up
						if not cursor:hasItem() then
							return
						end

						tmpempty:pickup() -- put down

						-- If failed to place item then return to origin
						if cursor:hasItem() then
							item:pickup()
							return
						end

						tmpempty:pickup() -- pick up

						toItem:pickup()

						-- If failed to place item then return to origin
						if cursor:hasItem() then
							tmpempty:pickup()
						end
					end
				else
					-- Normal merge
					item:pickup()

					toItem:pickup()
				end

				if item.ItemCount + toItem.ItemCount <= item.MaxStack then
					return
				else
					yrest(ITEM_REUSE_DELAY)
				end
			end
		end
	end

	-- Put the rest in an empty slot
	if not item.Empty then
		local empty = toLocation:findItem(0, bag)

		if empty then
			item:pickup()

			empty:pickup()
			if item.Location == "guildbank" then yrest(500) end
		end
	end
end
local function printRater(tmp)

	if (tmp == nil )then
		return nil
	end
	print("=========================================")
	printf("%s, Id %d, BaseItemAddress %X\n",tmp.Name,tmp.Id,tmp.BaseItemAddress)
	print("-----------------------------------------")
	if tmp.Address then
		printf("Address\t%X\n",tmp.Address)
	end
	printf("\tObject types\t%s\t%s\t",itemtypes[tmp.ObjType].Name,itemtypes[tmp.ObjType][tmp.ObjSubType].Name)
	if itemtypes[tmp.ObjType][tmp.ObjSubType][tmp.ObjSubSubType] then
		print(itemtypes[tmp.ObjType][tmp.ObjSubType].Name)
	else
		print()
	end

	print("\tRequired level", tmp.RequiredLvl)
	print("\tValue",tmp.Value)
	if tmp.Speed then
			print("\tSpeed",tmp.Speed)
	end
	print("\tEffects:")
	for k,v in pairs(tmp.Effects) do
		print("\t\t+"..v,getTEXT("SYS_WEAREQTYPE_"..k))
	end
end
local function haveCard(idorname)
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
local function eraseRest(sellprize, rarity, drop, logg , ignore)

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
	local weapontype = itemtypes[0].Name
	local armortype = itemtypes[1].Name
	local recepiestype = itemtypes[4].Name
	local monstercardtype = itemtypes[6].Name
	local potiontype = itemtypes[2][0].Name
	local runestype = itemtypes[5][1].Name
	local productionrunetype  =  itemtypes[3][4].Name
	
	local search = true;
	 guild = RoMScript("GetGuildInfo()")
	 PutMaterialsIn = "guild";
	while (search) do
		search = false;
		for i, item in pairs(inventory.BagSlot) do
			if(item.Id == 203635 or item.Id == 203028 or item.Id == 204555) then
				printf("Using Bag:  "..item.Name.."\n");
				item:use();
				yrest(200);
				search = true;
			elseif(item.Id == 202928 or item.Id == 202930 or item.Id == 208932 or  item.Id == 202929 or  item.Id == 203487 or item.Id == 203577 or item.Id == 203578 ) then
				printf("Using Arcane Charge:  "..item.Name.."\n");
				item:use();
				yrest(200);
				search = true;
			elseif(item.Id ==205819)then
				printf("opening Box:  "..item.Name.."\n");
				item:use();
				yrest(200);
				search = true;
			end
		end
	end
	for i, item in pairs(inventory.BagSlot) do
		if (item.SlotNumber >= settings.profile.options.INV_AUTOSELL_FROMSLOT + 60 and
		settings.profile.options.INV_AUTOSELL_TOSLOT + 60 >= item.SlotNumber) or (ignore and item.SlotNumber > 60)  then
			
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
				if (item:isType(weapontype) or item:isType(armortype)) and sellprize > item.Worth and item.Quality < rarity then
					printf("Deleting Item:  "..item.Name.."\n");
					if logg == true then
						logInfo("CleanBag", "" ..player.Name.. ": Deleted: " ..item.Name.. "." , true)
					end
					item:delete();
				elseif item:isType(recepiestype) then
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
				elseif item:isType( monstercardtype) then
					if not haveCard(item.Id) then
						printf("Using card:  "..item.Name.."\n");
						if logg == true then
							logInfo("UseCard", "" ..player.Name.. ": Using card:  " ..item.Name.. "." , true);
						end
						item:use();
						yrest(5000);
					end
				-- elseif item:isType(potiontype) and item.RequiredLvl < player.Level - 20 then
					-- if not string.find(item.Name, "Phirius") then
						-- item:delete();
					-- end
				elseif item:isType(runestype) or item:isType(productionrunetype) then
					item:delete();
				elseif(item.Id == 202928 or item.Id == 202930 or item.Id == 208932 or  item.Id == 202929 or  item.Id == 203487 or item.Id == 203577 or item.Id == 203578) then
						printf("Using Arcane Charge:  "..item.Name.."\n");
						item:use();
						yrest(200);
				end
					
			end
		end
	end
		if GuildDonate == nil then
			print("Unable to donate to guild. Move to Itemshop bag. Need \"GuildDonate\" userfunction.")
			PutMaterialsIn     = "itemshop"
		elseif guild == nil or guild == "" then
			print("Unable to donate to guild. Character not a member of a guild. Move to itemshop bag")
			PutMaterialsIn     = "itemshop"
		else
			
			inventory:update()
			GuildDonate("all",8)
		end
		if string.lower(PutMaterialsIn) == "itemshop" then
		
			inventory:update()
			for i = 61,240 do
				local item = inventory.BagSlot[i]
				if (not item.Empty) and item.Available and ((item.ObjType == 3 and -- Type Materials
						item.ObjSubType == 0) or item.ObjSubType == 1 or item.ObjSubType == 2 or item.Id == 207326 or item.Id == 207329 or item.Id == 207929 or item.Id == 207325 or item.Id == 207330) then -- SubType Ore, Herbs or Wood
					 cprintf(cli.yellow,"Placing %s in the itemshop backpack.\n",item.Name)
					 item:moveTo("itemshop")
						yrest(1000)
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
local function findEquipPosition( key1, key2, key3 )
	
--	local function cl( string_in) 
	
	--	return string.lower(string_in)
	--end
	--head
	if key1 == itemtypes[1][1][0].Name or key2 == itemtypes[1][1][0].Name or key3 == itemtypes[1][1][0].Name then
		return 0;
	end
	--hands
	if key1 == itemtypes[1][1][4].Name or key2 == itemtypes[1][1][4].Name or key3 == itemtypes[1][1][4].Name then
		return 1;
	end
	--feet
	if key1 == itemtypes[1][1][5].Name or key2 == itemtypes[1][1][5].Name or key3 == itemtypes[1][1][5].Name then
		return 2;
	end
	--chest
	if key1 == itemtypes[1][1][1].Name or key2 == itemtypes[1][1][1].Name or key3 == itemtypes[1][1][1].Name then
		return 3;
	end
	--legs
	if key1 == itemtypes[1][1][3].Name or key2 == itemtypes[1][1][3].Name or key3 == itemtypes[1][1][3].Name then
		return 4;
	end
	--cape
	if key1 == itemtypes[1][1][6].Name or key2 == itemtypes[1][1][6].Name or key3 == itemtypes[1][1][6].Name then
		return 5;
	end
	--belt
	if key1 == itemtypes[1][1][2].Name or key2 == itemtypes[1][1][2].Name or key3 == itemtypes[1][1][2].Name then
		return 6;
	end
	--shoulders
	if key1 == itemtypes[1][1][7].Name or key2 == itemtypes[1][1][7].Name or key3 == itemtypes[1][1][7].Name then
		return 7;
	end
	--necklace
	if key1 == itemtypes[1][4][2].Name or key2 == itemtypes[1][4][2].Name or key3 == itemtypes[1][4][2].Name then
		return 8;
	end
	--range weapon
	if key1 == itemtypes[0][5].Name or key2 == itemtypes[0][5].Name or key3 == itemtypes[0][5].Name then
		return 10;
	end
	-- main hand
	if key1 == itemtypes[0].Name or key2 == itemtypes[0].Name or key3 == itemtypes[0].Name then
		return 15;
	end
	--wings
	if key1 == itemtypes[1][7].Name or key2 == itemtypes[1][7].Name or key3 == itemtypes[1][7].Name then
		return 21;
	end

	return -1;
end
local function evalWeaponType( item )
	local answer = false;
	
	for i =1,6 do
		if CLASS_WEAPON[player.Class1][i] ~= nil then
			if( item:isType(CLASS_WEAPON[player.Class1][i]))then
				answer = true;
			end
		end
	end
		
	return answer;
end
local function evalArmorType( item )

	local answer = false;
	
	for i =1,6 do
		if CLASS_ARMOR[player.Class1][i] ~= nil then
			if( item:isType(CLASS_ARMOR[player.Class1][i]))then
				answer = true;
			end
		end
	end
		
	return answer;


end
local function scoreAll()
	
	local result = {{{{}}}}
	
	for i, item in pairs(inventory.BagSlot) do
		local objtype, objsubtype, objsubsubtype, objsubsubuniquetype = item:getTypes()
		--armor and necklese 
		if(item.Name ~="<EMPTY>" and i > 50 and (item:isType( itemtypes[1].Name) and evalArmorType(item)) or item:isType(itemtypes[1][4][2].Name) or item:isType(itemtypes[1][3][6].Name) ) then
			
			local score = getItemScore( item )
			-- init all arrays
			if(result[objtype] == nil)then
				result[objtype] = {};
			end
			if result[objtype][objsubtype] == nil then
				result[objtype][objsubtype] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] = {};
			end
			
			if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score ~= nil)then
				if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score < score)then
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score = score;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Item = item;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].BagSlot = i;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "normal";
				end
			else
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score = score;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Item = item;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].BagSlot = i;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "normal";
			end
			--weapons and left hand 
		elseif(item.Name ~="<EMPTY>" and i > 50 and (item:isType(itemtypes[0].Name) or item:isType(itemtypes[1][5].Name)) and evalWeaponType(item) and not item:isType(itemtypes[0][3].Name)) then
		
			local score = getItemScore( item )
			
			if(result[objtype] == nil)then
				result[objtype] = {};
			end
			if result[objtype][objsubtype] == nil then
				result[objtype][objsubtype] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] = {};
			end
			
			if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score ~= nil)then
				if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score < score)then
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score = score;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Item = item;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].BagSlot = i;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "normal";
				end
			else
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Score = score;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Item = item;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].BagSlot = i;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "normal";
			end
			-- we comapre all daggers in the bags
		elseif(item.Name  ~="<EMPTY>" and i > 50 and evalWeaponType(item) and item:isType(itemtypes[0][3].Name)) then
			local score = getItemScore( item )
			--result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1] = {};
			if(result[objtype] == nil)then
				result[objtype] = {};
			end
			if result[objtype][objsubtype] == nil then
				result[objtype][objsubtype] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2] = {};
			end
			
			if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score ~= nil)then
				if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score ~= nil)then
					-- I don't check which of them is crapier in compare this still only for until level 50
					if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score < score)then
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score = score;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Item = item;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].BagSlot = i;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "dagger";
					elseif (result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score < score)then
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score = score;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Item = item;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].BagSlot = i;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "dagger";
					
					end
					
				else
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score = score;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Item = item;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].BagSlot = i;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "dagger";
				end
			else
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score = score;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Item = item;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].BagSlot = i;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "dagger";
			end
		
		--- ears and rings
		elseif(item.Name ~="<EMPTY>" and i > 50 and item:isType(itemtypes[1][4]) ) then
			local score = getItemScore( item )
			--result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1] = {};
			if(result[objtype] == nil)then
				result[objtype] = {};
			end
			if result[objtype][objsubtype] == nil then
				result[objtype][objsubtype] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1] = {};
			end
			if result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2] == nil then
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2] = {};
			end
			
			if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score ~= nil)then
				if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score ~= nil)then
					if(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score < score)then
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score = score;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Item = item;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].BagSlot = i;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "jewles";
					elseif(result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score < score)then
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score = score;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Item = item;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].BagSlot = i;
						result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "jewles";
					end
				else
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Score = score;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].Item = item;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][2].BagSlot = i;
					result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "jewels";
					-- I don't check which of them is crapier in compare this still only for until level 50
					
				end
				
			else
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Score = score;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].Item = item;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1][1].BagSlot = i;
				result[objtype][objsubtype][objsubsubtype or -1][objsubsubuniquetype or -1].Type = "jewels";
			end
		
		end
	end
	
	return result;
end

local function addEffects(tabel, address, dura)
	dura = dura or 1
	local place = 0
	local effectId = memoryReadInt(getProc(),address+0xB8)
	
	while effectId > 0 do
	--	print("effectId: "..effectId.."");
		if CLASS_EFFECT[player.Class1][effectId] then
			local size = memoryReadInt(getProc(),address+0xB8+place+0x28)
		--	print("effect size: "..size.."");
			for eff,mul in pairs (CLASS_EFFECT[player.Class1][effectId]) do
				tabel[eff] = (tabel[eff] or 0) + size * mul * dura
			end
		else
			tabel[effectId] = (tabel[effectId] or 0) + memoryReadInt(getProc(),address+0xB8+place+0x28)* dura
		end
		place = place + 4
		effectId = memoryReadInt(getProc(),address+0xB8+place)
	end
end
local function addEffects2(tabel, address, dura)
	dura = dura or 1
	local place = 0
	local effectId = memoryReadInt(getProc(),address+0x98)
	
	while effectId > 0 do
	--	print("effectId: "..effectId.."");
		if CLASS_EFFECT[player.Class1][effectId] then
			local size = memoryReadInt(getProc(),address+0x98+place+0x28)
			--print("effect size: "..size.."");
			for eff,mul in pairs (CLASS_EFFECT[player.Class1][effectId]) do
				tabel[eff] = (tabel[eff] or 0) + size * mul * dura
			end
		else
			tabel[effectId] = (tabel[effectId] or 0) + memoryReadInt(getProc(),address+0x98+place+0x28)* dura
		end
		place = place + 4
		effectId = memoryReadInt(getProc(),address+0x98+place)
	end
end

function getRaterDataById(id,exclude_stats)
	local tmp = {}
	tmp.Id = id
	tmp.Name = GetIdName(id)
	tmp.BaseItemAddress = GetItemAddress(id)
	if tmp.BaseItemAddress == nil or tmp.BaseItemAddress == 0 then
		return tmp
	end

	tmp.ObjType = memoryReadInt(getProc(),tmp.BaseItemAddress+0x78)
	tmp.ObjSubType = memoryReadInt(getProc(),tmp.BaseItemAddress+0x7C)
	tmp.ObjSubSubType = memoryReadInt(getProc(),tmp.BaseItemAddress+0x80)

	-- is equipment
	if (tmp.ObjType == 0 and tmp.ObjSubType ~= -1 and (tmp.ObjSubType ~= 5 or tmp.ObjSubSubType == 1) and tmp.ObjSubType ~= 6 and tmp.ObjSubType ~= 7) or
	(tmp.ObjType == 1 and tmp.ObjSubType ~= 6 and tmp.ObjSubType ~= 7) then
		if tmp.ObjType == 0 then -- Weapon
			tmp.Speed = memoryReadInt(getProc(),tmp.BaseItemAddress+0x190)/10
		end
		tmp.RequiredLvl = memoryReadInt(getProc(),tmp.BaseItemAddress+0x58)
		tmp.Value = memoryReadInt(getProc(),tmp.BaseItemAddress+0x34)

		tmp.Effects = {}

		-- Base item effects
		addEffects(tmp.Effects, tmp.BaseItemAddress)

		-- Base item stat effects
		tmp.StatCount = 0
		if exclude_stats ~= true then
			for i = 1, 6 do
				local statId = memoryReadUInt( getProc(), tmp.BaseItemAddress + 0x114 + 0x8*(i-1) );
				if statId == 0 then -- No More stats
					break
				end
				tmp.StatCount = tmp.StatCount + 1
				local tmpidaddress = GetItemAddress(statId)
				addEffects(tmp.Effects,tmpidaddress)
			end
		end
	end
	--printRater(tmp)
	return tmp
end

function getRaterDataByItem(item)
	if item == nil then
		return item;
	end
	item:update()
	if item.BaseItemAddress == nil then
		print("This Item has no addresse Name: "..item.Name.."");
		return item;
	end
	local tmp = {}
	tmp.Id = item.Id
	tmp.Name = item.Name
	tmp.Address = item.Address
	tmp.BaseItemAddress = item.BaseItemAddress

	tmp.ObjType = item.ObjType
	tmp.ObjSubType = item.ObjSubType
	tmp.ObjSubSubType = item.ObjSubSubType

	if (tmp.ObjType == 0 and tmp.ObjSubType ~= -1 and (tmp.ObjSubType ~= 5 or tmp.ObjSubSubType == 1) and tmp.ObjSubType ~= 6 and tmp.ObjSubType ~= 7) or
	(tmp.ObjType == 1 and tmp.ObjSubType ~= 6 and tmp.ObjSubType ~= 7) then
		if tmp.ObjType == 0 then -- Weapon
			tmp.Speed = memoryReadInt(getProc(),tmp.BaseItemAddress+0x190)/10
		end

		local dura = 1.0
		if item.Durability > 100 or item.Durability > item.MaxDurability then
			dura = 1.2
		end

		local plusQuality = memoryReadByte( getProc(), item.Address + addresses.qualityTierOffset );
	--	print("Quality: "..plusQuality.."")
		local quality, tier = math.modf ( plusQuality / 16 );
		tier = tier * 16 - 10;
	--	print("Tier: "..tier.."")
		tmp.RequiredLvl = item.RequiredLvl
		tmp.Value = item.Value

		tmp.Effects = {}

		-- Base item effects
		addEffects(tmp.Effects, tmp.BaseItemAddress, dura)

		-- Apply tier bonus to damage and defence. Before stat and runes effects are added.
		if tier ~= 0 then
			if tmp.Effects[PDAM] then
				tmp.Effects[PDAM] = tmp.Effects[PDAM] + (tmp.Effects[PDAM]*0.1 * tier)
			elseif tmp.Effects[PDAM] then
				tmp.Effects[MDAM] = tmp.Effects[MDAM] + (tmp.Effects[MDAM]*0.1 * tier)
			elseif tmp.Effects[PDAM] then
				tmp.Effects[PDEF] = tmp.Effects[PDEF] + (tmp.Effects[PDEF]*0.1 * tier)
			elseif tmp.Effects[PDAM] then
				tmp.Effects[MDEF] = tmp.Effects[MDEF] + (tmp.Effects[MDEF]*0.1 * tier)
			end
		end

		-- Stat effects
		tmp.StatCount = #item.Stats
		for k,v in pairs(item.Stats) do
			local statBaseAddress = GetItemAddress(v.Id)
			addEffects(tmp.Effects, statBaseAddress, dura)
		end

		-- Rune effects
		for k,v in pairs(item.Runes) do
			local runeBaseAddress = GetItemAddress(v.Id)
			addEffects(tmp.Effects,runeBaseAddress, dura)
		end

		-- Plus value
		local plus = memoryReadUByte(getProc(), item.Address + 0x17)
		--print("plus: "..plus.."");
		if plus > 0 then
			local tmpid = memoryReadInt(getProc(), item.BaseItemAddress+0x3AC) + plus
			--print("tmpid: "..tmpid.."");
			local tmpidaddress = GetItemAddress(tmpid)
			--print("tmpidaddress: "..tmpidaddress.."");
			addEffects2(tmp.Effects, tmpidaddress, dura)
		end
	end
	--printRater(tmp)
	return tmp
end
function getItemScore( item )
	
	tmp = getRaterDataByItem(item);
--	 printRater(tmp)
	if not tmp or tmp.Effects == nil then
		return nil;
	end
	local score = 0;
			
	for type,value in pairs(tmp.Effects) do
		if( CLASS_SCORE[player.Class1][type] )then
			score = CLASS_SCORE[player.Class1][type] * value + score;
		else
			print("Unknown type for this class: "..type.."");
		end
	end
--	print("Item: "..tmp.Name.." with score: "..score.."");
	return score;
end

local function equipSafe (item, pos)

	local will_bound = false;
	if(item.BoundStatus == 3 or item.BoundStatus == 4)then
		will_bound = true
	end
	if (equipment.BagSlot[pos] ~= nil)then
		local empty = 70;
		for i = 50 ,#inventory.BagSlot do
			if inventory.BagSlot[i].Id == 0 then
				empty = i;
				break;
			end
		end
		equipment.BagSlot[pos]:moveTo("inventory");
	end
	-- move that Item 
	moveTo2(item, "equipment", pos);
	
	if(will_bound)then
		RoMScript("StaticPopup_OnClick(StaticPopup1, 1);")
		yrest(500)
		RoMScript("StaticPopup_OnClick(StaticPopup1, 1);")
		yrest(500)
		RoMScript("StaticPopup_OnClick(StaticPopup1, 1);")
	end

end
local function equipBest()
	
	local result = scoreAll();
	-- we equip
	for key1,v1 in pairs(result) do
		for key2,v2 in pairs(v1) do
			for key3,v3 in pairs(v2) do
				for key4,v4 in pairs(v3) do
					if result[key1][key2][key3][key4].Type == "normal" then
						if not (result[key1][key2][key3][key4]["BagSlot"] <= 21) then
							local item = result[key1][key2][key3][key4]["Item"];
							local score_new = 0;
							local score_old = 0;
							local old_item = nil;
							local pos;
							score_new = result[key1][key2][key3][key4]["Score"];
							
							pos = findEquipPosition(key1,key2,key3)
							if(pos == -1)then
								error("could not find position for item: "..item.Name.." with key1: "..key1.." with key2: "..key2.." with key3: "..key3.." and key4: "..key4.."");
							end
							old_item = equipment.BagSlot[pos];
							if(old_item and old_item.Name ~= "<EMPTY>")then
								--print("Vergleiche");
								score_old = getItemScore(old_item);
							end
							if( score_old == nil)then
								print("Something is wrong with: "..old_item.Name.." AT POS: "..pos.." At keys: "..item.Name.." with key1: "..key1.." with key2: "..key2.." with key3: "..key3.." and key4: "..key4.."");
								score_old = 0;
							end
							if( score_new  > (score_old + 1))then
								cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,score_new,score_old ); -- Open/equip item:
								equipSafe(item,pos);
							end
								
						end
					elseif result[key1][key2][key3][key4].Type == "dagger" then
						--items
						local item_main = equipment.BagSlot[15];
						local item_off = equipment.BagSlot[16];
						if(item_main)then
							item_main:update();
						end
						if(item_off)then
							item_off:update()
						end
						--ids
						local id_main =0;
						local id_off = 0;
						if(item_main)then
							id_main= item_main.Id;
						end
						if(item_off)then
							id_off = item_off.Id;
						end
						--score
						local score_main,score_off = 0,0; 
						score_main = getItemScore(item_main);
						if(item_off and item_off.Name ~= "<EMPTY>") then
							 score_off = getItemScore(item_off);
						end
						if(item_main and item_main.Name ~= "<EMPTY>") then
							 score_main = getItemScore(item_main);
						end
						
						if not (result[key1][key2][key3][key4][1]["BagSlot"] <= 21) then
							local item = result[key1][key2][key3][key4][1]["Item"];
							local score_new = result[key1][key2][key3][key4][1]["Score"]
							if((score_off + 1) < score_new)then
								if score_off == 0 then
									cprintf(cli.lightblue, "We found a dagger and our off-hand is empty we try to equip item: %s with score %f", item.Name,score_new); -- Open/equip item:
								else
									printf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,score_new,score_off ); -- Open/equip item
								end
								equipSafe(item,16);
								inventory:update();
								equipment:update();
								-- 16 left hand
								if( equipment.BagSlot[16] == nil)then
									-- WE LOST IT FIND IT
									
									item_main = inventory:findItem(id_main) or equipment:findItem(id_main);
									
									if equipment.BagSlot[15] ~= item_main then
										cprintf(cli.lightred,"Sry that didn't work we will undo this"  ); -- Open/equip item:
										equipSafe(item_main,15);
									end
									item_off = equipment:findItem(id_off) or inventory:findItem(id_off);
									
								end
								if( item_main and equipment.BagSlot[16] == nil and  score_main < result[key1][key2][key3][key4][1]["Score"])then
									cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,score_new,score_main ); -- Open/equip item
									equipSafe(item_off, 15);
									equipment:update();
								end
							elseif( item_main and (score_main + 1) < result[key1][key2][key3][key4][1]["Score"])then
								cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,score_new,score_main ); -- Open/equip item
								equipSafe(item,"main hand");;
								equipment:update();
		
							end
							--item:use();
						end
						if  result[key1][key2][key3][key4][2]["BagSlot"] ~= nil then
							if not (result[key1][key2][key3][key4][2]["BagSlot"] <= 21) then
								local item = result[key1][key2][key3][key4][2]["Item"];
								local score_new =  result[key1][key2][key3][key4][2]["Score"];
								if((score_off + 1) < score_new)then
									if( score_off == 0)then
										cprintf(cli.lightblue, "We found a dagger and our off-hand is empty we try to equip item: %s with score %f", item.Name,score_new); -- Open/equip item:
									else
										printf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,score_new,score_off ); 
									end
									equipSafe(item,16);
									equipment:update();
									if( equipment.BagSlot[16] == nil)then
									-- WE LOST IT FIND IT
									
									item_main = equipment:findItem(id_main) or inventory:findItem(id_main)
									if item_main and equipment.BagSlot[15]~=item_main then
										cprintf(cli.lightred,"Sry that didn't work we will undo this"  ); -- Open/equip item:
										equipSafe(item_main,15);
									end
									item_off= equipment:findItem (id_off) or inventory:findItem(id_off)
									
									end
									if( equipmentBagSlot[16] == nil and  score_main < result[key1][key2][key3][key4][2]["Score"])then
										cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,score_new,score_main ); -- Open/equip item
										equipSafe(item_off,15);
										equipment:update();
									end
								elseif(item_main and(score_main + 1) < result[key1][key2][key3][key4][2]["Score"])then
									cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,score_new,score_main ); -- Open/equip item
									equipSafe(item,15);;
									equipment:update();
								
								end
							end
						else
							local item_left; 
							local item_right;
							local posleft;
							local posright;
							if( key1 == itemtypes[1][4][1].Name or key2== itemtypes[1][4][1].Name or key3 == itemtypes[1][4][1].Name )then
								item_left = equipment.BagSlot[11];
								item_right = equipment.BagSlot[12];
								posleft = 11;
								posright = 12;
							end
							if( key1 == itemtypes[1][4][0].Name or key2 == itemtypes[1][4][0].Name or key3 == itemtypes[1][4][0].Name )then
								item_left = equipment.BagSlot[13];
								item_right = equipment.BagSlot[14];
								posleft = 13;
								posright = 14;
							end
						
						
							if(item_left) then
								item_left:update();
							end
							if(item_right)then
								item_right:update()
							end
						
						--score
						local score_left = getItemScore(item_left);
						if(item_left) then
							 score_left = getItemScore(item_left);
						end
						-- we have jewels the firt is alway there
						if not (result[key1][key2][key3][key4][1]["BagSlot"] <= 21) then
							local item = result[key1][key2][key3][key4][1]["Item"];
							local scoreItem = getItemScore(item);
							local scoreleft,scoreright = 0,0;	
							if(item_left) then
								scoreleft = getItemScore(item_left);
							end
							if(item_right)then
								scoreright = getItemScore(item_right);
							end
							local answer_a = scoreleft -  scoreItem;
							local answer_b = scoreright -  scoreItem;
							
							if(answer_a > answer_b) then
								cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,scoreItem ,scoreleft ); -- Open/equip item
								equipSafe(item,posleft);;
								
							else
								cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,scoreItem ,scoreright ); -- Open/equip item
								equipSafe(item,posright);;
							
							end
							
						end
						if  result[key1][key2][key3][key4][2]["BagSlot"] ~= nil then
							if not (result[key1][key2][key3][key4][2]["BagSlot"] <= 21) then
								local item = result[key1][key2][key3][key4][2]["Item"];
								
								local scoreItem = getItemScore(item);
								local scoreleft,scoreright = 0,0;	
								if(item_left) then
									scoreleft = getItemScore(item_left);
								end
								if(item_right)then
									scoreright = getItemScore(item_right);
								end
								local answer_a = scoreleft -  scoreItem;
								local answer_b = scoreright -  scoreItem;
								if(answer_a > answer_b) then
									cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,scoreItem ,scoreleft ); -- Open/equip item
									equipSafe(item,posleft);;
									
								else
									cprintf(cli.lightblue, ""..language[171].." because it gearscore is: %f which is better than the old %f", item.Name,scoreItem ,scoreright ); -- Open/equip item
									equipSafe(item,posright);;
									
								end
								
							end
						end
					end
					end
				end
			end
		end
	end
end
function clearAndEquipChar(erase, rarity, safeswitch)
	local safebolt = true;
	if rarity == nil then
		rarity = 2
	end
	
	if(safeswitch and safeswitch == "I know what I'm doing")then
		safebolt = false;
	end
	
	if(player.Level >= 50 and safebolt) then
		return;
	end
	
	inventory:update();
	equipBest()
	
	if(erase)then
		eraseRest(3000, rarity, true, false ,true);
	end
end












