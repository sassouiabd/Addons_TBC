--[[
	ClosetGnome storage mechanics:
		ClosetGnome.db.char.set contains set data name={item array}
		ClosetGnome.db.char.icons contains optional icons, name=("texture" or nil)
	Events:
		ClosetGnome_DeleteSet
		ClosetGnome_AddSet
		ClosetGnome_UpdateSet
]]

local OneRing = _G.OneRingLib;
local rname, ring, ringID = "OPieClosetGnome", {name="Closet Gnome", hotkey="ALT-G"};
local cgSetOrder, locked, colorsGenerated, floor = {}, true, 0, math.floor;

local function ringClicked(set)
	ClosetGnome:WearSet(set);
end
local function generateColor(v, s)
	local hue, hstep = 0, 360;
	for i=1,colorsGenerated do
		hue = hue + 2*hstep;
		if hue >= 360 then hue, hstep = hstep/2, hstep/2; end
	end
	colorsGenerated = colorsGenerated + 1;
	hue = (hue + 25) % 360;
	
	local h = floor(hue/60) % 6;
	local f = (hue/60) % 1;
	local p, q, t = v - v * s, v - v * f * s, v - v*s + v * f * s;
	if h == 0 then return v, t, p;
	elseif h == 1 then return q, v, p;
	elseif h == 2 then return p, v, t;
	elseif h == 3 then return p, q, v;
	elseif h == 4 then return t, p, v;
	elseif h == 5 then return v, p, q;
	end
end

local function doUpdateRing()
	if ringID and not locked then
		OneRing:SetRingData(ringID, ring);
	elseif #ring > 0 and not locked then
		ringID = OneRing:CreateRing(rname, ring);
	end
end
local function GnomeEvent_AddSet(name)
	local r,g,b = generateColor(1, 1);
	local pos = #ring+1;
	for i=1,#ring do
		if ring[i][3] > name then
			pos = i;
			break;
		end
	end
	table.insert(ring, pos, {"func", ringClicked, name, r=r,g=g,b=b, icon=ClosetGnome.db.char.icons[name], caption="Equip " .. name});
	for i=pos,#ring do
		cgSetOrder[ring[i][3]] = i;
	end

	doUpdateRing();
end
local function GnomeEvent_DeleteSet(name)
		local index = cgSetOrder[name];
		table.remove(ring, index);
		cgSetOrder[name] = nil;
		for k, v in pairs(cgSetOrder) do
			if v > index then cgSetOrder[k] = v - 1; end
		end
		doUpdateRing();
end
local function GnomeEvent_UpdateSet(name)
	ring[cgSetOrder[name]].icon = ClosetGnome.db.char.icons[name];
	doUpdateRing();
end

local function initializeRing(event, saved)
	if event == "PLAYER_LOGIN" and AceLibrary then
		local AceEvent = AceLibrary("AceEvent-2.0");
		AceEvent:RegisterEvent("ClosetGnome_DeleteSet", GnomeEvent_DeleteSet);
		AceEvent:RegisterEvent("ClosetGnome_AddSet", GnomeEvent_AddSet);
		AceEvent:RegisterEvent("ClosetGnome_UpdateSet", GnomeEvent_UpdateSet);
		for k in pairs(ClosetGnome.db.char.set) do
			GnomeEvent_AddSet(k);
		end
		locked = false;
		doUpdateRing();
	end
end

if type(OneRing) == "table" and type(OneRing.RegisterRing) == "function" then
	local name, prettyname, desc, enabled, loadable = GetAddOnInfo("ClosetGnome");
	if name and enabled then
		XSP = true;
		OneRing:RegisterRing(rname, initializeRing);
	end
end