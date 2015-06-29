--==<<          Rock5's mail related functions            >>==--
--==<<           By Rock5        Version 1.85             >>==--
--==<<                                                    >>==--
--==<<   Requirements: modified Ultimate Mail Mod addon   >>==--
--==<<                 ingamefunction addon installed     >>==--
--==<<                 mailbox to already be open         >>==--
--==<<                                                    >>==--
--==<<  www.solarstrike.net/phpBB3/viewtopic.php?p=12952  >>==--

local UMM_FromSlot = 61 -- Default 61, first slot
local UMM_ToSlot = 240 -- Default 240, last slot of bag 6

local use1UseMailbox
local recipientMailFullString

local function getMailboxFullString()
	if not recipientMailFullString then
		recipientMailFullString = getTEXT("SYS_SENDMAIL_TARGET_MAILFULL")
	end
	return recipientMailFullString
end

local function taggedCount()
	return RoMCode([[a=0 for k,v in pairs(UMMMailManager.Mails) do if v.WasRead then a=a+1 end end ]])
end

function UMM_SetSlotRange(_from, _to)
	-------------------------------
	-- Sets the range of slots to send from (61-240)

	-- Error checks
	if type(_from) ~= "number" or type(_to) ~= "number" or
	   _from > _to or _from < 61 or _to > 240 then
		error("Invalid arguments used in UMM_SetSlotRange(_from, _to). Valid values are from 61 to 240.")
	end

	UMM_FromSlot = _from
	UMM_ToSlot = _to
end

function UMM_SetOneUseMailboxRelog(boolean)
	-------------------------------
	-- Enables relogging after reaching the sending limit when using single-use convenient mailboxes.

	if type(boolean) == "boolean" then
		use1UseMailbox = boolean
	end
end

local function markToSend(_slotnumber)
	local item = inventory.BagSlot[_slotnumber + 60]
	item:update()
	if item.Empty then return end

	local bagid = math.floor((_slotnumber-1)/30+1)
	local slotid = _slotnumber - (bagid * 30 - 30)
	RoMScript("UMMMassSendItemsSlotTemplate_OnClick(_G['UMMFrameTab3BagsBag"..bagid.."Slot"..slotid.."'])")
end

local function openTab(_tab)
	if _tab == 1 then
		RoMScript("UMMFrameTab1:Show()") yrest(50)
		RoMScript("UMMFrameTab2:Hide()") yrest(50)
		RoMScript("UMMFrameTab3:Hide()") yrest(50)
		RoMScript("UMMFrameTab1Viewer:Hide()") yrest(50)
	elseif _tab == 2 then
		RoMScript("UMMFrameTab1:Hide()") yrest(50)
		RoMScript("UMMFrameTab2:Show()") yrest(50)
		RoMScript("UMMFrameTab3:Hide()") yrest(50)
	elseif _tab == 3 then
		RoMScript("UMMFrameTab1:Hide()") yrest(50)
		RoMScript("UMMFrameTab2:Hide()") yrest(50)
		RoMScript("UMMFrameTab3:Show()") yrest(50)
	end
	yrest(1000)
end

local function findMailbox()
	-- List of mailboxes and floating mail icon Id.
	local MailboxExceptions = {
		110538, 110694, 110771,
		110793, 112113, 112778,
		113043, 113112, 113136,
		113525, 114779, 117407,
		118670, 118688, 119274,
		122097, 123006, 123117,
		110986,					-- Mail boxe icon Id.
		};

	-- Check for a physical mailbox
	local mailboxicon = player:findNearestNameOrId(MailboxExceptions)		-- Mailbox exceptions and Mail icon.
	if mailboxicon and distance(mailboxicon.X, mailboxicon.Z, player.X, player.Z) < 100 then
		if mailboxicon.Id == 110986 then -- Find mailbox near icon
			-- Search for mailbox under icon
			local closestObject = nil;
			local obj = nil;
			local objectList = CObjectList();
			objectList:update();

			for i = 0,objectList:size() do
				obj = objectList:getObject(i);

				if obj ~= nil and obj.Type == PT_NPC and obj.Id ~= 110986 then
					local dist = distance(mailboxicon.X, mailboxicon.Z, obj.X, obj.Z);
					if( closestObject ~= nil ) then
						if dist < distance(mailboxicon.X, mailboxicon.Z, closestObject.X, closestObject.Z) then
							-- this node is closer
							closestObject = obj;
						end
					elseif dist < 5 then
						closestObject = obj;
					end
				end
			end
			mailboxicon = closestObject
		end

		return "mailbox", mailboxicon
	end

	-- check for rented mailbox
	local rented = tonumber(RoMScript("TimeLet_GetLetTime(\"MailLet\")"))
	if rented and rented > 1 then
		return "rented mailbox"
	end

	-- Check for convenient mailbox
	local convmailbox = (inventory:findItem(208792) or inventory:findItem(201136))
	if convmailbox then
		if convmailbox.Id == 208792 then
			return "7 day convenient mailbox", convmailbox
		else
			return "1 use convenient mailbox", convmailbox
		end
	end
end

local function openMailbox()
	-- Check if already open
	if RoMScript("MailFrame:IsVisible()") then
		return true
	end

	-- Find mailbox
	local mailtype, mailbox = findMailbox()

	-- If mailbox not found
	if not mailtype then
		cprintf(cli.yellow,"Was unable to open mailbox. No mailbox, rented mailbox or convenient mailbox found\n")
		return false
	end

	-- Check mailbox type and open accordingly
	if mailtype == "mailbox" then
		player:target_NPC(mailbox.Id) yrest(2000)
		if RoMScript("SpeakFrame:IsVisible()") then
			RoMScript("ChoiceOption(1)")
		end
	elseif mailtype == "rented mailbox" then
		RoMScript("OpenMail()")
	elseif mailtype == "7 day convenient mailbox" or mailtype == "1 use convenient mailbox" then
		mailbox:use()
	end

	-- See if it opened successfully
	yrest(1000)
	if not RoMScript("MailFrame:IsVisible()") then
		cprintf(cli.yellow,"Attempt to open "..mailtype.." failed.\n")
		return false
	else
		-- Wait while loading mail
		repeat
			local Loading = RoMScript("string.find(UMMFrameTab1InfoLabel:GetText(),UMM_INBOX_LOADING,1,true)")
			yrest(50)
		until not Loading
		yrest(100)
		return true
	end
end

local function tryRelog()
	printf("\n")
	-- Find mailbox
	local mailtype, mailbox = findMailbox()

	-- If mailbox not found
	if not mailtype or (use1UseMailbox ~= true and mailtype == "1 use convenient mailbox") then
		cprintf(cli.yellow,"Mailing delayed. No mailbox found. Sending stopped.\n")
		return false
	end

	if getLastWarning(getTEXT("SYS_CANOT_DO_IT"),30) then
		if not ChangeCharRestart then
			cprintf(cli.yellow,"Mailing delayed. Userfunction LoginNextChar not installed. Cannot send. Sending stopped.\n")
			return false
		end
		cprintf(cli.green,"Mailing delayed. Restarting before continuing.\n")
		ChangeCharRestart("current")
	else
		cprintf(cli.green,"Mailing delayed. Reloging before continuing.\n")
		repeat RoMScript("MailFrame:Hide()") until not RoMScript ("MailFrame:IsVisible()")
		RoMScript("ChangeChar(CHARACTER_SELECT.selectedIndex)")
		waitForLoadingScreen()
	end
	rest(3000)
	player:update()

	return openMailbox()
end

--== Primary functions ==--
function UMM_TakeMail()
	-------------------------------
	-- Takes all mail in the inbox.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end

	-- Open correct tab
	openTab(1)

	-- Check if there is mail
	local InboxCount
	repeat InboxCount = RoMScript("UMMMailManager.MailCount") until InboxCount ~= nil
	if InboxCount == 0 then -- no mail
		printf("No mail to take.\n")
		return true
	end

	-- Taking mail
	local starttimer = os.clock()
	repeat
		RoMScript("UMMFrameTab1Tools:ButtonClick('take');"); yrest(1000)
	until RoMScript("UMMMailManager.priv_AutoRunning") == true or
			RoMScript("UMMMailManager.MailCount") == 0 or os.clock() - starttimer > 5

	local lastInboxCount = taggedCount()
	repeat
		yrest(5000)
		InboxCount = taggedCount()
		if InboxCount == lastInboxCount then
			-- Stuck
			RoMScript("HideUIPanel(MailFrame)")
			break
		end
		lastInboxCount = InboxCount
	until RoMScript("UMMMailManager.priv_AutoRunning") == nil

	if InboxCount > 0 and inventory:itemTotalCount(0) == 0 then
		printf("Inventory is full.\n")
	else
		printf("Mail taken.\n")
	end

	inventory:update()

	return true
end

function UMM_SendMoney(_recipient, _amount)
	-------------------------------------
	-- Sends amount of gold to recipient.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end

	repeat Copper = RoMScript("GetPlayerMoney('copper')") until Copper ~= nil
	if _recipient == nil or _amount == nil then
		error("You must specify a recipient and amount of gold to send when using UMM_SendMoney()")
	elseif type(_amount) ~= "number" and string.lower(_amount) ~= "all" then
		error("Argument #2 to UMM_SendMoney(): Expected type 'number' or text value 'all'.")
	end
	if string.lower(_amount) == "all" or _amount > Copper then
		_amount = Copper
	end

	printf("Sending money to ".._recipient.."...  ")

	-- Open correct tab
	openTab(2)

	-- Enter recipients name
	RoMScript("UMMFrameTab2ComposerHeaderAuthor:SetText('".._recipient.."');")

	-- Set money
	RoMScript("UMMFrameTab2ComposerFooterMoney:SetText(".._amount..");")

	-- Sending
	RoMScript("UMMFrameTab2Composer:Send()")

	printf("Money sent.\n")

	return true
end

function UMM_SendAdvanced(_recipient, _itemTable, _quality, _reqlevel, _worth, _objtype, _statNo, _dura, _amount, _stacksize, _fusedtier, _stats)
	----------------------------------
	-- Sends if all search terms match

	local debugfilter = false

	inventory:update()

	local function passesFilter(_slotitem)

		-- Empty, rented, Bound?
		if not _slotitem.Available or _slotitem.Empty then
			return false
		end

		if( bot.ClientLanguage == "RU" ) then
			_slotitem.Name = utf82oem_russian(_slotitem.Name);
		end

		if debugfilter then printf("\n%16s slot%3d  ",string.sub(_slotitem.Name,1,15),_slotitem.SlotNumber) end

		if not bitAnd(_slotitem.BoundStatus, 1) then
			if debugfilter then printf("Bound") end
			return false
		end

		-- Check name or id
		if _itemTable ~= nil then
			local match = false
			for __, nam in pairs(_itemTable) do
				if string.find(string.lower(_slotitem.Name),string.lower(nam)) or (_slotitem.Id == tonumber(nam)) then
					match = true
					break
				end
			end
			if match == false then
				if debugfilter then printf("No item name match") end
				return false
			end
		end

		-- Check Quality
		if _quality ~= nil and _slotitem.Quality < _quality then
			if debugfilter then printf("Quality too low") end
			return false
		end

		-- Check RequiredLvl
		if _reqlevel ~= nil and _slotitem.RequiredLvl < _reqlevel then
			if debugfilter then printf("Level too low") end
			return false
		end

		-- Check Worth
		if _worth ~= nil and _slotitem.Worth < _worth then
			if debugfilter then printf("Worth too low") end
			return false
		end

		-- Check ObjType
		if _objtype ~= nil then
			local match = false
			for __, typ in pairs(_objtype) do
				if _slotitem:isType(typ) then
					match = true
					break
				end
			end
			if match == false then
				if debugfilter then printf("No item type match") end
				return false
			end
		end

		-- Check StatNo
		if _statNo ~= nil then
			-- Not Clean?
			if _statNo == 0 and #_slotitem.Stats ~= 0 then -- not clean
				return false
			end

			-- Clean but not weapon or armor
			if _statNo == 0 and not (_slotitem.ObjType == 0 or _slotitem.ObjType == 1) then
				return false
			end

			-- Enough stats
			if _statNo > 0 and #_slotitem.Stats < _statNo then -- not enough stats
				return false
			end
		end

		-- Check Dura
		if _dura ~= nil and (_slotitem.MaxDurability or _slotitem.Durability)  < _dura then
			return false
		end

		-- Check Stacksize
		if _stacksize ~= nil then
			-- Full stack?
			if string.lower(_stacksize) == "max" and _slotitem.ItemCount ~= _slotitem.MaxStack then
				return false
			end

			-- Not big enough stack
			if type(_stacksize) == "number" and _slotitem.ItemCount < _stacksize then
				return false
			end
		end

		-- Check fused tier. That is what tier level mana stone the item would make.
		if _fusedtier ~= nil then
			-- Only weapons and armor can be fused
			if not (_slotitem.ObjType == 0 or _slotitem.ObjType == 1) then
				return false
			end

			-- If weapon, can't be projectile
			if _slotitem.ObjType == 0 and _slotitem.ObjSubType == 6 then
				return false
			end

			-- If weapon, can't be arrows
			if _slotitem.ObjType == 0 and _slotitem.ObjSubType == 5 and _slotitem.ObjSubSubType == 2 then
				return false
			end

			-- Calculate item level including quality
			local level = _slotitem.RequiredLvl
			if _slotitem.Quality > 0 then
				level = level + 2
			end

			if _slotitem.Quality > 1 then
				level = level + (_slotitem.Quality - 1) * 4
			end

			-- Calculate tier level
			local tier = 1
			if level >= 20 and level <= 39 then
				tier = 2
			elseif level >= 40 and level <= 59  then
				tier = 3
			elseif level >= 60 and level <= 79  then
				tier = 4
			elseif level >= 80 and level <= 99  then
				tier = 5
			end

			if tier < _fusedtier then
				return false
			end
		end

		-- Check and find stats
		if _stats ~= nil then
			if _statNo ~= nil and #_slotitem.Stats ~= _statNo then	-- check enough stats
				return false
			end
			for i, stat in pairs(_stats) do
				if( type(stat) == "table" ) then					-- for table stats
					if( _statNo ~= nil and _statNo > #stat ) then
						for j, value in pairs(stat) do
							for k = 1, #_slotitem.Stats, 1 do		-- for each slotitem stats
								if( _slotitem.Stats[k].Id == value or _slotitem.Stats[k].Name == value ) then
									if debugfilter then
										if( bot.ClientLanguage == "RU" ) then
											_slotitem.Stats[k].Name = utf82oem_russian(_slotitem.Stats[k].Name);
										end
										printf("Sent. k: %s, StatsId: %s, StatsName: %s, value: %s,\n", k, _slotitem.Stats[k].Id, _slotitem.Stats[k].Name, value);
									end
									if( j == #stat ) then
										return true
									end
								end
							end
						end
					else
						if( #_slotitem.Stats == #stat ) then		-- Enough stats
							for j, value in pairs(stat) do
								if( _slotitem.Stats[j].Id == value or _slotitem.Stats[j].Name == value ) then
									if debugfilter then
										if( bot.ClientLanguage == "RU" ) then
											_slotitem.Stats[j].Name = utf82oem_russian(_slotitem.Stats[j].Name);
										end
										printf("Sent. j: %s, StatsId: %s, StatsName: %s, value: %s,\n", j, _slotitem.Stats[j].Id, _slotitem.Stats[j].Name, value);
									end
									if( j == #stat ) then
										return true
									end
								else
									break
								end
							end
						end
					end
				else												-- for single stats
					if( _statNo ~= nil and _statNo > #_stats ) then
						for j = 1, #_slotitem.Stats, 1 do			-- for each slotitem stats
							if( _slotitem.Stats[j].Id == stat or _slotitem.Stats[j].Name == stat ) then
								if debugfilter then
									if( bot.ClientLanguage == "RU" ) then
										_slotitem.Stats[j].Name = utf82oem_russian(_slotitem.Stats[j].Name);
									end
									printf("Sent. j: %s, StatsId: %s, StatsName: %s, stat: %s,\n", j, _slotitem.Stats[j].Id, _slotitem.Stats[j].Name, stat);
								end
								if( i == #_stats ) then
									return true
								end
							end
						end
					else
						if( #_slotitem.Stats == #_stats ) then		-- Enough stats
							if( _slotitem.Stats[i].Id == stat or _slotitem.Stats[i].Name == stat ) then
								if debugfilter then
									if( bot.ClientLanguage == "RU" ) then
										_slotitem.Stats[i].Name = utf82oem_russian(_slotitem.Stats[i].Name);
									end
									printf("Sent. I: %s, StatsId: %s, StatsName: %s, stat: %s,\n", i, _slotitem.Stats[i].Id, _slotitem.Stats[i].Name, stat);
								end
								if( i == #_stats ) then
									return true
								end
							else
								break
							end
						end
					end
				end
			end
			return false
		end

		if debugfilter then printf("Sent") end

		return true
	end

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil then
		error("You must specify a recipient to use UMM_SendAdvanced()")
	elseif _itemTable ~= nil and type(_itemTable) ~= "table" and type(_itemTable) ~= "number" and type(_itemTable) ~= "string" then
		error("Argument #2 to UMM_SendAdvanced(): Expected type 'table' or 'string' or 'number', got '" .. type(_itemTable) .. "'")
	elseif _quality ~= nil and type(_quality) ~= "number" then
		error("Argument #3 to UMM_SendAdvanced(): Expected type 'number', got '" .. type(_quality) .. "'")
	elseif _reqlevel ~= nil and type(_reqlevel) ~= "number" then
		error("Argument #4 to UMM_SendAdvanced(): Expected type 'number', got '" .. type(_reqlevel) .. "'")
	elseif  _worth ~= nil and type( _worth) ~= "number" then
		error("Argument #5 to UMM_SendAdvanced(): Expected type 'number', got '" .. type(_worth) .. "'")
	elseif _objtype ~= nil and type(_objtype) ~= "string" and type(_objtype) ~= "table" then
		error("Argument #6 to UMM_SendAdvanced(): Expected type 'string' or 'table', got '" .. type(_objtype) .. "'")
	elseif _statNo ~= nil and type(_statNo) ~= "number" then
		error("Argument #7 to UMM_SendAdvanced(): Expected type 'number', got '" .. type(_statNo) .. "'")
	elseif _dura ~= nil and type(_dura) ~= "number" then
		error("Argument #8 to UMM_SendAdvanced(): Expected type 'number', got '" .. type(_dura) .. "'")
	elseif _amount ~= nil and type(_amount) ~= "number" then
		error("Argument #9 to UMM_SendAdvanced(): Expected type 'number', got '" .. type(_amount) .. "'")
	elseif _stacksize ~= nil and type(_stacksize) ~= "number" and string.lower(_stacksize) ~= "max" then
		error("Argument #10 to UMM_SendAdvanced(): Expected type 'number' or string 'max', got '" .. type(_stacksize) .. "'")
	elseif _fusedtier ~= nil and type(_fusedtier) ~= "number" then
		error("Argument #11 to UMM_SendAdvanced(): Expected type 'number', got '" .. type(_fusedtier) .. "'")
	elseif _stats ~= nil and type(_stats) ~= "table" and type(_stats) ~= "string" and type(_stats) ~= "number" then
		error("Argument #12 to UMM_SendAdvanced(): Expected type 'table' or 'string' or 'number', got '" .. type(_stats) .. "'")
	end

	-- place item in table if not already
	if type(_itemTable) == "number" or type(_itemTable) == "string" then
		_itemTable = {_itemTable}
	end

	-- place item type in table if not already
	if type(_objtype) == "string" then
		_objtype = {_objtype}
	end

	-- place stats in table if not already
	if type(_stats) == "number" or type(_stats) == "string" then
		_stats = {_stats}
	end

	-- Make table of items to send
	local counter = 0
	local sendlist = {}
	local itemlinks = {}
	for item = UMM_FromSlot, UMM_ToSlot, 1 do -- for each inventory
		local slotitem = inventory.BagSlot[item];
		local slotNumber = slotitem.SlotNumber - 60

		if passesFilter(slotitem) then
			-- Check if split is necessary
			if _amount and (counter + slotitem.ItemCount > _amount) then -- split
				local emptyslot = inventory:findItem(0,"bags")
				if not emptyslot then
					error("Can't split stack for UMM_SendByNameOrId function. Inventory is full.")
				end

				local topickup = slotitem.ItemCount - (_amount - counter)
				RoMScript("SplitBagItem("..slotitem.BagId.." ,"..topickup..")")
				repeat yrest(500) until RoMScript("CursorHasItem()")
				RoMScript("PickupBagItem("..emptyslot.BagId..")")
				yrest(1500)
				slotitem:update()
			end

			-- Increment counter
			counter = counter + slotitem.ItemCount

			-- Add to table
			table.insert(sendlist, slotNumber)
			itemlinks[slotNumber] = slotitem.ItemLink	--! need code for check items in ItemQueue.

			-- Are we finished
			if _amount and counter >= _amount then
				break
			end
		end
	end

	cprintf(cli.green,"Sending items to ".._recipient.."...  ")

	-- Check if nothing to send
	if #sendlist == 0 then
		cprintf(cli.lightgreen,"Nothing to send.\n")
		return true
	end

	local numberLeft
	repeat
		-- open Mailbox
		if not RoMScript("MailFrame:IsVisible()") then
			if not openMailbox() then
				if tryRelog() == false then
					return false, "Mailbox did not open"
				end
			end
		end

		-- Open correct tab
		openTab(3)

		-- Selecting items
		for __, slotNumber in pairs(sendlist) do
			markToSend(slotNumber)
		end
		yrest(1000)

		-- Enter recipients name
		RoMScript("UMMFrameTab3RecipientRecipient:SetText('".._recipient.."');")

		-- Sending
		RoMScript("UMMFrameTab3Action:Send()")

		-- Waiting until finished
		local st = os.clock()
		repeat
			yrest(2000)
			if getLastWarning(getMailboxFullString(), os.clock()-st) then
				inventory:update()
				cprintf(cli.lightgreen,"Recipient's bags are full.\n")
				repeat RoMScript("MailFrame:Hide()") until not RoMScript ("MailFrame:IsVisible()")
				return false, "Recipient's bags are full"
			end
		until RoMScript("UMMFrameTab3Status:IsVisible()") == false or RoMScript ("MailFrame:IsVisible()") == false

		-- Check if all items are gone
		numberLeft = 0
		inventory:update()
		for __, slotNumber in pairs(sendlist) do
			if debugfilter then
				if( bot.ClientLanguage == "RU" ) then
					itemlinks[slotNumber] = utf82oem_russian(itemlinks[slotNumber]);
					inventory.BagSlot[slotNumber + 60].ItemLink = utf82oem_russian(inventory.BagSlot[slotNumber + 60].ItemLink);
				end
				cprintf(cli.lightgreen,"BagSlot: %s, ItemLink1: %s, ItemLink2: %s.\n", slotNumber, itemlinks[slotNumber], inventory.BagSlot[slotNumber + 60].ItemLink)
			end
			if not inventory.BagSlot[slotNumber + 60].Empty and itemlinks[slotNumber] == inventory.BagSlot[slotNumber + 60].ItemLink then
				numberLeft = numberLeft + 1
			end
		end

		if numberLeft ~= 0 then
			-- Wait a bit more for bag full message
			local stt = os.clock()
			repeat
				yrest(2000)
				if getLastWarning(getMailboxFullString(), os.clock()-st) then
					inventory:update()
					cprintf(cli.lightgreen,"Recipient's bags are full.\n")
					repeat RoMScript("MailFrame:Hide()") until not RoMScript ("MailFrame:IsVisible()")
					return false, "Recipient's bags are full"
				end
			until os.clock()-stt > 2 -- 2s maximum

			if tryRelog() == false then
				break
			end
		end
	until numberLeft == 0

	inventory:update()
	if numberLeft == 0 then
		cprintf(cli.lightgreen,"Items sent.\n")
		return true
	else
		cprintf(cli.lightgreen,"Failed to send all items.\n")
		return false, "Failed to send all items"
	end
end

function UMM_SendByStats(_recipient, _itemTable, _stats, _statNo, _amount)
	--------------------------------------
	-- Sending an inventory items by stats

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil then
		error("You must specify a recipient to use UMM_SendByStats()")
	elseif _stats == nil or _itemTable == nil then
		error("You must specify a _stats or _itemTable to use UMM_SendByStats()")
	elseif type(_itemTable) ~= "table" and type(_itemTable) ~= "number" and type(_itemTable) ~= "string" then
		error("Argument #2 to UMM_SendByStats(): Expected type 'table' or 'string' or 'number', got '" .. type(_itemTable) .. "'")
	elseif type(_stats) ~= "table" and type(_stats) ~= "string" and type(_stats) ~= "number" then
		error("Argument #3 to UMM_SendByStats(): Expected type 'table' or 'string' or 'number', got '" .. type(_stats) .. "'")
	elseif _statNo ~= nil and type(_statNo) ~= "number" then
		error("Argument #4 to UMM_SendByStats(): Expected type 'number', got '" .. type(_statNo) .. "'")
	elseif _amount ~= nil and type(_amount) ~= "number" then
		error("Argument #5 to UMM_SendByStats(): Expected type 'number', got '" .. type(_amount) .. "'")
	end

	-- place stats in table if not already
	if type(_stats) == "number" or type(_stats) == "string" then
		_stats = {_stats}
	end

	printf("\nSending Fusion or Mana Stones by stats.\n")
	if type(_itemTable) == "number" or type(_itemTable) == "string" then
		printf("\nSending item:".._itemTable..", statNo:"..(_statNo or "nil")..", amount:"..(_amount or "nil").." to ".._recipient..".\n")
	elseif type(_itemTable) == "table" then
		printf("\nSending ")
		for __, item in pairs(_itemTable) do
			printf(" item:"..item..",")
		end
		printf(" statNo:"..(_statNo or "nil")..", amount:"..(_amount or "nil").." to ".._recipient..".\n")
	end

	UMM_SendAdvanced(_recipient,_itemTable,nil,nil,nil,nil,_statNo,nil,_amount,nil,nil,_stats)
end

function UMM_SendInventoryItem(_recipient, _itemTable)
	-------------------------------------------------------
	-- Sends an inventory item by item object or slotnumber or a table of objects and slotnumbers

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil then
		error("You must specify a recipient when using UMM_SendInventoryItem()")
	end
	-- Check if table of items
	if not (type(_itemTable) == "table") or (_itemTable.Id ~= nil) then
		-- Put into item table
		_itemTable = {_itemTable}
	end


	printf("Sending inventory items to ".._recipient.."...  ")

	local slotitem
	local slotNumber
	local numberLeft
	local mailsent = false
	repeat
		-- Open correct tab
		openTab(3)

		-- Mark to send
		for num, item in pairs(_itemTable) do
			if type(item) == "table" then
				slotitem = item
				slotNumber = item.SlotNumber - 60
			else
				local itemslot = tonumber(item)
				if type(itemslot) == "nil"  then
					error("UMM_SendInventoryItem() invalid item value, "..item or "nil")
				end
				slotNumber = itemslot - 60
				slotitem = inventory.BagSlot[item]
			end
			if slotNumber < 1 or slotNumber > 180 then
				error("UMM_SendInventoryItem() can only send items from the bags, from slot 61 to 240."..
						" If using 'inventory:findItem' make sure you use the second argument \"bags\" "..
						"to restrict the search to the 'bags' and exclude the itemshop bag and magicbox.")
			end

			if slotitem.Available and not slotitem.Empty and bitAnd(slotitem.BoundStatus, 1) then
				mailsent = true
				markToSend(slotNumber)
				yrest(1000)
			else
				-- Can't send, remove from list
				_itemTable[num] = nil
			end
		end
		if not mailsent then
			printf("Nothing to send.\n")
			return true
		end

		-- Enter recipients name
		RoMScript("UMMFrameTab3RecipientRecipient:SetText('".._recipient.."');")

		-- Sending
		RoMScript("UMMFrameTab3Action:Send()")

		-- Waiting until finished
		local st = os.clock()
		repeat
			yrest(2000)
			if getLastWarning(getMailboxFullString(), os.clock()-st) then
				inventory:update()
				cprintf(cli.lightgreen,"Recipient's bags are full.\n")
				return false, "Recipient's bags are full"
			end
		until RoMScript("UMMFrameTab3Status:IsVisible()") == false

		-- Check if all items are gone
		numberLeft = 0
		inventory:update()
		for __, slotNumber in pairs(_itemTable) do
			if type(slotNumber) == "table" then slotNumber = slotNumber.SlotNumber end
			if not inventory.BagSlot[slotNumber + 60].Empty then
				numberLeft = numberLeft + 1
			end
		end

		if numberLeft ~= 0 and tryRelog() == false then
			break
		end
	until numberLeft == 0

	inventory:update()
	if numberLeft == 0 then
		cprintf(cli.lightgreen,"Items sent.\n")
		return true
	else
		cprintf(cli.lightgreen,"Failed to send all items.\n")
		return false, "Failed to send all items"
	end
end

function UMM_SendByRange(_recipient, _from, _to)
	------------------------------------------------------------
	-- Sends all items in inventory in the slot range specified.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil then
		error("You must specify a recipient and item or slotnumber when using UMM_SendByRange()")
	elseif type(_from) ~= "number" then
		error("Argument #2 to UMM_SendByRange(): Expected type 'number', got '" .. type(_from) .. "'")
	elseif type(_to) ~= "number" then
		error("Argument #3 to UMM_SendByRange(): Expected type 'number', got '" .. type(_to) .. "'")
	elseif _from < 61 or _to > 240 or _from > _to then
		error("Invalid range used in UMM_SendByRange(). Can only send items from slot 61 to 240.")
	end

	printf("Sending item range to ".._recipient.."...  ")

	-- Open correct tab
	openTab(3)

	-- Mark items to send
	local marked = false
	for slot = _from, _to do
		local slotitem = inventory.BagSlot[slot]
		local slotNumber = slot - 60

		if slotitem.Available and not slotitem.Empty and bitAnd(slotitem.BoundStatus, 1) then
			markToSend(slotNumber)
			yrest(1000)
			marked = true
		end
	end

	-- Were any marked for sending
	if not marked then
		printf("Nothing to send.\n")
		return true
	end

	-- Enter recipients name
	RoMScript("UMMFrameTab3RecipientRecipient:SetText('".._recipient.."');")

	-- Sending
	RoMScript("UMMFrameTab3Action:Send()")

	-- Waiting until finished
	local st = os.clock()
	repeat
		yrest(2000)
		if getLastWarning(getMailboxFullString(), os.clock()-st) then
			inventory:update()
			cprintf(cli.lightgreen,"Recipient's bags are full.\n")
			return false, "Recipient's bags are full"
		end
	until RoMScript("UMMFrameTab3Status:IsVisible()") == false

	printf("Items sent.\n")

	inventory:update()

	return true
end

--== Customised 'specific need' functions ==--
function UMM_SendByQuality(_recipient, _quality)
	----------------------------------------
	-- Sends bag items by quality or higher.
	-- 1 = green, 2 = blue, 3 = purple, etc.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil then
		error("You must specify a recipient to use UMM_SendByQuality()")
	elseif type(_quality) ~= "number" then
		error("Argument #2 to UMM_SendByQuality(): Expected type 'number', got '" .. type(_quality) .. "'")
	elseif _quality < 0 or _quality > 5 then
		error("Incorrect quality level specified. Valid levels are 0 to 5, where 0 = white, 1 = green, etc.")
	end

	printf("Sending items by quality.\n")

	-- Sending items
	return UMM_SendAdvanced(_recipient, nil, _quality)
end

function UMM_SendByStatNumber(_recipient, _statNo)
	--------------------------------------
	-- Sends bag items by number of stats.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil then
		error("You must specify a recipient when using UMM_SendByStatNumber()")
	end

	if type(_statNo) ~= "number" or _statNo < 0 or _statNo > 6 then
		_statNo = 3     -- Default value if value invalid
	end

	printf("Sending items by stat number.\n")

	-- Sending items
	return UMM_SendAdvanced(_recipient, nil, nil, nil, nil, nil, _statNo)
end

function UMM_SendByNameOrId(_recipient, _itemTable, _amount)
	---------------------------------
	-- Sends bag items by name or id.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil or _itemTable == nil then
		error("You must specify a recipient and item table when using UMM_SendByNameOrId()")
	elseif type(_itemTable) ~= "table" and type(_itemTable) ~= "number" and type(_itemTable) ~= "string" then
		error("Argument #2 to UMM_SendByNameOrId(): Expected type 'table' or 'string' or 'number', got '" .. type(_itemTable) .. "'")
	elseif _amount and type(_amount) ~= "number" then
		error("Argument #3 to UMM_SendByNameOrId(): Expected type 'number' or 'nil', got '" .. type(_amount) .. "'")
	end

	-- place item in table if not already
	if type(_itemTable) == "number" or type(_itemTable) == "string" then
		_itemTable = {_itemTable}
	end

	printf("Sending items by name or id.\n")

	-- Sending items
	return UMM_SendAdvanced(_recipient, _itemTable, nil, nil, nil, nil, nil, nil, _amount)
end

function UMM_SendByDura(_recipient, _dura, _statNo, _objtype)
	----------------------------------
	-- Sends items by dura and statno.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil or _dura == nil then
		error("You must specify a recipient and dura level when using UMM_SendByDura()")
	elseif type(_dura) ~= "number" then
		error("Argument #2 to UMM_SendByDura(): Expected type 'number', got '" .. type(_dura) .. "'")
	elseif _statNo ~= nil and type(_statNo) ~= "number" then
		error("Argument #3 to UMM_SendByDura(): Expected type 'number', got '" .. type(_statNo) .. "'")
	elseif _objtype ~= nil and type(_objtype) ~= "string" and type(_objtype) ~= "table" then
		error("Argument #4 to UMM_SendByDura(): Expected type 'string' or 'table', got '" .. type(_objtype) .. "'")
	end

	printf("Sending items by dura.\n")

	-- Sending items
	return UMM_SendAdvanced(_recipient, nil, nil, nil, nil, _objtype, _statNo, _dura)
end

function UMM_SendByStackSize(_recipient, _itemTable, _stacksize)
	---------------------------------
	-- Sends bag items by stack size.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil or _itemTable == nil or _stacksize == nil then
		error("You must specify a recipient, item table and stack size when using UMM_SendByStackSize()")
	elseif type(_itemTable) ~= "table" and type(_itemTable) ~= "number" and type(_itemTable) ~= "string" then
		error("Argument #2 to UMM_SendByStackSize(): Expected type 'table' or 'string' or 'number', got '" .. type(_itemTable) .. "'")
	elseif type(_stacksize) ~= "number" and string.lower(_stacksize) ~= "max" then
		error("Argument #3 to UMM_SendByStackSize(): Expected type 'number' or string 'max', got '" .. type(_stacksize) .. "'")
	end

	-- place item in table if not already
	if type(_itemTable) == "number" or type(_itemTable) == "string" then
		_itemTable = {_itemTable}
	end

	printf("Sending items by stack size.\n")

	-- Sending items
	return UMM_SendAdvanced(_recipient, _itemTable, nil, nil, nil, nil, nil, nil, nil, _stacksize)
end

function UMM_SendByFusedTierLevel(_recipient, _fusedtier, _amount)
	---------------------------------
	-- Sends bag items by fused tier.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end
	if _recipient == nil or _fusedtier == nil then
		error("You must specify a recipient and fused tier when using UMM_SendByFusedTierLevel()")
	elseif type(_fusedtier) ~= "number" then
		error("Argument #2 to UMM_SendByFusedTierLevel(): Expected type 'number', got '" .. type(_fusedtier) .. "'")
	elseif _amount and type(_amount) ~= "number" then
		error("Argument #3 to UMM_SendByFusedTierLevel(): Expected type 'number' or 'nil', got '" .. type(_amount) .. "'")
	end

	printf("Sending items by fused tier.\n")

	-- Sending items
	return UMM_SendAdvanced(_recipient, nil, nil, nil, nil, nil, nil, nil, _amount, nil, _fusedtier)
end

function UMM_DeleteEmptyMail()
	-----------------------------------
	-- Selects then deletes empty mail.

	-- Error checks
	if not openMailbox() then
		return false, "Mailbox did not open"
	end

	-- Open correct tab
	openTab(1)

	-- Click 'Empty' and then 'Delete' buttons
	RoMCode([[UMMFrameTab1Tools:ButtonClick("tagempty") if UMMFrameTab1ToolsButtonDelete:IsEnable() then UMMFrameTab1Tools:ButtonClick("delete") end]])
	repeat
		yrest(2000)
	until RoMScript("UMMMailManager.priv_AutoRunning") == nil
end