--[[ PixelShadow ]]

local LibButtonFacade = LibStub("LibButtonFacade",true)
if not LibButtonFacade then
	return
end

-- PixelShadow
LibButtonFacade:AddSkin("PixelShadow",{

	-- Skin data start.
	Backdrop = {
		Width = 50.769,
		Height = 50.769,
		Color = {1, 1, 1, 0.75},
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Backdrop]],
	},
	Icon = {
		Width = 33,
		Height = 33,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Flash = {
		Width = 50.769,
		Height = 50.769,
		Color = {1, 0, 0, 0.5},
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Overlay]],
	},
	Cooldown = {
		Width = 33,
		Height = 33,
	},
	AutoCast = {
		Width = 33,
		Height = 33,
		OffsetX = 1,
		OffsetY = -1,
		AboveNormal = true,
	},
	Normal = {
		Width = 50.769,
		Height = 50.769,
		Static = true,
		Color = {0.25, 0.25, 0.25, 1},
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Normal]],
	},
	Pushed = {
		Width = 50.769,
		Height = 50.769,
		Color = {0, 0, 0, 0.5},
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Overlay]],
	},
	Border = {
		Width = 50.769,
		Height = 50.769,
		BlendMode = "ADD",
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Border]],
	},
	Disabled = {
		Hide = true,
	},
	Checked = {
		Width = 50.769,
		Height = 50.769,
		BlendMode = "ADD",
		Color = {0, 0.75, 1, 0.5},
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Border]],
	},
	AutoCastable = {
		Width = 64,
		Height = 64,
		OffsetX = 0.5,
		OffsetY = -0.5,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Highlight = {
		Width = 50.769,
		Height = 50.769,
		BlendMode = "ADD",
		Color = {1, 1, 1, 0.5},
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Highlight]],
	},
	Gloss = {
		Width = 50.769,
		Height = 50.769,
		Texture = [[Interface\AddOns\ButtonFacade_PixelShadow\Textures\Gloss]],
	},
	HotKey = {
		Width = 40,
		Height = 10,
		OffsetX = -2,
		OffsetY = 10,
	},
	Count = {
		Width = 40,
		Height = 10,
		OffsetX = -2,
		OffsetY = -10,
	},
	Name = {
		Width = 40,
		Height = 10,
		OffsetY = -10,
	},
	-- Skin data end.

}, true)
