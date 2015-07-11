
	local itemList	= {
		
		['mail::Runenbänker']	= {
			"^Lebenskraft [IVX]+$",
			"^Leid [IVX]+$",
			"^Magie [IVX]+$",
			"^Panzer [IVX]+$",
			"^Schlagkraft [IVX]+$",
			"^Schlag [IVX]+$",
			"^Schnelligkeit [IVX]+$",
			"^Unermüdlichkeit [IVX]+$",
			"^Verstand [IVX]+$",
			"^Verteidigung [IVX]+$",
			"^Widerstandskraft [IVX]+$",
		},
		
		['mail::Brisinga'] = {
			"200850::200855",	-- p-runen
			"^Rezeptur - ",
			"^Karte - ",
			"200480",					-- ananas
			"200489",					-- kopfsalat
			"200491",					-- sellerie
			"203428",					-- orientalische teeblätter
			"202916::202917",	-- gildenrune, gildenstein
			"203028",					-- Handwerksrezeptgutschein
			"203065",					-- erfahrungssphäre 1k
			"203276",					-- erfahrungssphäre 10k
			"203450",					-- rubinstein
			"203635",					-- Materialkiste für musikinstrumente
			"205817::205821",	-- beute des siegers, ???, hexerei-schriftrollen-sammelkiste, magisches instrument sammelkiste, kurzzeit-pferdemietschein
			"206261::206263",	-- glücksgras, goldene kornähre, sternperle
			"206590::206592",	-- zauberglücksgrashalm, sonnenuntergangskornähre, mondscheinperle
			"206695::206696",	-- erzessenz, holzessenz
			"207325::207330",	-- schreckensessenz, albtraumessenz, ???, ???, furchtloser kern, weisheitskern
			"207929::207930",	-- handgefertigter rubin, tränenrubin
		},
		
		['mail::Mainbänker'] = {
			"200609",					-- Bärenkrallen (TQ)
			"200624",					-- Keilerhauer (TQ)
			"203033",					-- pferdemietschein
		},
		
		['mail::Matsbänker'] = {
			"240410::240413",	-- dunkler wandelsternstein, ???, ???, palmenfaser
			"241463::241466",	-- stern der zwietracht, ???, ruite metallstein, ginkgofaser
			"242314::242325",	-- sirenenstern, zinnnagel, ???, grüne faser, lotusstern, ???, floyd-metallstein, buchenfaser
			"205690"					-- ehrenmedaille
		},
		
		['move::itemshop'] = {
			"201014",					-- reparaturhammer des meisters
			"202435",					-- trautes heim
			"202506",					-- goldener hammer
			"202903",					-- transportrune
			"202904",					-- portalrune
			"202905",					-- durchgangsrune
			"203784",					-- gildenburg-transportstein
		},
		
		['mail::Mainbänker']	= {
			"money::50000",
		},
		
		['use'] = {
			"202928::202930","208932","203487","203577","203578", -- all types of arcane charges
		},		
		
	}
	
	local mailboxes		= {
		['Stadtplatz']			= { CWaypoint ( 4747,-1971), CWaypoint ( 4580,-2160) },
		['Jammerförde']			= { CWaypoint (-9880, 2265) },
		['Heffnerlager']		= { CWaypoint (-6895,-3645), CWaypoint (-6900,-3835), CWaypoint (-7140,-3960) },
		['Silberfall']			= { CWaypoint (-5870,3290) },
		['Logar']						= { CWaypoint (-433, -5971) },
	}
	
	local function getPlayerName ()
		return asciiToUtf8_umlauts(convert_utf8_ascii(player.Name))
	end

	function cleanupBags ()
	
		local mail = nil
		
		function handle (cmd, para, search)
			local item,items
			repeat
				inventory:update ()
				_,items = inventory:findItem (search, 'bags', (type (search)~="number"))
				if items~=nil then 
					for _,item in pairs (items) do
						if cmd=='use' then for i=1,item.ItemCount do item:use () end end
						if cmd=='move' then item:moveTo (para) end
						if cmd=='mail' then
							if para==getPlayerName () then return end
							mail				= mail or {}
							mail[para]	= mail[para] or {}
							table.insert (mail[para], item.Id)
							items = nil
						end
print (' -> '..tostring(item.ItemCount)..'x '..tostring(item.Name)..' ('..tostring(item.Id)..') found')
					end
				end
			until items==nil
		end
		
		message ('cleanupBags ('..tostring(useMail)..')')
		
		for todo, list in pairs (itemList) do
			local cmd, para	= table.unpack (explode (todo, "::"))
			for _,entry in pairs(list) do
				if tonumber (entry)~=nil then 
					handle (cmd, para, tonumber (entry))
				elseif entry:find ('::') then
					local s, e = table.unpack (explode (entry, "::"))
					if tostring (tonumber (s))==s then
						for i=s, e do
							handle (cmd, para, i)
						end
					elseif s=='money' and para~=getPlayerName () and inventory.Money>tonumber(e)*1.5 then
						mail = mail or {}
						mail[para]	= -tonumber(e)
					end
				else
					handle (cmd, para, entry)
				end
			end
		end
		
		if mail~=nil then
print (getZoneLocalName ()..' - '..getZoneName ()..' - '..tostring(mailboxes[zName]))
			local zName		= getZoneName ()
			if mailboxes[zName]==nil then 
				zName 			= getZoneLocalName ()
			end
			if mailboxes[zName]~=nil then
				message (' -> going to mailbox')
				smartMove (mailboxes[zName])
				for receiver, list in pairs (mail) do
					if type(list)=='number' and list<0 then
						UMM_SendMoney(receiver, inventory.Money+list)
					else
						UMM_SendByNameOrId (receiver, list) 
					end
				end
				smartMoveReverse (mailboxes[zName]) 
			end
		end
	end
