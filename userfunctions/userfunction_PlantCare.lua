-- ver 3.0


function PlantCare()
seeds = {}
pots = {}
furniture = {}
local function roundIt(_number)
	if _number > (math.floor(_number) + 0.5) then
		return math.ceil(_number);
	else
		return math.floor(_number);
	end
end
local function normaliseString(_str)
	_str = string.gsub(_str, string.char(45), ".")	-- Delete "-" in string
	_str = string.lower(_str) -- Lower case
	
	return _str
end
		
--=== populate seeds to a table ===--
	root = xml.open(getExecutionPath() .. "/database/seeds.xml");
	elements = root:getElements();

	for i,v in pairs(elements) do
		local name, id, type;
		local tmp = {}

		name = v:getAttribute("name");
		id = v:getAttribute("id");
		type = v:getAttribute("type");

		if( type == "WOOD" ) then
			type = NTYPE_WOOD;
		elseif( type == "ORE" ) then
			type = NTYPE_ORE;
		elseif( type == "HERB" ) then
			type = NTYPE_HERB;
		end;

		tmp.Name = name;
		tmp.Id = id;
		tmp.Type = type;

		seeds[id] = tmp;
	end
		
		
	 -- table.print(seeds) -- Tested table and works
	
	--=== check zone ===--
	local zoneid = RoMScript("GetZoneID()")
	if zoneid ~= 400 then printf("Need to be in your House, move to your house and then press Delete.\n")
		player:sleep()
	end
	
	--=== Createtable for pots ===--
	local objectList = CObjectList();
	objectList:update();
	local objSize = objectList:size()
	for i = 0,objSize do 
		obj = objectList:getObject(i);
		if obj.Id >= 200000 and 210000 >= obj.Id then
			table.insert(pots, {Address = obj.Address, Name = obj.Name, Id = obj.Id, X = obj.X, Z = obj.Z, Y = obj.Y})
		end
		--table.insert(furniture, {Type = obj.Type, Address = obj.Address, Name = obj.Name, Id = obj.Id})
		--_pot = normaliseString(" pot")
		--_name = normaliseString(obj.Name)
		--_pot = string.find(_name,_pot)
		--if _pot ~= nil and obj.Type == 0 then
		--	table.insert(pots, {Address = obj.Address, Name = obj.Name, Id = obj.Id, X = obj.X, Z = obj.Z, Y = obj.Y})
		--end
	end
	table.print(pots)
	
	--=== target pot ===--
	for k,v in pairs(pots) do

	RoMScript("HideUIPanel(PlantFrame);")
	player:clearTarget();
	printf(v.Name.."\n")
	memoryWriteInt(getProc(), player.Address + addresses.pawnTargetPtr_offset, v.Address);
	yrest(5000)
	local pet = player:findNearestNameOrId(113199)
	if pet then inventory:useItem(207051); end -- get rid of the annoying newbie pet
		
	--=== change camera to look at pot ===--
	local angle = math.atan2(v.Z - player.Z, v.X - player.X);
	local proc = getProc();
	camera:setRotation(angle);
	memoryWriteFloat(proc, camera.Address + addresses.camY_offset, 16.77);
	memoryWriteFloat(proc, camera.Address + addresses.camY_offset, 16.77);	
	memoryWriteFloat(proc, camera.Address + addresses.camY_offset, 16.77);	
	--yrest(3000) -- rest because of the stupid camera moving
	
	--=== get mouse over the right pot ===--
	repeat
	scan_for_pot(v.Address)
	local szState, szPotName, nPotType = RoMScript("Plant_GetInfo();")
	yrest(1000)
	until szState ~= nil
	yrest(500)
	local szState, szPotName, nPotType = RoMScript("Plant_GetInfo();")

	if nPotType == 2 then nPotType = 3 elseif nPotType == 3 then nPotType = 2 end 
	--make client and bot both on same page as far as numbers matching resources
	
	--=== check if pot needs a seed ===--
	if szState == "none" then 

		--=== find seed in inv to use ===--
		inventory:update()
			for slot,item in pairs(inventory.BagSlot) do
			local seedid = seeds[item.Id];
				if seedid and ( seedid.Type == nPotType or nPotType == 0 ) then 
				-- guessed that ALL would be 0, I don't have a pot to test it on.
				RoMScript("PickupBagItem("..item.BagId..")")
				yrest(1000)
				RoMScript('Plant_PickupItem("seed");')
				yrest(1000)
				RoMScript('Plant_Grow("seed");')
				yrest(500)
				end
			end
		--=== update to feed/water it. ===--
		-- needs fixing
		detach();
		RoMScript("HideUIPanel(PlantFrame);")
		player:clearTarget();
		memoryWriteInt(getProc(), player.Address + addresses.pawnTargetPtr_offset, v.Address);
		yrest(500)
		printf("click it again to feed\n")
		mouseLClick(); 
		yrest(500) 
		mouseLClick();
		attach(getWin());
	end
	end
	
end

function scan_for_pot(_potaddress)

	if( foregroundWindow() ~= getWin() ) then
		return;
	end
	local function scan()
		local mousePawn;
		-- Screen dimension variables
		local wx, wy, ww, wh = windowRect(getWin());
		local halfWidth = ww/2;
		local halfHeight = wh/2;

		-- Scan rect variables
		local scanWidth = 5; -- Width, in 'steps', of the area to scan
		local scanHeight = 5; -- Height, in 'steps', of area to scan
		local scanXMultiplier = 1.0;	-- multiplier for scan width
		local scanYMultiplier = 1.1;	-- multiplier for scan line height
		local scanStepSize = 60; -- Distance, in pixels, between 'steps'
		
		local mx, my; -- Mouse x/y temp values

		mouseSet(wx + (halfWidth*scanXMultiplier - (scanWidth/2*scanStepSize)),
		wy  + (halfHeight*scanYMultiplier - (scanHeight/2*scanStepSize)));
		yrest(200);

		local scanstart, scanende, scanstep;
		-- define scan direction top/down  or   bottom/up
			scanstart = 0;
			scanende = scanHeight-1;
			scanstep = 1;


		-- Scan nearby area for a pot
		for y = scanstart, scanende, scanstep do
			my = math.ceil(halfHeight * scanYMultiplier - (scanHeight / 2 * scanStepSize) + ( y * scanStepSize ));

			for x = 0,scanWidth-1 do
				mx = math.ceil(halfWidth * scanXMultiplier - (scanWidth / 2 * scanStepSize) + ( x * scanStepSize ));

				mouseSet(wx + mx, wy + my);
				yrest(13);
				mousePawn = CPawn(memoryReadRepeat("intptr", getProc(),	
				addresses.staticbase_char, addresses.mousePtr_offset));


				if( mousePawn.Address ~= 0 ) then
					local target = CPawn(mousePawn.Address);
					if( _potaddress and	not string.find(target.Address, _potaddress ) ) then
					    local dummy = 1;
					else
						mouseLClick();		
						yrest(500);
						mouseLClick();
						yrest(500);
						local szState, szPotName, nPotType  = RoMScript("Plant_GetInfo();")
						yrest(500)
						
						if szState ~= nil then
						cprintf(cli.green, "We found Pot: %s\n", target.Name);
						return
						end
					end;
				end
			end
		end
		
		return
	end	
detach();	
	scan();
attach(getWin());
	

end