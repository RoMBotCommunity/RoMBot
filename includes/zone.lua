
function getZoneName ()
	local zone = RoMScript ('GetZoneName ()')
	return zone, convert_utf8_ascii (asciiToUtf8_umlauts (zone))
end

function getZoneLocalName (id)
	local id		= id~=nil and id or getZoneId ()
	local zone	= RoMScript ('GetZoneLocalName ('..id..')')
	return zone, convert_utf8_ascii (asciiToUtf8_umlauts (zone))
end
