
	function checkOnline (name)
		EventMonitorStart ("CharDetect", "CHAT_MSG_SYSTEM") yrest(300)
		RoMScript ('AskPlayerInfo("'..name..'")')  yrest(300)
		local time, moreToCome, msg = EventMonitorCheck ("CharDetect", "1")
		local online = (msg ~= nil and string.find (msg, name))
		EventMonitorStop ("CharDetect") yrest(300)
		return online
	end
