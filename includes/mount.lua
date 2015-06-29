
	function mount (force)

		local function mountUp ()
			local casted	= false
			player:mount ()
			repeat
				yrest (500)
				if player.Casting then 
					casted = true 
				end
				player:updateCasting ()
			until not player.Casting
			return casted
		end
		
		if not player.Mounted then
			if mountUp () and not player.Mounted then
				message ('no mount allowed in this area (?)')
				return false
			elseif not player.Mounted and force==true then
				cardID		= ((inventory:itemTotalCount(205821)>0 and 205821) or (inventory:itemTotalCount(203033)>0 and 203033)) or nil
				if cardID~=nil then
					cprintf (cli.lightgreen, 'using "'..TEXT(cardID)..'"\n')
					inventory:useItem(cardID); yrest(2000)
					inventory:update ()
				end
				if not mountUp () then
					cprintf (cli.lightred, 'unable to mount and to use mount card\n')
				end
			end
		end
		player:update ()
		return player.Mounted
	end
