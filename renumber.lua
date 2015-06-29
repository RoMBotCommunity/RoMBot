	--===  Version 0.2 ===--

function main()
	filename	= "";
	input_ok	= false;

	cprintf(cli.yellow,"Starting Main Function \n")
	
	repeat
		cprintf(cli.lightgreen,"\n Enter Waypoint filename to renumber WITHOUT path and extension (.xml)\n")
		cprintf(cli.lightgreen," This script creates a renumbered copy.\n")
		cprintf(cli.lightgreen," Enter X to eXit\n")
		cprintf(cli.lightgreen," > ")
		keyboardBufferClear(); -- clear keyboard buffer
		filename = io.stdin:read();
		
		if (string.lower(filename) == "x" ) then
			error("Exit.", 0);
		else
			-- filname == nil, filename == "" or not existing is checked in Renumber()
			input_ok = true;
		end;
	until input_ok;

	Renumber(filename) -- Place the name of your file in here
end

function Renumber(waypt_file)

	cprintf(cli.yellow,"Starting Renumber Function \n")
	
	if (waypt_file == nil) or (waypt_file == "") then
		cprintf(cli.red,"No file name. Usage Renumber(\"YourWaypointFile\")\nDo not enter the path or extension.\nThis script creates a renumbered copy.\n\n");
		return false
	else

		local filenameIn		= getExecutionPath() .. "/waypoints/" .. waypt_file .. ".xml";
		local filenameOut 	= getExecutionPath() .. "/waypoints/" .. waypt_file .. "_renum.xml";
		local fileIn, err		= io.open(filenameIn, "r");
		local fileOut, err	= io.open(filenameOut, "w+");
		local newLine				= "";
		local lineNumber		= 1;
		
		if fileIn and fileOut then
			for line in fileIn:lines() do
				-- remove old numbering
				line								= string.gsub (line, '^%s*<!%-%-[#%s%d_%.]+%-%->', '')
				-- add new numbering
				newLine							= string.gsub (line, '<waypoint ', '\t<!--'..string.format ("#%03.d", lineNumber)..'--><waypoint ')
				lineNumber					= lineNumber + ((newLine~=line and 1) or 0);	-- up if line changed
				-- beautifying empty waypoints
				newLine							= string.gsub (newLine, '"%s*>%s*</waypoint>', '"/>')
				newLine							= string.gsub (newLine, '"%s*/>', '"/>')
				-- beautifying waypoints with code using <![CDATA[]]>
				newLine							= string.gsub (newLine, '<!%[CDATA%[', ''); -- remove old
				newLine							= string.gsub (newLine, ']]>', '');	-- remove old
				newLine							= string.gsub (newLine, '<waypoint (.*)"%s*>%s*$', '<waypoint %1"><![CDATA[')
				newLine							= string.gsub (newLine, '<waypoint (.*)"%s*>(.*)</waypoint>%s*$', '<waypoint %1"><![CDATA[\n\t\t%2\n\t]]></waypoint>')
				newLine							= string.gsub (newLine, '^%s*</waypoint>', '\t]]></waypoint>')
				-- output
				fileOut:write(newLine .. "\n");
			end
		else
			cprintf(cli.red,"Couldn't open/create the files. Usage Renumber(\"YourWaypointFile\")\nDo not the path or extension.\nThis script creates a renumbered copy.\n\n");
			return false
		end
		
		fileIn:close();
		fileOut:close();
		cprintf(cli.green,"Done. New file is " .. waypt_file .. "_renum.xml\n");
		
		return true;
	end;
end
startMacro(main,true);