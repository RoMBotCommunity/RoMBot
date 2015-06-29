-- Rock5's questlog class userfunction
--            version 0.06

-- If this is added to the bot, this userfunction will be bypassed
if not CQuestLog then

	IDTYPE_PLAYER = 0
	IDTYPE_MOB = 1
	IDTYPE_ITEM = 2 -- Inventory items
	IDTYPE_BUFF = 3
	IDTYPE_STAT = 5 -- eg. Dexterity I
	IDTYPE_QUEST = 7
	IDTYPE_TITLE = 8
	IDTYPE_TASK = 9 -- Quest goals that are tasks (not item or kill quests). For some reason skills Attack and Recall are also 9.
	IDTYPE_RECIPE = 10 -- Technically recipes are items. I don't know why they have different numbers.
	IDTYPE_RESOURCE = 11 -- wood, ore and herbs
	IDTYPE_NPC = 14 -- includes clickable objects
	IDTYPE_SET = 17 -- item sets
	IDTYPE_SKILL = 21

	local function checkAddresses()
		if not addresses.questLogBase then
			if addresses.high9sBase then
				addresses.questLogBase = addresses.high9sBase - 0x2E98
			else
				error("This version of questLogClass is for bot revision 743 or newer.", 0);
			end
		end
	end

	function getQuestBaseData(questId)
		local tmp = {}

		local address = GetItemAddress(questId)
		if address == nil or address == 0 then return end
		tmp.Id = questId
		tmp.BaseItemAddress = address
		tmp.Name = memoryReadStringPtr(getProc(), tmp.BaseItemAddress + addresses.nameOffset, 0 )
		tmp.Level = memoryReadUInt(getProc(), tmp.BaseItemAddress + 0xA0 )
		tmp.AcceptLevel = memoryReadUInt(getProc(), tmp.BaseItemAddress + 0xA4 )
		tmp.QuestGroup = memoryReadInt(getProc(), tmp.BaseItemAddress + addresses.questGroup_offset)

		-- Get quest givers
		tmp.QuestGiver = {}
		local i = 0
		local id
		repeat
			i = i + 1
			local id = memoryReadUInt(getProc(), tmp.BaseItemAddress + 0x540 + 0x4 * (i - 1))
			if id ~= 0 then
				tmp.QuestGiver[i] = {}
				tmp.QuestGiver[i].Id = id
				tmp.QuestGiver[i].Name = GetIdName(id)
			end
		until id == 0 or i == 10

		-- Get quest takers
		tmp.QuestTaker = {}
		id = memoryReadUInt(getProc(), tmp.BaseItemAddress  + 0x1D4)
		if id ~= 0 then
			tmp.QuestTaker.Id = id
			tmp.QuestTaker.Name = GetIdName(id)
		end

		-- Get goals that require items
		tmp.ItemGoals = {}
		i = 0
		repeat
			i = i + 1
			id = memoryReadUInt(getProc(), tmp.BaseItemAddress + 0x154 + 0x4 * (i - 1))
			if id ~= 0 then
				tmp.ItemGoals[i] = {}
				tmp.ItemGoals[i].Id = id
				local baseaddress = GetItemAddress(id)
				if baseaddress ~= 0 then
					tmp.ItemGoals[i].BaseItemAddress = baseaddress
					tmp.ItemGoals[i].Name = memoryReadStringPtr(getProc(), baseaddress + addresses.nameOffset, 0 )
					if tmp.ItemGoals[i].Name == null then
						printf("Goal ".. id .. " does not have a name")
					end
					tmp.ItemGoals[i].IdType = memoryReadUInt(getProc(), baseaddress + 4)
				else
					print("baseaddress",baseaddress)
					print("GetItemAddress(id)",GetItemAddress(id))
				end
				tmp.ItemGoals[i].NumReq = memoryReadUInt(getProc(), tmp.BaseItemAddress + 0x17C + 0x4 * (i - 1))
			end
		until id == 0 or i == 10

		-- Get goals that require tasks completed
		tmp.KillGoals = {}
		i = 0
		repeat
			i = i + 1
			id = memoryReadUInt(getProc(), tmp.BaseItemAddress + 0x1A4 + 0x4 * (i - 1))
			if id ~= 0 then
				tmp.KillGoals[i] = {}
				tmp.KillGoals[i].Id = id
				local baseaddress = GetItemAddress(id)
				if baseaddress ~= 0 then
					tmp.KillGoals[i].BaseItemAddress = baseaddress
					tmp.KillGoals[i].Name = memoryReadStringPtr(getProc(), baseaddress + addresses.nameOffset, 0 )
					if tmp.KillGoals[i].Name == null then
						printf("Goal ".. id .. " does not have a name")
					end
					tmp.KillGoals[i].IdType = memoryReadUInt(getProc(), baseaddress + 4)
				else
					print("baseaddress",baseaddress)
					print("GetItemAddress(id)",GetItemAddress(id))
				end
				tmp.KillGoals[i].NumReq = memoryReadUInt(getProc(), tmp.BaseItemAddress + 0x1B8 + 0x4 * (i - 1))
			end
		until id == 0 or i == 5

		return tmp
	end

	CQuest = class(
		function( self, index )
			self.Index = index
			self.Address = address
			self.Id = 0
			self.BaseItemAddress = nil;
			self.Name = ""
			self.Level = 0
			self.AcceptLevel = 0
			self.QuestGiver = {}
			self.QuestTaker = {}
			self.ItemGoals = {}
			self.KillGoals = {}
			self.QuestGroup = 0

			if ( self.Index ~= nil and self.Index ~= 0 ) then
				self:update()
			end
		end
	);

	function CQuest:update()
		if self.Index == nil or self.Index == 0 then
			return
		end

		if self.Address == nil or self.Address == 0 then
			self.Address = addresses.questLogBase + ((self.Index-1) * 0xC)
		end

		local tmpId = memoryReadUInt(getProc(), self.Address)
		if tmpId == self.Id then
			-- No change.
			return
		end

		self.Id = tmpId

		if self.Id == 0 then
			self.BaseItemAddress = nil;
			self.Name = ""
			self.Level = 0
			self.AcceptLevel = 0
			self.QuestGiver = {}
			self.QuestTaker = {}
			self.ItemGoals = {}
			self.KillGoals = {}
		else
			local baseData = getQuestBaseData(tmpId)
			for k,v in pairs(baseData) do
				self[k] = v
			end
		end
	end

	function CQuest:getKillCount(goal)
		goal = goal or 1
		if self.KillGoals[goal] then
			return memoryReadByte(getProc(), self.Address + 4 + goal)
		else
			print("No such kill goal.")
		end
	end

	function CQuest:getItemCount(goal)
		goal = goal or 1
		local goaldata = self.ItemGoals[goal]
		if goaldata then
			if goaldata.IdType == IDTYPE_ITEM then
				return inventory:itemTotalCount(goaldata.Id)
			else
				-- First get quest index
				local index = RoMScript("} local i,id = 0,nil repeat i = i + 1; id = GetQuestId(i); if id == "..self.Id.." then a = {i} break end until id == nil z={")
				if index then
					local __, count = RoMScript("GetQuestRequest("..index..","..goal..")")
					return count
				end
			end
		else
			print("No such item goal.")
		end
	end

	function CQuest:isComplete()
		-- First see if any itemgoals are not items
		-- Task type goals are also stored here.
		local useRoMScript = false
		for k,goal in pairs(self.ItemGoals) do
			if goal.IdType ~= IDTYPE_ITEM then
				useRoMScript = true
				break
			end
		end

		-- Now see if any kill goals are not mobs. Not sure if this is necessary but just to be sure.
		if useRoMScript == false then
			for k,goal in pairs(self.KillGoals) do
				if goal.IdType ~= IDTYPE_MOB then
					useRoMScript = true
					break
				end
			end
		end

		if useRoMScript then
			if (bot.IgfAddon == false) then
				error(language[1004], 0)	-- Ingamefunctions addon (igf) is not installed
			end
			if bot.IgfVersion and bot.IgfVersion > 3 then
				return (RoMScript("igf_questStatus("..self.Id..")") == "complete")
			else
				return (RoMScript("igf_questStatus("..self.Name..")") == "complete")
			end
		end


		-- Now go through ItemGoals and KillGoals and check each
		for k,goal in pairs(self.ItemGoals) do
			if inventory:itemTotalCount(goal.Id) < goal.NumReq then
				return false
			end
		end
		for k,goal in pairs(self.KillGoals) do
			if self:getKillCount(k) < goal.NumReq then
				return false
			end
		end

		return true
	end


	CQuestLog = class(
		function (self)
			self.Quest = {}

			for i = 1,30 do
				self.Quest[i] = CQuest()
				self.Quest[i].Index = i
			end
		end
	)

	function CQuestLog:update()
		checkAddresses()
		for i = 1,30 do
			if self.Quest[i].Address == nil then
				self.Quest[i].Address = addresses.questLogBase + ((i-1) * 0xC)
			end
			self.Quest[i].Index = i
			self.Quest[i]:update()
		end
	end

	function CQuestLog:questCount()
		self:update()
		local count = 0
		for i = 1,30 do
			if self.Quest[i].Id ~= 0 then
				count = count + 1
			end
		end

		return count
	end


	function CQuestLog:getQuest(nameorid, questgroup)
		self:update()
		for k,quest in pairs(self.Quest) do
			local matched

			if type(nameorid) == "number" then
				matched = (quest.Id == nameorid)
			else
				if string.find(nameorid,".",1,true) then -- Use Pattern Search
					matched = string.find(string.lower(quest.Name), string.lower(nameorid))
				else -- Use plain search
					matched = string.find(string.lower(quest.Name), string.lower(nameorid), 1, true)
				end
			end

			if matched then
				if questgroup == nil or questgroup == quest.QuestGroup then
					return quest
				end
			end
		end
	end

	function CQuestLog:haveQuest(nameorid, questgroup)
		return self:getQuest(nameorid, questgroup) ~= nil
	end

	questlog = CQuestLog()

	function getQuestStatus(nameorid, questgroup)
		local quest = questlog:getQuest(nameorid, questgroup)
		if quest == nil then
			return "not accepted"
		else
			if quest:isComplete() then
				return "complete"
			else
				return "incomplete"
			end
		end
	end
end
