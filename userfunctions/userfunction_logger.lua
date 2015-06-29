--=== V 2.4 ===--

local logerrors = false -- change to true if you want to log the errors the bot has

-- _filename: the file name of the log file
-- _msg: the message to be logged
-- _logtime: true for logging time stamp
-- _subfolder: String with name of subfolder if data is to be stored in a subfolder of rom\logs\

--=== _logtype ===-- 
--"new" overwrites existing log file with new info
--"add" add to new line at end of file (this is default if not specified)



function logInfo(_filename,_msg,_logtime,_subfolder,_logtype)
	local file, err, filename
	if type(_msg) ~= "string" or type(_filename) ~= "string" then 
		cprintf(cli.red,"Incorrect usage of logInfo function\n") 
		return
	end	
	if type(_subfolder) == "string" then
		if not (isDirectory(getExecutionPath() .. "/logs/" .. _subfolder)) then
			os.execute("mkdir \"" .. string.gsub(getExecutionPath(), "/+", "\\") .. "\\logs\\".._subfolder.."\"")
		end
		_filename = _subfolder.."/".._filename
	end
	filename = getExecutionPath() .. "/logs/".._filename..".txt"
	if type(_logtype) == "string" and string.find(_logtype,"new") then
		file, err = io.open(filename, "w")
	else
		file, err = io.open(filename, "a+")
	end
	if( not file ) then
		cprintf(cli.red,err.."\n")
		return
	end
	if _logtime == true then file:write(os.date().." ") end
	file:write(_msg.."\n")
	file:close()
end

function logtrace()
	errorCallback()
	logInfo(player.Name,debug.traceback(),true,"crashes")
end

if logerrors then
	atError(logtrace)
end

function logloot()

	local function comma_value(n) 
		local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
		return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
	end
	
	local acn = RoMScript("GetAccountName()")
	local gold = RoMScript('GetPlayerMoney("copper");')
	logInfo(player.Name, "", true, "loot/"..acn, "new")
	logInfo(player.Name, "Gold: "..comma_value(gold), false, "loot/"..acn)
	logInfo(player.Name, "--=== Bank ===--", false, "loot/"..acn)
	logInfo(player.Name, "Slot:\tCount:\tName:", false, "loot/"..acn)
	bank:update()
	for i = 1, bank.MaxSlots do
		if bank.BagSlot[i].Id ~= 0 then
			logInfo(player.Name, i.."\t\t"..bank.BagSlot[i].ItemCount.."\t\t"..bank.BagSlot[i].Name, false, "loot/"..acn)
		end
	end
	logInfo(player.Name, "\n--=== Item Shop ===--", false, "loot/"..acn)
	logInfo(player.Name, "Slot:\tCount:\tName:", false, "loot/"..acn)
	inventory:update()
	for slot = 1, 60 do
		item = inventory.BagSlot[slot]
 	    if item.Available and  item.Name ~= "<EMPTY>" then
			logInfo(player.Name, slot.."\t\t"..item.ItemCount.."\t\t"..item.Name, false, "loot/"..acn)
		end
	end
	logInfo(player.Name, "\n--=== Inventory ===--", false, "loot/"..acn)
	logInfo(player.Name, "Slot:\tCount:\tName:", false, "loot/"..acn)
	for slot = 61, 240 do
		item = inventory.BagSlot[slot]
 	    if item.Available and  item.Name ~= "<EMPTY>" then
			logInfo(player.Name, slot.."\t\t"..item.ItemCount.."\t\t"..item.Name, false, "loot/"..acn)
		end
	end
end