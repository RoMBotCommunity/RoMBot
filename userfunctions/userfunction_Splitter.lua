-- Splitter userfunction
--       By Rock5
--     Version 1.0

local harvestId
local questItemId
local itemStackLimit
local splitItemId


local function verifyName(name, action)
	local nameToNumber = tonumber(name)

	-- See if name is id
	if nameToNumber then
		if nameToNumber > 1000 then -- Is id
			name = GetIdName(nameToNumber)
		else -- Is slot
			local item = CInventoryItem(nameToNumber + 60)
			if item.Id ~= 0 then
				return item.Name -- Don't need to check if we have item.
			else
				printf("Can't %s. Slot %s is empty.\n", action, nameToNumber)
				return
			end
		end
	end

	-- Check if we have it.
	if not inventory:findItem(name, "bags") then
		printf("Can't %s. '%s' not found.\n", action, name)
		return
	end

	return name
end

-- Sets up the settings needed to use the splitter functions when collecting.
function splitCollectSetup(_harvestId, _questItemId, _itemStackLimit)
	harvestId = _harvestId
	questItemId = _questItemId
	itemStackLimit = _itemStackLimit or 5 -- Default to stack size of 5
end

-- Collects quest harvestable items using the item queue to collect more than usually possible
function splitCollect()
	if not (harvestId and questItemId and itemStackLimit) then
		print("Run 'splitCollectSetup' before using splitCollect()")
		return
	end

	local function ItemsInBag()
		return inventory:itemTotalCount(questItemId)
	end

	yrest(200)
	local SplitItem

	player:update()

	-- Find closest node
	local closest = player:findNearestNameOrId(harvestId)

	-- Can't collect right now, return.
	if player.Battling or closest == nil or distance(closest.X,closest.Z,player.X,player.Z) > 50 then -- too far
		return
	end

	-- If 3 items, wait a bit to make sure 4th isn't on it's way.
	if ItemsInBag() == 3 then
		yrest(1000)
	end

	-- 1 less than stack limit. Move to transmutor and fill bag with split items.
	if ItemsInBag() == (itemStackLimit-1) and  ItemQueueCount() == 0 then

		-- Move to transmutor
		local BagItem = inventory:findItem(questItemId, "bags")
		repeat
			if BagItem then
				BagItem:moveTo("magicbox")
			end
			yrest(1000)
			BagItem = inventory:findItem(questItemId,"bags")
		until BagItem == nil

		-- Split item
		split()

		-- Break if battling
		player:update()
		if player.Battling then return end

	-- Can not collect any more. Return "finished".
	elseif ItemsInBag() > (itemStackLimit-1) then
		return "finished"
	end

	-- Check if node is still valid
	closest:update()
	if closest.Id ~= harvestId and closest.Name ~= harvestId then return end

	-- Last item. Collect then merge.
	if ItemQueueCount() == 20 then
		player:target(closest.Address)
		Attack()
		yrest(2000)
		player:update()
		if player.Casting then
			-- Make a few spaces for itemqueue items to come in
			merge(nil, 5)
			yrest(4000)

			-- When item queue finishes, move magicbox items to bag
			registerTimer("SplitTimer", 10000,
				function(ItemId)
					repeat
						yrest(500)
					until ItemQueueCount() == 0
					yrest(500)
					local item = inventory:findItem(ItemId, "magicbox")
					if item then
						item:moveTo("bags")
					end
					unregisterTimer("SplitTimer")
				end, questItemId)

			if ItemsInBag() > (itemStackLimit-1) then
				return "finished"
			end
		end

	-- Just keep collecting.
	else
		return player:target_Object(harvestId,2,nil,false)
	end
end

-- Returns item with predefined stack sizes, splitting as necessary.
function findSplitStack(idOrName, size)
	-- Check arguments
	if not idOrName or not size then
		print("findSplitStack: Invalid arguments. Correct syntax - findSplitStack(idOrName, size)")
		return
	end

	-- See if we have a correct size stack yet.
	local function find(_itemId)
		for i = 61, 240 do
			local item = inventory.BagSlot[i]
			item:update()
			if item.Available and (item.Id == _itemId or item.Name == _itemId) and item.ItemCount == size then
				return item
			end
		end
	end

	-- Not enough items to make stack size
	local count = inventory:itemTotalCount(idOrName, "bags")
	if count < size then
		print("findSplitStack: Too few items to make stack size")
		return
	end

	-- Try to find stack
	local item = find(idOrName)

	-- Try split
	if not item then
		split(idOrName, size)
		item = find(idOrName)
	end

	-- Try merge then split
	if not item then
		merge() split(idOrName, size)
		item = find(idOrName)
	end

	if item then
		-- Make sure item isn't still locked
		while item.InUse do
			yrest(100)
			item:update()
		end
		return item
	end
end


function split(name, size)
	-- 'name' can be the slot number, item id or item name. Defaults to all splitable items.
	local args_str = ""
	if name and name ~= "all" then
		args_str = verifyName(name, "split")
		if not args_str then return end -- Error message already printed in verifyName
		if size then
			args_str = args_str..","..size
		end
	end

	RoMCode("Splitter:Split(\"".. args_str.."\")")
	repeat
		yrest(200)
	until RoMScript("Splitter.Action") == nil
end

function merge(name, spaces)
	-- 'name' can be the slot number, item id or item name. Defaults to last split item or all items.
	local args_str = ""
	if name and name ~= "all" then
		args_str = verifyName(name, "merge")
		if not args_str then return end
	end

	if spaces then
		args_str = args_str..","..spaces
	end

	RoMCode("Splitter:Merge(\""..args_str.."\")")
	repeat
		yrest(200)
	until RoMScript("Splitter.Action") == nil
end