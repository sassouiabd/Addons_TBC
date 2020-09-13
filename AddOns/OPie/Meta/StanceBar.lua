local OneRing = OneRingLib;
local assert, print = OneRing.xlu.assert, OneRing.xlu.print;

local frame = ShapeshiftBarFrame;
local keeper, parent = CreateFrame("Frame"), frame:GetParent();
keeper:Hide();

local hiddenClasses, SV, playerName, defaultState = {DRUID=true, PALADIN=true, WARRIOR=true}, {};
local pendingValue;

local function SetStanceBarVisibility(shown)
	assert(type(shown) == "boolean", "Syntax: SetStanceBarVisibility(shown); %q", 2, tostring(shown));
	if InCombatLockdown() then
		pendingValue = shown;
	else
		frame:SetParent(shown and parent or keeper);
		if shown and frame:IsShown() then frame:Show(); end
		pendingValue = nil;
	end
	if shown == defaultState then shown = nil; end
	SV[playerName] = shown;
end
local function GetStanceBarVisibility()
	if pendingValue ~= nil then
		return pendingValue;
	end
	return frame:GetParent() == parent;
end
local function syncPending(event)
	if pendingValue ~= nil then
		SetStanceBarVisibility(pendingValue);
	end
end
local function initializer(event, sv)
	if event == "ADDON_LOADED" then
		defaultState = not hiddenClasses[select(2, UnitClass("player"))];
		local state = defaultState;
		playerName = GetRealmName() .. "-" .. UnitName("player");
		if sv and type(sv[playerName]) == "boolean" then state = sv[playerName]; end
		SetStanceBarVisibility(state);
		SV = sv or SV;
	end
end
local function IsValidPlayerClass()
	return hiddenClasses[select(2, UnitClass("player"))] ~= nil;
end

OneRing.ext.StanceBar = {
	SetVisibility=SetStanceBarVisibility,
	GetVisibility=GetStanceBarVisibility,
	IsUsed=IsValidPlayerClass
};

OneRing:RegisterRing("OPie.Internal.StanceBar", initializer);
EC_Register("PLAYER_REGEN_ENABLED", "OPie.StanceBar.Combat", syncPending);