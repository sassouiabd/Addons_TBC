local OneRing = _G.OneRingLib;
local rname, ring, rdata, ringID = "OPieShamanWolf", {
	{"macrotext", "/cancelform", r=0.3, g=0.6, b=1, caption="Cancel Form"},
	name="Ghost Wolf", hotkey="BUTTON3"
}, {};

local function updateRing(force)
	local changed = force == true;
	if not (rdata.wolf and GetSpellInfo(rdata.wolf)) then
		local sn = GetSpellInfo(2645);
		if sn then rdata.wolf, changed = GetSpellInfo(sn), true; end
	end
	local level = UnitLevel("player");
	if level >= 40 and not (rdata.lmount and GetItemCount(rdata.lmount) > 0) then
		local lmount = OneRing.xls:FindMount(true);
		if lmount then rdata.lmount, changed = lmount, true; end
	end
	if level >= 70 and not (rdata.fmount and GetItemCount(rdata.fmount) > 0) then
		local fmount = OneRing.xls:FindMount(false);
		if fmount then rdata.fmount, changed = fmount, true; end
	end
	if changed then
		if next(rdata) then
			local macro = "/cast ";
			if rdata.fmount then macro = macro .. "[flyable,outdoors,nomod] " .. rdata.fmount .. "; " end
			if rdata.lmount then macro = macro .. "[outdoors,nocombat,nomod] " .. rdata.lmount .. "; " end
			if rdata.wolf then macro = macro .. rdata.wolf; end
			ring[2] = {"macrotext", macro, r=0.15, g=1, b=0.15};
		end
		if not ringID then
			ringID = OneRing:CreateRing(rname, ring);
		else
			OneRing:SetRingData(ringID, ring);
		end
	end
end

local function initializeRing(event)
	if event == "PLAYER_LOGIN" then
		rdata.preClick = updateRing;
		updateRing(true);
		EC_Register("SPELLS_CHANGED", "OneRing.Shaman.Wolf.Spells", updateRing);
	end
end

if type(OneRing) == "table" and type(OneRing.RegisterRing) == "function" then
	if select(2,UnitClass("player")) == "SHAMAN" then
		OneRing:RegisterRing(rname, initializeRing);
	end
end