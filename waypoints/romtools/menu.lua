
MENU_MAIN				= 'Main'
MENU_TRAVEL			= 'Travel'
MENU_CHARACTER	= 'Character'
MENU_WAYPOINTS	= 'Waypoints'

NAVI_RIGHT			= 'right'
NAVI_LEFT				= 'left'
NAVI_DOWN				= 'down'
NAVI_UP					= 'up'

-- Checks if the specified key or key combo is being pressed
function keyComboPressed(_key)
	if _key and keyPressedLocal(_key.key) then
		if _key.modifier == nil or keyPressedLocal(_key.modifier) then
			return true
		end
	end
end

-- Sets the dimensions of the console
function setupConsole (w, h)
	if setWindowPos and getWin then
		local gameX, gameY = windowRect (getWin ())
		if gameX == -32000 then -- If minimized
			gameX, gameY = 0,0
		end
		setWindowPos (getHwnd (), gameX + window_position_X, gameY + window_position_Y, nil, nil, true)
	end
	if setConsoleAttributes and getConsoleAttributes then
		local tmpW, tmpH, tmpX, tmpY = getConsoleAttributes ()
		if w > tmpX then
			setConsoleAttributes (tmpW, tmpH, w, tmpY)
		end
		yrest(100)
		setConsoleAttributes (w, h)
	end
end

--==================================--
--==  SHOW MENU										==--
--==================================--

local travelTargets 	= nil
local waypointFiles 	= nil
local activeTarget		= 1
local activeCharacter	= 1
local activeWaypoint	= 1

local function navigate (pos, max, step, key)
	if key==NAVI_RIGHT and math.fmod (pos-1, step)<step-1 and pos<max		then pos = pos + 1 end
	if key==NAVI_LEFT  and math.fmod (pos-1, step)>0 and pos>0					then pos = pos - 1 end
	if key==NAVI_DOWN  and pos<=max-step																then pos = pos + step end
	if key==NAVI_UP    and pos>step 																		then pos = pos - step end
	return pos
end

local function colorize (text, color)
	return string.format ('|%s|%s', color, text)
end

local function namekey (name, bool, value, len)
	if len==nil or tonumber(len)==nil then len = #name end
	if len > #name then
		name = name..string.rep (' ', len-#name)
	elseif #name > len then
		name = name:sub (0, len-3)..'...' 
	end
	if value then
		name	= colorize (name, 'yellow')
		value = colorize (value, ((bool and 'lightgreen') or 'lightred'))
	else
		name	= colorize (name, ((bool and 'lightgreen') or 'lightred'))
	end
	if value then
		return string.format('%s:%s ', name, value)
	else
		return string.format('%s ', name)
	end
end

function showMain (menu)
	if menu == MENU_MAIN then
		cprintf_ex( ' '..
			namekey (MENU_TRAVEL, true)..' '..
			namekey (MENU_CHARACTER, true)..' '..
			namekey (MENU_WAYPOINTS, true)
		)
	end
	cprintf_ex('\r')
end

function showMenu (menu, key)
	-- Update the window title with the menu name
	local title = sprintf ('[%s] - %s v%s', menu, NAME, VERSION)
	local lines = 2
	local txt		= '\n\n '
	
	setWindowName (getHwnd (), title)
	
	if menu == MENU_MAIN then
		io.write ('\n')
		setupConsole (80, 1)
		return
		
	elseif menu == MENU_TRAVEL then
		if travelTargets==nil then
			travelTargets = {}
			for key,val in pairs (travelData) do
				table.insert (travelTargets, utf8ToAscii_umlauts(RoMScript ('TEXT("'..val..'")')))	-- TODO: replace with ingame string
			end
			--table.sort (travelTargets)
		end
		activeTarget	= navigate (activeTarget, #travelTargets, 1, key)
		for key,val in ipairs (travelTargets) do
			txt = txt .. namekey (val, (key==activeTarget), nil, 77)
			if math.fmod (key, 1)==0 then
				txt = txt .. '\n '
				lines = lines + 1
			end
		end
		cprintf_ex (txt..'\n')
		
	elseif menu == MENU_CHARACTER then
		table.sort (characterData)
		activeCharacter = navigate (activeCharacter, #characterData, 4, key)
		for key, val in ipairs (characterData) do
			txt = txt .. namekey (utf8ToAscii_umlauts(val), (key==activeCharacter), nil, 18)
			if math.fmod (key, 4)==0 then
				txt = txt .. '\n '
				lines = lines + 1
			end
		end
		cprintf_ex (txt..'\n')
		
	elseif menu == MENU_WAYPOINTS then
		if waypointFiles==nil then
			waypointFiles = {}
			for key,val in pairs (waypointData) do
				table.insert (waypointFiles, key)	-- TODO: replace with ingame string
			end
			table.sort (waypointFiles)
		end
		activeWaypoint = navigate (activeWaypoint, #waypointFiles, 3, key)
		for key,val in ipairs (waypointFiles) do
			txt = txt .. namekey (val, (key==activeWaypoint), nil, 25)
			if math.fmod (key, 3)==0 then
				txt = txt .. '\n '
				lines = lines + 1
			end
		end
		cprintf_ex (txt..'\n')

	end
	
	lines = lines + 1
	setupConsole (80, lines)
end

--==================================--
--==  TRAVEL FUNCTIONS						==--
--==================================--

--==================================--
--==  CHARACTER FUNCTIONS					==--
--==================================--

--==================================--
--==  WAYPOINT FUNCTIONS					==--
--==================================--
