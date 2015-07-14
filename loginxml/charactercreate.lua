CHARACTER_CREATE_UPDATE_STOP = nil;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTERCREATE_SLIDERBUTTON_SCROLL_DELAY = 0.05;
CHARACTERCREATE_UPDATEMODEL = 1;

--CHARACTERCREATE_RACE_LIST = { TEXT("LOGIN_HUMAN") };
CHARACTERCREATE_RACE_LIST = { TEXT("LOGIN_HUMAN"), TEXT("LOGIN_ELF"), TEXT("LOGIN_DWARF") };
CHARACTERCREATE_GENDER_LIST1 = { TEXT("LOGIN_MALE"), TEXT("LOGIN_FEMALE") };
CHARACTERCREATE_GENDER_LIST2 = { TEXT("LOGIN_MALE") };
CHARACTERCREATE_GENDER_LIST = CHARACTERCREATE_GENDER_LIST1;

function FigureSlider_OnLoad(this)
	local partName = string.sub(this:GetName(), 13);
	local min_value, max_value, default_value = GetCharacterCreateFigureInfo(partName);

	this.step = 0.1;
	this:SetMinMaxValues(min_value, max_value);
	this:SetValue(default_value);

	getglobal(this:GetName().."Text"):SetText(TEXT("LOGIN_"..string.upper(partName)));
end

function FigureSlider_OnValueChanged(this, arg1)
	CharacterCreate_UpdateFigure();
end

function CharacterCreate_UpdateFigure()
	if ( CharacterCreate:IsVisible() ) then
		local headScale = FigureSliderHead:GetValue();
		local breastsScale = FigureSliderBreasts:GetValue();
		local statureScale = FigureSliderStature:GetValue();
		local chestScale = FigureSliderChest:GetValue();
		local figureScale = FigureSliderFigure:GetValue();
		local armScale = FigureSliderArm:GetValue();
		local forearmScale = FigureSliderForearm:GetValue();
		local handScale = FigureSliderHand:GetValue();
		local legScale = FigureSliderLeg:GetValue();
		local calfScale = FigureSliderCalf:GetValue();
		local footScale = FigureSliderFoot:GetValue();
		UpdateCharacterCreateModelBoneScale(headScale, breastsScale, statureScale, chestScale, figureScale, armScale, forearmScale, handScale, legScale, calfScale, footScale);
	end
end

g_SetLookAtFace = false;
function CharacterCreateLookAtFaceButton_OnClick()

	if( g_SetLookAtFace )then
		g_SetLookAtFace = false;
		CharacterCreateLookAtFaceButton:SetText( CHARACTERCREATE_ZOOM_IN );
	else
		g_SetLookAtFace = true;
		CharacterCreateLookAtFaceButton:SetText( CHARACTERCREATE_ZOOM_OUT );
	end
	CharacterCreate_SetLookAtFace( g_SetLookAtFace );

end

function CharacterCreate_Okay()
	local name = CharacterCreateNameEdit:GetText();
	if ( string.len(name) < 1 ) then
		LoginDialog_Show("OKAY", TEXT("CHARACTER_CREATE_NAME_ERR"));
		return;
	end

	CreateCharacter(CharacterCreateNameEdit:GetText());
	CharacterCreateOkayButton:Disable();

	LoginDialog_Show("CREATE_CHARACTER");

	g_SetLookAtFace = false;
	CharacterCreateLookAtFaceButton:SetText( CHARACTERCREATE_ZOOM_IN );
	CharacterCreate_SetLookAtFace( g_SetLookAtFace );
end

function CharacterCreate_Default()
	local min_value, max_value, default_value;
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Head");
	FigureSliderHead:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Breasts");
	FigureSliderBreasts:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Stature");
	FigureSliderStature:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Chest");
	FigureSliderChest:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Figure");
	FigureSliderFigure:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Arm");
	FigureSliderArm:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Forearm");
	FigureSliderForearm:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Hand");
	FigureSliderHand:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Leg");
	FigureSliderLeg:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Calf");
	FigureSliderCalf:SetValue(default_value);
	min_value, max_value, default_value = GetCharacterCreateFigureInfo("Foot");
	FigureSliderFoot:SetValue(default_value);
	CharacterCreate_UpdateFigure();
end

function CharacterCreate_Back()

	g_SetLookAtFace = false;
	CharacterCreateLookAtFaceButton:SetText( CHARACTERCREATE_ZOOM_IN );
	CharacterCreate_SetLookAtFace( g_SetLookAtFace );

	SetLoginScreen("charselect");
end

function CharacterCreate_OnLoad(this)
	this:RegisterEvent("CHARACTER_CREATE_SUCCESS");
	this:RegisterEvent("CHARACTER_CREATE_FAILED");
end

function CharacterCreate_OnEvent(this, event)
	if ( event == "CHARACTER_CREATE_SUCCESS" ) then
		local text;
		if ( arg1 ) then
			text = string.format("%s\n%s", CREATE_CHARACTER_SUCCESS, arg1);
		else
			text = CREATE_CHARACTER_SUCCESS;
		end
		LoginDialog_Show("CREATE_CHARACTER_SUCCESS", text);
	elseif ( event == "CHARACTER_CREATE_FAILED" ) then
		CharacterCreateOkayButton:Enable();
	end
end

function CharacterCreate_OnShow(this)
	OpenCharacterCreateModel();

	CHARACTER_CREATE_UPDATE_STOP = 1;
	LoginDropDownList_Initialize(this, CharacterCreateRaceDropDown_Initialize);
	LoginDropDownList_SetSelectedID(CharacterCreateRaceDropDown, GetCharacterRace());
	LoginDropDownList_Initialize(this, CharacterCreateGenderDropDown_Initialize);
	LoginDropDownList_SetSelectedID(CharacterCreateGenderDropDown, GetCharacterSex());
	LoginDropDownList_Initialize(this, CharacterCreateClassDropDown_Initialize);
	LoginDropDownList_SetSelectedValue(CharacterCreateClassDropDown, GetCharacterVocation());
	CharacterCreateFaceSlider_Update();
	CharacterCreateHairSlider_Update();
	--CharacterCreateFaceSlider:SetValue(GetCharacterFace());
	--CharacterCreateHairSlider:SetValue(GetCharacterHair());
	ColorDropDownList_SetSelectedID(CharacterCreateSkinColorDropDown, GetCharacterSkinIndex());

	local r, g, b = GetCharacterHairColor();
	CharacterCreateHairColorButton.r = r;
	CharacterCreateHairColorButton.g = g;
	CharacterCreateHairColorButton.b = b;
	CharacterCreateHairColorButtonTexture:SetColor(r, g, b);

	CHARACTER_CREATE_UPDATE_STOP = nil;
	CharacterCreate_UpdateModel();

	CharacterCreateNameEdit:SetText("");
	CharacterCreateOkayButton:Enable();

	local numReserveCharacter = GetReserveNumCharacters();
	if ( numReserveCharacter > 0 ) then
		CharacterCreateReserveButton:Show();

		LoginDialog_Show("RESERVE_CHARACTER");
	else
		CharacterCreateReserveButton:Hide();
	end
end

function CharacterCreate_OnHide(this)
	CloseCharacterCreateModel();
	CloseAllDropDownList();
end

function CharacterCreate_OnMouseDown(this)
	CHARACTER_CREATE_ROTATION_START_X = GetCursorPos();
end

function CharacterCreate_OnMouseUp(this)
	CHARACTER_CREATE_ROTATION_START_X = nil;
end

function CharacterCreate_OnUpdate(this, elapsedTime)
	if ( CHARACTER_CREATE_ROTATION_START_X ) then
		local x = GetCursorPos();
		local diff = (x - CHARACTER_CREATE_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_CREATE_ROTATION_START_X = x;
		SetCharacterCreateFacing(GetCharacterCreateFacing() - diff);
	end
end

function CharacterCreate_OnMouseWheel(this, delta)
end

function CharacterCreate_UpdateModel()
	if ( CharacterCreate:IsVisible() and not CHARACTER_CREATE_UPDATE_STOP ) then
		local race = LoginDropDownList_GetSelectedID(CharacterCreateRaceDropDown);
		local gender = LoginDropDownList_GetSelectedID(CharacterCreateGenderDropDown);
		local class = LoginDropDownList_GetSelectedValue(CharacterCreateClassDropDown);
		local skinColor = ColorDropDownList_GetSelectedID(CharacterCreateSkinColorDropDown);
		local hair_r = CharacterCreateHairColorButton.r;
		local hair_g = CharacterCreateHairColorButton.g;
		local hair_b = CharacterCreateHairColorButton.b;
		local face = CharacterCreateFaceSlider:GetValue();
		local hair = CharacterCreateHairSlider:GetValue();

		local location = GetImageLocation("ClassImage");
		CharacterCreateClassTexture:SetTexture(string.format("Interface\\Login\\CharacterCreate\\"..location.."\\CharacterCreate_Class%02d", class));
		ChacacterCreateClassText:SetText(TEXT(string.format("CLASS_%02d", class)));
		CharacterCreateClassScrollFrame:UpdateScrollChildRect();
		UpdateCharacterCreateModel(race, gender, class, face, hair, skinColor, hair_r, hair_g, hair_b);
		CharacterCreate_UpdateFigure();
	end
end

function CharacterCreateRotateLeftButton_OnUpdate(this, elapsed)
	if ( this:IsButtonPushed("LeftButton") ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
	end
end

function CharacterCreateRotateRightButton_OnUpdate(this, elapsed)
	if ( this:IsButtonPushed("LeftButton") ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
	end
end

function CharacterCreateSlider_Initialize(slider, mode, step)
	slider.step = step;
	if ( mode == "INT" ) then
		slider:SetValueStepMode("INT");
	elseif ( mode == "FLOAT" ) then
		slider:SetValueStepMode("FLOAT");
	end
	slider:SetMinMaxValues(0, 0);
	slider:SetValue(0);
end

function CharacterCreateSlider_Scroll(slider, left)
	local step = 1;
	if ( slider.step ) then
		step = slider.step;
	end
	if ( left ) then
		slider:SetValue(slider:GetValue() - step);
	else
		slider:SetValue(slider:GetValue() + step);
	end
end

function CharacterCreateSlider_OnMouseDown(this, left)
	CharacterCreateSlider_Scroll(this:GetParent(), left);
	this.downDelay = CHARACTERCREATE_SLIDERBUTTON_SCROLL_DELAY * 10;
end

function CharacterCreateSlider_OnUpdate(this, elapsed, left)
	if ( this:IsButtonPushed("LeftButton") and this.downDelay ) then
		this.downDelay = this.downDelay - elapsed;
		if ( this.downDelay < 0 ) then
			this.downDelay = CHARACTERCREATE_SLIDERBUTTON_SCROLL_DELAY;
			CharacterCreateSlider_Scroll(this:GetParent(), left);
		end
	end
end

-- Race DropDown
function CharacterCreateRaceDropDown_OnLoad(this)
	LoginDropDownList_Initialize(this, CharacterCreateRaceDropDown_Initialize);
	LoginDropDownList_SetSelectedID(CharacterCreateRaceDropDown, 1);
end

function CharacterCreateRaceDropDown_Initialize()
	local info;
	for index, value in pairs(CHARACTERCREATE_RACE_LIST) do
		if ( CheckCharacterCreateRace(index) ) then
			info = {};
			info.value = index;
			info.text = value;
			info.func = CharacterCreateRaceDropDown_Click;
			LoginDropDownList_AddButton(info);
		end
	end
end

function CharacterCreateRaceDropDown_Click(button)
	local id = button:GetID();
	if ( LoginDropDownList_GetSelectedID(CharacterCreateRaceDropDown) ~= id ) then
		LoginDropDownList_SetSelectedID(CharacterCreateRaceDropDown, id);

		CharacterCreate_UpdateModel();

		if ( id == 3 ) then
			CHARACTERCREATE_GENDER_LIST = CHARACTERCREATE_GENDER_LIST2;
		else
			CHARACTERCREATE_GENDER_LIST = CHARACTERCREATE_GENDER_LIST1;
		end

		LoginDropDownList_Initialize(CharacterCreateGenderDropDown, CharacterCreateGenderDropDown_Initialize);
		LoginDropDownList_SetSelectedID(CharacterCreateGenderDropDown, 1);
		LoginDropDownList_Initialize(CharacterCreateClassDropDown, CharacterCreateClassDropDown_Initialize);
		LoginDropDownList_SetSelectedValue(CharacterCreateClassDropDown, GetCharacterVocation());

		RandomCharacterCreateHair();
		RandomCharacterCreateFace();
		CharacterCreateHairSlider_Update();
		CharacterCreateFaceSlider_Update();

		local r, g, b = GetCharacterFaceColor();
		ColorDropDownList_SetSelectedID(CharacterCreateSkinColorDropDown, GetCharacterSkinIndex());
		ColorDropDownList_SetColor(CharacterCreateSkinColorDropDown, r, g, b);

		CharacterCreate_UpdateModel();
	end
end

-- Gender DropDown
function CharacterCreateGenderDropDown_OnLoad(this)
	LoginDropDownList_Initialize(this, CharacterCreateGenderDropDown_Initialize);
	LoginDropDownList_SetSelectedID(CharacterCreateGenderDropDown, 1);
end

function CharacterCreateGenderDropDown_Initialize()
	local info;
	for index, value in pairs(CHARACTERCREATE_GENDER_LIST) do
		info = {};
		info.text = value;
		info.func = CharacterCreateGenderDropDown_Click;
		LoginDropDownList_AddButton(info);
	end
end

function CharacterCreateGenderDropDown_Click(button)
	local id = button:GetID();
	if ( LoginDropDownList_GetSelectedID(CharacterCreateGenderDropDown) ~= id ) then
		LoginDropDownList_SetSelectedID(CharacterCreateGenderDropDown, id);
		CharacterCreate_UpdateModel();
		RandomCharacterCreateHair();
		RandomCharacterCreateFace();
		CharacterCreateHairSlider_Update();
		CharacterCreateFaceSlider_Update();
		CharacterCreate_UpdateModel();
	end
end

-- Class DropDown
function CharacterCreateClassDropDown_OnLoad(this)
	LoginDropDownList_Initialize(this, CharacterCreateClassDropDown_Initialize);
	LoginDropDownList_SetSelectedValue(CharacterCreateClassDropDown, 1);
end

function CharacterCreateClassDropDown_Initialize()
	CharacterCreateClassDropDown_SetClass(GetCharacterCreateClassInfo());
end

function CharacterCreateClassDropDown_SetClass(...)
	local info;
	for i = 1, arg.n, 2 do
		info = {};
		info.value = arg[i];
		info.text = arg[i+1];
		info.func = CharacterCreateClassDropDown_Click;
		LoginDropDownList_AddButton(info);
	end
end

function CharacterCreateClassDropDown_Click(button)
	local value = button.value;
	if ( LoginDropDownList_GetSelectedValue(CharacterCreateClassDropDown) ~= value ) then
		LoginDropDownList_SetSelectedValue(CharacterCreateClassDropDown, value);
		CharacterCreate_UpdateModel();
	end
end

-- Skin ColorDropDown
function CharacterCreateSkinColorDropDown_OnLoad(this)
	ColorDropDownList_Initialize(this, CharacterCreateSkinColorDropDown_Initialize);
	ColorDropDownList_SetSelectedID(CharacterCreateSkinColorDropDown, 1);
end

function CharacterCreateSkinColorDropDown_Initialize()
	local info;
	local colors = GetCharacterCreateNumSkinColors();
	for i = 1, colors do
		info = {};
		info.red, info.green, info.blue = GetCharacterCreateSkinColorInfo(i);
		info.func = CharacterCreateSkinColorDropDown_Click;
		ColorDropDownList_AddButton(info);
	end
end

function CharacterCreateSkinColorDropDown_Click(button)
	local id = button:GetID();
	if ( ColorDropDownList_GetSelectedID(CharacterCreateSkinColorDropDown) ~= id ) then
		ColorDropDownList_SetSelectedID(CharacterCreateSkinColorDropDown, id);
		CharacterCreate_UpdateModel();
	end
end

-- Hair Dropdown
function CharacterCreateHairColorButton_CallBack()
	CharacterCreateHairColorButton.r = LoginColorPickerFrame.r;
	CharacterCreateHairColorButton.g = LoginColorPickerFrame.g;
	CharacterCreateHairColorButton.b = LoginColorPickerFrame.b;
	CharacterCreateHairColorButtonTexture:SetColor(CharacterCreateHairColorButton.r, CharacterCreateHairColorButton.g, CharacterCreateHairColorButton.b);
	CharacterCreate_UpdateModel();
end

-- Hair Style
function CharacterCreateHairSlider_Update()
	local numHairs = GetCharacterCreateNumHairs(GetCharacterRace(), GetCharacterSex());

	CHARACTERCREATE_UPDATEMODEL = nil;
	if ( numHairs > 0 ) then
		CharacterCreateHairSlider:SetMaxValue(numHairs);
		CharacterCreateHairSlider:SetMinValue(1);
		CharacterCreateHairSlider:SetValue(GetCharacterHair());
	else
		CharacterCreateHairSlider:SetMaxValue(0);
		CharacterCreateHairSlider:SetMinValue(0);
		CharacterCreateHairSlider:SetValue(0);
	end
	CHARACTERCREATE_UPDATEMODEL = 1;
end

function CharacterCreateHairSlider_OnLoad(this)
	CharacterCreateSlider_Initialize(this, "INT", 1);
	CharacterCreateHairSlider_Update();
end

function CharacterCreateHairSlider_OnValueChanged(this)
	if ( CHARACTERCREATE_UPDATEMODEL ) then
		CharacterCreate_UpdateModel();
	end
end

-- Face Style
function CharacterCreateFaceSlider_Update()
	local numFaces = GetCharacterCreateNumFaces(GetCharacterRace(), GetCharacterSex());

	CHARACTERCREATE_UPDATEMODEL = nil;
	if ( numFaces > 0 ) then
		CharacterCreateFaceSlider:SetMaxValue(numFaces);
		CharacterCreateFaceSlider:SetMinValue(1);
		CharacterCreateFaceSlider:SetValue(GetCharacterFace());
	else
		CharacterCreateFaceSlider:SetMaxValue(0);
		CharacterCreateFaceSlider:SetMinValue(0);
		CharacterCreateFaceSlider:SetValue(0);
	end
	CHARACTERCREATE_UPDATEMODEL = 1;
end

function CharacterCreateFaceSlider_OnLoad(this)
	CharacterCreateSlider_Initialize(this, "INT", 1);
	CharacterCreateFaceSlider_Update();
end

function CharacterCreateFaceSlider_OnValueChanged(this)
	if ( CHARACTERCREATE_UPDATEMODEL ) then
		CharacterCreate_UpdateModel();
	end
end

--[[
function SetCharacterGender(gender)
	CharacterCreateGenderButtonMale:SetChecked(false);
	CharacterCreateGenderButtonFemale:SetChecked(false);
	if ( gender == 1 ) then
		CharacterCreateGenderButtonMale:SetChecked(true);
	elseif ( gender == 2 ) then
		CharacterCreateGenderButtonFemale:SetChecked(true);
	else
		return;
	end
	CHARACTER_CREATE_GENDER = gender;
end

function CharacterClass_OnClick(id)
	local classButton;
	for i = 1, 3 do
		classButton = getglobal("CharacterCreateClassButton"..i);
		if ( i == id ) then
			classButton:SetChecked(true);
		else
			classButton:SetChecked(false);
		end
	end
	CHARACTER_CREATE_CLASS = id;
end

function CharacterCreate_OnLoad(this)
	SetCharacterGender(CHARACTER_CREATE_GENDER);
	CharacterClass_OnClick(CHARACTER_CREATE_CLASS);
end
]]

function CharacterCreateScrollFrame_OnShow(this)
	this:UpdateScrollChildRect();
end

function CharacterCreateReserveDropdown_OnLoad(this)
	LoginDropDownList_Initialize(this, CharacterCreateReserveDropdown_Initialize, "MENU");
end

function CharacterCreateReserveDropdown_Initialize(this)
	local info;
	local numCharacters = GetReserveNumCharacters();
	local name, race, sex, class;

	for i = 1, numCharacters do
		name, race, sex, class = GetReserveCharacterInfo(i);
		info = {};
		info.text = name;
		info.func = CharacterCreateReserveDropdown_Click;
		LoginDropDownList_AddButton(info);
	end
end

function CharacterCreateReserveDropdown_Click(this)
	CharacterCreateNameEdit:SetText(this:GetText());
end

function CharacterCreateReserveButton_OnUpdate(this, elapsedTime)
	if ( this.alphaValue == nil ) then
		this.alphaValue = 0;
	end

	if ( this.state ) then
		this.alphaValue = this.alphaValue - elapsedTime;
		if ( this.alphaValue < 0 ) then
			this.alphaValue = 0;
			this.state = nil;
		end
	else
		this.alphaValue = this.alphaValue + elapsedTime;
		if ( this.alphaValue > 0.9 ) then
			this.alphaValue = 0.9;
			this.state = 1;
		end
	end
	CharacterCreateReserveButtonFlash:SetAlpha(this.alphaValue);
end

--==========================================--
--== Fast login added and moded functions ==--

function CharacterCreate_Okay()
	local name = CharacterCreateNameEdit:GetText();
	if ( string.len(name) < 1 ) then
		LoginDialog_Show("OKAY", TEXT("CHARACTER_CREATE_NAME_ERR"));
		return;
	end

	CreateCharacter(CharacterCreateNameEdit:GetText());
	CharacterCreateOkayButton:Disable();

	g_SetLookAtFace = false;
	CharacterCreateLookAtFaceButton:SetText( CHARACTERCREATE_ZOOM_IN );
	CharacterCreate_SetLookAtFace( g_SetLookAtFace );
end

function CharacterCreate_OnEvent(this, event)
	if ( event == "CHARACTER_CREATE_SUCCESS" ) then
		SetLoginScreen("charselect");
	elseif ( event == "CHARACTER_CREATE_FAILED" ) then
		CharacterCreateOkayButton:Enable();
	end
end

function CharacterCreate_OnShow(this)
	OpenCharacterCreateModel();

	CHARACTER_CREATE_UPDATE_STOP = 1;

	-- Set Character Race.
	LoginDropDownList_Initialize(this, CharacterCreateRaceDropDown_Initialize);
	if fastLoginDefaultRace ~= nil and type(fastLoginDefaultRace) == "number" and fastLoginDefaultRace > 0 and 4 > fastLoginDefaultRace then
		LoginDropDownList_SetSelectedID(CharacterCreateRaceDropDown, fastLoginDefaultRace);
	else
		LoginDropDownList_SetSelectedID(CharacterCreateRaceDropDown, GetCharacterRace());
	end

	LoginDropDownList_Initialize(this, CharacterCreateGenderDropDown_Initialize);
	LoginDropDownList_SetSelectedID(CharacterCreateGenderDropDown, GetCharacterSex());

	-- Set Character Class.
	LoginDropDownList_Initialize(this, CharacterCreateClassDropDown_Initialize);
	if fastLoginDefaultClass ~= nil and type(fastLoginDefaultClass) == "number" and fastLoginDefaultClass > 0 and 7 > fastLoginDefaultClass then
		LoginDropDownList_SetSelectedValue(CharacterCreateClassDropDown, fastLoginDefaultClass);
	else
		LoginDropDownList_SetSelectedValue(CharacterCreateClassDropDown, GetCharacterVocation());
	end

	CharacterCreateFaceSlider_Update();
	CharacterCreateHairSlider_Update();
	--CharacterCreateFaceSlider:SetValue(GetCharacterFace());
	--CharacterCreateHairSlider:SetValue(GetCharacterHair());
	ColorDropDownList_SetSelectedID(CharacterCreateSkinColorDropDown, GetCharacterSkinIndex());

	local r, g, b = GetCharacterHairColor();
	CharacterCreateHairColorButton.r = r;
	CharacterCreateHairColorButton.g = g;
	CharacterCreateHairColorButton.b = b;
	CharacterCreateHairColorButtonTexture:SetColor(r, g, b);

	CHARACTER_CREATE_UPDATE_STOP = nil;
	CharacterCreate_UpdateModel();

	-- Auto generate character name
	CharacterCreateNameEdit:SetText(GenerateName());
	CharacterCreateOkayButton:Enable();

	local numReserveCharacter = GetReserveNumCharacters();
	if ( numReserveCharacter > 0 ) then
		CharacterCreateReserveButton:Show();
		LoginDialog_Show("RESERVE_CHARACTER");
	else
		CharacterCreateReserveButton:Hide();
	end
end

function CharacterCreate_GenerateName()
	CharacterCreateNameEdit:SetText(GenerateName());
	CharacterCreateOkayButton:Enable();
end

function GenerateName()
	-- Variable holding the default or constructed name
	local TheName = getDefaultName()

	if TheName == nil then
		local min, max = 6,8 -- min and max length of name to generate.
		-- Rule for StartCons: Consolonant combinations that would work at the beginning of a name.
		local StartCons = {"b","c","d","f","g","h","j","k","l","m","n","p","r","s","t","v","w","z",
							"br","bl","cr","cl","ch","chr","dr","dw","fr","fl","gr","gl","gh","gn",
							"kr","kl","pr","pl","ph","phr","qu","sc","scr","sh","shr","sk","sl","sm",
							"sn","sp","spr","spl","squ","st","str","sw","th","thr","tr","tw","wr","wh"}
		-- Rules for EndCons: Consonant combinations that would work at the end of a name. These will be used in the middle of name too.
		local EndCons =   {"b","c","d","f","g","h","k","l","m","n","p","que","r","s","t","w",
							"rd","nd","ld","ff","rf","lf","ng","rg","gh","sh","ch","rch","th","rth","nth","ph",
							"rk","sk","lk","ll","rl","rn","gn","rp","sp","lp","ss","st","rst","ct","nt","lt"}
		-- Rule for StartVows: These will be used at the beginning of names.
		local StartVows = {"a","e","i","o","ai","ea","ei","ee","oo","oa","oi"}
		-- Rule for EndVows: These will be used in the middle and end of names.
		local EndVows =   {"a","e","i","o","u","ae","ai","ea","ei","ee","oo","oa","oi","y"}

		local NextIsVowel = #StartVows >= math.random(#StartVows+#StartCons) -- Randomly start with a vowel sound or a consonant sound
		local NameLength = math.random(min, max) -- Between min and max letters long

		-- Start the name
		if NextIsVowel then
			TheName = StartVows[math.random(#StartVows)]
		else
			TheName = StartCons[math.random(#StartCons)]
		end

		repeat
			NextIsVowel = not NextIsVowel -- Toggle
			if NextIsVowel then
				TheName = TheName .. EndVows[math.random(#EndVows)]
			else
				TheName = TheName .. EndCons[math.random(#EndCons)]
			end
		until #TheName >= NameLength
	end

	-- Capitalise
	TheName = TheName:sub(1,1):upper() .. TheName:sub(2,-1):lower()

	return TheName
end
