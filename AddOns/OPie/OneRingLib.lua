-- Burning Crusade branch
if math.floor(select(4,GetBuildInfo())/10000) ~= 2 then return; end

-- Implementation note: WoW's global sin and cos take degrees rather than math.sin/cos radians.
local versionMajor, versionRev = 0, 15;
local max, min, abs, sin, cos = math.max, math.min, math.abs, sin, cos;
local OR_AddonName, OR_Rings, OR_Headers, OR_RingInitializers, OR_PendingUpdates, OR_KeyBindings
	= "OPie", {}, {}, {}, {}, setmetatable({}, {__index=function(t,k) t[k] = {}; return t[k]; end});
local OneRing = {xls={landOnlyMounts={}}, xlu={}, ext={}};
local defaultConfig, unlocked, svloaded, configInstance = {DimScreen=false, RingAtMouse=false,
	ShowPointer=true, ShowIcons=false, ShowCooldowns=false, ShowCaptions=true, MultiIndication=true,
	ClickActivation=false, IndicationOffsetX=0, IndicationOffsetY=0,
	MIDisjoint=false, MIScale0=-0.175, MIScale1=0.10, MIScale2=0.15,
	MIAlpha=false, XTPointerSpeed=0, XTScaleSpeed=0, RingScale=1}, false, false, {};
local invalidatingOptions = {ClickActivation=true, IndicationOffsetX=true, IndicationOffsetY=true, RingAtMouse=true, RingScale=true};
local waitingToSyncBindings = false;
for k, id in pairs({32768, 33809, 30480, 35513}) do OneRing.xls.landOnlyMounts[id] = true; end
local defaultProps = {__index={offset=0, mindist=40, gap=0}};
local LBFGroup;

-- Some basic utility methods
local function assert(condition, text, level, ...)
	if not condition then error(tostring(text):format(...), 1 + (level or 1)); end
	return condition;
end
local function SetAttributes(frame, ...)
	for i=1,select("#", ...), 2 do
		frame:SetAttribute(select(i, ...), select(i+1, ...));
	end
end
local function SetDimensions(frame, w, h)
	frame:SetWidth(w); frame:SetHeight(h or w);
end
local function copy(t, lib, into)
	assert(type(t) == "table" and (lib == nil or type(lib) == "table"), "Syntax: copy(t[, tLib[, into]]);", 2);
	local nt, lib = type(into) == "table" and into or {}, lib or {}; lib[t] = nt;
	if type(into) == "table" then for k, v in pairs(nt) do if t[k] == nil then nt[k] = nil; end end end
	for k, v in pairs(t) do
		if type(v) == "table" then
			nt[k] = lib[v] or copy(v, lib, nt[k]);
		else nt[k] = v; end
	end
	return nt;
end
local function print(text, ...)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(text):format(...), 0.3, 0.5, 0.8);
end
local function parseMacro(text)
  if type(text) ~= "string" then return; end
	local cl = text:match("^#show ([^\n]+)") or text:match("^#showtooltip ([^\n]+)") or text:match("/cast ([^\n]+)") or text:match("/use ([^\n]+)");
	if cl then
		cl = SecureCmdOptionParse(cl);
		if not cl then return; end
		return GetSpellInfo(cl) and "spell" or "item", cl;
	end
end
OneRing.xlu.copy, OneRing.xlu.print, OneRing.xlu.assert, OneRing.xlu.parseMacro = copy, print, assert, parseMacro;

-- Settings retrieval
local function OR_GetRingOption(ringName, option)
	local v = configInstance.RingOptions[ringName .. "#" .. option];
	if v == nil then
		v = configInstance[option];
	end
	return v;
end

-- Spawn UI elements for indication interface
local iZoomTime = 1/0.3;
local OR_IndicationFrame = CreateFrame("Frame", "OneRingIndicator", UIParent);
SetDimensions(OR_IndicationFrame, 128); OR_IndicationFrame:SetFrameStrata("FULLSCREEN");
local ORI_ConfigCache = {};
OR_IndicationFrame:SetPoint("CENTER"); OR_IndicationFrame.config = ORI_ConfigCache;

local basepath = "Interface\\AddOns\\" .. OR_AddonName .. "\\";
local OR_IndicationCircle = OR_IndicationFrame:CreateTexture(nil, "ARTWORK");
SetDimensions(OR_IndicationCircle, 64); OR_IndicationCircle:SetPoint("CENTER");
OR_IndicationCircle:SetTexture(basepath .. "gfx\\circle.tga");
OR_IndicationCircle:SetVertexColor(0x38/0xff, 0xE2/0xff, 0x29/0xff, 0.9);


local OR_IndicationPointer = OR_IndicationFrame:CreateTexture(nil, "ARTWORK");
SetDimensions(OR_IndicationPointer, 128); OR_IndicationPointer:SetPoint("CENTER");
OR_IndicationPointer:SetTexture(basepath .. "gfx\\pointer.tga");
OR_IndicationPointer:SetVertexColor(0x38/0xff, 0xE2/0xff, 0x29/0xff, 0.9);

local OR_IndicationGlow = OR_IndicationFrame:CreateTexture(nil, "BACKGROUND");
SetDimensions(OR_IndicationGlow, 128); OR_IndicationGlow:SetPoint("CENTER");
OR_IndicationGlow:SetTexture(basepath .. "gfx\\glow.tga");
OR_IndicationGlow:SetVertexColor(0x38/0xff, 0xE2/0xff, 0x29/0xff, 0.9);

local OR_LogoVersion = OR_IndicationFrame:CreateFontString("OVERLAY", nil, "GameFontHighlight");
OR_LogoVersion:SetPoint("TOP", OR_IndicationCircle, "BOTTOM", 0, -20); OR_LogoVersion:SetJustifyH("CENTER");

local OR_ScreenDim = WorldFrame:CreateTexture(nil, "OVERLAY");
OR_ScreenDim:SetAllPoints(); OR_ScreenDim:SetTexture(0,0,0); OR_ScreenDim:SetAlpha(0.25); OR_ScreenDim:Hide();

local OR_CenterIndication = CreateFrame("Button", "ORSI_CenterContainer", OR_IndicationFrame);
	SetDimensions(OR_CenterIndication, 28); OR_CenterIndication:SetPoint("CENTER");
	local OR_SpellIcon = OR_CenterIndication:CreateTexture(nil, "ARTWORK");
	OR_SpellIcon:SetAllPoints(); OR_SpellIcon:SetAlpha(0.8);
	local OR_SpellCount = OR_CenterIndication:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge");
	OR_SpellCount:SetPoint("BOTTOMRIGHT", -1, 1);

local OR_SpellCaption = OR_IndicationFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
OR_SpellCaption:SetPoint("TOP", OR_IndicationCircle, "BOTTOM", 0, -15); OR_SpellCaption:SetJustifyH("CENTER");

local OR_SpellCD = OR_IndicationFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge");
OR_SpellCD:SetJustifyH("CENTER"); OR_SpellCD:SetJustifyV("CENTER"); OR_SpellCD:SetPoint("CENTER", OR_IndicationCircle);

local ORMI_Parent = CreateFrame("Frame", nil, OR_IndicationFrame);
	SetDimensions(ORMI_Parent, 256); ORMI_Parent:SetPoint("CENTER");
local function ORMI_SetAngle(self, angle, radius)
	self:SetPoint("CENTER", radius*cos(90+angle), radius*sin(90+angle));
end
local function ORMI_SetScale(self, scale)
	local oldScale, limit = self:GetScale(), 2^(ORI_ConfigCache.XTScaleSpeed)/GetFramerate();
	self:SetScaleForce(oldScale + math.min(limit, math.max(-limit, scale-oldScale)));
end
local OR_MultiIndicators = setmetatable({}, {
	__index=function(t, k)
		local e = CreateFrame("CheckButton", "ORMI_Container" .. k, ORMI_Parent);
		e.icon, e.text, e.count, t[k] = e:CreateTexture(nil, "ARTWORK"),
			e:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge"),
			e:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge"), e;
		e.SetAngle, e.SetScale, e.SetScaleForce = ORMI_SetAngle, ORMI_SetScale, e.SetScale;
		SetDimensions(e, 48); e.icon:SetAllPoints();
		e.text:SetPoint("CENTER");
		e:EnableMouse(false);
		if LBFGroup then
			e:SetDisabledTexture("");
			e:SetHighlightTexture("");
			e:SetCheckedTexture("");
			pcall(LBFGroup.AddButton, LBFGroup, e, {Icon=e.icon, Count=e.count});
		else
			e.icon:SetBlendMode("ADD");
			e.count:SetPoint("BOTTOMRIGHT", -4, 4);
		end
		return e;
	end
}); -- end (collapse block)

-- Indication ring updates (pretty shiny things) [for collapse block]
local r2, r42, realUpdate, colorTable = math.sqrt(0.5^2+0.5^2), math.sqrt(42), true, {[4]=0.9};
local function ORI_SetViewAngle(ofs, angle)
	OR_IndicationCircle:SetTexCoord(
		0.5+r2*cos(ofs+135), 0.5+r2*sin(ofs+135),
		0.5+r2*cos(ofs-135), 0.5+r2*sin(ofs-135),
		0.5+r2*cos(ofs+45), 0.5+r2*sin(ofs+45),
		0.5+r2*cos(ofs-45), 0.5+r2*sin(ofs-45)
	);
	OR_IndicationPointer:SetTexCoord(
		0.5+r2*cos(angle+135), 0.5+r2*sin(angle+135),
		0.5+r2*cos(angle-135), 0.5+r2*sin(angle-135),
		0.5+r2*cos(angle+45), 0.5+r2*sin(angle+45),
		0.5+r2*cos(angle-45), 0.5+r2*sin(angle-45)
	);
	OR_IndicationGlow:SetTexCoord(
		0.5+r2*cos(ofs+135), 0.5+r2*sin(ofs+135),
		0.5+r2*cos(ofs-135), 0.5+r2*sin(ofs-135),
		0.5+r2*cos(ofs+45), 0.5+r2*sin(ofs+45),
		0.5+r2*cos(ofs-45), 0.5+r2*sin(ofs-45)
	);
end
local function ORI_GetActionInfoEntry(e)
	if type(e) ~= "table" then return true, 0, nil, nil; end
	if type(e.actionHint) == "function" then return e.actionHint(); end

	local caption, icon, usable, cooldown, cd, t, n, enabled = e.caption, e.icon;
	if type(caption) == "function" then caption = e:caption(); end
	if type(icon) == "function" then icon = e:icon(); end

	-- Attempt to determine what this button does.
	local btype, bcontent, oicon, ocaption = e[1], e[2], icon, caption;
	if btype == "macrotext" then btype, bcontent = parseMacro(bcontent); end
	if btype == "spell" or btype == "item" then t, n = btype, bcontent;
	elseif btype == "macro" then
		t, n = "spell", GetMacroSpell(bcontent);
		if not n then	t, n = "item", GetMacroItem(bcontent); end
		if not n then
			local name, icon = GetMacroInfo(bcontent);
			return true, 0, icon, name;
		end
	end
	if not n then return true, 0, oicon or icon or nil, ocaption or caption, 0; end -- Failed, decry own inadequacy.

	-- Filter that pesky item identifier, unless it came from a native macro.
	if t == "item" and btype ~= "macro" then n = SecureCmdItemParse(n); caption = n and GetItemInfo(n); end

	-- Now determine whether the action is ready
	if t == "spell" then
		usable, icon, cooldown, cd, enabled = IsUsableSpell(n), GetSpellTexture(n), GetSpellCooldown(n);
	elseif t == "item" then
		usable, icon, cooldown, cd, enabled = IsUsableItem(n), GetItemIcon(n), GetItemCooldown(n);
	end
	if cooldown and cooldown ~= 0 then cooldown = cooldown + cd - GetTime(); end
	enabled = enabled == 0;
	usable = not not (usable and (cooldown == nil or cooldown == 0) or enabled);

	-- And the number of times this can be used
	local count = 0;
	if t == "item" and IsConsumableItem(n) then count = GetItemCount(n);
	elseif t == "spell" then count = GetSpellCount(n);
	end

	return usable, enabled and 0 or cooldown, oicon or icon, ocaption or caption or n or "", count or 0, t, n;
end
local function ORI_Cooldown(cd)
	if cd == 0 or not cd then return ""; end
	local f, n, unit = cd > 10 and "%d%s" or "%.1f", cd, "";
	if n > 86400 then n, unit = ceil(n/86400), "d";
	elseif n > 3600 then n, unit = ceil(n/3600), "h";
	elseif n > 60 then n, unit = ceil(n/60), "m";
	elseif n > 10 then n = ceil(n); end
	return f, n, unit;
end
local function ORI_Update(self, elapsed)
	local time, config = GetTime(), self.config;
	if self.effect == "zoomout" then
		local delta = max(0, (self.eend-time)*iZoomTime);
		if delta == 0 then return self:Hide(), OR_ScreenDim:Hide(); end
		self:SetScale(config.RingScale*delta); self:SetAlpha(delta);
		OR_ScreenDim:SetAlpha(delta*0.20);
		return;
	elseif self.effect == "zoomin" then
		local delta = max(0, (self.eend-time)*iZoomTime);
		if delta == 0 then self.effect = nil; end
		if delta < 1 then	self:SetScale(config.RingScale/max(0.2,cos(65*delta))); self:SetAlpha(1-delta); end
		OR_ScreenDim:SetAlpha(0.20-delta*0.20);
	end
	if not config.ShowPointer then SetCursor("HIDE"); end

	local ring = self.ring;
	local scale, l, b, w, h = ring:GetEffectiveScale(), ring:GetRect();
	if not (l and b and w and h) then return; end
	local maxdist, x, y = max(w,h) / 2, GetCursorPosition();
	local dx, dy = (x / scale) - (l + w / 2), (y / scale) - (b + h / 2);

	-- Calculate pointer location
	local angle = (math.deg(math.atan2(dx, dy)) -180) % 360;
	local oangle = self.angle or angle;
	local adiff = math.min((angle-oangle) % 360, (oangle-angle) % 360);
	local arate = 180;
	if adiff > 60 then
		arate = 420 + 120*sin(min(90, adiff-60));
	elseif adiff > 15 then
		arate = 180 + 240*sin(min(90, max((adiff-15)*2, 0)));
	else
		arate = 20 + 160*sin(min(90, adiff*6));
	end
	local abound, arotDirection = arate/GetFramerate(), ((oangle - angle) % 360 < (angle - oangle) % 360) and -1 or 1;
	abound = abound * 2^config.XTPointerSpeed;
	if adiff < abound then
		self.angle = angle;
	else
		self.angle = (oangle + arotDirection * abound) % 360;
	end
	ORI_SetViewAngle(time*180, self.angle);

	-- What is selected?
	local props = OR_Rings[self.ringID];
	local si, osi = SecurePieButton_GetIndex(dx, dy, maxdist, #props, props.mindist, props.gap, props.offset), self.oldValue;
	local usable, cd, icon, caption, count = nil, false;
	if si then
		usable, cd, icon, caption, count = ORI_GetActionInfoEntry(props[si]);
	end
	if si ~= osi then
		if props[si] then
			colorTable[1], colorTable[2], colorTable[3] = props[si].r or 0, props[si].g or 0, props[si].b or 0;
			OR_IndicationPointer:SetVertexColor(unpack(colorTable));
			OR_IndicationCircle:SetVertexColor(unpack(colorTable));
			OR_IndicationGlow:SetVertexColor(unpack(colorTable, 1, 3));
			OR_SpellCaption:SetTextColor(unpack(colorTable,1,3));
			OR_SpellCD:SetTextColor(unpack(colorTable));
		else
			OR_IndicationPointer:SetVertexColor(1,1,1,0.1);
			OR_IndicationCircle:SetVertexColor(1,1,1,0.3);
			OR_IndicationGlow:SetVertexColor(0.75,0.75,0.75);
		end
		self.oldValue = si;
	end
	if icon then
		OR_SpellIcon:SetTexture(icon);
		if not LBGroup then
			OR_SpellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
		end
	end
	OR_SpellCD:SetFormattedText(ORI_Cooldown(config.ShowCooldowns and cd or 0));
	OR_CenterIndication[icon and config.ShowIcons and (not config.MultiIndication) and "Show" or "Hide"](OR_CenterIndication);
	OR_SpellCaption:SetText(config.ShowCaptions and caption or "");
	OR_SpellCount:SetText(icon and config.ShowIcons and (not config.MultiIndication) and count and count > 0 and count or "");

	-- Glow animation block
	usable = usable == true; -- nil makes binary logic cry
	local gAnim, gEnd, oIG = self.gAnim, self.gEnd, self.oldIsGlowing;
	if usable ~= oIG then
		gAnim = usable and "in" or "out";
		if gEnd and gEnd > time then
			gEnd = time+0.5-(gEnd-time);
		else
			gEnd = time+0.5;
		end
		self.oldIsGlowing, self.gAnim, self.gEnd = usable, gAnim, gEnd;
		OR_IndicationGlow:Show();
	end
	if not gAnim then
	elseif gEnd <= time then
		self.gAnim, self.gEnd = nil, nil;
		OR_IndicationGlow[gAnim == "in" and "Show" or "Hide"](OR_IndicationGlow);
		OR_IndicationGlow:SetAlpha(sin(150));
	else
		local pg, base, shift = 1-(gEnd-time)/0.5,
			gAnim == "out" and 150 or 180,
			gAnim == "out" and 30 or -150;
		OR_IndicationGlow:SetAlpha(sin(base+shift*pg));
	end

	-- Multiple indication
	if config.MultiIndication then
		local cmState, mut = (IsShiftKeyDown() and 1 or 0) + (IsControlKeyDown() and 2 or 0) + (IsAltKeyDown() and 4 or 0), (self.schedMultiUpdate or 0);
		local astep = 360/#props;
		if self.omState ~= cmState or mut >= 0  then
			self.omState, self.schedMultiUpdate = cmState, -0.05;
			for i=1,#props do
				local usable, cd, icon, caption, count = ORI_GetActionInfoEntry(props[i]);
				OR_MultiIndicators[i].icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark");
				OR_MultiIndicators[i].text:SetFormattedText(ORI_Cooldown(config.ShowCooldowns and cd or 0));
				OR_MultiIndicators[i].count:SetText(count and count > 0 and count or "");
				SetDesaturation(OR_MultiIndicators[i].icon, (cd or 0) > 0 and 1 or nil);
				OR_MultiIndicators[i][(cd or 0) > 0 and "Disable" or "Enable"](OR_MultiIndicators[i]);
			end
		else
			self.schedMultiUpdate = mut + elapsed;
		end

		local cangle = config.MIDisjoint and ((angle - 180) % 360) or ((self.angle - 180) % 360);
		cangle = (cangle - props.offset) % 360;
		for i=1,#props do
			local adiff = math.min((astep*(i-1)-cangle) % 360, (cangle-astep*(i-1)) % 360);
			if config.MIAlpha then
				local sdiff = adiff / 360 * #props;
				local a = 0.45*cos(math.min(sdiff*30,90))+0.25*cos(math.min(sdiff*90, 90))+0.15;
				if i == si then a = 1; end
				OR_MultiIndicators[i]:SetAlpha(si and a or 0.5);
			elseif not si then
				OR_MultiIndicators[i]:SetScale(max(0.1, 1+config.MIScale0));
			else
				if adiff <= astep / 2 then
					local toprange = math.max(10, astep / 6);
					local range, delta = astep / 2 - toprange, adiff - toprange;
					OR_MultiIndicators[i]:SetScale(max(0.1, 1 + config.MIScale1 + config.MIScale2*cos(max(0, delta) * 90 / range)));
				elseif adiff <= astep * 1.25 then
					local range, delta = astep * 1.25 - astep / 2, adiff - astep / 2;
					OR_MultiIndicators[i]:SetScale(max(0.1, 1 + config.MIScale1*cos(delta * 90 / range)));
				else
					OR_MultiIndicators[i]:SetScale(1);
				end
			end
		end
		if config.MIAlpha then
			ORMI_Parent:SetAlpha(((2-5*elapsed)*ORMI_Parent:GetAlpha()+5*elapsed*(props[si] and 1 or 0.45))/2);
		end
		if si ~= osi then
			if osi then OR_MultiIndicators[osi]:UnlockHighlight(); end
			if si then OR_MultiIndicators[si]:LockHighlight(); end
		end
	end
end
local function ORI_FinishSplash(self)
	self:SetScript("OnUpdate", ORI_Update); self:Hide();
	OR_LogoVersion:Hide(); realUpdate = false;
	local LBF = LibStub and LibStub("LibButtonFacade",true);
	if LBF then
		local cfg = configInstance.LBFConfig;
		LBFGroup = LBF:Group(OR_AddonName);
		LBFGroup:AddButton(OR_CenterIndication, {Icon=OR_SpellIcon, Count=OR_SpellCount});
		if type(cfg) == "table" then
			LBFGroup.Colors = cfg.Colors or LBFGroup.Colors;
			LBFGroup:Skin(cfg.SkinID, cfg.Gloss, cfg.Backdrop);
		end
	end
end
local function ORI_Splash(self, elapsed)
	local frames, expire = self.frames, self.expire;
	if expire then
		local tl = max(0, expire - GetTime());
		if tl == 0 then
			ORI_FinishSplash(self);
		else
			local weighed = (tl > 0.55) and (tl/0.55*0.5) or (tl < 0.45 and (tl/0.45*0.5) or 0.5);
			ORI_SetViewAngle(GetTime()*180, 180 - 180*tl);
			self:SetAlpha(0.7*sin(180*weighed));
		end
	elseif frames == 84 then
		self.frames, self.expire = nil, GetTime()+1;
	elseif not frames then
		self.frames = 1;
		self:SetAlpha(0);
		OR_LogoVersion:SetText(GetAddOnMetadata(OR_AddonName, "X-Version-Name") or "");
	else
		self.frames = frames+ 1;
	end
end
local ORI_RingRadius = setmetatable({}, {
	__index=function(t,n)
		local radius, sideLength, abs, astep = 85, 48, math.abs, 360 / n;
		repeat
			local ox, oy, clear = radius, 0, true;
			for i=1,n-1 do
				local nx, ny = radius*cos(i*astep), radius*sin(i*astep);
				if abs(ox - nx) < sideLength and abs(oy - ny) < sideLength then
					clear, radius = false, radius + 10;
					break;
				end
				ox, oy = nx, ny;
			end
		until clear;
		t[n] = radius;
		return radius;
	end
});
local ORI_ActiveRing;
local function ORI_ShowRing(ring)
	local frame, props = OR_IndicationFrame, OR_Rings[ring.ringName];
	ORI_ActiveRing = ring;
	if realUpdate then
		-- Early trigger: splash animation is still active, get rid of it.
		ORI_FinishSplash(frame);
	end
	if type(props.preClick) == "function" then
		-- preClick handler may cause changes to the ring.
		local ok, err = pcall(props.preClick, ring.ringID);
		if not ok then EC_Error("OPie", tostring(ring.ringName) .. ".preClick", err:gsub("Interface\\AddOns\\", "")); end
		props = OR_Rings[ring.ringName];
	end

	-- Copy ring configuration to indication frame.
	local ringName = ring.ringName;
	frame.ring, frame.ringID = ring, ringName;
	for k, v in pairs(defaultConfig) do
		frame.config[k] = configInstance.RingOptions[ringName .. "#" .. k];
	end

	-- Zoom in to the ring's indication option
	frame.effect, frame.eend = "zoomin", GetTime() + 1/iZoomTime;

	-- Move pointer to match cursor position, reset glow
	local scale, l, b, w, h = ring:GetEffectiveScale(), ring:GetRect();
	local maxdist, x, y = max(w or 5000, h or 5000) / 2, GetCursorPosition();
	local dx, dy = (x / scale) - ((l or 0) + (w or 0) / 2), (y / scale) - ((b or 0) + (h or 0) / 2);
	frame.angle, frame.oldValue = (math.deg(math.atan2(dx, dy)) -180) % 360, -1; -- force glow update
	frame.oldShown, frame.oldIsGlowing, frame.gAnim = nil, true, nil;
	OR_IndicationGlow:Show(); OR_IndicationGlow:SetAlpha(sin(150));

	-- Show/Hide multiple indication icons as required
	frame.schedMultiUpdate = 1;
	local useMultipleIndication, astep = frame.config.MultiIndication, -360/#props;
	local radius = ORI_RingRadius[#props];
	for i=1,(useMultipleIndication and #props or 0) do
		local indic = OR_MultiIndicators[i];
		indic.text:SetText("");
		indic.text:SetTextColor(props[i].r or 1, props[i].g or 1, props[i].b or 1);
		indic:ClearAllPoints();
		indic:SetAngle((i - 1) * astep - props.offset, radius);
		indic:SetScaleForce(1);
		indic:Show();
	end
	for i=(useMultipleIndication and (#props+1) or 1),#OR_MultiIndicators do
		OR_MultiIndicators[i]:Hide();
	end
	for i=1,#OR_MultiIndicators do OR_MultiIndicators[i]:SetAlpha(1); end
	ORMI_Parent:SetAlpha(1);

	-- Show the indication frame
	frame:ClearAllPoints(); frame:SetPoint("CENTER", ring); frame:Show();
	if frame.config.DimScreen then OR_ScreenDim:Show(); end
	pcall(MouselookStop);
end
local function ORI_HideRing(ring)
	if ORI_ActiveRing == ring then
		OR_IndicationFrame.effect, OR_IndicationFrame.eend = "zoomout", GetTime() + 1/iZoomTime;
		SetCursor(nil);
	end
end
OR_IndicationFrame:SetScript("OnUpdate", ORI_Splash);
-- end collapse block

-- Ring creation and management core
local OR_ClickFuncHandlers = setmetatable({}, {__mode="v"});
local OR_RadioHeader, OR_RadioCount = CreateFrame("Frame", nil, UIParent, "SecureStateHeaderTemplate"), 0;
OR_RadioHeader:SetPoint("CENTER");
local btnAbortRing = CreateFrame("Button", "ORTB__Abort", nil, "SecureActionButtonTemplate");
SetAttributes(btnAbortRing, "newstate","0", "bindings-shown","*ESCAPE;BUTTON2");
btnAbortRing:RegisterForClicks("AnyUp", "AnyDown");
SetAttributes(OR_RadioHeader, "statebindings","0:none;*:shown", "addchild",btnAbortRing);

local function OR_HandleClick(btn)
	local pt = OR_ClickFuncHandlers[btn];
	if pt and pt[1] == "func" and type(pt[2]) == "function" then
		pt[2](pt[3] == pt and "Don't do that" or pt[3]);
	end
end
local function OR_CreateSubButton(h, k)
	h[k] = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate");
	h.trigger:SetAttribute("pie" .. k .. "child", h[k]);
	return h[k];
end
local function OR_CreateRingStructure(t, name)
	local header = CreateFrame("Frame", nil, UIParent, "SecureStateHeaderTemplate");
	SetAttributes(header, "raise","true", "headofspoint","CENTER");
	OR_RadioCount = OR_RadioCount + 1; local r = OR_RadioCount;
	SetAttributes(header, "exportstate","radio"..r, "statemap-parent-"..r,"1", "statemap-parent","0");
	SetAttributes(OR_RadioHeader, "statemap-radio"..r.."-1",r, "statemap-radio"..r,r..":0", "addchild",header);
	local button = CreateFrame("Button", "ORTB__" .. name, header, "SecurePieButtonTemplate");
	button:SetPoint("CENTER"); SetDimensions(button, max(3360,GetScreenWidth()*2), max(2100,GetScreenHeight()*2)); button:SetFrameStrata("HIGH");
	button:RegisterForClicks("AnyUp", "AnyDown");
	SetAttributes(button, "showstates",1, "newstate","0", "*newstate-open","1");
	SetAttributes(header, "addchild",button, "state",0);
	button:SetScript("OnShow", ORI_ShowRing); button:SetScript("OnHide", ORI_HideRing);
	button.ringName = name;
	header.buttons = setmetatable({trigger=button}, {__index=OR_CreateSubButton});
	t[name] = header;
	return header;
end
local function OR_SetActivationMethod(header, trigger, useClicks)
	SetAttributes(trigger, "*statedownbutton-use",useClicks and "0:open;1:close" or "0:open",
		"*statedownbutton1",useClicks and "1:use" or nil,
		"*statebutton-use",useClicks and "1:open" or nil,
		"statebutton",useClicks and "close" or nil);
end
setmetatable(OR_Headers, {__index=OR_CreateRingStructure});
local function OR_SetHotkey(name, hotkey)
	ClearOverrideBindings(OR_Headers[name]);
	if type(hotkey) == "string" then
		SetOverrideBindingClick(OR_Headers[name], true, hotkey, OR_Headers[name].buttons.trigger:GetName(), "use");
	end
end
local function OR_SyncRing(name, props)
	if InCombatLockdown() then
		OR_PendingUpdates[name] = props;
		return false, "combat";
	end

	-- Keep a local copy of the properties table, lest someone changes it while we're not looking
	local op, ringID = OR_Rings[name], OR_Rings[name] and OR_Rings[name].ringID or (#OR_Rings+1);
	OR_Rings[name] = op == props and OR_Rings[name] or copy(props, nil, OR_Rings[name]);
	OR_Rings[name].ringID, OR_Rings[ringID] = ringID, name;
	props = setmetatable(OR_Rings[name], defaultProps); -- use our copy from here on forward

	-- Get (or create) a header, set ring-wide options from properties and settings
	local header = OR_Headers[name];
	local button = header.buttons.trigger;
	header:SetAttribute("headofsrelpoint", OR_GetRingOption(name, "RingAtMouse") and "cursor" or nil);
	OR_SetActivationMethod(header, button, OR_GetRingOption(name, "ClickActivation"));
	local ofsx, ofsy = OR_GetRingOption(name, "IndicationOffsetX"), OR_GetRingOption(name, "IndicationOffsetY");
	SetAttributes(header, "headofsx","1:"..ofsx, "headofsy","1:"..-ofsy);
	SetAttributes(button, "piecount",#props, "piemindist",props.mindist,
												"pieoffset",props.offset, "piegap",props.gap);
	button:SetScale(OR_GetRingOption(name, "RingScale"));

	-- Clear previous hotkey ownership, clean up hotkey tables
	for k, v in pairs(OR_KeyBindings) do
		for k2, v2 in pairs(v) do
			if v2 == name then v[k2] = nil; end
		end
		if not next(v) then
			OR_KeyBindings[k] = nil;
		end
	end

	-- Set hotkey, if applicable.
	local hotkey, override = configInstance.Bindings[name], true; -- false: disabled
	if hotkey == nil then hotkey, override = props.hotkey, false; end
	if hotkey and GetBindingAction(hotkey) ~= "" and not override then hotkey = nil; end
	if hotkey then
		local owner = OR_KeyBindings[hotkey];
		for i=1, 2 do
			local wanted = bit.band(i, props.hotkeyState or 3) ~= 0;
			if wanted and (owner[i] == nil or (override and not configInstance.Bindings[owner[i]])) then
				owner[i] = name;
			end
		end
	end
	if hotkey and OR_KeyBindings[hotkey][1] ~= name then hotkey = nil; end
	OR_SetHotkey(name, hotkey);

	-- Update child buttons (buttons table creates elements as needed)
	for i=1,#props do
		local btn, btype = header.buttons[i], props[i][1];
		if btype == "macro" or btype == "macrotext" then
			SetAttributes(btn, "*type-use","macro", btype,props[i][2]);
		elseif btype == "item" or btype == "spell" then
			SetAttributes(btn, "*type-use",btype, btype,props[i][2], "target",props[i][3] or "player");
		elseif btype == "func" then
			OR_ClickFuncHandlers[btn] = props[i];
			SetAttributes(btn, "*type-use", "ORLFunc");
			btn.ORLFunc = OR_HandleClick;
		end
		local f = props[i].preClick;
		btn:SetScript("PreClick", type(f) == "function" and function(self) f(ringID, i) end or nil);
	end

	return ringID, button;
end

-- Responding to WoW Events
local function OR_SyncProps()
	if not InCombatLockdown() then
		for k, props in pairs(OR_PendingUpdates) do
			OR_SyncRing(k, props);
			OR_PendingUpdates[k] = nil;
		end
	end
end
local function OR_CheckBindings()
	if InCombatLockdown() then waitingToSyncBindings = true; return; end
	waitingToSyncBindings = false;
	local updated = false;
	for k, v in pairs(OR_Rings) do
		local key = v.hotkey;
		if configInstance.Bindings[k] == nil and type(key) == "string" then
			local isConflict, isActive = GetBindingAction(key) ~= "", OR_KeyBindings[key] and (OR_KeyBindings[key][1] == k or OR_KeyBindings[key][2] == k);
			if isConflict == isActive then OR_PendingUpdates[k], updated = v, true; end
		end
	end
	if updated then OR_SyncProps(); end
end
local function OR_SwitchCombatState(event)
	if event == "PLAYER_REGEN_ENABLED" then
		OR_SyncProps();
	end
	local flag = (event == "PLAYER_REGEN_ENABLED") and 1 or 2;
	for k, v in pairs(OR_Rings) do
		if type(v) == "table" and bit.band(v.hotkeyState or 3, flag) == 0 then
			-- This one is needs a clear, so we just do that regardless.
			OR_SetHotkey(k, nil);
		elseif v.hotkeyState and v.hotkeyState ~= 3 then
			-- This one wants a bind, so let's see if it owns the key first.
			local key = OneRing:GetRingBinding(v.ringID);
			if key and OR_KeyBindings[key][flag] == k then
				OR_SetHotkey(k, key);
			end
		end
		if waitingToSyncBindings then
			OR_CheckBindings();
		end
	end
end
local function OR_InitConfigState()
	-- Get saved vars, set defaults as defaults.
	setmetatable(configInstance, {__index=defaultConfig});
	if type(OneRing_Config) == "table" then
		for k, v in pairs(OneRing_Config) do
			configInstance[k] = v;
		end
	end

	-- And a few special tables.
	if type(configInstance.SavedRingData) ~= "table" then configInstance.SavedRingData = {}; end
	if type(configInstance.Bindings) ~= "table" then configInstance.Bindings = {}; end
	if type(configInstance.RingOptions) ~= "table" then configInstance.RingOptions = {}; end
	setmetatable(configInstance.SavedRingData, {__index=function(t,k) t[k] = {}; return t[k]; end});
	setmetatable(ORI_ConfigCache, {__index=function(t,k) return configInstance[k]; end});
	OneRing_Config = copy(configInstance); -- Keeps the real table internal.
end
local function OR_LibState(event, addon)
	if event == "ADDON_LOADED" and addon == OR_AddonName then
		OR_InitConfigState();
		unlocked = true;
	elseif not unlocked then
		return;
	end
	for k, v in pairs(OR_RingInitializers) do
		local ok, f = pcall(v, event, configInstance.SavedRingData[k]);
		if not ok then EC_Error("OPie", k, f:gsub("Interface\\AddOns\\"..OR_AddonName.."\\", "")); end
	end
	if event == "PLAYER_LOGIN" then
		svloaded = true;
	elseif event == "PLAYER_LOGOUT" and svloaded then
		for k, v in pairs(configInstance.SavedRingData) do
			if next(v) == nil then
				configInstance.SavedRingData[k] = nil;
			end
		end
		if LBFGroup then
			configInstance.LBFConfig = {};
			local t = configInstance.LBFConfig;
			for k, v in pairs({"SkinID","Gloss","Backdrop","Colors"}) do
				t[v] = LBFGroup[v];
			end
		end
		for k, v in pairs(configInstance) do
			if v == defaultConfig[k] then
				configInstance[k] = nil;
			end
		end
		if configInstance.RingOptions and not next(configInstance.RingOptions) then configInstance.RingOptions = nil; end
		OneRing_Config = configInstance;
	end
	return "remove";
end

-- Public API
function OneRing:RegisterRing(name, init)
	assert(type(init) == "function" and type(name) == "string", "Syntax: OneRing:RegisterRing(\"name\", initFunc)", 2);
	assert(OR_RingInitializers[name] == nil, "Duplicate initializer for ring %q", 2, name);
	OR_RingInitializers[name] = init;
end
function OneRing:CreateRing(name, props)
	assert(type(name) == "string" and type(props) == "table", "Syntax: header, button = OneRing:CreateRing(\"name\", propsTable)", 2);
	assert(unlocked, "Locked; rings can only be initialized after settings have been loaded", 2);
	assert(OR_Rings[name] == nil, "Ring name %q is already created.", 2, name);
	return OR_SyncRing(name, props);
end
function OneRing:GetNumRings()
	return #OR_Rings;
end
function OneRing:GetRingData(id)
	assert(type(id) == "number", "Syntax: propsTable = OneRing:GetRingData(index);", 2);
	local key = assert(OR_Rings[id], "Ring index out of bounds", 2);
	local ret = copy(OR_PendingUpdates[key] or OR_Rings[key]);
	ret.codename = key;
	return ret;
end
function OneRing:GetRingInfo(id)
	assert(type(id) == "number", "Syntax: name, key, numEntries = OneRing:GetRingData(index);", 2);
	local key = assert(OR_Rings[id], "Ring index out of bounds", 2);
	local ret = OR_PendingUpdates[key] or OR_Rings[key];
	return ret.name, key, #ret;
end
function OneRing:SetRingData(id, props)
	assert(type(id) == "number" and type(props) == "table", "Syntax: OneRing:SetRingData(index, propsTable);", 2);
	local key = assert(OR_Rings[id], "Ring index out of range.", 2);
	return OR_SyncRing(key, props);
end
function OneRing:GetVersion()
	return GetAddOnMetadata(OR_AddonName, "X-Version-Name"), versionMajor, versionRev;
end
function OneRing:GetOption(option, ringID)
	assert(type(option) == "string" and (ringID == nil or type(ringID) == "number"), "Syntax: value = OneRing:GetOption(\"option\"[, ringID]);", 2);
	assert(defaultConfig[option] ~= nil, "Option %q is unknown.", 2, option);
	local key = tostring(OR_Rings[ringID]) .. "#" .. option;
	if ringID and configInstance.RingOptions[key] ~= nil then
		return configInstance.RingOptions[key], true;
	end
	return configInstance[option], ringID == nil and rawget(configInstance, option) == nil;
end
function OneRing:SetOption(option, ...)
	local id, value = ...;
	if select("#", ...) == 1 then id, value = nil, ...; end
	assert(type(option) == "string" and (id == nil or type(id) == "number"), "Syntax: OneRing:SetOption(\"option\"[, id], value or nil);", 2);
	assert(defaultConfig[option] ~= nil, "Option %q is unknown.", 2, option);
	assert(value == nil or type(defaultConfig[option]) == type(value), "Type mismatch: %q expected to be a %s.", 2, option, type(defaultConfig[option]));
	local rkey = assert(id == nil or OR_Rings[id], "Ring index out of bounds.", 2);
	if id == nil then
		configInstance[option] = value;
		if invalidatingOptions[option] then
			for k,v in ipairs(OR_Rings) do
				OR_PendingUpdates[v] = OR_PendingUpdates[v] or OR_Rings[v];
			end
			OR_SyncProps();
		end
	else
		configInstance.RingOptions[rkey .. "#" .. option] = value;
		if invalidatingOptions[option] then
			OR_PendingUpdates[OR_Rings[id]] = OR_PendingUpdates[OR_Rings[id]] or OR_Rings[OR_Rings[id]];
			OR_SyncProps();
		end
	end
end
function OneRing:ClearRingOptions(id)
	assert(type(id) == "number", "Syntax: OneRing:ClearRingOptions(id);", 2);
	local key = assert(OR_Rings[id], "Ring index out of bounds.", 2);
	for k, v in pairs(defaultConfig) do
		configInstance.RingOptions[key .. "#" .. k] = nil;
	end
end
function OneRing:SetRingBinding(id, bind)
	assert(type(id) == "number" and (type(bind) == "string" or bind == false or bind == nil), "Syntax: OneRing:SetRingBinding(id, \"binding\" or false or nil);", 2);
	local key = assert(OR_Rings[id], "Ring index out of range", 2);
	if bind == configInstance.Bindings[key] then return; end
	local obind = OneRing:GetRingBinding(id);
	if obind then OR_KeyBindings[obind] = nil; end
	for i=1,#OR_Rings do
		local ikey, cbind, over = OR_Rings[i], OneRing:GetRingBinding(i);
		if cbind == bind or cbind == obind then
			OR_PendingUpdates[ikey] = OR_Rings[ikey];
			if over and cbind == bind and cbind then
				-- A ring already has an override binding for this key. Get rid of it.
				configInstance.Bindings[ikey] = nil;
			end
		end
	end
	configInstance.Bindings[key], OR_PendingUpdates[key] = bind, OR_Rings[key];
	if not InCombatLockdown() then OR_SyncProps(); end
end
function OneRing:GetRingBinding(id)
	assert(type(id) == "number", "Syntax: binding, override = OneRing:GetRingBinding(id);", 2);
	local rkey = assert(OR_Rings[id], "Ring index out of range", 2);
	local key, over, active = configInstance.Bindings[rkey], true, false;
	if key == nil then key, over = OR_Rings[rkey].hotkey, false; end
	if key then active = OR_KeyBindings[key][1] == rkey or OR_KeyBindings[key][2] == rkey; end
	return key, over, active;
end
function OneRing:ResetOptions(includePerRing)
	assert(type(includePerRing) == "boolean" or includePerRing == nil, "Syntax: OneRing:ResetOptions([includePerRing])", 2);
	for k in pairs(defaultConfig) do
		configInstance[k] = nil;
	end
	if includePerRing then
		for k in pairs(configInstance.RingOptions) do
			configInstance.RingOptions[k] = nil;
		end
	end
	for k,v in ipairs(OR_Rings) do
		OR_PendingUpdates[v] = OR_PendingUpdates[v] or OR_Rings[v];
	end
	OR_SyncProps();
end

-- Localization helper functions
function OneRing.xls:FindAbility(tex)
	assert(type(tex) == "string", "Usage: OneRing.xls:FindAbility(\"iconTexture\");", 2);
	tex = tex .. "$";
	local i, sn, sicon, foundSpellName = 2, GetSpellName(1, BOOKTYPE_SPELL), GetSpellTexture(1, BOOKTYPE_SPELL), nil;
	while sn ~= nil do
		if sicon:match(tex) then foundSpellName = sn; end
		i, sn, sicon = i + 1, GetSpellName(i, BOOKTYPE_SPELL), GetSpellTexture(i, BOOKTYPE_SPELL);
	end
	return foundSpellName;
end
function OneRing.xls:FindMount(landOnly)
	assert(type(landOnly) == "boolean", "Usage: OneRing.xls:FindMount(isLandMount);", 2);
	local winItem, winLevel = nil, -1;
	for i=0, NUM_BAG_SLOTS do
		for j=1, GetContainerNumSlots(i) do
			local link = GetContainerItemLink(i, j);
			if link then
				local id = tonumber(link:match("item:(%d+)"));
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(link);
				if (GetItemIcon(id):match("[Mm]ount") or self.landOnlyMounts[id]) and GetItemSpell(link) and itemEquipLoc == "" and itemCount == 1 and
					 itemMinLevel >= 40 and (itemLevel <= 60 or self.landOnlyMounts[id] or false) == landOnly and itemLevel > winLevel then
					winItem, winLevel = itemName, itemLevel;
				end
			end
		end
	end
	return winItem;
end
function OneRing.xls:FindBuff(tex)
	assert(type(tex) == "string", "Usage: OneRing.xls:FindBuff(\"iconTexture\");", 2);
	local i, tl, b, _, t = 2, #tex, UnitBuff("player",1);
	while b do
		if t:sub(-tl) == tex then return true; end
		i, b, _, t = i+1, UnitBuff("player", i);
	end
	return false;
end

EC_Register("ADDON_LOADED", "ORL.State", OR_LibState);
EC_Register("PLAYER_LOGIN", "ORL.State", OR_LibState);
EC_Register("PLAYER_LOGOUT", "ORL.State", OR_LibState);
EC_Register("PLAYER_REGEN_ENABLED", "ORL.OutOfCombat", OR_SwitchCombatState);
EC_Register("PLAYER_REGEN_DISABLED", "ORL.IntoCombat", OR_SwitchCombatState);
EC_Register("UPDATE_BINDINGS", "ORL.Bindings", OR_CheckBindings);

_G.OneRingLib = OneRing;