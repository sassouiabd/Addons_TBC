local frame = CreateFrame("Frame")
local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience
log("|c64FE2E0ASchakaPvPUI|r created for Nextgen-WoW by |cff0070DESchaka|r")
log("Type /SchakaPvPUI move to avoid frame resetting every relog")
log("Use /SchakaPvPUI target|player|party|focus [number] to scale frames || enable move to save scales")
frame:RegisterEvent("PLAYER_LOGIN")
SchakaPvPUI = SchakaPvPUI or { move = false, target = 1.0, player = 1.0, party = 1.0, focus = 1.0}

SLASH_PVPUI1 = '/SchakaPvPUI';
function SlashCmdList.PVPUI (msg, editBox)
	if msg == 'move' then
		if SchakaPvPUI.move == false then
			SchakaPvPUI.move = true
			log("Frames are now moveable")
		else
			SchakaPvPUI.move = false
			log("Frames are now constant")
		end
	elseif string.find(msg, "target") ~= nil then
		local message = string.sub(msg, 8)
		SchakaPvPUI.target = tonumber(message)
		TargetFrame:SetScale(SchakaPvPUI.target)
	elseif string.find(msg, "focus") ~= nil then
		local message = string.sub(msg, 7)
		SchakaPvPUI.focus = tonumber(message)
		FocusFrame:SetScale(SchakaPvPUI.focus)
	elseif string.find(msg, "player") ~= nil then
		local message = string.sub(msg, 8)
		SchakaPvPUI.player = tonumber(message)
		PlayerFrame:SetScale(SchakaPvPUI.player)
	elseif string.find(msg, "party") ~= nil then
		local message = string.sub(msg, 7)
		SchakaPvPUI.party = tonumber(message)
		PartyMemberFrame1:SetScale(SchakaPvPUI.party)
		PartyMemberFrame2:SetScale(SchakaPvPUI.party)
		PartyMemberFrame3:SetScale(SchakaPvPUI.party)
		PartyMemberFrame4:SetScale(SchakaPvPUI.party)
	end
end

local function eventHandler(self, event)
        if event == "PLAYER_LOGIN" then
                --PetFrame:ClearAllPoints()
                --PetFrame:SetPoint("LEFT",-22,50)
                --TotemFrame:ClearAllPoints()
                --TotemFrame:SetPoint("TOPRIGHT",0,22)
				
				PlayerFrame:SetScale(SchakaPvPUI.player)
				TargetFrame:SetScale(SchakaPvPUI.target)
				PartyMemberFrame1:SetScale(SchakaPvPUI.party)
				PartyMemberFrame2:SetScale(SchakaPvPUI.party)
				PartyMemberFrame3:SetScale(SchakaPvPUI.party)
				PartyMemberFrame4:SetScale(SchakaPvPUI.party)
				
				if SchakaPvPUI.move == false then
					--player
					PlayerFrame:ClearAllPoints()
					PlayerFrame:SetPoint("CENTER", -150, -135)
					PlayerFrame:SetScale(1.25)
					--target
					TargetFrame:ClearAllPoints()
					TargetFrame:SetPoint("RIGHT", PlayerFrame, 250, 0)
					TargetFrame:SetScale(1.25)
					--party
					PartyMemberFrame1:ClearAllPoints()
					PartyMemberFrame1:SetPoint("LEFT", PlayerFrame, -215, 150)
					PartyMemberFrame1:SetScale(1.6)
					PartyMemberFrame2:SetScale(1.6)
					PartyMemberFrame3:SetScale(1.6)
					PartyMemberFrame4:SetScale(1.6)
					TargetofTargetFrame:ClearAllPoints()
					TargetofTargetFrame:SetPoint("BOTTOMRIGHT", TargetFrame,-15,-10)
					TargetofFocusFrame:ClearAllPoints()
					TargetofFocusFrame:SetPoint("BOTTOMRIGHT", FocusFrame,-15,-10)
					
					-- player castbar
					CastingBarFrame:ClearAllPoints()
					CastingBarFrame:SetPoint("TOP", PlayerFrame, 10, -8)
					CastingBarFrame.SetPoint = function() end
					CastingBarFrame:SetScale(1.25)
					-- target castbar
					TargetFrameSpellBar:ClearAllPoints()
					TargetFrameSpellBar:SetPoint("TOP", TargetFrame, -20, -4)
					TargetFrameSpellBar.SetPoint = function() end
					TargetFrameSpellBar:SetScale(1.15)
				end
				TargetFrameFlash:SetAlpha(0)
				-- pvp icons
                PlayerPVPIcon:SetAlpha(0)
                TargetPVPIcon:SetAlpha(0)
                FocusPVPIcon:SetAlpha(0)
				-- interface
                MainMenuBarLeftEndCap:SetAlpha(0)
                MainMenuBarRightEndCap:SetAlpha(0)
				-- focus castbar
				--FocusFrameSpellBar:ClearAllPoints()
				--TargetFrameSpellBar:SetPoint("TOP", FocusFrame, -20, -4)
				--FocusFrameSpellBar.SetPoint = function() end
				--FocusFrameSpellBar:SetScale(1.15)
				
		end
        if LoadAddOn("Blizzard_CombatText") then
                ENTERING_COMBAT = "+Combat"
                LEAVING_COMBAT = "-Combat"
                CombatText:SetScale(.85)
                COMBAT_TEXT_TYPE_INFO["ENTERING_COMBAT"].r = 1
                COMBAT_TEXT_TYPE_INFO["ENTERING_COMBAT"].g = 0
                COMBAT_TEXT_TYPE_INFO["ENTERING_COMBAT"].b = 1
                COMBAT_TEXT_TYPE_INFO["LEAVING_COMBAT"].r = 1
                COMBAT_TEXT_TYPE_INFO["LEAVING_COMBAT"].g = 0
                COMBAT_TEXT_TYPE_INFO["LEAVING_COMBAT"].b = 1
        end
end
frame:SetScript("OnEvent", eventHandler)


local frame2=CreateFrame("Frame")
frame2:RegisterEvent("ADDON_LOADED")
frame2:SetScript("OnEvent", function(self, event, addon)
        if (addon == "Blizzard_TimeManager") then
                for i, v in pairs({PlayerFrameTexture, TargetFrameTexture, PetFrameTexture, PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture, PartyMemberFrame4Texture,
                        PartyMemberFrame1PetFrameTexture, PartyMemberFrame2PetFrameTexture, PartyMemberFrame3PetFrameTexture, PartyMemberFrame4PetFrameTexture, FocusFrameTexture,
                        TargetofTargetTexture, TargetofFocusTexture, BonusActionBarFrameTexture0, BonusActionBarFrameTexture1, BonusActionBarFrameTexture2, BonusActionBarFrameTexture3,
                        BonusActionBarFrameTexture4, MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3, MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2,
                        MainMenuMaxLevelBar3, MinimapBorder, CastingBarFrameBorder, FocusFrameSpellBarBorder, TargetFrameSpellBarBorder, MiniMapTrackingButtonBorder, MiniMapLFGFrameBorder, MiniMapBattlefieldBorder,
                        MiniMapMailBorder, MinimapBorderTop,
                        select(1, TimeManagerClockButton:GetRegions())
                }) do
                        v:SetVertexColor(.4, .4, .4)
                end

                for i,v in pairs({ select(2, TimeManagerClockButton:GetRegions()) }) do
                        v:SetVertexColor(1, 1, 1)
                end

                self:UnregisterEvent("ADDON_LOADED")
                frame:SetScript("OnEvent", nil)
		end
end)

for i, v in pairs({ MainMenuBarLeftEndCap, MainMenuBarRightEndCap }) do
        v:SetVertexColor(.35, .35, .35)
end

local frame3 = CreateFrame("FRAME")
frame3:RegisterEvent("GROUP_ROSTER_UPDATE")
frame3:RegisterEvent("PLAYER_TARGET_CHANGED")
frame3:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame3:RegisterEvent("UNIT_FACTION")

frame3:SetScript("OnEvent", eventHandler)


--[[ taken from DamnTargetBuffs by Shadowed @ WowInterface.com ]] --
-- Modify these two as you wish, spacing between each buff/debuff
local DEBUFF_OFFSET = 4
local BUFF_OFFSET = 3

-- Figure out how many buffs will be shown in the first row
local firstBuffRow = 6
local numBuffs = 0
local numDebuffs = 0

local Orig_TargetDebuffButton_Update = TargetDebuffButton_Update
function TargetDebuffButton_Update(...)
	if( TargetofTargetFrame:IsShown() ) then
		firstBuffRow = 6
	else
		firstBuffRow = 7
	end
	
	numBuffs = 0
	for i=1, MAX_TARGET_BUFFS do
		if( select(3, UnitBuff("target", i)) ) then
			numBuffs = numBuffs + 1
		end
	end
	
	
	numDebuffs = 0
	for i=1, MAX_TARGET_DEBUFFS do
		if( select(3, UnitDebuff("target", i)) ) then
			numDebuffs = numDebuffs + 1
		end
	end
	
	Orig_TargetDebuffButton_Update(...)
end

-- Update buff positioning/size
local Orig_TargetFrame_UpdateBuffAnchor = TargetFrame_UpdateBuffAnchor
function TargetFrame_UpdateBuffAnchor(buffName, index, numFirstRowBuffs, numDebuffs, buffSize, offset, ...)
	if( numBuffs >= firstBuffRow ) then
		buffSize = SMALL_BUFF_SIZE
	else
		buffSize = LARGE_BUFF_SIZE
	end
	
	Orig_TargetFrame_UpdateBuffAnchor(buffName, index, firstBuffRow, numDebuffs, buffSize, BUFF_OFFSET, ...)
end

-- Update debuff positioning/size
local Orig_TargetFrame_UpdateDebuffAnchor = TargetFrame_UpdateDebuffAnchor
function TargetFrame_UpdateDebuffAnchor(buffName, index, numFirstRowBuffs, numBuffs, buffSize, offset, ...)
	if( numDebuffs >= firstBuffRow ) then
		buffSize = SMALL_BUFF_SIZE
	else
		buffSize = LARGE_BUFF_SIZE
	end
		
	Orig_TargetFrame_UpdateDebuffAnchor(buffName, index, firstBuffRow, numBuffs, buffSize, DEBUFF_OFFSET, ...)
end


--[[hooksecurefunc("UnitFrame_Update",  function()
local unit = this:GetAttribute("unit")
    if UnitExists(unit) and UnitIsFriend("player", unit) then
        if UnitIsPlayer(unit) then
            if unit == "target" then
                TargetFrameNameBackground:SetVertexColor(0, 1, 0, 1)
			elseif unit == "focus" then
				FocusFrameNameBackground:SetVertexColor(0, 1, 0, 1)	   
            end
        end
	elseif 	UnitExists(unit) and not UnitIsFriend("player", unit) then
		if UnitIsPlayer(unit) then
            if unit == "target" then
                TargetFrameNameBackground:SetVertexColor(1, 0, 0, 1)
			elseif unit == "focus" then
				FocusFrameNameBackground:SetVertexColor(1, 0, 0, 1)	   
            end
        end
    end
end)]]