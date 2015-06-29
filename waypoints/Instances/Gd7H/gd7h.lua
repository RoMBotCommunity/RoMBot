-- ToSH_OT_farm by Bot_romka v0.1.3

-- virtual key codes: http://msdn.microsoft.com/en-us/library/ms927178.aspx
local triggerkey = key.VK_CONTROL
local pausekey = key.VK_SHIFT

local moovekey = settings.hotkeys.MOVE_BACKWARD.key
-- set moovekey to settings.hotkeys.MOVE_BACKWARD.key or settings.hotkeys.STRAFF_RIGHT.key

local setCamRotation = true;	-- set to false or true for auto rotate camera

local Center_X = -1505			-- Tosh coords center of circle
local Center_Z = -713

local CameraYAngle = 0.16		-- Camera Y angle in radians from the horizontal.
local CameraCAngle = 1			-- Camera angle to center of circle.

local Dist_to_Target = 150		-- distance to target from player
local Dist_to_Center = 220		-- distance from center of circle to player

local Tosh_Tp_Step = 20			-- teleport distance from player position
local Tosh_Tp_Pause = 50		-- after teleport
local Last_PX = player.X		-- player X position
local Last_PZ = player.Z		-- player Z position

local trykill = 0;
local mooved = false;
local trigger = false;
local ferstkill = true;
local Timer_KM = os.clock();
local Timer_CP = os.clock();
cprintf(cli.white, player.Name.." Start ToSH_OT_farm:   %s\n", os.clock());

local Anglediff = 0;			-- dont change it.
if moovekey == settings.hotkeys.MOVE_BACKWARD.key then
	Anglediff = 1.5666;
end;

-- check
--	local angle = math.atan2(Center_Z - player.Z, Center_X - player.X)
--	local playerAnglediff = player.Direction - angle
--	cprintf(cli.white, "playerAnglediff:   %s\n", playerAnglediff)
--	local Dist = math.sqrt( (player.X-Center_X)^2 + (player.Z - Center_Z)^2 )
--	cprintf(cli.white, "Now dist to center: %s, Dist_to_Center: %s\n", Dist, Dist_to_Center)

--[[
/script CastSpellByName("Грозовой шторм")
/script SpellTargetUnit()
-- макро на глада и поставь себе модельки лагать меньше будет.
/script CastSpellByName("Импульс заточения")
/wait 0.1
/script SpellTargetUnit("mouseover")
--]]
	------------------------------------functions------------------------------------

-- Totaltime
function Totaltime(_time)
	local ttime = os.difftime(os.time(),player.BotStartTime_nr)
	_time = _time or ttime
	local hours  =  math.floor(_time/3600)
	local minutes = math.floor((_time-(hours*3600))/60)
	local seconds = math.floor(_time-((hours*3600)+(minutes*60)))
	return hours, minutes, seconds, ttime
end;
	
-- Combo Rogue Scout Seven
function ComboRogueScoutSeven()
	if mooved == true then
		local player_haveTarget = player:haveTarget()
		if not player_haveTarget then
--			cprintf(cli.white, "Player not haveTarget\n")
			player:target(player:findEnemy(true,106112,evalTargetDefault))
		elseif player_haveTarget then
			if ferstkill and (os.clock() - Timer_KM) > 15 then
				ferstkill = false
			else
				target = player:getTarget()
				target:update()
				if target.Id ~= 0 and target.Id == 106112 and target.HP > 1 and target.Alive then
					player:updateXYZ()
					local Dist1 = math.sqrt( (player.X-target.X)^2 + (player.Z - target.Z)^2 )
					local Dist2 = math.sqrt( (player.X-Center_X)^2 + (player.Z - Center_Z)^2 )
					if Dist1 > Dist_to_Target+10 then
						keyboardRelease(moovekey)
						yrest(100)
						keyboardHold(moovekey)
					elseif Dist2+10 > Dist_to_Center then
						if trykill == 5 then
							RoMScript("CastSpellByName(TEXT('Sys491292_name'));"); yrest(100)
							RoMScript("CastSpellByName(TEXT('Sys491531_name'));"); yrest(100)
							trykill = 0
						else
							trykill = trykill + 1
						end
					end
				else
					player:clearTarget()
				end
			end
		end
	end
end;

--[[
				-- teleport from target and center
				player:updateXYZ()
				-- calc 1
				local Dist1 = math.sqrt( (player.X-target.X)^2 + (player.Z - target.Z)^2 )
				local New_X1 = target.X + Dist_to_Target * (player.X-target.X) / Dist
				local New_Z1 = target.Z + Dist_to_Target * (player.Z-target.Z) / Dist
				cprintf(cli.white, "1: New_X: %s, New_Z: %s\n", New_X1, New_Z1)
				-- calc 2
				local Dist2 = math.sqrt( (New_X-Center_X)^2 + (New_Z - Center_Z)^2 )
				local New_X2 = Center_X + Dist_to_Center * (New_X-Center_X) / Dist
				local New_Z2 = Center_Z + Dist_to_Center * (New_Z-Center_Z) / Dist
				cprintf(cli.white, "2: New_X: %s, New_Z: %s\n", New_X2, New_Z2)
				-- teleport to new coords
				teleport(New_X2, New_Z2)
				player:updateXYZ()
--]]

-- teleport from last player position and center
function Teleplac()
	player:updateXYZ()
	local target = player:getTarget()
	if not target or Last_PX == player.X then return end
	-- calc 1
	local Dist1 = math.sqrt( (player.X - target.X)^2 + (player.Z - target.Z)^2 )
	local New_X1 = target.X + Dist_to_Target * (player.X - target.X) / Dist1
	local New_Z1 = target.Z + Dist_to_Target * (player.Z - target.Z) / Dist1
--	cprintf(cli.white, "calc 1: New_X: %s, New_Z: %s\n", New_X1, New_Z1)
	-- calc 2
	local Dist2 = math.sqrt( (New_X1 - Center_X)^2 + (New_Z1 - Center_Z)^2 )
	local New_X2 = Center_X + Dist_to_Center * (New_X1 - Center_X) / Dist2
	local New_Z2 = Center_Z + Dist_to_Center * (New_Z1 - Center_Z) / Dist2
--	cprintf(cli.white, "calc 2: New_X: %s, New_Z: %s\n", New_X2, New_Z2)
	-- teleport to new coords
	teleport(New_X2, New_Z2)
end;

-- Combo Mage Thunderstorm
function ComboMageThunderstormSeven()
	-- if not mooved
	if mooved ~= true then return end

	-- Freeze mouse function
	local function nopmouse()
		-- x axis
		local addressX1 = addresses.functionMousePatchAddr
		local addressX2 = addresses.functionMousePatchAddr + addresses.mousePatchX2_offset
		local addressX3 = addresses.functionMousePatchAddr + addresses.mousePatchX3_offset
		memoryWriteString(getProc(), addressX1, string.rep(string.char(0x90),#addresses.functionMouseX1Bytes)); -- left of window
		memoryWriteString(getProc(), addressX2, string.rep(string.char(0x90),#addresses.functionMouseX2Bytes)); -- right of window
		memoryWriteString(getProc(), addressX3, string.rep(string.char(0x90),#addresses.functionMouseX3Bytes)); -- over window

		-- y axis
		local addressY1 = addresses.functionMousePatchAddr + addresses.mousePatchY1_offset
		local addressY2 = addresses.functionMousePatchAddr + addresses.mousePatchY2_offset
		local addressY3 = addresses.functionMousePatchAddr + addresses.mousePatchY3_offset
		memoryWriteString(getProc(), addressY1, string.rep(string.char(0x90),#addresses.functionMouseY1Bytes)); -- above window
		memoryWriteString(getProc(), addressY2, string.rep(string.char(0x90),#addresses.functionMouseY2Bytes)); -- below window
		memoryWriteString(getProc(), addressY3, string.rep(string.char(0x90),#addresses.functionMouseY3Bytes)); -- over window
	end

	-- Unfreeze mouse function
	local function unnopmouse()
		-- x axis
		local addressX1 = addresses.functionMousePatchAddr
		local addressX2 = addresses.functionMousePatchAddr + addresses.mousePatchX2_offset
		local addressX3 = addresses.functionMousePatchAddr + addresses.mousePatchX3_offset
		memoryWriteString(getProc(), addressX1, string.char(unpack(addresses.functionMouseX1Bytes)));
		memoryWriteString(getProc(), addressX2, string.char(unpack(addresses.functionMouseX2Bytes)));
		memoryWriteString(getProc(), addressX3, string.char(unpack(addresses.functionMouseX3Bytes)));

		-- y axis
		local addressY1 = addresses.functionMousePatchAddr + addresses.mousePatchY1_offset
		local addressY2 = addresses.functionMousePatchAddr + addresses.mousePatchY2_offset
		local addressY3 = addresses.functionMousePatchAddr + addresses.mousePatchY3_offset
		memoryWriteString(getProc(), addressY1, string.char(unpack(addresses.functionMouseY1Bytes)));
		memoryWriteString(getProc(), addressY2, string.char(unpack(addresses.functionMouseY2Bytes)));
		memoryWriteString(getProc(), addressY3, string.char(unpack(addresses.functionMouseY3Bytes)));
	end

	-- teleport from target and center
	local function teleftac()
		local target = player:getTarget()
		if not target then return end
		target:updateXYZ()
		player:updateXYZ()
		-- calc 1
		local Dist1 = math.sqrt( (player.X - target.X)^2 + (player.Z - target.Z)^2 )
		local New_X1 = target.X + Dist_to_Target * (player.X - target.X) / Dist1
		local New_Z1 = target.Z + Dist_to_Target * (player.Z - target.Z) / Dist1
		cprintf(cli.white, "calc 1: New_X: %s, New_Z: %s\n", New_X1, New_Z1)
		-- calc 2
		local Dist2 = math.sqrt( (New_X1 - Center_X)^2 + (New_Z1 - Center_Z)^2 )
		local New_X2 = Center_X + Dist_to_Center * (New_X1 - Center_X) / Dist2
		local New_Z2 = Center_Z + Dist_to_Center * (New_Z1 - Center_Z) / Dist2
		cprintf(cli.white, "calc 2: New_X: %s, New_Z: %s\n", New_X2, New_Z2)
		-- teleport to new coords
		teleport(New_X2, New_Z2)
	end
	
	-- Kill target
	local player_haveTarget = player:haveTarget()
	if not player_haveTarget then
		cprintf(cli.white, "Player not haveTarget\n")
		player:target(player:findEnemy(true,106112,evalTargetDefault))
	elseif player_haveTarget then
		local target = player:getTarget()
		repeat
			target:update()
--			if target.Id ~= 0 and target.Id == 106112 and target.HP > 1 and target.Alive then
			if target.Id ~= 0 and target.Id == 106355 and target.HP > 1 and target.Alive then
				keyboardRelease(moovekey)
				-- teleport from target and center
				teleftac()
				-- set camera Direction
				setCamDirection(angle)
				yrest(Tosh_Tp_Pause)
				-- check 
				if target:countMobs(60, nil, 106355) == 0 then
					RoMScript("CastSpellByName(TEXT('Sys490244_name'))")	-- "Thunderstorm"
--					cprintf(cli.white, "aimAt/")
--					player:aimAt(target)

					local ww = memoryReadIntPtr(getProc(),addresses.staticbase_char,addresses.windowSizeX_offset)
					local wh = memoryReadIntPtr(getProc(),addresses.staticbase_char,addresses.windowSizeY_offset)
					local clickX = math.ceil(ww/2)
					local clickY = math.ceil(wh/2)
--					yrest(50)
					cprintf(cli.white, "nopmouse/")
					nopmouse()
--					yrest(50)
					memoryWriteIntPtr(getProc(),addresses.staticbase_char,addresses.mouseX_offset,clickX)
					memoryWriteIntPtr(getProc(),addresses.staticbase_char,addresses.mouseY_offset,clickY)
--					yrest(50)
					RoMScript("SpellTargetUnit()")
--					yrest(50)
					-- unfreeze TargetPtr
					unnopmouse()
				end
			else
				keyboardHold(moovekey)
				player:clearTarget()
				break
			end
		until false
	end
	-- Dist_to_Center
	local Dist = math.sqrt( (player.X - Center_X)^2 + (player.Z - Center_Z)^2 )
	if Dist > Dist_to_Center + 30 then
		teleftac()
	end
end;

-- kite Thunderstorm
function kiteThunderstorm(mymob)
	if mymob then
		mymob = CPawn(mymob.Address)
	else
		return -- no mob found yet
	end

	-- return true if mob disappeared or dead or false if still alive
	if mymob.Id == 0 or
		1 > mymob.HP or
	not mymob.Alive then
		return true
	end

	player.target(mymob)
	local angle = math.atan2(mymob.Z - player.Z, mymob.X - player.X);
	player:faceDirection(angle)
	keyboardHold(settings.hotkeys.MOVE_BACKWARD.key)
	player:aimAt(mymob)
	RoMScript("CastSpellByName(TEXT('Sys490244_name'))")	-- "Thunderstorm"
	yrest(50)
	RoMScript("SpellTargetUnit()")

	-- return false if mob gone or dead
	mymob:update()
	if mymob.Id == 0 or 1 > mymob.HP or not mymob.Alive then
		return true
	end

	return false
end;

-- Set camera direction
function setCamDirection(angle)
	if setCamRotation == true and angle ~= nil then
	--if setCamRotation == true and (os.clock() - Timer_CP) > 1 then
		camera:setRotation(angle+CameraCAngle)
		-- set camera Y angle
		local playerYAngle = player.DirectionY
		if playerYAngle > CameraYAngle then
			playerYAngle = CameraYAngle
		elseif -CameraYAngle > playerYAngle then
			playerYAngle = -CameraYAngle
		end
		local vec3 = math.sin(CameraYAngle-playerYAngle) * camera.Distance
		memoryWriteFloat(getProc(), camera.Address + addresses.camY_offset, camera.YFocus + vec3);
		Timer_CP = os.clock()
	end
end;

-- Get target casting time
function TargetCastingTime(target)
	local target = target or player:findNearestNameOrId(106355)
	if target then
		player:target(target)
		if player:hasTarget() then
			local casttime = memoryReadRepeat("float", getProc(), target.Address + 0x260)
			local elapsedtime = memoryReadRepeat("float", getProc(), target.Address + 0x264)
			local remaining = casttime - elapsedtime
			printf(remaining.."\n")
			return remaining
		end
	end
	return 0
end;

	-------------------------------main script--------------------------------

function MainScript()
	repeat
		if keyPressedLocal(settings.hotkeys.STRAFF_LEFT.key) or keyPressedLocal(settings.hotkeys.MOVE_FORWARD.key) then
			keyboardRelease(moovekey)
			mooved = false
		end

		while keyPressedLocal(triggerkey) do
			trigger = true
			Timer_KM = os.clock()
			yrest(10)
		end

		if trigger == true then
			keyboardHold(moovekey)
			trigger = false
			mooved = true
		end

		if mooved == true and keyPressedLocal(pausekey) then
			keyboardRelease(moovekey)
			while keyPressedLocal(pausekey) do
				yrest(10)
			end
			keyboardHold(moovekey)
		end

		if mooved == true then
			player:update()
			if not player.Alive then mooved = false break end
			local Dist = math.sqrt( (player.X-Center_X)^2 + (player.Z - Center_Z)^2 )
			cprintf(cli.white, "Dist: %s, Dist_to_Center: %s\n", Dist, Dist_to_Center)
			local angle = math.atan2(Center_Z - player.Z, Center_X - player.X)
			-- check and correct player Direction
			if Dist+2 > Dist_to_Center then
				-- rotate left, Set faceDirection
				player:faceDirection(Anglediff+angle+0.1)
			elseif Dist_to_Center+2 > Dist then
				-- rotate right, Set faceDirection
				player:faceDirection(Anglediff+angle-0.1)
			end
			-- set camera Direction
			setCamDirection(angle)
			-- try to kill mobs
			--ComboMageThunderstormSeven()
			kiteThunderstorm ()
		end
		
		yrest(100)	-- wait time
	until false

end;
