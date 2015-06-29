-- Tier_Maker_onLoad v1.3.6

--== For All ==--
	-- Global Variables
	RecipientMailFullString = getTEXT("SYS_SENDMAIL_TARGET_MAILFULL");
	MailSenderCanotDoItString = getTEXT("SYS_CANOT_DO_IT");
	RoMCode("igf_events:StopMonitor('MSGWHISPER')");
	EventMonitorStart("MSGWHISPER", "CHAT_MSG_WHISPER");	-- for mail resivers
	player.free_counter1 = 0;			-- reset counter 1
	player.free_counter2 = 0;			-- reset counter 2
	Cur_ZoneId = getZoneId();			-- Check Zone Id
	ErrorSendStone = false;
	TwinkWindowList = {};				-- empty table for twink window
	BotsendedFusionStone = 0;
	BotsendedManaStone = 0;
	TierChannelNumber = 0;
	PresendedItems = 0;
	BotSendedMail = 0;
	TryRestartBot = 0;
	TryUnstick = 0;

	-- change Profile settings
	changeProfileOption("THROWN_BAG", 0);
	changeProfileOption("ARROW_QUIVER", 0);
	changeProfileOption("QUICK_TURN", true);
	changeProfileOption("COMBAT_DISTANCE", 50);
	changeProfileOption("MAX_UNSTICK_TRIALS", 3);
	-- Don't need assist. Disable it.
	if settings.profile.options.EGGPET_ENABLE_ASSIST == true then
		settings.profile.options.EGGPET_ENABLE_ASSIST = false
		local assistPet = CEggPet(settings.profile.options.EGGPET_ASSIST_SLOT)
		assistPet:Return()
	end;
	-- Don't need buffs, disable those skills
	for i, skill in pairs(settings.profile.skills) do
		if skill.Type == STYPE_BUFF then
			settings.profile.skills[i].AutoUse = false
		end
	end;

	-- change UMM settings
	UMM_SetSlotRange(61, 120);

	-- Code for onUnstickFailure
	function TirodelUnstick(Restart)
		TryUnstick = TryUnstick + 1
		releaseKeys()								-- stop moveng
		if( Restart or TryUnstick == 3 ) then
			-- Variables for Restart client and Bot
			local currAcc = RoMScript("LogID");
			local currChar = RoMScript("CHARACTER_SELECT.selectedIndex");
			local dirPath = string.gsub( getExecutionPath()," ","\" \"" );
			local currPath = __WPL.FileName;
			local Clientlink = TierTwinkClient;		-- specify you client shortcut links name if it not contains *client*
			-- kill Client
			killClient()
			-- Restart client and Bot
			os.execute("START "..dirPath.."/../../micromacro.exe "..dirPath.."/login acc:"..currAcc.." char:"..currChar.." client:"..Clientlink.." path:"..currPath.."")
			os.exit()
		else
			sendMacro("SendWedgePointReport()")
			waitForLoadingScreen(90)
			player = CPlayer.new()
			loadPaths(__WPL.FileName)
			player.Unstick_counter = 0				-- reset unstick counter
			player.free_counter1 = 0				-- reset counter
			inventory:update()
			player:mount()
			__WPL:setWaypointIndex(__WPL:getNearestWaypoint(player.X, player.Z));
		end
		if( TryUnstick == 4 ) then
			RestartAfterAllError = false;
			error("\a\a\a\aError TirodelUnstick.");
		end
	end;

	-- onUnstickFailure
	if( not onUnstickFailureProfile ) then
		if( type(settings.profile.events.onUnstickFailure) ~= "function" ) then
			onUnstickFailureProfile =  function(unused) return; end;
		else
			onUnstickFailureProfile = settings.profile.events.onUnstickFailure;
		end
	end;
	function settings.profile.events:onUnstickFailure()
		onUnstickFailureProfile();
		TirodelUnstick();
	end;

	-- Reserve main window, Process, Char and Acc
	local Main_WIN = __WIN;
	local Main_PROC = __PROC;
	local AccountID	= RoMScript("LogID");
	local AccountName	= RoMScript("GetAccountName()");
	local CharacterID	= RoMScript("CHARACTER_SELECT.selectedIndex");

	-- Change mm window Name and Attributes
	unregisterTimer("timedSetWindowName")		-- unregister mm window Name Timer
	function WP_SetWindowName()
		local clientX, clientY, clientW, clientH = windowRect(getAttachedHwnd())
		--printf("window is at (%d, %d) and is %d wide, and %d high.", clientX, clientY, clientW, clientH);
		if clientX == -32000 then				-- If minimized
			clientX,clientY = 0,0
		end
		setWindowPos(getHwnd(), clientX, clientY, nil, nil, false)
		local W,H,X,Y = getConsoleAttributes()
		if 65 > X then
			setConsoleAttributes(W,H,65,Y)
			yrest(100)
		end
		setConsoleAttributes(65,10)				-- setConsoleAttributes(W,H,X,Y)
		setWindowName(getHwnd(), sprintf("%s [%s].   %s [Char %s, Lvl %s] - %s [LogID %s].", WAYPOINTNAME, WAYPOINTVERSION, string.sub(player.Name, 1, 10), CharacterID, player.Level, AccountName, AccountID));
	end;
	WP_SetWindowName();
	
	-- Check Tier Channel Number
	function CheckTierChannelNumber()
		-- 
	end;

	-- Check MainLevel
	function CheckMainLevel()
		--local mainLevel, secLevel = RoMScript("UnitLevel(\'"..string.gsub("player", string.char(34), ".").."\');");
		player:update();
		mainLevel = player.Level
		cprintf(cli.white, player.Name.." MainLevel: %s\n", mainLevel)
		return mainLevel
	end;
	local mainLevel = CheckMainLevel();

	-- write MailSender name to file
	if mainLevel >= 18 then
		local filename = getExecutionPath().."/logs/Tier_Maker.log"
		if not fileExists(filename) then
			filename = getExecutionPath().."/../logs/Tier_Maker.log"
		end
		local file, err = io.open(filename, "w");
		if( not file ) then
			RestartAfterAllError = false;
			error(err, 0);
		end
		file:write("name:"..player.Name.." time:"..os.time())
		file:close()
	end;

	-- Check Tier Level Received Items
	function CheckTierItems(Tierlevel)
		local Tierlevel = Tierlevel or 80
		local TierItems = 0
		for slot = 61, 120 do
			local slotitem = inventory.BagSlot[slot]
			if slotitem.Available and not slotitem.Empty and bitAnd(slotitem.BoundStatus, 1) and (slotitem.ObjType == 0 or slotitem.ObjType == 1) then
				local level = slotitem.RequiredLvl
				if slotitem.Quality > 0 then
					level = level + 2
				end
				if slotitem.Quality > 1 then
					level = level + (slotitem.Quality - 1) * 4
				end
				if level >= Tierlevel then
					TierItems = TierItems + 1
				end
			end
		end
		return TierItems
	end;

	-- Check Mana Stones in inventory
	function CheckManaStones(minGrad, maxGrad)
		local minGrad = minGrad or 4
		local maxGrad = maxGrad or 12
		inventory:update()
		Grad = {};
		for i = minGrad,maxGrad do
			table.insert(Grad, inventory:itemTotalCount(i+202839))
		end
		return Grad
	end;

	-- Check Count Mana Stone
	function CheckCountManaStones(stonelvl)
		local stonelvl = stonelvl or 12
		local CountManaStones = 0
		for i = 4,stonelvl do
			CountManaStones = CountManaStones + inventory:itemTotalCount(i+202839)
		end
		return CountManaStones
	end;

	-- Check Count Tier Items for prevent error
	function CheckCountTierItems()
		inventory:update()
		local CountTierItems = CheckCountManaStones()
		CountTierItems = CountTierItems + CheckTierItems()
		CountTierItems = CountTierItems + inventory:getItemCount(202999)
		CountTierItems = CountTierItems + inventory:getItemCount(203001)
		CountTierItems = CountTierItems + inventory:getItemCount(203276)
		return CountTierItems
	end;

	-- Send fusion Stones
	function Send2StatFusionStones(_param)
		-- Open Mailbox
		if( not RoMScript("MailFrame:IsVisible()") ) then
			player:target_Object({110538,110771,112113,112778},1000);			-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1000);
		end
		UMM_SendByStats(FusionStonesReceiver[1], 203001, StatsTables1)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[2], 203001, StatsTables2)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[3], 203001, StatsTables3)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[4], 203001, StatsTables4)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[5], 203001, StatsTables5)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[6], 203001, StatsTables6)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[7], 203001, StatsTables7)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[8], 203001, StatsTables8)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[9], 203001, StatsTables9)		-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[10], 203001, StatsTables10)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[11], 203001, StatsTables11)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[12], 203001, StatsTables12)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[13], 203001, StatsTables13)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[14], 203001, StatsTables14)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[15], 203001, StatsTables15)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[16], 203001, StatsTables16)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[17], 203001, StatsTables17)	-- Двухстатные Камни соединения
		UMM_SendByStats(FusionStonesReceiver[18], 203001, StatsTables18)	-- Двухстатные Камни соединения
	end;

	-- Send 2 Stat Mana Stones
	function Send2StatManaStones(_param)
		-- Open Mailbox
		if( not RoMScript("MailFrame:IsVisible()") ) then
			player:target_Object({110538,110771,112113,112778},1000);			-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1000);
		end
		-- Send 2 stat Mana Stone.
		UMM_SendByStats(ManaStonesReceiver[1], ManaStones, StatsTables1)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[2], ManaStones, StatsTables2)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[3], ManaStones, StatsTables3)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[4], ManaStones, StatsTables4)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[5], ManaStones, StatsTables5)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[6], ManaStones, StatsTables6)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[7], ManaStones, StatsTables7)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[8], ManaStones, StatsTables8)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[9], ManaStones, StatsTables9)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[10], ManaStones, StatsTables10)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[11], ManaStones, StatsTables11)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[12], ManaStones, StatsTables12)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[13], ManaStones, StatsTables13)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[14], ManaStones, StatsTables14)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[15], ManaStones, StatsTables15)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[16], ManaStones, StatsTables16)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[17], ManaStones, StatsTables17)	-- Двухстатные Камни маны
		UMM_SendByStats(ManaStonesReceiver[18], ManaStones, StatsTables18)	-- Двухстатные Камни маны
	end;

	-----------------------------------------------------------------------------------------
	-- Speed function
	function SetFarmerSpeed(_speed)
		local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
		if playerAddress ~= 0 then
			memoryWriteFloat(getProc(), playerAddress + 0x40, _speed);
			printf("Speedhack ACTIVATED!\n");
			local Speed = memoryReadFloat(getProc(), playerAddress + 0x40);
			print("Player speed:", Speed);
		end
	end;

	-- gameState
	local function gameState(win)
		local proc
		local state = 0
		
		if win then
			proc = openProcess( findProcessByWindow(win) )
		else
			proc = getProc()
		end
		if proc == nil then
			error("No valid process found.")
		end
		if not windowValid(win) then return 5 end

		local atInitialized = memoryReadUInt(getProc(), addresses.staticbase_char) ~= 0										-- When g_pGameMain is not initialized
		local atFPS = atInitialized and (memoryReadFloatPtr(getProc(), addresses.staticbase_char, 0x8c) > 0)				-- Measured FPS (m_fps)
		local atLogin = memoryReadUInt(proc, addresses.editBoxHasFocus_address) == 0 										-- Only when not in game
		local atCharacterSelection = memoryReadUInt(proc, addresses.staticTableSize) == 1									-- Character selection display
		local atLoadingScreen = memoryReadBytePtr(proc,addresses.loadingScreenPtr, addresses.loadingScreen_offset) ~= 0		-- Loading screen
		local inGame = memoryReadInt(proc, addresses.isInGame) == 1															-- In game, ready to go
		if win then closeProcess(proc) end

		if not atLoadingScreen then
			if inGame then
				state = 4
			elseif atCharacterSelection then
				state = 3
			elseif atLogin and atFPS then		-- Now, we cant be at login unless fps is running!!!
				state = 2
			elseif atFPS then
				state = 1
			end
		end

		return state
	end;

	-- Start Twink Client
	function StartTwinkClient(client)
		print("Starting client "..client.." ...")
		-- Get shortcut
		if not string.match(client, "%.lnk$") then
			client = client .. ".lnk"
		end
		if not fileExists(getExecutionPath().."/"..client) then
			error("Game shortcut does not exist: ".. client)
		end
		client = string.lower(client)
		local path = getExecutionPath().."/"..client
		-- fix spaces
		path = string.gsub(path," ","\" \"")
		-- Start client
		local a,b,c = os.execute("START "..path.." NoCheckVersion")
		if not a then
			error("Trouble executing shortcut. Values returned were: "..(a or "nil")..", "..(b or "nil")..", "..(c or "nil"))
		end
	end;

	-- Check  Twink Online
	function CheckTwinkOnline(TwinkName)
		EventMonitorStop("CharDetect"); yrest(300)
		EventMonitorStart("CharDetect", "CHAT_MSG_SYSTEM"); yrest(300)
		RoMScript('AskPlayerInfo(\"'..TwinkName..'\")');  yrest(300)
		local time, moreToCome, msg = EventMonitorCheck("CharDetect", "1")
		if time ~= nil then
			if( bot.ClientLanguage == "RU" ) then msg = utf82oem_russian(msg) end
			print(msg)
			if string.find(msg, TwinkName) then
				EventMonitorStop("CharDetect")
				print("CharDetect: "..TwinkName.." is Online.")
				return true
			else
				return false
			end
		end
	end;

	-- Check  Twink Client
	function CheckTwinkClient(_ignore)
		-- Get a list of current clients
		TwinkWindowList = findWindowList("*", "Radiant Arcana")
		if( #TwinkWindowList == 0 ) then
			error("You need to run rom first!")
		end
		for i = #TwinkWindowList, 1, -1 do
			__PROC = openProcess(findProcessByWindow(TwinkWindowList[i]));
			-- read player address
			if addresses["staticbase_char"] and addresses["charPtr_offset"] and addresses["pawnName_offset"] then
				local playerAddress = memoryReadUIntPtr(__PROC, addresses["staticbase_char"], addresses["charPtr_offset"]);
				-- read player name
				if( playerAddress ) then
					--print(i.." playerAddress "..playerAddress )
					printf("%s playerAddress: %s,",i ,playerAddress)
					local nameAddress = memoryReadUInt(__PROC, playerAddress + addresses["pawnName_offset"]);
					if nameAddress ~= nil and memoryReadString(__PROC, nameAddress) ~= player.Name then
						printf(" nameAddress: %s,\t name: %s\n",nameAddress ,memoryReadString(__PROC, nameAddress))
						attach(TwinkWindowList[i])
						-- Setup the macros and action key.
						--printf("Setup the macros and action key.\n")
						setupMacros()
					else
						-- remove
						print("table.remove "..i.." window: "..TwinkWindowList[i])
						table.remove(TwinkWindowList, i)
					end
				end
			end
		end
		print("Count TwinkWindowList: "..#TwinkWindowList)
		-- Restore Process and main window
		__PROC = Main_PROC
		__WIN = Main_WIN
		attach(getWin())
	end;

	-- Twink Client direct control
	function ControlTwinkClient(Twinkname, Commandtype, Command, CheckInGame)
		-- check error
		if type(Twinkname) == "boolean" or type(Twinkname) ~= "string" then Twinkname = "All" end
		printf("KontrolTwinkClient. Twinkname: %s, Commandtype: %s, Command: %s\n",Twinkname ,Commandtype ,Command)
		if( #TwinkWindowList == 0 ) then
			error("Error. You need to run function CheckTwinkClient() first!")
		end
		-- direct control
		for i = 1, #TwinkWindowList do
			if windowValid(TwinkWindowList[i]) then
				attach(TwinkWindowList[i])
				if CheckInGame and gameState(windowList[i]) ~= 3 then
					break;
				end
				__PROC = openProcess(findProcessByWindow(TwinkWindowList[i]));
				--printf("Main_PROC: %s, __PROC: %s, getProc: %s\n",Main_PROC ,__PROC ,getProc())
				-- test
				--RoMScript("AcceptGroup();");
				-- Command
				if Commandtype == "Script" then
					sendMacro(""..Command.."");
				elseif Commandtype == "PressKey" then
					keyboardPress(Command);
				end
			end
		end
		-- Restore Process and main window
		__PROC = Main_PROC;
		__WIN = Main_WIN;
		attach(getWin());
	end;
	--ControlTwinkClient(false, "Script", "AcceptGroup();StaticPopup_Hide('PARTY_INVITE');")
	--ControlTwinkClient(false, "Script","if UnitExists('party1') == true then QuitGame() end;")

	-- Kill Twink Client
	function KillTwinkClient(windowname, twinkname)
		if twinkname ~= nil then
			print("Kill Client "..twinkname.." ...")
			-- Get a list of current clients
			local windowList = findWindowList("*", "Radiant Arcana")
			-- find twinkname client
			for i = #windowList, 1, -1 do
				local Process = openProcess(findProcessByWindow(windowList[i]))
				-- read player address
				local playerAddress = memoryReadUIntPtr(Process, addresses["staticbase_char"], addresses["charPtr_offset"])
				-- read player name
				if( playerAddress ) then
					local nameAddress = memoryReadUInt(Process, playerAddress + addresses["pawnName_offset"])
					if nameAddress ~= nil then
						local name = memoryReadString(Process, nameAddress)
						if( name == twinkname ) then
							local NewWINProc = findProcessByWindow(windowList[i])
							os.execute("TASKKILL /PID " .. NewWINProc .. " /F")
							return true
						end
					end
				end
			end
		elseif windowname ~= nil then
			print("Kill Client "..windowname.." ...")
			local NewWIN = findWindow(windowname)
			if NewWIN and windowValid(NewWIN) then
				cprintf(cli.white, "NewWIN: %s.\n", NewWIN)
				local NewWINProc = findProcessByWindow(NewWIN)
				os.execute("TASKKILL /PID " .. NewWINProc .. " /F")
				return true
			end
		end
		return false
	end;

	-- Clean Bag Items
	function CleanBagItems()
		inventory:update()
		for i, item in pairs(inventory.BagSlot) do
			if item.Available and not item.Empty then
				for __, ItemId in pairs(CL_CleanBagItems) do
					if( item.Id == ItemId ) then
						if( bot.ClientLanguage == "RU" ) then item.Name = utf82oem_russian(item.Name) end
						printf("Deleting Item:  "..item.Name.."\n")
						item:delete()
					end
				end
			end
		end
	end;

	-- CancelPlayerBuff
	function CancelPlayerBuff(buffNameOrId)
		local i = 1;
		while RoMScript("UnitBuff('player',"..i..");") ~= nil do
			local name, icon, cnt, id = RoMScript("UnitBuff('player',"..i..");")
			--cprintf(cli.white, "Buff name: %s, icon: %s, cnt: %s, id: %s.\n, name, icon, cnt, id")
			if type(buffNameOrId) == "number" then
				if id == buffNameOrId then
					RoMScript("CancelPlayerBuff("..i..");")
					return true
				end
			else
				if name == buffNameOrId then
					RoMScript("CancelPlayerBuff("..i..");")
					return true
				end
			end
			i = i + 1;
		end
		return false
	end;

	-- Check Players on distance
	function CheckPlayers(distancetoplayer)
		local distancetoplayer = distancetoplayer or 350
		local objectList = CObjectList()
		objectList:update()
		for i = 0,objectList:size() do
			local obj = objectList:getObject(i)
			if( obj ~= nil and obj.Type == PT_PLAYER and obj.Name ~= player.Name ) then
				local dist = distance(player.X, player.Z, obj.X, obj.Z)
				printf("%s, player Name: %s,\t distance: %s\n",i ,obj.Name, dist)
				if distancetoplayer > dist then 
					return true
				end
			end
		end
		return false
	end;

	-- Accaunt Characters Names
	function AccauntCharactersNames()
		local CharsNames = "";
		for index = 1, 8 do
			local name, gender, mainLevel, mainClass, secLevel, secClass, zone, destroyTime = sendMacro("GetCharacterInfo("..index..");");
			CharsNames = CharsNames..""..name..":"
		end
		return CharsNames
	end;


--== 1 ==--
--==== Mail Sender onLoad ====--
	if( mainLevel >= 55 and Cur_ZoneId == 20 ) then
		cprintf(cli.white, "include waypoint Tirol_Zone_20.\n")
		--include("waypoints/Tirol_Zone_20.lua",true)
		return
	end;

	local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
	if( mainLevel >= 55 and Cur_ZoneId ~= 19 and Cur_ZoneId ~= 20 ) then
		RestartAfterAllError = false;
		error("\a\aYou are too far from Land of Malevolence.")
	elseif( Cur_ZoneId == 19 and distance(player.X,player.Z,-3170,48890) > 70 ) then
		RestartAfterAllError = false;
		error("\a\aYou are too far from Mailbox.")
	elseif( Cur_ZoneId == 20 and distance(player.X,player.Z,-11655,38890) > 70 ) then
		RestartAfterAllError = false;
		error("\a\aYou are too far from NPC.")
	elseif( Cur_ZoneId == 19 and 8 > CheckTierItems() ) then
		RoMScript("DEFAULT_CHAT_FRAME:AddMessage('|cffffff00Tirodel:Not enough Excellent Belt. Buy Excellent Belt and Start again.|r')")
		RestartAfterAllError = false;
		error("\a\aError. Not enough Excellent Belt. Buy Excellent Belt and Start again.");
	elseif( Cur_ZoneId == 19 and 92000 > Cur_Gold or Cur_ZoneId == 20 and 92000 > Cur_Gold ) then
		RestartAfterAllError = false;
		error("\a\aError. GOLD WARNING!")
	elseif( Cur_ZoneId == 19 and 16 > inventory:itemTotalCount(203276) or Cur_ZoneId == 20 and 16 > inventory:itemTotalCount(203276) ) then		-- Amount of Experience Orb
		RestartAfterAllError = false;
		error("\a\aError. Not enough Experience Orb.");
	elseif( Cur_ZoneId == 27 and mainLevel >= 20 ) then
		if( distance(player.X,player.Z,-9887,2262) > 150
			and distance(player.X,player.Z,-10255,2260) > 150
			and distance(player.X,player.Z,-9251,2819) > 150 ) then
			RestartAfterAllError = false;
			--error("\a\aYou are too far from Wailing Fjord Mailbox or Spiderfoot.")
		elseif( 1 > inventory:getItemCount(203276) and inventory:getItemCount(0) >= 8 and 64840 > Cur_Gold ) then
			RestartAfterAllError = false;
			error("\a\aError. Not enough Gold or Experience Orb.\n")
		elseif( 8 > CheckTierItems() and 150 > distance(player.X,player.Z,-9887,2262) ) then
			printf("Error. Not enough TierItems.\n")
			player:moveTo( CWaypoint(-10255, 2260), true )
			__WPL:setWaypointIndex(__WPL:findWaypointTag("SpiderfootStore"))
		elseif( 100 > distance(player.X,player.Z,-9887,2262) ) then
			-- Open Mailbox
			player:target_Object(123006);								-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
			UMM_DeleteEmptyMail();
			if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 )
				or ( 8 > inventory:itemTotalCount(202999) and 8 > inventory:itemTotalCount(203001)
				and CheckTierItems() >= 8 ) then
				UMM_TakeMail(); yrest(4000);
			end;
			RoMScript("CloseWindows()"); yrest(500); inventory:update();
			if( 8 > inventory:itemTotalCount(202999)					-- Amount of Random Fusion Stones
				and 8 > inventory:itemTotalCount(203001)				-- Amount of Fusion Stones
				and UseFusionSender and CheckTierItems() >= 8 and inventory:itemTotalCount(0) >= 8 )
				or ( 8 > inventory:itemTotalCount(203001) and Make2StatTier ) then
				if( Make2StatTier ) then
					LoginNextChar()
				else
					printf("Relog to FusionSender.\n");
					RoMScript("CloseWindows()");
					BotsendedFusionStone = 0
					-- relog to FusionSender
					ChangeChar(CharList[2][1].chars[1], CharList[2][1].account);
				end
				loadPaths(__WPL.FileName)
			end
		end
		-- Sascilia Steppes Mailbox
	elseif( Cur_ZoneId == 10 and mainLevel >= 20 and 150 > distance(player.X,player.Z,-38220,1758) and not Make2StatTier ) then
		if( 8 > CheckTierItems() or 1 > inventory:getItemCount(203276) or 15840 > Cur_Gold ) then
			printf("\aError. Not enough Experience Orb or TierItems.\n")
			if( player.Name ~= LastMailSender ) then
				cprintf(cli.white, player.Name.." LoginNextToon.\n")
				-- Wait for Login next toon
				LoginNextChar()
				loadPaths(__WPL.FileName)
			else
				--error("\a\a\aError. Not enough Tier Items.");
				-- relog to MailSender1
				cprintf(cli.red, player.Name.." \a\a\aError. Not enough Tier Items. Login to MailSender1.\n")
				ChangeChar(CharList[1][1].chars[1], CharList[1][1].account);
				loadPaths(__WPL.FileName)
			end
		end
	end;

	-- Hide nuby pet
	if( mainLevel > 11 and player:hasBuff(509705)) then inventory:useItem(207051);end;

	-- get Recipient
	function getRecipient()
		local timer = os.clock()
		cprintf(cli.white, "Recipient checker started.\n")
		RoMScript("DEFAULT_CHAT_FRAME:AddMessage('|cffffff00Tirodel:Recipient checker started..|r')")
		repeat
			local time, moreToCome, name, msg = EventMonitorCheck("MSGWHISPER", "4,1")
			if( time ~= nil and msg ~= nil ) then
				if( bot.ClientLanguage == "RU" ) then msg = utf82oem_russian(msg) end
				cprintf(cli.lightred, "Time: " ..os.date().. " Char name: " ..name.. " Message: " ..msg.. "\n")
				if( string.find(msg,TierMessage1) and name ~= last_name) or (string.find(msg,TierMessage1) and (os.clock() - timer) > 500 ) then
					RoMScript("DEFAULT_CHAT_FRAME:AddMessage('|cffffff00Tirodel:Recipient Checked: " ..name.. ".|r')")
					last_name = name
					return name
				end
			end
			if( (os.clock() - timer) > MailSenderWhaitTime ) then
				os.execute("TASKKILL /PID " ..findProcessByWindow(getWin()).. " /F")
				os.exit()
				player.free_counter1 = 0
				repeat
					player.free_counter1 = player.free_counter1 + 1
					printf("\a\aError or final!\n");
					yrest(20000)
				until player.free_counter1 == 10
				--os.execute("TASKKILL /PID " ..findProcessByWindow(getWin()).. " /F")
				--os.exit()
			end
			yrest(50)
		until false
	end;


--== 2 ==--
--==== Mana Stone Sender onLoad ====--
	-- Check Level and Name of Mana Stone Sender
	if( player.Name == TierReceiver[1] ) then
		cprintf(cli.lightred, "You are too far from Howling Mountains.\n")
		LoginNextChar()
		loadPaths(__WPL.FileName)
	elseif( mainLevel > 16 and Cur_ZoneId == 400 ) then
		cprintf(cli.lightred, "You are too far from Howling Mountains.\n")
		repeat
			player:target_NPC(110758); yrest(1000);
			sendMacro("SpeakFrame_ListDialogOption(1, 1)");
			waitForLoadingScreen(10);
			player:update();
		until getZoneId() ~= 400
		loadPaths(__WPL.FileName)
	elseif( 21 > mainLevel and mainLevel > 16 and Cur_ZoneId ~= 1 and player.Class1 ~= CLASS_PRIEST ) then
		RestartAfterAllError = false;
		error("\a\aYou are too far from Howling Mountains.")
	elseif( mainLevel > 16 and Cur_ZoneId == 1 and distance(player.X,player.Z,-444,-5975) > 70 ) then
		RestartAfterAllError = false;
		error("\a\aYou are too far from Logar Mailbox.")
	elseif( mainLevel > 16 and Cur_ZoneId == 1 and 100 > distance(player.X,player.Z,-444,-5975) and 1 > inventory:itemTotalCount(203276) ) then	-- Amount of Experience Orb
		RestartAfterAllError = false;
		error("\a\aError. Not enough Experience Orb.");
	elseif( mainLevel > 16 and Cur_ZoneId == 1 and 100 > distance(player.X,player.Z,-444,-5975) ) then
		-- Open Mailbox
		player:target_Object(110771,1500);							-- Логарский почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1500);
		UMM_DeleteEmptyMail();
		if( inventory:itemTotalCount(0) >= 10 ) then
			UMM_TakeMail (); yrest(4000);
		end
		RoMScript("CloseWindows()"); yrest(500); inventory:update();
		__WPL:setWaypointIndex(__WPL:findWaypointTag("ManaStonesLogarMailbox"));
	end;

	-- Find Variant for Send Mana Stones
	function FindVariantSendManaStones()
		-- Check Mana Stones in inventory
		local Grad = CheckManaStones()
		for i,variant in pairs(SendVariants) do
			for j,values in pairs(variant) do
				--cprintf(cli.white, "value %s, Grad %s.\n", values, Grad[j])
				if values > Grad[j] then
					break
				elseif j == #variant then
					return i, variant
				end
			end
		end
		return
	end;

	-- Print Mana Stones Send Mode
	function PrintManaStonesSendMode(variant, Table)
		local pr = {}
		for i,v in pairs(Table) do
			if v ~= 0 then pr[i] = " T"..(i+3).."-"..v.."," else pr[i] = "" end
		end
		cprintf(cli.white, "Tirodel_ll: Variant%s.%s%s%s%s%s%s\n", variant, pr[1], pr[2], pr[3], pr[4], pr[5], pr[6])
	end;

	-- Find and Send Mana Stones
	function SendManaStones(recipient)
		-- Find Variant for Send Mana Stones
		local variant, send = FindVariantSendManaStones()
		-- if Ok Send Mana Stones
		if variant then
			-- Print variant
			PrintManaStonesSendMode(variant, send)
			-- Check recipient
			Recipient = recipient or getRecipient();
			-- Selecting and Send Item
			player:target_Object({110538,110771,112113,112778},1500)						-- Логарский почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
			if send[1] ~= 0 then UMM_SendByNameOrId(Recipient, 202843, send[1]); yrest(500); end	-- T4 Mana Stones
			if send[2] ~= 0 then UMM_SendByNameOrId(Recipient, 202844, send[2]); yrest(500); end	-- T5 Mana Stones
			if send[3] ~= 0 then UMM_SendByNameOrId(Recipient, 202845, send[3]); yrest(500); end	-- T6 Mana Stones
			if send[4] ~= 0 then UMM_SendByNameOrId(Recipient, 202846, send[4]); yrest(500); end	-- T7 Mana Stones
			if send[5] ~= 0 then UMM_SendByNameOrId(Recipient, 202847, send[5]); yrest(500); end	-- T8 Mana Stones
			if send[6] ~= 0 then UMM_SendByNameOrId(Recipient, 202848, send[6]); yrest(500); end	-- T9 Mana Stones
			if send[7] ~= 0 then UMM_SendByNameOrId(Recipient, 202849, send[7]); yrest(500); end	-- T10 Mana Stones
			UMM_SendByNameOrId (Recipient, 203276, 1)				-- Шар опыта: 10 000 очков
			RoMScript("CloseWindows()"); yrest(500); inventory:update();
			BotsendedManaStone = send[1]+send[2]+send[3]+send[4]+send[5]+send[6]+send[7]
			BotSendedMail = BotSendedMail + BotsendedManaStone + 1
			-- Send ChatMessage to recipient
			sendMacro("SendChatMessage(\'"..TierMessage2.."\', 'WHISPER', 0, \'"..Recipient.."\');");
		else
			return
		end
	end;


--== 3 ==--
--==== Fusion Stone Sender onLoad ====--
	-- Send Fusion Stones
	function SendFusionStones(_recipient, _stoneID, _stats)
		local UMM_FromSlot = 61				-- Default 61, first slot
		local UMM_ToSlot = 120				-- Default 240, last slot of bag 6

		local function markToSend(_slotnumber)
			local item = inventory.BagSlot[_slotnumber + 60]
			item:update()
			if item.Empty then return end

			local bagid = math.floor((_slotnumber-1)/30+1)
			local slotid = _slotnumber - (bagid * 30 - 30)
			RoMScript("UMMMassSendItemsSlotTemplate_OnClick(_G['UMMFrameTab3BagsBag"..bagid.."Slot"..slotid.."'])")
		end

		local _stoneID = _stoneID or 203001							-- Камень соединения с Выностливость и двумя произвольными
		
		-- place stats in table if not already
		if type(_stats) == "number" or type(_stats) == "string" then
			_stats = {_stats}
		end
		printf("Send Fusion Stones. StoneID: %s, to charname: %s.\n", _stoneID, _recipient);
		
		-- find Fusion Stones
		inventory:update()
		local sendlist = {}
		for item = UMM_FromSlot, UMM_ToSlot, 1 do 					-- for each inventory
			local slotitem = inventory.BagSlot[item];
			local slotNumber = slotitem.SlotNumber - 60
			if( slotitem.Id == _stoneID and slotitem.ObjType == 5 ) then
				for i, stat in pairs(_stats) do
					if( type(stat) == "table" ) then
						if( #slotitem.Stats == #stat ) then
							for j, value in pairs(stat) do
								if( bot.ClientLanguage == "RU" ) then
									slotitem.Stats[j].Name = utf82oem_russian(slotitem.Stats[j].Name);
								end
								if( slotitem.Stats[j].Id == value or slotitem.Stats[j].Name == value ) then
									printf("j: %s, slotitem.Stats[j]Id: %s, slotitem.Stats[j]Name: %s, value: %s,\n", j, slotitem.Stats[j].Id, slotitem.Stats[j].Name, value);
									if( j == #stat ) then
										-- Add to table
										table.insert(sendlist, slotNumber)
									end
								else
									break
								end
							end
						end
					else	-- for single stat
						if( #slotitem.Stats == #_stats ) then
							if( bot.ClientLanguage == "RU" ) then
								slotitem.Stats[i].Name = utf82oem_russian(slotitem.Stats[i].Name);
							end
							if( slotitem.Stats[i].Id == stat or slotitem.Stats[i].Name == stat ) then
								printf("I: %s, slotitem.Stats[i]Id: %s, slotitem.Stats[i]Name: %s, stat: %s,\n", i, slotitem.Stats[i].Id, slotitem.Stats[i].Name, stat);
								-- Add to table
								table.insert(sendlist, slotNumber)
							else
								break
							end
						end
					end
				end
			end
		end

		cprintf(cli.green,"Sending items to ".._recipient.."...  ")

		-- Check if nothing to send
		if #sendlist == 0 then
			cprintf(cli.lightgreen,"Nothing to send.\n")
			return true
		end

		-- send Fusion Stones
		if( #sendlist ~= 0 ) then
			-- Open correct tab
			RoMScript("UMMFrameTab1:Hide()") yrest(50)
			RoMScript("UMMFrameTab2:Hide()") yrest(50)
			RoMScript("UMMFrameTab3:Show();") yrest(50)
			yrest(1000)
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
				if getLastWarning(RecipientMailFullString, os.clock()-st) then
					inventory:update()
					cprintf(cli.lightgreen,"Recipient's bags are full.\n")
					repeat RoMScript("MailFrame:Hide()") until not RoMScript("MailFrame:IsVisible()")
					return false, "Recipient's bags are full"
				end
			until RoMScript("UMMFrameTab3Status:IsVisible()") == false or not RoMScript("MailFrame:IsVisible()")	
		end
	end;
	--if not UMM_SendByStats  then UMM_SendByStats = SendFusionStones end;


--== 4 ==--
--==== Mail Receiver onLoad ====--
	-- Check if Level >= 20 or Level == 10 and charges = 0 then Login next toon
	local charges = RoMScript("GetMagicBoxEnergy()");
	local Quest = RoMScript("CheckQuest(421457)");
	if( mainLevel >= 20 and Cur_ZoneId ~= 27 and Cur_ZoneId ~= 20 and Cur_ZoneId ~= 10 and player.Name ~= FusionSender ) or ( mainLevel == 1 and Cur_ZoneId ~= 12 and Cur_ZoneId ~= 1 )
		or ( mainLevel > 10 and 40 > mainLevel and player.Class1 == CLASS_PRIEST and player.Name ~= MailSender3 ) then
		RoMScript("DEFAULT_CHAT_FRAME:AddMessage('|cffffff00Tirodel:You are too far from Elven Island or Final.|r')")
		cprintf(cli.lightred, "You are too far from Elven Island.\n")
		LoginNextChar()
		loadPaths(__WPL.FileName)
	elseif( mainLevel >= 10 and 100 > distance(player.X,player.Z,4565,-2175) and Quest == 2 and CheckCountTierItems() > 1 ) then
		cprintf(cli.lightred, "Varanas Mailbox.\n")
		__WPL:setWaypointIndex(__WPL:findWaypointTag("VaranasMailbox"));
	elseif( mainLevel >= 10 and 100 > distance(player.X,player.Z,31797,3597) and Quest == 2 and CheckCountTierItems() > 1 ) then
		cprintf(cli.lightred, "Elven Island Mailbox 2.\n")
		__WPL:setWaypointIndex(__WPL:findWaypointTag("ElvenIslandMailbox2"));
	elseif( mainLevel >= 10 and 100 > distance(player.X,player.Z,4565,-2175) ) or ( mainLevel >= 10 and 100 > distance(player.X,player.Z,31797,3597) ) then
		-- Open Mailbox and take All
		player:target_Object({110538,110771,112113,112778},1000);		-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1500);
		UMM_DeleteEmptyMail();
		UMM_TakeMail(); yrest(4000);
		RoMScript("CloseWindows()"); yrest(500); inventory:update();
		if( 1 > charges and 1 > CheckCountTierItems() ) then
			cprintf(cli.lightred, "Finished. Delete Character.\n")
			sendMacro("}LogoutCharacterDelete=true;a={");
			LoginNextChar()
			loadPaths(__WPL.FileName)
		end
	end;

	-- Whisper to MailSender
	function WhispertoMailSenders()
		CheckTierChannelNumber()
		--if( TierChannelNumber == 0 ) then
		if( TierChannelNumber ~= 0 ) then
			sendMacro("SendChatMessage(\'"..TierMessage1.."\', 'CHANNEL', 0, Luna.ChannelNumber);")
			--sendMacro("SendChatMessage(\'"..TierMessage1.."\', 'CHANNEL', 0, \'"..TierChannelNumber.."\');")
		end
		-- Check MailSender name from file
		local filename = getExecutionPath().."/logs/Tier_Maker.log"
		if not fileExists(filename) then
			filename = getExecutionPath().."/../logs/Tier_Maker.log"
		end
		local file, err = io.open(filename, "r");
		if( file ) then
			local raw = file:read() or ""
			file:close()
			local MailSendername, time = string.match(raw,"name:(.*) time:(.*)")
			if( MailSendername and 600 > os.time() - tonumber(time) ) then
				sendMacro("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..MailSendername.."\');")
				return
			end
		end
		-- Old variant
		if( Make2StatTier ) then
			for i = 1, #FusionStonesReceiver do
				sendMacro("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..FusionStonesReceiver[i].."\');") yrest(1555)
			end
			for i = 1, #ManaStonesReceiver do
				sendMacro("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..ManaStonesReceiver[i].."\');") yrest(1555)
			end
		else
			sendMacro("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..MailSender1.."\');") yrest(1000)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..MailSender2.."\');") yrest(1000)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..MailSender3.."\');") yrest(1000)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..MailSender4.."\');") yrest(1000)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..TierReceiver[2].."\');"); yrest(1500)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..TierReceiver[3].."\');"); yrest(1500)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..TierReceiver[4].."\');"); yrest(1500)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..TierReceiver[5].."\');"); yrest(1500)
			RoMScript("SendChatMessage(\'"..TierMessage1.."\', 'WHISPER', 0, \'"..TierReceiver[6].."\');"); yrest(1500)
		end
	end;

	-- Twink Go
	function TwinkGo()
		local timer = os.clock()
		Account = RoMScript("GetAccountName();")
		cprintf(cli.white, player.Name.."-"..Account..": Whait for command started.\n")
		RoMScript("DEFAULT_CHAT_FRAME:AddMessage('|cffffff00Tirodel: Recipient Go checker started..|r')")
		repeat
			local time, moreToCome, name, msg = EventMonitorCheck("MSGWHISPER", "4,1")
			if( time ~= nil and msg ~= nil ) then
				if( bot.ClientLanguage == "RU" ) then msg = utf82oem_russian(msg) end
				cprintf(cli.lightred, "Time: " ..os.date().. " Char name: " ..name.. " Message: " ..msg.. "\n")
				if string.find(msg,TierMessage2) then
					RoMScript("DEFAULT_CHAT_FRAME:AddMessage('|cffffff00Tirodel:Command Go Checked: " ..name.. ".|r')")
					return name
					--break
				end
			end
			if( (os.clock() - timer) > MailReceiverWhaitTime ) then
				WhispertoMailSenders()
				player.free_counter1 = player.free_counter1 + 1
				timer = os.clock()
			end
			if( player.free_counter1 == 15 ) then
				player.free_counter1 = 0
				--repeat
					player.free_counter1 = player.free_counter1 + 1
					printf("\a\a\a\a\aTwink. Error Error!\n")
					yrest(20000)
				--until player.free_counter1 == 10
				os.execute("TASKKILL /PID " ..findProcessByWindow(getWin()).. " /F")
				os.exit()
			end
			yrest(50)
		until false
	end;

	-- Error Resive Mail
	function ErrorResiveMail()
		player.free_counter1 = player.free_counter1 + 1;
		player:target_Object({110538,110771,112113,112778},1500);		-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1000);
		if( RoMScript ("MailFrame:IsVisible()") ) then
			-- send back
			UMM_DeleteEmptyMail();
			UMM_SendByNameOrId(MailRecipient, StonesOrbs);				-- Камни соединения и Шар опыта: 10 000 очков
			UMM_SendByFusedTierLevel(MailRecipient, 4); yrest(500)		-- Шмотки для тира
			if RoMScript("GetPlayerMoney('copper');") > 1890 then
				UMM_SendMoney(MailRecipient, "All");
			end
			UMM_SendByNameOrId(TierReceiver[2], ManaStones1)			-- T4, T5 and T6 Mana Stones
			UMM_SendByNameOrId(TierReceiver[6], ManaStones2)			-- T7, T8 and T9 Mana Stones
			UMM_SendByNameOrId(TierReceiver[1], ManaStones3)			-- T10, T11 and T12 Mana Stones
			UMM_SendByNameOrId(TierReceiver[6], 203276)					-- Шар опыта: 10 000 очков
			WhispertoMailSenders()
			MailRecipient = TwinkGo();
			player:rest(15);
			RoMScript("CloseWindows()");
			Cur_ZoneId = getZoneId();
			if( Cur_ZoneId == 12 ) then
				__WPL:setWaypointIndex(__WPL:findWaypointTag("ElvenIslandMailbox"));
			elseif( Cur_ZoneId == 1 or Cur_ZoneId == 1002 ) then
				__WPL:setWaypointIndex(__WPL:findWaypointTag("LogarMailbox"));
			end
		else
			-- Variables for Restart client and Bot
			local currAcc = RoMScript("LogID");
			local currChar = RoMScript("CHARACTER_SELECT.selectedIndex");
			local dirPath = string.gsub( getExecutionPath()," ","\" \"" );
			local currPath = __WPL.FileName;
			local Clientlink = TierTwinkClient;		-- specify you client shortcut links name if it not contains *client*
			-- kill Client
			killClient()
			-- Restart client and Bot
			os.execute("START "..dirPath.."/../../micromacro.exe "..dirPath.."/login acc:"..currAcc.." char:"..currChar.." client:"..Clientlink.." path:"..currPath.."")
			os.exit()
		end
	end;

--== 5 ==--
---==== Auto MailSender functions ====---

--== Sascilia Steppes ==--
	-- Sascilia Steppes Mailbox
	function SasciliaSteppesMailbox()
		if( Make2StatTier ) then
			ManaStonesLogarMailbox()
			return
		end
		-- Open Mailbox
		player:target_Object(112113,1500);								-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1500);
		UMM_DeleteEmptyMail();
		inventory:update();
		if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 ) then
			UMM_TakeMail(); yrest(4000);
		end
		RoMScript("CloseWindows()"); yrest(500); inventory:update();

		-- Check recipient
		Recipient = getRecipient();

		-- Selecting and Send Item
		player:target_Object(112113,1500);								-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1500);
		UMM_DeleteEmptyMail();
		if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 ) then
			UMM_TakeMail(); yrest(4000);
			RoMScript("CloseWindows()"); yrest(500); inventory:update();
			player:target_Object(112113,1500);							-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
		end
		BagSpaceS = inventory:itemTotalCount(0); BotsendedS = 0;
		UMM_SendByFusedTierLevel(Recipient, 5, 8); yrest(500)			-- 8 штук шмоток для тира
		UMM_SendByNameOrId(Recipient, 203276, 1); yrest(500)			-- Шар опыта: 10 000 очков
		BotSendedMail = BotSendedMail + 9; BotsendedS = BotsendedS + 9;
		if( 8 > inventory:getItemCount(202999) or 8 > inventory:getItemCount(203001) )then	-- РџСЂРѕРІРµСЂРёС‚СЊ РЅР°Р»РёС‡РёРµ РєР°РјРЅРµР№    
--			UMM_SendMoney(Recipient, 92000);							-- Если камней нету то Послать денег
			UMM_SendMoney(Recipient, 15840);							-- Если камней нету то Послать денег
			BotSendedMail = BotSendedMail + 1; BotsendedS = BotsendedS + 1;
		else
			if( inventory:getItemCount(202999) >= 8 )then
				UMM_SendByNameOrId(Recipient, 202999, 8); yrest(500)	-- Случайный камень соединения
				BotSendedMail = BotSendedMail + 8; BotsendedS = BotsendedS + 8;
			else
				UMM_SendByNameOrId(Recipient, 203001, 8); yrest(500)	-- Камень соединения с Выносливость и произвольными
				BotSendedMail = BotSendedMail + 8; BotsendedS = BotsendedS + 8;
			end
		end
		RoMScript("CloseWindows()"); yrest(500); inventory:update();
		BagSpaceS = inventory:itemTotalCount(0)+2 - BagSpaceS

		-- Send ChatMessage to recipient
		sendMacro("SendChatMessage(\'"..TierMessage2.."\', 'WHISPER', 0, \'"..Recipient.."\');");

		-- Open Mailbox
		player:target_Object(112113,1000);								-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1500);
		UMM_DeleteEmptyMail();
		if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 ) then
			UMM_TakeMail(); yrest(4000); inventory:update();
		end
		RoMScript("CloseWindows()"); yrest(500); inventory:update();

		-- MailSender Report
		local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		cprintf(cli.white, "Random Fusion Stone: %s\n", inventory:itemTotalCount(202999))
		cprintf(cli.white, "Experience Orb:      %s\n", inventory:itemTotalCount(203276))
		cprintf(cli.white, "Excellent Belt:      %s\n", inventory:itemTotalCount(227502))
		cprintf(cli.white, "BotSendedMail:       %s\n", BotSendedMail)
		cprintf(cli.white, "Tier Items:          %s\n", CheckTierItems())
		cprintf(cli.white, "Total Gold:          %s\n", Cur_Gold)
		cprintf(cli.white, "Bag Space:           %s\n", inventory:itemTotalCount(0))

		-- Check Gold and Experience Orb
		if( 15840 > Cur_Gold ) then
			printf("\a\a\a Error. GOLD WARNING!");
		elseif( 1 > inventory:itemTotalCount(203276) ) then			-- Amount of Experience Orb
			printf("\a\a\a Error. Not enough Experience Orb.");	
		end

		-- Player ReLogin for mail unblock
		cprintf(cli.white, player.Name.." BotsendedS: %s, BagSpaceS %s\n", BotsendedS, BagSpaceS)
		if( BotSendedMail >= 50 and CheckTierItems() >= 8 )
			or ( BotsendedS > BagSpaceS and CheckTierItems() >= 8 ) then
			cprintf(cli.white, player.Name.." BotSendedMail: %s, BotsendedS: %s, BagSpaceS %s\n", BotSendedMail, BotsendedS, BagSpaceS)
			cprintf(cli.white, "Player "..player.Name.." ReLogin for mail unblock.\n")
			BotSendedMail = 0
			player:updateBuffs();
			if ( not player:hasBuff(506959) ) then
				--cprintf(cli.white, "You are havnt Premium!\n")
				ChangeChar("current");
				player = CPlayer.new();
				EventMonitorStart("MSGWHISPER", "CHAT_MSG_WHISPER");
			else
				repeat
					inventory:useItem(208456); yrest(1000);
					sendMacro("SpeakFrame_ListDialogOption(1, 3)")
					waitForLoadingScreen(30);
					player:update();
				until getZoneId() == 400
				repeat
					player:target_NPC(110758); yrest(1000);
					sendMacro("SpeakFrame_ListDialogOption(1, 1)");
					waitForLoadingScreen(30);
					player:update();
				until getZoneId() ~= 400
			end
		end

		-- Check amount of Tier Items, Gold and Experience Orb.
		inventory:update();
		if( CheckTierItems() >= 8 and Cur_Gold >= 15840 and inventory:itemTotalCount(203276) >= 1 ) then
			__WPL:setWaypointIndex(__WPL:findWaypointTag("SasciliaSteppesMailbox"));
		elseif( player.Name ~= LastMailSender ) then
			cprintf(cli.white, player.Name.." LoginNextToon.\n")
			-- Wait for Login next toon
			LoginNextChar()
			loadPaths(__WPL.FileName)
		else
			--error("\a\a\aError. Not enough Tier Items.");
			-- relog to MailSender1
			cprintf(cli.red, player.Name.." \a\a\aError. Not enough Tier Items. Login to MailSender1.\n")
			ChangeChar(CharList[1][1].chars[1], CharList[1][1].account);
			loadPaths(__WPL.FileName)
		end
	end;

--== Kampel Town ==--
	-- Freud Dinks Store
	function FreudDinksStore()
		-- Check Bag and amount of Excellent Belt
		inventory:update();
		if( 1 > inventory:itemTotalCount(0) ) and not ( CheckTierItems() >= 8 ) then
			RestartAfterAllError = false;
			error("\a\aError. Not enough BagSpase. Clean Bag and Start again.");
		end

		-- Buy Excellent Belt
		player:openStore(117108); yrest(1000);						-- Фред Дринкс
		store:buyItem(227502, inventory:itemTotalCount(0));			-- Превосходный пояс
		RoMScript("CloseWindows()");
		Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		cprintf(cli.white, "Random Fusion Stone: %s\n", inventory:itemTotalCount(202999))
		cprintf(cli.white, "Experience Orb:      %s\n", inventory:itemTotalCount(203276))
		cprintf(cli.white, "Excellent Belt:      %s\n", inventory:itemTotalCount(227502))
		cprintf(cli.white, "CheckTierItems:      %s\n", CheckTierItems())
		cprintf(cli.white, "Total Gold:          %s\n", Cur_Gold)

		-- Player ReLogin for mail unblock
		cprintf(cli.white, "Player ReLogin for mail unblock.\n")
		player:updateBuffs();
		if ( not player:hasBuff(506959) ) then
			cprintf(cli.white, "You are havnt Premium!\n")
			ChangeChar("current");
			player = CPlayer.new();
			EventMonitorStart("MSGWHISPER", "CHAT_MSG_WHISPER");
		else
			repeat
				inventory:useItem(208456); yrest(1000);
				sendMacro("SpeakFrame_ListDialogOption(1, 3)")
				waitForLoadingScreen(30);
				player:update();
			until getZoneId() == 400
			player:target_NPC(110758); yrest(1000);
			sendMacro("SpeakFrame_ListDialogOption(1, 1)");
			waitForLoadingScreen(30);
			player:update();
		end
	end;

	-- Kampel Town Mailbox
	function KampelTownMailbox()
		-- Open Mailbox
		player:target_Object(110694,1500);							-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1500);
		UMM_DeleteEmptyMail();
		if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 ) then
			UMM_TakeMail(); yrest(4000);
		end
		RoMScript("CloseWindows()"); yrest(500); inventory:update();

		-- Check recipient
		Recipient = getRecipient();

		-- Selecting and Send Item
		player:target_Object(110694,1500);							-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(1500);
		UMM_DeleteEmptyMail();
		if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 ) then
			UMM_TakeMail(); yrest(4000);
			RoMScript("CloseWindows()"); yrest(500); inventory:update();
			player:target_Object(110694,1500);						-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
		end
		BagSpaceS = inventory:itemTotalCount(0); BotsendedS = 0;
		UMM_SendByFusedTierLevel(Recipient, 4, 8); yrest(500)		-- 8 штук шмоток для тира
		UMM_SendByNameOrId(Recipient, 203276, 1); yrest(500)		-- Шар опыта: 10 000 очков
		BotSendedMail = BotSendedMail + 9; BotsendedS = BotsendedS + 9;
		if( 8 > inventory:getItemCount(202999) )then				-- Проверить наличие камней
			UMM_SendMoney(Recipient, 92000);						-- Если камней нету то Послать денег
			BotSendedMail = BotSendedMail + 1; BotsendedS = BotsendedS + 1;
		else
			UMM_SendByNameOrId(Recipient, 202999, 8); yrest(500)	-- Случайный камень соединения
			BotSendedMail = BotSendedMail + 8; BotsendedS = BotsendedS + 8;
		end
		RoMScript("CloseWindows()"); yrest(500); inventory:update();
		BagSpaceS = inventory:itemTotalCount(0)+2 - BagSpaceS

		-- Send ChatMessage to recipient
		sendMacro("SendChatMessage(\'"..TierMessage2.."\', 'WHISPER', 0, \'"..Recipient.."\');");
		
		-- Open Mailbox
		player:target_Object(110694,1000);							-- Почтовый ящик
		RoMScript("ChoiceOption(1);"); yrest(2000);
		UMM_DeleteEmptyMail();
		inventory:update();
		if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 ) then
			UMM_TakeMail(); yrest(4000);
		end
		RoMScript("CloseWindows()"); yrest(500); inventory:update();

		-- MailSender Report
		Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		cprintf(cli.white, "Random Fusion Stone: %s\n", inventory:itemTotalCount(202999))
		cprintf(cli.white, "Experience Orb:      %s\n", inventory:itemTotalCount(203276))
		cprintf(cli.white, "Excellent Belt:      %s\n", inventory:itemTotalCount(227502))
		cprintf(cli.white, "CheckTierItems:      %s\n", CheckTierItems())
		cprintf(cli.white, "BotSendedMail:       %s\n", BotSendedMail)
		cprintf(cli.white, "Total Gold:          %s\n", Cur_Gold)
		cprintf(cli.white, "Bag Space:           %s\n", inventory:itemTotalCount(0))

		if( 92000 > Cur_Gold ) then
			RestartAfterAllError = false;
			error("\a\a\aError. GOLD WARNING!");
		elseif( 1 > inventory:itemTotalCount(203276) ) then			-- Amount of Experience Orb
			RestartAfterAllError = false;
			error("\a\a\aError. Not enough Experience Orb.");	
		end

		-- Player ReLogin for mail unblock
		cprintf(cli.white, player.Name.." BotsendedS: %s, BagSpaceS %s\n", BotsendedS, BagSpaceS)
		if( BotSendedMail >= 50 and CheckTierItems() >= 8 )
			or ( BotsendedS > BagSpaceS and CheckTierItems() >= 8 ) then
			cprintf(cli.white, player.Name.." BotSendedMail: %s, BotsendedS: %s, BagSpaceS %s\n", BotSendedMail, BotsendedS, BagSpaceS)
			cprintf(cli.white, "Player "..player.Name.." ReLogin for mail unblock.\n")
			BotSendedMail = 0
			player:updateBuffs();
			if ( not player:hasBuff(506959) ) then
				--cprintf(cli.white, "You are havnt Premium!\n")
				ChangeChar("current");
				player = CPlayer.new();
				EventMonitorStart("MSGWHISPER", "CHAT_MSG_WHISPER");
			else
				repeat
					inventory:useItem(208456); yrest(1000);
					sendMacro("SpeakFrame_ListDialogOption(1, 3)")
					waitForLoadingScreen(30);
					player:update();
				until getZoneId() == 400
				repeat
					player:target_NPC(110758); yrest(1000);
					sendMacro("SpeakFrame_ListDialogOption(1, 1)");
					waitForLoadingScreen(30);
					player:update();
				until getZoneId() ~= 400
			end
		end

		-- Check amount of Excellent Belt
		inventory:update();
		if( CheckTierItems() >= 8 ) then
			__WPL:setWaypointIndex(__WPL:findWaypointTag("KampelTownMailbox"));
		end
	end;
	
--== Wailing Fjord ==--
	-- Spiderfoot Store
	function SpiderfootStore()
		-- check distance to Didide Spiderfoot
		local Spiderfoot = player:findNearestNameOrId(123010);
		if Spiderfoot and distance(player.X,player.Z, Spiderfoot.X,Spiderfoot.Z) > 50 then
			local Dist = math.sqrt( (player.X - Spiderfoot.X)^2 + (player.Z - Spiderfoot.Z)^2 )
			local New_X = Spiderfoot.X + 55 * (player.X - Spiderfoot.X) / Dist
			local New_Z = Spiderfoot.Z + 55 * (player.Z - Spiderfoot.Z) / Dist
			player:moveTo(CWaypoint(New_X,New_Z),true);
		end
		-- buy Recall Belt
		player:openStore(123010);										-- Didide Spiderfoot
		if( 8 > inventory:itemTotalCount(202999)						-- Amount of Random Fusion Stones
			and 8 > inventory:itemTotalCount(203001) )then				-- Amount of Fusion Stones
			if( BuyFusionStoneWithStat )then
				local ItemsTobuy = inventory:getItemCount(0) - (8 - inventory:itemTotalCount(203001))
				store:buyItem(228966, ItemsTobuy);						-- Пояс возвращения 6125
			else
				local ItemsTobuy = inventory:getItemCount(0) - (8 - inventory:itemTotalCount(202999))
				store:buyItem(228966, ItemsTobuy);						-- Пояс возвращения 6125
			end
		else
			store:buyItem(228966, inventory:getItemCount(0));			-- Пояс возвращения 6125
		end
		RoMScript("CloseWindows()"); inventory:update();
		-- Error if not receive Recall Belt
		local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		if( 8 > CheckTierItems() )then
			if( Cur_Gold > 6124 )then
				__WPL:setWaypointIndex(__WPL:findWaypointTag("Spiderfoot"));
			else
				RestartAfterAllError = false;
				error("\a\a\aError. Not enough Gold for buy Recall Belt.");
			end
		end
	end;

	-- Wailing Fjord Mailbox
	function WailingFjordMailbox()
		repeat
			-- Open Mailbox
			player:target_Object(123006);									-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
			UMM_DeleteEmptyMail();
			inventory:update();
			if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 )
				or ( 8 > inventory:itemTotalCount(202999) and 8 > inventory:itemTotalCount(203001)
				and CheckTierItems() >= 8 ) then
				UMM_TakeMail(); yrest(4000);
			end
			BagSpaceS = inventory:itemTotalCount(0); BotsendedS = 0;
			RoMScript("CloseWindows()"); yrest(500); inventory:update();
			local start = os.clock()

			-- if make 2 stat tier
			if( Make2StatTier and inventory:itemTotalCount(203001) >= 8 and CheckTierItems() >= 8 ) then
				-- Check recipient
				Recipient = getRecipient();

				-- Selecting and Send Item
				player:target_Object(123006);								-- Почтовый ящик
				RoMScript("ChoiceOption(1);"); yrest(1500);
				UMM_DeleteEmptyMail();
				if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 )
					or ( 8 > inventory:itemTotalCount(203001) and CheckTierItems() >= 8 ) then
					UMM_TakeMail(); yrest(4000);
					RoMScript("CloseWindows()"); yrest(500); inventory:update();
					player:target_Object(123006);							-- Почтовый ящик
					RoMScript("ChoiceOption(1);"); yrest(1500);
					UMM_DeleteEmptyMail();
				end
				BagSpaceS = inventory:itemTotalCount(0); BotsendedS = 0;
				UMM_SendByFusedTierLevel(Recipient, 5, 8); yrest(500)		-- 8 штук шмоток для тира
				UMM_SendByNameOrId(Recipient, 203276, 1); yrest(500)		-- Шар опыта: 10 000 очков
				BotSendedMail = BotSendedMail + 9; BotsendedS = BotsendedS + 9;
				if( 8 > inventory:itemTotalCount(203001) ) then
					UMM_TakeMail(); yrest(4000);
					RoMScript("CloseWindows()"); yrest(500); inventory:update();
					player:target_Object(123006);							-- Почтовый ящик
					RoMScript("ChoiceOption(1);"); yrest(1500);
					BagSpaceS = inventory:itemTotalCount(0); BotsendedS = 0;
				end
				if( 8 > inventory:itemTotalCount(203001) ) then break end
				UMM_SendByNameOrId(Recipient, 203001, 8); yrest(500)		-- Камень соединения с Выносливость и произвольными
				BotSendedMail = BotSendedMail + 8; BotsendedS = BotsendedS + 8;
				RoMScript("CloseWindows()"); yrest(500); inventory:update();
				BagSpaceS = inventory:itemTotalCount(0)+2 - BagSpaceS

				-- Send ChatMessage to recipient
				sendMacro("SendChatMessage(\'"..TierMessage2.."\', 'WHISPER', 0, \'"..Recipient.."\');");
			-- normal send mail
			elseif( not Make2StatTier and CheckTierItems() >= 8 ) then
				-- Check recipient
				Recipient = getRecipient();

				-- Selecting and Send Item
				player:target_Object(123006);								-- Почтовый ящик
				RoMScript("ChoiceOption(1);"); yrest(1500);
				UMM_DeleteEmptyMail();
				if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 )
					or ( 8 > inventory:itemTotalCount(202999) and 8 > inventory:itemTotalCount(203001)
					and CheckTierItems() >= 8 ) then
					UMM_TakeMail(); yrest(4000);
					RoMScript("CloseWindows()"); yrest(500); inventory:update();
					player:target_Object(123006);							-- Почтовый ящик
					RoMScript("ChoiceOption(1);"); yrest(1500);
				end
				BagSpaceS = inventory:itemTotalCount(0) - ItemQueueCount();
				BotsendedS = 0;
				if( not RoMScript("MailFrame:IsVisible()") ) then
					player:target_Object(123006); yrest(500);				-- Почтовый ящик
					ChoiceOptionByName(getTEXT("SO_OPENMAIL")); yrest(500);	-- 'Открыть почтовый ящик'
				end
				-- send Tier item
				UMM_SendByFusedTierLevel(Recipient, 5, 8); yrest(500)		-- 8 штук шмоток для тира
				-- send Tier item agane if error
				inventory:update();
				local ItemCount = inventory:itemTotalCount(0) - BagSpaceS;
				if( 8 > ItemCount )then
					UMM_SendByFusedTierLevel(Recipient, 5, ItemCount);		-- 8 штук шмоток для тира
				end
				-- send Orb
				UMM_SendByNameOrId(Recipient, 203276, 1); yrest(500)		-- Шар опыта: 10 000 очков
				BotSendedMail = BotSendedMail + 9;
				BotsendedS = BotsendedS + 9;
				-- take mails
				if( 8 > inventory:itemTotalCount(202999) and CheckTierItems() >= 8
					or 8 > inventory:itemTotalCount(203001) and CheckTierItems() >= 8 ) then
					UMM_TakeMail(); yrest(4000);
					RoMScript("CloseWindows()"); yrest(500); inventory:update();
					player:target_Object(123006);							-- Почтовый ящик
					RoMScript("ChoiceOption(1);"); yrest(1500);
					BagSpaceS = inventory:itemTotalCount(0) - ItemQueueCount();
					BotsendedS = 0;
				end
				-- send Money or fusion stones
				if( 8 > inventory:getItemCount(202999) and 8 > inventory:getItemCount(203001) ) then	-- Проверить наличие камней
--					UMM_SendMoney(Recipient, 92000);						-- Если камней нету то Послать денег
					UMM_SendMoney(Recipient, 15840);						-- Если камней нету то Послать денег
					BotSendedMail = BotSendedMail + 1; BotsendedS = BotsendedS + 1;
				else
					if( inventory:getItemCount(202999) >= 8 ) then
						UMM_SendByNameOrId(Recipient, 202999, 8); yrest(500)	-- Случайный камень соединения
						BotSendedMail = BotSendedMail + 8;
						BotsendedS = BotsendedS + 8;
						-- send agane if error
						inventory:update();
						local ItemCount = inventory:itemTotalCount(0) - BagSpaceS;
						if( 8 > ItemCount )then
							UMM_SendByNameOrId(Recipient, 202999, ItemCount);	-- Случайный камень соединения
						end
					else
						UMM_SendByNameOrId(Recipient, 203001, 8); yrest(500)	-- Камень соединения с Выносливость и произвольными
						BotSendedMail = BotSendedMail + 8;
						BotsendedS = BotsendedS + 8;
						-- send agane if error
						inventory:update();
						local ItemCount = inventory:itemTotalCount(0) - BagSpaceS;
						if( 8 > ItemCount )then
							UMM_SendByNameOrId(Recipient, 203001, ItemCount);	-- Камень соединения с Выносливость и произвольными
						end
					end
				end
				RoMScript("CloseWindows()"); yrest(500); inventory:update();
				BagSpaceS = inventory:itemTotalCount(0)+1 - BagSpaceS

				-- Send ChatMessage to recipient
				sendMacro("SendChatMessage(\'"..TierMessage2.."\', 'WHISPER', 0, \'"..Recipient.."\');");
			end

			-- check Mail Sender Canot Do It
			if getLastWarning(MailSenderCanotDoItString, os.clock()-start) then
				local client = TierTwinkClient;
				local account = RoMScript("LogID");
				local character = RoMScript("CHARACTER_SELECT.selectedIndex");
				print("killClient ...")
				killClient()
				print("startClient: "..client..", "..account..", "..character)
				login(character, account, client)
			end

			-- Open Mailbox
			player:target_Object(123006);									-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
			UMM_DeleteEmptyMail();
			inventory:update();
			if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 )
				or ( 8 > inventory:itemTotalCount(202999) and 8 > inventory:itemTotalCount(203001)
				and CheckTierItems() >= 8 ) then
				UMM_TakeMail(); yrest(4000);
			end
			RoMScript("CloseWindows()"); yrest(500); inventory:update();

			-- MailSender Report
			local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
			cprintf(cli.white, "Random Fusion Stone: %s\n", inventory:itemTotalCount(202999))
			cprintf(cli.white, "Experience Orb:      %s\n", inventory:itemTotalCount(203276))
			cprintf(cli.white, "BotSendedMail:       %s\n", BotSendedMail)
			cprintf(cli.white, "Fusion Stone:        %s\n", inventory:itemTotalCount(203001))
			cprintf(cli.white, "Recall Belt:         %s\n", inventory:itemTotalCount(228966))
			cprintf(cli.white, "Tier Items:          %s\n", CheckTierItems())
			cprintf(cli.white, "Total Gold:          %s\n", Cur_Gold)
			cprintf(cli.white, "Bag Space:           %s\n", inventory:itemTotalCount(0))

			-- Player ReLogin for mail unblock
			cprintf(cli.white, player.Name.." BotSendedMail: %s, BotsendedS: %s, BagSpaceS %s\n", BotSendedMail, BotsendedS, BagSpaceS)
			if ( BotSendedMail >= 50 and CheckTierItems() >= 8 )
				or ( BotsendedS > BagSpaceS and CheckTierItems() >= 8 ) then
				cprintf(cli.white, player.Name.." ReLogin for mail unblock.\n")
				BotSendedMail = 0
				player:updateBuffs();
				if ( not player:hasBuff(506959) ) then
					--cprintf(cli.white, "You are havnt Premium!\n")
					ChangeChar("current");
					player = CPlayer.new();
					EventMonitorStart("MSGWHISPER", "CHAT_MSG_WHISPER");
				else
					repeat
						inventory:useItem(208456); yrest(1000);
						sendMacro("SpeakFrame_ListDialogOption(1, 3)")
						waitForLoadingScreen(30);
						player:update();
					until getZoneId() == 400
					repeat
						player:target_NPC(110758); yrest(1000);
						sendMacro("SpeakFrame_ListDialogOption(1, 1)");
						waitForLoadingScreen(30);
						player:update();
					until getZoneId() ~= 400
				end
			end

			-- Open Mailbox
			player:target_Object(123006);									-- Почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
			UMM_DeleteEmptyMail();
			inventory:update();
			if( inventory:itemTotalCount(0) >= 30 and CheckTierItems() >= 16 )
				or ( 8 > inventory:itemTotalCount(202999) and 8 > inventory:itemTotalCount(203001)
				and CheckTierItems() >= 8 ) then
				UMM_TakeMail(); yrest(4000);
			end
			RoMScript("CloseWindows()"); yrest(500); inventory:update();

			-- Check Gold and Experience Orb and amount of Recall Belt or Tier Items
			inventory:update();
			if( 64840 > Cur_Gold and 8 > CheckTierItems() and 8 > inventory:itemTotalCount(202999) and 8 > inventory:itemTotalCount(203001) ) then
				RestartAfterAllError = false;
				error("\a\a\aError. GOLD WARNING!");
			elseif( 1 > inventory:itemTotalCount(203276) ) then			-- Amount of Experience Orb
				if( Make2StatTier and player.Name ~= LastMailSender ) then
					LoginNextChar()
					loadPaths(__WPL.FileName)
					break
				else
					RestartAfterAllError = false;
					error("\a\a\aError. Not enough Experience Orb.");
				end
			elseif( 8 > inventory:itemTotalCount(202999)				-- Amount of Random Fusion Stones
				and 8 > inventory:itemTotalCount(203001)				-- Amount of Fusion Stones
				and UseFusionSender and CheckTierItems() > 8 and inventory:itemTotalCount(0) >= 8 )
				or ( 8 > inventory:itemTotalCount(203001) and Make2StatTier ) then
				if( Make2StatTier ) then
					LoginNextChar()
				else
					printf("Relog to FusionSender.\n");
					RoMScript("CloseWindows()");
					BotsendedFusionStone = 0
					-- relog to FusionSender
					ChangeChar(CharList[2][1].chars[1], CharList[2][1].account);
				end
				loadPaths(__WPL.FileName)
				break
			elseif( 8 > CheckTierItems() ) then							-- Amount of Recall Belt or Tier Items
				break
			end
		until false
	end;

--== 6 ==--
---==== Auto MailReceiver functions ====---

--== Varanas ==--
	-- Varanas Twink Unstick
	function VaranasTwinkUnstick()
		-- Check for Varanas Error
		local LieveA = player:findNearestNameOrId(110755)
		if( not LieveA or LieveA.Y - player.Y > 50 ) then TirodelUnstick() end

		-- Tp to XBZ
		if RoMScript("AdvancedMagicBoxFrame == true") or RoMScript("MagicBoxFrame == true") then
			player:target_NPC(110755); yrest(1500);						-- Лив
			RoMScript("ChoiceOption(2);");  yrest(1500);
			RoMScript("ChoiceOption(2);");
			waitForLoadingScreen(60);
			player:update()
			__WPL:setWaypointIndex(__WPL:findWaypointTag("MakeMS"));
		else
			player:target_NPC(110755); yrest(1500);						-- Лив
			RoMScript("ChoiceOption(1);");
			waitForLoadingScreen(60);
			player:update()
			__WPL:setWaypointIndex(__WPL:findWaypointTag("Transmutor"));
		end
	end;

	-- Varanas Charges
	function VaranasCharges()
		-- Check for Varanas Error
		local Lehman = player:findNearestNameOrId(111367)
		if( not Lehman or Lehman.Y - player.Y > 50 ) then TirodelUnstick() end;

		-- Take Giftbags
		--inventory:useItem(201849);									-- 8 Lvl Giftbag

		-- Complete Quest for Arcane Transmutor
		player:target_NPC(111367); yrest(1000);							-- Леман
		RoMScript("OnClick_QuestListButton(1, 1);");
		sendMacro("AcceptQuest()");
		player:target_NPC(111367); yrest(1000);							-- Леман
		RoMScript("OnClick_QuestListButton(3, 1);");
		RoMScript("CompleteQuest()"); yrest(1000);	
		player.free_counter1 = player.free_counter1 + 1;

		-- Error if not find NPC. Twink Unstick
		if( player.free_counter1 == 5 ) then
			TirodelUnstick()
		end;

		if RoMScript("CheckQuest(421457)") ~= 2 then					-- Not did the quest "Магический Преобразователь"
		--repeat MBEnergy = RoMScript("GetMagicBoxEnergy()"); yrest(500) until MBEnergy
		--if 10 > MBEnergy or RoMScript("AdvancedMagicBoxFrame == nil") and RoMScript("MagicBoxFrame == nil") then
			__WPL:setWaypointIndex(__WPL:findWaypointTag("VaranasCharges"));
		elseif( FindVariantSendManaStones() or (inventory:getItemCount(202999) + inventory:getItemCount(203001)) >= 8 ) then
		--elseif MBEnergy == 10 and (inventory:getItemCount(202999) + inventory:getItemCount(203001)) >= 8 then
			-- Tp to Elven Island
			if player.Race == RACE_ELF then
				RoMScript("UseSkill(1,2);");							-- Tp to Elven Island
				print("		Tp to Elven Island");
				waitForLoadingScreen(30);
				player:update();
			end
			if( getZoneId() ~= 12 ) then 
				cprintf(cli.lightred, "You are too far from Elven Island.\n");
			else
				__WPL:setWaypointIndex(__WPL:findWaypointTag("ELF10Lvl"));
			end
		elseif( 8 > (inventory:getItemCount(202999) + inventory:getItemCount(203001)) ) then
		--elseif ( RoMScript("AdvancedMagicBoxFrame == true") or RoMScript("MagicBoxFrame == true") ) and ( 8 > (inventory:getItemCount(202999) + inventory:getItemCount(203001)) ) then
			-- Set faceDirection and Rotation, go to Buy Fusion Stone
			local angle = math.atan2(-4312 - player.Z, 5495 - player.X)
			player:faceDirection(angle)
			camera:setRotation(angle)
		end
	end;

	-- Varanas Lyeve
	function VaranasLyeve()
		-- Take Giftbags
		--inventory:useItem(201850);								-- 9 Lvl Giftbag
		-- Tp to VCS
		player:target_NPC(110922); yrest(1000);						-- Лив
--		RoMScript("ChoiceOption(2);");		-- tp to VCS
		RoMScript("ChoiceOption(4);");		-- tp to IPV
		waitForLoadingScreen(60); yrest(2500);
		player:update();

		-- Check for Varanas VCS Error
		if distance(player.X,player.Z,4745,-1967) > 70 and 70 > distance(player.X,player.Z,2846,-853) then
			player:update();
			-- Check for NPC Noriv Error
			local Noriv = player:findNearestNameOrId(110726)
			if not Noriv or (Noriv.Y - player.Y) > 30 then
				TirodelUnstick()
			else
				-- Tp to WPV
				player:target_NPC(110726); yrest(1000);					-- Норив
				RoMScript("ChoiceOption(3);");
				waitForLoadingScreen(60); yrest(2500);
				player:update();
				-- Check for WPV Error
				if distance(player.X,player.Z,2908,-798) > 70 then
					TirodelUnstick()
				end
			end
		elseif 70 > distance(player.X,player.Z,2846,-853) then
			--  Check and Buy Random Fusion Stone or Make Mana Stones
			inventory:update();
			if( ErrorSendStone == true ) then
				__WPL:setWaypointIndex(__WPL:findWaypointTag("MakeMS"));
			else
				if( 8 > inventory:getItemCount(202999) and 8 > inventory:getItemCount(203001) )then
					__WPL:setWaypointIndex(__WPL:findWaypointTag("BuyFS"));
				else
					__WPL:setWaypointIndex(__WPL:findWaypointTag("MakeMS"));
				end
			end
		end
	end;

	-- Varanas Buy Fusion Stone
	function VaranasBuyFusionStone()
		-- check for Fusion Stone Sender
		if player.Name == FusionSender then
			__WPL:setWaypointIndex(__WPL:findWaypointTag("MassBuyFusionStones"));
		else
			-- Buy Fusion Stone
			local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
			player:openStore(110576); yrest(1000);						-- Оделия Проул
			store:buyItem(202999, (Cur_Gold/1980));						-- Случайный камень соединения
			--store:buyItem(203001, inventory:getItemCount(0));			-- Камень соединения с Выностливость и двумя произвольными
			RoMScript("CloseWindows()"); inventory:update();
			
			-- Error if not receive Random Fusion Stone
			local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
			if( 8 > inventory:getItemCount(203001) and 8 > inventory:getItemCount(202999) and Cur_Gold >= 1980 )then    
				__WPL:setWaypointIndex(__WPL:findWaypointTag("VaranasBuyFusionStone"));
			else
				if( ErrorSendStone == true or player.Race ~= RACE_ELF ) then
					-- Set faceDirection and Rotation
					local angle = math.atan2(3064 - player.Z, -1740 - player.X)
					player:faceDirection(angle)
					camera:setRotation(angle)
				else
					-- Tp to Elven Island
					RoMScript("UseSkill(1,2);");						-- Tp to Elven Island
					print("		Tp to Elven Island");
					waitForLoadingScreen(10); yrest(1500);
					player:update();
					if ( getZoneId() ~= 12 ) then 
						cprintf(cli.lightred, "You are too far from Elven Island.\n");
						-- Set faceDirection and Rotation
						local angle = math.atan2(3064 - player.Z, -1740 - player.X)
						player:faceDirection(angle)
						camera:setRotation(angle)
					else
						__WPL:setWaypointIndex(__WPL:findWaypointTag("ELF10Lvl"));
					end
				end
			end
		end
	end;

--== Elven Island ==--
	-- Start Twink
	function StartTwink()
		-- collect garbage
		sendMacro("DEFAULT_CHAT_FRAME:AddMessage(collectgarbage('count') .. ' before');");
		sendMacro("collectgarbage('collect');"); yrest(1500)
		sendMacro("DEFAULT_CHAT_FRAME:AddMessage(collectgarbage('count') .. ' after');");

		-- Take Giftbags
		inventory:useItem(201843);									-- 1 Lvl Giftbag

		local MBEnergy = RoMScript("GetMagicBoxEnergy()");
		local MBQuest = RoMScript("CheckQuest(421457)");			-- quest "Магический Преобразователь"
		if( MBQuest ~= 2 and (MBEnergy == nil or 1 > MBEnergy) ) then
			-- Whisper to MailSender and whait for Command Go
			WhispertoMailSenders()
			MailRecipient = TwinkGo();
		end

		-- Set faceDirection and Rotation
		if( Cur_ZoneId == 12 ) then
			local angle = math.atan2(31925 - player.Z, 3391 - player.X)
			player:faceDirection(angle)
			camera:setRotation(angle)
		end
	end;

	-- Elven Island Mailbox
	function ElvenIslandMailbox()
		-- Check for Error
		if( player.free_counter1 > 5 ) then		-- player.free_counter1 > 10
			--error("\a\a\a\a\a\a\aError. Error. Error. Elven Island Mailbox.");
			TirodelUnstick(true)
		end;
		-- Open Mailbox and take All mails
		player:target_Object({110538,110771,112113,112778},1000);				-- Почтовый ящик Острова Эльфов
		RoMScript("ChoiceOption(1);"); yrest(1000);
		UMM_DeleteEmptyMail();
		UMM_TakeMail(); yrest(4000);
		RoMScript("CloseWindows()"); yrest(500); inventory:update();
		player:target_Object({110538,110771,112113,112778},1000);				-- Почтовый ящик Острова Эльфов
		RoMScript("ChoiceOption(1);"); yrest(1000);
		UMM_DeleteEmptyMail();
		UMM_TakeMail(); yrest(4000);
		RoMScript("CloseWindows()"); yrest(500); inventory:update();

		-- Check Received Items and Money if not All Ok then reinit all again
		local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		if( 1 > inventory:getItemCount(203276) and 10 > CheckMainLevel() ) then
			player.free_counter1 = player.free_counter1 + 1;
			printf("We receive Experience Orb error!.");
			ErrorResiveMail();
		-- Check received tier items
		elseif( not FindVariantSendManaStones() and 8 > CheckTierItems() ) then
			player.free_counter1 = player.free_counter1 + 1;
			printf("We receive Tier Items error!.");
			ErrorResiveMail();
		-- Check received fusion stones
		elseif( not FindVariantSendManaStones() and 8 > (inventory:itemTotalCount(202999) + inventory:itemTotalCount(203001)) and 15840 > Cur_Gold ) then
			player.free_counter1 = player.free_counter1 + 1;
			printf("We receive fusion stones or GOLD error!.");
			ErrorResiveMail();
		-- All Ok.
		else
			if( 10 > CheckMainLevel() ) then
				-- Use Experience Orb.
				inventory:useItem(203276); yrest(1000);
			end
			--[[
			-- Tp to Coast of Opportunity
			RoMScript("CastSpellByName(TEXT('Sys540193_name'));");		-- Tp to Heffner Camp
			print("		Tp to Coast of Opportunity");
			waitForLoadingScreen(60);
			player:update();
			if ( getZoneId() ~= 13 ) then error("\a\aYou are too far from Coast of Opportunity.");end
			--]]
			-- Take Giftbags
			local starttimer = os.clock()
			repeat
				if( inventory:itemTotalCount(201843) ) then
					inventory:useItem(201843); yrest(2500);					-- 1 Lvl Giftbag
				end
				inventory:useItem(201844); yrest(2500);						-- 2 Lvl Giftbag
				player:rest(math.random(5));
				inventory:update();
				player:mount();
				player:update();
			until player.Mounted or os.clock() - starttimer > 30
			-- Random Waypoint
			if( getZoneId() == 12 ) then
				local WPLtag = {"Esc1","Esc2","Esc3","Esc4"}
				local WPLtag = WPLtag[math.random(3)]
				cprintf(cli.white, "WPL tag:        %s\n", WPLtag)
				__WPL:setWaypointIndex(__WPL:findWaypointTag(WPLtag))
			end
		end
		repeat RoMScript("MailFrame:Hide()") until not RoMScript ("MailFrame:IsVisible()")
		RoMScript("CloseWindows();"); RoMScript("BagFrame:Hide();");
	end;

	function ElfCheckError()
		-- Move to first WP if not receive 10 Level, Tier Items or Mana stones.
		player:update(); inventory:update();
		local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		if( ErrorSendStone ~= true ) then
			if( 10 > player.Level ) or ( not FindVariantSendManaStones() and ( 8 > inventory:itemTotalCount(202999) or 8 > inventory:itemTotalCount(203001) or 15840 > Cur_Gold ) and 8 > CheckTierItems() ) then
				__WPL:setWaypointIndex(__WPL:findWaypointTag("Rove"));
			end
		end;
		player:mount();
	end;

	function TptoVaranas()
		-- Check for Sidklaw Error
		local Sidklaw = player:findNearestNameOrId(112797)
		if( not Sidklaw or Sidklaw.Y - player.Y > 50 ) then  TirodelUnstick(true) end
		player:target_NPC(112797);								-- Сидкло
		RoMScript("ChoiceOption(1);");
		waitForLoadingScreen(30);
		player:update();
		if distance(player.X,player.Z,4406,-3621) > 100 then TirodelUnstick() end;
	end;

	-- Tier Maker Mailbox
	function TierMakerMailbox(location)
		-- Check for location Mailbox Error
		if( location == "ElvenIsland" ) then
			-- Check for ELF Mailbox Error
			local Mailbox = player:findNearestNameOrId(112778);
			if( not Mailbox or Mailbox.Y - player.Y > 50 ) then TirodelUnstick() end;
		elseif( location == "Varanas" ) then
			-- Check for Error Send Stone
			if( ErrorSendStone == true ) then
				-- Wait for Login next toon -->
				LoginNextChar()
				loadPaths(__WPL.FileName)
			end
			-- Check for Varanas Mailbox Error
			local Mailbox = player:findNearestNameOrId(110538);
			if( not Mailbox or Mailbox.Y - player.Y > 50 ) then TirodelUnstick() end;
		end
		-- Check for MagicBox Error
		if RoMScript("AdvancedMagicBoxFrame == nil") and RoMScript("MagicBoxFrame == nil") then
			cprintf(cli.lightred, "Time: " ..os.date().. " MagicBoxFrame == nil\n")
			TirodelUnstick()
		end;
		-- Error if not receive Fusion Stone
		repeat MBEnergy = RoMScript("GetMagicBoxEnergy()"); yrest(500) until MBEnergy
		if( MBEnergy > 0 and not FindVariantSendManaStones() and ( 8 > CheckTierItems() or 8 > (inventory:getItemCount(202999) + inventory:getItemCount(203001)) ) )then
			if( location == "ElvenIsland" ) then
				-- Random Waypoint
				inventory:update(); player:mount();
				WpIndex= {"Esc1","Esc2","Esc3","Esc4"}
				__WPL:setWaypointIndex(__WPL:findWaypointTag(WpIndex[math.random(3)]));
			else
				TirodelUnstick()
			end
		else
			-- Open Mailbox
			if ( inventory:itemTotalCount(0) > 16 ) then
				player:target_Object({110538,110771,112113,112778},1500);			-- Почтовый ящик
				RoMScript("ChoiceOption(1);"); yrest(1000);
				UMM_DeleteEmptyMail();
				UMM_TakeMail();
				RoMScript("CloseWindows()");
			end

			-- Make Mana Stones -->
			retry_count = 0
			repeat MBEnergy = RoMScript("GetMagicBoxEnergy()"); yrest(500) until MBEnergy
			while( MBEnergy > 0 and 7 > retry_count ) do 
				-- Open dialogs
				if RoMScript("AdvancedMagicBoxFrame ~= nil") then
					RoMScript("AdvancedMagicBoxFrame:Show()"); yrest(2000)
				else
					RoMScript("MagicBoxFrame:Show()"); yrest(2000)
				end
				RoMScript("FusionFrame:Show()"); yrest(2000)
				-- check version of Fusion
				if RoMScript("FusionFrame1 ~= nil") then
					-- Config Save
					RoMScript("FusionConfig_OnShow()"); yrest(2000)
					RoMScript("FusionConfigFrame_ItemlistEditBox:SetText(TEXT('Sys227502_name'))"); yrest(2000)	-- Превосходный пояс
					RoMScript("FusionConfig_Save()"); yrest(2000)
					-- Set number to make
					RoMScript("FusionFrameFusionNumberEditBoxFusionAndItem:SetText('8')"); yrest(2000)
					RoMScript("FusionFrameFusionNumberEditBox5:SetText('2')"); yrest(2000)
					-- Do
					RoMScript("Fusion_QueueManastones(FusionFrame_Do)");
					repeat yrest(2000) until RoMScript("Fusion.LastGrad")==0 or RoMScript("MagicBoxFrame:IsVisible()")==false
					-- EmptyMagicBox
					RoMScript("PickupBagItem(51);"); yrest(500);
					RoMScript("PickupBagItem(Fusion_SearchEmptyBagslot(1));"); yrest(500);
					RoMScript("PickupBagItem(52);"); yrest(500);
					RoMScript("PickupBagItem(Fusion_SearchEmptyBagslot(2));"); yrest(500);
					RoMScript("PickupBagItem(53);"); yrest(500);
					RoMScript("PickupBagItem(Fusion_SearchEmptyBagslot(3));"); yrest(500);
				else
					-- on Fusion v2.0 and newer
					RoMScript("Fusion:Config_OnShow()"); yrest(500)
					RoMScript("FusionConfigFrame_FusionStones:SetChecked(" .. tostring(true) .. ")"); --yrest(500)
					RoMScript("FusionConfigFrame_UseItemlist:SetChecked(" .. tostring(false) .. ")"); --yrest(500)
					RoMScript("FusionConfigFrame_Green:SetChecked(" .. tostring(true) .. ")"); --yrest(500)
					RoMScript("FusionConfigFrame_Blue:SetChecked(" .. tostring(true) .. ")"); --yrest(500)
					RoMScript("FusionFrame_Number6EditBox:SetNumber(10)"); --yrest(500)
					RoMScript("FusionFrame_Number7EditBox:SetNumber(10)"); --yrest(500)
					RoMScript("FusionFrame_Number8EditBox:SetNumber(10)"); --yrest(500)
					RoMScript("FusionFrame_Number9EditBox:SetNumber(10)"); --yrest(500)
					RoMScript("FusionFrame_Number10EditBox:SetNumber(10)"); --yrest(500)
					RoMScript("Fusion:Config_Save()"); yrest(500)
					-- Do
					RoMScript("Fusion:Do_OnClick(FusionFrame_Do)");
					repeat
						yrest(1500)
					until RoMScript("Fusion.DoQueue") ~= true and RoMScript("Fusion.EmptyMagicBox") ~= true
				end
				-- close
				yrest(2000)
				if RoMScript("AdvancedMagicBoxFrame ~= nil") then
					RoMScript("AdvancedMagicBoxFrame:Hide()"); yrest(2000)
				else
					RoMScript("MagicBoxFrame:Hide()"); yrest(2000)
				end
				inventory:update(); player:update();
				repeat MBEnergy = RoMScript("GetMagicBoxEnergy()"); yrest(500) until MBEnergy
				retry_count = retry_count + 1;
			end

			-- Error if not receive Mana Stones
			repeat MBEnergy = RoMScript("GetMagicBoxEnergy()"); yrest(500) until MBEnergy
			if( MBEnergy > 0 ) then
				--RestartAfterAllError = false;
				error("\a\a\aWe didn't receive Mana Stones.");
			end

			-- Open Mailbox and Send Mana Stone, Fusion Stones, Gold and 2 stat Mana Stone
			local retry_count = 0;
			while( 5 > retry_count and CheckCountTierItems() > 0 ) do
				-- Open Mailbox
				if( inventory:itemTotalCount(0) > 8 ) then
					player:target_Object({110538,110771,112113,112778},1500);			-- Почтовый ящик
					RoMScript("ChoiceOption(1);"); yrest(1000);
					UMM_DeleteEmptyMail();
					UMM_TakeMail();
					RoMScript("CloseWindows()");
				end
				-- Send 2 stat Mana Stone.
				if( BuyFusionStoneWithStat ) then
					Send2StatManaStones()
				end
				-- Open Mailbox
				retry_count = retry_count + 1;
				TierReceiver1 = TierReceiver[math.random(2,5)]
				cprintf(cli.lightred, "Time: " ..os.date().. " Char name: " ..TierReceiver1.. "\n")
				local start = os.clock()
				player:target_Object({110538,110771,112113,112778},1500);				-- Почтовый ящик
				RoMScript("ChoiceOption(1);"); yrest(1000);
				-- Send Mana Stone and Gold
				UMM_SendAdvanced(TierReceiver1, ManaStones1, nil, nil, nil, nil,3);		-- Камни маны ур. 4, ур. 5, ур. 6
				UMM_SendAdvanced(TierReceiver[6], ManaStones2, nil, nil, nil, nil,3);	-- Камни маны ур. 7, ур. 8, ур. 9
				UMM_SendAdvanced(TierReceiver[1], ManaStones3, nil, nil, nil, nil,3);	-- Камни маны ур. 10, ур. 11, ур. 12
				UMM_SendByNameOrId(MailRecipient, StonesOrbs);							-- Камни соединения и Шар опыта: 10 000 очков
				UMM_SendByFusedTierLevel(MailRecipient, 4);								-- Шмотоки для тира
				if RoMScript("GetPlayerMoney('copper');") > 1890 then
					UMM_SendMoney(MailRecipient, "All");
				end
				if inventory:getItemCount(203001) > 0 then
					Send2StatFusionStones()												-- Двухстатные Камни соединения
				end
				RoMScript("CloseWindows()");
				inventory:update();
				if getLastWarning(MailSenderCanotDoItString, os.clock()-start) then
					local client = TierTwinkClient;
					local account = RoMScript("LogID");
					local character = RoMScript("CHARACTER_SELECT.selectedIndex");
					print("killClient ...")
					killClient()
					print("startClient: "..client..", "..account..", "..character)
					login(character, account, client)
				end
			end

			-- Error if not Send Random Fusion and Mana Stone. T4, T5, T6, T7, T8, T9 or T10 Stone
			if( CheckCountTierItems() > 0 ) then
				if( location == "ElvenIsland" ) then
					ErrorSendStone = true
					inventory:update(); player:mount();
					-- Random Waypoint
					if( getZoneId() == 12 ) then
						local WPLtag = {"Esc1","Esc2","Esc3","Esc4"}
						local WPLtag = WPLtag[math.random(3)]
						cprintf(cli.white, "WPL tag:        %s\n", WPLtag)
						__WPL:setWaypointIndex(__WPL:findWaypointTag(WPLtag))
					end
				else
					RestartAfterAllError = false;
					error("\a\a\a\a\a\a\aWe didn't Send Mana Stones or TierItems.");
				end
			else
				-- Twink Report
				Account = RoMScript("GetAccountName();");
				Cur_Gold = RoMScript("GetPlayerMoney('copper');");
				repeat MBEnergy = RoMScript("GetMagicBoxEnergy()"); yrest(500) until MBEnergy
				if( TierReceiver1 ~= nil )then
					cprintf(cli.white, player.Name.."_"..Account.." Bot sended Mana Stone: "..TierReceiver1.."\n");
				else
					cprintf(cli.white, player.Name.."_"..Account.." Same Error! Bot haven't Mana Stone!\n");
				end
				cprintf(cli.white, "Twink Gold:                %s\n", Cur_Gold)
				cprintf(cli.white, "Twink Tier Items:          %s\n", CheckTierItems())
				cprintf(cli.white, "Twink Fusion Stone:        %s\n", inventory:itemTotalCount(203001))
				cprintf(cli.white, "Twink T4 Mana Stone:       %s\n", inventory:itemTotalCount(202843))
				cprintf(cli.white, "Twink T5 Mana Stone:       %s\n", inventory:itemTotalCount(202844))
				cprintf(cli.white, "Twink T6 Mana Stone:       %s\n", inventory:itemTotalCount(202845))
				cprintf(cli.white, "Twink MagicBoxEnergy:      %s\n", MBEnergy)
				cprintf(cli.white, "Twink Excellent Belt:      %s\n", inventory:itemTotalCount(227502))
				cprintf(cli.white, "Twink Experience Orb:      %s\n", inventory:itemTotalCount(203276))
				cprintf(cli.white, "Twink Random Fusion Stone: %s\n", inventory:itemTotalCount(202999))
				cprintf(cli.white, "Check Count Tier Items:    %s\n", CheckCountTierItems())

			-- Wait for Login next toon
				repeat RoMScript("MailFrame:Hide()") until not RoMScript("MailFrame:IsVisible()")
				sendMacro("}LogoutCharacterDelete=true;a={");
				RestartAfterAllError = false;
				LoginNextChar()
				loadPaths(__WPL.FileName)
			end
		end
	end;


--== 7 ==--
---==== Auto Fusion Stone Sender functions ====---
--== Varanas ==--

	-- Mass Buy Fusion Stones
	function MassBuyFusionStones()
		local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		if( (BuyFusionStoneWithStat and 45144 > Cur_Gold) or (BuyFusionStoneWithStat == false and 15840 > Cur_Gold) ) then
			printf("\a\a\a\a\a\a\a Error. GOLD WARNING!");
		end;

		-- Buy Fusion Stones
		player:openStore(110576); yrest(500);							-- Оделия Проул
		if( BuyFusionStoneWithStat == false and Cur_Gold >= 1980 )then
			store:buyItem(202999, inventory:getItemCount(0));			-- Случайный камень соединения
		elseif( BuyFusionStoneWithStat and Cur_Gold >= 5643 )then
			store:buyItem(203001, inventory:getItemCount(0));			-- Камень соединения с Выностливость и двумя произвольными
		end;
		RoMScript("CloseWindows()"); inventory:update();

		-- Error if not receive Fusion Stone or Random Fusion Stone
		local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		if( (BuyFusionStoneWithStat == false and 8 > inventory:getItemCount(202999) and Cur_Gold >= 1980)
			or (BuyFusionStoneWithStat and 8 > inventory:getItemCount(203001) and Cur_Gold >= 5643))then    
			__WPL:setWaypointIndex(__WPL:findWaypointTag("MassBuyFusionStones"));
		else
			-- same code
		end;
	end;

	-- To Guild House
	function ToGuildHouse()
		player:target_NPC(111621); yrest(500);							-- Управляющий замками гильдий
		ChoiceOptionByName(getTEXT("SC_GUILDHOUSE_01")); yrest(500);	-- 'Я хочю войти в замок гильдии.'
		waitForLoadingScreen(10);
		player:update();
		__WPL:setWaypointIndex(__WPL:getNearestWaypoint(player.X, player.Z));
	end;

	-- Guild Fortress Gate
	function GuildFortressGate()
		-- Check Main Fortress Gate
		local success = player:moveTo(CWaypoint(-22,93),true);
		if success == false then
			player:moveTo(CWaypoint(-14,-125),true);
			player:target_Object(111577);								-- Main Fortress Gate
			yrest(3000);
		end
	end;

	-- Guild Fortress Mailbox
	function GuildFortressMailbox()
		local function CheckBotsendedFusionStone(_check)
			if _check  then
				BotsendedFusionStone = BotsendedFusionStone + (inventory:getItemCount(0) - PresendedItems)
				PresendedItems = 0
			else
				PresendedItems = inventory:getItemCount(0)
			end
		end
		-- Open Mailbox and take mails
		if ( inventory:itemTotalCount(0) > 16 ) then
			player:target_Object(113043,1000);								-- Почтовый ящик гильдии
			RoMScript("ChoiceOption(1);"); yrest(1000);
			UMM_DeleteEmptyMail();
			UMM_TakeMail(); yrest(1000);
			RoMScript("CloseWindows()"); yrest(500);
		end
		-- Open Mailbox and Send Fusion Stone with too stats
		local retry_count = 0;
		local start = os.clock()
		while( inventory:getItemCount(203001) > 0 and 3 > retry_count ) do
			retry_count = retry_count + 1;
			-- Open Mailbox
			player:target_Object(113043); yrest(500);						-- Почтовый ящик гильдии
			RoMScript("ChoiceOption(1);"); yrest(1000);
			-- Send Fusion Stones
			UMM_SendByStats(TierReceiver[1], 203001, StatsTables0)			-- Одностатные Камни соединения
			Send2StatFusionStones()											-- Двухстатные Камни соединения
			if( not RoMScript("MailFrame:IsVisible()") ) then
				player:target_Object(113043); yrest(500);					-- Почтовый ящик гильдии
				ChoiceOptionByName(getTEXT("SO_OPENMAIL")); yrest(500);		-- 'Открыть почтовый ящик'
			end
			CheckBotsendedFusionStone()
			UMM_SendByStats(MailSender1, 203001, 510360, 3)				-- Трехстатные Камни соединения
			RoMScript("CloseWindows()");
			inventory:update();
			if getLastWarning(RecipientMailFullString, os.clock()-start) then break end
		end
		-- Send Random Fusion Stone
		if( not RoMScript("MailFrame:IsVisible()") ) then
			player:target_Object(113043); yrest(500);						-- Почтовый ящик гильдии
			ChoiceOptionByName(getTEXT("SO_OPENMAIL")); yrest(500);			-- 'Открыть почтовый ящик'
		end
		if( inventory:getItemCount(202999) >= 8 ) then
			UMM_SendByNameOrId(MailSender1, 202999); yrest(500);			-- Случайный камень соединения
		end
		CheckBotsendedFusionStone(true)
		UMM_SendByFusedTierLevel(MailSender1, 4);							-- шмотоки для тира
		local Cur_Gold = RoMScript("GetPlayerMoney('copper');");
		printf("Sended Fusion Stones: %s, Cur_Gold: %s.\n", BotsendedFusionStone, Cur_Gold);
		-- Open Mailbox and take mails
		if ( inventory:itemTotalCount(0) > 16 ) then
			player:target_Object(113043,1000);								-- Почтовый ящик гильдии
			RoMScript("ChoiceOption(1);"); yrest(1000);
			UMM_DeleteEmptyMail();
			UMM_TakeMail(); yrest(1000);
			RoMScript("CloseWindows()"); yrest(500);
		end
		-- exit from guild
		local timer = os.clock()
		repeat
			RoMScript("CloseWindows()"); yrest(500);
			player:target_NPC(112588); yrest(500);							-- Горничная замка гильдии
		until RoMScript("SpeakFrame:IsVisible()") or (os.clock() - timer) > 60
		local timer = os.clock();
		repeat
			ChoiceOptionByName(getTEXT("SC_GUILDGIRL_P1_03"));				-- 'Я хочю покинуть замок гильдии'
			yrest(1000);
		until RoMScript("StaticPopup1:IsVisible()") or (os.clock() - timer) > 60
		AcceptPopup(StaticPopup1, 1);
		waitForLoadingScreen(10);
		-- check for error
		if getLastWarning(RecipientMailFullString, os.clock()-start)
			or 145144 > Cur_Gold or BotsendedFusionStone >= 210 then
			printf("Relog to MailSender1.\n");
			RoMScript("CloseWindows()");
			BotsendedFusionStone = 0
			-- relog to MailSender1
			--ChangeChar(CharList[1][1].chars[1], CharList[1][1].account);
			--loadPaths(__WPL.FileName)
			yrest(600000);
		end
	end;


--== 8 ==--
---==== Auto Mana Stone Sender functions ====---
--== Logar ==--

	-- ManaStonesLogarMailbox
	function ManaStonesLogarMailbox()
		repeat
			-- Open Mailbox
			player:target_Object({110538,110771,112113,112778},1500);				-- Логарский почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
			UMM_DeleteEmptyMail();
			if( inventory:itemTotalCount(0) >= 10 ) then
				UMM_TakeMail (); yrest(4000);
			end;
			RoMScript("CloseWindows()"); yrest(500); inventory:update();
			BagSpace1 = inventory:itemTotalCount(0);

			-- Send Mail
			SendManaStones();
			BagSpace2 = inventory:itemTotalCount(0) + 1

			-- Open Mailbox
			player:target_Object({110538,110771,112113,112778},1500);				-- Логарский почтовый ящик
			RoMScript("ChoiceOption(1);"); yrest(1500);
			UMM_DeleteEmptyMail();
			if( inventory:itemTotalCount(0) >= 6 ) then
				UMM_TakeMail (); yrest(4000);
			end;
			RoMScript("CloseWindows()"); yrest(500); inventory:update();

			-- Player ReLogin for mail unblock
			if( BotSendedMail >= 50 or BotSendedMail - 1 > (BagSpace2-BagSpace1) ) then
				cprintf(cli.white, player.Name.." BotSendedMail: %s BagSpaceDif: %s\n", BotSendedMail, BagSpace2-BagSpace1)
				cprintf(cli.white, player.Name.." ReLogin for mail unblock.\n")
				player:updateBuffs();
				if ( not player:hasBuff(506959) ) then
					--cprintf(cli.white, "You are havnt Premium!\n")
					ChangeChar("current");
					player = CPlayer.new();
					EventMonitorStart("MSGWHISPER", "CHAT_MSG_WHISPER");
				else
					repeat
						inventory:useItem(208456); yrest(1000);
						sendMacro("SpeakFrame_ListDialogOption(1, 3)")
						waitForLoadingScreen(30);
						player:update();
					until getZoneId() == 400
					repeat
						player:target_NPC(110758); yrest(1000);
						sendMacro("SpeakFrame_ListDialogOption(1, 1)");
						waitForLoadingScreen(30);
						player:update();
					until getZoneId() ~= 400
				end
				BotSendedMail = 0
			end;

			-- Check Mana Stones
			local Grad = CheckManaStones()

			-- Report
			cprintf(cli.white, player.Name.." Mana Stones T4: %s\n", Grad[1])
			cprintf(cli.white, player.Name.." Mana Stones T5: %s\n", Grad[2])
			cprintf(cli.white, player.Name.." Mana Stones T6: %s\n", Grad[3])
			cprintf(cli.white, player.Name.." Mana Stones T7: %s\n", Grad[4])
			cprintf(cli.white, player.Name.." Mana Stones T8: %s\n", Grad[5])
			cprintf(cli.white, player.Name.." Mana Stones T9: %s\n", Grad[6])
			cprintf(cli.white, player.Name.." Mana StonesT10: %s\n", Grad[7])
			cprintf(cli.white, player.Name.." Experience Orb: %s\n", inventory:itemTotalCount(203276))
			cprintf(cli.white, player.Name.." BotSendedMail:  %s\n", BotSendedMail)
			cprintf(cli.white, player.Name.." Bag Space:      %s\n", inventory:itemTotalCount(0))
				
			-- Check Amount of Experience Orb
			if( 1 > inventory:itemTotalCount(203276) ) then					-- Amount of Experience Orb
				if( player.Name ~= LastManaStoneSender ) then
					cprintf(cli.white, player.Name.." LoginNextToon.\n")
					-- Wait for Login next toon
					RestartAfterAllError = false;
					LoginNextChar()
					loadPaths(__WPL.FileName)
					return
				else
					RestartAfterAllError = false;
					error("\a\a\aError. Not enough Experience Orb.");
				end
			end;

			-- Check Mana Stones
			if not FindVariantSendManaStones() then									-- Find Variant for Send Mana Stones
				if( player.Name ~= LastManaStoneSender ) then
					cprintf(cli.white, player.Name.." LoginNextToon.\n")
					-- Wait for Login next toon
					LoginNextChar()
					loadPaths(__WPL.FileName)
					return
				else
					--RestartAfterAllError = false;
					--error("\a\a\aError. Final. Not enough Mana Stones.");
					-- relog to MailSender1
					ChangeChar(CharList[1][1].chars[1], CharList[1][1].account);
					loadPaths(__WPL.FileName)
					return
				end
			end
		until false
	end;

