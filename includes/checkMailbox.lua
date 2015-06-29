
	function checkMailbox ()
		repeat
			local mailCount		= RoMScript ('UMMMailManager.MailCount')
			UMM_DeleteEmptyMail ()
			UMM_TakeMail ()
			local bagSpace		= inventory:itemTotalCount (0)
		until bagSpace==0 or mailCount==0
		RoMScript ('HideUIPanel (UMMFrame)')
		RoMScript ('CloseMail()')
		return (bagSpace==0 or mailCount==30 or ItemQueueCount()>0)
	end
