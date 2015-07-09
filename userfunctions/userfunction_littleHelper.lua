---------------------------------------------------------------------------------------------------------
--  Schulani's little helper
--       Version 1.0.1
--
--  includes some little helper functions only if it is required and executes it
--  this is a simple smart method to test (or add) functions at runtime from another location
--
--  place files to the following path:	
__includePath	= getExecutionPath () .. '/../includes/'		-- micromacro/scripts/rom/includes
---------------------------------------------------------------------------------------------------------

function message (...)							return __loadInclude ('message', table.pack (...), 'tools') 									end
function saveReport (...)						return __loadInclude ('saveReport', table.pack (...), 'tools') 								end
function getPlayerName (...)				return __loadInclude ('getPlayerName', table.pack (...), 'tools') 						end
function savePlayerName (...)				return __loadInclude ('savePlayerName', table.pack (...), 'tools') 						end
function killStupidNewbiePet (...)	return __loadInclude ('killStupidNewbiePet', table.pack (...), 'tools')				end

function dayliesComplete (...)			return __loadInclude ('dayliesComplete', table.pack (...), 'dailies')					end
function getDailyDate (...)					return __loadInclude ('getDailyDate', table.pack (...), 'dailies') 						end
function exchangeClass (...)				return __loadInclude ('exchangeClass', table.pack (...), 'dailies') 					end
function RoMBarAutoKeys (...)				return __loadInclude ('RoMBarAutoKeys', table.pack (...), 'dailies') 					end

function setVolume (...)						return __loadInclude ('setVolume', table.pack (...), 'sound')									end
function soundOn (...)							return __loadInclude ('soundOn', table.pack (...), 'sound')										end
function soundOff (...)							return __loadInclude ('soundOff', table.pack (...), 'sound')									end

function getZoneName (...)					return __loadInclude ('getZoneName', table.pack (...), 'zone')								end
function getZoneLocalName (...)			return __loadInclude ('getZoneLocalName', table.pack (...), 'zone')						end

function smartMove (...)						return __loadInclude ('smartMove', table.pack (...)) 													end
function afterCrash (...)						return __loadInclude ('afterCrash', table.pack (...))													end
function cleanupBags (...)					return __loadInclude ('cleanupBags', table.pack (...))												end
function catchMysteriousBag (...)		return __loadInclude ('catchMysteriousBag', table.pack (...))									end

function mount (...)								return __loadInclude ('mount', table.pack (...))															end
function combatMode (...)						return __loadInclude ('combatMode', table.pack (...))													end
function bossBuffs (...)						return __loadInclude ('bossBuffs', table.pack (...))													end

function checkOnline (...)					return __loadInclude ('checkOnline', table.pack (...))												end
function checkMailbox (...)					return __loadInclude ('checkMailbox', table.pack (...))												end

---------------------------------------------------------------------------------------------------------
-- the loader
---------------------------------------------------------------------------------------------------------

function setIncludePath (path)
	local oldPath = __includePath
	__includePath = path
	return oldPath
end

function __loadInclude (funcName, args, fileName)
	local status, err
	local fullpath = fixSlashes ((__includePath..((fileName~=nil and fileName) or funcName)..'.lua'):gsub ("([%a%d%s%._]+)/%.%./", ""))
	if fileExists (fullpath) then
		status, err = pcall (dofile, fullpath)
		if status then
			cprintf (cli.lightgreen, 'file "'..getFileName (fullpath)..'" included...\n')
			return _G[funcName] (table.unpack (args))
		end
	end
	cprintf (cli.lightred, 'error loading file "'..fullpath..'"\n')
	if err then
		cprintf (cli.lightred, err .. '\n')
	end
	error ('',0)
end

----------------------------------------------------------------------------------------------------
-- eof
----------------------------------------------------------------------------------------------------
