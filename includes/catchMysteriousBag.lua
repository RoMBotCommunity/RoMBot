
	function catchMysteriousBag ()

		inventory:update ()
		if inventory:itemTotalCount (0)==0 then return end
		local mBag	= player:findNearestNameOrId (GetIdName (105930))
		if not mBag then return end
		cprintf(cli.yellow,"\aAttempting to open "..mBag.Name.."...\n")
		player:target (mBag)  yrest (500)
		player:fight () yrest (1000)
		player:loot ()
	end
