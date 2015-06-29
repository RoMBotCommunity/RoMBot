------------------------------------------------------------------
--  Rock5's BuyFromItemShop userfunction
--               Version 1.4
--
--  Syntax:
--  BuyFromItemShop(itemGUID, secondaryPassword [, number] )
--  BuyPresentFromItemShop(itemGUID, secondaryPassword, recipient [,subject] [,body])
--  guid = FindItemShopGUID(nameOrId, currency [,ammount])
--
--  Arguments:
--    itemGUID (type number) - The uniquie id of the item selection. Use FindItemShopGUID to find.
--    secondaryPassword (type string) - Your secondary password for that account
--    number (type number) - The number you want to buy of that selection. Optional. If not specified will, buy only one.
--    recipient (type string) - The person you want to send the present to.
--    subject (type string) - The subject of the message sent with the present. Optional.
--    body (type string) - The body of the message sent with the present. Optional.
--    nameOrId (type string or number) - The full name or id of the item. Not the GUID.
--    currency (type string) - The currency you wish to use. Can be "diamond", "ruby", "coin" or variations.
--    ammount (type number) - Number of items you receive, "Ammount:n". Optional. Assumes 1.
--
--  Examples:
--    To buy 2 items with GUID of 100
--       BuyFromItemShop(100, "secpass', 2)
--    To buy an item with GUID of 100 and send it as a present
--       BuyPresentFromItemShop(100, "secpass', "recipientName")
--    To find the guid of the 10 pack of charges you buy with coins.
--       guid = FindItemShopGUID(202928,"coin")

local function commonBuy(_itemGUID, _secondaryPassword, _numberOrRecipient, _subject, _body)
	if RoMScript("ItemMallFrame.OK") ~= true then
		RoMCode("ItemMallFrame:Show() ItemMallFrame:Hide()")
		print("Waiting for Item Shop database to load.")
		repeat
			yrest(50)
		until RoMScript("ItemMallFrame.OK") == true
	end
	if type(_itemGUID) ~=  "number" then
		print("You must use the Item Shop itemGUID number when using the '"..func.."' function.")
		return
	end

	if _secondaryPassword == nil then
		print("You must specify a secondary password for the '"..func.."' function to work.")
		return
	end

	local staticpopup = RoMCode("CheckPasswordState() a=StaticPopup_Visible('PASSWORD_CONFIRM') if a then _G[a..'EditBox']:ClearFocus() end")
	if staticpopup then
		RoMCode(staticpopup.."EditBox:SetText(\"".._secondaryPassword.."\")") rest(1000)
		RoMCode("StaticPopup_EnterPressed("..staticpopup..")") yrest(1000)
		RoMCode(staticpopup..":Hide()");
		yrest(1000)
		local passwordfailed = RoMScript("StaticPopup_Visible('PASSWORD_FAILED')")
		if passwordfailed then
			error("Rent(): Wrong secondary password.")
		end
	end

	RoMCode("ItemMallFrame.lock=1") yrest(500)
	if type(_numberOrRecipient) == "number" then
		RoMCode("CIMF_ShoppingBuy(".._itemGUID..",".._numberOrRecipient..")"); yrest(500) -- buy items
	else
		if _subject == nil then _subject = "Gift from "..player.Name end
		if _body == nil then _body = "" end
		RoMCode("CIMF_MailGift(".._itemGUID..", \"".._numberOrRecipient.."\", \"".._subject.."\", \"".._body.."\")"); yrest(500) -- buy items
	end

end

func = ""
function BuyFromItemShop(_itemGUID, _secondaryPassword, _number )
	if _number == nil then
		_number = 1
	else
		_number = tonumber(_number)
		if type(_number) ~= "number" then
			print("Invalid number to buy used with the 'BuyFromItemShop' function.")
			return
		end
	end

	func = "BuyFromItemShop"
	commonBuy(_itemGUID, _secondaryPassword, _number )
end

function BuyPresentFromItemShop(_itemGUID, _secondaryPassword, _recipient, _subject, _body)
	if type(_recipient) ~= "string" then
		print("Invalid recipient used with the 'BuyPresentFromItemShop' function. Type 'string' expected.")
		return
	end

	func = "BuyPresentFromItemShop"
	commonBuy(_itemGUID, _secondaryPassword, _recipient, _subject, _body )
end

function FindItemShopGUID(_nameOrId, _currency, _ammount)
	if RoMScript("ItemMallFrame.OK") ~= true then
		RoMCode("ItemMallFrame:Show() ItemMallFrame:Hide()")
		print("Waiting for Item Shop database to load.")
		repeat
			yrest(50)
		until RoMScript("ItemMallFrame.OK") == true
	end
	if type(_nameOrId) == "number" then
		_nameOrId = GetIdName(_nameOrId)
	end
	if type(_nameOrId) ~= "string" then
		print("Invalid first argument used in 'FindItemShopGUID' function. Expected full item name or id.")
		return
	end

	_currency = string.lower(_currency)
	local noSname = string.match(_currency,"^(.-)s?$") -- Take off ending 's'
	if noSname == "dia" or noSname == "diamond" or _currency == string.lower(getTEXT("SYS_MONEY_TYPE_1")) then
		_currency = 6
	elseif noSname == "rub" or noSname == "ruby" or noSname == "rubie" or _currency == string.lower(getTEXT("SYS_MONEY_TYPE_2")) then
		_currency = 7
	elseif noSname == "coin"  or _currency == string.lower(getTEXT("SYS_MONEY_TYPE_3")) then
		_currency = 8
	else
		print("Invalid second argument used in 'FindItemShopGUID' function. Expected 'diamond', 'ruby' or 'coin'.")
		return
	end

	if _ammount ~= nil and type(_ammount) ~= "number" then
		print("Invalid third argument used in 'FindItemShopGUID' function. Expected type 'number' or nil.")
		return
	end

	local guid = RoMCode([[
local c=0
repeat
	c=c+1
	a={CIMF_GetItemInfo(0,CIMF_GetTopItem(c))}
	if a[2]=="]] .. _nameOrId .. [[" and a[]] .. _currency .. [[]>0 and a[11]==]] .. (_ammount or 1) .. [[ then
		break
	end
until a[1]==0
a={a[1]}
]])
    if guid ~= 0 then
	 	return guid
	end
end