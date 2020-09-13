local OneRing = _G.OneRingLib;
local RingKeeper = type(OneRing) == "table" and type(OneRing.RingKeeper) == "table" and OneRing.RingKeeper or false;
if not (RingKeeper and RingKeeper.AddRing) then return; end

RingKeeper:AddRing("DruidUtility", {
	{r=0.07, g=0.48, b=0.93, id=29166}, -- innervate
	{r=0.87, g=0, b=.17, id=20484}, -- rebirth
	{r=0.91, g=0.65, b=0.06, id=22812}, -- bark
	{r=0.60, g=0.10, b=0.90, id=18960}, -- moonglade
	name="Utility", hotkey="BUTTON4", class="DRUID"
});
RingKeeper:AddRing("HunterAspects", {
	{r=0.60, g=0.50, b=0.18, id=13163}, -- monkey
	{r=0.21, g=0.71, b=0.56, id=13165}, -- hawk
	{r=0.73, g=0.41, b=0.01, id=5118}, -- cheetah
	{r=1, g=0.70, b=0, id=13159}, -- pack
	{r=0.59, g=0, b=0.24, id=13161}, -- beast
	{r=0.59, g=1, b=0.08, id=20043}, -- wild
	{r=0.10, g=0.20, b=0.80, id=34074}, -- viper
	name="Aspects", hotkey="BUTTON3", class="HUNTER"
});
RingKeeper:AddRing("HunterTraps", {
	{r=0.30, g=0.63, b=1, id=13809}, -- frost
	{r=0.90, g=0.46, b=0.02, id=13795}, -- immo
	{r=0.27, g=0.09, b=0.97, id=1499}, -- freeze
	{r=0.30, g=1, b=0, id=34600}, -- snake
	{r=0.76, g=0.32, b=0, id=13813}, -- explo
	name="Traps", hotkey="BUTTON4", class="HUNTER"
});
RingKeeper:AddRing("MageArmor", {
	{r=0.98, g=0.45, b=0, id=30482}, -- molten
	{r=0.1, g=0.40, b=1, id=168, id2=7302}, -- ice
	{r=0.5, g=0.9, b=0.90, id=6117}, -- mage
	name="Armor spells", hotkey="ALT-A", class="MAGE"
});
RingKeeper:AddRing("MageShields", {
	{r=0.4, g=0.8, b=1, id=1463}, -- mana
	{r=0, g=0.4, b=1, id=6143}, -- frost
	{r=0.5, g=0.3, b=1, id=45438}, -- block;
	{r=0.2, g=1, b=0.8, id=11426}, -- ice
	{r=1, g=0.4, b=0.2, id=543}, -- fire
	name="Mage Shields", hotkey="BUTTON4", class="MAGE"
});
RingKeeper:AddRing("MageTravel", {
	{r=0.47, g=0.88, b=0.77, id=33690, id2=33691, rtype="modrank"}, -- Shattrath
	{r=0.55, g=0.72, b=0.24, id=3561, id2=10059, rtype="modrank"}, -- Stormwind
	{r=0.66, g=0.15, b=0.88, id=3565, id2=11419, rtype="modrank"}, -- Darnassus
	{r=0.44, g=0.65, b=0.70, id=3566, id2=11420, rtype="modrank"}, -- Thunder Bluff
	{r=0.47, g=0.90, b=0.12, id=3563, id2=11418, rtype="modrank"}, -- Undercity
	{r=0.41, g=0.66, b=0.82, id=3562, id2=11416, rtype="modrank"}, -- Ironforge
	{r=0.91, g=0.49, b=0.13, id=3567, id2=11417, rtype="modrank"}, -- Orgrimmar
	{r=0.26, g=0.42, b=0.65, id=49359, id2=49360, rtype="modrank"}, -- Theramore
	{r=0.45, g=0.45, b=0.12, id=49358, id2=49361, rtype="modrank"}, -- Stonard
	{r=0.49, g=0.78, b=0.98, id=32272, id2=32267, rtype="modrank"}, -- Silvermoon
	{r=0.91, g=0.61, b=0.82, id=32271, id2=32266, rtype="modrank"}, -- Exodar
  name="Mage Travel", hotkey="BUTTON5", class="MAGE"
});
RingKeeper:AddRing("PaladinAuras", {
	{r=0xB8/255, g=0xA6/255, b=0x71/255, id=465}, -- devo
	{r=0.29, g=0.23, b=0.83, id=19746}, -- conc
	{r=0.72, g=0.36, b=0.58, id=20218}, -- sanctity
	{r=0.18, g=0.5, b=0.8, id=19888}, -- frost
	{r=1, g=1, b=0.65, id=32223}, -- crusader.
	{r=0.15, g=0.01, b=0.84, id=19876}, -- shadow
	{r=0.88, g=0.70, b=0.03, id=19891}, -- fire
	{r=0.62, g=0.36, b=0.78, id=7294}, -- ret
	name="Paladin Auras", hotkey="BUTTON4", class="PALADIN"
});
RingKeeper:AddRing("ShamanWeapons", {
	{r=0.55, g=0.75, b=0.95, id=8232}, -- windfury
	{r=1, g=0.52, b=0.10, id=8024}, -- flametongue
	{r=0.68, g=1, b=0.30, id=8017}, -- rockbiter
	{r=0.21, g=0.44, b=1, id=8033}, -- frostbrand
	name="Weapon Buffs", hotkey="BUTTON5", class="SHAMAN"
});
RingKeeper:AddRing("WarlockStones", {
	{r=0.4, g=1, b=0.05, id=6201}, -- health
	{r=0.70, g=0.05, b=0.90, id=693}, -- soul
	{r=0.85, g=0.45, b=1, id=29893}, -- ritual
	{r=1, g=0.50, b=0, id=6366}, -- fire
	{r=0, g=0.20, b=1, id=2362}, -- spell
	name="Stones", hotkey="BUTTON4", class="WARLOCK"
});
RingKeeper:AddRing("WarriorStances", {
	{r=1, g=0.3, b=0.3, id="Ability_Warrior_OffensiveStance"},
	{r=0.3, g=0.3, b=1, id="Ability_Warrior_DefensiveStance"},
	{r=0.3, g=1, b=0.3, rtype="mount"},
	{r=1, g=0.8, b=0.3, id="Ability_Racial_Avatar"},
	name="Warrior Stances", hotkey="BUTTON3", class="WARRIOR"
});
RingKeeper:AddRing("CommonTrades", {
	{r=0.85, g=0.82, b=0.68, id=3908}, -- tailoring
	{r=0.71, g=0.50, b=0.29, id=2108}, -- leatherworking
	{r=0.96, g=0.67, b=0.06, id=2018}, -- blacksmithing
	{r=0.20, g=0.10, b=0.90, id=25229}, -- jewelcrafting
	{r=0.96, g=0.94, b=0.16, id=7411}, -- enchanting
	{r=0.07, g=0.73, b=0.61, id=2259}, -- alchemy
	{r=0.76, g=0.25, b=0.06, id=2550}, -- cooking
	{r=0.75, g=0.15, b=0.15, id=3273}, -- first aid
	name="Trade Skills", hotkey="ALT-T"
});
RingKeeper:AddRing("DeathKnightPresence", {
	{r=0.90, g=0.30, b=0.10, id=48266}, -- blood
	{r=0.10, g=0.60, b=0.90, id=48263}, -- frost
	{r=0.30, g=0.90, b=0.10, id=48265}, -- unholy
	name="Death Knight Presence", hotkey="BUTTON3", class="DEATHKNIGHT"
});