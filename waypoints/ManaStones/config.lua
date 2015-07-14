
	--[[ modify user options here ]]-----------------------------------------------------------------------------------
	
	senderPass					= 'please'				-- a password to wisper to the senders for authentification
																				-- this is to prevent other players from stealing items and stones
	numTokensToKeep			= 0								-- if you want to keep some phirius tokens left on every character
	maxStoneTier				= 9  							-- max tier to build
	
	stoneSender					= 'Fusilli'				-- then name of the fusion stone sender
	stoneID							= 202999					-- 202999 or 203001 (or one of the other available fusion stones)
	stonePrice					= 1980						-- how much costs a single stone?
	stoneVendorID				= 111392					-- f.e. odeley prole (varanas)
	
	itemSender					= 'Beltolli'			-- then name of the item sender
	itemID							= 228966					-- the item to buy (f.e. 228966 at fjord vendor)
	itemTier						= 5								-- the item tier
	itemPrice						= 6124						-- how much costs a single item?
	itemVendorID				= 123010					-- f.e. didide spiderfoot (fjord)
	
	manaStoneReceiver		= 'Steinbänker'		-- name of the char where to send 'ready' manastones to
	
	charList						= {								-- your charlist (known format from SetCharList() but extended with 'secPass')
		{ account = 47, chars = {7, 4, 5, 8, 1}, 					secPass = 'animal10' }, 
		{ account = 68, chars = {1, 2, 5, 7}, 						secPass = 'animal10' }, 
		{ account = 90, chars = {1, 2, 3, 4, 5, 6, 7, 8}, secPass = 'animal10' }, 
		{ account = 91, chars = {1, 2, 3, 4, 5, 6, 7, 8}, secPass = 'animal10' }, 
		{ account = 92, chars = {1, 2, 3, 4, 5, 6, 7, 8}, secPass = 'animal10' }, 
		{ account = 93, chars = {1, 2, 3, 4, 5, 6, 7, 8}, secPass = 'animal10' }, 
		{ account = 94, chars = {1, 2, 3, 4, 5, 6, 7, 8}, secPass = 'animal10' },
		{ account = 95, chars = {1, 2, 3, 4, 5, 6, 7, 8}, secPass = 'animal10' },
		{ account = 96, chars = {1, 2, 3, 4, 5, 6, 7, 8}, secPass = 'animal10' },
	}

	--[[ end of user options ]]----------------------------------------------------------------------------------------
