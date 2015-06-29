--==<<             Rock5's craftItem function                 >>==--
--==<<              By Rock5     Version 1.22                 >>==--
--==<<
--==<<  www.solarstrike.net/phpBB3/viewtopic.php?f=27&t=2407  >>==--

local craftingCountPtr = addresses.skillsTableBase + 0x50
local craftingCount_offset = 0x20

function craftItem(_itemNameOrGUID, _craftNumber)
	-- Check _itemNameOrGUID
	if type(_itemNameOrGUID) ~= "string" and type(_itemNameOrGUID) ~= "number" then
		error("Argument #1 to 'CraftItem()': Expected type 'string' or 'number', got '" .. type(_itemNameOrGUID) .. "'.")
	end

	-- Shorten name if too long so macro is not too long.
	-- Take some from start and some from end to make sure we have important part of name.
	if type(_itemNameOrGUID) ~= "string" then
		local maxNameLen = 30 -- Maximum length of name without making macro command too long.
		local truncate = math.floor(maxNameLen/2-1)
		local len = string.len(_itemNameOrGUID)
		if len > maxNameLen then
			_itemNameOrGUID = string.sub(_itemNameOrGUID, 1, truncate) .. ".*" .. string.sub(_itemNameOrGUID, -truncate, -1)
		end
	end

	local GUID, itemName, maxCraft = findItemToCraft(_itemNameOrGUID)
	while itemName ~= nil do

		local toCraft = 1
		if _craftNumber ~= nil then
			if _craftNumber == "all" or _craftNumber > maxCraft then
				toCraft = maxCraft
			else
				toCraft = _craftNumber
			end
		end


		local goal = toCraft
		local last = 0
		repeat
			goal = goal - last
			last = 0
			cprintf(cli.yellow,"Crafting " .. goal .. " " .. itemName .. "\n")

			local c = 0
			repeat
				c = c + 1
				RoMScript("CreateCraftItem("..GUID..",".. goal ..", 0)")
				yrest(200)
			until memoryReadRepeat("intptr", getProc(), addresses.castingBarPtr, addresses.castingBar_offset) == 3 or c == 3

			-- Failed to start crafting
			if memoryReadRepeat("intptr", getProc(), addresses.castingBarPtr, addresses.castingBar_offset) == 0 then
				printf("Failed to craft. Make sure you are near the correct crafting tools.\n")
				return
			end

			-- wait until crafting stops
			repeat
				yrest(500)
				local count = memoryReadRepeat("intptr", getProc(), craftingCountPtr, craftingCount_offset)
				if count > 0 then
					last = count
				end
				displayProgressBar(last/goal*100, 30)
			until memoryReadRepeat("intptr", getProc(), addresses.castingBarPtr, addresses.castingBar_offset) == 0

			if last < goal then
				printf("\nCrafting interrupted, will try again to complete crafting.\n")
				last = last - 1
				yrest(1500)
			end
		until last == goal

		-- Only crafts once if 'all' not specified
		if _craftNumber ~= "all" then
			return
		end

		GUID, itemName, maxCraft = findItemToCraft(_itemNameOrGUID)
	end

end

function findItemToCraft(_itemNameOrGUID)
	-- _itemNameOrGUID must equal part or all of the item name or the id of the recipe to make it.
	-- Only returns recipes where you have the ingredients to make it.

	if type(_itemNameOrGUID) == "number" then -- GUID
		itemName, __, maxCraft =  RoMScript("GetCraftItemInfo(".._itemNameOrGUID..")")
		if itemName ~= nil and maxCraft > 0 then
			return _itemNameOrGUID, itemName, maxCraft
		end
	else -- Find recipe name
		for typeNo = 1, RoMScript("GetCraftItemList()") do
			local itemName, GUID, maxCraft =  RoMScript("} " ..
				"f=GetCraftItem " ..
				"for C=1,f("..typeNo..",1,-1) do " ..
					"_,_,_,G=f("..typeNo..",1,C) " ..
					"N,_,M=GetCraftItemInfo(G) " ..
					"if M>0 and string.find(N,\"".._itemNameOrGUID.."\") then " ..
						"a={N,G,M} " ..
						"break " ..
					"end " ..
				"end " ..
			"z={")
			if itemName ~= nil then
				return GUID, itemName, maxCraft
			end
		end
	end
end
