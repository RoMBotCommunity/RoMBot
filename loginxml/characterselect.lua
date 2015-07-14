CHARACTER_FACING_INCREMENT = 2;
CHARACTER_ROTATION_CONSTANT = 0.6
CHARACTER_SELECT_ROTATION_START_X = nil;

CHARACTERSELECT_REGION_SELECTED = nil;
CHARACTERSELECT_RECOVER_DELETE = nil;
MAX_REGION_BUTTONS = 15;
MAX_CHARACTERS_DISPLAYED = 8;
MAX_CHARACTERS_PER_REALM = 10;

CHARACTER_SELECT = {};

LOADLISTCOLOR = {};
LOADLISTCOLOR[1] = { r = 0, g = 1, b = 0 };
LOADLISTCOLOR[2] = { r = 1, g = 1, b = 1 };
LOADLISTCOLOR[3] = { r = 0.94, g = 0.4, b = 0.13 };
LOADLISTCOLOR[4] = { r = 1, g = 0, b = 0 };

DoRelog = false

function CharacterSelect_OnLoad(this)
	CHARACTER_SELECT.createIndex = 0;
	CHARACTER_SELECT.selectedIndex = 0;
	CHARACTER_SELECT.SelectedButton = nil;
	CHARACTER_SELECT.selectLast = 0;
	CHARACTER_SELECT.currentModel = "";
	this:RegisterEvent("UPDATE_CHARACTER_SELECT_LIST");
	this:RegisterEvent("UPDATE_CHARACTER_PARALLEZONE");
	this:RegisterEvent("UPDATE_SELECTED_CHARACTER");
	this:RegisterEvent("ADJUST_DISPLAY");

	local width = CharacterSelectChangeRealmButton:GetTextWidth();
	CharacterSelectChangeRealmButton:SetWidth(width + 24);
end

function CharacterSelect_OnShow(this)
	OpenCharacterSelect();
	CharacterList_Update();
	RegionList_Update();

	CharacterSelectZoneName:SetText("");
	CharacterSelectRealmName:SetText(GetCurrentRealm());
	UpdateCharacterSelection();

	if ( GetLocation() == "JP" or GetLocation() == "HG" or GetLocation() == "SG" ) then
		CharacterSelectBackButton:SetText(LOGIN_ACCOUNT_EXIT);
	else
		CharacterSelectBackButton:SetText(LOGIN_BACK);
	end
end

function CharacterSelect_OnHide(this)
	CloseCharacterSelect();
end

function CharacterSelect_OnMouseDown(this)
	CHARACTER_SELECT_ROTATION_START_X = GetCursorPos();
	--CHARACTER_SELECT_ROTATION_START_X = GetCharacterSelectFacing();
end

function CharacterSelect_OnMouseUp(this)
	CHARACTER_SELECT_ROTATION_START_X = nil;
end

function CharacterSelect_OnUpdate(this, elapsedTime)
	if ( CHARACTER_SELECT_ROTATION_START_X ) then
		local x = GetCursorPos();
		local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_SELECT_ROTATION_START_X = x;
		SetCharacterSelectFacing(GetCharacterSelectFacing() - diff);
	end
end

function CharacterSelect_OnMouseWheel(this, delta)
	LoginScrollBar_OnMouseWheel(CharacterSelectListScrollBar, delta);
end

function CharacterSelect_OnKeyDown(this, arg1)
	if ( arg1 == "ESCAPE" ) then
		CharacterSelect_Exit();
	elseif ( arg1 == "ENTER" ) then
		CharacterSelect_EnterWorld();
	end
end

function CharacterSelectEnterWorldButton_Update()
	if ( GetNumCharacters() > 0 and CHARACTERSELECT_REGION_SELECTED ~= nil ) then
		CharacterSelectEnterWorldButton:Enable();
	else
		CharacterSelectEnterWorldButton:Disable();
	end
end

function CharacterList_Update()
	local maxNums = GetNumCharacters() - MAX_CHARACTERS_DISPLAYED;
	if ( maxNums > 0 ) then
		CharacterSelectListScrollBar:SetMinMaxValues(0, maxNums);
		CharacterSelectListScrollBar:Show();
	else
		CharacterSelectListScrollBar:SetMinMaxValues(0, 0);
		CharacterSelectListScrollBar:Hide();
	end

	UpdateCharacterList();
end

function UpdateCharacterList()
	local numChars = GetNumCharacters();
	local index = CharacterSelectListScrollBar:GetValue() + 1;
	local coords, button;
	local name, gender, mainLevel, mainClass, secLevel, secClass, zone, destroyTime;

	for i = 1, MAX_CHARACTERS_DISPLAYED do
		button = getglobal("CharacterSelectCharacterButton"..i);
		if ( index <= numChars ) then
			name, gender, mainLevel, mainClass, secLevel, secClass, zone, destroyTime = GetCharacterInfo(index);

			if ( gender == 0 ) then
				gender = "MALE";
			else
				gender = "FEMALE";
			end

			if ( not name ) then
				button:SetText("ERROR!!");
			else
				local infoText;
				if ( not zone ) then
					zone = "";
				end

				if ( secLevel > 0 ) then
					infoText = mainClass.." Lv "..mainLevel.." / "..secClass.." Lv "..secLevel;
				else
					infoText = mainClass.." Lv "..mainLevel;
				end

				getglobal("CharacterSelectCharacterButton"..i.."ButtonTextName"):SetText(name);
				getglobal("CharacterSelectCharacterButton"..i.."ButtonTextInfo"):SetText(infoText);
			end
			button.zone = zone;
			button.destroyTime = destroyTime;
			button.index = index;

			-- 檢本角色是否被刪除
			button:SetAlpha(1);
			if ( destroyTime ) then
				button:SetAlpha(0.5);
			end

			button:Show();
			index = index + 1;
		else
			button:Hide();
		end
	end

	if ( numChars == 0 ) then
		CharacterSelectDeleteButton:Disable();
	else
		CharacterSelectDeleteButton:Enable();
	end
	CharacterSelectEnterWorldButton_Update();

	if ( numChars < GetMaxCharacterCreate() ) then
		CHARACTER_SELECT.createIndex = index;
		CharacterSelectCreateButton:SetID(index);
		CharacterSelectCreateButton:Show();
	else
		CHARACTER_SELECT.createIndex = 0;
		CharacterSelectCreateButton:Hide();
	end

	if ( numChars == 0 ) then
		CHARACTER_SELECT.selectedIndex = 0;
		return;
	end

	--if ( CHARACTER_SELECT.selectLast == 1 ) then
	--	CHARACTER_SELECT.selectLast = 0;
	--	CharacterSelect_SelectCharacter(numChars, 1);
	--	return;
	--end

	-- 檢查選取項目正確性
	if ( (CHARACTER_SELECT.selectedIndex == 0) or (CHARACTER_SELECT.selectedIndex > numChars) ) then
		CHARACTER_SELECT.selectedIndex = 1;
		CharacterSelectListScrollBar:SetValue(0);
	end

	CharacterSelect_SelectCharacter(CHARACTER_SELECT.selectedIndex, 1);
end

function CharacterSelect_OnEvent(this, event)
	if ( event == "UPDATE_CHARACTER_SELECT_LIST" ) then
		CharacterList_Update();
		UpdateCharacterSelection();
		--UpdateCharacterList();
	elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
		if ( arg1 > 0 ) then
			CHARACTER_SELECT.selectedIndex = arg1;
		end
		UpdateCharacterSelection();
	elseif ( event == "UPDATE_CHARACTER_PARALLEZONE" ) then
		CHARACTERSELECT_REGION_SELECTED = arg1;
		RegionListUpdate();
	elseif ( event == "ADJUST_DISPLAY" ) then
		LoginDialog_Show("ADJUST_DISPLAY");
	end
end

function UpdateCharacterSelection()
	CHARACTERSELECT_RECOVER_DELETE = nil;
	CharacterSelectEnterWorldButton:SetText(TEXT("CHARACTER_ENTER_WORLD"));

	local button;
	for i = 1, MAX_CHARACTERS_DISPLAYED do
		button = getglobal("CharacterSelectCharacterButton"..i);
		if ( button.index == CHARACTER_SELECT.selectedIndex ) then
			CharacterSelectZoneName:SetText(button.zone);
			button:LockHighlight();

			-- 如果角色為刪除狀態顯示文字為回復角色
			if ( (button ~= nil) and (button.destroyTime ~= nil) ) then
				CHARACTERSELECT_RECOVER_DELETE = 1;
				CharacterSelectEnterWorldButton:SetText(TEXT("CHARACTER_SELECT_RECOVER_DELETE"));
			end
		else
			button:UnlockHighlight();
		end
	end
end

function CharacterSelect_EnterWorld()
	if ( CHARACTERSELECT_RECOVER_DELETE ) then
		LoginDialog_Show("RECOVER_DELETE_CHARACTER");
	else
		EnterWorld(CHARACTERSELECT_REGION_SELECTED);
	end
end

function CharacterSelect_Exit()
	if ( GetLocation() == "JP" or GetLocation() == "HG" or GetLocation() == "SG" ) then
		AccountLogin_Exit();
		return;
	end

	DisconnectFromServer();
	SetLoginScreen("login");
end

function CharacterSelectButton_OnClick(this)
	local index = this.index;
	PlaySoundByPath("sound\\interface\\ui_charselect_pick.mp3");
	if ( index ~= CHARACTER_SELECT.selectedIndex ) then
		CharacterSelect_SelectCharacter(index);
	end
	CharacterSelectEnterWorldButton_Update();
end

function CharacterSelectButton_OnUpdate(this, elapsedTime)
	-- 刪除角色資料,更新刪除時間
	if ( this.destroyTime ) then
		this.destroyTime = this.destroyTime - elapsedTime;
	end
end

function CharacterSelectButton_OnEnter(this)
	local seconds = this.destroyTime;
	if ( seconds ) then
		LoginTooltip:ClearAllAnchors();
		LoginTooltip:SetAnchor("TOPRIGHT", "BOTTOMLEFT", this, 0, 0);
		if ( seconds >= 3600 ) then
			LoginTooltip:SetText(string.format("%d"..LOGIN_HOURS, math.ceil(seconds / 3600)));
		else
			LoginTooltip:SetText(string.format("%d"..LOGIN_MINUTES, math.ceil(seconds / 60)));
		end
	else
		LoginTooltip:Hide();
	end
end

function CharacterSelect_AccountOptions()
end

function CharacterSelect_TechSupport()
end

--[[function CharacterSelect_Delete()
	if ( CHARACTER_SELECT.selectedIndex > 0 ) then
		LoginDialog_Show("DELETE_CHARACTER");
	end
end]]

function CharacterSelect_Delete_OnEnter(this)
	LoginTooltip:ClearAllAnchors();
	LoginTooltip:SetAnchor("TOPRIGHT", "BOTTOMLEFT", this, 0, 0);
	LoginTooltip:SetText("Shift-Click to delete ALL characters");
end

function CharacterSelect_RecoverDelete()
	RecoverDeleteCharacter(CHARACTER_SELECT.selectedIndex);
end

function CharacterSelect_SelectCharacter(id, noCreate)
	if ( id == CHARACTER_SELECT.createIndex ) then
		if ( not noCreate ) then
			SetLoginScreen("charcreate");
		end
	else
		SelectCharacter(id);
	end
end

function CharacterSelectRotateRightButton_OnUpdate(this, elapsed)
	if ( this:IsButtonPushed("LeftButton") ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() - CHARACTER_FACING_INCREMENT);
	end
end

function CharacterSelectRotateLeftButton_OnUpdate(this, elapsed)
	if ( this:IsButtonPushed("LeftButton") ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() + CHARACTER_FACING_INCREMENT);
	end
end

function RegionListButton_OnClick(this)
 	CHARACTERSELECT_REGION_SELECTED = this.index;
	RegionListUpdate();
end

function RegionList_Update()
	local maxNums = GetNumParalleZones() - MAX_REGION_BUTTONS;
	if ( maxNums > 0 ) then
		RegionListScrollBar:SetMinMaxValues(0, maxNums);
		RegionListScrollBar:Show();
	else
		RegionListScrollBar:SetMinMaxValues(0, 0);
		RegionListScrollBar:Hide();
	end

	RegionListUpdate();
end

function RegionListUpdate()
	local numRegions = GetNumParalleZones();
	local index = RegionListScrollBar:GetValue() + 1;
	local button, nameText, loadText;
	local name, load, color;

	for i = 1, MAX_REGION_BUTTONS do
		button = getglobal("RegionListButton"..i);
		nameText = getglobal("RegionListButton"..i.."Name");
		loadText = getglobal("RegionListButton"..i.."Load");
		if ( index <= numRegions ) then
			name, load = GetParalleZonesInfo(index);
			nameText:SetText(name);
			nameText:SetColor(LOADLISTCOLOR[load].r, LOADLISTCOLOR[load].g, LOADLISTCOLOR[load].b);
			loadText:SetText(TEXT("LOAD_TYPE"..load));
			loadText:SetColor(LOADLISTCOLOR[load].r, LOADLISTCOLOR[load].g, LOADLISTCOLOR[load].b);

			button.index = index;
			button:Show();
			if ( index == CHARACTERSELECT_REGION_SELECTED ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		else
			button:Hide();
		end
		index = index + 1;
	end
	CharacterSelectEnterWorldButton_Update();
end

--==========================================--
--== Fast login added and moded functions ==--

function CharacterSelect_OnLoad(this)
	CHARACTER_SELECT.createIndex = 0;
	CHARACTER_SELECT.selectedIndex = 0;
	CHARACTER_SELECT.SelectedButton = nil;
	CHARACTER_SELECT.selectLast = 0;
	CHARACTER_SELECT.currentModel = "";
	this:RegisterEvent("UPDATE_CHARACTER_SELECT_LIST");
	this:RegisterEvent("UPDATE_CHARACTER_PARALLEZONE");
	this:RegisterEvent("UPDATE_SELECTED_CHARACTER");
	this:RegisterEvent("ADJUST_DISPLAY");

	local width = CharacterSelectChangeRealmButton:GetTextWidth();
	CharacterSelectChangeRealmButton:SetWidth(width + 24);

	fastLoginLoggedIn=false;

	CustomLoginVersion2:SetText("fastLogin Revisited v"..FASTLOGIN_VERSION.." by rock5")
end

function CharacterSelect_OnShow(this)
	if RealmServer and RealmServer ~= "" and RealmServer ~= " " then
		if GetCurrentRealm() ~= RealmServer then
			ChangeServerList(RealmServer)
		end
	end

	if ( AutoLoginAccount ~= 0 ) then
		CharacterSelect_Exit();
		CustomLoginButton_OnClick("..AutoLoginAccount..")
	end

	AccountLoginPasswordEdit:SetText("");
	AccountLogin:Hide();

	OpenCharacterSelect();

	CharacterList_Update();
	RegionList_Update();

	CharacterSelectZoneName:SetText("");
	CharacterSelectRealmName:SetText(GetCurrentRealm());
end

function CharacterSelect_OnHide(this)
	CloseCharacterSelect();
	fastLoginLoggedIn=true;
end

function CharacterSelect_OnUpdate(this, elapsedTime)
	if ( CHARACTER_SELECT_ROTATION_START_X ) then
		local x = GetCursorPos();
		local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_SELECT_ROTATION_START_X = x;
		SetCharacterSelectFacing(GetCharacterSelectFacing() - diff);
	end


	if (fastLoginAutoEnter and ( not fastLoginLoggedIn )) or (fastLoginLoggedIn and DoRelog) then -- rv edited
		if fastLoginRegSel then
			CHARACTERSELECT_REGION_SELECTED = fastLoginRegSel;
		end
		CharacterSelect_EnterWorld();
	end
end

function CharacterSelect_OnKeyDown(this, arg1)
	if ( arg1 == "ESCAPE" ) then
--		CharacterSelect_Exit();
		AccountLogin_Exit();
	elseif ( arg1 == "ENTER" ) then
		CharacterSelect_EnterWorld();
	end
end

function UpdateCharacterList()
	fastLoginNumChars = GetNumCharacters();
	local index = CharacterSelectListScrollBar:GetValue() + 1;
	local coords, button;
	local name, gender, mainLevel, mainClass, secLevel, secClass, zone, destroyTime;

	for i = 1, MAX_CHARACTERS_DISPLAYED do
		button = getglobal("CharacterSelectCharacterButton"..i);
		if ( index <= fastLoginNumChars ) then
			name, gender, mainLevel, mainClass, secLevel, secClass, zone, destroyTime = GetCharacterInfo(index);

			if ( gender == 0 ) then
				gender = "MALE";
			else
				gender = "FEMALE";
			end

			if ( not name ) then
				button:SetText("ERROR!!");
			else
				local infoText;
				if ( not zone ) then
					zone = "";
				end

				if ( secLevel > 0 ) then
					infoText = mainClass.." Lv "..mainLevel.." / "..secClass.." Lv "..secLevel;
				else
					infoText = mainClass.." Lv "..mainLevel;
				end

				getglobal("CharacterSelectCharacterButton"..i.."ButtonTextName"):SetText(name);
				getglobal("CharacterSelectCharacterButton"..i.."ButtonTextInfo"):SetText(infoText);
			end
			button.zone = zone;
			button.destroyTime = destroyTime;
			button.index = index;

			-- 檢本角色是否被刪除
			button:SetAlpha(1);
			if ( destroyTime ) then
				button:SetAlpha(0.5);
			end

			button:Show();
			index = index + 1;
		else
			button:Hide();
		end
	end

	if ( fastLoginNumChars == 0 ) then
		CharacterSelectDeleteButton:Disable();
	else
		CharacterSelectDeleteButton:Enable();
	end
	CharacterSelectEnterWorldButton_Update();

	if ( fastLoginNumChars < MAX_CHARACTERS_DISPLAYED ) then
		CHARACTER_SELECT.createIndex = index;
		CharacterSelectCreateButton:SetID(index);
		CharacterSelectCreateButton:Show();
	else
		CHARACTER_SELECT.createIndex = 0;
		CharacterSelectCreateButton:Hide();
	end

	if ( fastLoginNumChars == 0 ) then
		CHARACTER_SELECT.selectedIndex = 0;
		return;
	end

	--if ( CHARACTER_SELECT.selectLast == 1 ) then
	--	CHARACTER_SELECT.selectLast = 0;
	--	CharacterSelect_SelectCharacter(fastLoginNumChars, 1);
	--	return;
	--end

	-- 檢查選取項目正確性

	if (not fastLoginLoggedIn) then 																-- first login
		if fastLoginAutoEnter then 																  -- auto enter
			CHARACTER_SELECT.selectedIndex = fastLoginChrSel;
		else																						  -- no auto enter
			if ((CHARACTER_SELECT.selectedIndex == 0) or (CHARACTER_SELECT.selectedIndex > fastLoginNumChars)) then	-- ch out of range
				CHARACTER_SELECT.selectedIndex = 1
			end
		end
		CharacterSelectListScrollBar:SetValue(0);
	else																							-- not first login
		DoRelog=(fastLoginRelog or LoginNextToon or ChangeCharRelog)
		if DoRelog then																			  -- do relog
			if LoginNextToon then 																    -- user wants next toon
				if CHARACTER_SELECT.selectedIndex == fastLoginNumChars then 								      -- last character
					DoRelog=false
				else 																				      -- not last character
					CHARACTER_SELECT.selectedIndex = CHARACTER_SELECT.selectedIndex + 1
				end
			elseif ChangeCharRelog then
				CHARACTER_SELECT.selectedIndex = fastLoginChrSel
			end
		end
	end

	ChangeCharRelog=false
	LoginNextToon=false
	CharacterSelect_SelectCharacter(CHARACTER_SELECT.selectedIndex, 1);
	-- if fastLoginAutoEnter then CharacterSelect_EnterWorld() end 			--rv
end

function UpdateCharacterSelection()
	CHARACTERSELECT_RECOVER_DELETE = nil;
	CharacterSelectEnterWorldButton:SetText(TEXT("CHARACTER_ENTER_WORLD"));

	local button;
	for i = 1, MAX_CHARACTERS_DISPLAYED do
		button = getglobal("CharacterSelectCharacterButton"..i);
		if ( button.index == CHARACTER_SELECT.selectedIndex ) then
			CharacterSelectZoneName:SetText(button.zone);
			button:LockHighlight();

			-- 如果角色為刪除狀態顯示文字為回復角色
			if ( (button ~= nil) and (button.destroyTime ~= nil) ) then
				CHARACTERSELECT_RECOVER_DELETE = 1;
				CharacterSelectEnterWorldButton:SetText(TEXT("CHARACTER_SELECT_RECOVER_DELETE"));
			end
		else
			button:UnlockHighlight();
		end
	end
	if (swappingChar) then
		CHARACTER_SELECT.selectedIndex = fastLoginChrSel;
		fastLoginLoggedIn=true;
		swappingChar = false
	end
end

function CharacterSelect_EnterWorld()
	if UserSelectedChannel then
		local CurrChannel = GetCurrentParallelID()
		local NumChannels = GetNumParalleZones()

		if string.lower(UserSelectedChannel) == "next" then -- Next channel
			UserSelectedChannel = CurrChannel + 1
			if UserSelectedChannel > NumChannels then
				UserSelectedChannel = 1
			end
		elseif string.lower(UserSelectedChannel) == "random" then
			UserSelectedChannel = math.random(NumChannels)
		else
			UserSelectedChannel = tonumber(UserSelectedChannel)
		end

		CHARACTERSELECT_REGION_SELECTED = UserSelectedChannel
	end

	if ( CHARACTERSELECT_RECOVER_DELETE ) then
		LoginDialog_Show("RECOVER_DELETE_CHARACTER");
	else
		UpdateCharacterList()
		CharsLoadedCount = CharsLoadedCount + 1
		EnterWorld(CHARACTERSELECT_REGION_SELECTED);
		EnterWorld(CHARACTERSELECT_REGION_SELECTED);
	end
end

function CharacterSelect_Exit()
	DisconnectFromServer();
	SetLoginScreen("login");
end
