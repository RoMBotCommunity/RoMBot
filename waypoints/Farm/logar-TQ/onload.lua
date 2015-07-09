
		mailreceipient = "Mainbänker"					-- where to send collected items to
		
		itemsToCollect = {										-- use lootomatic for fine tuning!
			200609,															-- bärenkrallen
			200624,															-- keilerhauer
			202916,															-- gildenrune
			200854,															-- reinigungsrunen
		}
		
		requiredItems = {
			201843,  														-- bag lvl1
			201844,  241254,  									-- bag lvl2
			201845,  205931,  241255,  					-- bag lvl3
			201846,  205932,  241256,  					-- bag lvl4
			201847,  205933,  241257,  					-- bag lvl5
			201848,  205934,  241258,  					-- bag lvl6 
			201849,  205935,  241259,  					-- bag lvl7
			201850,  205936,  241260,  					-- bag lvl8
			201851,  205937,  241261,  					-- bag lvl9
			201852,  205938,  241262,  					-- bag lvl10
			201853,  														-- bag lvl11
			201854,  														-- bag lvl12
			201855,  														-- bag lvl13
			201856,  														-- bag lvl14
			201857,  														-- bag lvl15
			201858,  														-- bag lvl16
			201859,  														-- bag lvl17
			201860,  														-- bag lvl18
			201861,  														-- bag lvl19
			201862,  														-- bag lvl20
			201883,  														-- bag lvl25										
			200663,200664,200807,               -- heal potion
			201042,201043,201046,								-- mana potion
			210294,															-- stones
		}
		
		function checkBag ()
			for _,id in pairs (itemsToCollect) do
				local item = inventory:findItem (id, 'bag1')
				if item then item:moveTo ('bag2') end
			end
			for _,id in pairs (requiredItems) do
				local item = inventory:findItem (id, 'bag1')
				if item then item:moveTo ('bag2') end
			end
		end
		
		function mailCheck ()
			if player.freeFlag1 then return true end
			for _,id in pairs (itemsToCollect) do
				local item = inventory:findItem (id)
				if item then return true end
			end
			return false
		end
		
		function isBagFull ()
			if player.freeFlag1 then return true end
			return (inventory:itemTotalCount (0, 'bag1')==0)
		end
		
		function isLowLevel (secondClass)
			if secondClass==true then return (player.Level2<10)
			else											return (player.Level<10) end
		end
		
		function isMaxLevel (secondClass)
			if secondClass==true then return (player.Level2>12)
			else											return (player.Level>12) end
		end
		
		function isNewChar ()
			return (player.Level==1 and player.Level2==0)
		end
		
		function MyOnLevelup ()
			openGiftbags1To10(player.Level)
			levelupSkills1To10(player.Level)
		end
		
		function MyOnLeaveCombat ()
      player:lootAll ()
      clearAndEquipChar (false)
      checkBag ()
		end
		
		function MyOnSkillCast ()
		end
		
		function stopWander ()
			settings.profile.mobs 		= {"nobody"}
			changeProfileOption ("PATH_TYPE", 			'waypoints')
			changeProfileOption ("WANDER_RADIUS", 	0)
			changeProfileOption ("MAX_TARGET_DIST", 0)
			__WPL:setForcedWaypointType ('TRAVEL')
			player:mount ()
		end
		
		local pidFile 		= getExecutionPath ()..'/lastfile.pid'
		local currentFile = getFileName (__WPL.FileName):gsub ('.xml', '')
		
		function saveLastFile (file)
			local lastFile	= getFileName (file):gsub ('.xml', '')
			table.save ({['lastFile'] = lastFile}, pidFile)
		end
		
		stopWander ()
		changeProfileOption('HEALING_POTION', (isLowLevel () and 50) or 99)
		changeProfileOption('MANA_POTION', 		(isLowLevel () and 50) or 99)
		
		local file = table.load (pidFile)
		if file~=nil and type(file)=='table' and file.lastFile~=nil then
			if file.lastFile~=currentFile and not isNewChar () then
				loadPaths (getExecutionPath ()..'/'..file.lastFile)
			end
		end

