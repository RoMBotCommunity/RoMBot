--=== 								===--
--===    Original done by Tsutomu 	===--
--=== 		Version 1.5 			===--
--=== 		Updated by lisa			===--
--=== 								===--


local offsetsx = {0x598, 0x40};
function speed(_speed)
	if _speed == nil then _speed = 100 end
	if type(_speed) ~= "number" then
		_speed = string.lower(_speed)
		if _speed == "on" then _speed = 100 end		-- defaults to 100 if nothing specified
		if _speed == "off" then _speed = 50 end							-- normal walk speed
		if type(_speed) ~= "number" then
			printf("Incorrect usage of function speed().\n")
			player:sleep()
		end
	end
	
	if _speed > 106 or 30 > _speed then  						-- greater then 106 is to fast, less then 30 is to slow
		error("Speed outside of safe values, 30 to 106\n")
	end

	local sp
	
	if _speed > 50 then sp = "fast" end
	if 50 > _speed then sp = "slow" end
	if _speed == 50 then sp = "normal" end
	
	local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
	if playerAddress ~= 0 then
		memoryWriteFloat(getProc(), playerAddress + 0x40, _speed);
		printf("Speed set to how you like it, "..sp..".\n")
	end
end



function keepSpeed(_speed)
	if _speed == nil then _speed = 100 end
	if type(_speed) ~= "number" then
		_speed = string.lower(_speed)
		if _speed == "on" then _speed = 100 end		-- defaults to 100 if nothing specified
		if _speed == "off" then _speed = 50 end							-- normal walk speed
		if type(_speed) ~= "number" then
			printf("Incorrect usage of function speed().\n")
			player:sleep()
		end
	end	
	
	if _speed > 106 or 30 > _speed then  						-- greater then 106 is to fast, less then 30 is to slow
		error("Speed outside of safe values, 30 to 106\n")
	end
	
	local function speederr()
		local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
		if playerAddress ~= 0 then
			memoryWriteFloat(getProc(), playerAddress + 0x40, _speed);
			local mount = memoryReadInt(getProc(), playerAddress + addresses.charPtrMounted_offset);
			if mount ~= 0 then
				memoryWriteFloat(getProc(), mount + 0x40, 99);
			end
		end
	end	
	
	if _speed == 50 then
		unregisterTimer("Speed");
		local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
		printf("0x%X\n",playerAddress)
		if playerAddress ~= 0 then
			memoryWriteFloat(getProc(), playerAddress + 0x40, 50);
			local mount = memoryReadInt(getProc(), playerAddress + addresses.charPtrMounted_offset);
			if mount ~= 0 then
				memoryWriteFloat(getProc(), mount + 0x40, 82);
			end
		end
	else
		registerTimer("Speed", secondsToTimer(1), speederr);
		print("testing on")
	end
end
