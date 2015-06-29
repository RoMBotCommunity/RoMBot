	--===  Version 0.2 ===--

function main()
	filename	= "";
	repeat
		cprintf (cli.lightgreen, "\n  Enter waypoint filename to beautify WITHOUT path and extension (.xml)\n")
		cprintf (cli.lightgreen, "  Enter X to eXit\n")
		cprintf (cli.lightgreen, "  > ")
		keyboardBufferClear(); -- clear keyboard buffer
		filename = io.stdin:read();
		
		if (string.lower(filename) == "x" ) then
			error("Exiting", 0)
		end
		if filename=='' then
			filename = fixSlashes (getOpenFileName (getExecutionPath().."/waypoints/"))
		end
		if filename~='' then
			filename = filename:gsub (getExecutionPath().."/waypoints/", ''):gsub ('.xml', '')
			break;
		end;
	until false
	beautify (filename)
end

function beautify (filename)

	if filename==nil or filename=="" then
		cprintf (cli.red,"\nNo file name specified.\n");
		return false
	end

	local filePath			= getExecutionPath().."/waypoints/"
	local fileInName		= filePath..filename..".xml"
	local fileOutName		= filePath..filename.."_copy.xml"
	
	local fileIn, err		= io.open(fileInName, "r");
	if err~=nil then
		cprintf (cli.red, "\n"..err.."\n");
		return false
	else
		local line				= ''
		local newLine			= ''
		local newLines		= {};
		local lineNum			= 1;
		
		function prepareLine (str)
			-- removing old numbering
			str							= str:gsub ('%s*<!%-%-[#%s%d_%.]+%-%->', '')
			-- removing old CDATA-tag
			str							= str:gsub ('<!%[CDATA%[', ''):gsub (']]>', '')
			-- beautifying empty waypoints
			str							= str:gsub ('"%s*>%s*</waypoint>%s*$', '"/>'):gsub ('"%s*/>%s*$', '"/>')
			-- some code beautifying
			str							= str:gsub ('%s-%(%s-', ' ('):gsub ('%(%s-%(', '((')
			str							= str:gsub ('%s-%)%s-', ')'):gsub ('%s-,%s-', ','):gsub (',', ', '):gsub (',  ', ', ')
			return str
		end
		
		for line in fileIn:lines () do
			newLine					= ((newLine=='' and '') or newLine .. '\n') .. prepareLine (line)
			newLine					= newLine:gsub ('<onload>', '<onload><![CDATA['):gsub ('</onload>', ']]></onload>');
			if not newLine:find ('<waypoint ') then					-- keep everything outside waypoints unchanged
				table.insert (newLines, newLine)	
				newLine				= ''
			else
				if newLine:find ('/%s->') then								-- waypoint without code
					newLine				= newLine:gsub ('<waypoint ', '<!--'..string.format ("#%03.d", lineNum)..'--><waypoint ')	-- add line number
					newLine				= newLine:gsub ('^%s-<', '\t<')
					table.insert (newLines, newLine)	
					newLine				= ''
					lineNum				= lineNum + 1
				elseif newLine:find ('</waypoint>') then			-- waypoint with code
					newLine				= newLine:gsub ('<waypoint ', '<!--'..string.format ("#%03.d", lineNum)..'--><waypoint ')	-- add line number
					newLine				= newLine:gsub ('^%s-<', '\t<')
					-- beautifying waypoints with code using <![CDATA[]]>
					newLine				= newLine:gsub ('<waypoint (.-)>', '<waypoint %1><![CDATA[')
					newLine				= newLine:gsub ('</waypoint>', ']]></waypoint>')
					newLine				= newLine:gsub ('[\r\n]+', '\n')
					table.insert (newLines, newLine)
					newLine				= ''
					lineNum				= lineNum + 1
				end
			end
		end
		if newLine~='' then
			table.insert (newLines, newLine)
		end
		fileIn:close();
		
		local fileOut, err	= io.open(fileOutName, "w+");
		if err~=nil then
			cprintf (cli.red, "\n"..err.."\n");
			return false
		else
			fileOut:write (table.concat (newLines, "\n"))
			fileOut:close();
			cprintf(cli.green,"\nDone. New file is "..string.gsub (fileOutName, filePath, '').."\n");
		end
	end
	return true
end

startMacro(main,true);