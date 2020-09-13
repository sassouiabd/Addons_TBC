local wrathAPI = select(4,GetBuildInfo()) >= 30000;
local OneRing = _G.OneRingLib;
local lang, options = OneRing.lang, {
	{"bool", "MIDisjoint"},
	{"bool", "MIAlpha"},
	{"bool", "MIBlend"},
	{"range", "MIScale0", -.9, 0, dependOption="MIAlpha", dependValue=false},
	{"range", "MIScale1", -1, 1, dependOption="MIAlpha", dependValue=false},
	{"range", "MIScale2", -1, 1, dependOption="MIAlpha", dependValue=false},
	{"range", "XTScaleSpeed", -4, 4, dependOption="MIAlpha", dependValue=false},
	{"range", "XTPointerSpeed", -4, 4},
	{"range", "XTZoomTime", 0, 1},
};
if not wrathAPI then options[#options] = nil; table.remove(options, 3); end

-- Build Configuration dialog frames/widgets for OneRing
local function SetDimensions(frame, w, h)
	frame:SetWidth(w); frame:SetHeight(h or w);
end
local ConfigFrame = CreateFrame("Frame", "OneRing_AnimationConfig", UIParent);
	SetDimensions(ConfigFrame, 350, 400); ConfigFrame:SetPoint("CENTER"); ConfigFrame:Hide();
	ConfigFrame.name, ConfigFrame.parent = lang("cfgMetaAnimTitle"), lang("title");
	InterfaceOptions_AddCategory(ConfigFrame);
local ConfigTitle = ConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	ConfigTitle:SetText(ConfigFrame.name); SetDimensions(ConfigTitle, 340, 20);
	ConfigTitle:SetPoint("TOPLEFT", 15, -14); ConfigTitle:SetJustifyH("LEFT");
local ConfigIntro = ConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	SetDimensions(ConfigIntro, 360, 0); ConfigIntro:SetPoint("TOPLEFT", ConfigTitle, "BOTTOMLEFT");
	ConfigIntro:SetText("Animation."); ConfigIntro:SetJustifyH("LEFT");

local sliderExt, sliderReal, sliderExtMeta = {}, {};
function sliderExt:Enable()
	self.caption:SetFontObject(GameFontNormal);
	self.lockValue = nil;
end
function sliderExt:Disable()
	self.caption:SetFontObject(GameFontDisable);
	self.lockValue = self:GetValue();
end
function sliderExt:SetMinMaxValues(min, max)
	sliderReal.SetMinMaxValues(self, min, max);
	self.min:SetText(min); self.max:SetText(max);
end
function wrapSlider(widget)
	if not sliderRealMeta then
		local realMeta = getmetatable(widget);
		sliderReal = realMeta.__index;
		sliderExtMeta = setmetatable({__index=sliderExt}, {__index=realMeta});
		setmetatable(sliderExt, {__index=sliderReal});
	end
	setmetatable(widget, sliderExtMeta);
	local name = widget:GetName();
	if name then
		widget.min, widget.max, widget.caption = _G[name.."Low"], _G[name.."High"], _G[name.."Text"];
	end
	return widget;
end

local controls = {};
do
	local ydelta, prefix = 20, "ORC_Anim_";
	for i=1,#options do
		local name = prefix..options[i][2];
		if options[i][1] == "bool" then
			controls[i] = CreateFrame("CheckButton", name, ConfigFrame, "InterfaceOptionsCheckButtonTemplate");
			controls[i]:SetPoint("TOPLEFT", ConfigIntro, "BOTTOMLEFT", 5, -ydelta);
			controls[i].caption = _G[name.."Text"];
			ydelta = ydelta + 22;
		elseif options[i][1] == "range" then
			controls[i] = wrapSlider(CreateFrame("Slider", name, ConfigFrame, "OptionsSliderTemplate"));
			controls[i]:SetWidth(300);
			controls[i]:SetPoint("TOPLEFT", ConfigIntro, "BOTTOMLEFT", 35, -ydelta-15);
			controls[i]:SetMinMaxValues(options[i][3], options[i][4]);
			controls[i]:SetValueStep((options[i][4]-options[i][3])/20);
			controls[i]:Enable();
			ydelta = ydelta + 40;
		end
		controls[i]:SetID(i);
	end
end
-- Configuration UI construction [end]

local changesLocked = false;
local function updateControlStates()
	for i=1,#options do
		if options[i].dependOption then
			local e, c = OneRing:GetOption(options[i].dependOption) == options[i].dependValue, controls[i];
			c[e and "Enable" or "Disable"](c);
		end
	end
end
local function CTL_OnValueChanged(self)
	if changesLocked then return; end

	local id = self:GetID();
	local otype, oname = options[id][1], options[id][2];

	if otype == "bool" then
		OneRing:SetOption(oname, self:GetChecked() == 1);
	elseif otype == "range" then
		if self.lockValue then
			self:SetValue(self.lockValue);
		else
			OneRing:SetOption(oname, self:GetValue());
			self.caption:SetText(("%s (%0.3f)"):format(lang("cfgMAOptionDesc_" .. oname), self:GetValue()));
		end
	end
	updateControlStates();
end

function ConfigFrame.refresh()
	if ConfigFrame.isActive then return; end
	ConfigIntro:SetText(lang("cfgMAIntro"));
	changesLocked = true;
	for i=1,#options do
		local etype, oname, label = options[i][1], options[i][2];
		local label, value = lang("cfgMAOptionDesc_" .. oname), OneRing:GetOption(oname);
		controls[i].value = value;
		if etype == "bool" then
			controls[i]:SetChecked(controls[i].value and 1 or nil);
			controls[i].caption:SetText(label)
		elseif etype == "range" then
			controls[i]:SetValue(controls[i].value);
			controls[i].caption:SetText(("%s (%0.3f)"):format(label, controls[i].value));
		end
	end
	updateControlStates();
	ConfigFrame.isActive, changesLocked = true, false;
end
function ConfigFrame.cancel()
	for i=1,#options do
		OneRing:SetOption(options[i][2], controls[i].value);
	end
	ConfigFrame.isActive = false;
end
function ConfigFrame.okay()
	-- Changes are live, so we don't need to do anything
	ConfigFrame.isActive = false;
end
function ConfigFrame.default()
	for i=1,#options do
		OneRing:SetOption(options[i][2], nil);
	end
	ConfigFrame.isActive = false;
	ConfigFrame.refresh();
end

for i=1,#controls do
	controls[i]:SetScript(options[i][1] == "bool" and "OnClick" or "OnValueChanged", CTL_OnValueChanged);
end

ConfigFrame:SetScript("OnShow", ConfigFrame.refresh);