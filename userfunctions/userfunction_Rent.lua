-- Rent userfunction by Rock5
-- Version 1.0

-- http://www.solarstrike.net/phpBB3/viewtopic.php?p=40872#p40872

local function checkServiceName(service)
	service = string.lower(service)
	if service == "mail" or service == "maillet" then
		service = "MailLet"
	elseif service == "bank" or service == "banklet" then
		service = "BankLet"
	elseif service == "auction" or service == "auctionlet" then
		service = "AuctionLet"
	elseif string.find(service,"^bag%d$") or string.find(service,"^baglet%d$") then
		service = "BagLet"..string.sub(service, -1)
	elseif string.find(service,"^bankbag%d$") or string.find(service,"^bankbaglet%d$") then
		service = "BankBag"..string.sub(service, -1)
	else
		service = nil
	end
	return service
end

function Rent(service, days, secondarypassword)
	-- Check service value and change to proper service name
	service = checkServiceName(service)
	if service == nil then
		error("Rent(): Invalid service specified. Expected \"mail\", \"bank\", \"auction\", \"bag3-6\" or \"bankbag2-5\".",2)
	end

	-- Check 'days' and convert to minutes
	days = tonumber(days)
	if type(days) ~= "number" then
		error("Rent(): Invalid value used for 'days'. Number expected.",2)
	end
	days = days * 24 * 60

	-- Look for option with same number of days
	local i = 1;
	local selection, Time, Money
	while( true )do
		Time, Money = RoMScript("TimeLet_GetLetInfo( \""..service.."\", "..i.." )")

		if( not Time )then
			if i == 1 then
				error("Rent(): The '"..service.."' service is not available.",2)
			end
			break;
		end

		if Time == days then
			selection = i
			break
		end

		i = i + 1
	end
	if not selection then
		error("Rent(): Invalid number of days. Must match one of the values in the list.")
	end

	-- Check diamonds
	local acoountMoney = RoMScript("GetPlayerMoney(\"account\")")
	if ( Money > acoountMoney ) then
		print("Rent(): Not enough diamonds. Need "..Money..". You have "..acoountMoney..".")
		return false
	end

	-- Check secondary password
	RoMScript("CheckPasswordState(); StaticPopup1EditBox:ClearFocus()")
	yrest(1000)
	local staticpopup = RoMScript("StaticPopup_Visible('PASSWORD_CONFIRM')")
	if staticpopup then
		if secondarypassword == nil then
			error("Rent(): You must specify a secondary password.")
		else
			RoMScript(staticpopup.."EditBox:SetText(\""..secondarypassword.."\")") rest(1000)
			RoMScript("StaticPopup_EnterPressed("..staticpopup..");") yrest(1000)
			RoMScript(staticpopup..":Hide();");
			yrest(1000)
			local passwordfailed = RoMScript("StaticPopup_Visible('PASSWORD_FAILED')")
			if passwordfailed then
				error("Rent(): Wrong secondary password.")
			end
		end
	end

	-- Rent it
	RoMScript("TimeLet_StoreUp( \""..service.."\" , "..selection.." )") yrest(1000)

	-- See if it worked
	local rented = tonumber(RoMScript("TimeLet_GetLetTime(\""..service.."\")"))
	if rented and rented > 0 then
		return true
	else
		print("Rent(): Failed to rent '"..service.."' service. Reason unknown.")
		return false
	end
end

function GetRent(service)
	service = checkServiceName(service)
	if service == nil then
		error("GetRent(): Invalid service specified. Expected \"mail\", \"bank\", \"auction\", \"bag3-6\" or \"bankbag2-5\".",2)
	end
	local rented = tonumber(RoMScript("TimeLet_GetLetTime(\""..service.."\")"))
	if rented and rented > 0 then
		return rented / 60 / 24 -- In Days
	else
		return 0
	end
end
