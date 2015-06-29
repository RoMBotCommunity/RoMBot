--=== 								===--
--===    Original done by Tsutomu 	===--
--=== Version 2.1 patch 5.0.0		===--
--=== 		Updated by lisa			===--
--=== 								===--

--===  								===--
--===  swimAddress = 0x44DEB2		===--
--===  charPtr_offset = 0x5A8		===--
--===  pawnSwim_offset1 = 0xF0		===--
--===  pawnSwim_offset2 = 0xB4		===--
--===  								===--
local offsets = {addresses.charPtr_offset, addresses.pawnSwim_offset1, addresses.pawnSwim_offset2}
local active = 4

function fly()
	memoryWriteString(getProc(), addresses.swimAddress, string.rep(string.char(0x90),#addresses.swimAddressBytes));
	memoryWriteIntPtr(getProc(), addresses.staticbase_char, offsets, active);
	printf("Swimhack ACTIVATED!\n");
end

function flyoff()
	memoryWriteString(getProc(), addresses.swimAddress, string.char(unpack(addresses.swimAddressBytes)));
	printf("Swimhack DEactivated.\n");
end
