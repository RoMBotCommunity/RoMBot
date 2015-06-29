--==<<           Rock5's LoginNextChar Functions              >>==--
--==<<             By Rock5        Version 1.51               >>==--
--==<<                                                        >>==--
--==<<       Requirements: 'fastLogin Revisited' v3.0         >>==--
--==<<                                                        >>==--
--==<<  www.solarstrike.net/phpBB3/viewtopic.php?f=27&t=1245  >>==--

local charList = {}
local CharacterLoadCount = 1
local RestartClientInterval = 0 -- Restarts client after this many character changes. 0 means 'disabled'.

function SetCharList(_table)
	--[[ Example
		SetCharList({
			{account=1, chars= {1,2,6}},
			{account=2, chars= {1,3}},
			{account=4, chars= {}},
		})

		Or for groups of accounts
		SetCharList({{
			{account=1, chars= {1,2,6}},
			{account=2, chars= {1,3}},
		},
		{
			{account=4, chars= {}},
		}})
	--]]

	-- Error check account lists
	local function checklist(_ltable)
		local errorcheck = false
		if type(_ltable) ~= "table" then
			errorcheck = true
		end
		for k,v in pairs(_ltable) do
			if type(v) ~= "table" then
				errorcheck = true
				break
			end
			if v.chars == nil then
				_ltable[k].chars = {}
			end
			if type(v.account) ~= "number" and type(v.chars ~= "table") then
				errorcheck = true
				break
			end
			for __,vv in pairs(v.chars) do
				if type(vv) ~= "number" then
					errorcheck = true
					break
				end
			end
			if errorcheck then break end
		end

		if errorcheck then
			error("SetCharList(); Invalid argument.")
		end
	end

	if _table[1].account ~= nil then -- Just a list
		checklist(_table)
	else
		for k,v in pairs (_table) do
			checklist(v)
		end
	end

	charList = table.copy(_table)
end

local function GetNextChar()
	local currAcc = getAcc()
	local currChar = getChar()
	local numChars = RoMScript("fastLoginNumChars")

	-- If groups of lists then find which list
	local lcharList
	if charList[1].account ~= nil then -- Just a list
		lcharList = charList
	else
		for k,group in pairs(charList) do
			for i,account in pairs(group) do
				if account.account == currAcc then
					lcharList = group
					break
				end
			end
		end
	end

	-- Find current char in list
	local found = false
	local nextAcc, nextChar
	if lcharList then
		for __, acc in pairs(lcharList) do
			-- Current account found now look for current character.
			if #acc.chars ~= 0 then
				for __, char in pairs(acc.chars) do
					if found == true then
						nextAcc = acc.account
						nextChar = char
						break
					end
					if currAcc == acc.account and currChar == char then
						-- next character is the one we want to load
						found = true
					end
				end
			else -- No chars specified for this account. Do all.
				if found == true then
					nextAcc = acc.account
					nextChar = 1
					break
				end
				if currAcc == acc.account then
					if currChar < numChars then
						nextAcc = acc.account
						nextChar = currChar + 1
						break
					else
						found = true
					end
				end
			end
			if nextAcc ~= nil then break end
		end
	end

	return nextChar, nextAcc
end

function ChangeChar(char, acc, chan)
	local reloads = RoMScript("CharsLoadedCount")
	if reloads ~= nil then
		CharacterLoadCount = reloads
	end

	if RestartClientInterval > 0 and CharacterLoadCount >= RestartClientInterval then
		if ChangeCharRestart(char, acc) ~= false then
			return
		end
	end

	if char == "current" then
		char = getChar()
		acc = nil
	end

	if char == nil then
		printf("Changing to next character")
	else
		printf("Changing to character %d", char)
	end

	if acc == nil or char == nil then
		printf(" on the same account")
	else
		printf(" account %s", tostring(acc))
	end

	if chan then
		printf(" channel %d", chan)
	end

	printf(".\n")
	if type(acc) == "string" then
		acc = "\""..acc.."\""
	end
	if type(chan) == "string" then
		chan = "\""..chan.."\""
	end

	-- Remember acc and char login details
	CurrentLoginAcc = acc or RoMScript("LogID")
	CurrentLoginChar = char or RoMScript("CHARACTER_SELECT.selectedIndex") + 1

	CharacterLoadCount = CharacterLoadCount + 1
	SlashCommand("/script ChangeChar("..(char or "nil")..","..(acc or "nil")..","..(chan or "nil")..")")

	rest(2000)
	waitForLoadingScreen()
	repeat rest(1000) until isInGame()
	rest(3000)

	player:update()

	-- Remember login server
	CurrentLoginServer = RoMScript ("GetCurrentRealm()")

end

function LoginNextChar()
 	-- Character list defined?
	if #charList == 0 then
		error("LoginNextChar(); No character list defined. Use \"SetCharList(_table)\" to define list before using \"LoginNextChar()\"")
	end

	nextChar, nextAcc = GetNextChar()

	if nextAcc == nil then
		if (Quit_Game == "true") then
			-- we will quit game
			print("Last player finished. We will Quit game")
			RoMScript("QuitGame()")
		else			-- Last character
			print("Last player finished.")
			player:logout()
		end
	end

	ChangeChar(nextChar, nextAcc)
end

function SetChannelForLogin(_value)
	RoMScript("} UserSelectedChannel = \"" .. _value .. "\" a={");
end

function PrintCharList()
	if charList[1].account ~= nil then -- Just a list
		for k,v in pairs(charList) do
			printf("account = %d\tchars = ",v.account)
			print(unpack(v.chars))
		end
	else
		for k,group in pairs(charList) do
			print("Account group "..k)
			for k,v in pairs(group) do
				printf("\taccount = %d\tchars = ",v.account)
				print(unpack(v.chars))
			end
		end
	end
end

function SetRestartClientSettings(frequency, client)
	if type(frequency) == "number" then
		RestartClientInterval = frequency
	end

	-- This variable is also set if the game was started with login.lua or the login function
	if client then
		current_client_lnk_in_use = client
	end
end

function ChangeCharRestart(char, acc, client)
	-- Check if 'login' userfunction is installed.
	if not login or not killClient then
		print("Please install the latest version of the \"login\" userfunction.")
		return false
	end

	if char == "current" then
		char = CurrentLoginChar or getChar()
	end

	if acc == nil then
		acc = CurrentLoginAcc or getAcc()
	end

	if char == nil or acc == nil then
		error("Character and account not specified.")
	end

	if client == nil then
		client = getServerLink()
	end

	if client == nil then
		print("No client shortcut link specified. Not restarting client.")
		return false
	end

	printf("Changing to character %d account %d with client lnk \"%s\"\n", char, acc, client)
	RestartClientCount = 1

	killClient() rest(1000)

	login(char, acc, client)

	return true
end

function IsLastChar(override)
	local currAcc = getAcc()
	local currChar = getChar()
	local numChars = RoMScript("fastLoginNumChars")

	if override == nil then
		if #charList > 0 then
			override = "LoginNextChar"
		else
			override = "ChangeChar"
		end
	end
	if override then override = string.lower(override) end

	if override == "changechar" then
		return (currChar == numChars) -- last char of this account
	elseif override == "loginnextchar" then
		return (GetNextChar() == nil)
	else
		error("Incorrect arg#1 used in 'IsLastChar'. Should be 'changechar', 'loginnextchar' or nil.")
	end

	return false
end

function getChar()
	return RoMScript("CHARACTER_SELECT.selectedIndex")
end

function getAcc()
	return RoMScript("LogID")
end

function getServerLink(server)
	if server == nil then
		server = CurrentLoginServer
	end

	if ServerLinkList and ServerLinkList[server] then
		return ServerLinkList[server]
	else
		return current_client_lnk_in_use
	end
end

-- Default onClientCrash function to restart client.
function onClientCrash()
	ChangeCharRestart("current")
end
