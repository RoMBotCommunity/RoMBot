--==<<                                                >>==--
--==<<          Celesterias greetFriends              >>==--
--==<<         by Celesteria - version 1.0            >>==--
--==<<                                                >>==--
--==<< say hi to friends and guildmates while botting >>==--
--==<<                                                >>==--

	------------------------------------------------------------------------------------
	-- examples:
	--		UGF_activate (10, true, false)   -- greet friends and no guildmates (re-greet after 10 minutes)
	--		UGF_deactivate ()                -- deactivate
	------------------------------------------------------------------------------------

	local __UGF = {
		['friends'] 				= {},
		['useFriendList']   = false,
		['useGuildList']    = false,
		['active']	        = false,
		['emotes']          = {'wave','salute','tribute'},
		['timeout']         = false,
	}

	local function reset ()
		__UGF = {
			['friends'] 				= {},
			['useFriendList']   = false,
			['useGuildList']    = false,
			['active']         = false,
			['emotes']          = {'wave','salute','tribute'},
			['timeout']         = false,
		}
	end

	local function readFriendList ()
    __UGF.friends = __UGF.friends or {}
		if __UGF.active then return end
		local max = RoMScript ('GetFriendCount (DF_Socal_Token_Friend)')
		cprintf (cli.lightblue, 'retrieving friendslist ')
		for i=1, max do
			local name	= RoMScript ('GetFriendInfo (DF_Socal_Token_Friend, '..i..')')
			if name~=nil and name~='' then
				cprintf (cli.yellow, math.fmod (i,10)==0 and '|' or '.')
				__UGF.friends[name] = 0
			end
		end
		cprintf (cli.lightblue, ' done\n')
	end

	local function readGuildList ()
    __UGF.friends = __UGF.friends or {}
		if __UGF.active then return end
		local max = RoMScript ('GetNumGuildMembers ()')
		cprintf (cli.lightblue, 'retrieving guildlist ')
		for i=1, max do
			local name	= RoMScript ('GetGuildRosterInfo ('..i..')')
			if name~=nil and name~='' then
				cprintf (cli.yellow, math.fmod (i,10)==0 and '|' or '.')
				__UGF.friends[name] = 0
			end
		end
		cprintf (cli.lightblue, ' done\n')
	end

	local function check ()
		if not player or not __UGF.active then UGF_deactivate () return end
		if player.Battling or player.Casting then return end
		local objList = CObjectList ()
		objList:update ()
		for i = 0, objList:size () do
			local obj = objList:getObject (i)
			if obj and obj.Type==PT_PLAYER and obj.Name~='' and obj.Name~='<UNKNOWN>' and obj.Name~=player.Name then
				if __UGF.friends[obj.Name]~=nil then
					if __UGF.timeout==false or __UGF.friends[obj.Name] < os.time ()-minutesToTimer (__UGF.timeout) then
						player:updateTargetPtr()
						local oldTarget = CPawn (player.TargetPtr) or nil
						player:target (obj)
						RoMScript ('/' .. __UGF.emotes [math.floor (math.random()*3)+1])
						cprintf (cli.lightblue, 'greetings to '..obj.Name..'\n')
						player:target (oldTarget)
						if __UGF.timeout==false then
							__UGF.friends[obj.Name] = nil
						else
							__UGF.friends[obj.Name] = os.time ()
						end
						break
					end
				end
			end
		end
	end

	function UGF_activate (reGreet, friends, guild)
		if reGreet==false or reGreet<=0 or reGreet==nil then
			__UGF.timeout = false
		else
    	__UGF.timeout = tonumber (reGreet) or 10
		end
		if friends~=false then
			readFriendList ()
			__UGF.useFriendList = true
		end
		if guild~=false then
			readGuildList ()
			__UGF.useGuildList = true
		end
		registerTimer ("greet", secondsToTimer (5), check)
		cprintf (cli.lightblue, 'userfunction_greetFriends activated')
    __UGF.active = true
	end

	function UGF_deactivate ()
 		unregisterTimer ("greet")
    reset ()
		cprintf (cli.lightblue, 'userfunction_greetFriends deactivated')
	end
