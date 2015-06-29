--==<<                                               >>==--
--==<<        Celesterias magic box functions        >>==--
--==<<          by Celesteria - version 1.2          >>==--
--==<<                                               >>==--
--==<< this function DO NOT require any fusion addon >>==--
--==<<                                               >>==--

	ELE_WIND			= 1
	ELE_WATER			= 2
	ELE_FIRE			= 3
	ELE_EARTH			= 4
	
	LVL_STARDUST	= 2
	LVL_SAND			= 3
	LVL_STONE			= 4
	LVL_DIAMOND		= 5
	
	__timing			= 250
	__mboxenabled	= false
	
	local elements	= {
		{241479, 241334, 241333, 241332, 241331},	-- element, stardust, sand, stone, diamond
		{241480, 241338, 241337, 241336, 241335},
		{241481, 241342, 241341, 241340, 241339},
		{241482, 241346, 241345, 241344, 241343},
	}
	
	local function emptyMagicBox (all)
		for i = 51, 55 + (all==true and 5 or 0) do
			local item = inventory.BagSlot[i]
			item:update()
			if not item.Empty then
				item:moveTo("bags") yrest (__timing)
			end
		end
		inventory:update()
	end
	
	
	function UMB_getCharges ()
	------------------------------------------------------------------------------------
	-- get current amount of arcane charges
	--
	-- arguments
	-- 		none
	-- returns
	--		number
	------------------------------------------------------------------------------------
		return RoMScript ("GetMagicBoxEnergy ()") or 0
	end
		
	
	function UMB_getMagicBoxEnabled ()
	------------------------------------------------------------------------------------
	-- check if magicbox is enabled
	--
	-- arguments
	-- 		none
	-- returns
	--		boolean
	------------------------------------------------------------------------------------
		if __mboxenabled==false then
			__mboxenabled = RoMScript ("IsMagicBoxEnable ()")
		end
		return __mboxenabled
	end
		
	
	function UMB_fuseItems (...)
	------------------------------------------------------------------------------------
	-- fusing a list of items
	--
	-- arguments
	-- 		a list of (max. 5) items or itemIDs or itemNames (mixed)
	-- returns
	--		nothing
	------------------------------------------------------------------------------------
	
		local items, item, slot	= {...}, nil, 51
		for idx=1,math.min (5, #items) do
			if type (items[idx])=='number' or type (items[idx])=='string' then
				item	= inventory:findItem (items[idx])
			else
				item	= items[idx]
			end
			if item and (not item.Empty) then
				while not item.Available do
					yrest (__timing)
				end
				if item.ItemCount>1 then
					RoMScript ("SplitBagItem ("..item.BagId..",1)")
				else
					item:pickup ()
				end
				yrest(__timing)
				inventory.BagSlot[slot]:pickup () yrest (__timing)
				slot	= slot + 1
			end
		end
		if slot>51 then
			RoMScript ("MagicBoxRequest ()") yrest (__timing)
			emptyMagicBox ()
		end
	end
	
	
	function UMB_buyCharges (secPass, numTokensToKeep)
	------------------------------------------------------------------------------------
	-- find ID, buy arcane charges from itemshop using phirius tokens, use items
	--
	-- arguments
	-- 		secPass						- [required] secondary password
	--		numTokensToKeep		- [optional] how many phirius tokens left (at least)
	-- returns
	--		nothing
	------------------------------------------------------------------------------------
	
		if not secPass then
			cprintf (cli.red, "[UMB_buyCharges] second passwort required.\n")
			error ('')
		end
    
		local chargesItemshopID	= FindItemShopGUID (202928, "coin")
    local count             = 0
		numTokensToKeep         = tonumber (numTokensToKeep) or 0
		cprintf (cli.lightblue, "buy arcane charges ")
		inventory:update ()
		local numTokens = inventory:itemTotalCount (203038) - numTokensToKeep
		while numTokens>=100 do
			BuyFromItemShop (chargesItemshopID, secPass)	yrest (1000)
      count = count + 1
			cprintf (cli.yellow, math.fmod (count,10)==0 and '|' or '.')
			numTokens = numTokens - 100
		end
		cprintf (cli.lightblue, " done\n")
		if UMB_getMagicBoxEnabled () then
			for i=1,inventory:itemTotalCount (202928) do
				inventory:useItem (202928) yrest (500)
			end
		end
	end

	
	function UMB_numToBuy (id, itemTier, maxStoneTier)
	------------------------------------------------------------------------------------
	-- calculates the number of required items/stones
	--
	-- arguments
	-- 		id						- [required] id of item to check (f.e. from fjord is 228966, default stone id is 202999)
	--		itemTier			- [required] tier of the item in itemID (belt from fjord is 5)
	--		maxStoneTier	- [optional] highest tier to build (default 20)
	-- returns
	--		number
	------------------------------------------------------------------------------------
		if not id then 
			cprintf (cli.red, "[UMB_numToBuy] missing id.\n")
			error ('')
		end
		
		if not itemTier then 
			cprintf (cli.red, "[UMB_numToBuy] missing itemTier.\n")
			error ('')
		end
		
		maxStoneTier		= maxStoneTier or 20
		local workTier	= maxStoneTier
		local charges 	= UMB_getCharges ()
		local buy				= 0 - (id and inventory:itemTotalCount (id) or 0)
		local stones		= {}
		for i=itemTier, maxStoneTier do
			stones[i]			= inventory:itemTotalCount (202839 + i)
		end
		while charges > 0 do
			if stones[workTier]>=3 and workTier<maxStoneTier then
				charges						= charges - 1
				stones[workTier]	= stones[workTier] - 3
				workTier					= workTier + 1
				stones[workTier]	= stones[workTier] + 1
			elseif workTier==itemTier then
				charges 					= charges - 1
				buy								= buy + 1
				stones[workTier]	= stones[workTier] + 1
			else
				workTier					= workTier - 1
			end
		end
		return math.max (0, buy)
	end

	
	function UMB_fuseTierStones (itemID, itemTier, stoneID, maxStoneTier)
	------------------------------------------------------------------------------------
	-- fuses items and fusion stones as much as possible
	--
	-- arguments
	-- 		itemID				- [required] id of the item to use (belt from fjord is 228966)
	--		itemTier			- [required] tier of the item in itemID (belt from fjord is 5)
	--		stoneID				- [optional] id of fusion stones to use (default 202999)
	--		maxStoneTier	- [optional] highest tier to build (default 20)
	-- returns
	--		nothing
	------------------------------------------------------------------------------------
		
		if not itemID then 
			cprintf (cli.red, "[UMB_fuseTierStones] missing itemID.\n")
			error ('')
		end
		
		if not itemTier then 
			cprintf (cli.red, "[UMB_fuseTierStones] missing itemTier.\n")
			error ('')
		end
		
		maxStoneTier		= maxStoneTier or 20
		local workTier	= maxStoneTier
		stoneID 				= stoneID or 202999
		
		if UMB_getCharges () > 0 then
			emptyMagicBox (true)
			cprintf (cli.lightblue, "now fusing ")
			while UMB_getCharges () > 0 do
				inventory:update()
				local curID		= 202839 + workTier
				local stones 	= inventory:itemTotalCount (curID)
				if stones>=3 and workTier<maxStoneTier then
					cprintf (cli.yellow, ".")
					UMB_fuseItems (curID, curID, curID)
					workTier		= workTier + 1
				elseif workTier==itemTier and inventory:itemTotalCount (itemID)>0 and inventory:itemTotalCount (stoneID)>0 then
					cprintf (cli.yellow, ".")
					UMB_fuseItems (stoneID, itemID)
					workTier		= maxStoneTier
				else
					workTier		= workTier - 1
					if workTier<itemTier then break end
				end
			end
			cprintf (cli.lightblue, " done\n")
		end
	end
	
	
	function UMB_fuseElements (element, level, amount)
	------------------------------------------------------------------------------------
	-- fuses elements to higher level
	--
	-- arguments
	-- 		element				- [required] type of element - ELE_WIND, ELE_WATER, ELE_FIRE, ELE_EARTH
	--		level					- [required] max level to fuse - LVL_STARDUST, LVL_SAND, LVL_STONE, LVL_DIAMOND
	--		amount				- [optional] number of fused elements in bag to finish
	-- returns
	--		boolean				- failure or success
	------------------------------------------------------------------------------------

		if not element then 
			cprintf (cli.red, "[UMB_fuseElements] missing element.\n")
			error ('')
		elseif element<1 or element>4 then
			cprintf (cli.red, "[UMB_fuseElements] wrong element number (use ELE_WIND, ELE_WATER, ELE_FIRE, ELE_EARTH)\n")
			error ('')
		end
		
		if not level then 
			cprintf (cli.red, "[UMB_fuseElements] missing level.\n")
			error ('')
		elseif level<2 or level>5 then
			cprintf (cli.red, "[UMB_fuseElements] wrong level number (use LVL_STARDUST, LVL_SAND, LVL_STONE, LVL_DIAMOND)\n")
			error ('')
		end
		
		amount					= amount or 3
		local maxLevel	= math.max (2, math.min (level or 0, 5))
		local curLevel	= maxLevel
		local charges		= UMB_getCharges ()
		
		if charges>0 then
			emptyMagicBox (true)
			cprintf (cli.lightblue, "now fusing...")
			while charges>0 do
				inventory:update()
				local count = inventory:itemTotalCount (elements[element][curLevel])
				if curLevel==maxLevel then
					if count>=amount then
						cprintf (cli.lightblue, "done")
						return true
					else
						curLevel	= curLevel - 1
					end
				elseif count>=3 then
					cprintf (cli.yellow, ".")
					UMB_fuseItems (elements[element][curLevel], elements[element][curLevel], elements[element][curLevel])
					curLevel	= maxLevel
				else
					curLevel	= curLevel - 1
					if curLevel<1 then
						cprintf (cli.yellow, "not enought element items\n")
						return false
					end
				end
			end
		end
		cprintf (cli.yellow, "not enought arcane charges\n")
		return false 
	end
  