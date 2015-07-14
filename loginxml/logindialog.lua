--===========================================
--====== Auto login secondary password ======
--===========================================

local fastLoginSecPass = ""

--===============================================================================
--======= character secondary passes use same id as in accountlogin.lua  ========
--===============================================================================

local CustomSecondaryPass = {
	Account1	= {	SecondaryPassword = "Minako1876"	},
	Account47 = {	SecondaryPassword = "animal10"	},
	Account57 = {	SecondaryPassword = "animal10"	},
	Account68 = {	SecondaryPassword = "animal10"	},
	Account90 = {	SecondaryPassword = "animal10"	},
	Account91 = {	SecondaryPassword = "animal10"	},
	Account92 = {	SecondaryPassword = "animal10"	},
	Account93 = {	SecondaryPassword = "animal10"	},
	Account94 = {	SecondaryPassword = "animal10"	},
	Account95 = {	SecondaryPassword = "animal10"	},
	Account96 = {	SecondaryPassword = "animal10"	},
	Account98 = {	SecondaryPassword = "animal10"	},
	Account99 = {	SecondaryPassword = "animal10"	},
	Account101 = {	SecondaryPassword = "animal10"	},
}

-- Eg. If you only play on 1 server in one region
--
--	local CustomSecondaryPass = {
--		Account10 = {	SecondaryPassword = "password" },
--		Account11 = {	SecondaryPassword = "password"	},
--	}

-- Eg. If you play multiple regions
--	local CustomSecondaryPass = {
--		ENEU = {
--			Account10= {	SecondaryPassword = "password"	},
--			Account11 = {	SecondaryPassword = "password"	},
--		},
--
--		AUS = {
--			Account10 = {	SecondaryPassword = "password"	},
--			Account11 = {	SecondaryPassword = "password"	},
--		},
--	}

-- End of user options --------------------------------------------------------

local PasswordFailed = false


LoginDialogTypes = {};

LoginDialogTypes["PASSWORD_FAILED"] = {
	text = TEXT("LOGIN_PASSWORD_FAILED"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = nil,
	OnAccept = function()
		LinkActivateWeb();
		QuitGame();
	end,
	OnCancel = function()
	end,
}

LoginDialogTypes["CREATE_CHARACTER"] = {
	text = TEXT("CHARACTER_CREATING"),
	button1 = nil,
	button2 = nil,
}

LoginDialogTypes["RESERVE_CHARACTER"] = {
	text = TEXT("RESERVE_CHARACTER"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = nil,
}

LoginDialogTypes["CREATE_CHARACTER_SUCCESS"] = {
	text = TEXT("CREATE_CHARACTER_SUCCESS"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = nil,
	OnAccept = function()
		SetLoginScreen("charselect");
	end,
}

LoginDialogTypes["CANCEL"] = {
	text = "",
	button1 = TEXT("LOGIN_CANCEL"),
	button2 = nil,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

LoginDialogTypes["OKAY"] = {
	text = "",
	button1 = TEXT("LOGIN_OKAY"),
	button2 = nil,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

LoginDialogTypes["WAITING_QUEUE"] = {
	text = "",
	button1 = TEXT("LOGIN_CANCEL"),
	button2 = nil,
	OnAccept = function()
		SetSelectedRealmState(false);
		SetLoginScreen("login");
		CancelWaitingQueue();
	end,
	OnCancel = function()
		DisconnectFromServer();
		SetLoginScreen("login");
	end,
}

LoginDialogTypes["DELETE_CHARACTER"] = {
	text = TEXT("DELETE_CHARACTER"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = TEXT("LOGIN_CANCEL"),
	OnShow = function()
		LoginDialogEditBox:SetText("");
		LSKB_SetAnchor("TOP", "BOTTOM", "LoginDialog", -100, 20);
		LSKB_Open(LoginDialogEditBox_SetText);
	end,
	OnAccept = function()
		DeleteCharacter( CHARACTER_SELECT.selectedIndex, LoginDialogEditBox:GetText() );
		LoginDialogEditBox:SetText("");
		LSKB_Close();
	end,
	OnCancel = function()
		LSKB_Close();
	end,
	passwordMode = 1,
	hasEditBox = 1,
}

LoginDialogTypes["DELETE_CHARACTER_FAILED"] = {
	text = TEXT("DELETE_CHARACTER_FAILED"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

LoginDialogTypes["RECOVER_DELETE_CHARACTER"] = {
	text = TEXT("RECOVER_DELETE_CHARACTER"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = TEXT("LOGIN_CANCEL"),
	OnAccept = function()
		RecoverDeleteCharacter(CHARACTER_SELECT.selectedIndex);
	end,
	OnCancel = function()
	end,
}

LoginDialogTypes["SELECT_CHARACTER_ZONENOTEXIST"] = {
	text = TEXT("SELECT_CHARACTER_ZONENOTEXIST"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = TEXT("LOGIN_CANCEL"),
	OnAccept = function()
		EnterWorld(CHARACTER_SELECT.selectedIndex);
	end,
	OnCancel = function()
		CancelEnterWorld();
	end,
}

LoginDialogTypes["OPEN_ACTIVATE_WEB"] = {
	text = TEXT("LINK_ACTIVATE_WEB"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = TEXT("LOGIN_CANCEL"),
	OnAccept = function()
		LinkActivateWeb();
	end,
}

LoginDialogTypes["VALID_TIME_ERROR"] = {
	text = TEXT("VALID_TIME_ERROR"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		OpenActivateExecute();
		QuitGame();
	end,
}

LoginDialogTypes["RESET_PASSWORD"] = {
	text = TEXT("RESET_PASSWORD"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		OpenResetPasswordURL();
		QuitGame();
	end,
}


LoginDialogTypes["ADJUST_DISPLAY"] = {
	text = TEXT("PLZ_ADJUST_DISPLAY"),
	button1 = TEXT("LOGIN_OKAY"),
	button2 = TEXT("LOGIN_CANCEL"),
	OnAccept = function()
		LoginSettingsFrame.LSFTab = 1;
		PlaySoundByPath("sound\\interface\\ui_generic_open.mp3");
		LoginSettingsFrame:Show();
	end,
	OnCancel = function()
	end,
}

LoginDialogTypes["SERVER_FULL"] = {
	text = TEXT("LOGIN_SERVER_LIST_FULL"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
}

LoginDialogTypes["SERVER_ILLEGAL_AGE"] = {
	text = TEXT("LOGIN_ILLEGAL_AGE"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
}

LoginDialogTypes["CONFIRM_PASSWORD"] = {
	text = TEXT("LOGIN_CONFIRM_PASSWORD"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
	OnShow = function()
		LoginDialogEditBox:SetText("");
		LSKB_SetAnchor("TOP", "BOTTOM", "LoginDialog", -100, 20);
		LSKB_Open(LoginDialogEditBox_SetText);
	end,
	OnAccept = function()
		ConfirmPassword( LoginDialogEditBox:GetText() );
		LoginDialogEditBox:SetText("");
		LSKB_Close();
	end,
	passwordMode = 1,
	hasEditBox = 1,
	locked = 1,
	keyboard = 1,
}

LoginDialogTypes["CONFIRM_PASSWORD_FAILED"] = {
	text = TEXT("PASSWORD_INPUT_FAILED"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		LoginDialog_Show("CONFIRM_PASSWORD");
	end,
}

LoginDialogTypes["LOGIN_PASSWORD_THIRD"] = {
	text = TEXT("LOGIN_LOCK_CHARACTER"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		QuitGame();
	end,
	locked = 1,
}

LoginDialogTypes["LOGIN_LOCK_CHARACTER"] = {
	text = TEXT("LOGIN_LOCK_CHARACTER"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		QuitGame();
	end,
	locked = 1,
}

LoginDialogTypes["CONFIRM_PASSWORD2"] = {
	text = TEXT("LOGIN_CONFIRM_PASSWORD"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
	OnShow = function()
		LoginDialogEditBox:SetText("");
		LSKB_SetAnchor("TOP", "BOTTOM", "LoginDialog", -100, 20);
		LSKB_Open(LoginDialogEditBox_SetText);
	end,
	OnAccept = function()
		ConfirmPassword2( LoginDialogEditBox:GetText() );
		LoginDialogEditBox:SetText("");
		LSKB_Close();
	end,
	passwordMode = 1,
	hasEditBox = 1,
	locked = 1,
	keyboard = 1,
}

LoginDialogTypes["CONFIRM_PASSWORD_FAILED2"] = {
	text = TEXT("PASSWORD_INPUT_FAILED"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		LoginDialog_Show("CONFIRM_PASSWORD2");
	end,
}

LoginDialogTypes["CONFIRM_CAPTCHA_FAILED"] = {
	text = TEXT("PASSWORD_INPUT_FAILED"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
}

LoginDialogTypes["CONFIRM_CAPTCHA_TIME_EXPIRED"] = {
	text = TEXT("CAPTCHA_EXPIRED"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
}

LoginDialogTypes["CONFIRM_ENTER_WORLD"] = {
	text = "",
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		EnterWorld(CHARACTERSELECT_REGION_SELECTED);
	end,
}

function LoginDialogEditBox_SetText(text)
	LoginDialogEditBox:InsertChar(text);
end

function LoginDialog_Show(which, text, data)
	if ( LoginDiglogParent:IsVisible() ) then
		if ( LoginDialogTypes[LoginDialog.which].locked ) then
			return;
		end

		if ( LoginDialogTypes[LoginDialog.which].OnHide ) then
			LoginDialogTypes[LoginDialog.which].OnHide();
		end
	end

	if ( LoginDialogTypes[which].button2 ) then
		LoginDialogButton1:ClearAllAnchors();
		LoginDialogButton1:SetAnchor("BOTTOMRIGHT", "BOTTOM", "LoginDialog", -6, -16);
		LoginDialogButton2:ClearAllAnchors();
		LoginDialogButton2:SetAnchor("LEFT", "RIGHT", "LoginDialogButton1", 13, 0);
		LoginDialogButton2:SetText(LoginDialogTypes[which].button2);
		LoginDialogButton2:Show();
	else
		LoginDialogButton1:ClearAllAnchors();
		LoginDialogButton1:SetAnchor("BOTTOM", "BOTTOM", "LoginDialog", 0, -16);
		LoginDialogButton2:Hide();
	end

	if ( text ) then
		LoginDialogText:SetText(text);
	else
		local newText = LoginDialogTypes[which].text;
		if ( which == "CONFIRM_PASSWORD_FAILED" ) then
			newText = string.format(newText, GetPasswordErrorCount());
		elseif ( which == "CONFIRM_PASSWORD_FAILED2" ) then
			newText = string.format(newText, GetPasswordErrorCount());
		elseif ( which == "CONFIRM_CAPTCHA_FAILED" ) then
			newText = string.format(newText, GetPasswordErrorCount());
		elseif ( which == "LOGIN_LOCK_CHARACTER" ) then
			newText = string.format(newText, data);
		end
		LoginDialogText:SetText(newText);
	end

	local buttonHeight;
	if ( LoginDialogTypes[which].button1 ) then
		LoginDialogButton1:Show();
		LoginDialogButton1:SetText(LoginDialogTypes[which].button1);
		buttonHeight = LoginDialogButton1:GetHeight();
	else
		LoginDialogButton1:Hide();
		buttonHeight = 0;
	end

	LoginDialog.which = which;
	LoginDialog.data = data;

	-- Show or hide the alert icon
	if ( LoginDialogTypes[which].showAlert ) then
		LoginDialog:SetWidth(418);
		LoginDialogAlertIcon:Show();
	else
		LoginDialog:SetWidth(384);
		LoginDialogAlertIcon:Hide();
	end

	-- Editbox setup
	if ( LoginDialogTypes[which].hasEditBox ) then
		LoginDialogEditBox:Show();
		LoginDialogEditBox:SetFocus();
	else
		LoginDialogEditBox:Hide();
	end
	LoginDialogEditBox:SetPasswordMode(LoginDialogTypes[LoginDialog.which].passwordMode);

	LoginDialogButton1:GetHeight()

	if ( LoginDialogTypes[which].hasEditBox ) then
		LoginDialog:SetHeight(16 + LoginDialogText:GetHeight() + 8 + LoginDialogEditBox:GetHeight() + 8 + buttonHeight + 16);
	else
		LoginDialog:SetHeight(16 + LoginDialogText:GetHeight() + 8 + buttonHeight + 16);
	end
	LoginDiglogParent:Show();
end

function LoginDialogButton_Click(index)
	LoginDiglogParent:Hide();
	if ( index == 1 ) then
		local OnAccept = LoginDialogTypes[LoginDialog.which].OnAccept;
		if ( OnAccept ) then
			OnAccept();
		end
	else
		local OnCancel = LoginDialogTypes[LoginDialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel();
		end
	end
end

function LoginDialog_OnLoad(this)
	this:RegisterEvent("OPEN_LOGIN_DIALOG");
	this:RegisterEvent("UPDATE_LOGIN_DIALOG");
	this:RegisterEvent("CLOSE_LOGIN_DIALOG");
	this:RegisterEvent("LINK_ACTIVATE_WEB");
	this:RegisterEvent("VALID_TIME_ERROR");
	this:RegisterEvent("LOGIN_PASSWORD_FAILED");
	this:RegisterEvent("CONFIRM_PASSWORD");
	this:RegisterEvent("CONFIRM_PASSWORD_FAILED");
	this:RegisterEvent("PASSWORD_THIRD_FAILED");
	this:RegisterEvent("LOGIN_LOCK_CHARACTER");
	this:RegisterEvent("RESET_PASSWORD");
	this:RegisterEvent("CONFIRM_PASSWORD2");
	this:RegisterEvent("CONFIRM_PASSWORD_FAILED2");
end

function LoginDialog_OnShow(this)
	if ( LoginDialogTypes[this.which].OnShow ) then
		LoginDialogTypes[this.which].OnShow();
	end
end

function LoginDialog_OnEvent(this, event)
	if ( event == "OPEN_LOGIN_DIALOG" ) then
		LoginDialog_Show(arg1, arg2, arg3);
	elseif ( event == "UPDATE_LOGIN_DIALOG" ) then
		if ( arg1 and string.len(arg1) > 0 ) then
			LoginDialogText:SetText(arg1);
			local buttonText = nil;
			if ( arg2 ) then
				buttonText = arg2;
			elseif ( LoginDialogTypes[LoginDialog.which] ) then
				buttonText = LoginDialogTypes[LoginDialog.which].button1;
			end
			if ( buttonText ) then
				LoginDialogButton1:SetText(buttonText);
			end
			LoginDialog:SetHeight(32 + LoginDialogText:GetHeight() + 8 + LoginDialogButton1:GetHeight() + 16);
		end
	elseif ( event == "CLOSE_LOGIN_DIALOG" ) then
		if ( LoginDialogTypes[LoginDialog.which].locked ) then
			return;
		end
		LoginDiglogParent:Hide();
	elseif ( event == "LINK_ACTIVATE_WEB" ) then
		LoginDialog_Show("OPEN_ACTIVATE_WEB");
	elseif ( event == "VALID_TIME_ERROR" ) then
		LoginDialog_Show("VALID_TIME_ERROR");
	elseif ( event == "LOGIN_PASSWORD_FAILED" ) then
		LoginDialog_Show("PASSWORD_FAILED");
	elseif ( event == "CONFIRM_PASSWORD" ) then
		LoginDiglogParent:Hide();
		LoginDialog_Show("CONFIRM_PASSWORD");
	elseif ( event == "CONFIRM_PASSWORD_FAILED" ) then
		LoginDialog_Show("CONFIRM_PASSWORD_FAILED");
	elseif ( event == "PASSWORD_THIRD_FAILED" ) then
		LoginDialog_Show("LOGIN_PASSWORD_THIRD");
	elseif ( event == "LOGIN_LOCK_CHARACTER" ) then
		LoginDialog_Show("LOGIN_LOCK_CHARACTER", nil, math.floor((3600 - arg1)/60)+1);
	elseif ( event == "RESET_PASSWORD" ) then
		LoginDialog_Show("RESET_PASSWORD");
	elseif ( event == "CONFIRM_PASSWORD2" ) then
		LoginDiglogParent:Hide();
		LoginDialog_Show("CONFIRM_PASSWORD2");
	elseif ( event == "CONFIRM_PASSWORD_FAILED2" ) then
		LoginDialog_Show("CONFIRM_PASSWORD_FAILED2");
	end
end

function LoginDialog_EditBoxOnEnterPressed(this)
	this:ClearFocus();
end

function LoginDialog_EditBoxOnEscapePressed()
	this:ClearFocus();
end

function LoginDialog_OnKeyDown(this, key)
	local info = LoginDialogTypes[LoginDialog.which];
	if ( not info or info.ignoreKeys ) then
		return;
	end

	if ( key == "ESCAPE" ) then
		if ( LoginDialogButton2:IsVisible() ) then
			LoginDialogButton_Click(2);
		else
			LoginDialogButton_Click(1);
		end
	elseif ( key == "ENTER" ) then
		LoginDialogButton_Click(1);
	end
end

--==========================================--
--== Fast login added and moded functions ==--

local function CheckSecondaryPass()
	local data
	if CustomSecondaryPass[GetLocation()] then
		data = CustomSecondaryPass[GetLocation()]
	else
		data = CustomSecondaryPass
	end
	if data["Account"..LogID] then
		return data["Account"..LogID].SecondaryPassword
	end
	return
end

LoginDialogTypes["CONFIRM_PASSWORD"] = {
	text = TEXT("LOGIN_CONFIRM_PASSWORD"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
	OnShow = function()
		LoginDialogEditBox:SetText("");
		LSKB_SetAnchor("TOP", "BOTTOM", "LoginDialog", -100, 20);
		LSKB_Open(LoginDialogEditBox_SetText);
	end,
	OnAccept = function()
		ConfirmPassword( LoginDialogEditBox:GetText() );
		LoginDialogEditBox:SetText("");
		PasswordFailed = false
		LSKB_Close();
	end,
	passwordMode = 1,
	hasEditBox = 1,
	locked = 1,
	keyboard = 1,
}

LoginDialogTypes["CONFIRM_PASSWORD_FAILED"] = {
	text = TEXT("PASSWORD_INPUT_FAILED"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		PasswordFailed = true
		LoginDialog_Show("CONFIRM_PASSWORD");
	end,
}

LoginDialogTypes["CONFIRM_PASSWORD2"] = {
	text = TEXT("LOGIN_CONFIRM_PASSWORD"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
	end,
	OnShow = function()
		LoginDialogEditBox:SetText("");
		LSKB_SetAnchor("TOP", "BOTTOM", "LoginDialog", -100, 20);
		LSKB_Open(LoginDialogEditBox_SetText);
	end,
	OnAccept = function()
		ConfirmPassword2( LoginDialogEditBox:GetText() );
		LoginDialogEditBox:SetText("");
		PasswordFailed = false
		LSKB_Close();
	end,
	passwordMode = 1,
	hasEditBox = 1,
	locked = 1,
	keyboard = 1,
}

LoginDialogTypes["CONFIRM_PASSWORD_FAILED2"] = {
	text = TEXT("PASSWORD_INPUT_FAILED"),
	button1 = TEXT("LOGIN_OKAY"),
	OnAccept = function()
		PasswordFailed = true
		LoginDialog_Show("CONFIRM_PASSWORD2");
	end,
}

function LoginDialog_Show(which, text, data)
	if (which == "CONFIRM_PASSWORD" or which == "CONFIRM_PASSWORD2") and not PasswordFailed then
		local SecondaryPassword = CheckSecondaryPass();
		if(SecondaryPassword == nil or SecondaryPassword == "") and fastLoginAutoLogin then
			SecondaryPassword = fastLoginSecPass
		end

		if SecondaryPassword ~= nil and SecondaryPassword ~= "" then
			if which == "CONFIRM_PASSWORD" then
				ConfirmPassword(SecondaryPassword);
			else
				ConfirmPassword2(SecondaryPassword);
			end
			return
		end;
	end


	if ( LoginDiglogParent:IsVisible() ) then
		if ( LoginDialogTypes[LoginDialog.which].locked ) then
			return;
		end

		if ( LoginDialogTypes[LoginDialog.which].OnHide ) then
			LoginDialogTypes[LoginDialog.which].OnHide();
		end
	end

	if ( LoginDialogTypes[which].button2 ) then
		LoginDialogButton1:ClearAllAnchors();
		LoginDialogButton1:SetAnchor("BOTTOMRIGHT", "BOTTOM", "LoginDialog", -6, -16);
		LoginDialogButton2:ClearAllAnchors();
		LoginDialogButton2:SetAnchor("LEFT", "RIGHT", "LoginDialogButton1", 13, 0);
		LoginDialogButton2:SetText(LoginDialogTypes[which].button2);
		LoginDialogButton2:Show();
	else
		LoginDialogButton1:ClearAllAnchors();
		LoginDialogButton1:SetAnchor("BOTTOM", "BOTTOM", "LoginDialog", 0, -16);
		LoginDialogButton2:Hide();
	end

	if ( text ) then
		LoginDialogText:SetText(text);
	else
		local newText = LoginDialogTypes[which].text;
		if ( which == "CONFIRM_PASSWORD_FAILED" ) then
			newText = string.format(newText, GetPasswordErrorCount());
		elseif ( which == "CONFIRM_PASSWORD_FAILED2" ) then
			newText = string.format(newText, GetPasswordErrorCount());
		elseif ( which == "CONFIRM_CAPTCHA_FAILED" ) then
			newText = string.format(newText, GetPasswordErrorCount());
		elseif ( which == "LOGIN_LOCK_CHARACTER" ) then
			newText = string.format(newText, data);
		end
		LoginDialogText:SetText(newText);
	end

	local buttonHeight;
	if ( LoginDialogTypes[which].button1 ) then
		LoginDialogButton1:Show();
		LoginDialogButton1:SetText(LoginDialogTypes[which].button1);
		buttonHeight = LoginDialogButton1:GetHeight();
	else
		LoginDialogButton1:Hide();
		buttonHeight = 0;
	end

	LoginDialog.which = which;
	LoginDialog.data = data;

	-- Show or hide the alert icon
	if ( LoginDialogTypes[which].showAlert ) then
		LoginDialog:SetWidth(418);
		LoginDialogAlertIcon:Show();
	else
		LoginDialog:SetWidth(384);
		LoginDialogAlertIcon:Hide();
	end

	-- Editbox setup
	if ( LoginDialogTypes[which].hasEditBox ) then
		LoginDialogEditBox:Show();
		LoginDialogEditBox:SetFocus();
	else
		LoginDialogEditBox:Hide();
	end
	LoginDialogEditBox:SetPasswordMode(LoginDialogTypes[LoginDialog.which].passwordMode);

	LoginDialogButton1:GetHeight()

	if ( LoginDialogTypes[which].hasEditBox ) then
		LoginDialog:SetHeight(16 + LoginDialogText:GetHeight() + 8 + LoginDialogEditBox:GetHeight() + 8 + buttonHeight + 16);
	else
		LoginDialog:SetHeight(16 + LoginDialogText:GetHeight() + 8 + buttonHeight + 16);
	end
	LoginDiglogParent:Show();
end

function CharacterSelect_Delete()
	if( IsShiftKeyDown() ) then
		LoginDialog_Delete_All_Characters()
	else
		if ( CHARACTER_SELECT.selectedIndex > 0 ) then
			-- Fast Character Delete.
			local SecondaryPassword = CheckSecondaryPass()
			if fastLoginFastCharacterDelete and SecondaryPassword ~= nil and SecondaryPassword ~= "" and SecondaryPassword ~= "EgSecondaryPassword" then
				DeleteCharacter( CHARACTER_SELECT.selectedIndex, SecondaryPassword )
			else
				LoginDialog_Show("DELETE_CHARACTER")
			end
		end
	end
end;

-- Delete All Characters
function Delete_All_Characters()
	if ( CHARACTER_SELECT.selectedIndex > 0 ) then
		local MaxCharacters = GetNumCharacters()
		local SecondaryPassword = CheckSecondaryPass()
		for i = 1, MaxCharacters do
			CharacterSelect_SelectCharacter( i, 1 )
			if fastLoginFastCharacterDelete and SecondaryPassword ~= nil and SecondaryPassword ~= "" and SecondaryPassword ~= "EgSecondaryPassword" then
				DeleteCharacter( CHARACTER_SELECT.selectedIndex, SecondaryPassword )
			else
				LoginDialog_Show("DELETE_CHARACTER")
			end
		end
	end
end;

LoginDialogTypes["DELETE_ALL_CHARACTERS"] = {
	text = "Delete All Characters ?",
	button1 = TEXT("LOGIN_OKAY"),
	button2 = TEXT("LOGIN_CANCEL"),
	OnAccept = function()
		Delete_All_Characters()
	end,
	OnCancel = function()
	end,
};

function LoginDialog_Delete_All_Characters()
	LoginDialog_Show("DELETE_ALL_CHARACTERS")
end;

