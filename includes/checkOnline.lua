
	function checkOnline (name)
		cprintf (cli.lightblue, 'check online status for char "%s": ', name)
		EventMonitorStart ("CharDetect", "CHAT_MSG_SYSTEM") yrest(300)
		RoMScript ('AskPlayerInfo("'..name..'")')  yrest(1000)
		local time, moreToCome, msg = EventMonitorCheck ("CharDetect", "1")
		local online = (msg ~= nil and string.find (msg, name))
		EventMonitorStop ("CharDetect") yrest(300)
		if online then
			cprintf (cli.lightgreen, 'online\n')
		else
			cprintf (cli.lightred, 'offline\n')
		end
		return online
	end
