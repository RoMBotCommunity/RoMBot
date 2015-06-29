--=== Created by Lisa 			===--
--=== 		V 1.32 					 	===--
--=== Updated by Bill D Cat	===--
--=== Updated by Celesteria	===--

-- examples	changeOptionFriendMob("mob", "Wolf", "Add")
-- examples	changeOptionFriendMob("friend", "Hokeypokey", "Remove")
-- examples	changeOptionFriendMob("friend", "reset") 	-- goes back to profile for friend
-- examples	changeOptionFriendMob("mob", "reset")		-- goes back to profile for mob

-- new in version 1.32:
--
-- examples changeOptionFriends ('add', 'player1')
-- -> same as:
--		changeOptionFriendMob ('friend', 'player1', 'add') 
--
-- examples changeOptionFriends ('add', {'player1', 'player2', mobID})
-- -> same as:
--		changeOptionFriendMob ('friend', 'player1', 'add') 
--		changeOptionFriendMob ('friend', 'player2', 'add')
--		changeOptionFriendMob ('friend', mobID, 'add')
--
-- examples changeOptionMobs ('remove', {'mobname', mobID})
-- -> same as:
--		changeOptionFriendMob ('mob', 'mobname', 'remove') 
--		changeOptionFriendMob ('mob', mobID, 'remove')
--
-- examples changeOptionMobs ('list')
-- examples changeOptionFriends ('reset')
--
-- second parameter can be a single name/id or a table of names/ids

function changeOptionMobs (_command, _namesOrIds)
	if _namesOrIds~=nil then
		_namesOrIds	= type (_namesOrIds)~='table' and { _namesOrIds } or _namesOrIds
		if type (_namesOrIds)=='table' then
			for _,nameOrId in pairs (_namesOrIds) do
				changeOptionFriendMob ('mob', nameOrId, _command)
			end
		end
	else
		changeOptionFriendMob ('mob', _command)
	end
end

function changeOptionFriends (_command, _namesOrIds)
	if _namesOrIds~=nil then
		_namesOrIds	= type (_namesOrIds)~='table' and { _namesOrIds } or _namesOrIds
		if type (_namesOrIds)=='table' then
			for _,nameOrId in pairs (_namesOrIds) do
				changeOptionFriendMob ('friend', nameOrId, _command)
			end
		end
	else
		changeOptionFriendMob ('friend', _command)
	end
end

local oldlist, oldprofile

local function printlist(_list)
	for k,v in ipairs(_list) do
		if type(tonumber(v)) == "number" then
			printf(k..": "..v.." ("..GetIdName(tonumber(v))..")\n")
		else
			printf(k..": "..v.."\n")
		end
	end
end

function changeOptionFriendMob(_type,_name,_addremove)
--examples   changeOptionFriendMob("mob", "Wolf", "Add")
--examples   changeOptionFriendMob("friend", "Hokeypokey", "Remove")
--examples   changeOptionFriendMob("friend", "reset")    -- goes back to profile for friend
--examples   changeOptionFriendMob("mob", "list")      -- displays the mob list

	if( _name ) then name = trim(_name) end;

	if _name == "list" or _name == "reset" then
		_addremove = _name
	elseif _name == nil or _name == "" then
		printf("Need to specify name.\n")
	end

	if _addremove == nil then _addremove = "add" end

	addremove = string.lower(_addremove)

	if addremove ~= "add" and addremove ~= "remove" and addremove ~= "list" and addremove ~= "reset" then
		printf("Wrong usage of arg#3, _addremove")
	end

	local list, listname
	if _type == "friend" then
		list, listname = settings.profile.friends, "friends"
	elseif _type == "mob" then
		list, listname = settings.profile.mobs, "mobs"
	else
		return
	end

	-- Update oldlist if profile changes
	if settings.profile ~= oldprofile then
		print("New profile detected")
		oldlist = {	friends = table.copy(settings.profile.friends),
					mobs = table.copy(settings.profile.mobs)}
		oldprofile = settings.profile
	end
	if _addremove == "reset" then
		settings.profile[listname] = table.copy(oldlist[listname])
		return
	end
	if addremove == "add" then
		for k,v in ipairs(list) do
			if (v == tostring(_name)) or (GetIdName(tonumber(v)) == _name) or (v == GetIdName(tonumber(_name))) then return end
		end
		table.insert(list, tostring(_name));
		printf("Updating %s List\n",listname)
		printlist(list)
	end
	if addremove == "remove" then
		printf("Updating %s List\n", _type)
		for k = #list, 1, -1 do -- Need to go in reverse in case there are more than 1 entry.
			local v = list[k]
			if (v == tostring(_name)) or (GetIdName(tonumber(v)) == _name) or (v == GetIdName(tonumber(_name))) then
				table.remove(list,k);
				if type(tonumber(v)) == "number" then
					printf("Removing %s %d (%s)\n", _type, v,GetIdName(tonumber(v)))
				else
					printf("Removing %s %s\n", _type, v)
				end
			end
		end
		printlist(list)
	end
	if addremove == "list" then
		printf("Displaying %s List\n", _type)
		printlist(list)
	end
end
