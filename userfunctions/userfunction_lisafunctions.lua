--[[setmetatable(_G, {__newindex = function(t, k, v)

-- do stuff eg.
print("Created new global variable "..k.." = "..tostring(v))

rawset(_G, k, v)
end})]]

function lisa_dailycount()

	local dqCount, dqPerDay = RoMScript("Daily_count()");
	printf(dqCount.. " done out of "..dqPerDay.." Which means "..dqPerDay-dqCount.." left \n")

end

function lisa_printinventory()
	local bags = {}
	inventory:update()
	for slot = 61, 240 do
		item = inventory.BagSlot[slot]
 	    if item.Available and  item.Name ~= "<EMPTY>" then
			table.insert(bags, {Name = item.Name, Id = item.Id, Rlevel = item.RequiredLvl, stats = item.Stats})
		end;
	end;
	table.print(bags)
end

function lisa_printskills()
	for k,v in pairs(settings.profile.skillsData) do table.print(v) end
end

function lisa_pawnlog(_name,_comment)
	local found = false
	local objectList = CObjectList();
	objectList:update();
	local objSize = objectList:size()
	filename = getExecutionPath() .. "/logs/pawnlog.txt";
	file, err = io.open(filename, "a+");
	if( not file ) then
		error(err, 0);
	end
	--_offset = 640
	_offset = 904 -- pawn attackable offset
	--repeat
	--_offset = _offset + 4
	if _name == nil then -- use target
		local target = player:getTarget()
		if target then
			found = true
			local flags = memoryReadRepeat("int", proc, target.Address + _offset) or 0;
			local bitnum=0x80000000
			local bitstring=""
			if bitAnd(flags,0x80000000) then
				file:write("Bits,1,")
			else
				file:write("Bits,0,")
			end
			
			repeat
				bitnum = bitnum / 2
				if bitAnd(flags,bitnum) then
					bitstring = bitstring .. "1,"
				else
					bitstring = bitstring .. "0,"
				end
			until bitnum == 1
			file:write(bitstring)
			if _comment ~= nil then 
				file:write(target.Name..",".._comment.."\n")
			else
				file:write(target.Name.." ".._offset.."\n\n")
			end	
		end
		file:close();
		return
	end	
		for i = 0,objSize do 
			obj = objectList:getObject(i);
			if _name == "mob" then
				--local pawn = CPawn(obj.Address)
				--if pawn. then
				if obj.Type == PT_MONSTER then
					found = true
					local flags = memoryReadRepeat("int", proc, obj.Address + _offset) or 0;
					local bitnum=0x80000000
					local bitstring=""
					if bitAnd(flags,0x80000000) then
						file:write("Bits,1,")
					else
						file:write("Bits,0,")
					end
					
					repeat
						bitnum = bitnum / 2
						if bitAnd(flags,bitnum) then
							bitstring = bitstring .. "1,"
						else
							bitstring = bitstring .. "0,"
						end
					until bitnum == 1
					file:write(bitstring)
					if _comment ~= nil then 
						file:write(obj.Name..",".._comment.."\n")
					else
						file:write(obj.Name.." ".._offset.."\n\n")
					end			
				end
			else
				if obj.Name == _name then -- edited out char name of course
					found = true
					local flags = memoryReadRepeat("int", proc, obj.Address + _offset) or 0;
					local bitnum=0x80000000
					local bitstring=""
					if bitAnd(flags,0x80000000) then
						file:write("Bits,1,")
					else
						file:write("Bits,0,")
					end
					
					repeat
						bitnum = bitnum / 2
						if bitAnd(flags,bitnum) then
							bitstring = bitstring .. "1,"
						else
							bitstring = bitstring .. "0,"
						end
					until bitnum == 1
					file:write(bitstring)
					if _comment ~= nil then 
						file:write(obj.Name..",".._comment.."\n")
					else
						file:write(obj.Name.." ".._offset.."\n\n")
					end
				end
			end
		end
	--until _offset == 764
	file:close();
	if found ~= true then printf("\n no such pawn name \n") end
end

function lisa_nearbypawnlog()
	player:update()
	filename = getExecutionPath() .. "/logs/pawnlog.txt";
	file, err = io.open(filename, "a+");
	if( not file ) then
		error(err, 0);
	end
	local tiime = os.time()
	local objectList = CObjectList();
	objectList:update();
	local objSize = objectList:size()	
	for i = 0,objSize do 
		obj = objectList:getObject(i);
		if 150 > distance(player.X,player.Z,obj.X,obj.Z) and obj.Name ~= player.Name and obj.Id ~= 121044 then
			file:write(obj.Name..obj.Id.."\n")
		end
	end
	yrest(1000)
	file:close();
end

function lisa_tester()
--=== version 2.0 ===--

-- /script local duration, remaining = GetExtraActionCooldown(1); SendSystemChat(remaining)

-- /script local icon = GetExtraActionInfo(2) SendSystemChat(icon)
--  thi12-2 		invisibility
--  thi_new35-1 	feign death
--  ran18-1 		snipe
--  kni15-2 		binding chains
-- _war24-2 		ghost cavalier transformation
-- thi_new45-4 		gass trap
-- drug_006			avure reguvination (full heal)
-- kni48-1			Protective Shield
-- telestep = true -- added code to teleport to make it step a little after each teleport

mapname = {
	[1]={ X=3342 , Z=3956, Y=7, Links={[1]={Num=2},}},
	[2]={ X=3392 , Z=3944, Y=7, Links={[1]={Num=1},[2]={Num=3},}},
	[3]={ X=3441 , Z=3933, Y=7, Links={[1]={Num=2},[2]={Num=4},}},
	[4]={ X=3489 , Z=3921, Y=7, Links={[1]={Num=3},[2]={Num=5},[3]={Num=26},}},
	[5]={ X=3538 , Z=3916, Y=7, Links={[1]={Num=4},[2]={Num=6},}},
	[6]={ X=3582 , Z=3931, Y=7, Links={[1]={Num=5},[2]={Num=7},}},
	[7]={ X=3608 , Z=3963, Y=7, Links={[1]={Num=6},[2]={Num=8},}},
	[8]={ X=3635 , Z=4010, Y=7, Links={[1]={Num=7},[2]={Num=9},}},
	[9]={ X=3654 , Z=4047, Y=7, Links={[1]={Num=8},[2]={Num=10},}},
	[10]={ X=3671 , Z=4090, Y=7, Links={[1]={Num=9},[2]={Num=11},}},
	[11]={ X=3693 , Z=4128, Y=7, Links={[1]={Num=10},[2]={Num=12},[3]={Num=24},}},
	[12]={ X=3706 , Z=4163, Y=7, Links={[1]={Num=11},[2]={Num=13},}},
	[13]={ X=3707 , Z=4202, Y=7, Links={[1]={Num=12},[2]={Num=14},}},
	[14]={ X=3697 , Z=4247, Y=7, Links={[1]={Num=13},[2]={Num=15},}},
	[15]={ X=3680 , Z=4297, Y=7, Links={[1]={Num=14},[2]={Num=16},}},
	[16]={ X=3664 , Z=4346, Y=7, Links={[1]={Num=15},[2]={Num=17},}},
	[17]={ X=4166 , Z=4415, Y=7, Links={[1]={Num=16},[2]={Num=18},[3]={Num=31},}},
	[18]={ X=4406 , Z=3929, Y=7, Links={[1]={Num=17},[2]={Num=19},[3]={Num=30},}},
	[19]={ X=4097 , Z=3378, Y=7, Links={[1]={Num=18},[2]={Num=20},[3]={Num=29},}},
	[20]={ X=3611 , Z=3421, Y=7, Links={[1]={Num=19},[2]={Num=21},[3]={Num=27},}},
	[21]={ X=3359 , Z=3778, Y=7, Links={[1]={Num=20},[2]={Num=22},[3]={Num=36},[4]={Num=26},}},
	[22]={ X=3329 , Z=3954, Y=7, Links={[1]={Num=21},[2]={Num=1},}},
	[23]={ X=4021 , Z=3944, Y=7, Links={[1]={Num=30},[2]={Num=35},[3]={Num=37},}},
	[24]={ X=3830 , Z=4094, Y=7, Links={[1]={Num=35},[2]={Num=32},[3]={Num=11},}},
	[25]={ X=3676 , Z=4124, Y=7, Links={}},
	[26]={ X=3506 , Z=3836, Y=7, Links={[1]={Num=21},[2]={Num=34},[3]={Num=4},}},
	[27]={ X=3681 , Z=3549, Y=7, Links={[1]={Num=34},[2]={Num=20},[3]={Num=28},}},
	[28]={ X=3827 , Z=3577, Y=7, Links={[1]={Num=33},[2]={Num=27},}},
	[29]={ X=4012 , Z=3551, Y=7, Links={[1]={Num=33},[2]={Num=30},[3]={Num=19},[4]={Num=37},}},
	[30]={ X=4169 , Z=3837, Y=7, Links={[1]={Num=29},[2]={Num=23},[3]={Num=18},[4]={Num=37},}},
	[31]={ X=4007 , Z=4128, Y=7, Links={[1]={Num=32},[2]={Num=17},}},
	[32]={ X=3873 , Z=4097, Y=7, Links={[1]={Num=24},[2]={Num=31},}},
	[33]={ X=3835 , Z=3629, Y=7, Links={[1]={Num=33},[2]={Num=28},[3]={Num=29},[4]={Num=34},[5]={Num=37},}},
	[34]={ X=3657 , Z=3728, Y=7, Links={[1]={Num=26},[2]={Num=27},[3]={Num=33},[4]={Num=35},[5]={Num=37},}},
	[35]={ X=3847 , Z=4029, Y=7, Links={[1]={Num=23},[2]={Num=34},[3]={Num=24},[4]={Num=37},}},
	[36]={ X=3062 , Z=3556, Y=7, Links={[1]={Num=21},}},
	[37]={ X=3890 , Z=3788, Y=7, Links={[1]={Num=23},[2]={Num=34},[3]={Num=33},[4]={Num=29},[5]={Num=30},[6]={Num=35},}},	
}
	
candles = {	
	[55]={ X=4021 , Z=3944, Y=88,  Links = {}},
	[56]={ X=3830 , Z=4094 ,Y=88,  Links = {}},
	[57]={ X=3676 , Z=4124 ,Y=88,  Links = {}},
	[58]={ X=3506 , Z=3836 ,Y=88,  Links = {}},
	[59]={ X=3681 , Z=3549 ,Y=88,  Links = {}},
	[60]={ X=3827 , Z=3577 ,Y=88,  Links = {}},
	[62]={ X=4012 , Z=3551 ,Y=88,  Links = {}},
	[63]={ X=4169 , Z=3837 ,Y=88,  Links = {}},
	[64]={ X=4007 , Z=4128 ,Y=88,  Links = {}},
	[65]={ X=3873 , Z=4097 ,Y=88,  Links = {}},
	[66]={ X=3835 , Z=3629 ,Y=88,  Links = {}},
	[67]={ X=3657 , Z=3728 ,Y=88,  Links = {}},
	[68]={ X=3847 , Z=4029 ,Y=88,  Links = {}},	
}

candlesearch = {[1] ={ X=3838, Z=4024, Y=7},[2] ={ X=4051, Z=3629, Y=7},[3] ={ X=3546, Z=3902, Y=7},[4] ={ X=4024, Z=4052, Y=7},}

	for k,v in pairs(settings.profile.skills) do
	      v.AutoUse = false
	end
	
local function travel(_dest,_move,_function)
	player:update()
	local path = {}
	if type(_dest) == "table" then -- _dest are coords
		if _dest.X ~= nil then
			dest = {_dest.X,_dest.Z,_dest.Y}
		else
			dest = _dest
		end
	end
	--=== determine location ===--
	local closest = 1;
	for i,v in pairs(mapname) do
		local oldClosestWp = mapname[closest];
		if v.Y == nil then
			if( distance(player.X, player.Z, oldClosestWp.X, oldClosestWp.Z) > distance(player.X, player.Z, v.X, v.Z) ) then
				closest = i;
			end		
		else
			if( distance(player.X, player.Z, player.Y, oldClosestWp.X, oldClosestWp.Z, oldClosestWp.Y) > distance(player.X, player.Z, player.Y, v.X, v.Z, v.Y) ) then
				closest = i;
			end
		end
		travellocation = closest
	end	

	--=== determine destination ===--
	local closest = 1;
	for i,v in pairs(mapname) do
		local oldClosestWp = mapname[closest];
		if v.Y == nil then
			if( distance(dest.X, dest.Z, oldClosestWp.X, oldClosestWp.Z) > distance(dest.X, dest.Z, v.X, v.Z)	) then
			closest = i;
			end
		else
			if( distance(dest[1], dest[2],dest[3], oldClosestWp.X, oldClosestWp.Z, oldClosestWp.Y) > distance(dest[1], dest[2],dest[3], v.X, v.Z, v.Y)	) then
			closest = i;
			end
		end
		traveldestination = closest
	end

	for pointnum,point in pairs(mapname) do
		for Num,link in pairs(point.Links) do
			if mapname[pointnum].Links[Num].dist == nil then
				mapname[pointnum].Links[Num].dist = distance(point.X, point.Z, mapname[Num].X, mapname[Num].Z)
			end
		end
	end

	local function findPath(_from, _val)

		-- initialize
		local dist = {} -- Current total distances to each point
		local previous = {} -- Current previous points that yield the shortest distance to those points
		local completed = {} -- points already checked and finished with
		local Q = {}-- queue of current points being worked on. Only the index numbers
		dist[_from] = 0
		Q[_from] = true

		local function getSmallestDist(_Q)
			-- Look for shortest path in Q
			local shortestdist = math.huge -- So we don't have to check for nil all the time
			local shortest
			for k,__ in pairs(_Q) do
				if shortestdist > dist[k] then
					shortestdist = dist[k]
					shortest = k
				end
			end

			return shortest
		end


		local destination_found = false
		while next(Q) ~= nil do -- not empty
			-- find point with shortest dist
			local currNum = getSmallestDist(Q)
			if currNum == nil then
				error("I think it finished without finding a path to the destination.")
			end
	if mapname[currNum]~= nil then -- This line is not needed. Added because of faulty database
			currPoint = table.copy(mapname[currNum])
			-- see if it's the destination
			if currNum == _val then
				destination_found = currNum
			end

			if destination_found then
				-- destination reached
				print("Destination found")
				break
			end

			-- bring in connected Links that aren't already completed
			for k,v in pairs(currPoint.Links) do
				if Q[v.Num] then -- Already in the Q. Update dist.
					local tmp = dist[currNum] + v.dist
					if  dist[v.Num] > tmp then
						dist[v.Num] = tmp
						previous[v.Num] = currNum
					end
				elseif not completed[v.Num] then -- add new point
					Q[v.Num] = true
					dist[v.Num] = dist[currNum] + v.dist
					previous[v.Num] = currNum
				end
			end
	end -- This line is not needed. Added because of faulty database
			-- pop from the Q.
			completed[currNum] = true
			Q[currNum] = nil
		end

		if next(Q) == nil then
			print("Didn't find path to destination.")
			player:sleep()
		end

		if destination_found then -- return path
			-- 'currNum' is the destination
			table.insert(path,{X=mapname[destination_found].X,Z=mapname[destination_found].Z,Y=mapname[destination_found].Y})
			while previous[destination_found] do
				destination_found = previous[destination_found]
				--table.insert(path,destination_found)
				table.insert(path,{X=mapname[destination_found].X,Z=mapname[destination_found].Z,Y=mapname[destination_found].Y})
			end
		end

	end	
	findPath(traveldestination,travellocation)
	fly()
	local count = #path
	for k,v in pairs(path) do
		--player:moveTo(CWaypoint(v.X,v.Z,v.Y),true,false,30)
		teleport(v.X,v.Z,v.Y,true)
		print(count..": points left to go before destination.")
		count = (count - 1)
	end
	print("Arrived at destination.")
end

--=== changing teleport settings
teleport_SetStepSize(50)
teleport_SetStepPause(800)

--[[
--=== for testing paths, before mobs spawn is best.
--=== must have model to remove the solid doors
travel({3835,4298,49})
travel({3842,3838,49})
travel({3847,3379,49})
travel({3842,3838,49})
travel({3437,4069,49})
travel({3842,3838,49})
travel({4240,3610,49})
travel({3842,3838,49})
travel({3444,3607,49})
travel({3842,3838,49})
travel({4245,4067,49})
]]

player:sleep()
end

function lisa_madman()
	if RoMScript("madman.Time") >= 1 then 
		player:clearTarget();
		printf("Running\n")
		yrest(4000)
	end
end

function lisa_monitorwhispers()
	function CheckWhispers()
		local time, moreToCome, name, msg = EventMonitorCheck("chwhispers", "4,1")
		if msg ~= nil then -- you got whispered
			print("been whispered")
		   local ResponseTable = {
			  [1] = "Sorry, got to go",
			  [2] = "Im just logging off, sorry.",
			  [3] = "My favourite show is about to start. See ya.",
			  [4] = "Daughter just got hurt I need to go sorry",
			  [5] = "Sorry mum is yelling I need to log",
			  [6] = "Dad said not to talk to anyone and now I have to go =(",
		   }
		   local gmreply = ResponseTable[math.random(#ResponseTable)]
		   sendMacro("SendChatMessage(\'"..gmreply.."\', 'WHISPER', 0, \'"..name.."\');");
			RoMScript("Logout();");
		   error("Logging out because you got whispered.")
		end
	end
	EventMonitorStart("chwhispers", "CHAT_MSG_WHISPER");
	registerTimer("checkwhispers", secondsToTimer(5),CheckWhispers);
end


function lisa_lovepet()
	EventMonitorStart("lovepet", "SYSTEM_MESSAGE");
	while(true) do 	
		local time, moreToCome, name = EventMonitorCheck("lovepet", "1")
		if name ~= nil and string.match(name,getTEXT("Sys107479_name")) then 
			yrest(1000)
			local objectList = CObjectList();
			objectList:update();
			local objSize = objectList:size()
			for i = 0,objSize do
				local obj = objectList:getObject(i);
				if obj.Id == 107479 then
					pawn = CPawn(obj.Address)
					if pawn.IsPet == player.Address then
						player:target(pawn)
						Attack()
						yrest(2000)
						--RoMScript("ChoiceOption(1)") -- this also works.
						ChoiceOptionByName(getTEXT("SC_LOVEPET_SPEAK2"))
						print("got something")
					end
				end
			end
		end
	end
end