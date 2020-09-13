--[[
	Solariz ChatMOD
	Chat LINK Features
	Credit of part of this code goes  to the original ChatLink Author Yrys - Hellscream
	Visit original Chatlink page at: http://twpa.net/wow/addons/
]]

function ChatMOD_CLINK_GO(text)
		-- Check if original chatlink is loaded ?!? If so do nothing.
		if not IsAddOnLoaded("ChatLink") then
		    -- Chatlink compatibility feature
			if ( string.find(text, "CLINK:") ) then
				text = ChatMOD_CLINK_Decompose(text);
  		    end
		end;
 	    return text;
end

function ChatMOD_CLINK_CreateLink (chatstring)
	if chatstring then
	   if not IsAddOnLoaded("ChatLink") then
	   	   ChatMOD_debug("FUNCTION","ChatMOD_CLINK_CreateLink");
		   --		1.10 item links: to possibly be reactivated in a future version.
		   --		chatstring = string.gsub (chatstring, "|c(%x+)|H(item):(%d-):(%d-):(%d-):(%d-)|h%[([^%]]-)%]|h|r", "{CLINK:%2:%1:%3:%4:%5:%6:%7}")
		   --		Old item links: backward compatibility.
		   chatstring = string.gsub (chatstring, "|c(%x+)|Hitem:(%d-:%d-:%d-:%d-:%d-:%d-:%d-:%d-)|h%[([^%]]-)%]|h|r", "{CLINK:item:%1:%2:%3}")
		   chatstring = string.gsub (chatstring, "|c(%x+)|H(enchant):(%d-)|h%[([^%]]-)%]|h|r", "{CLINK:enchant:%2:%1:%3:%4}")
	   end
	   return chatstring
	end
end

function ChatMOD_CLINK_Decompose (chatstring)
	if chatstring then
		chatstring = string.gsub (chatstring, "{CLINK:item:(%x+):(%d-:%d-:%d-:%d-:%d-:%d-:%d-:%d-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
		chatstring = string.gsub (chatstring, "{CLINK:enchant:(%x+):(%d-):([^}]-)}", "|c%1|Henchant:%2|h[%3]|h|r")
		-- For backward compatibility (yeah, I should have done it before...).
		chatstring = string.gsub (chatstring, "{CLINK:(%x+):(%d-:%d-:%d-:%d-:%d-:%d-:%d-:%d-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")

		-- Forward compatibility, for future clink structure changes.
		chatstring = string.gsub (chatstring, "{CLINK(%d):%[?([^:}%]]-)%]?:([^:}]-)[^}]-}", "%2")
	end
	return chatstring
end