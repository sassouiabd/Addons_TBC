local OneRing = _G.OneRingLib;
local rname, rdesc = "OPieTrinkets", {
	{"item", (GetInventorySlotInfo("Trinket0Slot")), r=0.05, g=0.75, b=0.95}, -- top
	{"item", (GetInventorySlotInfo("Trinket1Slot")), r=0.95, g=0.75, b=0.05}, -- bottom
	name="Trinkets"
};

local function initializeRing(event, saved)
	if event == "PLAYER_LOGIN" then
		OneRing:CreateRing(rname, rdesc);
	end
end

if type(OneRing) == "table" and type(OneRing.RegisterRing) == "function" then
	OneRing:RegisterRing(rname, initializeRing);
end