local VERSION = 3.1

include("addresses.lua")
include("functions.lua")

if fileExists(getExecutionPath() .. "/userfunctions/userfunction_login.lua") then
	include("userfunctions/userfunction_login.lua")
elseif fileExists(getExecutionPath() .. "/../romglobal/userfunctions/userfunction_login.lua") then
	include("../romglobal/userfunctions/userfunction_login.lua")
else
	error("Required userfunction not found: \"userfunction_login.lua\"")
end

function main()
	cprintf(cli.lightgreen,"\n    Rock5s 'login' script.")
	cprintf(cli.yellow," Version %s\n\n",VERSION)

	-- Extract args for login
	local client, account, character
	for i = #args,1,-1 do
		args[i] = string.lower(args[i])
		local foundpos = string.find(args[i], ":", 1, true);
		if( foundpos ) then
			local var = string.sub(args[i], 1, foundpos-1);
			local val = string.sub(args[i], foundpos+1);

			if( var == "client" ) then
				client = val
				table.remove(args,i)
			elseif( var == "acc" ) then
				account = tonumber(val)
				table.remove(args,i)
			elseif ( var == "char" ) then
				character = tonumber(val)
				table.remove(args,i)
			end
		end
	end

	-- Do login
	login(character, account, client)

	-- remove first arg
	table.remove(args,1)

	-- Insert first arg again
	table.insert(args,1,"bot.lua")
end

main()
include("bot.lua")
