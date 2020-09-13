-------------------------------------------------
-- DEFAULT FUNCTIONS
-------------------------------------------------

function solColorChatNicks_OnLoad()
	-- Register Events
		this:RegisterEvent("VARIABLES_LOADED");
		this:RegisterEvent("FRIENDLIST_UPDATE");
		this:RegisterEvent("RAID_ROSTER_UPDATE");
		this:RegisterEvent("GUILD_ROSTER_UPDATE");
		this:RegisterEvent("PARTY_MEMBERS_CHANGED");
		this:RegisterEvent("GOSSIP_SHOW");
		this:RegisterEvent("CHAT_MSG_GUILD");
		this:RegisterEvent("CHAT_MSG_WHISPER");
		this:RegisterEvent("CHAT_MSG_OFFICER");
		this:RegisterEvent("CHAT_MSG_PARTY");
		this:RegisterEvent("CHAT_MSG_RAID");
		this:RegisterEvent("CHAT_MSG_RAID_LEADER");
		this:RegisterEvent("CHAT_MSG_ADDON");
		this:RegisterEvent("UNIT_FOCUS");
		this:RegisterEvent("PLAYER_TARGET_CHANGED");
		this:RegisterEvent("PLAYER_ENTERING_WORLD");
		if SCCN_disablewhocheck == 1 then this:RegisterEvent("WHO_LIST_UPDATE") end;
		this:RegisterEvent("CHAT_MSG_SYSTEM");
    -------------------------------------------------
	-- Setting Slash commands  
	-------------------------------------------------
		SlashCmdList["SCCN"] = solColorChatNicks_SlashCommand;
		SLASH_SCCN1 = "/chatmod";
		SLASH_SCCN2 = "/sccn";
		SlashCmdList["TT"] = SCCN_CMD_TT;
		SLASH_TT1 = "/wt";  
		SlashCmdList["clear"] = SCCNclearChat;
		SLASH_clear1 = "/cls";
		SLASH_clear2 = "/clear";
		SlashCmdList["ctst"] = ChatMODtest;
		SLASH_ctst1 = "/ctst";
		SlashCmdList["seen"] = ChatMOD_seen;
		SLASH_seen1 = "/seen";
end

function solColorChatNicks_OnEvent(event)
 if strsub(event, 1, 16) == "VARIABLES_LOADED" then
		-- Fade controll
		if SCCN_NOFADE == 1 then
			SCCNnofade();
		end
		-- confab compatibility
		if ( CONFAB_VERSION ) then
			SCCN_write(SCCN_CONFAB);
			SCCN_topeditbox   = 9;
		else
			-- top editbox
			SCCN_EditBox(SCCN_topeditbox);
		end
		-- chat hooks
        if SendChatMessage_Org == nil then
            SendChatMessage_Org = SendChatMessage
            SendChatMessage = ChatMOD_SendChatMessage
        end
        -- Scrollback buffer
        ChatMOD_set_chatlinebuffer();
		if ChatFrame_MessageEventHandler_Org == nil then
			ChatFrame_MessageEventHandler_Org = ChatFrame_MessageEventHandler;
			ChatFrame_MessageEventHandler = solColorChatNicks_ChatFrame_MessageEventHandler;
		  	-- Sticky 
			ChatMOD_sticky(SCCN_AllSticky);
		end
		if( SCCN_hyperlinker == 1 ) then
		  -- catches URL's
			SCCN_Org_SetItemRef = SetItemRef;
			SetItemRef = SCCN_SetItemRef;
		end
		if Chronos == nil then
			-- no chronos, direct purge
			SCCN_write("ChatMOD SVN Revision "..CHATMOD_COLOR["YELLOW"]..CHATMOD_REVISION.."|r loaded!");
			-- doing auto purge event
			solColorChatNicks_PurgeDB();
		else
			Chronos.schedule(3,SCCN_write,"ChatMOD SVN Revision "..CHATMOD_COLOR["YELLOW"]..CHATMOD_REVISION.."|r loaded! "..CHATMOD_COLOR["SILVER"].."(Chronos found)");
			-- doing auto purge event 30 sec delayed
			Chronos.schedule(5,solColorChatNicks_PurgeDB);
			-- map pins
		end
		SCCN_write("Check out "..CHATMOD_COLOR["YELLOW"].."htt".."p://w".."ww.so".."la".."riz.".."de");
		-- refill
		if IsInGuild() then GuildRoster(); end
		if GetNumFriends() > 0 then ShowFriends(); end
		-- store original chat Editbox history buffer size
		SCCN_EditBoxKeysToggle(SCCN_editboxkeys);
		-- replacing chat some customized strings
		SCCN_CustomizeChatString(SCCN_chatstring);
		-- config dialog fillin
		SCCN_Config_OnLoad();

		-- Sound dialog setup
		SCCN_CHATSOUND_ONLOAD();
 elseif ( event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_GUILD" or event == "CHAT_MSG_OFFICER" or event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") then
		local msgtype = string.sub (event, 10)
		if SCCN_chatsound then
			if ( SCCN_chatsound[1] or SCCN_chatsound[2] or SCCN_chatsound[3] or SCCN_chatsound[4] or SCCN_chatsound[5] ) then
				if msgtype then
                        ChatMOD_debug("ChatSound msgtype",msgtype);
						if( SCCN_chatsound[5] > 0 and msgtype == "WHISPER" ) then
						    -- arg1=text, arg2=author
						    if( string.len(arg1) > 2 and arg2 ) then
								SCCN_PLAYSOUND(SCCN_chatsound[5]);
							end;
						elseif( SCCN_chatsound[4] > 0 and msgtype == "RAID" ) then
							SCCN_PLAYSOUND(SCCN_chatsound[4]);
						elseif( SCCN_chatsound[3] > 0 and msgtype == "PARTY" ) then
							SCCN_PLAYSOUND(SCCN_chatsound[3]);
						elseif( SCCN_chatsound[2] > 0 and msgtype == "OFFICER" ) then
							SCCN_PLAYSOUND(SCCN_chatsound[2]);
						elseif( SCCN_chatsound[1] > 0 and msgtype == "GUILD" ) then
							SCCN_PLAYSOUND(SCCN_chatsound[1]);
						end
				end
			end
		end
 elseif strsub(event, 1, 17) == "FRIENDLIST_UPDATE" then
	solColorChatNicks_InsertFriends();	
 elseif strsub(event, 1, 19) == "GUILD_ROSTER_UPDATE" then
	solColorChatNicks_InsertGuildMembers();
 elseif strsub(event, 1, 18) == "RAID_ROSTER_UPDATE" then
	solColorChatNicks_InsertRaidMembers();
 elseif strsub(event, 1, 21) == "PARTY_MEMBERS_CHANGED" then
	solColorChatNicks_InsertPartyMembers();
 elseif ( event == "GOSSIP_SHOW" and not IsControlKeyDown() ) then
		SCCN_GOSSIP();
 elseif event == "UNIT_FOCUS" or event == "PLAYER_TARGET_CHANGED" then
		solColorChatNicks_InsertTarget();
 elseif event == "WHO_LIST_UPDATE" and SCCN_disablewhocheck == 1 then
		solColorChatNicks_InsertWhoList();
 elseif event == "CHAT_MSG_SYSTEM" and SCCN_disablewhocheck == 1 then
		  solColorChatNicks_InsertWhoText(arg1);
 elseif event == "CHAT_MSG_ADDON" then
        if( arg1 == ChatMOD_COM_ID) then
		  -- arg1 = Addon
		  -- arg2 = Var
		  -- arg3 = Target  (RAID, GUILD, PARTY)
		  -- arg4 = name ???
		  if( arg2 ~= nil and arg3 ~= nil and arg4 ~= nil ) then
		  	  ChatMOD_COM_Parse(arg2,arg3,arg4);
		  end
 		end
 elseif event == "PLAYER_ENTERING_WORLD" then		  
		-- event on world entering
        -- select default chatframe1
        if( SCCN_JOINEDDEF == nil ) then
       		FCF_SelectDockFrame(ChatFrame1);
       		SCCN_JOINEDDEF = true;
       		ChatMOD_set_chatlinebuffer();
		end;
 end
end

function solColorChatNicks_PurgeDB()
	SCCN_purged = 0;
	SCCN_keept  = 0;
	SCCN_OldStorage = SCCN_storage;
	SCCN_storage = nil;
	SCCN_storage = {};
	table.foreach(SCCN_OldStorage, solColorChatNicks_PurgeEntry);
	SCCN_write("Purged: "..SCCN_purged..", Keept: "..SCCN_keept);
	SCCN_write("Memory currently used by ChatMOD Addon: "..ChatMOD_GetAddOnMemoryUsage().." Kb");
	SCCN_OldStorage = nil;
	SCCN_purged = nil;
end

function ChatMOD_GetAddOnMemoryUsage()
    -- New Function since 2.x to get the exact amount of used memory for addon's
	UpdateAddOnMemoryUsage()
	return floor(GetAddOnMemoryUsage('ChatMOD'))
end

function solColorChatNicks_PurgeEntry(k,v)
		if( (SCCN_OldStorage[k]["t"] + (3600*24*7*SCCN_PURGEWEEKS) ) < time() ) then 
			SCCN_purged = SCCN_purged + 1;
		else
			local keyName = ChatMOD_prepName(k);
			SCCN_storage[keyName] = { t=SCCN_OldStorage[k]["t"], c=SCCN_OldStorage[k]["c"], l=SCCN_OldStorage[k]["l"] }
			SCCN_keept = SCCN_keept + 1;
		end
end

function ChatMOD_prepName(name)
	if name then 
		return string.lower(name)
	end
end

function SCCN_write(msg)
	if( msg ~= nil ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffaad372".."Chat".."|cfffff468".."MOD".."|cffffffff: "..msg);
	end
end

function ChatMOD_sticky(state)
			if state == 1 then
				ChatTypeInfo["SAY"].sticky 		= 1;
				ChatTypeInfo["PARTY"].sticky 	= 1;
				ChatTypeInfo["GUILD"].sticky 	= 1;
				ChatTypeInfo["WHISPER"].sticky 	= 0; -- Use the 'R' key ;p 
				ChatTypeInfo["RAID"].sticky 	= 1;
				ChatTypeInfo["OFFICER"].sticky 	= 1;
				ChatTypeInfo["CHANNEL"].sticky 	= 1;
				ChatTypeInfo["CHANNEL1"].sticky 	= 1;
				ChatTypeInfo["CHANNEL2"].sticky 	= 1;
				ChatTypeInfo["CHANNEL3"].sticky 	= 1;
				ChatTypeInfo["CHANNEL4"].sticky 	= 1;
				ChatTypeInfo["CHANNEL5"].sticky 	= 1;
				ChatTypeInfo["CHANNEL6"].sticky 	= 1;
				ChatTypeInfo["CHANNEL7"].sticky 	= 1;
				ChatTypeInfo["CHANNEL8"].sticky 	= 1;
				ChatTypeInfo["CHANNEL9"].sticky 	= 1;
			else
				-- blizzards default stiky behavior
				ChatTypeInfo["SAY"].sticky 		= 1;
				ChatTypeInfo["PARTY"].sticky 	= 1;
				ChatTypeInfo["GUILD"].sticky 	= 1;
				ChatTypeInfo["WHISPER"].sticky 	= 0;
				ChatTypeInfo["RAID"].sticky 	= 1;
				ChatTypeInfo["OFFICER"].sticky 	= 0;
				ChatTypeInfo["CHANNEL"].sticky 	= 0;
				ChatTypeInfo["CHANNEL1"].sticky 	= 0;
				ChatTypeInfo["CHANNEL2"].sticky 	= 0;
				ChatTypeInfo["CHANNEL3"].sticky 	= 0;
				ChatTypeInfo["CHANNEL4"].sticky 	= 0;
				ChatTypeInfo["CHANNEL5"].sticky 	= 0;
				ChatTypeInfo["CHANNEL6"].sticky 	= 0;
				ChatTypeInfo["CHANNEL7"].sticky 	= 0;
				ChatTypeInfo["CHANNEL8"].sticky 	= 0;
				ChatTypeInfo["CHANNEL9"].sticky 	= 0;
			end
end

-------------------------------------------------
-- CHAT FRAME MANIPULATION FUNCTIONS
-------------------------------------------------
function SCCNclearChat()
	local chatFrame;
	for i = 1, 7 do
		chatFrame = getglobal("ChatFrame"..i);
		if( (chatFrame ~= nil) and chatFrame:IsVisible() ) then
			chatFrame:Clear();
		end
	end
end

function SCCNnofade()
	if SCCN_NOFADE == 1 then
		for i=1,7 do
			local frame = getglobal("ChatFrame"..i)
			frame:SetFading(0)
			frame:SetTimeVisible(3600)
		end
	else
		for i=1,7 do
			local frame = getglobal("ChatFrame"..i)
			frame:SetFading(1)
			frame:SetTimeVisible(300)
		end	
	end
end

function ChatMOD_set_chatlinebuffer()
	if SCCN_SCROLLBACK_BUFFER ~= 128 then
       for i=1,NUM_CHAT_WINDOWS do
         getglobal("ChatFrame"..i):SetMaxLines(SCCN_SCROLLBACK_BUFFER);
       end
	end
end;

function solColorChatNicks_ChatFrame_MessageEventHandler(event)
		if( not this.ORG_AddMessage ) then
			this.ORG_AddMessage = this.AddMessage
			this.AddMessage = S_AddMessage
		end;
        -- GM workaround
	    if ( event == "CHAT_MSG_WHISPER" ) then
		   if (arg6 == "GM") then
              ChatMOD_debug("solColorChatNicks_ChatFrame_MessageEventHandler","GM Message, skip all filters")
              ChatFrame_MessageEventHandler_Org(event);
		   end
        end
		if SCCN_colornicks == 1 then
			this.solColorChatNicks_Name = arg2;
		end
		-- Strip channel name
		if arg9 and event ~= nil and event ~= "CHAT_MSG_CHANNEL_NOTICE" then
			local _, _, strippedChannelName = string.find(arg9, "(.-)%s.*");
			this.solColorChatNicks_Channelname = strippedChannelName;
		end	 
	 -- Call original handler
	if (ChatFrame_MessageEventHandler_Org) then
       ChatFrame_MessageEventHandler_Org(event)
    end
end

function S_AddMessage(this,text,r,g,b,id,addToStart)
	if ( addToStart ) then
        -- skip filtering of Combat Log reorderd messages
		this:ORG_AddMessage(text,r,g,b,id,addToStart)
        return
    end
    if text and event and string.find(event,"CHAT_MSG") then
		-- Check to Ignore / Hide spam of GEM and CTRA / CastParty
		-- this:ORG_AddMessage(text,r,g,b,id);
		local SkipMessage = false;
		if text then
			if string.find(text, "<GEM%d*%p%d*>") 	then SkipMessage = true end;   	-- Guild Event Manager
			if string.find(text, "SYNCE_") 			then SkipMessage = true end;	-- Damage Meters
			if string.find(text, "SYNC_") 			then SkipMessage = true end;	-- Damage Meters
			if string.find(text, "<HA%d>%d*") 		then SkipMessage = true end;	-- Heal Assist
			if string.find(text, "RN%s%d*%s%d*%s%d*") 		then SkipMessage = true end;	-- RA
			if string.find(text, "KLHTM%s")			then SkipMessage = true end; 	-- KLH Threat Meter
			if string.find(text, "%s<CECB>%s") 		then SkipMessage = true end;   	-- CECB
		end
		if text == nil or SkipMessage == true then
			-- this:ORG_AddMessage(text,r,g,b,id);
			SkipMessage = false;
			return false;
		end
		-- ChatLink Support
		if( SCCN_CHATLINK == 1 ) then
			text = ChatMOD_CLINK_GO(text);
		end
	    
		-- URL detection
		if( SCCN_hyperlinker == 1 and text ~= nil ) then
			SCCN_URLFOUND = nil;
			-- numeric IP's 123.123.123.123:12345
			if SCCN_URLFOUND == nil then text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", SCCN_GetURL); end;
			-- TeamSpeak like IP's sub.domain.org:12345 or domain.de:123
			if SCCN_URLFOUND == nil then text = string.gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", SCCN_GetURL); end;
			-- complete http urls
			if SCCN_URLFOUND == nil then text = string.gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", SCCN_GetURL); end;
			-- www.URL.de
			if SCCN_URLFOUND == nil then text = string.gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", SCCN_GetURL); end;
			-- test@test.de
			if SCCN_URLFOUND == nil then text = string.gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", SCCN_GetURL); end;
		end	  
		-- clickinvite
		if( SCCN_clickinvite == 1 and text ~= nil and arg2 ~= nil ) then
		 SCCN_INVITEFOUND = nil; 
		 -- invite
		 if SCCN_INVITEFOUND == nil then text = string.gsub(text, "%s+(invite)(.?)", SCCN_ClickInvite,1); end
		 if SCCN_INVITEFOUND == nil then text = string.gsub(text, "%s+(inv)(.?)", SCCN_ClickInvite,1); end
		 if SCCN_INVITEFOUND == nil and SCCN_CUSTOM_INV ~= nil then
				-- custom invite word in localization
			for i=0, table.getn(SCCN_CUSTOM_INV) do
				if SCCN_INVITEFOUND == nil then text = string.gsub(text, "%s+("..SCCN_CUSTOM_INV[i]..")(.?)", SCCN_ClickInvite,1); end
			end
		 end
		end		

		if SCCN_hidechanname == 1 and this.solColorChatNicks_Channelname then
			-- Remove channel name	
			text = string.gsub(text, ".%s" .. this.solColorChatNicks_Channelname, "", 1);
			this.solColorChatNicks_Channelname = nil;	  
		end
		if ( (SCCN_hidechanname == 1) and text ~= nil ) then  
			-- Strip custom Channels
			local text_new = string.gsub(text,"%[(%d*)%p%s(%a*)%]%s",SCCN_STRIPCHANNAMEFUNC_NEW);
			if text_new ~= nil and text ~= text_new then
				text = text_new;
			else
				--remove Guild, Party, Raid from chat channel name  
				for i=1, table.getn(SCCN_STRIPCHAN) do
					-- text = string.gsub(text, "(%[)(%d?)(.?%s?"..SCCN_STRIPCHAN[i].."%s?)(%])(%s?)", SCCN_STRIPCHANNAMEFUNC,1);
					text = string.gsub(text, "(%[)("..SCCN_STRIPCHAN[i].."?)(%])(%s?)", SCCN_STRIPCHANNAMEFUNC,1);
				end
			end
		elseif ( SCCN_shortchanname == 1 ) then
			-- Short Channel Names
			local temp = nil;
			if text ~= nil then
				for i = 1, 9 do
					if SCCN_Chan_Replace[i] ~= nil and SCCN_Chan_ReplaceWith[i] ~= nil then
						temp = string.gsub(text, SCCN_Chan_Replace[i].."]%s", SCCN_Chan_ReplaceWith[i].."] ", 1)
						if temp ~= text then
							text = temp;
							temp = nil;
							break;
						end
					end		
				end
			end
		end
			
		-- color self in text
		if( SCCN_selfhighlight == 1 and text ~= nil ) then
			if( arg8 ~= 3 and arg8 ~= 4 ) then
				if( arg2 ~= nil and arg2 ~= UnitName("player") and UnitName("player") ~= nil and string.len(text) >= string.len(UnitName("player")) ) then
					if string.find(string.lower(text), string.lower(UnitName("player"))) then
						text = string.gsub(text, "[^:^%[]".."("..UnitName("player")..")" , " "..CHATMOD_COLOR["YELLOW"]..">"..CHATMOD_COLOR["RED"].."%1"..CHATMOD_COLOR["YELLOW"].."<|r");
						text = string.gsub(text, "[^:^%[]".."("..string.lower(UnitName("player"))..")" , " "..CHATMOD_COLOR["YELLOW"]..">"..CHATMOD_COLOR["RED"].."%1"..CHATMOD_COLOR["YELLOW"].."<|r");
						-- On Screen Msg
						if( SCCN_selfhighlightmsg == 1 ) then
							if SCCNOnScreenMessage ~= text then
								-- anti spam, twice line output fix
								SCCNOnScreenMessage = text;
								UIErrorsFrame:AddMessage(text, 1, 1, 1, 1.0, UIERRORS_HOLD_TIME);
								PlaySound("FriendJoinGame");
							end
						end
					end
				end
			end
		end

		-- Custom Highlight /SCCN highlight
		SCCN_Custom_Highlighted = false;
		if SCCN_Custom_Highlighted == false then text = SCCN_CustomHighlightProcessor(text,SCCN_Highlight_Text[1]); end;
		if SCCN_Custom_Highlighted == false then text = SCCN_CustomHighlightProcessor(text,SCCN_Highlight_Text[2]); end;
		if SCCN_Custom_Highlighted == false then text = SCCN_CustomHighlightProcessor(text,SCCN_Highlight_Text[3]); end;


		-- Name Highlight in chat text
		if text and SCCN_InChatHighlight == 1 and arg8 ~= 3 and arg8 ~= 4 and SCCN_URLFOUND == nil and SCCN_INVITEFOUND == nil then
			local rWord = "";
			for rWord in string.gmatch(text, "%w+") do
				if rWord ~= arg2 and string.len(rWord) > 3 and string.find(rWord,"|") == nil and string.find(rWord,"^%x*$") == nil and string.find(rWord,"^%a*$") ~= nil then
					if SCCN_selfhighlight == 1 and ( rWord == UnitName("player") or rWord == string.lower(UnitName("player")) )then
					-- blub
					else
						-- check if name blacklisted if yes skip this name
						local temp = string.lower(rWord);
						if SCCN_IGNORE_HNAMES[temp] ~= 1 and string.len(solColorChatNicks_GetColorFor(rWord)) > 3 then
							local xName = "|r"..SCCN_ColorNickName(rWord);
							if (string.len(xName)-string.len(rWord)) > 3 then
						        xName = "|Hplayer:"..rWord.."|h"..xName.."|h";
								--text = string.gsub(text,rWord.."([^%]%d%a])",xName.."|r%1");
								text = string.gsub(text,"%s"..rWord," "..xName);
							end
						end
					end
				end
			end
		end
		
			
		-- color nick's
		if this.solColorChatNicks_Name and string.len(this.solColorChatNicks_Name) > 2  and text ~= nil and arg2 ~= nil then
           local outputName = this.solColorChatNicks_Name;
		   if( SCCN_SHOWLEVEL == 1 ) then
				-- Level display
				local LOWname = ChatMOD_prepName(this.solColorChatNicks_Name);
				local level = nil;
				if( LOWname ~= nil and string.len(LOWname) > 2 ) then
				    if( SCCN_storage[LOWname] ~= nil ) then
						level = SCCN_storage[LOWname]["l"];
					end;
				end;
				if( level ~= nil and SCCN_SHOWLEVEL == 1) then
				    outputName = this.solColorChatNicks_Name..":"..level;
				end
			end;
			-- OLD: text = string.gsub(text, "(.-)"..this.solColorChatNicks_Name .. "([%]%s].*)", "%1"..solColorChatNicks_GetColorFor(this.solColorChatNicks_Name)..outputName.."|r%2", 1);
			-- Nickname
			local temp = string.lower(this.solColorChatNicks_Name);
			if SCCN_IGNORE_HNAMES[temp] ~= 1 then
                if string.len(solColorChatNicks_GetColorFor(this.solColorChatNicks_Name)) > 3 then
			       text = string.gsub(text, "(.-)"..this.solColorChatNicks_Name .. "([%]%s].*)", "%1|r"..solColorChatNicks_GetColorFor(this.solColorChatNicks_Name)..outputName.."|r%2", 1);
				end;
			end
		end
		this.solColorChatNicks_Name = nil;
		
		-- Icon Mark
		if( SCCN_SHOWICON == 1) then
           if( arg2 == UnitName("player") ) then    -- Self
               text = SCCN_AddIcon("self")..text;
           elseif( event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_OFFICER") then -- Important Icon
               text = SCCN_AddIcon("important")..text;
           elseif( event == "CHAT_MSG_PARTY" ) then     -- Group Event
               text = SCCN_AddIcon("group")..text;
           elseif( SCCN_InMyGuild(arg2) == true ) then    -- Guildy
               text = SCCN_AddIcon("guild")..text;
           elseif( SCCN_IsMyFriend(arg2) == true ) then    -- Friendlist
               text = SCCN_AddIcon("friend")..text;
           end
        end

		-- Timestamp
		if( SCCN_timestamp == 1 and text ~= nil ) then
			-- fix for timestamp error on other OS than windows, mentioned by Nevarin on world of war
			local hour =		tonumber(string.sub(date("%x %X"), 10, 11));
			local minute=	tonumber(string.sub(date("%x %X"), 13, 14));
			local second=	tonumber(string.sub(date("%x %X"), 16, 17));
			local periode = "";
			local hour12  = "";
			if hour > 0 and hour < 12 then
				periode = "am";
				hour12  = hour;
			else
				periode = "pm";  
				hour12  = hour-12;
			end  		
			-- 2 digit
			if( string.len(tostring(hour)) < 2) then hour = "0"..tostring(hour); end
			if( string.len(tostring(hour12)) < 2) then hour12 = "0"..tostring(hour12); end  
			if( string.len(tostring(minute)) < 2) then minute = "0"..tostring(minute); end 
			if( string.len(tostring(second)) < 2) then second = "0"..tostring(second); end  
			-- setting timestamp
			local TimeStamp = SCCN_ts_format;
			TimeStamp = string.gsub(TimeStamp, "$h", hour);
			TimeStamp = string.gsub(TimeStamp, "$m", minute);
			TimeStamp = string.gsub(TimeStamp, "$s", second);
			TimeStamp = string.gsub(TimeStamp, "$p", periode);
			TimeStamp = string.gsub(TimeStamp, "$t", hour12);
			TimeStamp = string.gsub(TimeStamp, "#", "|cff");
			text = TimeStamp.."|r "..text;
		end
	end	
	-- output
	if (this.ORG_AddMessage ~= nil) then
		this:ORG_AddMessage(text,r,g,b,id,addToStart);
	end
end

function SCCN_CustomHighlightProcessor(text,SCCN_Custom_Highlight_Word)
	if SCCN_Custom_Highlight_Word and text and SCCN_Highlight == 1 then
		if ( string.len(text) >= string.len(SCCN_Custom_Highlight_Word) and string.len(SCCN_Custom_Highlight_Word) > 2 ) then 
			if ( string.find(string.lower(text),string.lower(SCCN_Custom_Highlight_Word)) or string.find(text,SCCN_Custom_Highlight_Word) ) then
			-- NO CTRA and NO DMSYNC
				if( text ~= string.gsub(text, "([^:^%[]"..SCCN_Custom_Highlight_Word..")" , "")) then
					text = string.gsub(text, "([^:^%[])"..SCCN_Custom_Highlight_Word, "%1"..CHATMOD_COLOR["YELLOW"]..">|r"..CHATMOD_COLOR["RED"]..SCCN_Custom_Highlight_Word.."|r"..CHATMOD_COLOR["YELLOW"].."<|r");
				else
					text = string.gsub(text, "([^:^%[])"..string.lower(SCCN_Custom_Highlight_Word), "%1"..CHATMOD_COLOR["YELLOW"]..">|r"..CHATMOD_COLOR["RED"]..string.lower(SCCN_Custom_Highlight_Word).."|r"..CHATMOD_COLOR["YELLOW"].."<|r");
				end
				-- On Screen Msg
				if( SCCN_selfhighlightmsg == 1 ) then
					UIErrorsFrame:AddMessage(text, 1, 1, 1, 1.0, UIERRORS_HOLD_TIME);
					PlaySound("FriendJoinGame");
				end
				-- set already highlighted = True
				SCCN_Custom_Highlighted = true;
			end
		end
		return text;
	else
		return text;
	end
end

function SCCN_OnMouseWheel(chatframe, value)
  if (SCCN_chatscrollicon == 0) then
  	 SCCNScrollDown:Hide();
  end
  if( SCCN_mousescroll == 1) then
	if IsShiftKeyDown()  then
		-- shift key pressed (Fast scroll)  
		if ( value > 0 ) then
			for i = 1,5 do chatframe:ScrollUp(); end;
			if(SCCN_chatscrollicon == 1) then SCCNScrollDown:Show(); end;
		elseif ( value < 0 ) then
			for i = 1,5 do chatframe:ScrollDown(); end;
		end
	elseif IsControlKeyDown() then
		-- to top / to bottom
		if ( value > 0 ) then
			chatframe:ScrollToTop();
			if(SCCN_chatscrollicon == 1) then SCCNScrollDown:Show(); end;
		elseif ( value < 0 ) then
			chatframe:ScrollToBottom();
			SCCNScrollDown:Hide();
		end		
	else
		-- Normal Scroll without shift key  
		if ( value > 0 ) then
			chatframe:ScrollUp();
			if(SCCN_chatscrollicon == 1) then SCCNScrollDown:Show(); end;
		elseif ( value < 0 ) then
			chatframe:ScrollDown();
		end
    end 
  end
end  

function ChatMOD_SendChatMessage (msg, type, lang, channel)
	local chan_num, chan_name = nil
--    system, _, channel = unpack (arg)
	if type == "CHANNEL" then
		_, chan_name = GetChannelName (channel)
		if chan_name and
		not string.find (chan_name, SCCN_ILINK[1]) and
		not string.find (chan_name, SCCN_ILINK[2]) and
		not string.find (chan_name, SCCN_ILINK[3]) and
		not string.find (chan_name, SCCN_ILINK[4]) and
		not string.find (chan_name, SCCN_ILINK[5]) and
        SCCN_CHATLINK == 1	then
			msg = ChatMOD_CLINK_CreateLink(msg);
		end
	end

	-- Pass along to original function.
	SendChatMessage_Org (msg, type, lang, channel)
end


function SCCN_EditBox(where)
	SCCNScrollDown:SetPoint("BOTTOMRIGHT", "ChatFrame1", "BOTTOMRIGHT", 8, -9);
	if SCCNScrollDown_X > 0 then
        SCCNScrollDown.x = SCCNScrollDown_X;
    end
	if SCCNScrollDown_Y > 0 then
        SCCNScrollDown.y = SCCNScrollDown_Y;
    end     
	--SCCNScrollDown:SetPoint("BOTTOMLEFT", "ChatFrame1", "BOTTOMLEFT", 0, -28);
	--SCCNScrollDown:SetPoint("BOTTOMLEFT", "ChatFrame1", "BOTTOMLEFT", 0, -28);
	
	if(where == 1) then
		-- top
		ChatFrameEditBox:ClearAllPoints();
		--ChatFrameEditBox:SetAlpha(0.8);
		ChatFrameEditBox:SetPoint("BOTTOMLEFT", "ChatFrame1", "TOPLEFT", 0, 2);
		ChatFrameEditBox:SetPoint("BOTTOMRIGHT", "ChatFrame1", "TOPRIGHT", 0, 2);
	elseif(where == 0) then
		-- bottom
		-- ChatFrameEditBox:ClearAllPoints();
		--ChatFrameEditBox:SetAlpha(0.8);
		ChatFrameEditBox:SetPoint("BOTTOMLEFT", "ChatFrame1", "BOTTOMLEFT", 0, -28);
		ChatFrameEditBox:SetPoint("BOTTOMRIGHT", "ChatFrame1", "BOTTOMRIGHT", 0, -28);
	end
end

function SCCN_CustomizeChatString(status)
	if OLD_CHAT_WHISPER_GET == nil then OLD_CHAT_WHISPER_GET = CHAT_WHISPER_GET; end
	if OLD_CHAT_WHISPER_INFORM_GET == nil then OLD_CHAT_WHISPER_INFORM_GET = CHAT_WHISPER_INFORM_GET; end;
	if( status == 1 ) then
		CHAT_WHISPER_GET = SCCN_CUSTOM_CHT_FROM.." ";
		CHAT_WHISPER_INFORM_GET = SCCN_CUSTOM_CHT_TO.." ";
	else
		-- restore original
		CHAT_WHISPER_GET = OLD_CHAT_WHISPER_GET;
		CHAT_WHISPER_INFORM_GET = OLD_CHAT_WHISPER_INFORM_GET;
	end
end

function SCCN_EditBoxKeysToggle(status)
	if( status == 1 ) then
		ChatFrameEditBox:SetAltArrowKeyMode(false);
	else
		-- restore original
		ChatFrameEditBox:SetAltArrowKeyMode(true);
	end		
end

function SCCN_STRIPCHANNAMEFUNC(a,b,c,d,e)
	-- a = (%[)
	-- b = (%d?)
	-- c = (.?%s?"..SCCN_STRIPCHAN[i].."%]%s?)
	-- d = (%])
	-- e = (%s?)
	if(SCCN_hidechanname == 1) then 
	--	if(c ~= nil and string.find(c,"%.") ) then
	    if(b ~= nil ) then 	
			-- return a..b..d;
			return d;
		else
			return;
		end
	end
end

function SCCN_STRIPCHANNAMEFUNC_NEW(Num,Name)
	return "|Hscn:["..Num.."] = ["..Num..". "..Name.."]|h["..Num.."]|h ";
end




function SCCN_ChatFrame_OnUpdate()
   local BottomButton	= getglobal(this:GetParent():GetName().."BottomButton");
   local DownButton	= getglobal(this:GetParent():GetName().."DownButton");
   local UpButton	= getglobal(this:GetParent():GetName().."UpButton");
   if( SCCN_HideChatButtons == 1 ) then
	   if BottomButton:IsVisible() then BottomButton:Hide(); end
	   if DownButton:IsVisible() then DownButton:Hide(); end
	   if UpButton:IsVisible() then UpButton:Hide(); end
	   if ChatFrameMenuButton:IsVisible() then ChatFrameMenuButton:Hide(); end
   else
	   if not BottomButton:IsVisible() then BottomButton:Show(); end
	   if not DownButton:IsVisible() then DownButton:Show(); end
	   if not UpButton:IsVisible() then UpButton:Show(); end
	   if not ChatFrameMenuButton:IsVisible() then ChatFrameMenuButton:Show(); end
   end

end

function SCCN_KeyBinding_ChatFrameEditBox(kommando)
	if (not ChatFrameEditBox:IsVisible()) then
		ChatFrame_OpenChat(kommando);
	else
		ChatFrameEditBox:SetText(kommando);
	end;
	ChatFrameEditBox:Show();
	ChatEdit_ParseText(ChatFrame1.editBox,0);
end

function SCCN_SET_CHAT_TO(prefix)
		prefix = "/"..prefix.." "
    	if ChatFrameEditBox:IsVisible() then
    		ChatFrameEditBox:SetText(prefix);
        else
            ChatFrame_OpenChat(prefix);
        end;
        ChatEdit_ParseText(ChatFrame1.editBox, 0);
end

function SCCN_SELECT_CHAT_WINDOW(number)
		 if(number == '1') then FCF_SelectDockFrame(ChatFrame1) end
		 if(number == '2') then FCF_SelectDockFrame(ChatFrame2) end
		 if(number == '3') then FCF_SelectDockFrame(ChatFrame3) end
		 if(number == '4') then FCF_SelectDockFrame(ChatFrame4) end
		 if(number == '5') then FCF_SelectDockFrame(ChatFrame5) end
		 if(number == '6') then FCF_SelectDockFrame(ChatFrame6) end
		 if(number == '7') then FCF_SelectDockFrame(ChatFrame7) end
end

-------------------------------------------------
-- MOD INTERFACE FOR 3rd PARTY MODS
-------------------------------------------------
function SCCN_ColorNickName(Name)
	if Name then
		local FCcolor = solColorChatNicks_GetColorFor(Name);
		if( FCcolor ~= nil ) then
			return solColorChatNicks_GetColorFor(Name)..Name.."|r";
		else
			return Name;
		end
	end
end
function SCCN_ForgottenChatNickName(Name)
   -- Backwards compatibility ;p
   return SCCN_ColorNickName(Name);
end
-------------------------------------------------
-- INFORMATION GATHERING FUNCTIONS
-------------------------------------------------
-- Seen function
function ChatMOD_seen(name)
  if( name ~= nil ) then
      local LOWname = ChatMOD_prepName(name);
      if( SCCN_storage[LOWname] ~= nil ) then
		  local color = solColorChatNicks_GetClassColor(SCCN_storage[LOWname]["c"]);
          local time  = tonumber(SCCN_storage[LOWname]["t"]);
          local xName = "[|Hplayer:"..name.."|h"..color..name.."|h|r]";
          local level = SCCN_storage[LOWname]["l"];
		  local seen   = date("%d. %b. %H:%M",time);
		  local OutMSG = xName..CHATMOD_COLOR["YELLOW"].." last seen on "..seen;
		  if( level ~= nil ) then
		      OutMSG = OutMSG..CHATMOD_COLOR["YELLOW"].." at Level "..level;
		  end
		  SCCN_write(OutMSG);
	  else
	      SCCN_write(LOWname.." unknown.");
      end
  end
end

-- Color management
function solColorChatNicks_GetColorFor(name)
	-- Default color
	local color = "";
	-- lowercase
	local LOWname = ChatMOD_prepName(name);
	-- Check if unit name exists in storage
	if( SCCN_storage[LOWname] ~= nil ) then
		color = solColorChatNicks_GetClassColor(SCCN_storage[LOWname]["c"]);
	elseif( name == UnitName("player") ) then
	 -- You are the person. That's easy
		local _, class = UnitClass("player");
		local class = solColorChatNicks_ClassToNum(class);
		color = solColorChatNicks_GetClassColor(class);
		SCCN_storage[LOWname] = { c = class, t=time() };
	end
   
	return color;
end
		
function solColorChatNicks_InsertFriends()
  -- add current online friends
  for i = 1, GetNumFriends() do
    local name, level, class = GetFriendInfo(i);
	local LOWname = ChatMOD_prepName(name);
	local class = solColorChatNicks_ClassToNum(class);
	if( class ~= nil and name ~= nil and class > 0 ) then
		SCCN_storage[LOWname] = { c = class, t=time(), l = level };
	end
  end
end	

function solColorChatNicks_InsertGuildMembers()
  -- add current online guild members
  for i = 1, GetNumGuildMembers() do
	local name,_,_,level,class = GetGuildRosterInfo(i);
	local LOWname = ChatMOD_prepName(name);
	local class = solColorChatNicks_ClassToNum(class);
	if( class ~= nil and name ~= nil and class > 0 ) then
		SCCN_storage[LOWname] = { c = class, t=time(), l = level };
	end
  end
end

function solColorChatNicks_InsertRaidMembers()
  for i = 1, GetNumRaidMembers() do
    local name, _, _, level, class = GetRaidRosterInfo(i);
	local LOWname = ChatMOD_prepName(name);
	local class = solColorChatNicks_ClassToNum(class);
	if( class ~= nil and name ~= nil and class > 0 ) then
		SCCN_storage[LOWname] = { c = class, t=time(), l = level };
	end
  end	
end

function solColorChatNicks_InsertPartyMembers()
  for i = 1, GetNumPartyMembers() do
    local unit = "party" .. i;
    local _, class = UnitClass(unit);
	local name     = UnitName(unit);
	local LOWname = ChatMOD_prepName(name);
 	local class    = solColorChatNicks_ClassToNum(class);
	if( class ~= nil and name ~= nil and class > 0) then
		SCCN_storage[LOWname] = { c = class, t=time() };
	end   
  end	
end

function solColorChatNicks_InsertTarget()
	local _, classname = UnitClass("target");
	local name = UnitName("target");
	local level = UnitLevel("target");
	local LOWname = ChatMOD_prepName(name);
	local class = solColorChatNicks_ClassToNum(classname);
	ChatMOD_debug("solColorChatNicks_InsertTarget",name);
	if( class ~= nil and name ~= nil and UnitIsPlayer("target") and class > 0) then
		-- Send to com channel
		if( SCCN_COM_GUILD == 1 ) then
			if( UnitName("target") ~= UnitName("player") and GetGuildInfo("target") ~= GetGuildInfo("player") ) then
			    -- antispam, only report once in 10 min of if unkown before
			    if ( SCCN_storage[LOWname] == nil or (SCCN_storage[LOWname]["t"] + 600) < time() ) then
			       -- Temporary disabled sending to guild because RAID is enough in my eyes
				   -- ChatMOD_COM_Send("NEW:"..LOWname..":"..class..":"..level,"GUILD");
				    if( UnitInRaid("player") ) then
				        ChatMOD_COM_Send("NEW:"..LOWname..":"..class..":"..level,"RAID");
				    elseif( UnitInParty("player") ) then
				        ChatMOD_COM_Send("NEW:"..LOWname..":"..class..":"..level,"PARTY");
				    end
				end
	        end
		end
		-- Insert into storage Array
	    SCCN_storage[LOWname] = { c = class, t=time(), l = level };
	end
end

function solColorChatNicks_InsertWhoList()
	local numWhoResults = GetNumWhoResults();
	for i = 1, numWhoResults, 1 do
		local name, _, _, _, classname = GetWhoInfo(i);
		local LOWname = ChatMOD_prepName(name);
		local classname = string.upper(classname);
		local class = solColorChatNicks_ClassToNum(classname);
		if( class ~= nil and name ~= nil and classname ~= nil) then
			SCCN_storage[LOWname] = { c = class, t=time() };
		end
	end
end

function solColorChatNicks_InsertWhoText(arg)
	for name, regA, regB in string.gmatch(arg, "%[(.-)%].+ %d+ .- (.-) (.-) .+") do
		if string.find(regB,"-") or string.find(regB,"<") then
			classname = string.upper(regA)
		else
			classname = string.upper(regB)
		end
		if string.find(classname,"%[") then
			return false;
		end
		local class = solColorChatNicks_ClassToNum(classname);
		local LOWname = ChatMOD_prepName(name);
		SCCN_storage[LOWname] = { c = class, t=time() };
	end
end


-------------------------------------------------
-- CONVERTER / GET FROM ARRAY   FUNCTIONS
-------------------------------------------------
function solColorChatNicks_ClassToNum(class)
	if(class == "WARLOCK" or class == SCCN_LOCAL_CLASS["WARLOCK"] or class == SCCN_LOCAL_CLASS["WARLOCKF"]) then
		return 1;
	elseif(class == "HUNTER" or class == SCCN_LOCAL_CLASS["HUNTER"] or class == SCCN_LOCAL_CLASS["HUNTERF"]) then
		return 2;
	elseif(class == "PRIEST" or class == SCCN_LOCAL_CLASS["PRIEST"] or class == SCCN_LOCAL_CLASS["PRIESTF"]) then
		return 3;
	elseif(class == "PALADIN" or class == SCCN_LOCAL_CLASS["PALADIN"]) then		
		return 4;
	elseif(class == "MAGE" or class == SCCN_LOCAL_CLASS["MAGE"] or class == SCCN_LOCAL_CLASS["MAGEF"]) then
		return 5;
	elseif(class == "ROGUE" or class == SCCN_LOCAL_CLASS["ROGUE"] or class == SCCN_LOCAL_CLASS["ROGUEF"]) then
		return 6;
	elseif(class == "DRUID" or class == SCCN_LOCAL_CLASS["DRUID"] or class == SCCN_LOCAL_CLASS["DRUIDF"] ) then
		return 7;
	elseif(class == "SHAMAN" or class == SCCN_LOCAL_CLASS["SHAMAN"] or class == SCCN_LOCAL_CLASS["SHAMANF"] ) then
		return 8;
	elseif(class == "WARRIOR" or class == SCCN_LOCAL_CLASS["WARRIOR"] or class == SCCN_LOCAL_CLASS["WARRIORF"] ) then
		return 9;
	elseif(class == "DEATHKNIGHT" or class == SCCN_LOCAL_CLASS["DEATHKNIGHT"] or class == SCCN_LOCAL_CLASS["DEATHKNIGHTF"] ) then
		return 10;
	end
	return 0;
end

function solColorChatNicks_ClassNumToRGB(classnum)
	if(classnum == 1) then return {r=100,g=0,b=112}
	elseif(classnum == 2) then return {r=81,g=140,b=11}
	elseif(classnum == 3) then return {r=1,g=1,b=1}
	elseif(classnum == 4) then return {r=255,g=0,b=255}
	elseif(classnum == 5) then return {r=0,g=180,b=240}
	elseif(classnum == 6) then return {r=220,g=200,b=0}
	elseif(classnum == 7) then return {r=240,g=136,b=0}
	elseif(classnum == 8) then return {r=16,g=155,b=146}
	elseif(classnum == 9) then return {r=147,g=112,b=67}
	elseif(classnum == 10) then return {r=150,g=0,b=0}
	else return {r=0,g=0,b=0}; end
end

function solColorChatNicks_GetClassColor(class)
	if(class == 1) 		then return ChatMOD_ReadClassColor("WARLOCK");
	elseif(class == 2) 	then return ChatMOD_ReadClassColor("HUNTER");
	elseif(class == 3) 	then return ChatMOD_ReadClassColor("PRIEST");
	elseif(class == 4) 	then return ChatMOD_ReadClassColor("PALADIN");
	elseif(class == 5) 	then return ChatMOD_ReadClassColor("MAGE");
	elseif(class == 6) 	then return ChatMOD_ReadClassColor("ROGUE");
	elseif(class == 7) 	then return ChatMOD_ReadClassColor("DRUID");
	elseif(class == 8) 	then return ChatMOD_ReadClassColor("SHAMAN");
	elseif(class == 9) 	then return ChatMOD_ReadClassColor("WARRIOR");
	elseif(class == 10) 	then return ChatMOD_ReadClassColor("DEATHKNIGHT");
	end
	return "";
end

--------------------------------------------------
-- Hyperlink and make clickable in chat Stuff
--------------------------------------------------
function SCCN_HyperlinkWindow(url)
	if( url ~= nil ) then
		getglobal( "solHyperlinkerEditBox" ):SetText( url );
		solHyperlinkerForm:Show();
	end
end

function SCCN_GetURL(before, URL, after)
	SCCN_URLFOUND = 1;
	return before.."|cff".."9999EE".. "|Href:" .. URL .. "|h[".. URL .."]|h|r" ..  after;
end

function SCCN_SetItemRef(link, text, button)
	if (string.sub(link, 1 , 3) == "ref") then
		SCCN_HyperlinkWindow(string.sub(link,5));
		return;
	elseif (string.sub(link, 1 , 3) == "inv" and string.sub(link,5) ) then
		local Player = string.gsub(link, "inv:", "", 1);
		InviteUnit(Player);
	elseif (string.sub(link, 1 , 3) == "scn" and string.sub(link,5) ) then 
		SCCN_write(string.sub(link,5));		
	else
		SCCN_Org_SetItemRef(link, text, button);
	end
end

function SCCN_ChanRewrite(before, msg, after)
	-- maybe doing something special herein later
	-- my Idea is to switch from highlighting to hiding or shortening
	
--	after = string.gsub(after , "]", "");
	return before..after;
end

function SCCN_ClickInvite(msg,trail)
	if (trail == nil or trail == " " or trail == "") and arg2 ~= UnitName("player") and event ~= "CHAT_MSG_RAID" and event ~= "CHAT_MSG_RAID_LEADER" and event ~= "CHAT_MSG_RAID_WARNING" then
		SCCN_INVITEFOUND = true;
		return " |Hinv:" .. arg2 .. "|h[|cffffff00"..msg.."|r]|h".." ";
	else
		return " "..msg..trail;
	end
end

--------------------------------------------------
-- Slash Command handlers
--------------------------------------------------
function SCCN_CMD_TT(msg)
	if( UnitName("target") == nil ) then
		SCCN_write("No Target for /tt");
		return false;
	end
	if( msg ~= nil and string.len(msg) > 1 ) then	
		-- send a whisper to your target
		SendChatMessage(msg, "WHISPER", this.language, UnitName("target"));
	else
		SCCN_write("Use: /tt This is a example!");
	end
end

function solColorChatNicks_SlashCommand(cmd)
	-- This function handle the Help and general Option calls
	local cmd = string.lower(cmd);
	if    ( cmd == "hidechanname") then
		if SCCN_hidechanname == 0 then 
			SCCN_hidechanname = 1;
			SCCN_write(SCCN_CMDSTATUS[1].."|cff00ff00".." ON");
		else 
			SCCN_hidechanname = 0; 
			SCCN_write(SCCN_CMDSTATUS[1].."|cffff0000".." OFF");
		end;
    elseif( cmd == "test") then
    		ChatMODtest();
    elseif( strsub(cmd, 1, 9) == "chatlines") then
			if(string.len(cmd) > 9) then
               -- more then just the toggleswitch
		  	   local more = tonumber(strsub(cmd, 11));
			   if ( more > 49 and more < 5001 ) then
			   	  SCCN_SCROLLBACK_BUFFER = more;
				  ChatMOD_set_chatlinebuffer();
                  SCCN_write("Chatframe Scrollback buffer set to "..more.." Lines");
			   else
				  SCCN_write("chatlines invalid value, please enter a number between 50 and 5000");
				  SCCN_write("chatlines set to default:128");
			   end
			else
			    SCCN_write("Usage: /chatmod chatlines <no of chatlines>\n"..CHATMOD_COLOR["CYAN"].."e.g: /chatmod chatlines 512");
			end
			
    elseif( cmd == "comping") then
    		ChatMOD_COM_Send("PING_RQ:"..CHATMOD_REVISION, "ALL");
	elseif( cmd == "colornicks") then
		if SCCN_colornicks == 0 then 
			SCCN_colornicks = 1;
			SCCN_write(SCCN_CMDSTATUS[2].."|cff00ff00".." ON");
		else 
			SCCN_colornicks = 0; 
			SCCN_write(SCCN_CMDSTATUS[2].."|cffff0000".." OFF");
		end;
	elseif( cmd == "comguild") then
	    if SCCN_COM_GUILD == 0 then
			SCCN_COM_GUILD = 1;
			SCCN_write("Smart Guild communication:".."|cff00ff00".." ON");
		else
			SCCN_COM_GUILD = 0;
			SCCN_write("Smart Guild communication:".."|cffff0000".." OFF");
		end;
	elseif( cmd == "chatlink") then
	    if SCCN_CHATLINK == 0 then
			SCCN_CHATLINK = 1;
			SCCN_write("Chatlink Support:".."|cff00ff00".." ON");
		else
			SCCN_CHATLINK = 0;
			SCCN_write("Chatlink Support:".."|cffff0000".." OFF");
		end;
	elseif( cmd == "mousescroll") then
		if SCCN_mousescroll == 0 then 
			SCCN_mousescroll = 1;
			SCCN_write(SCCN_CMDSTATUS[3].."|cff00ff00".." ON");
		else 
			SCCN_mousescroll = 0; 
			SCCN_write(SCCN_CMDSTATUS[3].."|cffff0000".." OFF");
		end;
	elseif( cmd == "chatcolorname") then
		if SCCN_InChatHighlight == 0 then
			SCCN_InChatHighlight = 1;
			SCCN_write(SCCN_CMDSTATUS[19].."|cff00ff00".." ON");
		else
			SCCN_InChatHighlight = 0;
			SCCN_write(SCCN_CMDSTATUS[19].."|cffff0000".." OFF");
		end;
	elseif( cmd == "topeditbox") then
		if( CONFAB_VERSION ) then SCCN_write(SCCN_CONFAB); return false; end;
  	    if( SCCN_topeditbox == 1 ) then
			SCCN_topeditbox = 0;
			SCCN_EditBox(0);
			SCCN_write(SCCN_CMDSTATUS[4].."|cffff0000".." OFF");
		else
			SCCN_topeditbox = 1;
			SCCN_EditBox(1);
			SCCN_write(SCCN_CMDSTATUS[4].."|cff00ff00".." ON");
		end
	elseif( cmd == "debug") then
  	    if( SCCN_DEBUG == 1 ) then
			SCCN_DEBUG = nil;
			SCCN_write("ChatMOD Debug|cffff0000".." OFF");
		else
			SCCN_DEBUG = 1;
			SCCN_write("ChatMOD Debug|cff00ff00".." ON");
		end
	elseif( cmd == "usage") then
  	    if( SCCN_displayusage == 1 ) then
			SCCN_displayusage = nil;
			SCCN_write("ChatMOD Display Usage|cffff0000".." OFF");
		else
			SCCN_displayusage = 1;
			SCCN_write("ChatMOD Display Usage|cff00ff00".." ON");
		end
	elseif( strsub(cmd, 1, 9) == "timestamp") then
		if(string.len(cmd) > 9) then
		 -- more then just the toggleswitch
		  local more = strsub(cmd, 11);
			if more then
				if(more == "?" or more == "help") then
					SCCN_write(SCCN_TS_HELP);
				elseif( more == "" or more == "off") then
                    SCCN_timestamp = 0; 
				    SCCN_write(SCCN_CMDSTATUS[5].."|cffff0000".." OFF");				    
				else  
					SCCN_ts_format = more;
					SCCN_write("Timestamp format changed to: "..SCCN_ts_format);
					SCCN_timestamp = 1;
				    SCCN_write(SCCN_CMDSTATUS[5].."|cff00ff00".." ON");
				end
			else
				SCCN_write(SCCN_TS_HELP);
			end
	    else
			if SCCN_timestamp == 0 then 
				SCCN_timestamp = 1;
				SCCN_write(SCCN_CMDSTATUS[5].."|cff00ff00".." ON");
			else 
				SCCN_timestamp = 0; 
				SCCN_write(SCCN_CMDSTATUS[5].."|cffff0000".." OFF");
			end;
		end
	elseif( cmd == "selfhighlight") then
		if SCCN_selfhighlight == 0 then 
			SCCN_selfhighlight = 1;
			SCCN_write(SCCN_CMDSTATUS[8].."|cff00ff00".." ON");
		else 
			SCCN_selfhighlight = 0; 
			SCCN_write(SCCN_CMDSTATUS[8].."|cffff0000".." OFF");
		end;
	elseif( cmd == "clickinvite") then
		if SCCN_clickinvite == 0 then 
			SCCN_clickinvite = 1;
			SCCN_write(SCCN_CMDSTATUS[9].."|cff00ff00".." ON");
		else 
			SCCN_clickinvite = 0; 
			SCCN_write(SCCN_CMDSTATUS[9].."|cffff0000".." OFF");
		end;
	elseif( cmd == "editboxkeys") then
		if SCCN_editboxkeys == 0 then
			SCCN_EditBoxKeysToggle(1);
			SCCN_editboxkeys = 1;
			SCCN_write(SCCN_CMDSTATUS[10].."|cff00ff00".." ON");
		else 
			SCCN_EditBoxKeysToggle(0);
			SCCN_editboxkeys = 0; 
			SCCN_write(SCCN_CMDSTATUS[10].."|cffff0000".." OFF");
		end;
	elseif( cmd == "selfhighlightmsg") then
		if SCCN_selfhighlightmsg == 0 then 
			SCCN_selfhighlightmsg = 1;
			SCCN_write(SCCN_CMDSTATUS[12].."|cff00ff00".." ON");
		else 
			SCCN_selfhighlightmsg = 0; 
			SCCN_write(SCCN_CMDSTATUS[12].."|cffff0000".." OFF");
		end;		
	elseif( cmd == "chatstring") then
		if SCCN_chatstring == 0 then 
			SCCN_chatstring = 1;
			SCCN_write(SCCN_CMDSTATUS[11].."|cff00ff00".." ON");
			SCCN_CustomizeChatString(1);
		else 
			SCCN_chatstring = 0; 
			SCCN_write(SCCN_CMDSTATUS[11].."|cffff0000".." OFF");
			SCCN_CustomizeChatString(0);
		end;	
	elseif( cmd == "hyperlink") then
		if SCCN_hyperlinker == 0 then 
			SCCN_hyperlinker = 1;
			SCCN_write(SCCN_CMDSTATUS[7].."|cff00ff00".." ON");
			SCCN_Org_SetItemRef = SetItemRef;
			SetItemRef = SCCN_SetItemRef;			
		else
			SCCN_hyperlinker = 0; 
			SCCN_write(SCCN_CMDSTATUS[7].."|cffff0000".." OFF");
			if( SCCN_Org_SetItemRef ) then
				SetItemRef = SCCN_Org_SetItemRef;
			end
		end;		
	elseif( cmd == "purge" ) then 
		solColorChatNicks_PurgeDB();
	elseif( cmd == "hidechatbuttons" ) then
		if(SCCN_HideChatButtons == 1) then
			SCCN_HideChatButtons = 0;
			SCCN_write(SCCN_CMDSTATUS[13].."|cffff0000".." OFF");
		else
			SCCN_HideChatButtons = 1;
			SCCN_write(SCCN_CMDSTATUS[13].."|cff00ff00".." ON");
		end
	elseif( cmd == "killdb" ) then
		SCCN_write("Whiped complete Database.");
		SCCN_storage = {};
		SCCN_OldStorage = {};
		solColorChatNicks_PurgeDB();
	elseif( cmd == "disablewho" ) then
		if(SCCN_disablewhocheck == 1) then
			SCCN_disablewhocheck = 0;
			SCCN_write("Disable Who Check:".."|cffff0000".." OFF");
			this:RegisterEvent("WHO_LIST_UPDATE")
		else
			SCCN_disablewhocheck = 1;
			SCCN_write("Disable Who Check:".."|cff00ff00".." ON");
			this:UnregisterEvent("WHO_LIST_UPDATE")
		end		
	elseif( cmd == "highlight" ) then
		if(SCCN_Highlight == 1) then
			SCCN_Highlight = 0;
			SCCN_write(SCCN_CMDSTATUS[15].."|cffff0000".." OFF");
		else
			SCCN_Highlight = 1;
			SCCN_write(SCCN_CMDSTATUS[15].."|cff00ff00".." ON");
		end		
	elseif( cmd == "autogossipskip" ) then 
		if(SCCN_AutoGossipSkip == 1) then
			SCCN_AutoGossipSkip = 0;
			SCCN_write(SCCN_CMDSTATUS[17].."|cffff0000".." OFF");
		else
			SCCN_AutoGossipSkip = 1;
			SCCN_write(SCCN_CMDSTATUS[17].."|cff00ff00".." ON");
		end		
	elseif( cmd == "autodismount" ) then 
		if(SCCN_AutoDismount == 1) then
			SCCN_AutoDismount = 0;
			SCCN_write(SCCN_CMDSTATUS[18].."|cffff0000".." OFF");
		else
			SCCN_AutoDismount = 1;
			SCCN_write(SCCN_CMDSTATUS[18].."|cff00ff00".." ON");
		end			
	elseif( cmd == "shortchanname" ) then 
		if(SCCN_shortchanname == 1) then
			SCCN_shortchanname = 0;
			SCCN_write(SCCN_CMDSTATUS[16].."|cffff0000".." OFF");
		else
			SCCN_shortchanname = 1;
			SCCN_write(SCCN_CMDSTATUS[16].."|cff00ff00".." ON");
		end
	elseif( cmd == "inchathighlight" ) then
		if(SCCN_InChatHighlight == 1) then
			SCCN_InChatHighlight = 0;
			SCCN_write(SCCN_CMDSTATUS[19].."|cffff0000".." OFF");
		else
			SCCN_InChatHighlight = 1;
			SCCN_write(SCCN_CMDSTATUS[19].."|cff00ff00".." ON");
		end
elseif( cmd == "nofade" ) then
		if(SCCN_NOFADE == 1) then
			SCCN_NOFADE = 0;
			SCCN_write(SCCN_CMDSTATUS[21].."|cffff0000".." OFF");
		else
			SCCN_NOFADE = 1;
			SCCN_write(SCCN_CMDSTATUS[21].."|cff00ff00".." ON");
		end
		SCCNnofade();
elseif( cmd == "sticky" ) then
		if(SCCN_AllSticky == 1) then
			SCCN_AllSticky = 0;
			ChatMOD_sticky(0);
			SCCN_write(SCCN_CMDSTATUS[20].."|cffff0000".." OFF");
		else
			SCCN_AllSticky = 1;
			ChatMOD_sticky(1);
			SCCN_write(SCCN_CMDSTATUS[20].."|cff00ff00".." ON");
		end
	elseif( cmd == "chaticon" ) then
		if(SCCN_chatscrollicon == 1) then
			SCCN_chatscrollicon = 0;
			SCCN_write(SCCN_CMDSTATUS[22].."|cffff0000".." OFF");
		else
			SCCN_chatscrollicon = 1;
			SCCN_write(SCCN_CMDSTATUS[22].."|cff00ff00".." ON");
		end
	elseif( cmd == "showlevel" ) then
		if(SCCN_SHOWLEVEL == 1) then
			SCCN_SHOWLEVEL = 0;
			SCCN_write(SCCN_CMDSTATUS[23].."|cffff0000".." OFF");
		else
			SCCN_SHOWLEVEL = 1;
			SCCN_write(SCCN_CMDSTATUS[23].."|cff00ff00".." ON");
		end
	elseif( cmd == "icon" ) then
		if(SCCN_SHOWICON == 1) then
			SCCN_SHOWICON = 0;
			SCCN_write(SCCN_CMDSTATUS[25].."|cffff0000".." OFF");
			MyFriendList = nil
			MyGuildMembers = nil
		else
			SCCN_SHOWICON = 1;
			SCCN_write(SCCN_CMDSTATUS[25].."|cff00ff00".." ON");
		end
    elseif( cmd == "tst") then
        ChatMOD_debug("Command","tst")
        SCCN_InMyGuild("Dwarfser")
    elseif( cmd == "ico") then
        ChatMOD_debug("Command","ico")
        SCCN_write(SCCN_AddIcon("important").." Important persons like Officer or Raid Leader")
        SCCN_write(SCCN_AddIcon("group").." Members of your Group")
        SCCN_write(SCCN_AddIcon("guild").." Your Guild Mates")
        SCCN_write(SCCN_AddIcon("friend").." On your Friendlist")
        SCCN_write(SCCN_AddIcon("self").." You Self")
	elseif( cmd == "help" or cmd == "?" ) then
		SCCN_write(SCCN_HELP[1]);
		SCCN_write(SCCN_HELP[4]);
		SCCN_write(SCCN_HELP[5]);
		SCCN_write(SCCN_HELP[8]);
		SCCN_write(SCCN_HELP[14]);
		SCCN_write(SCCN_HELP[24]);
		SCCN_write(SCCN_HELP[26]);
		SCCN_write(SCCN_HELP[99]);	
	elseif( cmd == "status" ) then
		SCCN_write("|cff006CFF ---[ChatMOD Status]---");
		if( SCCN_colornicks == 1) then 	SCCN_write(SCCN_CMDSTATUS[2].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[2].."|cffff0000".." OFF"); end;
		if( SCCN_hidechanname == 1) then 	SCCN_write(SCCN_CMDSTATUS[1].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[1].."|cffff0000".." OFF"); end;
		if( SCCN_mousescroll == 1) then 	SCCN_write(SCCN_CMDSTATUS[3].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[3].."|cffff0000".." OFF"); end;	
		if( SCCN_topeditbox == 1) then 	SCCN_write(SCCN_CMDSTATUS[4].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[4].."|cffff0000".." OFF"); end;			
		if( SCCN_timestamp == 1) then 	SCCN_write(SCCN_CMDSTATUS[5].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[5].."|cffff0000".." OFF"); end;
		if( SCCN_hyperlinker == 1) then 	SCCN_write(SCCN_CMDSTATUS[7].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[7].."|cffff0000".." OFF"); end;
		if( SCCN_selfhighlight == 1) then 	SCCN_write(SCCN_CMDSTATUS[8].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[8].."|cffff0000".." OFF"); end;		
		if( SCCN_clickinvite == 1) then 	SCCN_write(SCCN_CMDSTATUS[9].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[9].."|cffff0000".." OFF"); end;		
		if( SCCN_editboxkeys == 1) then 	SCCN_write(SCCN_CMDSTATUS[10].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[10].."|cffff0000".." OFF"); end;
		if( SCCN_chatstring == 1) then 	SCCN_write(SCCN_CMDSTATUS[11].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[11].."|cffff0000".." OFF"); end;
		if( SCCN_selfhighlightmsg == 1) then 	SCCN_write(SCCN_CMDSTATUS[12].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[12].."|cffff0000".." OFF"); end;
		if( SCCN_HideChatButtons == 1) then 	SCCN_write(SCCN_CMDSTATUS[13].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[13].."|cffff0000".." OFF"); end;
		if( SCCN_shortchanname == 1) then 	SCCN_write(SCCN_CMDSTATUS[16].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[16].."|cffff0000".." OFF"); end;
		if( SCCN_AutoGossipSkip == 1) then 	SCCN_write(SCCN_CMDSTATUS[17].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[17].."|cffff0000".." OFF"); end;
		if( SCCN_AutoDismount == 1) then 	SCCN_write(SCCN_CMDSTATUS[18].."|cff00ff00".." ON");
		else		SCCN_write(SCCN_CMDSTATUS[18].."|cffff0000".." OFF"); end;
		if( SCCN_disablewhocheck == 1) then 	SCCN_write("Disable Who Check:".."|cff00ff00".." ON");
		else		SCCN_write("Disable Who Check:".."|cffff0000".." OFF"); end;		
else
        -- timestampeidtbox aktualisieren
        getglobal( "ChatMOD_TimestampBox" ):SetText( SCCN_ts_format );

        -- Memanzeige aktualisieren
        getglobal("SCCNConfigForm".."stat1".."Label"):SetText(CHATMOD_COLOR["SILVER"].."ChatMOD uses currently "..ChatMOD_GetAddOnMemoryUsage().." Kb memory, storing "..SCCN_keept.." players.");
		SCCNConfigForm:Show();
	end
end

-----------------------------------------------
-- SCCN Config GUI Stuff
-----------------------------------------------
function SCCN_Config_OnLoad()
	-- Setzen der UI Eigenschaften
	-- * Version	
		getglobal("SCCNConfigForm".."ver1".."Label"):SetText(CHATMOD_COLOR["SILVER"].."SVN REVISION "..CHATMOD_REVISION);
	-- * Help Eintr��ge
		getglobal("SCCNShortchanForm".."HLP1".."Label"):SetText(SCCN_HELP[2]);
		getglobal("SCCNShortchanForm".."HLP2".."Label"):SetText(SCCN_HELP[19]);
		getglobal("SCCNConfigForm".."HLP2".."Label"):SetText(SCCN_HELP[3]);
		getglobal("SCCNConfigForm".."HLP3".."Label"):SetText(SCCN_HELP[6]);
		getglobal("SCCNConfigForm".."HLP4".."Label"):SetText(SCCN_HELP[7]);
		getglobal("SCCNConfigForm".."HLP6".."Label"):SetText(SCCN_HELP[10]);
		getglobal("SCCNConfigForm".."HLP8".."Label"):SetText(SCCN_HELP[12]);
		getglobal("SCCNConfigForm".."HLP9".."Label"):SetText(SCCN_HELP[13]);
		getglobal("SCCNConfigForm".."HLP11".."Label"):SetText(SCCN_HELP[16]);
		getglobal("SCCNConfigForm".."HLP12".."Label"):SetText(SCCN_HELP[20]);
		getglobal("SCCNConfigForm".."HLP13".."Label"):SetText(SCCN_HELP[21]);
		getglobal("SCCNConfigForm".."HLP14".."Label"):SetText(SCCN_HELP[23]);
		getglobal("SCCNConfigForm".."HLP15".."Label"):SetText(SCCN_HELP[25]);
		getglobal("SCCNConfigForm".."HLP17".."Label"):SetText(SCCN_HELP[26]);
		getglobal("SCCNConfigForm".."HLP18".."Label"):SetText(SCCN_HELP[27]);
		getglobal("SCCNConfigForm".."HLP19".."Label"):SetText(SCCN_HELP[28]);
		getglobal("SCCN_Highlight_Form".."HLP0".."Label"):SetText(SCCN_HELP[17]);
		getglobal("SCCN_Highlight_Form".."HLP1".."Label"):SetText(SCCN_HELP[11]);
		getglobal("SCCN_Highlight_Form".."HLP2".."Label"):SetText(SCCN_HELP[15]);
		getglobal("SCCN_Highlight_Form".."HLP3".."Label"):SetText(SCCN_HELP[22]);
		
	-- * Button Config auslesen und setzen
		SCCN_Config_SetButtonState(SCCN_hidechanname,1);
		SCCN_Config_SetButtonState(SCCN_shortchanname,7);
		SCCN_Config_SetButtonState(SCCN_colornicks,2);
		SCCN_Config_SetButtonState(SCCN_mousescroll,3);
		SCCN_Config_SetButtonState(SCCN_topeditbox,4);
		SCCN_Config_SetButtonState(SCCN_hyperlinker,6);
		--SCCN_Config_SetButtonState(SCCN_selfhighlight,7);
		SCCN_Config_SetButtonState(SCCN_clickinvite,8);
		SCCN_Config_SetButtonState(SCCN_editboxkeys,9);
		SCCN_Config_SetButtonState(SCCN_HideChatButtons,11);
		SCCN_Config_SetButtonState(SCCN_AutoGossipSkip,12);
		SCCN_Config_SetButtonState(SCCN_AutoDismount,13);
		SCCN_Config_SetButtonState(SCCN_AllSticky,14);
		SCCN_Config_SetButtonState(SCCN_NOFADE,15);
		SCCN_Config_SetButtonState(SCCN_chatscrollicon,17);
		SCCN_Config_SetButtonState(SCCN_SHOWLEVEL,18);
		SCCN_Config_SetButtonState(SCCN_InChatHighlight,19);
		SCCN_Config_SetButtonState(SCCN_Highlight,100);
		SCCN_Config_SetButtonState(SCCN_selfhighlight,101);
		SCCN_Config_SetButtonState(SCCN_selfhighlightmsg,102);
		SCCN_Config_SetButtonState(SCCN_InChatHighlight,103);
		SCCN_Config_SetButtonState(SCCN_SHOWICON,104);
		
		
end 

function SCCN_Config_SetButtonState(val,buttonnr)
	if(val == 0 or val == false or val == nil) then
		getglobal( "SCCN_CONF_CHK"..buttonnr ):SetChecked(0);
	else
		getglobal( "SCCN_CONF_CHK"..buttonnr ):SetChecked(1);
	end
end

--------------------------------------------------------
-- Misc functions
--------------------------------------------------------
function SCCN_InMyGuild(ToonName)
     ChatMOD_debug("SCCN_InMyGuild","init")
     if(not ToonName or not IsInGuild()) then
            ChatMOD_debug("SCCN_InMyGuild","return false 1")
            return
     end
     ChatMOD_debug("SCCN_InMyGuild","Toon:"..ToonName)
     if(not MyGuildMembers) then
            GuildRoster()
            ChatMOD_debug("SCCN_InMyGuild","Re Creating Guildmate List, Members="..GetNumGuildMembers())
            MyGuildMembers = {}
            for i = 1, GetNumGuildMembers() do
                local name,_ = GetGuildRosterInfo(i);
                local LOWname = ChatMOD_prepName(name);
                MyGuildMembers[LOWname] = 1;
            end
     end
     local tmp = ChatMOD_prepName(ToonName)
     if( MyGuildMembers[tmp] ) then
         ChatMOD_debug("SCCN_InMyGuild","return true")
         return true
     end
     ChatMOD_debug("SCCN_InMyGuild","return false default")
end

function SCCN_IsMyFriend(ToonName)
     ChatMOD_debug("SCCN_IsMyFriend","init")
     if(not ToonName) then
            ChatMOD_debug("SCCN_IsMyFriend","return false 1")
            return
     end
     if(not MyFriendList) then
            MyFriendList = {}
            ChatMOD_debug("SCCN_IsMyFriend","Re Creating Friend List, Members="..GetNumGuildMembers())
            for i = 1, GetNumFriends() do
                local name,_ = GetFriendInfo(i);
                local LOWname = ChatMOD_prepName(name);
                MyFriendList[LOWname] = 1;
            end
     end
     local tmp = ChatMOD_prepName(ToonName)
     if( MyFriendList[tmp] ) then
         ChatMOD_debug("SCCN_IsMyFriend","return true")
         return true
     end
     ChatMOD_debug("SCCN_IsMyFriend","return false default")
end

function SCCN_AddIcon(ico)
    local icons={
          ["important"]="Interface\\AddOns\\ChatMOD\\gfx\\important.tga",
          ["self"]="Interface\\AddOns\\ChatMOD\\gfx\\self.tga",
          ["group"]="Interface\\AddOns\\ChatMOD\\gfx\\group.tga",
          ["guild"]="Interface\\AddOns\\ChatMOD\\gfx\\guild.tga",
          ["friend"]="Interface\\AddOns\\ChatMOD\\gfx\\friend.tga",
    }
    if( icons[ico] ~= nil ) then
        return "|T"..icons[ico]..":0:0:0:-1|t"
    end
    return nil
end

function SCCN_OnGOSSIP()
    -- bugged function
	local GossipSkipped = nil;
	if SCCN_AutoGossipSkip == 1 and event == "GOSSIP_SHOW" and not IsControlKeyDown() and not GetGossipAvailableQuests() and not GetGossipActiveQuests() then	
		local GossipOptions = {};
		_,GossipOptions[1],_,GossipOptions[2],_,GossipOptions[3],_,GossipOptions[4],_,GossipOptions[5]=  GetGossipOptions()
		for i=1, getn(GossipOptions) do
			if (GossipOptions[i] == "taxi") then 
				SCCN_Dismount(); 
			end
			if (GossipOptions[i] == "vendor" or GossipOptions[i] == "battlemaster" or GossipOptions[i] == "taxi" or GossipOptions[i] == "banker") then
				SelectGossipOption(i);
                if GossipOptions then
			         GossipSkipped = true;
		        end				
			elseif (GossipOptions[i] == "gossip") then
				SCCN_GossipFrame_OnEvent_org();
			end
		end
	end
	if GossipSkipped == nil then
		SCCN_GossipFrame_OnEvent_org();
	end
end


function SCCN_GOSSIP()
    -- reverted to 1.3 behavior. Slower but works for all.
	if SCCN_AutoGossipSkip == 1 then	
		local GossipOptions = {};
		local append = ".";
		--SelectGossipOption(1);
		_,GossipOptions[1],_,GossipOptions[2],_,GossipOptions[3],_,GossipOptions[4],_,GossipOptions[5]=  GetGossipOptions()
		for i=1, getn(GossipOptions) do
			if (GossipOptions[i] == "taxi") then SCCN_Dismount(); append=", Dismounting." end;
			if (GossipOptions[i] == "battlemaster" or GossipOptions[i] == "taxi" or GossipOptions[i] == "banker" or GossipOptions[i] == "trainer") then
				--SCCN_write("Skip Gossip: '"..GossipOptions[i].."' detected, Autoselecting Option "..i..append);
				SelectGossipOption(i);
			end
		end
	end
end



function SCCN_Dismount()
	if SCCN_AutoDismount == 1 then
		for i=0,15 do
			local buffIndex, untilCancelled = GetPlayerBuff(i, "HELPFUL");
			if GetPlayerBuffTexture(buffIndex) then
				if string.find(GetPlayerBuffTexture(buffIndex),"Mount") then
					CancelPlayerBuff(buffIndex);
				end
			end
		end
	end
end

function SCCN_CHATSOUND_ONLOAD()
	for i=1,5 do
		local slider = getglobal("SND_SLIDER"..i);
		if SCCN_chatsound[i] == nil then SCCN_chatsound[i] = 0; end;
		slider:SetValue(SCCN_chatsound[i]);
		local label = getglobal("SND_LABEL"..i.."Label");
		if SCCN_chatsound[i] == 0 then 
			v_name = "OFF"; 
		else
			v_name = SCCN_chatsound[i];
		end		
		label:SetText(v_name);
		local label = getglobal("SND_DIZ"..i.."Label");
		label:SetText(SCCN_TRANSLATE[i]);
	end
end

function SCCN_CHATSOUND_SAVE()
	for i=1,5 do
		local slider = getglobal("SND_SLIDER"..i);
		local value  = slider:GetValue();
		if value == nil then value = 0; end
		SCCN_chatsound[i] = value;
		--SCCN_write(i.."="..SCCN_chatsound[i])
	end
	SCCN_CHATSOUND_ONLOAD();
end

function SCCN_CHATSOUND_VALUECHANGED(id)
	if(id > 0 and id < 6) then
		value = this:GetValue();
		if value == nil then value = 0; end
		if value == 0 then 
			v_name = "OFF"; 
		else
			v_name = value;
		end
		if(SND_LABEL2 == nil) then return 0; end;
		-- Status label updaten:
		if 			id == 1	then	getglobal(SND_LABEL1:GetName() .. "Label"):SetText(v_name);
		elseif		id == 2	then	getglobal(SND_LABEL2:GetName() .. "Label"):SetText(v_name);
		elseif 	id == 3	then	getglobal(SND_LABEL3:GetName() .. "Label"):SetText(v_name);
		elseif 	id == 4	then	getglobal(SND_LABEL4:GetName() .. "Label"):SetText(v_name);
		elseif 	id == 5	then	getglobal(SND_LABEL5:GetName() .. "Label"):SetText(v_name);
		end
	end
end

function SCCN_PLAYSOUND(id)
	if id >= 0 and id <= 5 then
	    -- Workaround for Sound Problem. Some client's need a initial sound playing before the actual sound starts. engine bug !?!? 
	    -- However, this worls.  -solariz-
	    -- Changes:
	    -- 16.10.2007 23:30:19 - Again trying to get rid of the MAC Crash bug.
	    local soundfile = tostring("Interface\\AddOns\\ChatMOD\\audio\\"..id..".mp3");
	        PlaySound("GAMEHIGHLIGHTFRIENDLYUNIT")
		    PlaySoundFile(soundfile)
	end
end


function ChatMOD_debug(level,msg)
		 if( SCCN_DEBUG ~= nil) then
			 if(msg == nil) then msg = "nil"; end;
			 if(level == nil) then level = "nil"; end;
			 SCCN_write(CHATMOD_COLOR["MAGENTA"]..level.."["..CHATMOD_COLOR["WHITE"]..msg..CHATMOD_COLOR["MAGENTA"].."]");
		 end;
end;

function ChatMOD_ReadClassColor(class)
    -- new Function since SVN_110 inspired by HatteSoul
    local color = string.format("%02x%02x%02x", RAID_CLASS_COLORS[class].r*255, RAID_CLASS_COLORS[class].g*255, RAID_CLASS_COLORS[class].b*255);
    return "|cff"..color;
end

---------- testing -------------
function ChatMODtest()
		 ChatMOD_COM_Send("INIT:"..CHATMOD_REVISION, "ALL");
end;