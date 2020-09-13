--[[
RingKeeper simplifies creation and management of ability rings. RingKeeper rings are specified
by their originator (either plug in code or a configuration interface); RingKeeper then maintains
the ring based on player abilities, inventory items etc; rings can be designated to persist
through interface reloads (in which case they're safed in RingKeeper saved variables).

Because RingKeeper plug-ins contain no functionality other than specifying a ring to be managed
by RingKeeper, RingKeeper rings can be shared with other players without requiring them to 
download additional lua files. On the other hand, RingKeeper allows less flexibility in ring
description than the OneRing API, so custom plug-ins may still be useful in some circumstances.
]]
local OneRing = _G.OneRingLib;
local RingKeeper, assert, copy, print = {}, OneRing.xlu.assert, OneRing.xlu.copy, OneRing.xlu.print;
local RK_RingDesc, RK_RingData, RK_RingIDs, RK_Version, RK_Rev, SV = {}, {}, {}, 0, 8;
local RK_DeletedRings;
local RK_ManagedRingNames, RK_ConditionedRings = {}, setmetatable({}, {__index=function(t,k) t[k] = {}; return t[k]; end});
local landMount, flightMount;
local unlocked, queue = false, {};

-- Ring description -> OneRing propsTable conversion and updates code
local RK_RingPreClick; -- upvalue;
local function RK_IsRelevantRingDescription(desc)
	if (desc.class ~= nil and desc.class ~= select(2, UnitClass("player"))) or
		 (desc.limitToChar ~= nil and desc.limitToChar ~= UnitName("player")) then
		return false;
	end
	return true;
end
local function RK_Initializer(event, sv)
	if event == "PLAYER_LOGIN" then
		SV, unlocked = sv, true;
		local pname, deleted = UnitName("player"), sv.OPieDeletedRings or {};
		RK_DeletedRings, sv.OPieDeletedRings = {}, nil;

		for k, v in pairs(queue) do
			if deleted[k] == nil and (sv[k] == nil or (sv[k].version or 0) < (v.version or 0)) then
				local ok, err = pcall(RingKeeper.AddRing, RingKeeper, k, v);
				if not ok then
					EC_Error("RingKeeper", k, err:gsub("Interface\\AddOns\\[^\\]+\\", ""));
				end
				sv[k] = nil;
			elseif deleted[k] then
				RK_DeletedRings[k] = true;
			end
		end
		for k, v in pairs(sv) do
			for i, v2 in ipairs(v) do
				if v2.c and not (v2.r and v2.g and v2.b) then
					local r,g,b = v2.c:match("^(%x%x)(%x%x)(%x%x)$");
					if r then
						v2.r, v2.g, v2.b, v2.c = tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255, nil;
					end
				end
			end
			local ok, err = pcall(RingKeeper.AddRing, RingKeeper, k, v);
			if not ok then
				EC_Error("RingKeeper", k, err:gsub("Interface\\AddOns\\[^\\]+\\", ""));
			end
		end
	elseif event == "PLAYER_LOGOUT" then
		for k, v in pairs(sv) do sv[k] = nil; end
		for k, v in pairs(RK_RingDesc) do
			if type(v) == "table" and v.save and not RK_DeletedRings[k] then
				for i, v2 in ipairs(v) do
					v2.c = ("%02x%02x%02x"):format((v2.r or 0) * 255, (v2.g or 0) * 255, (v2.b or 0) * 255);
					v2.spell, v2.spell2, v2.type, v2.action = nil, nil, nil, nil;
					v2.b, v2.g, v2.r = nil, nil, nil;
				end
				sv[k] = v;
			end
		end
		sv.OPieDeletedRings = next(RK_DeletedRings) and RK_DeletedRings or nil;
	end
end
local function RK_CheckMounts()
	local level, oLand, oFlight = UnitLevel("player"), landMount, flightMount;
	if level >= 40 and (landMount == nil or GetItemCount(landMount) == 0) then
		landMount = OneRing.xls:FindMount(true);
	end
	if level >= 70 and (flightMount == nil or GetItemCount(flightMount) == 0) then
		flightMount = OneRing.xls:FindMount(false);
	end
	return oLand ~= landMount or oFlight ~= flightMount;
end
local function RK_SyncRingEntry(e)
	local etype, action, changed = e.type, e.action, false;
	
	local rtype = e.rtype;
	if rtype == nil or rtype == "uprank" or rtype == "modrank" then
		local idt, missSpell, rank = type(e.id), (e.spell == nil or GetSpellInfo(e.spell) == nil);
		if idt == "string" and missSpell then
			e.spell = OneRing.xls:FindAbility(e.id);
		elseif idt == "number" then
			e.spell, rank = GetSpellInfo(e.id)
			if e.erank and e.spell and rank ~= "" then
				e.spell = e.spell .. "(" .. rank .. ")"
			elseif e.spell then
				e.spell = GetSpellInfo(e.spell);
			end
		end
	
		idt, missSpell = type(e.id2), (e.spell2 == nil or GetSpellInfo(e.spell2) == nil);
		if idt == "string" and missSpell and rtype ~= "macro" then
			e.spell2 = OneRing.xls:FindAbility(e.id2);
		elseif idt == "number" and rtype ~= "macro" then
			e.spell2, rank = GetSpellInfo(e.id2);
			if e.erank and e.spell2 and rank ~= "" then
				e.spell2 = e.spell2 .. "(" .. rank .. ")"
			elseif e.spell2 then
				e.spell2 = GetSpellInfo(e.spell2);
			end
		end
	end
	
	if rtype == "mount" then changed = RK_CheckMounts(); end

	if rtype == "modrank" and e.spell2 and e.spell then
		e.type, e.action = "macrotext", "/cast [mod] " .. e.spell2 .. "; " .. e.spell;
	elseif rtype == "uprank" or rtype == "modrank" or not rtype then
		e.type, e.action = "spell", e.spell2 or e.spell;
	elseif rtype == "mount" then
		if landMount and flightMount then
			e.type, e.action = "macrotext", "/cast [flyable,nomod] " .. flightMount .. "; " .. landMount;
		elseif landMount or flightMount then
			e.type, e.action = "item", landMount or flightMount;
		else
			e.type = nil;
		end
	elseif rtype == "macro" or rtype == "macrotext" then
		e.type, e.action = rtype, e.id;
	elseif rtype == "item" then
		e.type, e.action = rtype, "item:" .. e.id;
	elseif rtype == "nitem" then
		e.type, e.action = "item", GetItemInfo(e.id);
	elseif rtype == "companion" then
		local name, _, icon = GetSpellInfo(e.id);
		e.type, e.action, e.autocaption, e.autoicon = "spell", name, name, icon;
	end
	
	if e.onlyWhilePresent and e.type then
		local found = false;
		if e.type == "item" then
			found = GetItemCount(e.action) > 0;
		elseif rtype == "companion" then
			for i=1,GetNumCompanions("CRITTER") do
				local cID, cName, csID = GetCompanionInfo(i, "CRITTER");
				if csID then found = true; break; end
			end
			for i=1,found and 0 or GetNumCompanions("MOUNT") do
				local cID, cName, csID = GetCompanionInfo(i, "CRITTER");
				if csID then found = true; break; end
			end
		end
		e.type = found and e.type or nil;
	end

	return changed or e.type ~= etype or e.action ~= action;
end
local function RK_SyncRing(name, force)
	local desc, ring, changed = RK_RingDesc[name], RK_RingData[name], (force == true);
	if not ring then
		RK_RingData[name] = {};
		ring, changed = RK_RingData[name], true;
	end
	if not RK_IsRelevantRingDescription(desc) then return; end
	
	-- Parse description
	RK_ConditionedRings.item[name], RK_ConditionedRings.companion[name] = nil, nil;
	for i, e in ipairs(desc) do
		changed = RK_SyncRingEntry(e) or changed;
		if e.onlyWhilePresent then
			RK_ConditionedRings[e.rtype][name] = true;
		end
	end

	if changed or not RK_RingIDs[name] then
		-- Clear previous ring entries, copy metadata again
		for k, v in pairs(ring) do
			ring[k] = nil;
		end
		for k, v in pairs(desc) do 
			if type(k) ~= "number" then 
				ring[k] = v; 
			end
		end
		
		-- Copy well-defined ring entries from parsed description
		local hasMount = false;
		for i, e in ipairs(desc) do
			if e.type and e.action then
				ring[#ring+1] = {e.type, e.action, e.target, r=e.r, g=e.g, b=e.b, caption=e.caption or e.autocaption, icon=e.icon or e.autoicon};
			end
			hasMount = hasMount or (e.rtype == "mount");
		end
		ring.preClick = (hasMount or RK_ConditionedRings.item[name]) and RK_RingPreClick or nil;
		
		-- Submit ring for update
		if not RK_RingIDs[name] then
			RK_RingIDs[name] = OneRing:CreateRing(name, ring);
		else
			OneRing:SetRingData(RK_RingIDs[name], ring);
		end
	end
end
RK_RingPreClick = function(ring, slice)
	RK_SyncRing(RK_RingDesc[ring].name);
end
local function RK_Event(event, ...)
	if event == "SPELLS_CHANGED" then
		for k,v in pairs(RK_RingDesc) do
			RK_SyncRing(k);
		end
	elseif event == "PLAYER_REGEN_DISABLED" or event == "COMPANION_UPDATE" then
		for k in pairs(RK_ConditionedRings[event == "PLAYER_REGEN_DISABLED" and "item" or "companion"]) do
			RK_SyncRing(k);
		end
	end
end

-- Chunk below deals with ring sharing through addon messages.
local RKS_isListening, RKS_transfers = true, {};
local RKS_SReq, RKS_SRep, RKS_SRes = "RK/HEAD", "RK/REPL", "RK/CONC";
local RKS_TransferMetaKeys, RKS_TransferEntryKeys = {"name", "hotkey", "hotkeyState", "mindist", "offset", "gap", "author"}, {"r", "g", "b", "caption", "icon", "id", "id2", "rtype", "erank", "onlyWhilePresent"};
local RKS_StringEnc, RKS_StringDec = {["&"] = "&a", ["["] = "&s", ["]"]="&e", [":"] = "&c"}, {};
for k,v in pairs(RKS_StringEnc) do RKS_StringDec[v] = k; end
for i, v in ipairs(RKS_TransferMetaKeys) do RKS_TransferMetaKeys[v] = true; end
for i, v in ipairs(RKS_TransferEntryKeys) do RKS_TransferEntryKeys[v] = true; end

local function RK_GenTransferID()
	local n;
	while n == nil or RKS_transfers[n] do
		n = ("%06x"):format(math.random(256^3-1));
	end
	return n;
end
local function RK_SummarizeInto(t, dict, data, key)
	local ci, prefix, entry = #t + 1, key .. ":";
	for _, k in ipairs(dict) do
		local v = data[k];
		if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
			entry = (" %s:%s[%s]"):format(k, type(v):sub(1,1), tostring(v):gsub("[%[%]&:]", RKS_StringEnc));
			t[ci] = (t[ci] and t[ci] or prefix) .. entry;
			while #t[ci] > 220 do
				ci, t[ci], t[ci+1] = ci + 1, t[ci]:sub(1, 219) .. "+", "+" .. t[ci]:sub(220);
			end
		end
	end
end
local function RK_SummarizeRing(data)
	local summary = {};
	RK_SummarizeInto(summary, RKS_TransferMetaKeys, data, "meta");
	for i, r in ipairs(data) do
		RK_SummarizeInto(summary, RKS_TransferEntryKeys, r, i);
	end
	return summary;
end
local function RK_CreateFromSummary(summary)
	local t = {};
	for i, d in ipairs(summary) do
		while d:sub(-1) == "+" do d = d .. table.remove(summary, i+1):sub(2); end
		local k, entries, data, dict = d:match("^(%S+):(.+)$");
		if k == "meta" then
			data, dict = t, RKS_TransferMetaKeys;
		elseif k and k:match("^%d+$") then
			k = tonumber(k);
			if k == 1 or t[k-1] then
				t[k] = t[k] or {};
				data, dict = t[k], RKS_TransferEntryKeys;
			end
		end
		if not (data and dict and entries) then return false, "Unknown summary key: " .. k; end
		for vk, vt, vv in entries:gmatch(" ([^:]+):([nsb])%[([^%]]+)%]") do
			if dict[vk] == true then
				if vt == "n" then data[vk] = tonumber(vv);
				elseif vt == "b" then data[vk] = vv == "true";
				elseif vt == "s" then data[vk] = vv:gsub("&[asec]", RKS_StringDec); end
			else
				return false, "Unknown entry: " .. k .. "." .. vk;
			end
		end
	end
	return true, t;
end
local function RK_Message(e, prefix, message, channel, sender)
	if prefix:sub(1, 3) ~= "RK/" then return;
	elseif prefix == "RK/VR" then
		local v, r, k, m, n = RK_Version, RK_Rev, OneRing:GetVersion();
		SendAddonMessage("RK/V", ("%d %d / %d %d [%s]"):format(v, r, m, n, k), "WHISPER", sender)
		return;
	elseif channel ~= "WHISPER" then return;
	end

	local transferID = prefix:match("^RK/(%x+)$");
	if prefix == RKS_SReq then -- requesting to send
		local localID, remoteID, lineCount, major, rev, rname, title = RK_GenTransferID(), message:match("^(%x+) #(%d+) V(%d+)%.(%d+) %[([^%]]+)%] %[([^%]]+)%]");
		if remoteID and RKS_isListening  then
			rname = rname:gsub("&[asec]", RKS_StringDec);
			RKS_transfers[localID] = {source=sender, remID=remoteID, lines=tonumber(lineCount), name=rname, title=title};
			EC_Raise("RK.Transfer", "Request", localID, sender, rname, title);
		end
	elseif prefix == RKS_SRep then -- replying to
		local reply, localID, remoteID = message:match("^(%S+) (%x+) (%x+)");
		if localID and RKS_transfers[localID] and RKS_transfers[localID].target == sender and not RKS_transfers[localID].remID then
			RKS_transfers[localID].remID = remoteID;
			if reply == "YES" then
				EC_Raise("RK.Transfer", "Accepted", localID, sender, RKS_transfers[localID].title);
				local t, r, s, c = RKS_transfers[localID].summary, remoteID, sender, RKS_transfers[localID].lines;
				EC_Timer("RK.Transfer." .. localID, function ()
					SendAddonMessage("RK/" .. r, table.remove(t, 1), "WHISPER", s);
					EC_Raise("RK.Transfer", "Data", localID, c-#t, c);
					return next(t) and "" or "remove";
				end, 0.5);
			else
				EC_Raise("RK.Transfer", "Rejected", localID, sender, RKS_transfers[localID].title);
				RKS_transfers[localID] = nil;
			end
		end
	elseif prefix == RKS_SRes then
		local localID, status, msg = message:match("^(%x+) (%S+) (%S*)$");
		local t = RKS_transfers[localID or 1];
		if localID and t and t.target == sender then
			if status == "OK" then
				EC_Raise("RK.Transfer", "Complete", localID, "OUT", sender, t.title);
			else
				EC_Raise("RK.Transfer", "Failed", localID, "OUT", sender, t.title, msg);
			end
			RKS_transfers[localID] = nil;
			EC_DelTimer("RK.Transfer." .. localID);
		end
	elseif transferID and RKS_transfers[transferID] then
		local t = RKS_transfers[transferID];
		if t.source == sender and t.summary then
			t.summary[#t.summary+1] = message;
			EC_Raise("RK.Transfer", "Data", transferID, #t.summary, t.lines);
			if #t.summary == t.lines then
				local ok, result = RK_CreateFromSummary(t.summary);
				SendAddonMessage(RKS_SRes, t.remID .. " " .. (ok and "OK " or ("FAIL " .. tostring(result))), "WHISPER", sender);
				if ok then
					result.save = true;
					if not t.overwrite then	t.name = RingKeeper:GenFreeRingName(t.name); end
					RingKeeper[RK_RingDesc[t.name] and "ModifyRing" or "AddRing"](RingKeeper, t.name, result);
					EC_Raise("RK.Transfer", "Complete", transferID, "IN", sender, t.title);
				else
					EC_Raise("RK.Transfer", "Failed", transferID, "IN", sender, t.title, result);
				end
				RKS_transfers[transferID] = nil;
			end
		end
	end
end
-- That concludes non-public part of the ring sharing code.

-- Public API
function RingKeeper:AddRing(name, desc)
	assert(type(name) == "string" and type(desc) == "table", "Syntax: RingKeeper:AddRing(name, descTable);", 2);
	assert(RK_RingDesc[name] == nil, "Ring %q is already described.", 2, name);
	assert(unlocked == true or not queue[name], "Ring %q is already described.", 2, name);
	if not unlocked then
		queue[name] = desc;
		return;
	end
	local rid = RK_RingIDs[name] or (#RK_ManagedRingNames + 1);
	RK_ManagedRingNames[rid], RK_RingDesc[name], RK_DeletedRings[name] = name, copy(desc), nil;
	RK_SyncRing(name, true);
end
function RingKeeper:ModifyRing(name, desc)
	assert(type(name) == "string" and type(desc) == "table", "Syntax: RingKeeper:ModifyRing(name, descTable);", 2);
	assert(RK_RingDesc[name], "Ring %q is not described.", 2, name);
	desc.save = true; -- modifications must be saved.
	RK_RingDesc[name] = copy(desc, nil, RK_RingDesc[name]);
	RK_SyncRing(name, true);
end
function RingKeeper:RemoveRing(name)
	assert(type(name) == "string", "Syntax: RingKeeper:RemoveRing(name);", 2);
	assert(RK_RingDesc[name], "Ring %q is not described.", 2, name);
	if RK_RingIDs[name] then
		-- Replace ring with dummy, unbind.
		OneRing:SetRingData(RK_RingIDs[name], {name="Remnant", removed=true});
		OneRing:SetRingBinding(RK_RingIDs[name], nil);
		OneRing:ClearRingOptions(RK_RingIDs[name]);
	end
	RK_RingDesc[name], SV[name], RK_DeletedRings[name] = nil, nil, true;

	for i,n in ipairs(RK_ManagedRingNames) do
		if n == name then
			table.remove(RK_ManagedRingNames, i);
			return;
		end
	end
end
function RingKeeper:GetRingDescription(name)
	assert(type(name) == "string", "Syntax: descTable = RingKeeper:GetRingDescription(name);", 2);
	local ring = assert(RK_RingDesc[name], "Ring %q is not described.", 2, name);
	return copy(ring);
end
function RingKeeper:GetVersion()
	return RK_Version, RK_Rev;
end
function RingKeeper:GetManagedRings()
	return #RK_ManagedRingNames;
end
function RingKeeper:GetManagedRingName(id)
	assert(type(id) == "number", "Syntax: name, hname, active = RingKeeper:GetManagedRingName(index);", 2);
	local id = assert(RK_ManagedRingNames[id], "Index out of range", 2);
	return id, RK_RingDesc[id].name or id, RK_RingIDs[id] ~= nil;
end
function RingKeeper:RestoreDefaults()
	for k, v in pairs(queue) do
		if RK_IsRelevantRingDescription(v) then -- Do not reset rings that cannot be "seen".
			if RK_RingDesc[k] ~= nil then
				self:ModifyRing(k, queue[k]);
			else
				self:AddRing(k, queue[k]);
			end
		end
	end
end
function RingKeeper:GenFreeRingName(base)
	assert(type(base) == "string", "Syntax: name = RingKeeper:GenFreeRingName(\"base\");", 2);
	local ap, c = "", 1;
	while RK_RingDesc[base .. ap] or SV[base .. ap] do ap, c = "_" .. math.random(2^c), c+1; end
	if base:match("^OPie") then base = "X" .. base; end
	return base .. ap;
end

-- Public API: Ring Sharing
function RingKeeper:SendRing(name, player)
	assert(type(name) == "string" and type(player) == "string", "Syntax: RingKeeper:SendRing(\"ringName\", \"playerName\");", 2);
	assert(RK_RingDesc[name], "Ring %q is not described", 2, name);
	local id, tid, summary, title = RK_GenTransferID(), "%s #%s V%s.%s [%s] [%s]", RK_SummarizeRing(RK_RingDesc[name]), RK_RingDesc[name].name or name;
	RKS_transfers[id] = {summary=summary, target=player, lines=#summary, name=name, title=title};
	SendAddonMessage(RKS_SReq, tid:format(id, #summary, RK_Version, RK_Rev, name:sub(1,50):gsub("[%]%[&]", RKS_StringEnc), title:sub(1,50):gsub("[%]%[&]", RKS_StringEnc)), "WHISPER", player);
end
function RingKeeper:AcceptRing(transfer, accept, overwrite)
	assert(type(transfer) == "string" and type(accept) == "boolean" and (overwrite == nil or type(overwrite) == "boolean"), "Syntax: RingKeeper:AcceptRing(\"transferID\", accept[, overwrite]);");
	local tdata = assert(RKS_transfers[transfer], "Transfer %q does not exist.", 2, transfer);
	SendAddonMessage(RKS_SRep, (accept and "YES " or "NO ") .. tdata.remID .. " " .. transfer, "WHISPER", tdata.source);
	if accept then
		tdata.overwrite, tdata.summary, tdata = overwrite or false, {};
	else
		RKS_transfers[transfer] = nil;
	end
end
function RingKeeper:GetTransferInfo(id)
	assert(type(id) == "string", "Syntax: RingKeeper:GetTransferInfo(\"id\");", 2);
	local t = RKS_transfers[id];
	if not t then return; end
	local direction, target = t.target and "OUT" or "IN", t.target or t.source;
	return direction, target, t.remID and t.summary and true, t.title, t.lines, t.summary and #t.summary or 0;
end

if type(OneRing) == "table" then
	OneRing.RingKeeper = RingKeeper;
	OneRing:RegisterRing("RingKeeper", RK_Initializer);
	EC_Register("SPELLS_CHANGED", "OneRing.RingKeeper.Update", RK_Event);
	EC_Register("PLAYER_REGEN_DISABLED", "OneRing.RingKeeper.Items", RK_Event);
	EC_Register("CHAT_MSG_ADDON", "OneRing.RingKeeper.Share", RK_Message);
end