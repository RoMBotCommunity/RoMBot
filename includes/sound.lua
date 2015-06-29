
__saveMasterVolume	= RoMScript ("MasterVolumeSlider_GetValue()")
if __saveMasterVolume==0 then __saveMasterVolume = 100 end

function setMasterVolume (vol)
	if vol==nil or tonumber(vol)==nil then
		vol = __saveMasterVolume
	end
	RoMScript ("SYS_AudioSettings_MasterVolumeSlider:SetValue("..vol..")")	yrest (200)
	RoMScript ("SYS_AudioSettings_MusicVolumeSlider:SetValue(0)") 					yrest (200)
	RoMScript ("SYS_AudioSettings_AmbienceVolumeSlider:SetValue(100)") 			yrest (200)
	RoMScript ("SYS_AudioSettings_SoundFXVolumeSlider:SetValue(100)")				yrest (200)
	RoMScript ("SYS_AudioSettings_InterfaceSFXVolumeSlider:SetValue(100)")	yrest (200)
	RoMScript ("SSF_AudioSettings_OnApply()") yrest (200)
end

function soundOn ()
	setMasterVolume (__saveMasterVolume)
end

function soundOff ()
	setMasterVolume (0)
end
