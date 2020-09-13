local OneRing = _G.OneRingLib;
local rname, rdesc = "OPieRaidSymbols", {
	{"func", r=1, g=1, b=0}, -- yellow star
	{"func", r=1, g=0.5, b=0.05}, -- orange circle
	{"func", r=1, g=0.30, b=1}, -- purple diamond
	{"func", r=0.20, g=1, b=0.20}, -- green triangle
	{"func", r=0.65, g=0.84, b=1}, -- silver moon
	{"func", r=0.20, g=0.20, b=1}, -- blue square
	{"func", r=1, g=0.10, b=0.10}, -- red cross
	{"func", r=0.74, g=0.70, b=0.60}, -- white skull
	name="Raid Markers", hotkey="ALT-R"
};
local function ringClick(id)
	if GetRaidTargetIndex("target") == id then id = 0; end
	SetRaidTarget("target", id);
end

local function initializeRing(event, saved)
	if event == "PLAYER_LOGIN" then
		for i=1,8 do
			rdesc[i][2], rdesc[i][3], rdesc[i].icon = ringClick, i, "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i;
		end
		OneRing:CreateRing(rname, rdesc);
	end
end

if type(OneRing) == "table" and type(OneRing.RegisterRing) == "function" then
	OneRing:RegisterRing(rname, initializeRing);
end