--================================
-- Rock5's 'travelTo' userfunction
-- Version 3.14
-- Works with Game Version 6.0.0
--
-- Thanks go to noobbotter for the work he did on 'worldtraveler' userfunction,
--     the inspiration for this work, and anyone who contributed to it.

-----------------------------------------------------------
--========== TABLES THAT NEED TO BE MAINTAINED ==========--

-- The node list is a list of npcs, mostly teleports, and the links between them, represented by the 'ConnectsTo' argument.
-- Each ConnectsTo entry is the nodeList name it connects to.
-- If the connection is a teleport then it also requires the optionString name it will choose in the npc dialog unless the name of the node and string are the same.
--   Eg. To teleport to Varanas from a teleporter that uses the "Varanas" name you can just use "Varanas" in the ConnectsTo arg.
--       For teleporters that use "Silverspring" instead you would use "Varanas,Silverspring".
local nodeList = {
	-- Hub nodes should be first because we know for sure if they are available or not.
	Varanas                  = {Zone=2, Npc={Id=111256, X=2307, Z=1152, Y=0}, ConnectsTo={"VaranasBridge","Obsidian","Logar","Yrvandis","Haven","Rorazan","Heffner","Silverfall","HarfTradingPost","Reifort","AbandonedFortress","Boulderwind","GreenTower","Dimarka","AyrenCaravan","Lyk","WailingFjord"}},
	AyrenCaravan             = {Zone=10, Npc={Id=111256, X=-38733, Z=1545, Y=1}, ConnectsTo={"Lyk","Obsidian","Reifort"}},
	Obsidian                 = {Zone=6, Npc={Id=111256, X=-20458, Z=6519, Y=-188}, ConnectsTo={"BattleSquare","Varanas","Logar","Heffner","AyrenCaravan","Lyk","Reifort","Silverfall","HarfTradingPost","AbandonedFortress","Boulderwind","GreenTower","Dimarka","WailingFjord"}},
	Dalanis                  = {Zone=15, Npc={Id=114353, X=-4282, Z=5088, Y=7}, ConnectsTo={"Rorazan","DoD","DalanisObsidianEnvoy","SouthernJanost","NorthernJanost","Limon","Kampel","Fireboot","TergothenBay","WailingFjord"}},
	Rorazan                  = {Zone=22, Npc={Id=118219, X=-20708, Z=-22750, Y=564}, ConnectsTo={"Varanas","Obsidian","Dalanis,Thunderhoof","Chrysalia","Tundra","Syrbal","Sarlo","WailingFjord","DemostrationBattle"}},
	
	Logar                    = {Zone=1, Npc={Id=111256, X=-1163, Z=-5535, Y=36}, ConnectsTo={"Varanas","LogarHousemaid"}},
	VaranasBridge            = {Zone=2, Npc={Id=110755, X=2767, Z=956, Y=54}, ConnectsTo={"Varanas","VaranasWisdom","VaranasGuildHall","VaranasCentral","VaranasEast","VaranasWest","VaranasClassHall"}},
	VaranasWest              = {Zone=2, Npc={Id=110728, X=2900, Z=-800, Y=57}, ConnectsTo={"VaranasBridge","VaranasWisdom","VaranasGuildHall","VaranasCentral","VaranasEast","VaranasClassHall","VaranasCastleWest"}},
	VaranasCastleWest        = {Zone=2, Npc={Id=111621, X=2497, Z=-1392, Y=53}, ConnectsTo={"VaranasWest"}},
	VaranasClassHall         = {Zone=2, Npc={Id=110922, X=5271, Z=-3896, Y=60}, ConnectsTo={"VaranasBridge","VaranasWisdom","VaranasGuildHall","VaranasCentral","VaranasEast","VaranasWest",}},
	VaranasEast              = {Zone=2, Npc={Id=110727, X=4475, Z=-39, Y=52}, ConnectsTo={"VaranasBridge","VaranasWisdom","VaranasGuildHall","VaranasCentral","VaranasWest","VaranasClassHall","VaranasCastleEast"}},
	VaranasCastleEast        = {Zone=2, Npc={Id=111621, X=4992, Z=300, Y=53}, ConnectsTo={"VaranasEast"}},
	VaranasCentral           = {Zone=2, Npc={Id=110726, X=4747, Z=-1971, Y=115}, ConnectsTo={"VaranasBridge","VaranasWisdom","VaranasGuildHall","VaranasEast","VaranasWest","VaranasClassHall"}},
	VaranasGuildHall         = {Zone=2, Npc={Id=110561, X=6364, Z=-3104, Y=60}, ConnectsTo={"VaranasBridge","VaranasWisdom","VaranasCentral","VaranasEast","VaranasWest","VaranasClassHall"}},
	VaranasWisdom            = {Zone=2, Npc={Id=111339, X=6929, Z=-2491, Y=58}, ConnectsTo={"VaranasBridge","VaranasGuildHall","VaranasCentral","VaranasEast","VaranasWest","VaranasClassHall"}},
	Silverfall               = {Zone=4, Npc={Id=111256, X=-5913, Z=2867, Y=598}, ConnectsTo={"Varanas","HarfTradingPost","GoblinMines"}},
	HarfTradingPost          = {Zone=5, Npc={Id=111256, X=-14459, Z=-150, Y=755}, ConnectsTo={"Silverfall","Obsidian","Lyk"}},
	Lyk                      = {Zone=11, Npc={Id=111256, X=-29438, Z=-17657, Y=250}, ConnectsTo={"HarfTradingPost","AyrenCaravan"}},
	Reifort                  = {Zone=10, Npc={Id=118586, X=-29471, Z=1190, Y=-544}, ConnectsTo={"Varanas","Obsidian","AyrenCaravan"}},
	BattleSquare             = {Zone=6, Npc={Id=110530, X=-20782, Z=6214, Y=-226}, ConnectsTo={"Obsidian","MercenarySquare","CraftingSquare","GlorySquare","TradeSquare"}},
	TradeSquare              = {Zone=6, Npc={Id=110944, X=-22819, Z=2679, Y=-179}, ConnectsTo={"BattleSquare","MercenarySquare","CraftingSquare","GlorySquare"}},
	GlorySquare              = {Zone=6, Npc={Id=110805, X=-23203, Z=4489, Y=-260}, ConnectsTo={"BattleSquare","MercenarySquare","CraftingSquare","TradeSquare"}},
	CraftingSquare           = {Zone=6, Npc={Id=110532, X=-23631, Z=5814, Y=-260}, ConnectsTo={"BattleSquare","MercenarySquare","GlorySquare","TradeSquare","ObsidianCastle","ObsidianHousemaid"}},
	ObsidianCastle           = {Zone=6, Npc={Id=111731, X=-22152, Z=6465, Y=-179}, ConnectsTo={"CraftingSquare"}},
	ObsidianHousemaid        = {Zone=6, Npc={Id=111251, X=-23631, Z=5814, Y=-262}, ConnectsTo={"CraftingSquare"}},
	MercenarySquare          = {Zone=6, Npc={Id=110531, X=-22001, Z=3636, Y=-179}, ConnectsTo={"BattleSquare","CraftingSquare","GlorySquare","TradeSquare","ObsidianDalanisEnvoy"}},
	ObsidianDalanisEnvoy     = {Zone=6, Npc={Id=114777, X=-20597, Z=4183, Y=-172}, ConnectsTo={"DalanisObsidianEnvoy","MercenarySquare"}},
	AbandonedFortress        = {Zone=3, Npc={Id=111256, X=13868, Z=6768, Y=27}, ConnectsTo={"Varanas","Boulderwind"}},
	Boulderwind              = {Zone=7, Npc={Id=111256, X=19647, Z=21909, Y=10}, ConnectsTo={"AbandonedFortress","GreenTower"}},
	GreenTower               = {Zone=8, Npc={Id=111256, X=5939, Z=20618, Y=219}, ConnectsTo={"Boulderwind","Dimarka"}},
	Dimarka                  = {Zone=9, Npc={Id=111256, X=-11317, Z=26312, Y=972}, ConnectsTo={"GreenTower"}},
	DalanisObsidianEnvoy     = {Zone=15, Npc={Id=114776, X=-4672, Z=7595, Y=107}, ConnectsTo={"Dalanis","ObsidianDalanisEnvoy","DoD"}},
	SouthernJanost           = {Zone=16, Npc={Id=114353, X=-6017, Z=21630, Y=-148}, ConnectsTo={"Dalanis","NorthernJanost"}},
	NorthernJanost           = {Zone=17, Npc={Id=114353, X=3563, Z=31618, Y=112}, ConnectsTo={"SouthernJanost","Limon"}},
	Limon                    = {Zone=18, Npc={Id=114353, X=3074, Z=47621, Y=84}, ConnectsTo={"NorthernJanost","Kampel"}},
	Kampel                   = {Zone=19, Npc={Id=114353, X=-2893, Z=49657, Y=118}, ConnectsTo={"Limon","Fireboot"}},
	Fireboot                 = {Zone=20, Npc={Id=114353, X=-16459, Z=41043, Y=610}, ConnectsTo={"Kampel","TergothenBay"}},
	TergothenBay             = {Zone=21, Npc={Id=114353, X=-26309, Z=29777, Y=-98}, ConnectsTo={"Fireboot"}},
	Heffner                  = {Zone=13, Npc={Id=118002, X=-6336, Z=-3913, Y=162}, ConnectsTo={"Varanas,Silverspring","Lyonsyde","DesertInvestigation","FangersMakeshift","RuinsResearch","Jinners","Frontline","HeffnerHousemaid"}},
	Lyonsyde                 = {Zone=13, Npc={Id=118020, X=50, Z=-1137, Y=137}, ConnectsTo={"Heffner","DesertInvestigation","FangersMakeshift","RuinsResearch","Jinners","Frontline"}},
	DesertInvestigation      = {Zone=13, Npc={Id=118020, X=-7413, Z=1191, Y=615}, ConnectsTo={"Heffner","Lyonsyde","FangersMakeshift","RuinsResearch","Jinners","Frontline"}},
	FangersMakeshift         = {Zone=13, Npc={Id=118020, X=2, Z=5036, Y=686}, ConnectsTo={"Heffner","Lyonsyde","DesertInvestigation","RuinsResearch","Jinners","Frontline"}},
	RuinsResearch            = {Zone=14, Npc={Id=118002, X=989, Z=13370, Y=326}, ConnectsTo={"Varanas,Silverspring","Heffner","Lyonsyde","DesertInvestigation","FangersMakeshift","Jinners","Frontline"}},
	Jinners                  = {Zone=14, Npc={Id=118020, X=12879, Z=1939, Y=52}, ConnectsTo={"Heffner","Lyonsyde","DesertInvestigation","FangersMakeshift","RuinsResearch","Frontline"}},
	Frontline                = {Zone=14, Npc={Id=118020, X=6777, Z=6312, Y=92}, ConnectsTo={"Heffner","Lyonsyde","DesertInvestigation","FangersMakeshift","RuinsResearch","Jinners","Butterflies"}},
	Yrvandis                 = {Zone=31, Npc={Id=111256, X=2270, Z=-409, Y=1554}, ConnectsTo={"Varanas"}},
	Haven                    = {Zone=12, Npc={Id=111256, X=28492, Z=3465, Y=312}, ConnectsTo={"Varanas"}},
	Chrysalia                = {Zone=23, Npc={Id=120413, X=-7794, Z=-16589, Y=718}, ConnectsTo={"Rorazan","Tundra"}},
	Tundra                   = {Zone=24, Npc={Id=118219, X=3843, Z=-7737, Y=448}, ConnectsTo={"Chrysalia","Syrbal","TundraHousemaid"}},
	Syrbal                   = {Zone=25, Npc={Id=118219, X=-6556, Z=-7719, Y=1463}, ConnectsTo={"Tundra","Sarlo"}},
	Sarlo                    = {Zone=26, Npc={Id=118219, X=-17874, Z=-3329, Y=804}, ConnectsTo={"Syrbal"}},
	WailingFjord             = {Zone=27, Npc={Id=118219, X=-9174, Z=3061, Y=19}, ConnectsTo={"Varanas","Obsidian","Dalanis,Thunderhoof","Rorazan","Hortek","WailingFjordHousemaid"}},
	Hortek                   = {Zone=28, Npc={Id=123262, X=2587, Z=24618, Y=146}, ConnectsTo={"WailingFjord","Salioca"}},
	Salioca                  = {Zone=29, Npc={Id=123262, X=7054, Z=22694, Y=11}, ConnectsTo={"Hortek","Kashaylan"}},
	Kashaylan                = {Zone=30, Npc={Id=123262, X=19298, Z=34933, Y=45}, ConnectsTo={"Salioca","HoviksCamp"}},
	HoviksCamp               = {Zone=30, Npc={Id=123542, X=19494, Z=34794, Y=67}, ConnectsTo={"SabanosCamp","HiddenCamp","Kashaylan"}},
	SabanosCamp              = {Zone=30, Npc={Id=123542, X=21057, Z=38119, Y=370}, ConnectsTo={"HiddenCamp","HoviksCamp"}},
	HiddenCamp               = {Zone=30, Npc={Id=123542, X=16462, Z=44897, Y=39}, ConnectsTo={"SabanosCamp","HoviksCamp"}},

	Butterflies              = {Zone=14, Npc={Id=118072, X=6424, Z=5432, Y=155}, ConnectsTo={"Frontline"}},
	DoD                      = {Zone=209, Npc={Id=115571, X=1656, Z=-4903, Y=772}, ConnectsTo={"Dalanis","DalanisObsidianEnvoy"}},
	DemostrationBattle       = {Zone=22, Npc={Id=119856, X=-18361, Z=-22709, Y=496}, ConnectsTo={"Rorazan"}},
	GoblinMines              = {Zone=4, Npc={Id=112651, X=-5873, Z=3315, Y=572}, ConnectsTo={"Silverfall"}},

	TundraHousemaid          = {Zone=24, Npc={Id=121272, X=4112, Z=-8503, Y=448}, ConnectsTo={"Tundra"}},
	LogarHousemaid           = {Zone=1, Npc={Id=110773, X=-433, Z=-5971, Y=36}, ConnectsTo={"Logar"}},
	HarfTradingPostHousemaid = {Zone=5, Npc={Id=111253, X=-13872, Z=-62, Y=802}, ConnectsTo={"HarfTradingPost"}},
	HeffnerHousemaid				 = {Zone=13, Npc={Id=118002, X=-6948, Z=-3652, Y=162}, ConnectsTo={"Heffner"}},
	WailingFjordHousemaid    = {Zone=27, Npc={Id=123003, X=-9428, Z=2619, Y=56}, ConnectsTo={"WailingFjord"}},
}

-- The optionString list is a list of strings that match the options that need to be selected to go to the desired destination.
-- Preferably the main string used to go to the nodes above should match to simplify filling in the 'ConnectsTo' values above.
-- Nodes that aren't teleported to, eg. DoD, Butterflies and GoblinMines, don't need strings but strings are still required
--    for all nodes to avoid quality control errors. Just add them to the end of the list.
local optionString = {
	Logar = "ZONE_ROGSHIRE",
	Rorazan = "ZONE_Z22_OLD_ROJAN_KINGDOM",
	Chrysalia = "ZONE_Z23_QUESLANA",
	Tundra = "ZONE_Z24_MERDIN_TUNDRA",
	Heffner = "ZONE_HARFEN_CAMP",
	Obsidian = "ZONE_OBSIDIAN BASTION",
	AbandonedFortress = "ZONE_DUST HOLD",
	Reifort = "ZONE_REIFORT POINT",
	Silverfall = "ZONE_ARGENFALL",
	VaranasClassHall = "ZONE_VARANAS_CLASS_HALL",
	VaranasWest = "ZONE_VARANAS WEST WING",
	VaranasBridge = "SO_110561_10",
	VaranasWisdom = "SC_111339_12",
	VaranasGuildHall = "SO_110561_6",
	VaranasCentral = "ZONE_VARANAS CENTRAL SQUARE",
	VaranasEast = "ZONE_VARANAS EAST WING",
	Varanas = "ZONE_VARANAS",
	VaranasBridgePreoption = "SO_110561_12",
	Silverspring = "ZONE_SILVERSPRING",
	HarfTradingPost = "ZONE_HAROLFE TRADING POST",
	Lyk = "ZONE_LAGO",
	AyrenCaravan = "ZONE_AYEN CARAVAN",
	MercenarySquare = "SO_110944_8",
	CraftingSquare = "SO_110944_7",
	GlorySquare = "SO_110944_3",
	TradeSquare = "SO_110944_2",
	BattleSquare = "SO_110944_6",
	DalanisObsidianEnvoy = "SC_114777_1",
	Boulderwind = "ZONE_BOULDERWIND",
	GreenTower = "ZONE_THE GREEN TOWER",
	Dimarka = "ZONE_DIMARKA",
	ObsidianDalanisEnvoy = "SC_114776_0",
	SouthernJanost = "ZONE_SOUTH_JENOTAR_FOREST",
	NorthernJanost = "ZONE_NORTHERN_JANOST_FOREST",
	Dalanis = "ZONE_DAELANIS",
	Limon = "ZONE_LYMUN_KINGDOM",
	Kampel = "ZONE_CAMPBELL_TOWNSHIP",
	Fireboot = "ZONE_FIREBOOT_DWARF_FORTRESS",
	TergothenBay = "ZONE_TORAGG_CARAVAN",
	Lyonsyde = "ZONE_LANZERD_HORDE",
	DesertInvestigation = "ZONE_WILDERNESS_RESEARCH_CAMP",
	FangersMakeshift = "ZONE_TEMPORARY_FANGT_CAMP",
	Jinners = "ZONE_JINNERS_CAMP",
	RuinsResearch = "ZONE_RUINS_TESTING_CAMP",
	Frontline = "ZONE_FRONT_LINES_CAMP",
	Thunderhoof = "ZONE_THUNDERHOOF_MESA",
	Yrvandis  = "ZONE_Z31_IFANTRISH_CRYPT",
	Haven = "ZONE_STONES FURLOUGH",
	intosewer = "SC_115531_1",
	outofsewer = "SC_115531_1",
	Syrbal = "ZONE_Z25_SERBAYT_PASS",
	Sarlo = "ZONE_Z26_ZHYRO",
	WailingFjord = "ZONE_Z27_WAILING_FJORD",
	Hortek = "ZONE_Z28_HURTEKKE_JUNGLE",
	Salioca = "ZONE_Z29_XADIA_BASIN",
	Kashaylan = "ZONE_Z30_KATHALAN",
	HoviksCamp = "ZONE_ALLRIC_GARRISON",
	HiddenCamp = "ZONE_UNKNOWN_VILLAGE_01",
	SabanosCamp = "ZONE_SAABARIO_GARRISON",

	-- The below locations can't be teleported to so don't need strings but are included to avoid errors during quality control.
	DoD = "DoD",
	GoblinMines = "GoblinMines",
	Butterflies = "Butterflies",
	DemostrationBattle = "DemostrationBattle",
	
	VaranasCastleWest = "VaranasCastleWest",
	VaranasCastleEast = "VaranasCastleEast",
	ObsidianCastle = "ObsidianCastle",
	ObsidianHousemaid = "ObsidianHousemaid",
	LogarHousemaid = "LogarHousemaid",
	HeffnerHousemaid = "HeffnerHousemaid",
	TundraHousemaid = "TundraHousemaid",
	WailingFjordHousemaid = "WailingFjordHousemaid",
}

-- This is a list of nodes that are hubs for going to different locations.
-- If a hub hasn't been visited (which it checks in memory using the offset and bit) it will try to find another path.
-- AutoLinkFrom are lists of nodes that link to the hub even if the hub hasn't been visited yet.
--       They include auto links such a Reifort to Ayren and walking links such as Battle Square to Obsidian Snoop.
-- There are a couple of functions in the 'HELPER FUNCTIONS' section, for finding Offsets and Bits, if a new hub needs to be added.

local hubList = {
   Varanas = {Offset=0x0, Bit=4, AutoLinkFrom={"VaranasBridge","Heffner"}},
   Rorazan = {Offset=0x261, Bit=32},
   Obsidian = {Offset=0x0, Bit=32, AutoLinkFrom={"Reifort","BattleSquare"}},
   Dalanis = {Offset=0x12B, Bit=1, AutoLinkFrom={"DalanisObsidianEnvoy","DoD"}},
   AyrenCaravan = {Offset=0x0, Bit=64, AutoLinkFrom={"Reifort"}}, -- Added because it adds an alternate route to Lyk
   WailingFjord = {Offset=0x373, Bit=16},
}
----------------------------------------
--========== STARTUP CHECKS ==========--

-- Check requirements
if not NPCTeleport then
	error("This userfunction requires Rock5's 'gotoportal' userfunction which can be downloaded here.\n http://www.solarstrike.net/phpBB3/viewtopic.php?p=37916#p37916")
end

-- Check table values
local invalidConnection = false
for from, node in pairs(nodeList) do
	-- Check connections and options
	for __, connection in pairs(node.ConnectsTo) do
		local neighbor, option = string.match(connection,"([%a%d]*)[^%a%d]*([%a%d]*)")
		if not nodeList[neighbor] then
			printf("Undefined destination '%s' in node %s.\n",neighbor,from)
			invalidConnection = true
		end
		if option == "" then option = neighbor end
		if not optionString[option] then
			printf("Undefined option string '%s' in node %s\n", option, from)
			invalidConnection = true
		end
	end
	-- Check Npc
	if not node.Npc or not node.Npc.Id or not node.Npc.X or not node.Npc.Z or not node.Npc.Y then
		printf("Incorrect Npc information provided for node %s\n", from)
		invalidConnection = true
	end
	-- Check Zone
	if not node.Zone then
		printf("Zone id missing in node %s\n", from)
		invalidConnection = true
	end
end
if invalidConnection then
	error("Please repair the connections.")
end

------------------------------------------
--========== HELPER FUNCTIONS ==========--

-- Returns true if links is available, false if not.
local function linkIsEnabled(fromNode, toHub)
	-- Check for diabled hub
	local baseAddress = memoryReadInt(getProc(), addresses.playerCraftLevelBase + 0x1C ) + 0x698
	-- If not a hub, enabled
	if not hubList[toHub] then
		return true
	end

	-- If visited, enabled
	local byte = memoryReadUInt(getProc(),baseAddress + hubList[toHub].Offset)
	if bit32.btest(byte,hubList[toHub].Bit) then
		return true
	end

	-- If link is always available then enabled
	if hubList[toHub].AutoLinkFrom then
		for __, link in pairs(hubList[toHub].AutoLinkFrom) do
			if link == fromNode then
				return true
			end
		end
	end

	-- Trying to link to unvisited hub with no auto link from 'fromNode'
	return false
end

-- Returns table with shortest path.
local function Dijkstra(start, finish)
	--Create a closed and open set
	local open = {}
	local closed = {}

	--Attach data to all noded without modifying them
	local data = {}
	for node in pairs(nodeList) do
		data[node] = {
			distance = math.huge,
			previous = nil
		}
	end

	--The start node has a distance of 0, and starts in the open set
	open[start] = true
	data[start].distance = 0

	while true do
		--pick the nearest open node
		local best = nil
		for node in pairs(open) do
			if not best or data[node].distance < data[best].distance then
				best = node
			end
		end
		--at the finish - stop looking
		if best == finish then break end

		--all nodes traversed - finish not found! No connection between start and finish
		if not best then return end

		--calculate a new score for each neighbors
		for from, node in pairs(nodeList[best].ConnectsTo) do
			local neighbor = string.match(node,"[%a%d]*")
			--provided it's not already in the closed set
			if not closed[neighbor] and linkIsEnabled(best, neighbor) then
				local newdist = data[best].distance + 1
				if newdist < data[neighbor].distance then
					data[neighbor].distance = newdist
					data[neighbor].previous = best
					open[neighbor] = true
				end
			end
		end

		--move the node to the closed set
		closed[best] = true
		open[best] = nil
	end

	--walk backwards to reconstruct the path
	local path = {}
	local at = finish
	while at ~= start do
		table.insert(path, 1, at)
		at = data[at].previous
	end

	return path
end

-- Function that converts strings and takes all steps to teleport
local function targetNpcAndTeleport(npcId, option, preoption)
	local npcName = GetIdName(npcId)
	local optiontext = getTEXT(optionString[option])
	local preoptiontext = getTEXT(optionString[preoption])
	if optiontext == nil then
		error("Invalid string option names: "..(option or "nil") .. " " .. (preoption or ""))
	end

	-- Find Npc
	local Npc = player:findNearestNameOrId(npcName)

	if not Npc then
		error("Can't find Npc "..npcName)
	end

	-- Move closer if necessary
	if distance(player,Npc) > 50 then
		player:moveInRange(Npc, 50, true)
		yrest(400)
	end

	-- Target Npc and teleport
	if NPCTeleport(npcName, optiontext, preoptiontext) == false then
		-- Try again
		yrest(3000)
		player:update()
		if NPCTeleport(npcName, optiontext, preoptiontext) == false then
			error("Unable to teleport to "..optiontext)
		end
	end
	yrest(2000)
	player:update()
end

-- If a new hub needs to be added, eg. if a new continent is added, the following 2 functions can be used to find the
--      'Offset' and 'Bit' needed for the hubList entry.
-- Just run 'readPorts()' from the commandline BEFORE the first time you open the teleporter dialog, then run 'comparePorts' afterwards.
--      It should print the offset and bit. If there is more than 1 result, the first result should be the correct one.
local portdata
function readPorts()
	portdata = {}
	local proc = getProc()
	local address = memoryReadInt(proc, addresses.playerCraftLevelBase + 0x1C ) + 0x698
	portdata = {}
	for c = 1, 0x2000 do
		portdata[c] = memoryReadUByte(proc, address + (c-1))
	end
end
function comparePorts()
	local proc = getProc()
	local address = memoryReadInt(proc, addresses.playerCraftLevelBase + 0x1C ) + 0x698
	printf("\nBase address is 0x%X\n",address)
	printf("Location: Zone %d, LocalName \"%s\"\n", RoMScript("GetZoneID(),GetZoneName()"))
	for c = 1, 0x2000 do
		local tmp = memoryReadUByte(proc, address + (c-1))
		if tmp ~= portdata[c] then
			printf("\tOffset: 0x%X, Bit: %d\n", (c-1),tmp-portdata[c])
		end
	end
	printf("\n")
end

---------------------------------------
--========== MAIN FUNCTION ==========--

function travelToAddNode(name, zone, npcId, npcX, npxZ, npcY, connectsTo)
	nodeList[name] = {Zone=zone, Npc={Id = npcId, X=npcX, Z=npcZ, Y=npcY or 1}, ConnectsTo=connectsTo or {}}
end

function travelToAddDestination (nodeName, dests, option)
	if type (dest) == "table" then
		for k,v in pairs (dests) do
			table.insert(nodeList[nodeName].ConnectsTo, v)
		end
	else
		table.insert (nodeList[nodeName].ConnectsTo, dests)
	end
	optionString[nodeName] = option~=nil and option or 'not used but required for quality control'
end

function travelTo(destNode)
	-- check destination
	if not nodeList[destNode] then
		error("'travelTo' destination unknown: "..(destNode or "nil"))
	end

	repeat
		-- Find Nearest Npc
		player:update()
		local start
		local bestdist
		local path
		local zone = getZoneId()
		for from, node in pairs(nodeList) do
			if zone == node.Zone then
				if bestdist == nil or distance(player,node.Npc) < bestdist then
					start = from
					bestdist = distance(player,node.Npc)
				end
			end
		end
		-- Check if you have reached your destination
		if start == destNode then
			---- changed by Celesteria ----
			print("You have reached your destination")
			return true	
		end

		-- Get path
		if start and 300 > bestdist then
			path = Dijkstra(start, destNode)
		end

		-- If no path then try from transport skill
		local bestTransport
		if path == nil then
			-- First check if on cooldown
			local cooldown, remaining = RoMScript("GetSkillCooldown(1,2)") -- recall
			if remaining == 0 then
				-- Transport list
				local transportSkills = {
					{Id=540191,Start="Reifort"},
					{Id=540193,Start="Heffner"},
					--{Id=540190,Start="Logar"}, -- no good results
				}

				-- Check for best path from each
				for k,skill in pairs(transportSkills) do
					local tmpSkill = FindSkillBookSkill(skill.Id,1)
					if tmpSkill then
						tmpPath = Dijkstra(skill.Start, destNode)
						if tmpPath and (path == nil or #path > #tmpPath) then
							-- Found quicker route, replace
							path = tmpPath
							bestTransport = tmpSkill
						end
					end
				end
			end
		end

		-- If still no path then it can't be found
		if path == nil then
			---- changed by Celesteria ----
			print("No path to '"..destNode.."' found from current location")
			return false
		end

		-- If Transport, transport there else take step allong path
		if bestTransport then
			RoMScript("UseSkill("..bestTransport.skilltab..","..bestTransport.skillnum..")")
			waitForLoadingScreen(20)
			yrest(3000)
			bestTransport = nil
		else
			-- Check for function or teleport via npc
			if _G[start.."To"..path[1]] then
				if not player.Mounted then player:mount () end
				local oldWaypointType = __WPL.Type
				__WPL:setForcedWaypointType ('TRAVEL')
				_G[start.."To"..path[1]]()
				__WPL:setForcedWaypointType (oldWaypointType)
			else
				-- Find option string
				local selectString
				for from, node in pairs(nodeList[start].ConnectsTo) do
					local neighbor, option = string.match(node,"([%a%d]*)[^%a%d]*([%a%d]*)")
					if neighbor == path[1] then
						if option == "" then
							selectString = neighbor
						else
							selectString = option
						end
					end
				end

				-- Find Npc
				local npcId = nodeList[start].Npc.Id

				-- Target Npc and teleport
				targetNpcAndTeleport(npcId, selectString)
			end
		end
	until false
end

--------------------------------------------------
--========== Special Travel Functions ==========--

-- These functions are run, if they exit, instead of doing the usual 'target npc and select option'.
-- If they are named correctly, they get automatically run. The names consist of the 'From' node name and the
-- 'Destination' node name separated by 'To', eg. 'FromToDestination()'
function VaranasBridgeToVaranasCentral()
	-- To include the pre option during teleport for newby characters
	local npcId = nodeList.VaranasBridge.Npc.Id
	local option = "VaranasCentral"
	local preoption = "VaranasBridgePreoption"
	targetNpcAndTeleport(npcId, option, preoption)
end

function VaranasBridgeToVaranasEast()
	-- To include the pre option during teleport for newby characters
	local npcId = nodeList.VaranasBridge.Npc.Id
	local option = "VaranasEast"
	local preoption = "VaranasBridgePreoption"
	targetNpcAndTeleport(npcId, option, preoption)
end

function VaranasBridgeToVaranasWest()
	-- To include the pre option during teleport for newby characters
	local npcId = nodeList.VaranasBridge.Npc.Id
	local option = "VaranasWest"
	local preoption = "VaranasBridgePreoption"
	targetNpcAndTeleport(npcId, option, preoption)
end

function VaranasBridgeToVaranasClassHall()
	-- To include the pre option during teleport for newby characters
	local npcId = nodeList.VaranasBridge.Npc.Id
	local option = "VaranasClassHall"
	local preoption = "VaranasBridgePreoption"
	targetNpcAndTeleport(npcId, option, preoption)
end

function VaranasBridgeToVaranasWisdom()
	-- To include the pre option during teleport for newby characters
	local npcId = nodeList.VaranasBridge.Npc.Id
	local option = "VaranasWisdom"
	local preoption = "VaranasBridgePreoption"
	targetNpcAndTeleport(npcId, option, preoption)
end

function VaranasBridgeToVaranasGuildHall()
	-- To include the pre option during teleport for newbie characters
	local npcId = nodeList.VaranasBridge.Npc.Id
	local option = "VaranasGuildHall"
	local preoption = "VaranasBridgePreoption"
	targetNpcAndTeleport(npcId, option, preoption)
end

function VaranasBridgeToVaranas()
	print("Moving to Varanas Snoop")
	player:moveTo(CWaypoint(2307,1152), true)
end

function VaranasToVaranasBridge()
	print("Moving to Varanas Bridge")
	player:moveTo(CWaypoint(2767,956), true)
end

function VaranasCastleWestToVaranasWest()
	print("Moving to Varanas West Transporter")
	player:moveTo(CWaypoint(2466,-1182), true)
	player:moveTo(CWaypoint(2897,-826), true)
end

function VaranasWestToVaranasCastleWest()
	print("Moving to Varanas West Castle Manager")
	player:moveTo(CWaypoint(2466,-1182), true)
	player:moveTo(CWaypoint(2515,-1420), true)
end

function VaranasCastleEastToVaranasEast()
	print("Moving to Varanas East Transporter")
	player:moveTo(CWaypoint(4899,173), true)
	player:moveTo(CWaypoint(4607,-20), true)
	player:moveTo(CWaypoint(4489,-31), true)
end

function VaranasEastToVaranasCastleEast()
	print("Moving to Varanas East Castle Manager")
	player:moveTo(CWaypoint(4607,-20), true)
	player:moveTo(CWaypoint(4899,173), true)
	player:moveTo(CWaypoint(4958,308), true)
end

function SilverfallToGoblineMines()
	print("Moving to Goblin Mines NPC.")
	player:moveTo(CWaypoint(-5908,2865), true)
	player:moveTo(CWaypoint(-5890,3047), true)
	player:moveTo(CWaypoint(-5812,3291), true)
	player:moveTo(CWaypoint(-5865,3327), true)
end

function ObsidianToBattleSquare()
	print("Moving To Battle Square")
	player:moveTo(CWaypoint(-20782,6214), true)
end

function BattleSquareToObsidian()
	print("Moving to Obsidian Snoop")
	player:moveTo(CWaypoint(-20458,6519), true)
end

function CraftingSquareToObsidianCastle()
	print("Moving to Obsidian Stronghold Castle Manager")
	player:moveTo(CWaypoint(-22764,6376), true)
	player:moveTo(CWaypoint(-22475,6112), true)
	player:moveTo(CWaypoint(-22220,6239), true)
	player:moveTo(CWaypoint(-22152,6465), true)
end

function ObsidianCastleToCraftingSquare()
	print("Moving to Crafting Square")
	player:moveTo(CWaypoint(-22220,6239), true)
	player:moveTo(CWaypoint(-22475,6112), true)
	player:moveTo(CWaypoint(-22764,6376), true)
	player:moveTo(CWaypoint(-23620,5821), true)
end

function MercenarySquareToObsidianDalanisEnvoy()
	print("Moving to Obsidian to Dalanis Envoy")
	player:moveTo(CWaypoint(-21441,4199), true)
	player:moveTo(CWaypoint(-21261,4379), true)
	player:moveTo(CWaypoint(-20999,4541), true)
	player:moveTo(CWaypoint(-20743,4319), true)
	player:moveTo(CWaypoint(-20653,4237), true)
end

function ObsidianDalanisEnvoyToMercenarySquare()
	print("Moving to Mercenary Square")
	player:moveTo(CWaypoint(-20743,4319), true)
	player:moveTo(CWaypoint(-20999,4541), true)
	player:moveTo(CWaypoint(-21261,4379), true)
	player:moveTo(CWaypoint(-21441,4199), true)
	player:moveTo(CWaypoint(-21941,3709), true)
end

function DalanisObsidianEnvoyToDalanis()
	print("Moving to Dalanis Snoop")
	player:moveTo(CWaypoint(-4639,7600), true)
	player:moveTo(CWaypoint(-4497,7474), true)
	player:moveTo(CWaypoint(-4403,7187), true)
	player:moveTo(CWaypoint(-4407,6829), true)
	player:moveTo(CWaypoint(-4193,6256), true)
	player:moveTo(CWaypoint(-4143,6031), true)
	player:moveTo(CWaypoint(-4170,5641), true)
	player:moveTo(CWaypoint(-4044,5128), true)
	player:moveTo(CWaypoint(-4285,5090), true)
end

function DalanisObsidianEnvoyToDoD()
	print("Moving to Dungeon of Dalanis")
	player:moveTo(CWaypoint(-4523,7545), true)
	player:moveTo(CWaypoint(-4426,7237), true)
	player:moveTo(CWaypoint(-4386,6803), true)
	player:moveTo(CWaypoint(-4136,6055), true)
	player:moveTo(CWaypoint(-3809,6067), true)
	player:moveTo(CWaypoint(-3374,6227), true)
	player:moveTo(CWaypoint(-3212,6412), true)
	player:moveTo(CWaypoint(-2839,6974), true)
	yrest(500)
	player:moveTo(CWaypoint(-2915,7232), true)
	yrest(500)
	-- enter portal:
	while not GoThroughPortal(150,112224) do
		print("Failed to portal into DoD")
		player:sleep ()
	end
	player:moveTo(CWaypoint(51,-886), true)
	targetNpcAndTeleport(115572, "intosewer")
end

function DoDToDalanis()
	print("Moving to Dalanis Snoop")
	targetNpcAndTeleport(nodeList.DoD.Npc.Id, "outofsewer")-- Exit with text "Please transport me."
	player:moveTo(CWaypoint(130,-739), true)
	GoThroughPortal(150,111065)
	player:mount()yrest(1000)
	player:moveTo(CWaypoint(-2769,7237), true)
	player:moveTo(CWaypoint(-2709,7024), true)
	player:moveTo(CWaypoint(-3048,6657), true)
	player:moveTo(CWaypoint(-3208,6409), true)
	player:moveTo(CWaypoint(-3439,6201), true)
	player:moveTo(CWaypoint(-4048,5971), true)
	player:moveTo(CWaypoint(-4173,5709), true)
	player:moveTo(CWaypoint(-4071,5126), true)
	player:moveTo(CWaypoint(-4282,5091), true)
end

function DoDToDalanisObsidianEnvoy()
	print("Moving to Dalanis to Obsidian Envoy")
	targetNpcAndTeleport(nodeList.DoD.Npc.Id, "outofsewer")-- Exit with text "Please transport me."
	player:moveTo(CWaypoint(130,-739), true)
	GoThroughPortal(150,111065)
	player:moveTo(CWaypoint(-2769,7237), true)
	player:moveTo(CWaypoint(-2709,7024), true)
	player:moveTo(CWaypoint(-3048,6657), true)
	player:moveTo(CWaypoint(-3208,6409), true)
	player:moveTo(CWaypoint(-3439,6201), true)
	player:moveTo(CWaypoint(-3848,6062), true)
	player:moveTo(CWaypoint(-4142,6096), true)
	player:moveTo(CWaypoint(-4396,6811), true)
	player:moveTo(CWaypoint(-4411,7241), true)
	player:moveTo(CWaypoint(-4512,7459), true)
	player:moveTo(CWaypoint(-4625,7591), true)
	player:moveTo(CWaypoint(-4661,7594), true)
end

function DalanisToDoD()
	print("Moving to Dungeon of Dalanis")
	player:moveTo(CWaypoint(-4044,5128), true)
	player:moveTo(CWaypoint(-4170,5641), true)
	player:moveTo(CWaypoint(-4192,5970), true)
	player:moveTo(CWaypoint(-4116,6028), true)
	player:moveTo(CWaypoint(-3809,6067), true)
	player:moveTo(CWaypoint(-3374,6227), true)
	player:moveTo(CWaypoint(-3212,6412), true)
	player:moveTo(CWaypoint(-2839,6974), true)
	yrest(500)
	player:moveTo(CWaypoint(-2923,7232), true)
	yrest(500)
	-- enter portal:
	while not GoThroughPortal(150,112224) do
		print("Failed to portal into DoD")
		playe:sleep ()
	end
	player:moveTo(CWaypoint(51,-886), true)
	targetNpcAndTeleport(115572, "intosewer")
end

function DalanisToDalanisObsidianEnvoy()
	print("Moving to Dalanis to Obsidian Envoy")
	player:moveTo(CWaypoint(-4285,5090), true)
	player:moveTo(CWaypoint(-4044,5128), true)
	player:moveTo(CWaypoint(-4170,5641), true)
	player:moveTo(CWaypoint(-4196,5933), true)
	player:moveTo(CWaypoint(-4158,6094), true)
	player:moveTo(CWaypoint(-4193,6256), true)
	player:moveTo(CWaypoint(-4407,6829), true)
	player:moveTo(CWaypoint(-4403,7187), true)
	player:moveTo(CWaypoint(-4497,7474), true)
	player:moveTo(CWaypoint(-4639,7600), true)
end

function FrontlineToButterflies()
	print("Moving to Butterflies Daily NPC.")
	player:moveTo(CWaypoint(6665,6295), true)
	player:moveTo(CWaypoint(6404,6170), true)
	player:moveTo(CWaypoint(6362,5678), true)
	player:moveTo(CWaypoint(6424,5432), true)
end

function ButterfliesToFrontline()
	print("Moving to Frontline Camp Teleporter")
	player:moveTo(CWaypoint(6362,5678), true)
	player:moveTo(CWaypoint(6404,6170), true)
	player:moveTo(CWaypoint(6665,6295), true)
	player:moveTo(CWaypoint(6777,6312), true)
end

function SilverfallToGoblinMines()
	print("Moving to Goblin Mines NPC.")
	player:moveTo(CWaypoint(-5904,2856), true)
	player:moveTo(CWaypoint(-5830,3032), true)
	player:moveTo(CWaypoint(-5838,3253), true)
	player:moveTo(CWaypoint(-5873,3299), true)
end

function GoblinMinesToSilverfall()
	print("Moving to Silverfall Teleporter")
	player:moveTo(CWaypoint(-5873,3299), true)
	player:moveTo(CWaypoint(-5838,3253), true)
	player:moveTo(CWaypoint(-5830,3032), true)
	player:moveTo(CWaypoint(-5904,2856), true)
end

function LogarHousemaidToLogar ()
	print("Moving to Logar Teleporter")
	player:moveTo(CWaypoint(-433,-5971), true)
	player:moveTo(CWaypoint(-694,-5797), true)
	player:moveTo(CWaypoint(-757,-5654), true)
	player:moveTo(CWaypoint(-959,-5604), true)
	player:moveTo(CWaypoint(-1167,-5527), true)
end

function LogarToLogarHousemaid ()
	print("Moving to Logar Housemaid")
	player:moveTo(CWaypoint(-1167,-5527), true)
	player:moveTo(CWaypoint(-959,-5604), true)
	player:moveTo(CWaypoint(-757,-5654), true)
	player:moveTo(CWaypoint(-694,-5797), true)
	player:moveTo(CWaypoint(-433,-5971), true)
end

function HeffnerHousemaidToHeffner ()
	print("Moving to Heffner Teleporter")
	player:moveTo(CWaypoint(-6948,-3652), true)
	player:moveTo(CWaypoint(-6336,-3913), true)
end

function HeffnerToHeffnerHousemaid ()
	print("Moving to Heffner Housemaid")
	player:moveTo(CWaypoint(-6336,-3913), true)
	player:moveTo(CWaypoint(-6948,-3652), true)
end

function WailingFjordHousemaidToWailingFjord ()
	print("Moving to WailingFjord Teleporter")
	player:moveTo(CWaypoint(-9428,2619), true)
	player:moveTo(CWaypoint(-9464,2653), true)
	player:moveTo(CWaypoint(-9171,3055), true)
end

function WailingFjordToWailingFjordHousemaid ()
	print("Moving to WailingFjord Housemaid")
	player:moveTo(CWaypoint(-9171,3055), true)
	player:moveTo(CWaypoint(-9464,2653), true)
	player:moveTo(CWaypoint(-9428,2619), true)
end

function TundraHousemaidToTundra ()
	print("Moving to Tundra Teleporter")
	player:moveTo(CWaypoint(4112,-8503), true)
	player:moveTo(CWaypoint(3991,-8483), true)
	player:moveTo(CWaypoint(3901,-8244), true)
	player:moveTo(CWaypoint(3848,-7769), true)
end

function TundraToTundraHousemaid ()
	print("Moving to Tundra Housemaid")
	player:moveTo(CWaypoint(3848,-7769), true)
	player:moveTo(CWaypoint(3901,-8244), true)
	player:moveTo(CWaypoint(3991,-8483), true)
	player:moveTo(CWaypoint(4112,-8503), true)
end

function ObsidianHousemaidToCraftingSquare ()
	print("Moving to TradeSquare Teleporter")
	player:moveTo(CWaypoint(-23631,5814), true)
	player:moveTo(CWaypoint(-23481,6049), true)
	player:moveTo(CWaypoint(-23475,6028), true)
end

function CraftingSquareToObsidianHousemaid ()
	print("Moving to Obsidian Housemaid")
	player:moveTo(CWaypoint(-23475,6028), true)
	player:moveTo(CWaypoint(-23481,6049), true)
	player:moveTo(CWaypoint(-23631,5814), true)
end

function HarfTradingPostHousemaidToHarfTradingPost ()
	print("Moving to HarfTradingPost Teleporter")
	player:moveTo(CWaypoint(-14459,-150), true)
	player:moveTo(CWaypoint(-14203,-118), true)
	player:moveTo(CWaypoint(-13872,-62), true)
end

function HarfTradingPostToHarfTradingPostHousemaid ()
	print("Moving to HarfTradingPost Housemaid")
	player:moveTo(CWaypoint(-13872,-62), true)
	player:moveTo(CWaypoint(-14203,-118), true)
	player:moveTo(CWaypoint(-14459,-150), true)
end

function RorazanToDemostrationBattle()
	print("Moving to Demostration Battle NPC")
	player:mount()yrest(1000)
	player:moveTo(CWaypoint(-20651,-22852), true)
	player:moveTo(CWaypoint(-20479,-22890), true)
	player:moveTo(CWaypoint(-20355,-23050), true)
	player:moveTo(CWaypoint(-20238,-23360), true)
	player:moveTo(CWaypoint(-19708,-23649), true)
	player:moveTo(CWaypoint(-19298,-23501), true)
	player:moveTo(CWaypoint(-18639,-23539), true)
	player:moveTo(CWaypoint(-18494,-23275), true)
	player:moveTo(CWaypoint(-18488,-22943), true)
	player:moveTo(CWaypoint(-18384,-22832), true)
	player:moveTo(CWaypoint(-18354,-22706), true)
end

function DemostrationBattleToRorazan()
	print("Moving to Rorazan Snoop")
	player:mount()yrest(1000)
	player:moveTo(CWaypoint(-18354,-22706), true)
	player:moveTo(CWaypoint(-18384,-22832), true)
	player:moveTo(CWaypoint(-18488,-22943), true)
	player:moveTo(CWaypoint(-18494,-23275), true)
	player:moveTo(CWaypoint(-18639,-23539), true)
	player:moveTo(CWaypoint(-19298,-23501), true)
	player:moveTo(CWaypoint(-19708,-23649), true)
	player:moveTo(CWaypoint(-20238,-23360), true)
	player:moveTo(CWaypoint(-20355,-23050), true)
	player:moveTo(CWaypoint(-20479,-22890), true)
	player:moveTo(CWaypoint(-20651,-22852), true)
end

function KashaylanToHoviksCamp ()
	print("Moving to Hoviks Camp Teleporter")
	player:moveTo(CWaypoint(19298,34933), true)
	player:moveTo(CWaypoint(19343,34929), true)
	player:moveTo(CWaypoint(19494,34794), true)
end

function HoviksCampToKashaylan ()
	print("Moving to Kashaylan Teleporter")
	player:moveTo(CWaypoint(19494,34794), true)
	player:moveTo(CWaypoint(19343,34929), true)
	player:moveTo(CWaypoint(19298,34933), true)
end
