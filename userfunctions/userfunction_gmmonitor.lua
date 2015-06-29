-- ver 7.5

--== Change this to another character you can use to test the userfunction, function will basically think it is a GM. ==--
local testcharname = "Charname" -- Must be exactly as the character's name, any capitals and any special letters.

--=== New feature ===--
-- this is for monitoring players who may be following you.
local ignoreplayertime = 30 
-- time in seconds when alarm will be sounded for a player "following" you

local clearplayertime = 60 
-- time in seconds for players to be removed from table

-- when the ignoreplayertime time is reached it will play the alarm sound
-- if you want your own code performed then create a function named beingfollowed() and that code will be done instead.


local gm_detected = false;
local last_gm_name = "";
local soundresource = nil;
local logg,gmreply,gmname,playerexists,_time,printtime,pause_start,time_remaining
local ResponseTable = {}
local valid_chars = {}
local wp = {}
local wp2 = {}

if( soundLoad ) then
	soundresource = soundLoad(getExecutionPath() .. "/alarm.wav");
	if( soundresource == nil ) then
		warning("Failed to load sound file \'alarm.wav\'");
	end
end

function messagereply()
-- You can write pretty much anything you want as the response 
-- but don't use any ' as it will mess with the code and just error out
	ResponseTable = {
		[1] = "Sorry, muss off",
		[2] = "sry babyalarm, muss off",
		[3] = "sry bin gerade am ausloggen, ciao",
	}
	gmreply = ResponseTable[math.random(#ResponseTable)]
	sendMacro("SendChatMessage(\'"..gmreply.."\', 'WHISPER', 0, \'"..gmname.."\');");
end

local valid_chars = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
	'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'Ä', 'ä', 'Ç', 'ç', 'Ü', 'ü', 'Ö', 'ö', 'ë', 'ÿ',  'ñ',
};

function valid_name(name)
	-- Checks to make sure only valid characters are in the name.
	for i = 1,#name do
		local char = string.sub(name, i, i);
		if( not table.contains(valid_chars, char) ) then
		printf("Had a detection but the characters dont match up, probably a bug, ignoring it.\n")
			return false;
		end
	end

	return true;
end

function GMdetection()
	
	local obj = nil;
	local objectList = CObjectList();
	objectList:update();

	gm_detected = false;
	for i = 0,objectList:size() do
		obj = objectList:getObject(i);
		if obj and obj.Type == PT_PLAYER and obj.Name ~= "<UNKNOWN>" then
			local pawn = CPawn(obj.Address);
			if pawn and pawn.Name ~= player.Name and pawn.InParty ~= true then  
				if ( pawn.Class1 == 0 or pawn.Class2 == 0 or pawn.Level >= 100 or pawn.Name == testcharname ) then
					if( valid_name(pawn.Name) ) then
						gm_detected = true;
						if( pawn.Name ~= last_gm_name ) then
							logMessage(sprintf("A Game Master (%s) has been detected near your character.", pawn.Name));
						end
						printf("GM detected! Name: %s, Class IDs: %d/%d\n", tostring(pawn.Name), pawn.Class1, pawn.Class2);
						if logg then logInfo(player.Name,"GM detected! Name: "..tostring(pawn.Name)..", class IDs: "..pawn.Class1.."/"..pawn.Class2,true,"GM") end
						break;
					end
					last_gm_name = pawn.Name
				else 
				--players
					if settings.profile.options.playerDETECT == true then
						for k,v in pairs(playertable) do
							if v.Name == obj.Name then --name in table already
								playerexists = true
							end
						end
						if playerexists ~= true then
							table.insert(playertable,{Name = pawn.Name, ptime = os.time(), alarmsounded = 0})
						else
							for k,v in pairs(playertable) do
								if v.Name == obj.Name and (os.time() - v.ptime >= ignoreplayertime) and 3 >= v.alarmsounded then -- someone is following us
									if logg then
										logInfo(player.Name,"Followed by "..obj.Name.." Class IDs: "..pawn.Class1.."/"..pawn.Class2,true,"GM")
									end
									print("Followed by "..obj.Name)
									if beingfollowed then
										beingfollowed(obj,v.alarmsounded)
									else
										if playalarm then 
											playalarm()
										else
											if( soundresource == nil ) then
												printf("\a\a\a");
											else
												if( soundGetState(soundresource) ~= "playing" ) then
													soundPlay(soundresource);
												end
											end
										end
									end	
									v.alarmsounded = v.alarmsounded + 1
								end	
							end
						end
						--=== clear out old names ===--
						for k,v in pairs(playertable) do
							if os.time() - v.ptime >= clearplayertime then
								table.remove(playertable,k)
							end
						end
					end
				end
			end
		end
	end

	if( gm_detected ) then
		if playalarm then 
			playalarm()
		else
			if( soundresource == nil ) then
				printf("\a\a\a");
			else
				RoMScript ("SYS_AudioSettings_MasterVolumeSlider:SetValue(100)")	yrest (200)
				RoMScript ("SYS_AudioSettings_InterfaceSFXVolumeSlider:SetValue(100)")	yrest (200)
				RoMScript ("SSF_AudioSettings_OnApply()") yrest (200)
				if( soundGetState(soundresource) ~= "playing" ) then
					soundPlay(soundresource);
				end
			end
		end
		if settings.profile.options.GMnearbylogout == true then
			 RoMScript("Logout();");
			error("Logging out because GM detected.")
		elseif gmnearby then
		gmnearby()
		end			
	else
		last_gm_name = "";
	end
	local friends = {"Hilfsbegleiter"}	
	repeat
	local time, moreToCome, name, msg = EventMonitorCheck("GMdetect", "4,1")
		if msg ~= nil and name ~= "Newbie Pet" then -- make sure something was returned
			for k,v in pairs(friends) do
				if name == v then return end
			end
			if logg then logInfo(player.Name,"Char name: " ..name.. " Message: " ..msg,true,"GM") end
			EventMonitorStart("GMdetect2", "CHAT_MSG_SYSTEM");
			local _ttime = RoMScript("GetTime()")
			if _ttime and time and 60 >= ( _ttime - time ) then
				sendMacro("AskPlayerInfo(\'"..name.."\');")
				yrest(1000)
				printf("\nYou have been whispered by: " ..name.. "\n")
				gmname = name			
				local time, moreToCome, msg = EventMonitorCheck("GMdetect2", "1")
				if msg ~= nil then
					if logg then logInfo(player.Name,"Char name: " ..name.. " Message: " ..msg,true,"GM") end
					if string.find(msg,"GM") or string.find(msg,"200") or string.find(msg,"Moderator") or string.find(msg,testcharname) then
						if playalarm then playalarm() playalarm() end
						if settings.profile.options.PAUSEONGM ~= 0 and settings.profile.options.PAUSEONGM ~= nil then
							keyboardRelease( settings.hotkeys.MOVE_FORWARD.key );
							_time = settings.profile.options.PAUSEONGM
							pause_start = os.time()
							printtime = os.time()
							printf("Pausing for ".._time.." seconds. Press "..getKeyName(settings.hotkeys.START_BOT.key).." to stop the pause.\n")
							repeat 
								if keypress ~= true then 
									keyboardRelease( settings.hotkeys.MOVE_FORWARD.key );
									keypress = true
								end
								player:update();
								time_remaining = (pause_start + _time - os.time())
								if (printed ~= true and (pause_start + 10) == os.time()) then 
									printf("Time remaining "..time_remaining.." seconds.\n") 
									printed = true
									printtime = os.time()
								end
								if printtime ~= nil then
									if (os.time() == printtime + 10) then 
									printf("Time remaining "..time_remaining.." seconds.\n") 
									printed = true
									printtime = os.time()
									end	
								end					
								if( player.Battling ) then          -- we get aggro,
									printf("We got aggro, skipping pause and logging out.\n")
									player:update();
									if settings.profile.options.RECALL == true then
										local cooldown, remaining = sendMacro("GetSkillCooldown(1,2);")
										if remaining > 1 then
											messagereply()
											yrest(1000)
											RoMScript("Logout();");
											error("Recall was on cooldown, so logged out in mob area.")	
										else
											player:update()
											local X = player.X
											local Z = player.Z
											repeat
												sendMacro("UseSkill(1,2);");
												yrest(1000)
												player:update()
											until memoryReadBytePtr(getProc(), addresses.loadingScreenPtr, addresses.loadingScreen_offset) ~= 0 or 
											distance(player.X, player.Z, X, Z) > 100 or 
											keyPressedLocal(settings.hotkeys.START_BOT.key)
										end
										if memoryReadBytePtr(getProc(), addresses.loadingScreenPtr, addresses.loadingScreen_offset) ~= 0 then waitForLoadingScreen() end
										messagereply()
										yrest(1000)
										RoMScript("Logout();");
										error("Logging out because GM whispered, used recall.")
									else
										messagereply()
										yrest(1000)
										RoMScript("Logout();");
										error("Logging out because GM whispered, used recall.")
									end
								end
							until os.time() == (pause_start + _time) or keyPressedLocal(settings.hotkeys.START_BOT.key)
							player:update()
							wp = __WPL:getNextWaypoint();
							_distance = distance(player.X, player.Z, player.Y, wp.X, wp.Z, wp.Y);
							--printf(_distance.."\n")
							if _distance > 50 then -- we have been ported elsewhere
								__WPL:setWaypointIndex(__WPL:getNearestWaypoint(player.X, player.Z, player.Y));
								player:update()
								wp2 = __WPL:getNextWaypoint();
								_distance2 = distance(player.X, player.Z, player.Y, wp2.X, wp2.Z, wp2.Y);			
								if _distance2 > 150 then			
									RoMScript("Logout();");
									if logg then logInfo(player.Name,"We were moved by a GM, WTF",true,"GM") end
									error("Logging out because we were moved by GM.")
								end
							end
							printf("reseting monitor\n")
							break
						else
							yrest(5000)
							messagereply()
							yrest(1000)
							RoMScript("Logout();");
							error("Logging out because GM whispered.")
						end
					end
				end
			end
		else break
		end
		if moreToCome == false then EventMonitorStop("GMdetect2") end
	until moreToCome == false
end

function startGMDetect()
	if logInfo then logg = true end
	playertable = {}
	if settings.profile.options.GMDETECT == true then
		unregisterTimer("GMdetection");
		printf("GM detection started\n");
		EventMonitorStart("GMdetect", "CHAT_MSG_WHISPER");
		registerTimer("GMdetection", secondsToTimer(5), GMdetection);
	end
end