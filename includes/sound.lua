
__saveMasterVolume	= RoMScript ("MasterVolumeSlider_GetValue()")
if __saveMasterVolume==0 then __saveMasterVolume = 100 end

function setMasterVolume (vol)
	if vol==nil or tonumber(vol)==nil then
		vol = __saveMasterVolume
	end
	RoMScript ("SYS_AudioSettings_MasterVolumeSlider:SetValue("..vol..")")	yrest (200)
	RoMScript ("SSF_AudioSettings_OnApply()") yrest (200)
end

function setVolume (master, interface, ambience, fx, music)
	master    = master 		or __saveMasterVolume
	interface = interface or __saveMasterVolume
	ambience  = ambience 	or __saveMasterVolume
	fx        = fx 				or __saveMasterVolume
	music     = music 		or 0
	RoMScript ("SYS_AudioSettings_MasterVolumeSlider:SetValue("..master..")")						yrest (200)
	RoMScript ("SYS_AudioSettings_MusicVolumeSlider:SetValue("..music..")") 						yrest (200)
	RoMScript ("SYS_AudioSettings_AmbienceVolumeSlider:SetValue("..ambience..")") 			yrest (200)
	RoMScript ("SYS_AudioSettings_SoundFXVolumeSlider:SetValue("..fx..")")							yrest (200)
	RoMScript ("SYS_AudioSettings_InterfaceSFXVolumeSlider:SetValue("..interface..")")	yrest (200)
	RoMScript ("SSF_AudioSettings_OnApply()") yrest (200)
end

function soundOn ()
	setVolume (__saveMasterVolume, 100, 100, 100, 0)
end

function soundOff (full)
	if full==true then
		setMasterVolume (0)
	else
		setVolume (__saveMasterVolume, 100, 0, 0, 0)
	end
end
