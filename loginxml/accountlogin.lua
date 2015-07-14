FASTLOGIN_VERSION = 3.7

--===============================================================================
--============================ login screen settings ============================
--===============================================================================
-- >>>>>>>>>>>>>>>>>>>> CHOOSE WHETHER TO AUTO LOGIN OR NOT <<<<<<<<<<<<<<<<<<<<<
fastLoginAutoLogin = false
-- >>>>>>>>>>>>>>> ENTER YOUR USERNAME BETWEEN THE QUOTES BELOW <<<<<<<<<<<<<<<<<
fastLoginUser = ""
-- >>>>>>>>>>>>>>> ENTER YOUR PASSWORD BETWEEN THE QUOTES BELOW <<<<<<<<<<<<<<<<<
local fastLoginPass = ""
--===============================================================================
--========================== character select settings ==========================
--===============================================================================
-- >>>>> CHOOSE WHETHER TO AUTO ENTER THE GAME WORLD WITH THAT CHAR OR NOT <<<<<<
fastLoginAutoEnter = false
-- >>>>>>> ENTER THE NUMBER OF THE CHARACTER YOU WANT TO BE AUTO SELECTED <<<<<<<
fastLoginChrSel = 1
-- >>>>>>>> ENTER THE NUMBER OF THE CHANNEL YOU WANT TO BE AUTO SELECTED <<<<<<<<
fastLoginRegSel = 1
-- >>>>>>>>> SHOULD WE RELOG IN AFTER RETURNING TO CHARACTER SELECTION <<<<<<<<<<
fastLoginRelog = false
-- >>> CHOOSE WHAT IS ON LOGIN BUTTONS "Account", "Server" or "AccountServer" <<<
-- >> YOU CAN ALSO CHANGE THE DISPLAY BY SHIFT/LEFT MOUSE CLICKING THE BUTTONS <<
fastLoginButtonDisplay = "AccountServer"
-- >>>>> SET RACE NUMBER FOR DEFAULT RACE SELECTION WHEN CREATING CHARACTERS <<<<
fastLoginDefaultRace = 2;	-- 1-HUMAN, 2-ELF, 3-DWARF or nil for random Race.
-- >>>>> SET GENDER NUMBER FOR DEFAULT GENDER SELECTION WHEN CREATING CHARACTERS <<<<
fastLoginDefaultGender = nil;	-- 1-MALE, 2-FEMALE or nil for random Gender.
-- >>>>>>>> SET CLASS NUMBER FOR DEFAULT CLASS WHEN CREATING CHARACTERS <<<<<<<<<
fastLoginDefaultClass = 4;	-- From 1 to 6 or nil for random Class.
-- >>>>> SET TO FALSE TO NOT SKIP THE CHARACTER DELETE CONFIRMATION DIALOG <<<<<<
fastLoginFastCharacterDelete = true
--===============================================================================
--========================== character Acc & Pass  ==============================
--===============================================================================
-- Here is a button map to help with button placement.
--
--   Account1   Account20  Account39  Account50  Account60  Account71  Account90
--   Account2   Account21  Account40  Account51  Account61  Account72  Account91
--   Account3   Account22  Account41  Account52  Account62  Account73  Account92
--   Account4   Account23  Account42  Account53  Account63  Account74  Account93
--   Account5   Account24  Account43  Account54  Account64  Account75  Account94
--   Account6   Account25                                   Account76  Account95
--   Account7   Account26                                   Account77  Account96
--   Account8   Account27                                   Account78  Account97
--   Account9   Account28                                   Account79  Account98
--   Account10  Account29                                   Account80  Account99
--   Account11  Account30                                   Account81  Account100
--   Account12  Account31                                   Account82  Account101
--   Account13  Account32                                   Account83  Account102
--   Account14  Account33  Account44    Log In   Account65  Account84  Account103
--   Account15  Account34  Account45  Account55  Account66  Account85  Account104
--   Account16  Account35  Account46  Account56  Account67  Account86  Account105
--   Account17  Account36  Account47  Account57  Account68  Account87  Account106
--   Account18  Account37  Account48  Account58  Account69  Account88  Account107
--   Account19  Account38  Account49  Account59  Account70  Account89  Account108
--===============================================================================

local CustomLogin = {
	Account1	= {	UserName = "AnGel2208",		Password = "AnGel2208", 				Server = "Muinin", Label = "Sakieta"	},
	
	Account47 = {	UserName = "TFender74",		Password = "Romrom74", 					Server = "Muinin", Label = "Vindictive"	},
	Account57 = {	UserName = "Celesteria",	Password = "Romrom74", 					Server = "Muinin", Label = "Main"	},
	Account68 = {	UserName = "FarmeRoma",		Password = "Romrom74", 					Server = "Muinin", Label = "Hexxxhexxx"	},
	
	Account90 = {	UserName = "ElfenLager1",	Password = "Romrom74", 					Server = "Muinin", Label = "Ela (90)"	},
	Account91 = {	UserName = "ElfenLager2",	Password = "Romrom74", 					Server = "Muinin", Label = "Elb (91)"	},
	Account92 = {	UserName = "ElfenLager3",	Password = "Romrom74", 					Server = "Muinin", Label = "Elc (92)"	},
	Account93 = {	UserName = "ElfenLager4",	Password = "Romrom74", 					Server = "Muinin", Label = "Eld (93)"	},
	Account94 = {	UserName = "ElfenLager5",	Password = "Romrom74", 					Server = "Muinin", Label = "Ele (94)"	},
	Account95 = {	UserName = "ElfenLager6",	Password = "Romrom74", 					Server = "Muinin", Label = "Elg (95)"	},
	Account96 = {	UserName = "ElfenLager7",	Password = "Romrom74", 					Server = "Muinin", Label = "Elh (96)"	},

	Account98 = {	UserName = "Fussimen",	Password = "Romrom74", 					Server = "Muinin", Label = "Fussimen"	},
	Account99 = {	UserName = "Beltiboy",	Password = "Romrom74", 					Server = "Muinin", Label = "Beltiboy"	},

	Account101 = {	UserName = "FarmerOpa",		Password = "TCrkEem8", 					Server = "Muinin", Label = "Logarlager"	},
}
-- Eg. If you only play on 1 server in one region
--
--	fastLoginButtonDisplay = "Account" -- Don't show server info because we only play 1 server.
--	local CustomLogin = {
--		Account10 = {	UserName = "Account1",	Password = "password", Server = "",	},
--		Account11 = {	UserName = "Account2",	Password = "password", Server = "",	},
--	}

-- Eg. If you play multiple regions
--	local CustomLogin = {
--		ENEU = {
--			Account10= {	UserName = "Account1",	Password = "password", Server = "Siochain",	},
--			Account11 = {	UserName = "Account2",	Password = "password", Server = "Smacht",	},
--		},
--
--		AUS = {
--			Account10 = {	UserName = "Account3",	Password = "password", Server = "Thalia",	},
--			Account11 = {	UserName = "Account4",	Password = "password", Server = "Thalia",	},
--		},
--	}


-- Default names to use for each account when creating new characters.
-- It will use a random name if no default name is specified.
local CharacterCreateDefaultNames = {
	Account101 = {
		'Logarlagereins',
		'Logarlagerzwo',
		'Logarlagerdrei',
		'Logarlagervier',
		'Logarlagerfünf',
		'Logarlagersechs',
		'Logarlagersieben',
	},
	Account90 = {
		'Elaone', 'Elatwo', 'Elathree', 'Elafour', 'Elafive', 'Elasix', 'Elaseven', 'Elaeight'
	},
	Account91 = {
		'Elbone', 'Elbtwo', 'Elbthree', 'Elbfour', 'Elbfive', 'Elbsix', 'Elbseven', 'Elbeight'
	},
	Account92 = {
		'Elcone', 'Elctwo', 'Elcthree', 'Elcfour', 'Elcfive', 'Elcsix', 'Elcseven', 'Elceight'
	},
	Account93 = {
		'Eldone', 'Eldtwo', 'Eldthree', 'Eldfour', 'Eldfive', 'Eldsix', 'Eldseven', 'Eldeight'
	},
	Account94 = {
		'Eleone', 'Eletwo', 'Elethree', 'Elefour', 'Elefive', 'Elesix', 'Eleseven', 'Eleeight'
	},
	Account95 = {
		'Elgone', 'Elgtwo', 'Elgthree', 'Elgfour', 'Elgfive', 'Elgsix', 'Elgseven', 'Elgeight'
	},
	Account96 = {
		'Elhone', 'Elhtwo', 'Elhthree', 'Elhfour', 'Elhfive', 'Elhsix', 'Elhseven', 'Elheight'
	},
}
-- Example:
--	local CharacterCreateDefaultNames = {
--		Account55 = {"Alphaone","Betatwo","Capathree"},
--	}

-- Multiple region example:
--
--	local CharacterCreateDefaultNames = {
--		ENEU = {
--			Account55 = {"Alphaone","Betatwo","Capathree"},
--		},
--
--		AUS = {
--			Account55 = {"Cartman","Kenny","Kyle","Stan"}
--		},
--	}

-- End of user options --------------------------------------------------------

LoginNextToon=false -- Do not change this here. Change it in game to log into next character
AutoLoginAccount=0 -- Do not change this here. Change it in game to log into other account
ChangeCharRelog=false
fastLoginLoggedInUser = ""
CharsLoadedCount = 0
local fastLoginLastPage = 1
local fastLoginCurrentPage = 1
local fastLoginShowButtonMap = false

ACCOUNTLOGIN_FADEIN_TIME1 = 0.001;
ACCOUNTLOGIN_FADEIN_TIME2 = 0.001;
ACCOUNTLOGIN_AGREEMENT = false;

LOGIN_FLASH_MAX_ALPHA = 1.2;
LOGIN_FLASH_MIN_ALPHA = 0.3;

function AccountLogin_OnShow()
	if ( GetLocation() == "JP" or GetLocation() == "HG" or GetLocation() == "SG" ) then
		AccountLoginAccountEdit:Hide();
		AccountLoginPasswordEdit:Hide();
		AccountLastAccountButton:Hide();
		AccountLoginLoginButton:Hide();
	end

	if ( GetLocation() == "JP" or GetLocation() == "HG" or GetLocation() == "SG" ) then
		UserAgreement:Hide();
		AcceptUserAgreement();
		if ( ACCOUNTLOGIN_AGREEMENT ) then
			ACCOUNTLOGIN_AGREEMENT = nil;
			AccountLoginShow();
		end
	end

	if ( ACCOUNTLOGIN_AGREEMENT ) then
		ACCOUNTLOGIN_AGREEMENT = nil;
		AccountLogin:Hide();
		UserAgreement:Show();
	else
		AccountLoginAccountEdit:SetFocus();
	end
end

function AccountLogin_OnKeyDown(this, key)
	if ( key == "ESCAPE" ) then
		AccountLogin_Exit();
	end
end

function AccountLogin_OnKeyUp(this, key)

end

function AccountLogin_OnMouseDown(this, key)

end

function AccountLogin_OnMouseUp(this, key)

end

function AccountLogin_OnUpdate(this, elapsedTime)
	if ( AccountLogin.update ) then
		AccountLogin.update = AccountLogin.update + elapsedTime;
		Alpha = ( AccountLogin.update - ACCOUNTLOGIN_FADEIN_TIME1 ) / ACCOUNTLOGIN_FADEIN_TIME2;
		if( Alpha < 0 )then
			Alpha = 0;
		elseif( Alpha > 1.0 )then
			Alpha = 1.0;
		end
		AccountLogin:SetAlpha( Alpha );

		if ( Alpha >= 1.0 ) then
			AccountLogin.update = nil;
		end
	end
end

function AccountLogin_Login()
	DefaultServerLogin(AccountLoginAccountEdit:GetText(), AccountLoginPasswordEdit:GetText());
	AccountLoginPasswordEdit:SetText("");
	AccountLoginAccountEdit:ClearFocus();
	AccountLoginPasswordEdit:ClearFocus();
end

function AccountLogin_FocusPassword()
	AccountLoginPasswordEdit:SetFocus();
end

function AccountLogin_FocusAccountName()
	AccountLoginAccountEdit:SetFocus();
end

function AccountLoginPasswordEdit_OnGained(this, arg1)

end

function AccountLoginPasswordEdit_SetText(text)
	AccountLoginPasswordEdit:InsertChar(text);
end

function AccountLogin_Exit()
	QuitGame();
end

--[[function LoginFlashFrame_OnUpdate(this, elapsedTime)
	if ( this.alphaValue == nil ) then
		this.alphaValue = 0;
	end

	if ( this.state ) then
		this.alphaValue = this.alphaValue - elapsedTime;
		if ( this.alphaValue < LOGIN_FLASH_MIN_ALPHA ) then
			this.alphaValue = LOGIN_FLASH_MIN_ALPHA;
			this.state = nil;
		end
	else
		this.alphaValue = this.alphaValue + elapsedTime;
		if ( this.alphaValue > LOGIN_FLASH_MAX_ALPHA ) then
			this.alphaValue = LOGIN_FLASH_MAX_ALPHA;
			this.state = 1;
		end
	end
	this:SetAlpha(this.alphaValue);
end]]

function AccountLogin_OnLoad()
	local imageLocation = GetImageLocation("LOGO");
	local file = "Interface\\Login\\Logo\\"..imageLocation.."\\RA_LOGO";
	AccountLogin.update = nil;
	AccountLoginVersion:SetText(GetVersion());
	AccountLoginLogo:SetTexture(file);
end

function AccountLogin_Show()
	AccountLogin.update = 0;
	AccountLogin:SetAlpha(0);
	AccountLogin:Show();
end

function AccountLoginBoard_OnLoad(this)
	this:RegisterEvent("SERVER_BOARD_UPDATE");
end

function AccountLoginBoard_OnEvent(this, event)
	if ( event == "SERVER_BOARD_UPDATE" ) then
		AccountLoginBoardText:SetText(GetServerBoardText());
		AccountLoginBoardScrollFrame:UpdateScrollChildRect();
		AccountLoginBoard:Show();
	end
end

function CompanyLogo_OnLoad(this)
	this.updateTime = 2;
	this.runewakerTime = 4;

	local imageLocation = GetImageLocation("LOGO");
	CompanyLogoTexture:SetTexture("Interface\\Login\\Logo\\"..imageLocation.."\\RunewakerLogo");
	CompanyLogoTexture2:SetTexture("Interface\\Login\\Logo\\"..imageLocation.."\\CompanyLogo");
end

function CompanyLogo_OnUpdate(this, elapsedTime)
	local updateTime = math.min(elapsedTime, 1);

	if ( this.runewakerTime ) then
		this.runewakerTime = this.runewakerTime - updateTime;
		if ( this.runewakerTime < 0 ) then
			CompanyLogoTexture:Hide();
			CompanyLogoTexture2:Show();
			this.runewakerTime = nil;
		elseif ( this.runewakerTime < 2.5 ) then
			CompanyLogoTexture:SetAlpha( this.runewakerTime );
			CompanyLogoTexture2:Show();
		end
	elseif ( this.updateTime ) then
		this.updateTime = this.updateTime - updateTime;
		if ( this.updateTime < 0 ) then
			this.updateTime = nil;
			this.fadeout = 1;
		end
	elseif ( this.fadeout ) then
		this.fadeout = this.fadeout - updateTime;

		this:SetAlpha(this.fadeout);
		if ( this.fadeout < 0 ) then
			this.fadeout = nil;
			this:Hide();

			--SetLoginScreen("login");
		end
	end
end

function UserAgreement_OnShow()
	if ( GetLocation() == "KR" ) then
		LoginKoreanImage15:Show();
		LoginKoreanImage18:Show();
		LoginKoreanImageVoilence:Show();
	else
		LoginKoreanImage15:Hide();
		LoginKoreanImage18:Hide();
		LoginKoreanImageVoilence:Hide();
	end
end

function UserAgreement_OnHide()
	LoginKoreanImage15:Hide();
	LoginKoreanImage18:Hide();
	LoginKoreanImageVoilence:Hide();
end

function VivoxUserAgreement_OnLoad(this)
	this:RegisterEvent("VIVOX_PACT");
end

function VivoxUserAgreement_Show(this)
	VivoxUserAgreementText:SetText(GetVivoxUserAgreementText());
	VivoxUserAgreementScrollFrame:UpdateScrollChildRect();
	VivoxUserAgreementOkayButton:Disable();
	VivoxUserAgreementCancelButton:Disable();

	local scrollFrame = getglobal(this:GetName().."ScrollFrame");
	local scrollbar = getglobal(scrollFrame:GetName().."ScrollBar");
	scrollbar:SetValue(0);
	local min, max = scrollbar:GetMinMaxValues();
	if ((scrollbar:GetValue() - max) == 0) then
		VivoxUserAgreement_ReadFinish();
	end
	this:Show();
end

function VivocUserAgreement_OnEvent(this, event)
	if ( event == "VIVOX_PACT" ) then
		if ( not VivoxUserAgreement:IsVisible() ) then
			VivoxUserAgreement_Show(this);
		end
	end
end

function VivoxUserAgreement_ReadFinish()
	VivoxUserAgreementOkayButton:Enable();
	VivoxUserAgreementCancelButton:Enable();
end

--==========================================--
--== Fast login added and moded functions ==--

local function ReturnLoginID(ID)
	if type(ID) == "string" then
		-- Find ID number
		for account, details in pairs(CustomLogin) do
			if details.UserName == ID then
				ID = tonumber(string.match(account,"Account(%d*)"))
				break
			end
		end
	end
	if type(ID) ~= "number" then
		return
	end
	if CustomLogin["Account"..ID] then
		local name = CustomLogin["Account"..ID].UserName
		local pass = CustomLogin["Account"..ID].Password
		local server = CustomLogin["Account"..ID].Server
		local label = CustomLogin["Account"..ID].Label

		-- Clear values if empty
		if (name == "" or name == " ") then name = nil end
		if (server == "" or server == " ") then server = nil end
		if (label == "" or label == " ") then label = nil end

		return name, pass ,server ,label ,ID
	end
end

function AccountLogin_OnShow()
	if ( fastLoginAutoLogin and ( not fastLoginTriedOnce ) ) then
		local tmpUser, tmpPass, tmpServer
		local tmpId = tonumber(fastLoginUser)
		if tmpId then
			tmpUser, tmpPass, tmpServer = ReturnLoginID(tmpId)
			if tmpUser == nil then
				tmpUser = fastLoginUser
				tmpPass = fastLoginPass
			else
				LogID = tmpId;
				RealmServer = tmpServer
			end
		else
			tmpUser = fastLoginUser
			tmpPass = fastLoginPass
		end

		AccountLoginAccountEdit:SetText(tmpUser);
		AccountLoginPasswordEdit:SetFocus();
		AccountLoginPasswordEdit:SetText(tmpPass);
		fastLoginTriedOnce=true;
		AccountLogin_Login();
	else
		AccountLoginAccountEdit:SetFocus();
	end

end

function AccountLogin_Login()
	if ( fastLoginAutoLogin and ( not fastLoginTriedOnce ) ) then
		fastLoginLoggedInUser = fastLoginUser -- rv
		DefaultServerLogin(fastLoginUser, fastLoginPass);
	else
		fastLoginLoggedInUser = AccountLoginAccountEdit:GetText() -- rv
		DefaultServerLogin(AccountLoginAccountEdit:GetText(), AccountLoginPasswordEdit:GetText());
		AccountLoginPasswordEdit:SetText("");
	end

	AccountLoginAccountEdit:ClearFocus();
	AccountLoginPasswordEdit:ClearFocus();
end

function AccountLogin_OnLoad()
	CustomLogin_OnLoad();
	local imageLocation = GetImageLocation("LOGO");
	local file = "Interface\\Login\\Logo\\"..imageLocation.."\\RA_LOGO";
	AccountLogin.update = nil;
	AccountLoginVersion:SetText(GetVersion().."    Region: "..GetLocation());
	AccountLoginLogo:SetTexture(file);
	CustomLoginVersion:SetText("fastLogin Revisited v"..FASTLOGIN_VERSION.." by rock5")
end

function CustomLogin_OnLoad()
	if type(fastLoginButtonDisplay) == "string" then
		if fastLoginButtonDisplay == "Account" then
			fastLoginButtonDisplay = 2
		elseif fastLoginButtonDisplay == "Server" then
			fastLoginButtonDisplay = 3
		else
			fastLoginButtonDisplay = 1
		end
	end

	-- Check for region specific accounts
	if CustomLogin[GetLocation()] then
		CustomLogin = CustomLogin[GetLocation()]
	end

	-- See how many pages to display
	local highest = 0
	for k,v in pairs(CustomLogin) do
		local accid = tonumber(string.match(k,"%d+"))
		if accid > highest then
			highest = accid
		end
	end

	fastLoginLastPage = math.ceil(highest/108)

	CustomLoginButtonsDisplay_Update()
end

function CustomLoginButton_OnClick(this, button)
	if fastLoginShowButtonMap == false then
		if( IsShiftKeyDown() ) then
			CustomLoginButton_ToggleDisplay()
		else
			local ID = tonumber(string.sub(this:GetName(), 18)) -- Gets the ID from the button name
			ID = ID + (108*(fastLoginCurrentPage-1))
			local Name, Pass, Server, Label, LocalLogID = ReturnLoginID(ID);
			AccountLoginAccountEdit:SetText(Name);
			AccountLoginPasswordEdit:SetText(Pass);
			LogID = LocalLogID;
			RealmServer = Server
			SetSelectedRealmState(true)
			AccountLogin_Login();
		end
	end
end

function CustomLoginButton_OnEnter(this)
	if fastLoginShowButtonMap == false then
		if this:IsEnable() then
			LoginTooltip:ClearAllAnchors();
			LoginTooltip:SetAnchor("TOPLEFT", "BOTTOM", this, 4, 0);
			if ( this.tooltip ) then
				LoginTooltip:SetText(this.tooltip.."\nShift-Click to change button display");
			else
				LoginTooltip:SetText("Shift-Click to change button display");
			end
		end
	end
end

function CustomLoginPrevNext_OnClick(this, button)
	local name = this:GetName()
	if name == "CustomLoginPrev" then
		if fastLoginShowButtonMap then
			fastLoginMapCurrentPage = fastLoginMapCurrentPage - 1
		else
			fastLoginCurrentPage = fastLoginCurrentPage - 1
		end
	elseif name == "CustomLoginNext" then
		if fastLoginShowButtonMap then
			fastLoginMapCurrentPage = fastLoginMapCurrentPage + 1
		else
			fastLoginCurrentPage = fastLoginCurrentPage + 1
		end
	end
	CustomLoginButtonsDisplay_Update()
end

function CustomLoginButtonMap_OnClick(this, button)
	if fastLoginShowButtonMap then
		fastLoginShowButtonMap = false
		this:SetText("Show Button Map")
	else
		fastLoginShowButtonMap = true
		fastLoginMapCurrentPage = fastLoginCurrentPage
		this:SetText("Hide Button Map")
	end
	CustomLoginButtonsDisplay_Update()
end

function ChangeChar(toontoload, acctoload, channel)
	if channel ~= nil then
		UserSelectedChannel = channel
	end

	if acctoload == nil or toontoload == nil or toontoload == "current" then
		acctoload = LogID
	end

	if toontoload == "current" then
		toontoload = CHARACTER_SELECT.selectedIndex
	end

	if toontoload == nil then -- User wants to load next character
		toontoload = CHARACTER_SELECT.selectedIndex
		LoginNextToon = true
	else
		ChangeCharRelog=true
	end

	local name, pass ,server ,label ,ID = ReturnLoginID(acctoload)
	if name == nil then -- not found
		return
	end

	swappingChar = true

	fastLoginChrSel = toontoload
	CHARACTER_SELECT.selectedIndex = toontoload
	LogID = ID
	RealmServer = server or ""
	fastLoginUser = name
	fastLoginPass = pass
	DisconnectFromServer()
	DefaultServerLogin(fastLoginUser,fastLoginPass)
end

function CustomLoginButtonsDisplay_Update()
	-- Update login buttons
	local button
	for i=1, 108 do
		button = getglobal("CustomLoginButton"..i);
		button:SetTextColor(1, 0.78, 0) -- Default text color
		button:Enable() -- Enable by default
		if fastLoginShowButtonMap == true then
			button:Disable()
			button:SetText("Account"..i +(fastLoginMapCurrentPage-1)*108)
			button:Show()
		else
			local Name, Pass, Server, Label = ReturnLoginID(i +(fastLoginCurrentPage-1)*108);

			-- The full displayed text based on the option
			local fullText, displayText
			if Name then -- Only display account server info if supplied
				if fastLoginButtonDisplay == 2 then -- Account names only
					fullText = Name
					displayText = string.sub(fullText,1,16)
				elseif fastLoginButtonDisplay == 3 then -- Server names only
					fullText = Server or "nil" -- in case server is not specified
					displayText = string.sub(fullText,1,16)
				else
					fullText = Name .. "/".. (Server or "nil")
					if string.len(fullText) > 16 then
						local subName = string.sub(Name, 1, 10)
						local subServer = string.sub((Server or "nil"), 1, 5 + 10 - string.len(subName))
						displayText = subName .. "/" .. subServer
					else
						displayText = fullText
					end
				end
			end

			-- Set text and tooltip
			if Label then
				button:SetText(Label);
				if fullText then
					button.tooltip = fullText
				else
					button:Disable()
					button:SetTextColor(0, 1, 0)
				end
				button:Show()
			elseif displayText then
				if fullText ~= displayText then
					button.tooltip = fullText
					button:SetText(displayText)
				else
					button.tooltip = nil
					button:SetText(displayText);
				end
				button:Show()
			else
				button:Hide()
			end
		end
	end

	-- Update page info
	if fastLoginShowButtonMap == false and fastLoginLastPage == 1 then
		-- 1 page, no need for page info
		CustomLoginPages:Hide()
		CustomLoginPrev:Hide()
		CustomLoginNext:Hide()
	else
		local page
		if fastLoginShowButtonMap then
			page = fastLoginMapCurrentPage
		else
			page = fastLoginCurrentPage
		end
		CustomLoginPages:SetText("Page ".. page)
		CustomLoginPages:Show()
		if page > 1 then
			CustomLoginPrev:Show()
		else
			CustomLoginPrev:Hide()
		end
		if fastLoginShowButtonMap or fastLoginCurrentPage < fastLoginLastPage then
			CustomLoginNext:Show()
		else
			CustomLoginNext:Hide()
		end
	end
end

function CustomLoginButton_ToggleDisplay()
	fastLoginButtonDisplay = fastLoginButtonDisplay + 1
	if fastLoginButtonDisplay > 3 then
		fastLoginButtonDisplay = 1
	end

	CustomLoginButtonsDisplay_Update()
end

function Logout()
	RealmServer = GetCurrentRealm()
	DisconnectFromServer()
end

function Console_UpdateRangeChanged(this)
	local scrollbar = getglobal(this:GetName().."ScrollBar");
	if ( not scrollbar ) then
		return;
	end

	local maxline = this:GetMultiMaxLines();
	local rangeLine = this:GetMultiRangeLines();
	if ( maxline > rangeLine ) then
		scrollbar:SetMinMaxValues(0, 1+maxline - rangeLine);
		scrollbar:SetValue(1+maxline - rangeLine);
		scrollbar:Show();
	else
		scrollbar:Hide();
	end
end

function pr(...)
	local consolebox, chatbox
	if IsEnterWorld() then
		chatbox = getglobal("DEFAULT_CHAT_FRAME")
	else
		consolebox = getglobal("ConsoleOutput")
	end

	if not consolebox and not chatbox then -- Nowhere to print
		return
	end

	local spaces = 0
	local tabsize = 4
	function printline(value, key)
		if type(value) ~= "table" then
			--if value == nil then value = "nil" end
			value = string.rep(" ",spaces)..(key and (tostring(key).."=") or "")..tostring(value)
			if chatbox then
				chatbox:AddMessage(value,.8,.8,.8)
			else
				local tt = consolebox:GetText().."\n"..value
				if #tt > 12800 then -- 12800 is the "letters" value of the ConsoleOutput editbox in accountlogin.xml
					tt = tt:sub(#tt-12800+1,#tt)
				end
				consolebox:SetText(tt,.8,.8,.8)
			end
		else
			printline((key and (tostring(key).."=") or "").."{")
			spaces=spaces + tabsize
			for k,v in pairs(value) do
				printline(v,k)
			end
			spaces=spaces - tabsize
			printline("}")
		end
	end

	local str = ""
	for k = 1, select("#", ...) do
		local v = select(k, ...)
		if type(v) ~= "table" then
			str = str .. tostring(v) .. string.rep(" ",tabsize)
		else
			if str ~= "" then
				printline(str)
				str = ""
			end
			printline(v)
		end
	end

	if str ~= "" then
		printline(str)
	end
end

function ConsoleEnter(this)
	local text = this:GetText();
	local consolebox = getglobal("ConsoleOutput")

	this:AddHistoryLine(text);
	if text == "" then
		pr("")
	else
		pr("> "..text)
	end
	local funct=loadstring(text)
	if type(funct) == "function" then
		local status,err = pcall(funct);
		if status == false then
			pr("Error: ".. (err or "nil"));
		end
	else
		pr ("Invalid Command")
	end

	this:SetText("")
end

function ConsoleKeyDown(this, key)
	if key == "`" then
		local console = getglobal("Console")
		if console:IsVisible() then
			console:Hide()
		else
			console:Show()
		end
		key = ""
	end
end

function getDefaultName()
	-- Check if there is data
	if (not CharacterCreateDefaultNames) then
		return
	end

	-- Check for region
	local data
	if CharacterCreateDefaultNames[GetLocation()] then
		data = CharacterCreateDefaultNames[GetLocation()]
	else
		data = CharacterCreateDefaultNames
	end

	-- Check if there is data for this account
	if (not LogID) or not (data["Account"..LogID]) then
		return
	end
	local thisAccountNames = data["Account"..LogID]

	-- Get list of current names
	local CurNames = {}
	for i = 1, GetNumCharacters() do
		CurNames[(GetCharacterInfo(i))] = true
	end

	-- Find first name in default names that isn't being used
	for k,v in pairs(thisAccountNames) do
		if not CurNames[v] then
			return v
		end
	end
end
