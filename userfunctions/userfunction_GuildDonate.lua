-- =============================================
-- Joint effort by the solarstrike/rom dev team
-- and Rickster, dx876234
-- Version 1.44 (10/01/2012 - mm/dd/yyyy)
-- last edited by: dx876234
-- =============================================

local function GuildDonateBagID(bagid)
	RoMScript("PickupBagItem("..bagid..")")
	RoMScript("GCB_GetContributionItem(n)")
	if RoMScript("CursorHasItem()") then
		RoMScript("PickupBagItem("..bagid..")")            -- Put it back in the bag
	else
		RoMScript("GCB_OnOK()")
	end
end

function GuildDonateItems(itemlist)
	for slot = 61, 240 do
		item = inventory.BagSlot[slot]
		for k, nameid in pairs(itemlist) do
			if item.Name == nameid or item.Id == nameid then
				cprintf(cli.yellow, "Name %s at %d\n", tostring(nameid), item.BagId)
				GuildDonateBagID(item.BagId)
			end
		end
	end
end

function GuildDonate(_type, _quality, _lesser)
	inventory:update()	
	local oreTypeName	= itemtypes[3][0].Name
	local woodTypeName	= itemtypes[3][1].Name
	local herbTypeName	= itemtypes[3][2].Name
	local donated = false;
	local local_debug_mode = false;
		
	if ( _type == nil and _quality == nil and _lesser == nil ) then 
		_lesser = "true"
		_type = "all"
		_quality = 15
	end



	-- argument fool proofing
	if ( _type == "white" or _type == "green" or _type == "blue" or _type == "purple" ) then _quality = _type end

	-- _lesser if "true" then lesser qualities will be donated, otherwise only specified quality will be donated.

	-- for _quality use names "white", "green", "blue", "purple", "orange", "gold".

	if _quality == "white" then _quality = 0
	elseif _quality == "green" then _quality = 1
	elseif _quality == "blue" then _quality = 2  
	elseif _quality == "purple" then _quality = 3 
	elseif _quality == "orange" then _quality = 4 
	elseif _quality == "gold" then _quality = 5  
	elseif (type(_quality) == "number" and (_quality >= 0 and 15 >= _quality)) then 
		-- _quality is given as a number between 0 and 15
	else 
		error("Error in function call GuildDonate(_type, _quality, _lesser), check \"_quality\"!",0);
	end
	if local_debug_mode then
		cprintf_ex("|purple| DEBUG: Donate quality is set to: %s.\n", _quality)
		player:sleep();
	end;

	if (_type == "wood" or _type == "woods") then _type = woodTypeName
	elseif (_type == "ore" or _type == "ores") then _type = oreTypeName
	elseif (_type == "herb" or _type == "herbs") then _type = herbTypeName
	elseif (_type == "all" or _type == "All") then _type = "all" 
	else 
		error("Error in function call GuildDonate(_type, _quality, _lesser), check \"_type\"!",0);
	end
	if local_debug_mode then
		cprintf_ex("|purple| DEBUG: Donate type is set to: %s.\n", _type)
		player:sleep();
	end;
	
	if local_debug_mode then
		cprintf_ex("|purple| Donating %s to guild ...\n", _type);
	end;

	local item;
	for slot = 61, 240 do
		item = inventory.BagSlot[slot];
		if ( _type == "all" and (item:isType(woodTypeName) or item:isType(oreTypeName) or item:isType(herbTypeName)) ) or ( _type ~= "all" and item:isType(_type) ) then
			if  _lesser == "true"  then -- Donates quality stated and lesser
				if _quality >= item.Quality then
					local itemtype, itemsubtype, itemsubsubtype = item:getTypes()
					cprintf_ex("|lightgreen| Donating  %s %s (%s) ...\n", item.ItemCount, item.Name, itemsubtype)
					if local_debug_mode then player:sleep(); end;

					GuildDonateBagID(item.BagId)
					donated = true;
				end
			elseif _quality == item.Quality then
				local itemtype, itemsubtype, itemsubsubtype = item:getTypes()
				cprintf_ex("|lightgreen| Donating  %s %s (%s) ...\n", item.ItemCount, item.Name, itemsubtype)
				if local_debug_mode then player:sleep(); end;
				
				GuildDonateBagID(item.BagId)
				donated = true;
			end
		end
	end
	if not donated then
		cprintf_ex("|lightgreen| There was nothing to donate to the guild.\n");
	end;

	if local_debug_mode then
		cprintf_ex("|purple| Donation finished.\n");
	end;
end