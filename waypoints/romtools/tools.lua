
NAME, VERSION = "Schulani's Little Helper", 0.1

include ("settings.lua")
include ("menu.lua")

-- Restore console size when ending hack
function exitCallback ()
	printf ("\n")
	setupConsole (80, 30)
end
atExit (exitCallback)
--atError (exitCallback)

function main ()
	local menu = MENU_MAIN

	-- Check edit box state and try to clear it
	local ignoreEditboxState = false
	if getProc and memoryReadUInt (getProc (), addresses.editBoxHasFocus_address) == 0 then
		local count = 0
		repeat
			count = count + 1
			keyboardPress (key.VK_ENTER)
			yrest (1000)
		until count == 2 or memoryReadUInt (getProc (), addresses.editBoxHasFocus_address) ~= 0
		-- If editbox state not clearing then ignore it
		if memoryReadUInt (getProc (), addresses.editBoxHasFocus_address) == 0 then
			ignoreEditboxState = true
		end
	end

	setupConsole (80,1) -- Needed because of bug with setConsoleAttributes
	showMenu (menu)
	
	-- Main loop
	local hf_key_pressed, hf_key
	while (true) do

		hf_key_pressed = false

		-- Ignore keypresses if edit box is open
--		if ignoreEditboxState or memoryReadUInt (getProc (), addresses.editBoxHasFocus_address) ~= 0 then
			if menu == MENU_MAIN then
				if keyComboPressed (hotkeys.TRAVEL_MENU) then
					hf_key_pressed = true hf_key = MENU_TRAVEL
				elseif keyComboPressed (hotkeys.CHARACTER_MENU) then
					hf_key_pressed = true hf_key = MENU_CHARACTER
				elseif keyComboPressed (hotkeys.WAYPOINTS_MENU) then
					hf_key_pressed = true hf_key = MENU_WAYPOINTS
				end
			elseif menu == MENU_TRAVEL then
				if keyComboPressed (hotkeys.NAVI_LEFT) then
					hf_key_pressed = true hf_key = NAVI_LEFT
				elseif keyComboPressed (hotkeys.NAVI_RIGHT) then
					hf_key_pressed = true hf_key = NAVI_RIGHT
				elseif keyComboPressed (hotkeys.NAVI_UP) then
					hf_key_pressed = true hf_key = NAVI_UP
				elseif keyComboPressed (hotkeys.NAVI_DOWN) then
					hf_key_pressed = true hf_key = NAVI_DOWN
				elseif keyComboPressed (hotkeys.BACK_TO_MAIN) then
					hf_key_pressed = true hf_key = MENU_MAIN
				end
			elseif menu == MENU_CHARACTER then
				if keyComboPressed (hotkeys.NAVI_LEFT) then
					hf_key_pressed = true hf_key = NAVI_LEFT
				elseif keyComboPressed (hotkeys.NAVI_RIGHT) then
					hf_key_pressed = true hf_key = NAVI_RIGHT
				elseif keyComboPressed (hotkeys.NAVI_UP) then
					hf_key_pressed = true hf_key = NAVI_UP
				elseif keyComboPressed (hotkeys.NAVI_DOWN) then
					hf_key_pressed = true hf_key = NAVI_DOWN
				elseif keyComboPressed (hotkeys.BACK_TO_MAIN) then
					hf_key_pressed = true hf_key = MENU_MAIN
				end
			elseif menu == MENU_WAYPOINTS then
				if keyComboPressed (hotkeys.NAVI_LEFT) then
					hf_key_pressed = true hf_key = NAVI_LEFT
				elseif keyComboPressed (hotkeys.NAVI_RIGHT) then
					hf_key_pressed = true hf_key = NAVI_RIGHT
				elseif keyComboPressed (hotkeys.NAVI_UP) then
					hf_key_pressed = true hf_key = NAVI_UP
				elseif keyComboPressed (hotkeys.NAVI_DOWN) then
					hf_key_pressed = true hf_key = NAVI_DOWN
				elseif keyComboPressed (hotkeys.BACK_TO_MAIN) then
					hf_key_pressed = true hf_key = MENU_MAIN
				end
			end

			if hf_key then
				if hf_key_pressed == false then	--== Keys actioned on release
					if hf_key == MENU_MAIN				then menu = MENU_MAIN 			end
					if hf_key == MENU_TRAVEL			then menu = MENU_TRAVEL 		end
					if hf_key == MENU_CHARACTER		then menu = MENU_CHARACTER	end
					if hf_key == MENU_WAYPOINTS		then menu = MENU_WAYPOINTS	end
					showMenu (menu, hf_key)
					hf_key = nil	-- clear last pressed key
				end
			end
			yrest (50)
			showMain (menu)
--		end
	end
end

startMacro (main,true)
