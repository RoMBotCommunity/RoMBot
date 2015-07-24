--==<<                                               >>==--
--==<<          Celesterias auto speed hack          >>==--
--==<<          by Celesteria - version 1.2          >>==--
--==<<                                               >>==--
--==<< this hack auto uses speed hacks if no other	 >>==--
--==<< player is around you                          >>==--


__UASH_active	  		= false
__UASH_mountspeed   = 99
__UASH_runspeed     = 75

local function checkSpeed ()
	if not player or not __UASH_active then UASH_deactivate () return end
	if player.Battling or player.Casting then return end
	local objList 		= CObjectList ()
	local playerFound = false
	objList:update ()
	for i = 0, objList:size () do
		local obj = objList:getObject (i)
		if obj and obj.Type==PT_PLAYER and obj.Name~='' and obj.Name~='<UNKNOWN>' and obj.Name~=player.Name then
    	playerFound = true
			break
		end
	end
	local playerAddress = memoryReadIntPtr (getProc (), addresses.staticbase_char, addresses.charPtr_offset)
	if playerAddress ~= 0 then
		memoryWriteFloat (getProc (), playerAddress + 0x40, playerFound and 50 or __UASH_runspeed)
		local mount = memoryReadInt(getProc(), playerAddress + addresses.charPtrMounted_offset)
		if mount ~= 0 then
			memoryWriteFloat(getProc(), mount + 0x40, playerFound and 82 or __UASH_mountspeed)
		end
	end
end

function UASH_Activate ()
	registerTimer("UASH_speed", 5, checkSpeed)
	cprintf (cli.lightblue, "AutoSpeedHack ") cprintf (cli.lightgreen, "activated\n")
	__UASH_active = true
end

function UASH_Deactivate ()
	unregisterTimer("UASH_speed")
	cprintf (cli.lightblue, "AutoSpeedHack ") cprintf (cli.lightred, "deactivated\n")
	__UASH_active = false
end

