function playalarm(_adjust)
--	usage
--	playalarm() -- default volume
--	playalarm(10) -- a little louder then default
--	playalarm(-10) -- a little softer then default, max of -20

	_adjust = _adjust or 0

	--=== User option to adjust volume ===--
	local permanantadjust = 0		-- set higher value to make sound louder.
	
	
	--=== start of function ==---	
	local volumeadjustment = permanantadjust + _adjust 
	if -20 > volumeadjustment then volumeadjustment = -20 end -- make sure value isn't less then -20	
	if volumeadjustment > 80 then volumeadjustment = 80 end -- make sure value isn't more then 80
	
	local interfacevolume = RoMScript("InterfaceSFXVolumeSlider_GetValue()")
	local mastervolume = RoMScript("MasterVolumeSlider_GetValue()")
	RoMScript("InterfaceSFXVolumeSlider_SetValue(100)")
	RoMScript("MasterVolumeSlider_SetValue("..20 + volumeadjustment..")")
	RoMScript("PlaySoundByPath('Interface/AddOns/ingamefunctions/alarm.wav')")
	cprintf(cli.red,"Alarm has been sounded\n")
	yrest(2000)
	RoMScript("InterfaceSFXVolumeSlider_SetValue("..interfacevolume..")")
	RoMScript("MasterVolumeSlider_SetValue("..mastervolume..")")
end