--==<<            Rock5'scatchCavy function               >>==--
--==<<           By Rock5        Version 1.02             >>==--
--==<<                                                    >>==--
--==<<  www.solarstrike.net/phpBB3/viewtopic.php?p=12979  >>==--

function catchCavy(_cavy)

	local hpper = 50 -- Players hp percent threshhold to give-up catching the cavy
	_cavy = _cavy or 103567 -- Default value "Golden Magic Cavy"
	if string.lower(_cavy) == "cavy" then -- Look for all cavies
		_cavy = {103566,103567}
	end

	local cavy = player:findNearestNameOrId(_cavy, player.IgnoreCavy)

	if not cavy then return end -- No cavy, return

	yrest(200); -- Make sure you've come to a complete stop.
	player:update()

	-- Don't catch cavy if still battling.
	if player.Battling  and
		player:findEnemy(true, nil, evalTargetDefault) then
		return
	end

	local function CalcNewPos(_trap, _cavy)
		local HerdDist 			= 40 --50 -- distance to herd cavy
		local TrapCavyDist	= distance(_trap.X, _trap.Z, _cavy.X, _cavy.Z)
		local Ratio 				= (TrapCavyDist + HerdDist) / TrapCavyDist
		local x 						= (_cavy.X - _trap.X) * Ratio + _trap.X
		local z 						= (_cavy.Z - _trap.Z) * Ratio + _trap.Z
		local NewPos 				= CWaypoint(x, z)
		NewPos.Type 				= 4 -- Travel
		return NewPos
	end

	if cavy and inventory:itemTotalCount (206776)>0 then -- Huntsman's Trap
		cprintf(cli.yellow,"\aAttempting to catch cavy...\n")
		if distance (player, cavy)>100 then
			NewPos = CalcNewPos (cavy, player)
			player:moveTo (NewPos, true)
		end
		inventory:useItem (206776)
		yrest(3000)
		player:update()
		trap = CWaypoint (player.X, player.Z)
		while true do
			cavy:update()
			if cavy.Id == 0 then break end -- cavy is gone
			if distance (cavy, trap) < 5 then -- cavy is in trap
				printf ("Cavy is in trap\n")
				memoryWriteInt (getProc (), player.Address + addresses.pawnTargetPtr_offset, cavy.Address)
				RoMScript("UseSkill(1,1)") yrest(50)
				RoMScript("UseSkill(1,1)") yrest(2000) -- 'click' again to be sure
				break
			end
			if player.Battling and (100*player.HP/player.MaxHP) < hpper then -- taking too much damage. fight
				player.IgnoreCavy = cavy.Address
				break
			end
			NewPos = CalcNewPos (trap, cavy)
			player:moveTo (NewPos, true)
			yrest(200)
			player:update()
		end
	end
end
