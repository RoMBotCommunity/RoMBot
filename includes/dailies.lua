
	__dqCardCount				= -1
	__dqCardID					= 202434

	local function checkDqCardCount (silent, maxValue)
		local cardCount		= inventory:itemTotalCount (__dqCardID)
		if cardCount>0 then
			if silent==true then
				if type (maxValue)=='number' then
					cardCount	= math.min (maxValue, cardCount)
				elseif maxValue~=true then
					cardCount	= 0
				end
			else
				cardCount = AskForNumber (0, cardCount, 'Use "'..TEXT (__dqCardID)..'"?')
			end
		end
		return cardCount
	end

	function RoMBarAutoKeys (onOff)
		onOff	= onOff and 'true' or 'false'
		RoMScript ('if RoMBar and RoMBar.auto then RoMBar.core.func.setVar ("SkipDialogs", '..onOff..') end')
	end

	function getDailyDate (format)
		format = format or '%Y%m%d'
		return os.date (format, os.time () - (6 * 3600))
	end

	function dayliesComplete (dqCardCount, silent)
		if __dqCardCount<0 then	-- first call
			__dqCardCount = 0 --checkDqCardCount (silent, dqCardCount)
		end
		
		local flag		= false
		
		for i=1,2 do
			dqCount, dqTotal	= RoMScript ('Daily_count ()')
			flag	= (dqCount >= dqTotal)
			if i==1 and flag and __dqCardCount>0 then
				if inventory:itemTotalCount (__dqCardID)>0 then
					cprintf (cli.lightgreen, '\nusing "'..getIdText (__dqCardID)..'"\n')
					inventory:useItem (__dqCardID)
					yrest (2000)
					__dqCardCount = __dqCardCount - 1
				else
					__dqCardCount = 0
					break
				end
			else
				break
			end
		end
		return flag, __dqCardCount
	end

	function exchangeClass (class1, class2, useHomeRune, npc)

		RoMBarAutoKeys (false)
		useHomeRune 		= (useHomeRune==true)
		local innerNPC  = {110758,115235}
		local outerNPC  = {123495}  -- incomplete list of outer npcs
		if type(npc)=='number' or type(npc)=='string' then
		  outerNPC      = {npcIdOrNameOrList}
		elseif type(npc)=='table' then
			outerNPC      = npcIdOrNameOrList
		end

		if player.Class1 ~= class1 then	-- swap classes
			if (#npc and not player:target(outerNPC)) and useHomeRune==true and getZoneId ()~=400 then
				inventory:update ()
				if inventory:itemTotalCount (202435)<=0 then
					cprintf (cli.lightred, '\nmissing "'..getIdText (202435)..'"\n')
					error ('')
				end
				inventory:useItem (202435)
				waitForLoadingScreen ()
			end
			if getZoneId ()==400 then
				player:target_NPC (innerNPC)
        ChoiceOptionByName ('HOUSE_MAID_HOUSE_CHANGEJOB') yrest (750)  -- Klasse ändern
			else
				player:target_NPC (outerNPC)
        ChoiceOptionByName ('SO_110581_1') yrest (750)  -- Ich möchte meine Primär- und Sekundärklasse wechseln.
			end
			RoMScript ('ExchangeClass ('..(class1+1)..', '..(class2+1)..')') yrest (2000)
			player:update ()
		end
		if getZoneId()==400 then -- leaving home
			player:target_NPC (innerNPC)
			ChoiceOptionByName (getTEXT ("HOUSE_MAID_LEAVE_HOUSE"))
			waitForLoadingScreen()
		end
		RoMBarAutoKeys (true)
	end
