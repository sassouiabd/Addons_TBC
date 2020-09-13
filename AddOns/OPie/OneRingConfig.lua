local wrathAPI = select(4,GetBuildInfo()) >= 30000;
local OneRing = _G.OneRingLib;
local lang = OneRing.lang;

local OR_ConfigBindings, OR_OptionReverts = nil, {};
local OR_CurrentOptionsDomain;
local AR_RingListOffset, AR_RingListSelection = 0, 0;

local function SetDimensions(frame, w, h)
	frame:SetWidth(w); frame:SetHeight(h or w);
end
-- Options interface [for]
local RingLineCount = 14;
local ORC_Frame = CreateFrame("Frame", "OPie_Config", UIParent);
	SetDimensions(ORC_Frame, 350, 400); ORC_Frame:Hide();
	ORC_Frame.name = "OPie";
	InterfaceOptions_AddCategory(ORC_Frame);
	
	local ORC_Title = ORC_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
		SetDimensions(ORC_Title, 340, 20); ORC_Title:SetPoint("TOPLEFT", 15, -14);
		ORC_Title:SetJustifyH("LEFT");
	local ORC_Version = ORC_Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
		ORC_Version:SetPoint("TOPRIGHT", -15, -15); ORC_Version:SetJustifyH("RIGHT");
	local ORC_Intro = ORC_Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		ORC_Intro:SetWidth(350); ORC_Intro:SetPoint("TOPLEFT", ORC_Title, "BOTTOMLEFT");
		ORC_Intro:SetJustifyH("LEFT");
	local ORC_OptionDomain = CreateFrame("Frame", "ORC_OptionDomain", ORC_Frame, "UIDropDownMenuTemplate");
		ORC_OptionDomain:SetPoint("TOPRIGHT", ORC_Intro, "BOTTOMRIGHT", 0, -20);
	local ORC_OptionDomainLabel = ORC_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		ORC_OptionDomainLabel:SetPoint("TOPLEFT", ORC_Intro, "BOTTOMLEFT", 0, -25);

	local ORC_Options = {};
	local function ORC_SafeOptionChange(option, value)
		local found = false;
		for i=1,#OR_OptionReverts,3 do
			if OR_OptionReverts[i] == option and OR_OptionReverts[i+1] == OR_CurrentOptionsDomain then
				found = true;
				break;
			end
		end
		if not found then
			local id = #OR_OptionReverts+1;
			OR_OptionReverts[id], OR_OptionReverts[id+1], OR_OptionReverts[id+2] =
				option, OR_CurrentOptionsDomain, OneRing:GetOption(option, OR_CurrentOptionsDomain);
		end
		OneRing:SetOption(option, OR_CurrentOptionsDomain, value);
	end
	local function ORC_OptionChanged(self, btn)
		local value = self:GetChecked() == 1;
		if btn == "RightButton" then value = nil; end
		ORC_SafeOptionChange(self.id, value);
		self:SetChecked(OneRing:GetOption(self.id, OR_CurrentOptionsDomain) and 1 or nil);
	end
	local function ORC_SliderChanged(self)
		ORC_SafeOptionChange(self.id, self:GetValue());
		self.text:SetText(lang("cfg" .. self.id):format(self:GetValue()));
	end
	local function ORC_SpawnOption(id, relativeTo, relativePoint, ofsx, ofsy)
		local chk = CreateFrame("CheckButton", "OneRingConfig_Option_" .. id, ORC_Frame, "InterfaceOptionsCheckButtonTemplate");
		chk:SetPoint("TOPLEFT", relativeTo or ORC_Options[#ORC_Options] or ORC_OptionDomainLabel, relativePoint or "BOTTOMLEFT", ofsx or 0, (ofsy or 0) + 5);
		chk:SetScript("OnClick", ORC_OptionChanged); SetDimensions(chk, 24); chk:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		ORC_Options[id], ORC_Options[#ORC_Options+1], chk.id = chk, chk, id;
	end
	ORC_SpawnOption("RingAtMouse", nil, nil, 0, -18);
	local ORC_IndicationOffsetCaption = ORC_Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	ORC_IndicationOffsetCaption:SetPoint("TOPLEFT", ORC_Options[#ORC_Options], "BOTTOMLEFT", 26, 0);
	local ORC_IndicationOffsetInput = CreateFrame("EditBox", "ORC_IndicationOffset", ORC_Frame, "InputBoxTemplate");
		ORC_IndicationOffsetInput:SetPoint("LEFT", ORC_IndicationOffsetCaption, "RIGHT", 15, 0);
		SetDimensions(ORC_IndicationOffsetInput, 80, 16);
		ORC_IndicationOffsetInput:SetAutoFocus(false);
	local ORC_IndicationCaption = ORC_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	ORC_IndicationCaption:SetPoint("TOPLEFT", ORC_IndicationOffsetCaption, "BOTTOMLEFT", -26, -10);
	ORC_SpawnOption("DimScreen", ORC_IndicationCaption, nil, 0, -8);
	ORC_SpawnOption("ShowPointer", ORC_IndicationCaption, nil, 155, -8);
	ORC_SpawnOption("ShowIcons", ORC_Options[#ORC_Options-1]);
	ORC_SpawnOption("ShowCaptions", ORC_Options[#ORC_Options-1]);
	ORC_SpawnOption("ShowCooldowns", ORC_Options[#ORC_Options-1]);
	ORC_SpawnOption("MultiIndication", ORC_Options[#ORC_Options-1]);
	ORC_SpawnOption("ClickActivation", ORC_Options[#ORC_Options-1]);
	local ORC_ScaleSlider = CreateFrame("Slider", "ORC_ScaleSlider", ORC_Frame, "OptionsSliderTemplate");
		ORC_ScaleSlider:SetWidth(300); ORC_ScaleSlider:SetPoint("TOPLEFT", ORC_Options[#ORC_Options], "BOTTOMLEFT", 7, -15);
		ORC_ScaleSlider:SetMinMaxValues(0, 3); ORC_ScaleSlider:SetValueStep(0.10);
		ORC_ScaleSlider:SetScript("OnValueChanged", ORC_SliderChanged);
		ORC_ScaleSlider.id, ORC_ScaleSlider.text = "RingScale", ORC_ScaleSliderText;

	local ORC_StanceBarButton = CreateFrame("Button", "ORC_StanceBarPref", ORC_Frame, "UIPanelButtonTemplate2");
		SetDimensions(ORC_StanceBarButton, 180, 16);
		ORC_StanceBarButton:SetPoint("BOTTOM", 0, 20);
-- Options Interface [end]
-- Bindings Interface [for]
	local ORC_Bindings = CreateFrame("Frame", "OneRing_BindingsConfig", UIParent);
		SetDimensions(ORC_Bindings, 350, 400); ORC_Bindings:Hide();
		ORC_Bindings.name, ORC_Bindings.parent = lang("cfgBindingTitle"), "OPie";
		InterfaceOptions_AddCategory(ORC_Bindings);
	local OR_BindingsTitle = ORC_Bindings:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
		SetDimensions(OR_BindingsTitle, 340, 20); OR_BindingsTitle:SetPoint("TOPLEFT", 15, -14);
		OR_BindingsTitle:SetJustifyH("LEFT");
	local OR_BindingsIntro = ORC_Bindings:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		OR_BindingsIntro:SetWidth(340); OR_BindingsIntro:SetPoint("TOPLEFT", OR_BindingsTitle, "BOTTOMLEFT");
		OR_BindingsIntro:SetJustifyH("LEFT");
	local function AR_SpawnConfigLine(id, fontstyle)
		local line = CreateFrame("Button", nil, ORC_Bindings);
		SetDimensions(line, 350, 20);
		line.caption = line:CreateFontString(nil, "OVERLAY", fontstyle or "GameFontHighlightSmall");
		line.content = line:CreateFontString(nil, "OVERLAY", fontstyle or "GameFontHighlightSmall");
		if id ~= 0 then
			line.shortcut = CreateFrame("Button", "OneRingConfigKey" .. id, line, "UIPanelButtonTemplate2");
			if wrathAPI then
				line.shortcut:SetNormalFontObject(GameFontHighlightSmall);
			else
				line.shortcut:SetTextFontObject(GameFontHighlightSmall);
			end
			line.shortcut:SetHighlightFontObject(GameFontHighlightSmall);
			line.shortcut:RegisterForClicks("AnyUp");
		else
			line.shortcut = line:CreateFontString(nil, "OVERLAY", fontstyle or "GameFontNormalSmall");
		end
		line.shortcut:SetPoint("RIGHT"); SetDimensions(line.shortcut, 120, 16);
		line.caption:SetJustifyH("LEFT"); line.caption:SetAllPoints();
		line.content:SetPoint("LEFT", line, "LEFT", 100, 0); line.content:SetJustifyH("LEFT"); 
		line:SetID(id);
		return line;
	end
	local AR_RingList = {[0]=AR_SpawnConfigLine(0, "GameFontNormal")};
	AR_RingList[0]:SetPoint("TOPLEFT", OR_BindingsIntro, "BOTTOMLEFT", 0, -10); AR_RingList[0]:Disable();
	for i=1,RingLineCount do
		AR_RingList[i] = AR_SpawnConfigLine(i);
		AR_RingList[i]:SetPoint("TOP", AR_RingList[i-1],"BOTTOM");
	end
	local ORC_ScrollUp = CreateFrame("Button", "OneRingConfigUp", ORC_Bindings, "UIPanelScrollUpButtonTemplate");
	ORC_ScrollUp:SetPoint("TOPLEFT", AR_RingList[#AR_RingList], "BOTTOMLEFT", 0, -2);
	local ORC_ScrollDown = CreateFrame("Button", "OneRingConfigUp", ORC_Bindings, "UIPanelScrollDownButtonTemplate");
	ORC_ScrollDown:SetPoint("LEFT", ORC_ScrollUp, "RIGHT", 1, 0);
	ORC_ScrollUp:SetID(1); ORC_ScrollDown:SetID(3);
	local ORC_Unbind = CreateFrame("Button", "OneRingConfigUnbind", ORC_Bindings, "UIPanelButtonTemplate")
	SetDimensions(ORC_Unbind, 120, 22); ORC_Unbind:SetPoint("TOP", AR_RingList[#AR_RingList].shortcut, "BOTTOM", 0, -10);
	ORC_Unbind:Disable();
-- Configuration Interface [end]

local function OR_SyncBindingsList(ofs)
	local n = #OR_ConfigBindings;
	AR_RingListOffset = ofs;
	for i=ofs+1,ofs+RingLineCount do
		local entry, props = AR_RingList[i-ofs], OR_ConfigBindings[i];
		if i > n then
			entry:Hide();
		else
			local none = lang("cfgNoBinding");
			local hotkey, override, active = OneRing:GetRingBinding(i);
			if not hotkey then hotkey = none; end
			hotkey = _G["KEY_" .. hotkey] or hotkey;
			if hotkey ~= none and not active then hotkey = "|cff808080" .. hotkey .. "|r";
			elseif not override then hotkey = "|cfff0f033" .. hotkey .. "|r"; end
			entry.caption:SetText(props.name or props.codename or "#@$@!");
			entry.shortcut:SetText(hotkey);
			local cnt, ico, questionMark = "", " |T%s:16|t", "Interface\\Icons\\INV_Misc_QuestionMark";
			for i=1,#props do
				if props[i][1] == "macrotext" then
					cnt = cnt .. ico:format("Interface\\Icons\\Trade_Engineering");
				elseif props[i][1] == "macro" then
					cnt = cnt .. ico:format(select(2, GetMacroInfo(props[i][2])) or "");
				elseif props[i][1] == "item" then
					cnt = cnt .. ico:format((GetItemIcon(SecureCmdItemParse(props[i][2]))) or questionMark);
				elseif props[i][1] == "spell" then
					cnt = cnt .. ico:format(GetSpellTexture(props[i][2]) or "Interface\\Icons\\INV_Misc_QuestionMark");
				elseif props[i].icon then
					local icon = nil;
					icon = type(props[i].icon) == "function" and props[i]:icon() or props[i].icon;
					cnt = cnt .. ico:format(type(icon) == "string" and icon or questionMark);
				else
					cnt = cnt .. ico:format(questionMark);
				end
			end
			entry.content:SetText(#props > 0 and cnt or lang("cfgNoContent"));
			entry:SetID(i);
			entry:Show();
		end
	end
	if RingLineCount >= n then
		ORC_ScrollUp:Hide(); ORC_ScrollDown:Hide();
	else
		ORC_ScrollUp:Show(); ORC_ScrollDown:Show();
		ORC_ScrollUp[ofs > 0 and "Enable" or "Disable"](ORC_ScrollUp);
		ORC_ScrollDown[(ofs + RingLineCount) < n and "Enable" or "Disable"](ORC_ScrollDown);
	end
end
local function OR_SetOriginalOffset(self)
	local x, y = OneRing:GetOption("IndicationOffsetX", OR_CurrentOptionsDomain), OneRing:GetOption("IndicationOffsetY", OR_CurrentOptionsDomain);
	self:SetText(x .. ", " .. y);
	self:ClearFocus();
end
local function OR_SetModifiedOffset(self)
	local x, y = self:GetText():match("^%s*(%-?%d+%.?%d*)%s*,%s*(%-?%d+%.?%d*)%s*$");
	if not x then
		self:HighlightText(0, #(self:GetText()));
	else
		ORC_SafeOptionChange("IndicationOffsetX", tonumber(x));
		ORC_SafeOptionChange("IndicationOffsetY", tonumber(y));
		OR_SetOriginalOffset(self);
	end
end
local function OR_ClearOffset(self, button)
	if button == "RightButton" then
		ORC_SafeOptionChange("IndicationOffsetX", nil);
		ORC_SafeOptionChange("IndicationOffsetY", nil);
		OR_SetOriginalOffset(self);
	end
end
local function OR_SyncOptions()
	for k, v in pairs(ORC_Options) do
		if type(k) ~= "number" then
			_G["OneRingConfig_Option_" .. k .. "Text"]:SetText(lang("cfg" .. k));
			v:SetChecked(OneRing:GetOption(k, OR_CurrentOptionsDomain) == true and 1 or nil);
		end
	end
	ORC_ScaleSlider:SetValue(OneRing:GetOption("RingScale", OR_CurrentOptionsDomain));
	ORC_ScaleSliderText:SetText(lang("cfgRingScale"):format(ORC_ScaleSlider:GetValue()));
	OR_SetOriginalOffset(ORC_IndicationOffsetInput);
	local label = lang("cfgGlobalDomain");
	if OR_CurrentOptionsDomain then
		local name, key, count = OneRing:GetRingInfo(OR_CurrentOptionsDomain);
		label = lang("cfgRingDomain"):format(name or key, count);
	end
	if wrathAPI then
		UIDropDownMenu_SetText(ORC_OptionDomain, label);
	else
		UIDropDownMenu_SetText(label, ORC_OptionDomain);
	end
end
local function OR_UpdateStanceBarState()
	if not (OneRing.ext.StanceBar and OneRing.ext.StanceBar.IsUsed()) then
		ORC_StanceBarButton:Hide();
	else
		local state = OneRing.ext.StanceBar:GetVisibility();
		ORC_StanceBarButton:SetText(lang(state and "cfgHideStanceBar" or "cfgShowStanceBar"));
	end
end
local function OR_StanceBarStateClick(self)
	local m = OneRing.ext.StanceBar;
	m.SetVisibility(not m.GetVisibility());
	OR_UpdateStanceBarState();
end

function ORC_OptionDomain.click(self, ringID)
	if not wrathAPI then ringID = self; end
	OR_CurrentOptionsDomain = ringID;
	OR_SyncOptions();
end
function ORC_OptionDomain.menu()
	local info = UIDropDownMenu_CreateInfo();
	info.func, info.arg1, info.text, info.checked = ORC_OptionDomain.click, nil, lang("cfgGlobalDomain"), OR_CurrentOptionsDomain == nil and 1 or nil;
	UIDropDownMenu_AddButton(info);
	for i=1,OneRing:GetNumRings() do
		local name, key, count = OneRing:GetRingInfo(i);
		info.text, info.arg1, info.checked = lang("cfgRingDomain"):format(name or key, count), i, i == OR_CurrentOptionsDomain and 1 or nil;
		UIDropDownMenu_AddButton(info);
	end
end

local function ORC_BindingsShow()
	if not OR_ConfigBindings then
		OR_ConfigBindings = {Bindings={}};
		for i=1, OneRing:GetNumRings() do
			OR_ConfigBindings[i] = OneRing:GetRingData(i);
			local bind, over = OneRing:GetRingBinding(i)
			OR_ConfigBindings.Bindings[i] = over and bind or nil;
		end
	end
	ORC_Bindings.name = lang("cfgBindingTitle");
	OR_BindingsTitle:SetText(ORC_Bindings.name);
	OR_BindingsIntro:SetText(lang("cfgBindingIntro"));
	AR_RingList[0].caption:SetText(lang("cfgName"));
	AR_RingList[0].content:SetText(lang("cfgContent"));
	AR_RingList[0].shortcut:SetText(lang("cfgBinding"));
	ORC_Unbind:SetText(lang("cfgUnbind"));
	OR_SyncBindingsList(AR_RingListOffset);
end
local function ORC_OptionsShow()
	ORC_Title:SetText(lang("title"));
	ORC_Version:SetFormattedText("%s (%d.%d)", OneRing:GetVersion());
	ORC_Intro:SetText(lang("cfgMainIntro"));
	ORC_IndicationCaption:SetText(lang("cfgIndication"));
	ORC_OptionDomainLabel:SetText(lang("cfgDomain"));
	ORC_IndicationOffsetCaption:SetText(lang("cfgIndicationOffset"));
	ORC_ScaleSliderHigh:SetText(3);
	ORC_ScaleSliderLow:SetText(0);
	OR_CurrentOptionsDomain = nil;
	OR_SyncOptions();
	OR_UpdateStanceBarState();
end
function ORC_Bindings.okay()
	OR_ConfigBindings = nil;
end
function ORC_Frame.okay()
	for k in pairs(OR_OptionReverts) do
		OR_OptionReverts[k] = nil;
	end
end
function ORC_Bindings.cancel()
	if OR_ConfigBindings then
		for k, b in ipairs(OR_ConfigBindings.Bindings) do
			OneRing:SetRingBinding(k, b);
		end
		OR_ConfigBindings = nil;
	end
end
function ORC_Frame.cancel()
	for i=1,#OR_OptionReverts,3 do
		OneRing:SetOption(OR_OptionReverts[i], OR_OptionReverts[i+1], OR_OptionReverts[i+2]);
		OR_OptionReverts[i], OR_OptionReverts[i+1], OR_OptionReverts[i+2] = nil, nil, nil;
	end
end
function ORC_Frame.default()
	OneRing:ResetOptions(true);
end
function ORC_Bindings.default()
	for i=1,#OR_ConfigBindings do
		OneRing:SetRingBinding(i, nil);
	end
end

local function ORC_Scroll(self)
	OR_SyncBindingsList(AR_RingListOffset+self:GetID()-2);
end

local mouseTranslation = {["MiddleButton"]="BUTTON3", ["Button4"]="BUTTON4", ["Button5"]="BUTTON5"};
local function ORC_BindingDisarm(btn)
	btn:UnlockHighlight(); btn:SetScript("OnKeyDown", nil); btn:EnableKeyboard(false);
	btn:GetParent():GetParent().keysetActive = nil;
	ORC_Unbind.binding = nil; ORC_Unbind:Disable();
end
local function ORC_BindingListen(self, arg1)
	if not (arg1:match("^[LR]?ALT$") or arg1:match("^[LR]?CTRL$") or arg1:match("^[LR]?SHIFT$")) then
		if arg1 ~= "ESCAPE" then
	  	local bind = (IsAltKeyDown() and "ALT-" or "") ..  (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "") .. arg1;
			OneRing:SetRingBinding(self:GetParent():GetID(), bind);
			OR_SyncBindingsList(AR_RingListOffset);
		end
		ORC_BindingDisarm(self);
	end
end
local function ORC_BindingClick(self, button)
	local oldKeySet = self:GetParent():GetParent().keysetActive;
	if oldKeySet == self and mouseTranslation[button] then
		ORC_BindingListen(self, mouseTranslation[button]);
	elseif oldKeySet then	ORC_BindingDisarm(oldKeySet); end
	if oldKeySet == self then return; end
	self:LockHighlight();	self:GetParent():GetParent().keysetActive = self;
	self:SetScript("OnKeyDown", ORC_BindingListen); self:EnableKeyboard(true);
	self:SetScript("OnHide", ORC_BindingDisarm);
	ORC_Unbind:Enable(); ORC_Unbind.binding = self;
end
local function ORC_BindingClear(self)
	if self.binding ~= nil then
		OneRing:SetRingBinding(self.binding:GetParent():GetID(), false);	
		ORC_BindingDisarm(self.binding);
		OR_SyncBindingsList(AR_RingListOffset);
	end
end

ORC_Frame.refresh = ORC_OptionsShow;
ORC_Bindings.refresh = ORC_BindingsShow;
do
	ORC_Frame:SetScript("OnShow", ORC_OptionsShow);
	ORC_Bindings:SetScript("OnShow", ORC_BindingsShow);
	ORC_Unbind:SetScript("OnClick", ORC_BindingClear);
	ORC_ScrollUp:SetScript("OnClick", ORC_Scroll);
	ORC_ScrollDown:SetScript("OnClick", ORC_Scroll);
	ORC_IndicationOffsetInput:SetScript("OnEscapePressed", OR_SetOriginalOffset);
	ORC_IndicationOffsetInput:SetScript("OnEnterPressed", OR_SetModifiedOffset);
	ORC_IndicationOffsetInput:SetScript("OnMouseUp", OR_ClearOffset);
	if wrathAPI then
		UIDropDownMenu_SetWidth(ORC_OptionDomain, 200)
	else
		UIDropDownMenu_SetWidth(200, ORC_OptionDomain);
	end
	UIDropDownMenu_Initialize(ORC_OptionDomain, ORC_OptionDomain.menu);
	for i=1,RingLineCount do
		AR_RingList[i].shortcut:SetScript("OnClick", ORC_BindingClick);
	end
	ORC_StanceBarButton:SetScript("OnClick", OR_StanceBarStateClick);
end

SLASH_OPIE1, SLASH_OPIE2 = "/opie", "/op";
local ShowPanel = wrathAPI and InterfaceOptionsFrame_OpenToCategory or InterfaceOptionsFrame_OpenToFrame;
SlashCmdList["OPIE"] = function (args)
	if not ORC_Frame:IsVisible() and ShowPanel then
		ShowPanel(ORC_Frame);
	end
end