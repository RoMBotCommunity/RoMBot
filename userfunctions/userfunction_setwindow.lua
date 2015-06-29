--=== Developed by Lisa ===--
--=== Inspired by many  ===--
--=== version 3.0       ===--
--=== Call the function ===--
--=== in WP onload      ===--


	local ghitems = {
	{Id = "200852", ahValue = "2000"}, -- activate rune
	{Id = "241271", ahValue = "1500"}, -- arrowhead eoj
	}


function setwindow(ID)
	unregisterTimer("timedSetWindowName");
	unregisterTimer("setwindow")
	
   -- number formatting by Wonder bob
   -- Usage is as follows :    comma_value(Insert your value here) 	
	local function comma_value(n) 
		local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
		return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
	end
	
	local _starttime = os.time()
	
	if ID == "AH" then
		local startitems = {}
		for k,v in pairs(ghitems) do
			table.insert(startitems,{Id = v.Id,startcount = inventory:itemTotalCount(v.Id), value = v.ahValue})
		end
		local function _window()
			local AHgold = 0
			for k,v in pairs(startitems) do
				local moregold = (inventory:itemTotalCount(v.Id) - v.startcount) * v.value
				AHgold = AHgold + moregold
			end
			local _charname = string.sub(player.Name,1,7)
			local _timepassed = (os.time() - _starttime)/3600
			local _printtime = string.sub(_timepassed,1,4)
			local _goldperhour = string.sub((AHgold/_timepassed),1,8)
			setWindowName(getHwnd(),sprintf(_charname.." AH Gold per hour: "
			..comma_value(_goldperhour).." Time passed: ".._printtime))
		end
		registerTimer("setwindow", secondsToTimer(30), _window)
		return
	end	
	
	if ID == "gold" then
		local startgold = RoMScript('GetPlayerMoney("copper");')
		local function _window()
			local currentgold = RoMScript('GetPlayerMoney("copper");')
			if currentgold then 
				local _charname = string.sub(player.Name,1,7)
				local _timepassed = (os.time() - _starttime)/3600
				local _printtime = string.sub(_timepassed,1,4)
				local _goldreceived = currentgold - startgold
				local _goldperhour = string.sub((_goldreceived/_timepassed),1,8)
				setWindowName(getHwnd(),sprintf(_charname.." Gold per hour: "
				..comma_value(_goldperhour).." Time passed: ".._printtime))
			end
		end
		registerTimer("setwindow", secondsToTimer(30), _window);
	elseif ID == "tp" then
		local starttp = player.TP
		local function _window()
			player.TP = memoryReadRepeat("int", getProc(), addresses.charClassInfoBase + (addresses.charClassInfoSize* player.Class1 ) + addresses.charClassInfoTP_offset) or player.TP
			local _charname = string.sub(player.Name,1,7)
			local _timepassed = (os.time() - _starttime)/3600
			local _printtime = string.sub(_timepassed,1,4)
			local _tpreceived = player.TP - starttp
			local _tpperhour = string.sub((_tpreceived/_timepassed),1,8)
			setWindowName(getHwnd(),sprintf(_charname.." TP per hour: "
			..comma_value(_tpperhour).." Time passed: ".._printtime))
		end
		registerTimer("setwindow", secondsToTimer(30), _window);
	elseif ID == "xp" then
		local startxp = player.XP
		local function _window()
			player.XP = memoryReadRepeat("int", getProc(), addresses.charClassInfoBase + (addresses.charClassInfoSize* player.Class1 ) + addresses.charClassInfoXP_offset) or player.XP
			local _charname = string.sub(player.Name,1,7)
			local _timepassed = (os.time() - _starttime)/3600
			local _printtime = string.sub(_timepassed,1,4)
			local _xpreceived = player.XP - startxp
			local _xpperhour = string.sub((_xpreceived/_timepassed),1,8)
			setWindowName(getHwnd(),sprintf(_charname.." XP per hour: "
			..comma_value(_xpperhour).." Time passed: ".._printtime))
		end
		registerTimer("setwindow", secondsToTimer(30), _window);
	elseif ID == "hp" then
			local function _window()
				player.HP = memoryReadRepeat("int", getProc(), player.Address + addresses.pawnHP_offset) or player.HP;
				setWindowName(getHwnd(),sprintf(player.Name.." Max HP: "..comma_value(player.MaxHP).." Actual HP: "..comma_value(player.HP)))
			end
		registerTimer("setwindow", secondsToTimer(1), _window);
	else
		local _itemname
		--=== ID as item name or item ID ===--
		if type(tonumber(ID)) == "number" then -- arg is item Id
			_itemname = string.sub(GetIdName(ID),1,10)
		else
			_itemname = string.sub(ID,1,10)
		end
		local _startitem = inventory:itemTotalCount(ID)
		local function _window()
			local _charname = string.sub(player.Name,1,7)
			local _timepassed = (os.time() - _starttime)/3600 -- total time in hours
			local _printtime = string.sub(_timepassed,1,4)
			local _gathereditems = inventory:itemTotalCount(ID) - _startitem -- total items aquired since starting
			local _itemsperhour = string.sub((_gathereditems/_timepassed),1,4)
			local _currentitems = inventory:itemTotalCount(ID) 
			setWindowName(getHwnd(),sprintf(_charname..". ".._itemname..": "
			..comma_value(_currentitems).." ("..comma_value(_itemsperhour).."/h) Time(h): ".._printtime))
			--setWindowName(getHwnd(),sprintf("1234567890123456789012345678901234567890123"))
		end
		registerTimer("setwindow", secondsToTimer(36), _window);
		yrest(1000)
		_window()
	end

end