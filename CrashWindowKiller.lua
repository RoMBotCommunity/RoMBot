-- Crash Window Killer by Bot_romka

local name, version = "Crash Window Killer", "v0.1"
local windowname 		= name.." ["..version.."] started."
local linkList			= {}
local dirPath				= 'C:/Games/#MicroMacro/scripts/rom/'

if findWindow (windowname)>0 then
	os.exit ()
end;

local romdir = getDirectory (dirPath)
for i,v in pairs (romdir) do
	local match = string.match (string.lower (v), "rom(.*)%.lnk")
	if match~=nil then
		table.insert (linkList, v)
	end
end

-- set micromacro Window Name
setWindowName (getHwnd (), sprintf (windowname));

-- Crash Window Killer
function CrashWindowKiller ()
	local crashwin = findWindow ("Fehler melden", "#32770")
	if  crashwin > 0 then
		printf ("Crashed window found [%s/%s]. Date: %s\n", getWindowName (crashwin), getWindowClassName (crashwin), os.date ())
		local pid = findProcessByWindow (crashwin)
		os.execute ("TASKKILL /PID " .. pid .. " /F")
		if  (writeLog) then
			-- write CrashWindowKiller Log
			local filename = getExecutionPath () .. "/logs/KilledCrashWindow.log";
			local file, err = io.open (filename, "a+");
			if file then
				file:write ("Date: "..os.date ().." \tPid: "..pid.." \n")
				file:close ()
			end
		end
	end
end;

-- main Macro function
function main ()
	cprintf (cli.lightgreen,"\n    %s.",name)
	cprintf (cli.yellow," Version %s\n\n",version)
	repeat CrashWindowKiller () yrest (2000) until false
end;

startMacro (main,true);
