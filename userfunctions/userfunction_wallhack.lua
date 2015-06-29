--==<<              Tsutomu's Wallhack function           >>==--
--==<<              By Tsutomu     Version 1.11           >>==--
--==<<                Requirements: Rom bot.              >>==--
--==<<              Usage: wallon(); OR walloff();          >>==--
-- When u need to activate the hack you put "wallon();" without quotes inside the waypoint
-- When u don't need it anymore, you put "walloff();" without quotes inside the waypoint
-- That's it. Happy wall-climbing :p from SERBIA! ;)

--0x985E8C <<-- ADDRESS
--value 0.1 for 90 degrees (go through everywhere) 0.2 optimal value
local whacked = 0.2;
local wnormal = 4;

local wallhack_addr
local function checkAddress()
	if not wallhack_addr then
		local pattern = string.char(
			0xD9, 0x44, 0x24, 0xFF,
			0xF3, 0x0F, 0x10, 0x05, 0xFF, 0xFF, 0xFF, 0xFF,
			0xDC, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF,
			0xF3, 0x0F, 0x11, 0x4C, 0x24, 0xFF)
		local mask = "xxx?xxxx????xx????xxxxx?"
		local offset = 8
		local startloc = 0x450000

		local found = findPatternInProcess(getProc(), pattern, mask, startloc, 0xA0000);
		if( found == 0 ) then
			error("Unable to find wall hack address. Pattern needs updating.", 0);
		end

		wallhack_addr = memoryReadUInt(getProc(), found + offset);
	end
end

function wallon()
	checkAddress()
	memoryWriteFloat(getProc(), wallhack_addr, whacked);
	printf("Wallhack ACTIVATED!\n");
end

function walloff()
	checkAddress()
	memoryWriteFloat(getProc(), wallhack_addr, wnormal);
	printf("Wallhack DEactivated.\n");
end
