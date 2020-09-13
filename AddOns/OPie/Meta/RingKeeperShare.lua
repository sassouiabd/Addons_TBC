local OneRing = _G.OneRingLib;
local lang, print, RingKeeper = OneRing.lang, OneRing.xlu.print, OneRing.RingKeeper;

local infoTip = CreateFrame("Frame", nil, UIParent);
	infoTip:SetFrameStrata("TOOLTIP"); infoTip:SetWidth(220); infoTip:SetHeight(90);
	infoTip:SetMovable(true);	infoTip:SetPoint("CENTER"); infoTip:Hide(); infoTip:EnableMouse(true);
	infoTip:SetScript("OnMouseDown", infoTip.StartMoving);
	infoTip:SetScript("OnMouseUp", infoTip.StopMovingOrSizing);
	infoTip:SetScript("OnHide", infoTip.StopMovingOrSizing);
	infoTip:SetBackdrop(GameTooltip:GetBackdrop());
	infoTip:SetBackdropColor(0.1,0.1,0.1);
	infoTip:SetBackdropBorderColor(0.7,0.7,0.8);
	local close = CreateFrame("Button", nil, infoTip, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT");
local rname = infoTip:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	rname:SetPoint("TOPLEFT", 6, -6); 	rname:SetPoint("TOPRIGHT", -40, -6); rname:SetJustifyH("LEFT");
local rdesc = infoTip:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	rdesc:SetPoint("TOPLEFT", rname, "BOTTOMLEFT", 0, -2); rdesc:SetJustifyH("LEFT"); rdesc:SetJustifyV("TOP");
local accept = CreateFrame("Button", "RKS_AcceptRing", infoTip, "UIPanelButtonTemplate2");
	accept:SetPoint("BOTTOMRIGHT", -5, 7); accept:SetWidth(100);
local reject = CreateFrame("Button", "RKS_RejectRing", infoTip, "UIPanelButtonTemplate2");
	reject:SetPoint("BOTTOMLEFT", 6, 7); reject:SetWidth(100);

local okMsg, neutralMsg, failMsg = "|c0022ff22%s|r", "|c000088ff%s|r", "|c00ffbb00%s|r";

local function RKS_SetTransferInfo(id)
	local direction, player, started, title, total, done = RingKeeper:GetTransferInfo(id);
	if not direction then return; end
	rname:SetText(title);
	accept:SetText(lang:GetString("shareAccept"));
	reject:SetText(lang:GetString("shareReject"));
	if direction == "IN" then
		rdesc:SetFormattedText(lang:GetString("shareIN"), player, done, total, math.ceil(total/2));
		accept:Show(); reject:Show();
	else
		rdesc:SetFormattedText(lang:GetString("shareOUT"), player, done, total, math.ceil(total/2));
	end
	local s = direction == "IN" and not started;
	accept[s and "Show" or "Hide"](accept);
	reject[s and "Show" or "Hide"](reject);
	infoTip.id = id;
	infoTip:Show();
end
reject:SetScript("OnClick", function(self)
	self:GetParent():Hide();
	RingKeeper:AcceptRing(self:GetParent().id, false);
end);
accept:SetScript("OnClick", function(self)
	RingKeeper:AcceptRing(self:GetParent().id, true); accept:Hide(); reject:Hide();
end);

local oldItemRef = SetItemRef;
function SetItemRef(link, text, button, ...)
	local lid = tostring(link):match("^rkshare:(%x+)$");
	if lid then	return RKS_SetTransferInfo(lid); end
	return oldItemRef(link, text, button, ...);
end


local eh = {}; -- (event handlers table)
function eh:Request(id, player, name, title)
	print(lang:GetString("shareRequest", neutralMsg), player, "rkshare:" .. id, title or name);
end
function eh:Accepted(id, player, title)
	print(lang:GetString("shareAccepted", okMsg), player, "rkshare:" .. id, title);
end
function eh:Rejected(id, player, title)
	print(lang:GetString("shareRejected", failMsg), player, title or "#!@$");
	if infoTip.id == id then infoTip:Hide(); end
end
function eh:Data(id, done, total)
	if id == infoTip.id and infoTip:IsVisible() then
		RKS_SetTransferInfo(id);
	end
end
function eh:Complete(id, direction, player, ring)
	if direction == "OUT" then
		print(lang:GetString("shareComplete", okMsg), player, ring or "!@#!");
	elseif direction == "IN" then
		print(lang:GetString("shareCompleteIN", okMsg), ring or "!@#!", player);
	end
	if infoTip.id == id then infoTip:Hide(); end
end
function eh:Failed(id, direction, player, ring, reason)
	if direction == "OUT" then
		print(lang:GetString("shareFailed", failMsg), player, ring or "!@#!");
	elseif direction == "IN" then
		print(lang:GetString("shareFailedIN", failMsg), ring or "!@#!", player, reason or "dog ate it");
	end
	if infoTip.id == id then infoTip:Hide(); end
end

local function UpdateEvent(e, event, ...)
	if eh[event] then
		eh[event](eh, ...);
	end
end

EC_Register("RK.Transfer", "RK.Sharing.Events", UpdateEvent);