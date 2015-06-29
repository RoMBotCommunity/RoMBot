------------MountSpeed function-- Use MountSpeedHack(); to set MountSpeed = 99, normal speed is 82. Use MountSpeedoff(); to DEactivate.
function memoryfreezeMountSpeed()
	local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
	if playerAddress ~= 0 then
		local mount = memoryReadInt(getProc(), playerAddress + addresses.charPtrMounted_offset);
		if mount ~= 0 then
			memoryWriteFloat(getProc(), mount + 0x40, 99);
		end
	end
end

function MountSpeedHack()
	registerTimer("MountSpeed", 10, memoryfreezeMountSpeed);
	printf("MountSpeedHack ACTIVATED!\n"); yrest(500);
	local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
	if playerAddress ~= 0 then
		local mount = memoryReadInt(getProc(), playerAddress + addresses.charPtrMounted_offset);
		if mount ~= 0 then
			local MountSpeed = memoryReadFloat(getProc(), mount + 0x40);
			print("MountSpeed:", MountSpeed);
		end
	end
end

function MountSpeedoff()
	unregisterTimer("MountSpeed");
	local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
	if playerAddress ~= 0 then
		local mount = memoryReadInt(getProc(), playerAddress + addresses.charPtrMounted_offset);
		if mount ~= 0 then
			memoryWriteFloat(getProc(), mount + 0x40, 82);
			printf("MountSpeedhack DEactivated.\n");
			local MountSpeed = memoryReadFloat(getProc(), mount + 0x40);
			print("MountSpeed:", MountSpeed);
		else
			print("Player not Mounted. MountSpeed is normal.");
		end
	end
end

function getMountSpeed()
	local playerAddress = memoryReadIntPtr(getProc(), addresses.staticbase_char, addresses.charPtr_offset);
	if playerAddress ~= 0 then
		local mount = memoryReadInt(getProc(), playerAddress + addresses.charPtrMounted_offset);
		if mount ~= 0 then
			local MountSpeed = memoryReadFloat(getProc(), mount + 0x40);
			print("MountSpeed:", MountSpeed);
			return MountSpeed
		else
			print("Can't set MountSpeed: player not Mounted");
			return nil;
		end
	else
		print("Can't set MountSpeed: playerAddress = nil");
		return nil;
	end
end