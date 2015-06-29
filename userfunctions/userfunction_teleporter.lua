	-----------------------------------------------------------
	------------ MiesterMan's Teleporter Functions ------------
	------------------- Version 1.4 ---------------------------
	-----------------------------------------------------------

local playerAddress = addresses.staticbase_char;
local charZoneID_offset = 0x6FE; -- I only checked the character
local charZoneID = 0;

local serverName_ptr = 0xA199C0; -- Server Name pointer, text
local serverName_offset = 0x18;
local serverName = "";

-- Debug setting
local DEBUGUFZ = true;

ufZone = {}; -- Make accessible from outside the file (fear of making globals)

-- HP Threshold is the median between your HP in instance gear and
-- pvp gear.  PvP is enabled by default below, if you play on PVE and
-- don't have to worry about guild challenges, just disable it.
ufZone.hpThreshold = 15000;

-- PvP drop prevention
local pvpServer = true;


-- Update ZoneID
function updateZoneID()
	charZoneID = memoryReadShortPtr(getProc(),playerAddress,charZoneID_offset);
	return;
end

-- Returns the ZoneID
function getZoneID()
	updateZoneID();
	return charZoneID;
end

-- Update Server Name
function updateServerName()
	serverName = memoryReadStringPtr(getProc(),serverName_ptr,serverName_offset);
	return;
end

-- Returns the Server Name
function getServer()
	updateServerName();
	return serverName;
end

-- This function will swap gear sets before leaving party to 
-- exit an instance. Then it wait until you're close to the
-- coords listed in _X, _Z before continuing the script.
function partyQuitExit(_X,_Z)
	if DEBUGUFZ then printf("DEBUG:  X-%s\tZ-%s\n",tostring(_X),tostring(_Z)); end;

	-- Regular practice on PvP servers, would lose tons of money without it
	if pvpServer then
		repeat
			player:update();
			yrest(500);
			if player.MaxHP > hpThreshold then
				RoMScript("SwapEquipmentItem();");
			end
			yrest(2000);
			player:update();
			yrest(500);
		until hpThreshold > player.MaxHP;
	end
	
	-- Ditch party and wait till we're at the res point
	-- NOTE: If you are in a place that has a res point glitch, use zoneCheck instead
	RoMScript("LeaveParty();");
	isTeleport(_X,_Z);
	player:rest(2);
	return true;
end

-- Accepts: Coords, Zone ID, "next", "file: <path filename>" and if
-- needed a teleporter's name and the ChoiceOption on their menu.
-- Then waits till you are close to the coords to continue.
-- Note:  Zone ID can be Zone ID number, "house", "guild" or "any" (anywhere but house or guild)
function isTeleport(_X,_Z,_teleporter,_option)

	-- No random globals, please
	if not _option then local _option;end
	if not _teleporter then local _teleporter;end
	if not _Z then local _Z; end
	
	-- If nothing specified, check for next waypoint
	if not _X then local _X = "next";end;
	
	-- So the special Zone keywords can pass the "next" check
	if type(_X) == "string" then  
		_X = _X:lower();
		if _X == "house" then _X = 1234567;end;
		if _X == "guild" then _X = 2234567;end;
		if _X == "any" then _X = 3234567;end;
	end
	
	-- Fill in the blanks if we skip _Z and go straight to teleporter name
	if _Z and type(_Z) == "string" then 
		if _teleporter then _option = _teleporter; end
		_teleporter = _Z;
		_Z = false;
	end
	
	-- Use next waypoint or first waypoint of specified file
	if type(_X) == "string" then
		
		-- Remove spaces
		_X = _X:gsub("%s","");
		
		-- Initializing destination variable
		local nextWaypoint = __WPL.CurrentWaypoint
		-- if _X == "next" then
			-- nextWaypoint = nextWaypoint + 1;
		-- end
		
		-- We can load files too!
		if _X:find("file:") then
			loadPaths(_X:gsub("file:",""));
			__WPL.setWaypointIndex(1);
			nextWaypoint = 1;
			_X = "next"
		end
		
		-- If the string is not 'next' yet, it's not a valid argument
		if not (_X == "next") then
			error("\nisTeleport(_X,_Z,_teleporter,_option) - Unrecognized string argument.\nMake sure the string is either \"next\" or \"file: <path filename>\"");
			return false;
		end
		
		-- Finally, setting the next waypoint
		_X = __WPL.Waypoints[nextWaypoint].X;
		_Z = __WPL.Waypoints[nextWaypoint].Z;
	end
	
	-- Moved to a function to make sure changes are to both cases
	local function _useTeleporter()
		if _teleporter then
			if not _option then _option = 1;end;
			player:target_NPC(_teleporter);
			yrest(500);
			RoMScript("ChoiceOption(" .. _option .. ");");
			yrest(200);
			RoMScript("StaticPopup_EnterPressed(StaticPopup1);StaticPopup1:Hide();");
		end
		waitForLoadingScreen(3);
		player:update();
		yrest(500);
	end

	-- Re-valueing these arguments
	if _X == 1234567 then _X = "house";end;
	if _X == 2234567 then _X = "guild";end;
	if _X == 3234567 then _X = "any";end;
	
	if DEBUGUFZ then printf("DEBUG:  X-%s\tZ-%s\tTP-%s\tOP-%s\n",tostring(_X),tostring(_Z),tostring(_teleporter),tostring(_option)); end;

	-- Use NPC + Menu if needed then wait till we're in the right place (repeat as necessary)
	if _X and not _Z then
		repeat
			_useTeleporter();
		until checkZone(_X);
	else
		repeat
			_useTeleporter();
		until 200 > distance(player.X,player.Z,_X,_Z);
	end
	return true;
end

-- This function will return true if in the indicated zone, false otherwise.
-- Accepts: Zone ID (number), "guild", "house", or "any" (anywhere but guild or house)
function checkZone(_zoneID)
	if DEBUGUFZ then printf("DEBUG:  Zone ID - %s\n",tostring(_zoneID)); end;
	if type(_zoneID) == "string" then
		_zoneID = _zoneID:lower()
		if _zoneID == "any" then			-- Anything but house or guild
			if getZoneID() ~= 400 and getZoneID() ~= 401 then
				return true;
			else
				print("Still in house or guild, try again.");
				return false;
			end
		elseif _zoneID == "guild" then		-- Check for guild
			if getZoneID() == 401 then
				return true;
			else
				print("Wrong Zone ID detected (not in guild castle), try again.");
				return false;
			end
		elseif _zoneID == "house" then		-- Check for house
			if getZoneID() == 400 then
				return true;
			else
				print("Wrong Zone ID detected (not in house), try again.");
				return false;
			end
		else
			error("\nERROR:  checkZone(_zoneID) requires a number, \"Any\", \"Guild\", or \"House\"!\nERROR:  Please check the arguments being used.\n")
		end
	elseif type(_zoneID) == "number" then			-- Check for zone ID number
		if 	getZoneID() == _zoneID then
			return true;
		else
			print("Wrong Zone ID detected, try again.\nNOTE:  Remember, channel affects the Zone ID.");
			return false;
		end
	else
		error("\nERROR:  checkZone(_zoneID) requires a number, \"Any\", \"Guild\", or \"House\"!\nERROR:  Please check the arguments being used.\n");
	end
end

-- This function will enter different house than the one
-- owned by the character.
function visitHouseEnter(housemaid,_housename,housepass)
	if DEBUGUFZ then printf("DEBUG:  Housemaid - %s\tHouse Name - %s\t House Password - %s\n",tostring(housemaid),tostring(_housename),tostring(housepass)); end;
	-- Our defaults and missing argument errors
	if not housemaid then housemaid = "Meydo"; end;
	if not _housename then error("\nERROR:  visitHouseEnter(housemaid,_housename,housepass) missing _housename.");end
	if not housepass then housepass = "";end;
	_housename = tostring(_housename); -- In case they're numbers
	housepass = tostring(housepass); -- ...
	
	-- Entering the visit house using the information provided
	repeat
		-- Open housemaid dialog
		player:target_NPC(housemaid);
		ChoiceOptionByName(getTEXT("SO_VISITHOME")) yrest(2000) -- 'Ich möchte zum Haus eines anderen Spielers.'
		--RoMScript("ChoiceOption(4);");yrest(2000);
		
		-- Enter _housename
		local tmpIterator = 1;
		local testChar = _housename:sub(tmpIterator,tmpIterator);
		while testChar:find("%w") do
			if ( (testChar >= "a" and "z" >= testChar) or (testChar >= "0" and "9" >= testChar) ) then
				keyboardPress(key["VK_"..testChar:upper()]);
			elseif (testChar >= "A" and "Z" >= testChar) then
				keyboardPress(key["VK_"..testChar],VK_SHIFT);
			end
			tmpIterator = tmpIterator + 1;
			testChar = _housename:sub(tmpIterator,tmpIterator);
		end	
		
		-- Enter password
		tmpIterator = 1;
		testChar = housepass:sub(tmpIterator,tmpIterator);
		keyboardPress(key.VK_TAB);
		while testChar:find("%w") do
			if ( (testChar >= "a" and "z" >= testChar) or (testChar >= "0" and "9" >= testChar) ) then
				keyboardPress(key["VK_"..testChar:upper()]);
			elseif (testChar >= "A" and "Z" >= testChar) then
				keyboardPress(key["VK_"..testChar],VK_SHIFT);
			end
			tmpIterator = tmpIterator + 1;
			testChar = housepass:sub(tmpIterator,tmpIterator);
		end
		
		-- Confirm and wait for entry
		keyboardPress(key.VK_ENTER);
		waitForLoadingScreen(5);
	until checkZone("house");
	player:update();
end

-- Will leave the visit house.
function visitHouseLeave(_zoneID)
	if DEBUGUFZ then printf("DEBUG:  Zone ID - %s\n",tostring(_zoneID)); end;

	if not _zoneID then _zoneID = "any";end;
	repeat
		player:target_NPC("Housekeeper");
		RoMScript("SpeakFrame_ListDialogOption(1, 1)");
		waitForLoadingScreen(5);
	until checkZone(_zoneID);
	player:update();
end

-- Will leave the character's house.
function houseLeave(_zoneID)
	if DEBUGUFZ then printf("DEBUG:  Zone ID - %s\n",tostring(_zoneID)); end;

	if not _zoneID then _zoneID = "any";end;
	repeat
		player:target_NPC("Housekeeper");
		RoMScript("SpeakFrame_ListDialogOption(1, 6)");
		waitForLoadingScreen(5);
	until checkZone(_zoneID);
	player:update();
end

-- Will enter the character's house.
function houseEnter(housemaid)
	if DEBUGUFZ then printf("DEBUG:  Housemaid - %s\n",tostring(housemaid)); end;

	if not housemaid then housemaid = "Meydo";end;
	cprintf(cli.yellow,"Entering House through %s\n", tostring(housemaid));
	repeat
		player:target_NPC(housemaid);
		RoMScript("ChoiceOption(1);");
		waitForLoadingScreen(5);
	until checkZone("house");
	player:update();
end

-- Will enter the character's guild castle.
function guildCastleEnter()
	cprintf(cli.yellow,"Entering Guild Castle\n");
	repeat
		player:target_NPC("Guild Castle Manager");
		RoMScript("ChoiceOption(2);");
		waitForLoadingScreen(5);
	until checkZone("guild");
	player:update();
end

-- Will leave a guild castle.
function guildCastleLeave(_zoneID)
	if DEBUGUFZ then printf("DEBUG:  Zone ID - %s\n",tostring(_zoneID)); end;

	cprintf(cli.yellow,"Leaving Guild Castle\n");
	if not _zoneID then _zoneID = "any";end;
	repeat 
		player:moveTo(CWaypoint(-50,-500),true);
		player:moveTo(CWaypoint(-80,-560),true);yrest(1000);
		RoMScript("StaticPopup_EnterPressed(StaticPopup1);StaticPopup1:Hide();");
		waitForLoadingScreen(5);
	until checkZone(_zoneID);
	player:update();
end

-- Test function that helps you be confident with __WPL. commands!!!
function enumerateWaypoints()
	for i,v in pairs(__WPL.Waypoints) do 
		for j,z in pairs(v) do 
			printf("\n" .. tostring(i) .. "\t");
			printf(tostring(j) .. "\t" .. tostring(z) .. "\t");
		end; 
		printf("\n");
	end;
end
