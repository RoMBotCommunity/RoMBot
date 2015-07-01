
	local path										= getExecutionPath()
	local dataFileName						= path..'/temp.dat'

	EventMonitorStart("MSGWHISPER", "CHAT_MSG_WHISPER")

	local function saveData (name, itemCount, stoneCount)
		local saved									= table.load (dataFileName)
		saved												= type (saved)=='table' and saved or {}
		saved[name]									= saved[name] or {}
		saved[name].name						= name
		saved[name].date						= tonumber (getDailyDate ('%Y%m%d'))
		saved[name]['num'..itemID]	= saved[name]['num'..itemID] or 0
		saved[name]['num'..stoneID]	= saved[name]['num'..stoneID] or 0
    if type(itemCount)=='number'  then saved[name]['num'..itemID] = itemCount end 
    if type(stoneCount)=='number' then saved[name]['num'..stoneID] = stoneCount end 
		saved[name].finished				= (saved[name]['num'..itemID] + saved[name]['num'..stoneID] == 0)
		table.save (saved, dataFileName)
	end
	
	local function loadData ()
		local saved									= table.load (dataFileName)
		saved												= type (saved)=='table' and saved or {}
		return saved
	end
	
	local function checkWisper ()
		local msg, time, moreToCome, name = nil
		repeat
			time, moreToCome, name, msg = EventMonitorCheck("MSGWHISPER", "4,1")
			if msg~=nil then
				local parts	= explode (msg, ' ')
				if parts[1]=='send' and parts[4]==senderPass then
					if parts[3]=='stones' then
						saveData (name, nil, tonumber (parts[2]))
					elseif parts[3]=='items' then
						saveData (name, tonumber (parts[2]), nil)
					elseif parts[3]=='all' then
						saveData (name, tonumber (parts[2]), tonumber (parts[2]))
					end
				end
			end
			yrest (500)
		until msg==nil
	end
	
	local function getNextPlayerName (acc, char)
		local acc               = acc or getAcc ()
		local char              = char or getChar ()
		local curChar, curAcc 	= 0,0
		local savChar, savAcc 	= 0,0
		local data, stop, name	= loadData (), false, nil
		
		for a,list in ipairs (charList) do
			if list.account == acc then
				for c,id in ipairs (list.chars) do
					if id == char then
						curChar = c
						curAcc	= a
						break
					end					
				end
			end
		end
		
		if curAcc>0 and curChar>0 then
      savAcc  = curAcc
      savChar = curChar
      repeat
  			if #charList[curAcc].chars>curChar then
					curChar   = curChar + 1
  			else
					curChar   = 1
					if #charList>curAcc then
						curAcc  = curAcc + 1
	  			else
						curAcc  = 1
	  			end
				end

        if (savAcc==curAcc and savChar==curChar) then
					-- all chars finished
					curAcc    = 1
					curChar   = 1
					stop      = true
				end

        name  = getPlayerName (charList[curAcc].account, charList[curAcc].chars[curChar])
				if name then
					-- checking next char
	        if stop or not data[name] or tonumber (data[name].date) < tonumber (getDailyDate ('%Y%m%d')) then
						stop    = true
					end
				else
					stop  = true
				end
      until stop
    end
		return name, charList[curAcc].account, charList[curAcc].chars[curChar]
	end
	
	local function waitForMails (amountS, amountI)
		local mails		= 0
		EventMonitorStart ('WaitForMail', 'CHAT_MSG_SYSTEM') yrest(300)
		cprintf (cli.lightblue, 'waiting for mails ('..amountS..' stones / '..amountI..' items) ')
		while mails<amountI + amountS do
			local time, moreToCome, msg = EventMonitorCheck ('WaitForMail', '1')
			if msg and string.find (msg, getTEXT ('SYS_NEW_MAIL')) then
				mails			= mails + 1
				cprintf (cli.yellow, math.fmod (mails,10)==0 and '|' or '.')
			end
			if not moreToCome then yrest (1000) end
		end
		EventMonitorStop ('WaitForMail') yrest(300)
		cprintf (cli.lightblue, ' done\n')
	end

	local function sendStones ()
		local itemList 	= {}
		local nextChar	= getNextPlayerName ()
		
		if nextChar and nextChar~=getPlayerName () then
			for i=itemTier,maxStoneTier-1 do
				if inventory:itemTotalCount (202839 + i)>0 then
					table.insert (itemList, 202839 + i)
				end
			end
			if #itemList>0 then
				UMM_SendByNameOrId (nextChar, itemList)
			end
    end
    
		if inventory:itemTotalCount (202839 + maxStoneTier)>0 and manaStoneReceiver~=getPlayerName () then
			UMM_SendByNameOrId (manaStoneReceiver, 202839 + maxStoneTier)
		end
    
		if inventory:itemTotalCount (itemID)>0 then
			UMM_SendByNameOrId (itemSender, inventory:itemTotalCount (itemID))
		end
    
		if inventory:itemTotalCount (stoneID)>0 then
			UMM_SendByNameOrId (stoneSender, inventory:itemTotalCount (stoneID))
		end
    
		RoMScript ("HideUIPanel (UMMFrame)")
	end
	
	local function buyFromVendor (merchant, id, amount)
		if amount>0 then
			cprintf (cli.lightblue, "buying "..amount.."x "..getTEXT ('Sys'..id..'_name').."\n")
			repeat
				local toBuy	= math.min (amount, 10)
				player:openStore (merchant)
				store:buyItem (id, toBuy)
				amount = amount - toBuy
				inventory:update ()
			until amount<=0 or inventory:itemTotalCount (0)==0 
		end
	end
	
	local function needMoney (item)
		inventory:update ()
    if inventory:itemTotalCount(item==1 and stoneID or itemID)>8 then return false end
		return (inventory:itemTotalCount (0) * (item==1 and stonePrice or itemPrice) > inventory.Money)
	end
  
	local function getSecPass ()
		local secPass	= nil
		local acc			= getAcc ()
		for _,account in pairs (charList) do
			if account.account == acc then
				secPass = account.secPass
				break
			end
		end
		if secPass==nil then
			error ('second passwort for account '..getAcc ()..' required', 0)
		end
		return secPass
	end
	
	function handleReceiver ()
		savePlayerName ()
		if UMB_getMagicBoxEnabled () then
			local secPass = getSecPass ()
			UMB_buyCharges (secPass, numTokensToKeep)
			if UMB_getCharges ()>0 then
			
				repeat
					moreToCome = checkMailbox ()
					UMB_fuseTierStones (itemID, itemTier, stoneID, maxStoneTier)
				until moreToCome == false
        
				local amountS	= checkOnline (stoneSender) and UMB_numToBuy (stoneID, itemTier, maxStoneTier) or 0
				if amountS>0 then 
					RoMScript ('SendChatMessage("send '..amountS..' stones '..senderPass..'", "WHISPER", 0, "'..stoneSender..'")') 
				end
					
				local amountI	= checkOnline (itemSender) and UMB_numToBuy (itemID, itemTier, maxStoneTier) or 0
				if amountI>0 then 
					RoMScript ('SendChatMessage("send '..amountI..' items '..senderPass..'", "WHISPER", 0, "'..itemSender..'")') 
				end
				
				waitForMails (amountS, amountI)
				saveData (getPlayerName (), 0, 0)
				
				repeat
					moreToCome = checkMailbox ()
					UMB_fuseTierStones (itemID, itemTier, stoneID, maxStoneTier)
				until moreToCome == false
				
			end
		end
		saveData (getPlayerName (), 0, 0)
		sendStones ()
	end
	
	function handleSender (senderType, atMailbox)
		local typeID    = (senderType==1 and stoneID or itemID)
		local amount    = 0
		local count	    = 0
		if atMailbox then
			repeat
        while needMoney (senderType) do
					print ('\a\a') yrest (500) print ('\a\a') yrest (500) print ('\a\a')
					cprintf (cli.lightred, "!!! not enought money !!!\n\n")
					player:sleep ()
					checkMailbox ()
					inventory:update ()
        end
				checkWisper ()
				local data 	= loadData ()
				for name,dat in pairs (data) do
					if dat.date==tonumber (getDailyDate ('%Y%m%d')) and dat['num'..typeID]>0 and inventory:itemTotalCount (typeID)>0 then
						inventory:update ()
						amount = math.min (dat['num'..typeID], inventory:itemTotalCount (typeID))
						cprintf (cli.lightblue, string.format ('Sending %dx "%s" to %s\n', amount, getTEXT ('Sys'..typeID..'_name'), dat.name ))
						UMM_SendByNameOrId (dat.name, typeID, amount)
        		RoMScript ("HideUIPanel (UMMFrame)")
						if senderType==1 then
							saveData (dat.name, nil, dat['num'..typeID]-amount)
						else
							saveData (dat.name, dat['num'..typeID]-amount, nil)
						end
					end
					if inventory:itemTotalCount (typeID)==0 then break end
				end
				yrest (5000)
			until inventory:itemTotalCount (typeID)<8
		else
			amount = inventory:itemTotalCount (0)
			if amount>0 then
				if not needMoney (senderType) then
					buyFromVendor (typeID==itemID and itemVendorID or stoneVendorID, typeID, amount)
				end
			end
		end
	end

	function startup ()
		local zoneID = getZoneId ()
		
		while zoneID==400 do	-- we are in the house
			player:target_NPC ({110758,115235})
			RoMScript ('ChoiceListDialogOption (0)')
			waitForLoadingScreen ()
			zoneID = getZoneId ()
		end
	
		while zoneID==401 do	-- we are in the guildhouse
			player:target_NPC (112588)
			ChoiceOptionByName (getTEXT ("SC_GUILDGIRL_P1_03")) -- 'Ich will die Gildenburg verlassen'
			waitForLoadingScreen ()
			zoneID = getZoneId ()
		end

		if getPlayerName ()==stoneSender then
			if fileExists (path..'/stoneSender/zone'..zoneID..'.xml') then
				loadPaths (path..'/stoneSender/zone'..zoneID)
				return true
			else
				cprintf (cli.lightred, 'missing zone-file for stoneSender zone '..zoneID..'\n')
				loadPaths (path..'/stoneSender/stoneSender')
				return false
			end
		end
		
		if getPlayerName ()==itemSender then
			if fileExists (path..'/itemSender/zone'..zoneID..'.xml') then
				loadPaths (path..'/itemSender/zone'..zoneID)
				return true
			else
				cprintf (cli.lightred, 'missing zone-file for itemSender zone '..zoneID..'\n')
				loadPaths (path..'/itemSender/itemSender')
				return false
			end
		end
		
		if fileExists (path..'/receiver/zone'..zoneID..'.xml') then
			loadPaths (path..'/receiver/zone'..zoneID)
			return true
		else
			cprintf (cli.lightred, err..'\n')
			loadPaths (path..'/receiver/receiver')
			return true
		end

		return false
	end
	
	if not checkRelog then
		function checkRelog ()
			cprintf (cli.lightblue, "All finished - next char.\n")
			SetCharList (charList)
			RoMScript ("CloseAllWindows ()")
			LoginNextChar ()
			loadProfile ()
			loadPaths (path..'/start')
		end
	end
	
