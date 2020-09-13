local OneRing = _G.OneRingLib;
local rname, spells, ring, class, ringID = "OPieWarlockDemons", {
	{r=0xEC/255, g=0x39/25, b= 0x23/255, id=30146}, -- felguard
	{r=0.47, g=0.12, b=0.85, id=697}, -- void
	{r=0.97, g=0.22, b=0.06, id=688}, -- imp
	{r=1, g=0.12, b=0.20, id=5784, id2=23161, type="mount"}, -- steed
	{r=1, g=0.20, b=0.70, id=712}, -- succubus
	{r=0.10, g=0.40, b=0.80, id=691}, -- felhunter
}, {name="Demons", hotkey="BUTTON5"}, "WARLOCK";

local function updateRingData(force)
	local changed = force;

	for i, e in pairs(spells) do
		if not (e.spell and GetSpellInfo(e.spell)) then
			e.spell = GetSpellInfo((GetSpellInfo(e.id)));
			changed = changed or e.spell ~= nil;
		end
		if e.id2 and not (e.spell2 and GetSpellInfo(e.spell2)) then
			e.spell2 = GetSpellInfo((GetSpellInfo(e.id2)));
			changed = changed or e.spell2 ~= nil;
		end
		if type == "mount" and UnitLevel("player") >= 70 and not (e.mount and GetItemCount(e.mount) > 0) then
			e.mount = OneRing.xls:FindMount(false);
		end
	end

	if changed then
		for i=1,#ring do ring[i] = nil; end
		for i, e in pairs(spells) do
			if e.type == "mount" and e.mount then
				local type, cnt, land = "item", e.mount, e.spell2 or e.spell;
				if land then
					type, cnt = "macrotext", ("/cast [flyable] %s; %s"):format(e.mount, land);
				end
				ring[#ring+1] = {type, cnt, r=e.r, g=e.g, b=e.b};
			elseif e.spell or e.spell2 then
				ring[#ring+1] = {"spell", e.spell2 or e.spell, r=e.r, g=e.g, b=e.b};
			end
		end
		if not ringID then
			ringID = OneRing:CreateRing(rname, ring);
		else
			OneRing:SetRingData(ringID, ring);
		end
	end
end
local function updateMountCheck()
	if InCombatLockdown() then return; end
	local level, e = UnitLevel("player"), spells[4];
	if (level >= 40 and not e.spell) or
		 (level >= 60 and not e.spell2) or
		 (level >= 70 and not e.mount) then
		updateRingData();
	end
end

local function initializeRing(event, saved)
	if event == "PLAYER_LOGIN" then
		ring.preClick = updateMountCheck;
		updateRingData(true);
		EC_Register("SPELLS_UPDATE", "OneRing." .. rname .. ".Spells", updateRingData);
	end
end

if type(OneRing) == "table" and type(OneRing.RegisterRing) == "function" then
	if select(2,UnitClass("player")) == class then
		OneRing:RegisterRing(rname, initializeRing);
	end
end