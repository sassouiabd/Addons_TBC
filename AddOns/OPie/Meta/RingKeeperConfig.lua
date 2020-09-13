local wrathAPI = select(4,GetBuildInfo()) >= 30000;
local OneRing = _G.OneRingLib;
local lang, RingLineCount, RingKeeper = OneRing.lang, nil, OneRing.RingKeeper;
-- Build Configuration dialog frames/widgets for OneRing
local function SetDimensions(frame, w, h)
	frame:SetWidth(w); frame:SetHeight(h or w);
end
local RKC_Frame = CreateFrame("Frame", "OneRing_RKConfig", UIParent);
	SetDimensions(RKC_Frame, 350, 400); RKC_Frame:SetPoint("CENTER"); RKC_Frame:Hide();
	RKC_Frame.name, RKC_Frame.parent = lang("cfgRKTitle"), "OPie";
	InterfaceOptions_AddCategory(RKC_Frame);
	
	local ConfigTitle = RKC_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
		ConfigTitle:SetText(RKC_Frame.name); SetDimensions(ConfigTitle, 340, 20);
		ConfigTitle:SetPoint("TOPLEFT", 15, -14); ConfigTitle:SetJustifyH("LEFT");
	local RKC_Version = RKC_Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
		RKC_Version:SetPoint("TOPRIGHT", -15, -20); RKC_Version:SetJustifyH("RIGHT");
	local RKC_ConfigIntro = RKC_Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		SetDimensions(RKC_ConfigIntro, 360, 0); RKC_ConfigIntro:SetPoint("TOPLEFT", ConfigTitle, "BOTTOMLEFT");
		RKC_ConfigIntro:SetText("42");
		RKC_ConfigIntro:SetJustifyH("LEFT");
	local RKC_RingDropdown = CreateFrame("Frame", "RKC_RingDropdown", RKC_Frame, "UIDropDownMenuTemplate");
		RKC_RingDropdown:SetPoint("TOPLEFT", RKC_ConfigIntro, "BOTTOMLEFT", -5, -10);
		if wrathAPI then
			UIDropDownMenu_SetWidth(RKC_RingDropdown, 200);
		else
			UIDropDownMenu_SetWidth(200, RKC_RingDropdown);
		end
	local RKC_CreateNewRing = CreateFrame("Button", "RKC_AddNewRing", RKC_Frame, "UIPanelButtonTemplate2");
		RKC_CreateNewRing:SetPoint("LEFT", RKC_RingDropdown, "RIGHT", -6, 2); RKC_CreateNewRing:SetWidth(120);
	local RKC_Detail = CreateFrame("Frame", "RKC_DetailFrame", RKC_Frame);
		SetDimensions(RKC_Detail, 350, 290); RKC_Detail:SetPoint("TOPLEFT", RKC_RingDropdown, "BOTTOMLEFT", 5, -2);
		RKC_Detail:SetBackdrop({edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16, insets={left=5,right=5, top=5, bottom=5}});
		RKC_Detail:SetBackdropBorderColor(.6, .6, .6, 1);
	local RKCD_Name = CreateFrame("EditBox", nil, RKC_Detail);
		SetDimensions(RKCD_Name, 300, 20); RKCD_Name:SetFontObject(GameFontNormalLarge); RKCD_Name:SetAutoFocus(false);
		RKCD_Name:SetPoint("TOPLEFT", 7, -7);
	local RKCD_Instruct = RKC_Detail:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
		RKCD_Instruct:SetWidth(330); RKCD_Instruct:SetPoint("TOPLEFT", RKCD_Name, "BOTTOMLEFT", 0, -2);
		RKCD_Instruct:SetJustifyH("LEFT");

	local RKCD_Buttons = {};
	local function RKCD_Desc_Enter(self)
		self.border:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	local function RKCD_Desc_Exit(self)
		self.border:SetVertexColor(1,1,1);
	end
	local function RKCD_CreateDescButton(id)
		local btn = CreateFrame("Frame", nil, RKC_Detail);
			SetDimensions(btn, 32, 54);
		btn.ico = CreateFrame("CheckButton", nil, btn);
			SetDimensions(btn.ico, 32); btn.ico:SetPoint("TOP");
			btn.ico:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
			btn.ico:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight");
		btn.tex = btn.ico:CreateTexture(nil, "ARTWORK"); btn.tex:SetAllPoints();
		btn.color = CreateFrame("Button", nil, btn);
			SetDimensions(btn.color, 32, 16); btn.color:SetPoint("TOP", btn.ico, "BOTTOM", 0, -6);
		btn.ctex = btn.color:CreateTexture(nil, "OVERLAY");
			SetDimensions(btn.ctex, 26, 10); btn.ctex:SetPoint("CENTER");
			btn.ctex:SetTexture(1,1,1);
		local bg = btn.color:CreateTexture(nil, "BORDER");
			SetDimensions(bg, 30, 14); bg:SetPoint("CENTER");
		btn.color.border = btn.color:CreateTexture(nil, "BACKGROUND");
			SetDimensions(btn.color.border, 32, 16); btn.color.border:SetPoint("CENTER");
		bg:SetTexture(0,0,0); btn.color.border:SetTexture(1,1,1);
		btn.color:SetScript("OnEnter", RKCD_Desc_Enter); btn.color:SetScript("OnLeave", RKCD_Desc_Exit);
		btn:SetID(id);
		return btn;
	end
	local RKCD_Prev = CreateFrame("Button", nil, RKC_Detail);	SetDimensions(RKCD_Prev, 32); RKCD_Prev:SetID(1);
	RKCD_Prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
	RKCD_Prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
	RKCD_Prev:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled");
	RKCD_Prev:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
	local RKCD_Next = CreateFrame("Button", nil, RKC_Detail); SetDimensions(RKCD_Next, 32); RKCD_Next:SetID(3);
	RKCD_Next:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	RKCD_Next:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
	RKCD_Next:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled");
	RKCD_Next:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");

	RKCD_Buttons[1] = RKCD_CreateDescButton(1);
	RKCD_Buttons[1]:SetPoint("TOPLEFT", RKCD_Instruct, "BOTTOMLEFT", 30, -5);
	for i=2,8 do
		RKCD_Buttons[i] = RKCD_CreateDescButton(i);
		RKCD_Buttons[i]:SetPoint("LEFT", RKCD_Buttons[i-1], "RIGHT", 3, 0);
	end
	RKCD_Prev:SetPoint("RIGHT", RKCD_Buttons[1], "LEFT", -1, 12);
	RKCD_Next:SetPoint("LEFT", RKCD_Buttons[#RKCD_Buttons], "RIGHT", 1, 12);

	local RKC_InnerDetail = CreateFrame("Frame", nil, RKC_Detail);
		RKC_InnerDetail:SetWidth(325);	RKC_InnerDetail:SetPoint("TOP", RKCD_Buttons[1], "BOTTOM", 0, -8);
		RKC_InnerDetail:SetPoint("BOTTOMLEFT", 12, 35);
		RKC_InnerDetail:SetBackdrop(RKC_Detail:GetBackdrop());
		RKC_InnerDetail:SetBackdropBorderColor(RKC_Detail:GetBackdropBorderColor());

	local RKCD_EntryDetail = CreateFrame("Frame", "RKCD_EntryFrame", RKC_InnerDetail);
		RKCD_EntryDetail:SetPoint("TOPLEFT"); RKCD_EntryDetail:SetPoint("BOTTOMRIGHT");
	local RKCD_SpellDetail = RKCD_EntryDetail:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		SetDimensions(RKCD_SpellDetail, 310, 0); RKCD_SpellDetail:SetPoint("TOPLEFT", 10, -10);
		RKCD_SpellDetail:SetJustifyH("LEFT");
	local RKCD_EntryByName = CreateFrame("CheckButton", "RKCD_EntryByName", RKCD_EntryDetail, "InterfaceOptionsCheckButtonTemplate");
		RKCD_EntryByNameText:SetWidth(290); RKCD_EntryByNameText:SetJustifyH("LEFT");
		SetDimensions(RKCD_EntryByName, 24); RKCD_EntryByName:SetPoint("TOPLEFT", RKCD_SpellDetail, "BOTTOMLEFT", 0, -3);
		RKCD_EntryByName:Hide();
	local RKCD_OnlyWhilePresent = CreateFrame("CheckButton", "RKCD_OnlyWhilePresent", RKCD_EntryDetail, "InterfaceOptionsCheckButtonTemplate");
		RKCD_OnlyWhilePresentText:SetWidth(290); RKCD_OnlyWhilePresentText:SetJustifyH("LEFT");
		SetDimensions(RKCD_OnlyWhilePresent, 24); RKCD_OnlyWhilePresent:SetPoint("TOPLEFT", RKCD_EntryByName, "BOTTOMLEFT", 0, 2);
		RKCD_OnlyWhilePresent:Hide();
	local RKCD_UseExactRank = CreateFrame("CheckButton", "RKCD_ExactRank", RKCD_EntryDetail, "InterfaceOptionsCheckButtonTemplate");
		RKCD_ExactRankText:SetWidth(290); RKCD_ExactRankText:SetJustifyH("LEFT");
		SetDimensions(RKCD_UseExactRank, 24); RKCD_UseExactRank:SetPoint("TOPLEFT", RKCD_SpellDetail, "BOTTOMLEFT", 0, -3);
		RKCD_UseExactRank:Hide();

	local RKCD_MacroBG = CreateFrame("Frame", "RK_MBG", RKCD_EntryDetail);
		RKCD_MacroBG:SetBackdrop(RKC_Detail:GetBackdrop());
		RKCD_MacroBG:SetPoint("TOPLEFT", RKCD_SpellDetail);
		RKCD_MacroBG:Hide();
	local RKCD_MacroScroll = CreateFrame("ScrollFrame", "RKCD_MacroFrame", RKCD_MacroBG, "UIPanelScrollFrameTemplate");
		RKCD_MacroScroll:SetPoint("TOPLEFT", 5, -7); RKCD_MacroScroll:SetPoint("BOTTOMRIGHT", -28, 7);
	local RKCD_EntryMacro = CreateFrame("EditBox", "RKCD_EntryMacroText", RKCD_MacroScroll);
		RKCD_EntryMacro:SetWidth(300); RKCD_EntryMacro:SetMaxBytes(1023);
		RKCD_EntryMacro:SetMultiLine(true); RKCD_EntryMacro:SetAutoFocus(false);
		RKCD_EntryMacro:SetFontObject(GameFontHighlight);
		RKCD_MacroScroll:SetScrollChild(RKCD_EntryMacro);
		RKCD_EntryMacro.bar = _G["RKCD_MacroFrameScrollBar"];

	RKCD_MacroScroll:EnableMouse();
	RKCD_MacroScroll:SetScript("OnMouseDown", function() RKCD_EntryMacro:SetFocus(); end);

	local occH, occP; -- Height, Pos
	RKCD_EntryMacro:SetScript("OnCursorChanged", function(s, x,y,w,h)
		occH, occP, y = RKCD_MacroScroll:GetHeight(), RKCD_MacroScroll:GetVerticalScroll(), -y;
		if occP > y then occP = y; -- too far
		elseif (occP + occH) < (y+h) then occP = y+h-occH; -- not far enough
		else return; end -- is fine
		RKCD_MacroScroll:SetVerticalScroll(occP);
		local _, mx = s.bar:GetMinMaxValues();
		s.bar:SetMinMaxValues(0, occP < mx and mx or occP);
		s.bar:SetValue(occP);
	end);

	local RKCD_SliceHint = CreateFrame("Frame", "RKCD_SliceHintFrame", RKC_InnerDetail);
		RKCD_SliceHint:SetPoint("TOPLEFT");	RKCD_SliceHint:SetPoint("BOTTOMRIGHT");
		RKCD_SliceHint:Hide();
	local RKCD_SliceCaption = RKCD_SliceHint:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		RKCD_SliceCaption:SetPoint("TOPLEFT", 8, -10);
		RKCD_SliceCaption:SetText("Foo");
	local RKCD_SliceCaptionInput = CreateFrame("EditBox", "RKCD_SliceCaptionInput", RKCD_SliceHint, "InputBoxTemplate");
		RKCD_SliceCaptionInput:SetPoint("TOPLEFT", 120, -5);
		SetDimensions(RKCD_SliceCaptionInput, 196, 20);
		RKCD_SliceCaptionInput:SetAutoFocus(false);
		RKCD_SliceCaptionInput:SetFontObject(GameFontHighlight);
	local RKCD_EntryBackToDetail = CreateFrame("BUTTON", "RKCD_ShowEntryDetail", RKCD_SliceHint, "UIPanelButtonTemplate2");
		SetDimensions(RKCD_EntryBackToDetail, 130, 16); RKCD_EntryBackToDetail:SetPoint("BOTTOM", 0, 9);
	local RKCD_SliceScroll = CreateFrame("ScrollFrame", "RKCD_SliceIconScroll", RKCD_SliceHint, "UIPanelScrollFrameTemplate");
		RKCD_SliceScroll:SetPoint("TOPLEFT", 10, -28); RKCD_SliceScroll:SetPoint("BOTTOMRIGHT", -28, 24);
		local RKCD_SliceIconBar = RKCD_SliceIconScrollScrollBar;
		RKCD_SliceIconBar:SetMinMaxValues(1, 100);
		RKCD_SliceIconBar:SetValueStep(42);
		RKCD_SliceIconBar:SetValue(1);
	local RKCD_IconButtons = {};
	for y=0,1 do	for x=0,6 do
			local btn = CreateFrame("CheckButton", "RKCD_Icon" .. y .. "c" .. x, RKCD_SliceHint, "PopupButtonTemplate");
			btn:SetPoint("TOPLEFT", 10+x*42, -30-y*42);
			btn.icon, RKCD_IconButtons[y*7+x+1] = _G["RKCD_Icon" .. y .. "c" .. x .. "Icon"], btn;
	end end


	local RKCD_AddEntryMenu = CreateFrame("Frame", "RKCD_AddEntryMenu", UIParent, "UIDropDownMenuTemplate");
	local RKCD_AddEntry = CreateFrame("Button", nil, RKC_Detail);
		SetDimensions(RKCD_AddEntry, 16);
		RKCD_AddEntry:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
		RKCD_AddEntry:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down");
		RKCD_AddEntry:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
		RKCD_AddEntry:SetPoint("TOP", RKCD_Prev, "BOTTOM", 1, -6);
	local RKCD_EntryMoveLeft = CreateFrame("BUTTON", "RKCD_MoveEntryLeft", RKCD_EntryDetail, "UIPanelButtonTemplate2");
		SetDimensions(RKCD_EntryMoveLeft, 24, 16); RKCD_EntryMoveLeft:SetID(1); RKCD_EntryMoveLeft:SetText("<");
		RKCD_EntryMoveLeft:SetPoint("BOTTOMLEFT", 10, 10);
	local RKCD_EntryMoveRight = CreateFrame("BUTTON", "RKCD_MoveEntryRight", RKCD_EntryDetail, "UIPanelButtonTemplate2");
		SetDimensions(RKCD_EntryMoveRight, 24, 16); RKCD_EntryMoveRight:SetID(3); RKCD_EntryMoveRight:SetText(">");
		RKCD_EntryMoveRight:SetPoint("LEFT", RKCD_EntryMoveLeft, "RIGHT", 3, 0);
	local RKCD_EntryAlterHint = CreateFrame("BUTTON", "RKCD_ShowHintDetail", RKCD_EntryDetail, "UIPanelButtonTemplate2");
		SetDimensions(RKCD_EntryAlterHint, 130, 16); RKCD_EntryAlterHint:SetPoint("BOTTOM", 0, 10);

	local RKCD_Remove = CreateFrame("Button", "RKCD_RemoveElement", RKCD_EntryDetail, "UIPanelButtonTemplate2,UIPanelButtonGrayTemplate");
		SetDimensions(RKCD_Remove, 80, 22); RKCD_Remove:SetPoint("BOTTOMRIGHT", -10, 7);
		RKCD_MacroBG:SetPoint("BOTTOMRIGHT", RKCD_Remove, "TOPRIGHT", 3, 3);
	local RKCD_Save = CreateFrame("Button", "RKCD_Save", RKC_Detail, "UIPanelButtonTemplate2");
		SetDimensions(RKCD_Save, 80, 22); RKCD_Save:SetPoint("BOTTOMRIGHT", -10, 8);
	local RKCD_RemoveRing = CreateFrame("Button", "RKCD_RemoveRing", RKC_Detail, "UIPanelButtonTemplate2,UIPanelButtonGrayTemplate");
		SetDimensions(RKCD_RemoveRing, 80, 22); RKCD_RemoveRing:SetPoint("RIGHT", RKCD_Save, "LEFT", -10, 0);
	local RKCD_Hotkey = CreateFrame("Button", "RKCD_Hotkey", RKC_Detail, "UIPanelButtonTemplate2");
		SetDimensions(RKCD_Hotkey, 120, 22); RKCD_Hotkey:SetPoint("BOTTOMLEFT", 10, 8);

	local RKC_RingDetail = CreateFrame("Frame", "RKCD_RingFrame", RKC_InnerDetail);
		RKC_RingDetail:SetPoint("TOPLEFT");	RKC_RingDetail:SetPoint("BOTTOMRIGHT");
	local RKC_OnlyThisChar = CreateFrame("CheckButton", "RKC_LimitToMe", RKC_RingDetail, "InterfaceOptionsCheckButtonTemplate");
		SetDimensions(RKC_OnlyThisChar, 24); RKC_OnlyThisChar:SetPoint("TOPLEFT", RKC_RingDetail, "TOPLEFT", 5, -5);
	local RKC_OnlyThisClass = CreateFrame("CheckButton", "RKC_LimitToClass", RKC_RingDetail, "InterfaceOptionsCheckButtonTemplate");
		SetDimensions(RKC_OnlyThisClass, 24); RKC_OnlyThisClass:SetPoint("TOPLEFT", RKC_OnlyThisChar, "BOTTOMLEFT", 0, 5);
	local RKC_OffsetSlider = CreateFrame("Slider", "RKC_RingOffset", RKC_RingDetail, "OptionsSliderTemplate");
		RKC_OffsetSlider:SetPoint("TOP", 0, -54); RKC_OffsetSlider:SetWidth(290);
		RKC_OffsetSlider:SetMinMaxValues(0, 360); RKC_OffsetSlider:SetValueStep(15);
		RKC_RingOffsetLow:SetText("0\194\176"); RKC_RingOffsetHigh:SetText("360\194\176");
	local RKC_ShareText = RKC_RingDetail:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		RKC_ShareText:SetPoint("TOPLEFT", RKC_OnlyThisClass, "BOTTOMLEFT", 0, -40);
	local RKC_SharePlayerName = CreateFrame("EditBox", nil, RKC_RingDetail, "InputBoxTemplate");
		SetDimensions(RKC_SharePlayerName, 140, 32); RKC_SharePlayerName:SetAutoFocus(false);
		RKC_SharePlayerName:SetScript("OnEscapePressed", RKC_SharePlayerName.ClearFocus);
		RKC_SharePlayerName:SetPoint("LEFT", RKC_ShareText, "RIGHT", 10, 0);
		RKC_SharePlayerName:SetFontObject(GameFontHighlight);
	local RKC_ShareDo = CreateFrame("Button", "RKC_ShareRing", RKC_RingDetail, "UIPanelButtonTemplate2");
		RKC_ShareDo:SetWidth(80); RKC_ShareDo:SetPoint("LEFT", RKC_SharePlayerName, "RIGHT", 5, 0);

StaticPopupDialogs["RK_NAMEPROMPT"] = {button1=TEXT(ACCEPT), button2=TEXT(CANCEL), hasEditBox=1, maxLetters=255, whileDead=1, timeout=0, hideOnEscape=true, OnHide = function() _G[this:GetName().."EditBox"]:SetText(""); end};
-- textmate end tag: UI construction block.

local companionID, companionType;
if wrathAPI then
	hooksecurefunc("PickupCompanion", function(id, type)
		companionID, companionType = id, type;
	end);
end

local RK_SelectedRing, RK_SelectedRingID, RK_ElementOffset;
local RK_cInstance, desc, RK_SelectedRingEntry, RK_SelectedRingEntryID;

local function ORC_BindingFormat(bind)
	bind = bind or lang("cfgNoBinding");
	return _G["KEY_" .. bind] or bind;
end

local function RKCD_ClearSelection()
	RKCD_EntryDetail:Hide();
	if RK_SelectedRingEntry then
		RK_SelectedRingEntry:SetChecked(nil);
		RK_SelectedRingEntry = nil; RK_SelectedRingEntryID = nil;
		RKCD_SpellDetail:SetText("");
	end
	RKC_RingDetail:Show();
	RKCD_SliceHint:Hide();
end
local function RKC_ClearSelection()
	RK_SelectedRing = nil; RKC_Detail:Hide();
	if wrathAPI then
		UIDropDownMenu_SetText(RKC_RingDropdown, lang("cfgRKSelectARing"));
	else
		UIDropDownMenu_SetText(lang("cfgRKSelectARing"), RKC_RingDropdown);
	end
	RKCD_ClearSelection();
	RKC_RingDetail:Hide();
end
local function RKCD_UpdateDisplay()
	RK_SelectedRingEntry = nil;
	for i=RK_ElementOffset,#desc do
		local btn, rtype, rid = RKCD_Buttons[i-RK_ElementOffset+1], desc[i].rtype, desc[i].id;
		if not btn then break; end
		btn:SetID(i);	btn.ico:SetChecked(RK_SelectedRingEntryID == i and 1 or nil);
		if RK_SelectedRingEntryID == i then RK_SelectedRingEntry = btn.ico; end
		if rtype == "macrotext" then rtype, rid = OneRing.xlu.parseMacro(rid); end
		if rtype == "item" or rtype == "nitem" then
			btn.tex:SetTexture(GetItemIcon(rid) or "Interface\\Icons\\INV_Misc_QuestionMark");
		elseif rtype == "mount" then
			btn.tex:SetTexture(GetItemIcon(rid) or "Interface\\Icons\\Spell_Nature_Swiftness");
		elseif rtype == "macro" then
			btn.tex:SetTexture(select(2,GetMacroInfo(rid)));
		elseif type(rid) == "number" or rtype == "spell" or rtype == "companion" then
			btn.tex:SetTexture(select(3,GetSpellInfo(rid)) or "Interface\\Icons\\INV_Misc_QuestionMark");
		elseif type(rid) == "string" then
			btn.tex:SetTexture("Interface\\Icons\\" .. rid);
		else
			btn.tex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
		end
		if type(desc[i].icon) == "string" then
			btn.tex:SetTexture(desc[i].icon);
		end
		SetDesaturation(btn.tex, not (desc[i].action and desc[i].type));
		btn.ctex:SetVertexColor(desc[i].r, desc[i].g, desc[i].b);
		btn:Show();
	end
	for i=#desc+2-RK_ElementOffset,#RKCD_Buttons do
		RKCD_Buttons[i]:Hide();
	end
	RKCD_Prev[#desc < #RKCD_Buttons and "Hide" or "Show"](RKCD_Prev);
	RKCD_Next[#desc < #RKCD_Buttons and "Hide" or "Show"](RKCD_Next);
	RKCD_Prev[(RK_ElementOffset <= 1) and "Disable" or "Enable"](RKCD_Prev);
	RKCD_Next[(RK_ElementOffset+#RKCD_Buttons > #desc) and "Disable" or "Enable"](RKCD_Next);
	RKCD_AddEntry:Show();
end
local function RKC_SelectRing(self, cID)
	if not wrathAPI then cID = self; end
	local id = RK_cInstance[cID];
	local pname = RK_cInstance[id].name or id;

	RK_SelectedRing, RK_SelectedRingID, RK_ElementOffset = id, cID, 1;
	if wrathAPI then
		UIDropDownMenu_SetText(RKC_RingDropdown, pname);
	else
		UIDropDownMenu_SetText(pname, RKC_RingDropdown);
	end
	RKCD_Name:SetText(pname);
	RKCD_Name:ClearFocus();
	
	RKCD_ClearSelection();

	desc = RK_cInstance[id];
	RKCD_UpdateDisplay();
	RKCD_Hotkey:SetText(ORC_BindingFormat(desc.hotkey));
	RKC_OnlyThisChar:SetChecked(desc.limitToChar ~= nil and 1 or nil);
	RKC_OnlyThisClass:SetChecked(desc.class ~= nil and 1 or nil);
	RKC_SharePlayerName:SetText("");
	RKC_OffsetSlider:SetValue((desc.offset or 0) % 360);
	RKC_RingOffsetText:SetFormattedText(lang("cfgRKRotate"), desc.offset or 0);

	RKC_Detail:Show();
end
local function RKC_RingDropdownMenu(level)
	if not RK_cInstance then return; end
	local info = UIDropDownMenu_CreateInfo();
	info.func = RKC_SelectRing;
	for i, v in ipairs(RK_cInstance) do
		info.text, info.arg1, info.checked = RK_cInstance[v].name or v, i, RK_SelectedRing == v and 1 or nil;
		UIDropDownMenu_AddButton(info);
	end
end
local function RKCD_ChangeColor(self)
	local id, ctex = self:GetParent():GetID(), self:GetParent().ctex;
	local cp = ColorPickerFrame;
	cp.func, cp.previousValues, cp.hasOpacity = function(v)
		if v then
			ctex:SetVertexColor(unpack(v));
		else
			local r,g,b = cp:GetColorRGB();
			ctex:SetVertexColor(r,g,b)
		end
		desc[id].r, desc[id].g, desc[id].b = ctex:GetVertexColor();
	end, {ctex:GetVertexColor()}, false;
	cp.cancelFunc = cp.func;
	cp:SetColorRGB(ctex:GetVertexColor()); ColorSwatch:SetTexture(ctex:GetVertexColor()); cp:Show();
end
local function RKCD_InsertFromCursor(self, id)
	local type, cid, cid2 = GetCursorInfo();
	if type == "item" then
		table.insert(desc, id, {id=cid, rtype="item", r=0, g=1, b=1});
	elseif type == "spell" and cid == 0 then
		if wrathAPI and companionID then
			local cID, cName, cSpellID, icon, issummoned = GetCompanionInfo(companionID, companionType);
			table.insert(desc, id, {id=cSpellID, rtype="companion", r=0x89/255, g=0xC0/255, b=0xD6/255});
			companionID = nil;
		else
			return;
		end
	elseif type == "companion" then
		local cID, cName, cSpellID, icon, issummoned = GetCompanionInfo(cid, cid2);
		table.insert(desc, id, {id=cSpellID, rtype="companion", r=0x89/255, g=0xC0/255, b=0xD6/255});
	elseif type == "spell" then
		local spellId = tonumber(GetSpellLink(cid, cid2):match("spell:(%d+)"));
		table.insert(desc, id, {id=spellId, r=1, g=1, b=0});
	elseif type == "macro" then
		table.insert(desc, id, {id=cid, rtype="macro", r=0, g=1, b=1});
	end
	ClearCursor();
	RKCD_UpdateDisplay();
end
local function RKCD_GetSpellDescription(rtype, exactRank, id, id2)
	local s1, r1 = GetSpellInfo(id or 0);
	local s2, r2 = GetSpellInfo(id2 or 0);
	if exactRank and r1 ~= "" and s1 then s1 = s1 .. " (" .. r1 .. ")" end
	if exactRank and r2 ~= "" and s2 then s2 = s2 .. " (" .. r2 .. ")"; end
	if rtype == "uprank" or not rtype then
		return lang(id2 and "cfgRKDUprankDouble" or "cfgRKDUprankSingle"):format(s1, s2);
	elseif rtype == "modrank" then
		return lang("cfgRKDModrank"):format(s1, s2 or "");
	end
end
local function RKCD_SelectRingEntry(self)
	local eid = self:GetParent():GetID();
	if GetCursorInfo() then
		RKCD_InsertFromCursor(self, eid);
	elseif RK_SelectedRingEntryID == eid then
		return RKCD_ClearSelection();
	end
	RK_SelectedRingEntryID = eid;

	if RK_SelectedRingEntry ~= nil then
		RK_SelectedRingEntry:SetChecked(nil);
	end
	self:SetChecked(1);
	RK_SelectedRingEntry = self;

	RKCD_EntryByName:Hide();
	RKCD_MacroBG:Hide();
	RKCD_UseExactRank:Hide();
	RKCD_OnlyWhilePresent:Hide();

	local rtype, id, id2 = desc[eid].rtype or "uprank", desc[eid].id, desc[eid].id2;
	if rtype == "uprank" or rtype == "modrank" then
		RKCD_SpellDetail:SetText(RKCD_GetSpellDescription(rtype, desc[eid].erank, id, id2));
		RKCD_UseExactRank:SetChecked(desc[eid].erank and 1 or nil);
		RKCD_UseExactRank:Show();
	elseif rtype == "item" or rtype == "nitem" then
		RKCD_SpellDetail:SetFormattedText(lang("cfgRKDItem"), select(2, GetItemInfo(id)) or ("#" .. id));
		RKCD_EntryByName:Show();
		RKCD_EntryByName:SetChecked(rtype == "nitem" and 1 or nil);
		RKCD_OnlyWhilePresent:Show();
		RKCD_OnlyWhilePresent:SetChecked(desc[eid].onlyWhilePresent and 1 or nil);
	elseif rtype == "macro" then
		RKCD_SpellDetail:SetFormattedText(lang("cfgRKDMacro"), GetMacroInfo(id) or ("#" .. id));
	elseif rtype == "mount" then
		RKCD_SpellDetail:SetText(lang("cfgRKDMount"));
	elseif rtype == "companion" then
		RKCD_SpellDetail:SetFormattedText(lang("cfgRKDCompanion"), GetSpellInfo(id));
		RKCD_OnlyWhilePresent:Show();
		RKCD_OnlyWhilePresent:SetChecked(desc[eid].onlyWhilePresent and 1 or nil);
	elseif rtype == "macrotext" then
		RKCD_SpellDetail:SetText("");
		RKCD_MacroBG:Show();
		RKCD_EntryMacro:SetText(id or "");
		RKCD_MacroScroll:SetVerticalScroll(0);
	end

	RKCD_EntryDetail:Show();
	RKC_RingDetail:Hide();
	RKCD_SliceHint:Hide();
end
local function RKCD_ButtonDrag(self)
	if GetCursorInfo() then
		RKCD_SelectRingEntry(self:GetParent().ico);
	end
end
local function RKCD_SelectRingEntryByID(id)
	local bi = id-RK_ElementOffset+1;
	if not RKCD_Buttons[bi] then
		if bi <= 0 then
			RK_ElementOffset, bi = id, 1;
		else
			RK_ElementOffset, bi = math.max(1, id - #RKCD_Buttons + 1), #RKCD_Buttons;
		end
		RKCD_UpdateDisplay();
	end
	RKCD_SelectRingEntry(RKCD_Buttons[bi].ico);
end
local function RKCD_RemoveRingEntry(self)
	if RK_SelectedRingEntry then
		local id = RK_SelectedRingEntryID;
		table.remove(desc, id);
		RKCD_ClearSelection();
		RKCD_UpdateDisplay();
	end
end
local function RKC_RingAuthor()
	return ("%s-%s-%s"):format(GetCVar("realmList"):match("^([^.]+)"):upper(), GetRealmName(), UnitName("player"));
end
local function RKC_DoAddNew()
	local eb = _G[this:GetParent():GetName().."EditBox"];
	local name = eb:GetText(); eb:SetText("");
	local kn = name:gsub("%s", "");
	if name == "" or kn == "" then return; end
	RK_SelectedRing = RingKeeper:GenFreeRingName(kn);
	local okay, author = pcall(RKC_RingAuthor);
	RK_cInstance[#RK_cInstance+1], RK_cInstance[RK_SelectedRing] = RK_SelectedRing, {name=name, isNewConfigRing=true, author=okay and author or nil};
	RKC_SelectRing(#RK_cInstance, #RK_cInstance); -- wrathAPI workaround.
	StaticPopup_Hide("RK_NAMEPROMPT");
end
local function RKC_SelectNew()
	local prompt = StaticPopupDialogs["RK_NAMEPROMPT"];
	prompt.text, prompt.OnAccept, prompt.EditBoxOnEnterPressed = lang("cfgRKNewName"), RKC_DoAddNew, RKC_DoAddNew;
	StaticPopup_Show("RK_NAMEPROMPT");
end
local function RKCD_ChangeByName(self)
	desc[RK_SelectedRingEntryID].rtype = self:GetChecked() and "nitem" or "item";
end
local function RKCD_ChangeWhenPresent(self)
	desc[RK_SelectedRingEntryID].onlyWhilePresent = self:GetChecked() and true or nil;
end
local function RKCD_ChangeExactRank(self)
	local id = RK_SelectedRingEntryID;
	desc[id].erank = self:GetChecked() and true or nil;
	RK_SelectedRingEntryID = nil;
	RKCD_SelectRingEntryByID(id);
end
local function RKC_ChangeLimitToMe(self)
	desc.limitToChar = self:GetChecked() and UnitName("player") or nil;
end
local function RKC_ChangeLimitToClass(self)
	desc.class = self:GetChecked() and select(2,UnitClass("player")) or nil;
end
local function RKC_ChangeRingOffset(self)
	desc.offset = self:GetValue() % 360;
	if desc.offset == 0 then desc.offset = nil; end
	RKC_RingOffsetText:SetFormattedText(lang("cfgRKRotate"), desc.offset or 0);
end
local function RKCD_ShiftDisplay(self)
	RK_ElementOffset = math.max(1, RK_ElementOffset+self:GetID()-2);
	RKCD_UpdateDisplay();
end
local function RKCD_StrayClick(self)
	local _, y = GetCursorPosition();
	local scale, _, b, _, h = RKCD_Buttons[1]:GetEffectiveScale(), RKCD_Buttons[1]:GetRect();
	y = y / scale;
	if y <= (b+h+5) and y >= (b-5) and GetCursorInfo() then
		RKCD_InsertFromCursor(self, #desc+1);
	end
end
local function RKCD_NameSet(self, key)
	if self:GetText():gsub("%s", "") == "" then return; end
	desc.name = self:GetText();
	self:ClearFocus();
end
local function RKCD_NameForget(self)
	self:SetText(desc.name or RK_SelectedRing);
	self:ClearFocus();
end
local function RKCD_SaveRing(rid, saveOnly)
	if rid == RKCD_Save then
		rid = RK_SelectedRingID;
	end
	if rid == -1 then
		RKCD_SaveNewRing(desc.name:gsub("%s", ""));
		rid = #RK_cInstance;
	end
	local v = RK_cInstance[rid];
	if RK_cInstance[v].isNewConfigRing then
		RK_cInstance[v].isNewConfigRing, RK_cInstance[v].save = nil, true;
		RingKeeper:AddRing(v, RK_cInstance[v]);
	elseif v then
		RingKeeper:ModifyRing(v, RK_cInstance[v]);
	end
	RKCD_EntryMacro:ClearFocus();
	if saveOnly ~= true then
		RK_cInstance[v] = RingKeeper:GetRingDescription(v);
		if RK_SelectedRing == v then
			desc = RK_cInstance[v];
		end
		RKCD_UpdateDisplay();
	end
end
local function RKCD_DeleteRing(self)
	if RK_SelectedRing then
		RK_cInstance[RK_SelectedRing] = "remove";
		table.remove(RK_cInstance, RK_SelectedRingID);
		RKC_ClearSelection();
	end
end
local function RKCD_MacroTextEdit(self)
	desc[RK_SelectedRingEntryID].id = self:GetText();
end
local function RKCD_AddEntry_Do(self, etype)
	if not wrathAPI then etype = self; end
	table.insert(desc, RK_ElementOffset or 1, {rtype=etype, id=(etype == "macrotext" and "" or nil), r=0, g=1, b=0.3});
	RKCD_UpdateDisplay();
	RKCD_SelectRingEntryByID(RK_ElementOffset or 1);
end
local function RKCD_AddEntry_Menu(level)
	if level == 1 then
		local info = UIDropDownMenu_CreateInfo();
		info.func, info.text, info.arg1 = RKCD_AddEntry_Do, lang("cfgRKDMount"), "mount";
		UIDropDownMenu_AddButton(info);
		info.text, info.arg1 = lang("cfgRKDCustomMacro"), "macrotext";
		UIDropDownMenu_AddButton(info);
	end
end
local function RKCD_EntryMove(self)
	local dir, sel = self:GetID()-2, RK_SelectedRingEntryID;
	if desc[sel + dir] then
		desc[sel + dir], desc[sel] = desc[sel], desc[sel+dir];
		RK_SelectedRingEntryID = sel + dir;
		RKCD_UpdateDisplay();
	end
end
local function RKC_ShareRing(self)
	local p = RKC_SharePlayerName:GetText();
	if p ~= "" and p:match("^[^%d%s]+$") then
		RingKeeper:SendRing(RK_SelectedRing, p);
		RKC_SharePlayerName:ClearFocus();
		RKC_SharePlayerName:SetText("");
	else
		RKC_SharePlayerName:SetFocus();
	end
end

-- Action Hinting
local function RKC_PopHintList(offset)
	if type(offset) == "table" then
		offset = math.floor(offset:GetValue()/42)*7+1;
	else
		RKCD_SliceScroll:SetVerticalScroll(math.floor(offset/7)*42);
	end
	local n = GetNumMacroIcons();
	offset = math.min(math.max(1, offset or 1), n-14);
	for j=offset,n do
		local i, ico = j-offset+1, GetMacroIconInfo(j);
		if not RKCD_IconButtons[i] then break; end
		RKCD_IconButtons[i].icon:SetTexture(ico);
		RKCD_IconButtons[i]:SetChecked(ico == desc[RK_SelectedRingEntryID].icon and 1 or nil);
		RKCD_IconButtons[i]:Show();
	end
	for j=n+1,offset+#RKCD_IconButtons do
		OneRing.xlu.print(j .. " " .. offset);
		RKCD_IconButtons[j-offset]:Hide();
	end
	RKCD_SliceIconBar:SetMinMaxValues(0, math.ceil((n - #RKCD_IconButtons + 1) / 7) * 42);
end
local function RKC_HintIconSet(self)
	desc[RK_SelectedRingEntryID].icon = self:GetChecked() and self.icon:GetTexture() or nil;
	for k,v in pairs(RKCD_IconButtons) do
		v:SetChecked(v == self and 1 or nil);
	end
end
local function RKC_HintCaptionSave(self)
	local text = self:GetText();
	desc[RK_SelectedRingEntryID].caption = text ~= "" and text or nil;
	self:ClearFocus();
end
local function RKC_HintCaptionRestore(self)
	self:SetText(desc[RK_SelectedRingEntryID].caption or "");
	self:ClearFocus();
end
local function RKC_ShowHintConfig(self)
	RKCD_SliceHint:Show();
	RKCD_SliceCaptionInput:SetText(desc[RK_SelectedRingEntryID].caption or "");
	self:GetParent():Hide();
	local offset, icon = 0, desc[RK_SelectedRingEntryID].icon;
	if icon then
		for i=1,GetNumMacroIcons() do
			if GetMacroIconInfo(i) == icon then
				offset = 1 + math.floor(i/7)*7;
				break;
			end
		end
	end
	RKC_PopHintList(offset);
end
local function RKC_ReturnToEntryDetail(self)
	RKCD_SliceHint:Hide();
	RKCD_EntryDetail:Show();
end

local function RKC_CopyConfig()
	if RK_cInstance == nil then
		RK_cInstance = {};
		for i=1,RingKeeper:GetManagedRings() do
			local index, name, active = RingKeeper:GetManagedRingName(i);
			if active then
				table.insert(RK_cInstance, index);
				RK_cInstance[index] = RingKeeper:GetRingDescription(index);
			end
		end
	end
end
local function RKC_OnShow()
	RK_SelectedRing = nil; RKC_Detail:Hide();
	RKC_Version:SetFormattedText("%d.%d", RingKeeper:GetVersion());
	RKC_ConfigIntro:SetText(lang("cfgRKIntro"));
	RKCD_Remove:SetText(lang("cfgRKDRemove"));
	RKCD_Save:SetText(lang("cfgRKDSave"));
	RKC_CreateNewRing:SetText(lang("cfgRKNewRing"));
	RKCD_RemoveRing:SetText(lang("cfgRKDRemoveRing"));
	RKCD_Instruct:SetText(lang("cfgRKDInstructions"));
	RKCD_EntryByNameText:SetText(lang("cfgRKDByName"));
	RKCD_OnlyWhilePresentText:SetText(lang("cfgRKDWhilePresent"));
	RKCD_ExactRankText:SetText(lang("cfgRKDExactRank"));
	RKC_LimitToMeText:SetText(lang("cfgRKOnlyForMe"));
	RKC_LimitToClassText:SetText(lang("cfgRKOnlyForMyClass"))
	RKC_ShareText:SetText(lang("cfgRKShareWith"));
	RKC_ShareDo:SetText(lang("cfgRKShare"));
	RKCD_SliceCaption:SetText(lang("cfgRKSliceCaption"));
	RKCD_EntryAlterHint:SetText(lang("cfgRKModifyHint"));
	RKCD_EntryBackToDetail:SetText(lang("cfgRKBackToDetail"));
	RKC_Frame.name = lang("cfgRKTitle");
	ConfigTitle:SetText(RKC_Frame.name);
	RKC_ClearSelection();
	RKC_CopyConfig();
end

local function RKC_RevertSettings()
	RK_cInstance = nil; -- and the rest will follow.
end
local function RKC_SaveSettings()
	for i, v in ipairs(RK_cInstance) do
		RKCD_SaveRing(i, true);
		RK_cInstance[v] = nil;
	end
	for k, v in pairs(RK_cInstance) do
		if type(k) == "string" and v == "remove" then
			RingKeeper:RemoveRing(k);
		end
	end
	RK_cInstance = nil;
end
local function RKC_DefaultSettings()
	RingKeeper:RestoreDefaults();
	RK_cInstance = nil;
end
RKC_Frame.refresh = RKC_OnShow;

local function RKC_AdjustOptionsPosition(self)
	local r = InterfaceOptionsFrame:IsVisible() and RKC_Frame:IsVisible() and math.max(SpellBookFrame:IsVisible() and SpellBookFrame:GetRight() or 0, MacroFrame and MacroFrame:IsVisible() and MacroFrame:GetRight() or 0) or 0;
	if not InterfaceOptionsFrame:IsUserPlaced() then
		local tdiff = (InterfaceOptionsFrame:GetWidth() - UIParent:GetWidth())/2 + r+5;
		InterfaceOptionsFrame:ClearAllPoints();
		InterfaceOptionsFrame:SetPoint("CENTER", math.max(tdiff, 0), 0);
	end
end
local function RKC_MacroListen(event, addon)
	if event == "ADDON_LOADED" and MacroFrame and MacroFrame.HookScript then
		MacroFrame:HookScript("OnShow", RKC_AdjustOptionsPosition);
		MacroFrame:HookScript("OnHide", RKC_AdjustOptionsPosition);
		return "remove";
	end
end

-- Functions below are mostly a copy of OneRingConfig; this really should be shared, somehow.
local mouseTranslation = {["RightButton"]="BUTTON2", ["MiddleButton"]="BUTTON3", ["Button4"]="BUTTON4", ["Button5"]="BUTTON5"};
local function ORC_BindingDisarm(btn)
	btn:UnlockHighlight(); btn:SetScript("OnKeyDown", nil); btn:EnableKeyboard(false);
end
local function ORC_BindingListen(self, arg1)
	if not (arg1:match("^[LR]?ALT$") or arg1:match("^[LR]?CTRL$") or arg1:match("^[LR]?SHIFT$")) then
		if arg1 ~= "ESCAPE" then
			local bind = (IsAltKeyDown() and "ALT-" or "") ..  (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "") .. arg1;
			desc.hotkey = bind ~= "CTRL-BACKSPACE" and bind or nil;
			self:SetText(ORC_BindingFormat(desc.hotkey));
		end
		ORC_BindingDisarm(self);
	end
end
local function ORC_BindingClick(self, button)
	if self:IsKeyboardEnabled() then
		if mouseTranslation[button] then return ORC_BindingListen(self, mouseTranslation[button])
		else return ORC_BindingDisarm(self);
		end
	end
	self:SetScript("OnKeyDown", ORC_BindingListen); self:EnableKeyboard(true);
	self:SetScript("OnHide", ORC_BindingDisarm); self:LockHighlight();
end


	RKC_Frame:SetScript("OnShow", RKC_OnShow);
	RKC_Frame:HookScript("OnShow", RKC_AdjustOptionsPosition);
	RKC_Frame:SetScript("OnHide", RKC_AdjustOptionsPosition);
	RKC_Frame.cancel, RKC_Frame.okay, RKC_Frame.default = RKC_RevertSettings, RKC_SaveSettings, RKC_DefaultSettings;
	UIDropDownMenu_Initialize(RKC_RingDropdown, RKC_RingDropdownMenu);
	RKCD_Name:SetScript("OnEscapePressed", RKCD_NameForget);
	RKCD_Name:SetScript("OnEnterPressed", RKCD_NameSet);
	RKCD_Prev:SetScript("OnClick", RKCD_ShiftDisplay);
	RKCD_Next:SetScript("OnClick", RKCD_ShiftDisplay);
	for k, v in ipairs(RKCD_Buttons) do
		v.color:SetScript("OnClick", RKCD_ChangeColor);
		v.ico:SetScript("OnClick", RKCD_SelectRingEntry);
		v.ico:SetScript("OnReceiveDrag", RKCD_ButtonDrag);
		v.color:SetScript("OnReceiveDrag", RKCD_ButtonDrag);
	end
	RKC_Detail:SetScript("OnMouseDown", RKCD_StrayClick);
	RKC_Detail:SetScript("OnReceiveDrag", RKCD_StrayClick);
	RKC_Detail:EnableMouse(true);
	RKCD_Remove:SetScript("OnClick", RKCD_RemoveRingEntry);
	RKCD_Save:SetScript("OnClick", RKCD_SaveRing);
	RKCD_RemoveRing:SetScript("OnClick", RKCD_DeleteRing);
	SpellBookFrame:HookScript("OnShow", RKC_AdjustOptionsPosition);
	SpellBookFrame:HookScript("OnHide", RKC_AdjustOptionsPosition);
	RKCD_Hotkey:SetScript("OnClick", ORC_BindingClick);
	RKCD_Hotkey:RegisterForClicks("AnyUp");
	RKCD_EntryByName:SetScript("OnClick", RKCD_ChangeByName);
	RKCD_OnlyWhilePresent:SetScript("OnClick", RKCD_ChangeWhenPresent);
	RKCD_UseExactRank:SetScript("OnClick", RKCD_ChangeExactRank);
	UIDropDownMenu_Initialize(RKCD_AddEntryMenu, RKCD_AddEntry_Menu, "MENU");
	RKCD_AddEntry:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, RKCD_AddEntryMenu, "cursor"); end);
	RKCD_EntryMacro:SetScript("OnEscapePressed", function(self) self:ClearFocus() end);
	RKCD_EntryMacro:SetScript("OnTextChanged", RKCD_MacroTextEdit);
	RKCD_EntryMoveLeft:SetScript("OnClick", RKCD_EntryMove);
	RKCD_EntryMoveRight:SetScript("OnClick", RKCD_EntryMove);
	RKC_ShareDo:SetScript("OnClick", RKC_ShareRing);
	RKC_OnlyThisChar:SetScript("OnClick", RKC_ChangeLimitToMe);
	RKC_OnlyThisClass:SetScript("OnClick", RKC_ChangeLimitToClass);
	RKC_OffsetSlider:SetScript("OnValueChanged", RKC_ChangeRingOffset);
	RKC_CreateNewRing:SetScript("OnClick", RKC_SelectNew);
	RKCD_EntryAlterHint:SetScript("OnClick", RKC_ShowHintConfig);
	RKCD_SliceIconBar:SetScript("OnValueChanged", RKC_PopHintList);
	RKCD_SliceCaptionInput:SetScript("OnEnterPressed", RKC_HintCaptionSave);
	RKCD_SliceCaptionInput:SetScript("OnEscapePressed", RKC_HintCaptionRestore);
	RKCD_EntryBackToDetail:SetScript("OnClick", RKC_ReturnToEntryDetail);
	for i, b in pairs(RKCD_IconButtons) do b:SetScript("OnClick", RKC_HintIconSet); end
	EC_Register("ADDON_LOADED", "RKC.MacroListen", RKC_MacroListen);

SLASH_RINGKEEPER1, SLASH_RINGKEEPER2 = "/ringkeeper", "/rk";
local ShowPanel = wrathAPI and InterfaceOptionsFrame_OpenToCategory or InterfaceOptionsFrame_OpenToFrame;
SlashCmdList["RINGKEEPER"] = function (args)
	if not RKC_Frame:IsVisible() then
		ShowPanel(RKC_Frame);
	end
end