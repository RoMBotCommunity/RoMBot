
	function smartMove (...)
		local wpList	= {...}
		if wpList[1].X==nil then wpList = wpList[1] end
		local start 	= nil
		local dist		= nil
		player:updateXYZ ()
		for i=1,#wpList do
			local tmp = distance (player.X, player.Z, wpList[i].X, wpList[i].Z)
			if dist==nil or tmp<dist then
				dist	= tmp
				start	= i
			end
		end
		printf ('player position X:%d Z:%d\n', player.X, player.Z)
		for i=start,#wpList do
			local wp = CWaypoint (wpList[i])
			cprintf (cli.green, 'moving to temporary waypoint X:%d Z:%d tag:%s\n', wp.X, wp.Z, wp.Tag)
			player:moveTo (wp, true)
		end
		player:updateXYZ ()
	end

	function smartMoveReverse (...)
		local wpList	= {...}
		if wpList[1].X==nil then wpList = wpList[1] end
		local newList = {}
		for i=1,#wpList do table.insert (newList, 1, wpList[i]) end
		smartMove (newList)
	end