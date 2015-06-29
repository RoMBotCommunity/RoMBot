--=== V 1.6 ===--
--=== if you find it misses using an item that it prints it is using ===--
--=== then increase the laggallowance value in milliseconds ===--
--=== ie. 200   300   400   500 ===--
local laggallowance = 200

local function itembufftable()
	local buffitems = {
	--=== Housemaid Potions ===--
	{itemId = 207200, buffId = 506684, types = "both"}, 		-- Unbridled Enthusiasm , faster run/walk
	{itemId = 207202, buffId = 506686, types = "magic"},		-- Clear Thought, faster spell casting
	{itemId = 207203, buffId = 506687, types = "both"},			-- Turn of Luck Powder Dust
	{itemId = 207206, buffId = 506690, types = "both", cooldown = 0},			-- Scarlet Love, increases physical defence
	{itemId = 207207, buffId = 506691, types = "both", cooldown = 0},			-- Pungent Vileness, "tank" increases agro
	{itemId = 207208, buffId = 506692, types = "both"},			-- Godspeed
	
	--=== Housemaid Food ===--
	{itemId = 207209, buffId = 506673, types = "physical"},		-- Housekeeper Special Salted Fish with Sauce
	{itemId = 207210, buffId = 506674, types = "magic"},		-- Housekeeper Special Smoked Bacon with Herbs
	{itemId = 207211, buffId = 506675, types = "physical"},		-- Housekeeper Special Caviar Sandwich
	{itemId = 207212, buffId = 506676, types = "magic"},		-- Housekeeper Special Deluxe Seafood
	{itemId = 207213, buffId = 506677, types = "physical"},		-- Housekeeper Special Spicy Meatsauce Burrito
	{itemId = 207214, buffId = 506678, types = "magic"},		-- Housekeeper Special Delicious Swamp Mix
	{itemId = 207215, buffId = 506679, types = "physical"},		-- Housekeeper Special Unimaginable Salad
	{itemId = 207216, buffId = 506680, types = "magic"},		-- Housekeeper Special Cheese Fishcake
	
	
	--=== mementos vendor ===--
	{itemId = 206874, buffId = 506271, types = "both"},			-- Grassland Mix
	{itemId = 206891, buffId = 506268, types = "both"},			-- Lizard Blood
	
	{itemId = 206875, buffId = 506272, types = "both"},			-- Fresh Fish Soup, "healer"
	{itemId = 206876, buffId = 506273, types = "physical"},		-- Roast Wolf Leg
	{itemId = 206877, buffId = 506119, types = "physical"},		-- Roast Leg of Lamb	
	{itemId = 206878, buffId = 506120, types = "magic"},		-- Crispy Chicken Drumstick
	{itemId = 206890, buffId = 506121, types = "magic"},		-- Charcoal Barbequed Beef
	
	{itemId = 207020, buffId = 506122, types = "both"},			-- Vegetable Sandwich
	{itemId = 207021, buffId = 506123, types = "both"},			-- Smoked Salmon
	
	{itemId = 207969, buffId = 507251, types = "both"},			-- Rhinoceros Blood
	{itemId = 207970, buffId = 507252, types = "physical"},		-- War Insignia
	{itemId = 207971, buffId = 507253, types = "magic"},		-- Secret Ritual Manual
	{itemId = 207675, buffId = 507077, types = "both"},			-- Madness Potion Bag, "tank". IS bag item 207921
	{itemId = 207671, buffId = 506985, types = "both"},			-- Defense Potion Bag, "tank". IS bag item 207922
	{itemId = 207673, buffId = 507075, types = "both"},			-- Cleansing Potion Bag, "healer". IS bag item 207923
	{itemId = 206892, buffId = 506269, types = "physical"},		-- Tiger Fury
	
	--=== Item shop ===--
	{itemId = 202322, buffId = 501647, types = "both"},			-- Potent Luck, might remove this.
	
	{itemId = 200056, buffId = 500999, types = "physical"},		-- Attack Sigil
	{itemId = 200927, buffId = 501002, types = "magic"},		-- Magic Attack Sigil
	{itemId = 200359, buffId = 501631, types = "physical"},		-- Hot Stew
	{itemId = 202240, buffId = 501614, types = "both"},			-- Egg Rice Dumplings
	{itemId = 204553, buffId = 503326, types = "both"},			-- Universal Potion, +100 all attributes
	
	{itemId = 204461, buffId = 503328, types = "magic"},		-- Magic Guitar (3 Days)	
	{itemId = 204462, buffId = 503327, types = "physical"},		-- Magic Lute (3 Days)
	{itemId = 204463, buffId = 503331, types = "both"},			-- Magic Tambourine (3 Days)

	--=== Crafted Items ===--
	{itemId = 207636, buffId = 495798, types = "magic"},		-- Loaf of Handmade Black Bread
	{itemId = 207645, buffId = 507064, types = "magic"},		-- Meat Sandwich
	{itemId = 207654, buffId = 507046, types = "physical"},		-- Spiced Rack of Ribs
	{itemId = 207605, buffId = 495816, types = "physical"},		-- Spiced Roast Fish, needs buff Id checked.
	{itemId = 207653, buffId = 507045, types = "physical"},		-- Lightly Burnt Ribs
	{itemId = 207635, buffId = 507054, types = "magic"},		-- Loaf of Magic Hard Bread
	{itemId = 207644, buffId = 507063, types = "magic"},		-- Lettuce Sandwich
	{itemId = 200122, buffId = 501162, types = "magic"},		-- Dinner of the Gods
	{itemId = 200115, buffId = 501155, types = "magic"},		-- Moti Blended Sausage
	{itemId = 200109, buffId = 501149, types = "magic"},		-- Delicious Swamp Mix
	{itemId = 200108, buffId = 501148, types = "magic"},		-- Seaworm Salad
	{itemId = 200096, buffId = 501136, types = "magic"},		-- Fish Egg Sandwich
	{itemId = 207596, buffId = 507028, types = "both"},			-- Ordinary Chocolate
	{itemId = 207663, buffId = 507019, types = "both"},			-- Cheesecake
	{itemId = 207662, buffId = 507018, types = "both"},			-- Chocolate Cake
	{itemId = 207595, buffId = 507027, types = "both"},			-- Bitter Dark Chocolate
	{itemId = 200192, buffId = 500112, types = "magic"},		-- Ancient Spirit Water
	{itemId = 200225, buffId = 500311, types = "both"},			-- Embrace of the Muse, mana, but knights also use mana
	{itemId = 240535, buffId = 507126, types = "magic"},		-- Extinguish Potion
	{itemId = 240533, buffId = 507122, types = "magic"},		-- Strong Magic Potion
	{itemId = 200114, buffId = 501154, types = "magic"},		-- Cheese Fishcake
	{itemId = 200194, buffId = 501213, types = "both"},			-- Life Source
	{itemId = 200113, buffId = 501153, types = "physical"},		-- General's Three-color Sausage
	{itemId = 200277, buffId = 501337, types = "both"},			-- Hero Potion, all attributes +20%
	{itemId = 200427, buffId = 501325, types = "both"},			-- Tranquility Powder, - agro for 30 seconds
	
	--=== Untested, got info from memory ===--
	{itemId = 207656, buffId = 495827, types = "both"},			-- Smoked Ribs
	{itemId = 207607, buffId = 495818, types = "physical"},		-- Smoked Fish
	{itemId = 207665, buffId = 495791, types = "both"},			-- Honey Cake
	{itemId = 207647, buffId = 495809, types = "magic"},		-- Huge Sandwich
	
	{itemId = 202895, buffId = 850473, types = "both"},			-- Meaningful Love Cake Slice, possible other buffid 623767
	{itemId = 241959, buffId = 850476, types = "physical"},		-- Vanilla Strawberry Dessert, possible other buffid 623770
	{itemId = 241965, buffId = 850482, types = "both"},			-- Elegant Cuisine Delicacy, possible other buffid 623776
	{itemId = 203024, buffId = 502704, types = "both"},			-- Blessing of the Flower God
	
	}
	
	local playertype
	if player.Class1 == CLASS_MAGE or player.Class1 == CLASS_PRIEST or player.Class1 == CLASS_DRUID or player.Class1 == CLASS_WARLOCK then
		playertype = "magic"
	else
		playertype = "physical"
	end
	local currentitems = {}
	inventory:update()
	for slot = 1, 240 do
		local item = inventory.BagSlot[slot]
		--print(item.Name)
		item:update()
		for k,v in pairs(buffitems) do
			if item.Available and item.Id == v.itemId and player.Level >= item.RequiredLvl and (v.types == "both" or v.types == playertype) then
				item.buffId = v.buffId
				item.types = v.types
				item.group = memoryReadInt(getProc(),GetItemAddress(v.buffId)+0xC0)
				item.maxBuffTime = memoryReadFloat(getProc(),GetItemAddress(v.buffId)+0x9C)
				if v.cooldown then item.CoolDownTime = v.cooldown end
				table.insert(currentitems,item)
			end;
		end
	end;
	
	--table.print(currentitems)
	return currentitems
end


function itemBuffs()

	local itemtable = itembufftable()

	if not itemtable[1] then 
		print("You have run out of buff items")
		return
	end
	
	--=== use item, check for casting bar and allow for global cooldown ===--
	local function useitem(v)
		print("using: "..v.Name)	
		v:use()
		repeat
			yrest(300 + laggallowance)
			player:updateCasting()
		until player.Casting == false	
	end
	
	--===  deal with over riding buffs using the buff group ===--
	local hasgroupbuff = {}
	player:updateBuffs()
	for j,buff in pairs(player.Buffs) do
		table.insert(hasgroupbuff, {group = memoryReadRepeat("int",getProc(),GetItemAddress(buff.Id)+0xC0), buffTimeLeft = buff.TimeLeft})
	end	
	
	local workingtable = itemtable
	local tmptable = {}
	local _remove = false
	--=== remove items with existing buff group ===--
	for k,v in pairs(workingtable) do
		local _remove = false
		for l,buff in pairs(hasgroupbuff) do
			if v.group == buff.group and buff.buffTimeLeft > 10  then
				_remove = true
			end
		end
		if _remove == false then 
			table.insert(tmptable,v)
		end
	end
	
	workingtable = tmptable
	tmptable = {}
	
	--=== remove items on cooldown ===--
	for k,v in pairs(workingtable) do
		local _remove = false
		local cd, success = v:getRemainingCooldown()
		if success == true and cd ~= 0 then
			_remove = true
		end
		if _remove == false then 
			table.insert(tmptable,v)
		end
	end	
	
	workingtable = tmptable
	tmptable = {}
	
	-- add a score to the items
	for k,v in pairs(workingtable) do
		local score = 0
		-- make sure to use housemaid items first
		if v.Id > 207200 and 207220 > v.Id then score = 10000 end
		-- then use items with longer lasting buffs
		score = score + v.maxBuffTime
		-- if items still have same score use higher level items
		score = score + v.RequiredLvl
		v.score = score
	end
	
	-- add groups into their own table of tables
	local groups = {}
	for k,v in ipairs(workingtable) do
		if tmptable[v.group] == nil then tmptable[v.group] = {} table.insert(groups,v.group) end
		table.insert(tmptable[v.group],v)
	end
	
	workingtable = {}
	-- sort items by score, within their own groups
	for k,v in pairs(groups) do
		table.sort(tmptable[v], function(a,b) return a.score > b.score end)
		-- first item will be best score item because of the sorting
		table.insert(workingtable,tmptable[v][1])
	end
	
	--Now sort table to use longer lasting buffs first
	table.sort(workingtable, function(a,b) return a.maxBuffTime > b.maxBuffTime end)
	
	--use items, yay
	for k,v in ipairs(workingtable) do
		useitem(v)
		--print(k.."\t"..v.group)
	end	
end