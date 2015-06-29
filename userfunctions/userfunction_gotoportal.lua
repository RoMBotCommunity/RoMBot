--======================================================--
--==       Rock5's Teleporter Helper Functions        ==--
--==                  Version 2.10                    ==--
--== www.solarstrike.net/phpBB3/viewtopic.php?p=37916 ==--
--======================================================--

local function movetoportal(_table)
	-- Face portal
	local angle = math.atan2(_table.Z - player.Z, _table.X - player.X);
	player:faceDirection(angle);
	camera:setRotation(angle);

	-- Move forward
	keyboardHold( settings.hotkeys.MOVE_FORWARD.key );

	-- Wait till reached coords or loading screen appears
	local successdist = 10
	local loopstart = os.time()
	repeat
		yrest(100)
		if isInGame() then
			player:update()
			local dist = distance(player.X, player.Z, _table.X, _table.Z);
			if successdist >= dist then
				keyboardRelease( settings.hotkeys.MOVE_FORWARD.key );
			end
		else
			keyboardRelease( settings.hotkeys.MOVE_FORWARD.key );
			return true
		end
	until os.time() - loopstart > 10
	return false
end

function GoToPortal(_range,_portalid)
	_range = _range or 150 -- Default value
	local nth = 1 -- Will use the nth closest no name object.
	if _portalid and _portalid <= 10 then
		nth = _portalid
		_portalid = nil
	end

	player:update()
	ignore = ignore or 0;
	local closestObject = nil;
	local closestDist = nil;
	local obj = nil;
	local objectList = CObjectList();
	objectList:update();

	local noNameTable = {} -- table of closest no name objects
	local function addNoName(_obj)
		local dist = distance(player.X, player.Z, player.Y, _obj.X, _obj.Z, _obj.Y);
		if dist <= _range then
			if #noNameTable == 0 then
				noNameTable = {_obj}
			else
				for pos,v in ipairs(noNameTable) do
					if dist < distance(player.X, player.Z, player.Y, v.X, v.Z, v.Y) then
						table.insert(noNameTable, pos, _obj)
						return
					end
				end
				table.insert(noNameTable, _obj)
			end
		end
	end

	for i = 0,objectList:size() do
		obj = objectList:getObject(i);

		if obj ~= nil  and obj.Name == "" then
			if _portalid == nil then -- find closest no name object
				addNoName(obj);
			elseif obj.Id == _portalid then -- id matched. use this obj.
				closestObject = obj
				break
			end
		end
	end
	closestObject = closestObject or noNameTable[nth]

	if closestObject then
		print("Targeting portal "..closestObject.Id..", range "..distance(player.X,player.Z,closestObject.X,closestObject.Z))
		return movetoportal(closestObject)
	else
		print("Portal not found within range of "..tostring(_range))
		return false
	end

end

function GoThroughPortal(_range,_portalid)
	player:update()
	local playerOldX, playerOldZ = player.X, player.Z

	GoToPortal(_range,_portalid)

	waitForLoadingScreen(10)
	yrest(3000)
	player:update()

	local wp = __WPL.Waypoints[__WPL.LastWayPoint]
	if (wp and distance(wp.X, wp.Z, player.X, player.Z) > 500) or
	   (distance(player.X,player.Z,playerOldX, playerOldZ) > 500) then
		-- Teleport a success
		return true
	else
		return false
	end
end

function NPCTeleport(_npc, _dest, _preoption)
	local function SelectOption(_option)
		if type(tonumber(_option)) == "number" then
			RoMScript("ChoiceOption(".._option..")")
			return true
		else
			local nextpage = RoMScript("TEXT(\"SC_205764_2\")")
			repeat
				if ChoiceOptionByName(_option) then
					return true
				end
			until not ChoiceOptionByName(nextpage)
			return false
		end
	end

	yrest(1000)
	print("Teleporting to \"".. _dest .. "\" via npc " .. _npc)

	-- Remember last player position
	player:update()
	local oldx, oldz = player.X, player.Z

	-- Target NPC
	repeat
		if not player:target_NPC(_npc) then
			error("Can't find NPC ".._npc)
		end
		yrest(1000)
	until RoMScript("SpeakFrame:IsVisible()")
	yrest(500)

	-- If there is a preoption, select that first
	if _preoption then
		SelectOption(_preoption)
		yrest(1000)
	end

	-- Choose the destination
	if not SelectOption(_dest) then
		print("Option \"".._dest.."\" not found.")
		return false
	end
	yrest(500)

	-- Check if you need to accept the cost
	local acceptCost = RoMScript("StaticPopup_Visible('SET_REQUESTDIALOG')")
	if acceptCost then
		RoMScript("StaticPopup_EnterPressed("..acceptCost..");")
	end

	-- Wait
	waitForLoadingScreen(15)
	yrest(3000)

	-- Check location
	player:update()
	if distance(player.X,player.Z,oldx,oldz) > 200 then
		-- Success
		return true
	else
		print("Failed to teleport")
		return false
	end
end
