local OneRing = _G.OneRingLib;
local ringID, ShiftInfo, ShiftRingData = nil, {
	{r=0.8, g=0.4, b=1, i="Spell_Nature_ForceOfNature", id="special"},
	{r=0.3, g=1, b=0.4, i="Ability_Druid_TreeofLife", id="special"},
	{r=1, g=0.3, b=0.3, i="Ability_Racial_BearForm", id="bear"},
	{r=0.2, g=0.7, b=1, i={"Ability_Druid_FlightForm", "Ability_Druid_TravelForm", "Ability_Druid_AquaticForm"}, id="travel"},
	{r=1, g=1, b=0, i="Ability_Druid_CatForm", id="cat"}
}, {name="Druid Forms", hotkey="BUTTON3"};
local lockMountOnBuffs = {"Inv_Misc_SummerFest_BrazierGreen", "INV_BannerPVP_02", "INV_BannerPVP_01"};

local function updateRingData(forceChange)
	local changed = (forceChange == true);

	-- Find ability names
	for i=1,#ShiftInfo do
		if type(ShiftInfo[i].i) == "string" and not (ShiftInfo[i].spell and GetSpellInfo(ShiftInfo[i].spell)) then
			ShiftInfo[i].spell = OneRing.xls:FindAbility(ShiftInfo[i].i);
			changed = changed or (ShiftInfo[i].spell ~= nil);
		elseif type(ShiftInfo[i].i) == "table" then
			ShiftInfo[i].spell = ShiftInfo[i].spell or {};
			for j=1,#ShiftInfo[i].i do
				if not (ShiftInfo[i].spell[j] and GetSpellInfo(ShiftInfo[i].spell[j])) then
					ShiftInfo[i].spell[j] = OneRing.xls:FindAbility(ShiftInfo[i].i[j]);
					changed = changed or (ShiftInfo[i].spell[j] ~= nil);
				end
			end
		end
	end

	-- Find a land mount
	if UnitLevel("player") >= 40 and (ShiftInfo[4].mount == nil or GetItemCount(ShiftInfo[4].mount) == 0) then
		local mount = OneRing.xls:FindMount(true);
		ShiftInfo[4].mount, changed = mount, changed or (ShiftInfo[4].mount ~= mount);
	end

	-- update the ring
	if changed then
		for i=1,#ShiftRingData do ShiftRingData[i] = nil;	end
		for i=1,#ShiftInfo do
			local e = ShiftInfo[i];
			if type(e.spell) == "string" then
				ShiftRingData[#ShiftRingData+1] = {"spell", e.spell, r=e.r, g=e.g, b=e.b};
			elseif type(e.spell) == "table" then
				local m = "/cancelform [noflyable]\n/cast";
				if e.spell[1] then m = m .. " [flyable,nocombat,noswimming][flying] " .. e.spell[1] .. ";";	end
				if e.spell[3] then m = m .. " [swimming] " .. e.spell[3] .. ";"; end
				if e.mount then m = m .. " [nocombat,nomod] " .. e.mount .. ";"; end
				if e.spell[2] then m = m .. " [outdoors] " .. e.spell[2] .. ";"; end
				if m:match(";$") then
					ShiftRingData[#ShiftRingData+1] = {"macrotext", m, r=e.r, g=e.g, b=e.b, preClick=e.preClick, xDSId=e.id};
				end
			end
		end
		if not ringID then
			ringID = OneRing:CreateRing("OPieDruidShift", ShiftRingData);
		else
			OneRing:SetRingData(ringID, ShiftRingData);
		end
	end
end

-- Check that mount data collected still applies
local function updateRingMount()
	if UnitLevel("player") >= 40 and not ShiftInfo[4].mount then
		updateRingData();
	end
end

-- Prevent player from mounting when that would be silly (carrying PvP flags)
local function DS_IsPreventedFromMounting()
	if InCombatLockdown() or not ShiftInfo[4].mount then return false; end
	for k, v in pairs(lockMountOnBuffs) do
		if OneRing.xls:FindBuff(v) then return true; end
	end
	return false;
end
local function DS_TravelHint()
	local usable, cooldown, icon, caption;
	if IsSwimming() and ShiftInfo[4].spell[3] then
		caption, usable, icon, cooldown, cd = ShiftInfo[4].spell[3], IsUsableSpell(ShiftInfo[4].spell[3]), GetSpellTexture(ShiftInfo[4].spell[3]), GetSpellCooldown(ShiftInfo[4].spell[3]);
	elseif (not IsIndoors()) and ShiftInfo[4].spell[2] then
		caption, usable, icon, cooldown, cd = ShiftInfo[4].spell[2], IsUsableSpell(ShiftInfo[4].spell[2]), GetSpellTexture(ShiftInfo[4].spell[2]), GetSpellCooldown(ShiftInfo[4].spell[2]);
	end
	if cooldown and cooldown ~= 0 then cooldown = cooldown + cd - GetTime(); end
	usable = not not (usable and (cooldown == nil or cooldown == 0));
	return usable, cooldown, icon, caption;
end
function ShiftRingData.preClick(ring, slice)
	updateRingMount();
	local cantMount = DS_IsPreventedFromMounting();
	for k, v in ipairs(ShiftRingData) do
		if v.xDSId == "travel" and (not not v.actionHint) == (not cantMount) then
			--v.actionHint = cantMount and DS_TravelHint or nil;
			return OneRing:SetRingData(ringID, ShiftRingData);
		end
	end
end

local function initializeRing(event, saved)
	if event == "PLAYER_LOGIN" then
		updateRingData(true);
		EC_Register("SPELLS_UPDATE", "OneRing.Druid.Shift.Spells", updateRingData);
		EC_Register("BAG_UPDATE", "OneRing.Druid.Shift.Bags", function() updateRingData() return "remove"; end);
	end
end


if type(OneRing) == "table" and type(OneRing.RegisterRing) == "function" then
	if select(2,UnitClass("player")) == "DRUID" then
		OneRing:RegisterRing("OPieDruidShift", initializeRing);
		table.remove(lockMountOnBuffs, UnitFactionGroup("player") == "Alliance" and 2 or 3);
	end
end