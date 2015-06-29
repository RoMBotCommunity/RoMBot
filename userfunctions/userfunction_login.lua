local VERSION = 3.5
current_client_lnk_in_use = "rom" -- Default client link name. It uses this link if no 'client' link is specified.

-- Load server link list.
if fileExists(getExecutionPath() .. "/ServerLinkList.lua") then
	include("ServerLinkList.lua")
end

local function reserveActiveWindow()
	local pid = getHwnd()
	local file, err, raw, apid, atime

	-- Wait for if other bot needs active window
	local printed = false
	repeat
		while true do
			file = io.open(getExecutionPath().."/../micromacro.pid", "r");
			if file then
				raw = file:read() or ""
				file:close()
				apid, atime = string.match(raw,"pid:(.*) time:(.*)")
				apid = tonumber(apid)
				atime = tonumber(atime)
				if apid == nil or apid == pid or os.time()-tonumber(atime) > 60 then
					break
				else
					if not printed then
						printf("Waiting for another bot to release the active window.")
						printed = true
					else
						printf(".")
					end
				end
			else
				break
			end
			rest(3000)
		end
		if printed then printf("\n") end

		-- Reserve the active window
		file, err = io.open(getExecutionPath().."/../micromacro.pid", "w");
		if( not file ) then
			error(err, 0);
		end

		file:write("pid:"..getHwnd().." time:"..os.time())
		file:close()

		-- See if we still have the active window. Make sure 2 windows didn't write to the file at the same time.
		rest(1000)
		file = io.open(getExecutionPath().."/../micromacro.pid", "r");
		if file then
			raw = file:read() or ""
			file:close()

			apid, atime = string.match(raw,"pid:(.*) time:(.*)")
			apid = tonumber(apid)
		end
	until apid == pid
end

local function releaseActiveWindow()
	file, err = io.open(getExecutionPath().."/../micromacro.pid", "w");
	if( not file ) then
		error(err, 0);
	end

	file:write("")
	file:close()
end

local function startClient(client)
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

	reserveActiveWindow() -- So you don't accidentally attach to another consoles client.
	-- Get a list of current clients
	local beforeWindows = findWindowList("*", "Radiant Arcana");

	-- Start client
	local a,b,c = os.execute("START "..path.." NoCheckVersion")
	if not a then
		error("Trouble executing shortcut. Values returned were: "..(a or "nil")..", "..(b or "nil")..", "..(c or "nil"))
	end

	-- Wait for new client to start
	__WIN = nil
	repeat
		rest(1000)
		local nowWindows = findWindowList("*", "Radiant Arcana");
		for i = 1, #nowWindows do
			local found = false
			for j = 1, #beforeWindows do
				if nowWindows[i] == beforeWindows[j] then
					found = true
					break
				end
			end
			if not found then -- This is the one we just started
				__WIN = nowWindows[i]
				break
			end
		end
	until __WIN
	releaseActiveWindow()

	current_client_lnk_in_use = client
end

local function gameState(win)
	local proc
	if win then
		proc = openProcess( findProcessByWindow(win) )
	else
		proc = getProc()
	end
	if proc == nil then
		error("No valid process found.")
	end

	local atLogin = memoryReadUInt(proc, addresses.editBoxHasFocus_address) == 0 -- Only when not in game
	local atCharacterSelection = memoryReadUInt(proc, addresses.staticTableSize) == 1
	local atLoadingScreen = memoryReadBytePtr(proc,addresses.loadingScreenPtr, addresses.loadingScreen_offset) ~= 0
	local inGame = memoryReadInt(proc, addresses.isInGame) == 1
	if win then closeProcess(proc) end

	if not atLoadingScreen then
		if inGame then
			return 3
		elseif atCharacterSelection then
			return 2
		elseif atLogin then
			return 1
		end
	end

	return 0 -- Means between states
end

local function clickLoginButton(account)
	-- Login button array (ba)
	local ba = {}
	local a = 0
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+38]={row=a,col=3} ba[a+49]={row=a,col=4} ba[a+59]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+38]={row=a,col=3} ba[a+49]={row=a,col=4} ba[a+59]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+38]={row=a,col=3} ba[a+49]={row=a,col=4} ba[a+59]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+38]={row=a,col=3} ba[a+49]={row=a,col=4} ba[a+59]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+38]={row=a,col=3} ba[a+49]={row=a,col=4} ba[a+59]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2}                                                                      ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+30]={row=a,col=3}                        ba[a+51]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+30]={row=a,col=3} ba[a+40]={row=a,col=4} ba[a+51]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+30]={row=a,col=3} ba[a+40]={row=a,col=4} ba[a+51]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+30]={row=a,col=3} ba[a+40]={row=a,col=4} ba[a+51]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+30]={row=a,col=3} ba[a+40]={row=a,col=4} ba[a+51]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}
	a=a+1 ba[a]={row=a,col=1} ba[a+19]={row=a,col=2} ba[a+30]={row=a,col=3} ba[a+40]={row=a,col=4} ba[a+51]={row=a,col=5} ba[a+70]={row=a,col=6} ba[a+89]={row=a,col=7}

	local function buttonXPer(butnum)
		return -62 + 15.5*ba[butnum].col
	end
	local function buttonYPer(butnum)
		return -73 + 3.5*ba[butnum].row
	end

	showWindow(getWin(), sw.show)
	detach()
	rest(500)

	-- Get dimensions of window
	local x,y,w,h = windowRect(getWin())

	-- Calculate coords
	local xPer,yPer = buttonXPer(account), buttonYPer(account)
	moveX,moveY = x+w/2+xPer*h/100, y+h+yPer*h/100

	-- Move and click mouse
	mouseSet(moveX,moveY) rest(100)
	mouseLClick()

	attach(getWin())
end

local function clickCharacter(num)
	-- Character click array
	local charXPer = -18
	local charYPer = {
		[1] = -26,
		[2] = -19,
		[3] = -12,
		[4] = -5,
		[5] = 2,
		[6] = 9,
		[7] = 16,
		[8] = 23,
	}

	showWindow(getWin(), sw.show)
	detach()
	rest(500)

	-- Get dimensions of window
	local x,y,w,h = windowRect(getWin())

	-- Calculate coords
	local xPer,yPer = charXPer, charYPer[num]
	moveX,moveY = x+w+xPer*h/100, y+h/2+yPer*h/100

	-- Move and click mouse
	mouseSet(moveX,moveY) rest(100)
	mouseLClick()

	attach(getWin())
end

function login(character, account, client)
	client = client or current_client_lnk_in_use

	if not client then
		error("No client specified.")
	end
	if not account then
		error("No account specified.")
	end
	if not character then
		error("No character specified.")
	end

	startClient(client)
	rest(5000)
	__PROC = openProcess( findProcessByWindow(getWin()) )

	-- Wait until it's at the login screen. ('atLogin' returns true early so I'm not sure this is necessary)
	repeat
		rest(1000)
	until gameState(__WIN) == 1
	rest(3000)

	-- Click login button until it leave login
	reserveActiveWindow()
	print("Clicking account "..account.." ...")
	repeat
		clickLoginButton(account)
		rest(2000)
	until gameState() ~= 1
	releaseActiveWindow()

	-- Wait until at character selection
	repeat
		rest(2000)
	until gameState() == 2
	rest(3000)

	-- Click character
	reserveActiveWindow()
	print("Selecting character "..character.." ... ")
	clickCharacter(character) rest(500)
	keyboardPress(key.VK_ENTER)
	releaseActiveWindow()

	-- Wait until in game
	print("Waiting until in-game ...")
	repeat
		rest(2000)
	until gameState() == 3
	rest(3000)

	--== Things that need updating
	IdAddressTables = {}

	if CCamera then
		local cameraAddress = memoryReadUIntPtr(getProc(), addresses.staticbase_char, addresses.camPtr_offset) or 0;
		camera = CCamera(cameraAddress);
	end

	if CGuildbank then guildbank = CGuildbank() end

	-- Remember login details
	if player then
		player:update() -- Makes sure the macro is set up for RoMScripts.
		CurrentLoginAcc = RoMScript("LogID")
		CurrentLoginChar = RoMScript("CHARACTER_SELECT.selectedIndex")
		CurrentLoginServer = RoMScript ("GetCurrentRealm")
	end
end

function killClient()
	if __WIN and windowValid(__WIN) then
		local pid = findProcessByWindow(__WIN);
		os.execute("TASKKILL /PID " .. pid .. " /F")
	end

	local crashed, pid, killed
	repeat
		rest(500)
		if not killed then
			crashed, pid = isClientCrashed()
			if crashed then
				os.execute("TASKKILL /PID " .. pid .. " /F");
				killed = true
			end
		end
	until not windowValid(__WIN)
end


