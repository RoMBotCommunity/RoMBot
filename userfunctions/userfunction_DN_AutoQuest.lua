-- DN_AutoQuest userfunction
--    By Rock5    Version 1

-- Adds quest id to DailyNotes and enables it for auto accept/complete
-- http://solarstrike.net/phpBB3/viewtopic.php?p=61225#p61225

function DN_AutoQuest(questid,onoff)
	-- Check that user used quest id as argument
	if type(tonumber(questid)) ~= "number" then
		error("DN_AutoQuest: invalid argument. Expected quest id.",0)
	end

	-- Check if DailyNotes is installed
	if RoMScript("DailyNotes == nil") then
		error("DN_AutoQuest: addon DailyNotes is not installed.",0)
	end

	onoff	= (onoff==nil or onoff==true or tostring (onoff):lower()=='on') and 1 or 0
	
	-- Get server name
	local serverName = RoMScript("GetCurrentRealm()") or ""

	-- DailyNotes only uses last word of name
	serverName = string.match(serverName,"(%w*)$")

	-- Check if there is already an entry for server then enable Auto-Quest
	local serverSet = RoMScript("(DN_Options_Of_Char."..serverName.." ~= nil)")
	if serverSet then
		RoMCode("DN_Options_Of_Char."..serverName..".autoquest=true")
	else
		RoMCode("DN_Options_Of_Char."..serverName.." = {autoquest=true}")
	end

	-- Check that there is a quest list then add the quest id.
	local aq_accept = RoMScript("(DN_Options_Of_Char."..serverName..".aq_accept ~= nil)")
	if aq_accept then
		RoMCode("DN_Options_Of_Char."..serverName..".aq_accept["..questid.."]="..onoff)
	else
		RoMCode("DN_Options_Of_Char."..serverName..".aq_accept={["..questid.."]="..onoff.."}")
	end
end
