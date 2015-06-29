
__lastCombatMode			= nil
__lastCombatDistance	= nil
__lastCombatMobList		= nil


function combatMode (mode, distance, mobs)
	if mode~=nil and mode~=__lastCombatMode then
		
		local function _set (loot, dist, wp, mobs)
			if settings.profile.options.LOOT~=loot 						then changeProfileOption ('LOOT', 						loot) end
			if settings.profile.options.MAX_TARGET_DIST~=dist	then changeProfileOption ('MAX_TARGET_DIST',	dist) end
			if __WPL.ForcedType~=wp 													then __WPL:setForcedWaypointType (wp) end
			settings.profile.mobs = mobs
		end
		
		local mobList	= ''
		
		if mobs==nil then
			mobList = 'all'
			mobs		= {}
		elseif type(mobs)=="number" or type(mobs)=="string" then
			mobList = mobs
			mobs		= {mobs}
		else
			mobList = ''
			for _,m in pais(mobs) do mobList = ((mobList=='' and '') or ',') .. m end
		end
		
		distance	= ((distance~=nil and distance) or 250)
		
		if mode=='trash' or mode==true then
			mode 			= 'trash'
			distance	= ((distance~=nil and distance) or 250)
			_set (true, distance, 'NORMAL', mobs)
			--if bossBuffs then bossBuffs (false) end
			
		elseif mode=='boss' then
			distance	= ((distance~=nil and distance) or 250)
			_set (false, distance, 'NORMAL', mobs)
			if player.Mounted then player:dismount () end
			--if bossBuffs then bossBuffs (true) end
			
		elseif mode==false then
			mobList 	= 'none'
			distance	= 0
			_set (false, distance, 'TRAVEL', {1})
			if not player.Mounted then mount () end
			--if bossBuffs then bossBuffs (false) end
			
		else
			message ('usage: combatMode (["trash"|"boss"|false, [distance, [mobs]]])');
			return
		end
		
		if __lastCombatMode~=mode or __lastCombatDistance~=distance or __lastCombatMobList~=mobList then
			__lastCombatMode			= mode
			__lastCombatDistance	= distance
			__lastCombatMobList		= mobList
			message ('combatMode:'..tostring(__lastCombatMode)..' dist:'..__lastCombatDistance..' mobs:'..__lastCombatMobList)
		end
	end
	
	return __lastCombatMode, __lastCombatDistance, __lastCombatMobList
end
