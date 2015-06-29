
if TQ then os.exit () end

local currAcc			= RoMScript ("LogID")
local currChar		= RoMScript ("CHARACTER_SELECT.selectedIndex")
local dirPath			= 'C:/Games/#MicroMacro/scripts/rom/' --getExecutionPath () ..'/../'
local currPath		= __WPL.FileName
local Clientlink	= false

atError (nil)

if (Clientlink == false) then
	local romdir = getDirectory (dirPath)
	for i,v in pairs (romdir) do
		local match = string.match (string.lower (v), "rom(.*)%.lnk")
		if (match ~= nil) then
			Clientlink = v
		end
	end
end;
cprintf (cli.white, "Current Acc: %s, Char: %s, Path: %s, dirPath: %s, Client: %s\n", currAcc, currChar, currPath, dirPath, Clientlink)

function onClientCrash ()
	yrest (secondsToTimer (10))
	if (not windowValid (getAttachedHwnd ())) then
		if TQ then 
			TQ:log ("Account: "..currAcc.." \tName: " ..string.format ("%-10s",player.Name).." \tDate: "..os.date ().." \tPath: "..currPath.." \n")
		end
		-- Restart client and Bot
		os.execute ("START "..dirPath.."/../../micromacro.exe "..dirPath.."/login acc:"..currAcc.." char:"..currChar.." client:"..Clientlink.." path:"..currPath)
		os.exit ()
	end
end;

local name, version		= "Crash Window Killer", "v0.1"
if TQ then
	name, version				= "TQ Main", "v0.1"
end
local windowname			= name.." ["..version.."] started."
local allreadyStarted	= findWindow (windowname)
if allreadyStarted==0 then
	local a,b,c = os.execute ("START "..dirPath.."/../../micromacro.exe "..dirPath.."/CrashWindowKiller.lua")
	if not a then
		cprintf (cli.red, "Trouble executing file. Values returned were: ".. (a or "nil")..", ".. (b or "nil")..", ".. (c or "nil"))
	end
end;

if (Clientlink) then
	atError (onClientCrash)
end;
