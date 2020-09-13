local OneRing, ADDON_NAME = _G.OneRingLib, "OPie";
local assert = OneRing.xlu.assert;

local lockedLocales, desiredLocale, localeTables, localeCache, lang = {}, GetLocale(), {}, {}, {};
function lang:GetLocale()
	return desiredLocale;
end
function lang:SetLocale(locale)
	assert(type(locale) == "string", "Usage: OneRingLang:SetLocale(\"locale\");", 2);
	if desiredLocale ~= locale then
		desiredLocale, OPie_Locale, localeCache = locale, locale, {};
	end
end
function lang:GetString(token, format)
	assert(type(token) == "string" and (format == nil or type(format) == "string"), "Usage: OneRingLang:GetString(\"token\"[, \"format\"]);", 2);
	if not localeCache[token] then
		localeCache[token] = localeTables[desiredLocale] and localeTables[desiredLocale][token] or localeTables.enUS[token] or ("#" .. token .. "#");
	end
	return format and format:format(localeCache[token]) or localeCache[token];
end
function lang:AddLocalization(lang, data, lock)
	assert(type(lang) == "string" and type(data) == "table", "Usage: OneRingLang:AddLocalization(\"locale\", localizationTable)", 2);
	assert(not lockedLocales[lang], "Locale %q is already available and locked.", 2, lang);
	localeTables[lang], lockedLocales[lang] = data, lock == true;
end
EC_Register("ADDON_LOADED", "OPie.Locale.Loaded", function(e, a)
	if a == ADDON_NAME and type(OPie_Locale) == "string" and localeTables[OPie_Locale] then
		lang:SetLocale(OPie_Locale);
	end
end);
setmetatable(lang, {__call=lang.GetString});
OneRing.lang = lang;

--[[
	Official enUS locale follows.

	Localization should be handled through downloadable, third-party plug-ins.
	If you're a localization author, see http://www.go-hero.net/opie/api/localize for a description and instructions.
]]
lang:AddLocalization("enUS", {
	title="OPie",
	locale="English (EU-ED-Atreju)",

	cfgMainIntro="Customize indication options; right click on a checkbox to set to default (or global) value.",
	cfgGlobalDomain="Defaults for all rings",
	cfgDomain="Alter options for:",
	cfgRingDomain="Ring: |cffaaffff%s|r (%d entries)",
	cfgRingAtMouse="Show rings at mouse location (vs screen center)",
	cfgShowPointer="Show mouse cursor",
	cfgShowIcons="Action icons",
	cfgShowCooldowns="Cooldowns",
	cfgShowCaptions="Action captions",
	cfgDimScreen="Dim screen",
	cfgMultiIndication="Multiple icons",
	cfgIndication="Indication elements",
	cfgClickActivation="Activate on left click",
	cfgHideStanceBar="Hide Shapeshift bar",
	cfgShowStanceBar="Show Shapeshift bar",
	cfgIndicationOffset="Position offset:",
	cfgRingScale="Ring Scale (%0.1f)",

	cfgBindingTitle="Ring Bindings",
	cfgBindingIntro="Customize ring hotkey bindings below; |cff808080gray bindings|r conflict with others and are not bound.",
	cfgBinding="Binding",
	cfgContent="Contents",
	cfgNoBinding="Not bound",
	cfgNoContent="Empty ring",
	cfgName="Ring Name",
	cfgUnbind="Unbind Ring",

	cfgRKTitle="Custom Rings",
	cfgRKIntro="Create, modify and share rings containing abilities, items and macros.",
	cfgRKSelectARing="Select a ring",
	cfgRKNewRing="New Ring...",
	cfgRKNewName="New ring name:",
	cfgRKDSave="Save",
	cfgRKDRemove="Remove",
	cfgRKDHotkey="Default hotkey",
	cfgRKDRemoveRing="Delete",
	cfgRKDUprankSingle="Spell: |cff0077ff%s|r",
	cfgRKDUprankDouble="Spell: |cff0077ff%s|r or |cff0077ff%s|r",
	cfgRKDModrank="Spells: |cff0077ff%s|r or |cff0077ff%s|r (hold a mod key)",
	cfgRKDItem="Item: %s",
	cfgRKDMacro="Macro: %s",
	cfgRKDCompanion="Companion: |cff77aaff%s|r",
	cfgRKDMount="Automatic Mount macro",
	cfgRKDCustomMacro="Custom macros",
	cfgRKDCMacro="Custom Macro",
	cfgRKDInstructions="Drop items, macros and spells into the area immediately below to add them to the ring, or select a ring entry to modify.",
	cfgRKDByName="Also use items with the same name",
	cfgRKDExactRank="Use specified rank instead of max rank",
	cfgRKOnlyForMe="Only show this ring on this character",
	cfgRKOnlyForMyClass="Only show this ring on character of my class",
	cfgRKRotate="Rotation (%d\194\176)",
	cfgRKShareWith="Share with:",
	cfgRKShare="Share",
	cfgRKSliceCaption="Slice Caption:",
	cfgRKModifyHint="Set Text/Icon",
	cfgRKBackToDetail="View slice detail",
	cfgRKDWhilePresent="Show slice only while object is present",

	shareRequest="[OPie] %s wants to send you |H%s|h|c00aa44ff[%s Ring]|r|h.",
	shareAccepted="[OPie] %s accepted transfer, sending data: |H%s|h|c00aa44ff[%s Ring]|r|h",
	shareRejected="[OPie] %s did not accept shared %s ring.",
	shareComplete="[OPie] %s received [%s Ring] successfully.",
	shareCompleteIN="[OPie] Received [%s Ring] from %s successfully.",
	shareFailed="[OPie] %s failed to receive shared ring: %s.",
	shareFailedIN="[OPie] Failed to receive shared ring %s from %s: %s.",
	shareAccept="Accept",
	shareReject="Reject",
	shareIN="Offered by: %s\n%d / %d lines received\nEstimated transfer time: %d sec",
	shareOUT="Offered to: %s\n%d / %d lines sent\nEstimated transfer time: %d sec",

	cfgMetaAnimTitle="Animations",
	cfgMAIntro="This panel allows you to customize animations OPie uses while displaying action selection and multiple indication UI.",
	cfgMAOptionDesc_MIDisjoint = "Unlink indication animation from pointer animation",
	cfgMAOptionDesc_MIAlpha = "Use alpha animation instead of scale animation",
	cfgMAOptionDesc_MIBlend = "Translucent spell icons (with no ButtonFacade)",
	cfgMAOptionDesc_MIScale0 = "Scale delta when nothing is selected",
	cfgMAOptionDesc_MIScale1 = "Scale delta for icons close to pointer",
	cfgMAOptionDesc_MIScale2 = "Scale delta for selected icon",
	cfgMAOptionDesc_XTScaleSpeed = "Scale animation speed (lg)",
	cfgMAOptionDesc_XTPointerSpeed = "Pointer movement speed (lg)",
	cfgMAOptionDesc_XTZoomTime = "Zoom-in/out time (s)",
}, true);