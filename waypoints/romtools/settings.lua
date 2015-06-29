-- The keys that trigger the specified hack action
hotkeys = {
	-- menu "main"
	BACK_TO_MAIN  	= {key = _G.key.VK_NUMPAD0,  modifier = nil},
	TRAVEL_MENU    	= {key = _G.key.VK_NUMPAD1,  modifier = nil},
	CHARACTER_MENU 	= {key = _G.key.VK_NUMPAD2,  modifier = nil},
	WAYPOINTS_MENU 	= {key = _G.key.VK_NUMPAD3,  modifier = nil},
	-- "navigation"
	NAVI_LEFT				= {key = _G.key.VK_NUMPAD4,  modifier = nil},
	NAVI_RIGHT			= {key = _G.key.VK_NUMPAD6,  modifier = nil},
	NAVI_UP					= {key = _G.key.VK_NUMPAD8,  modifier = nil},
	NAVI_DOWN				= {key = _G.key.VK_NUMPAD2,  modifier = nil},
	-- menu "teleport"
	-- menu "character"
}

-- The starting position of the MM display relative to the game window
window_position_X = 10
window_position_Y = 30

-- travel targets (from userfunction_travelTo)
travelData = {
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
	VaranasGuildHall = "ZONE_VARANAS GUILD HALL",
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

	-- The below locations can't be teleported to so don't need strings but are included to avoid errors during quality control.
	DoD = "Dungeon of Dalanis",
	GoblinMines = "Goblin Mines",
	Butterflies = "Butterflies",
	VaranasCastleWest = "Varanas West Guild Castle",
	VaranasCastleEast = "Varanas East Guild Castle",
	ObsidianCastle = "Obsidian Guild Castle",
	LogarHousemaid = "Logar Housemaid",
	HeffnerHousemaid = "Heffner Housemaid",
	TundraHousemaid = "Tundra Housemaid",
	ObsidianHousemaid = "Obsidian Housemaid",
	WailingFjordHousemaid = "WailingFjord Housemaid",
}

characterData = {
	"Mainbänker",
	"Foodbänker",
	"Matsbänker",
	"Manabänker",
	"Steinbänker",
	"Restebänker",
	"Crapbänker",
	"Dailybänker",
	"Kräuterbänker",
	"Holzbänker",
	"Erzbänker",
	"Runenbänker",
	"Statsbänker",
	"Brisinga",
}

waypointData = {
	["Logar Daylies1"]		= "2_TQ/TQ-Logar",
	["Logar Daylies2"]		= "2_TQ/TQ-Logar",
	["Logar Daylies3"]		= "2_TQ/TQ-Logar",
	["Logar Daylies4"]		= "2_TQ/TQ-Logar",
	["Logar Daylies5"]		= "2_TQ/TQ-Logar",
}