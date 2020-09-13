local h, Log, csession, cnID = CreateFrame("FRAME"), {}, {}, 1;
local assert, copy = OneRingLib.xlu.assert, OneRingLib.xlu.copy;
local doRestore = false;

-- UI
local frame = CreateFrame("Frame", nil, UIParent);
frame:SetWidth(400); frame:SetHeight(300); frame:SetPoint("CENTER"); frame:Hide();
frame:SetBackdrop(GameTooltip:GetBackdrop());
frame:SetBackdropBorderColor(1,0,0, 0.75);
frame:SetBackdropColor(0,0,0, 0.75);
local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
label:SetPoint("TOPLEFT", 15,-15); label:SetText("Oops!");
local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2); desc:SetJustifyH("LEFT"); desc:SetWidth(370);
desc:SetText("Looks like OPie lost your custom rings. Help fix this bug by reporting the error; submit the text below to\n|cff00a0ffhttp://go-hero.net/opie/feedback");
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
close:SetPoint("TOPRIGHT");
local dismiss = CreateFrame("CheckButton", "OPieOopsDismiss", frame, "UICheckButtonTemplate");
dismiss:SetPoint("BOTTOMLEFT", 15, 25); OPieOopsDismissText:SetText("Do not show this report again.");
dismiss:SetWidth(24); dismiss:SetHeight(24);
local fixNow = CreateFrame("CheckButton", "OPieOopsFixNow", frame, "UICheckButtonTemplate");
fixNow:SetPoint("BOTTOMLEFT", 15, 5); OPieOopsFixNowText:SetText("Attempt to restore lost rings.");
fixNow:SetWidth(24); fixNow:SetHeight(24);
local errbox = CreateFrame("EditBox", nil, frame);
	errbox:SetWidth(370); errbox:SetHeight(200); errbox:SetPoint("TOP", desc, "BOTTOM", 0, -3);
	errbox:SetPoint("BOTTOM", 0, 50);
	errbox:SetMultiLine(true); errbox:SetAutoFocus(false); errbox:SetFontObject(GameFontNormal);
	errbox:SetScript("OnEditFocusGained", function(self) self:HighlightText(); end);
	errbox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); end);
	errbox:SetScript("OnTextSet", function(self) self.text = self:GetText() end);
	errbox:SetScript("OnTextChanged", function(self) self:SetText(self.text or ""); self:ClearFocus() end);
XF = frame;

close:SetScript("OnClick", function(self)
	self:GetParent():Hide();
	if not frame.activeID then return; end
	doRestore = fixNow:GetChecked() and OPie_OLog[frame.activeID].RKData or false;
	if dismiss:GetChecked() then
		table.remove(OPie_OLog, frame.activeID);
	end
	if doRestore then
		OPie_OLog[frame.activeID].RKData = nil;
		ReloadUI();
	end
end);

-- Internal API
local function Log_Write(text)
	csession[cnID], cnID = text, cnID + 1;
end
local function Restore_RK(source, gently)
	if doRestore then
		if not OneRing_Config then OneRing_Config = {}; end
		if not OneRing_Config.SavedRingData then OneRing_Config.SavedRingData = {}; end
		OneRing_Config.SavedRingData.RingKeeper = doRestore;
		if not gently then doRestore = false; end
		Log_Write(tostring(source) .. ": Restored RK config");
	end
end

-- Event Handling
h:SetScript("OnEvent", function(s, e, ...) s[e](s, ...); end);
setmetatable(h, {__newindex=function(t,k,v)	if type(v) == "function" then t:RegisterEvent(k); end	rawset(t,k,v); end, __index=getmetatable(h).__index});
function h:ADDON_LOADED(addon)
	if addon == "OPie" then
		Log_Write(("SYS: ADDON_LOADED on %s"):format(date()));
		if type(OPie_OLog) ~= "table" then OPie_OLog = {}; end
		local i, lRep = 1;
		while i <= #OPie_OLog do
			if OPie_OLog[i].RKStart == nil or OPie_OLog[i].RKStart <= 0 or OPie_OLog[i].RKEnd > 0 then
				table.remove(OPie_OLog, i);
			else
				i, lRep = i + 1, i;
			end
		end
		OPie_OLog[i] = csession;
		if lRep then
			frame.activeID = lRep;
			errbox:SetText(table.concat(OPie_OLog[lRep], "\n"));
			if not OPie_OLog[lRep].RKData then
				fixNow:Hide();
			end
			frame:Show();
		end
	end
end
function h:PLAYER_LOGIN()
	Log_Write("SYS: PLAYER_LOGIN on " .. date());
end
function h:PLAYER_LOGOUT()
	Log_Write("SYS: PLAYER_LOGOUT on " .. date());
	Restore_RK("SYS", true);
end

-- External API
function Log:WriteLog(text, ...)
	Log_Write(tostring(text):format(...));
end
function Log:SetProp(k, v)
	assert(type(k) ~= "number", "Log:SetProp(k, v): numeric keys only", 2);
	assert(csession[k] == nil, "Log:SetProp(k, v): key %q already exists", 2, tostring(k));
	csession[k] = v;
end
function Log:PublicSV()
	Restore_RK("PubSV");
end
Log:WriteLog("+ OneRingLib v.%s.%s", select(2, OneRingLib:GetVersion()));

OneRingLib.ext.Log = Log;