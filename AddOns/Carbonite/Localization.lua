---------------------------------------------------------------------------------------
-- Carbonite Localization File
-- Copyright 2007-2008 Carbon Based Creations, LLC
---------------------------------------------------------------------------------------

if GetLocale() == "deDE" then		-- German

	BINDING_NAME_NxMAPTOGORIGINAL		= "Toggle Original Map"
	BINDING_NAME_NxMAPTOGNORMMAX		= "Toggle Normal or Max Map"
	BINDING_NAME_NxMAPTOGNONEMAX		= "Toggle None or Max Map"
	BINDING_NAME_NxMAPTOGNONENORM		= "Toggle None or Normal Map"
	BINDING_NAME_NxMAPSCALERESTORE	= "Restore Saved Map Scale"
	BINDING_NAME_NxMAPTOGMINIFULL		= "Toggle Full Size Minimap"
	BINDING_NAME_NxTOGGLEFAV			= "Toggle Favorites"
	BINDING_NAME_NxTOGGLEGUIDE			= "Toggle Guide"
	BINDING_NAME_NxTOGGLEWAREHOUSE	= "Toggle Warehouse"
	BINDING_NAME_NxTOGGLEWATCHMINI	= "Toggle Watch List Minimize"

	NXLOADING			= "loading"
	NXLOAD_DONE			= "load done"

	NXlEXTRACTGAS		= "Gas extrahieren"
	NXlFISHING			= "Angeln"
	NXlHERBGATHERING	= "Kr\195\164utersammeln"
	NXlINCONFLICT		= "Umk\195\164mpft"
	NXlLEVELSPC			= "Stufe "
	NXlMINING			= "Bergbau"
	NXlOpening			= "\195\150ffnen"
	NXlOpeningNoText	= "\195\150ffnen - No Text"	-- Check
	NXlGLOWCAP			= "Gl\195\188hkappe"

	NxlRiding			= "Reiten"

	NXlBGMessages = {		-- Battleground messages. Menu text, message text
		"Incoming", "Inc",
		"Clear", "Clear",
		"Help", "Help",
		"Attack", "Attack",
		"Guard", "Guard",
		"Well Defended", "Well Defended",
		"Losing", "Losing",
	}

	NXlBGStatus			= "Report Status"

	NXlMapNames = {
		["Alterac Mountains"] = "Alteracgebirge",
		["Arathi Highlands"] = "Arathihochland",
		["Ashenvale"] = "Eschental",
		["Auchenai Crypts"] = "Auchenaikrypta",
		["Mana-Tombs"] = "Managruft",
		["Sethekk Halls"] = "Sethekkhallen",
		["Shadow Labyrinth"] = "Schattenlabyrinth",
--		["Azshara"] = "",
		["Azuremyst Isle"] = "Azurmythosinsel",
		["Badlands"] = "\195\150dland",
		["Black Temple"] = "Der Schwarze Tempel",
		["Blackfathom Deeps"] = "Tiefschwarze Grotte",
		["Blackrock Depths"] = "Schwarzfelstiefen",
		["Blackrock Mountain"] = "Der Schwarzfels",
		["Blackrock Spire"] = "Schwarzfelsspitze",
		["Blackwing Lair"] = "Pechschwingenhort",
		["Blade's Edge Mountains"] = "Schergrat",
		["Blasted Lands"] = "Verw\195\188stete Lande",
		["Bloodmyst Isle"] = "Blutmythosinsel",
		["Burning Steppes"] = "Brennende Steppe",
		["Hyjal Summit"] = "Hyjalgipfel",
		["Old Hillsbrad Foothills"] = "Vorgebirge des Alten H\195\188gellands",
		["The Black Morass"] = "Der schwarze Morast",
		["Champions' Hall"] = "Halle der Champions",
		["Serpentshrine Cavern"] = "H\195\182hle des Schlangenschreins",
		["The Slave Pens"] = "Die Sklavenunterk\195\188nfte",
		["The Steamvault"] = "Die Dampfkammer",
		["The Underbog"] = "Der Tiefensumpf",
		["Darkshore"] = "Dunkelk\195\188ste",
--		["Darnassus"] = "",
		["Deadwind Pass"] = "Gebirgspass der Totenwinde",
		["Deeprun Tram"] = "Die Tiefenbahn",
--		["Desolace"] = "",
		["Dire Maul"] = "D\195\188sterbruch",
--		["Dun Morogh"] = "",
--		["Durotar"] = "",
		["Duskwood"] = "D\195\164mmerwald",
		["Dustwallow Marsh"] = "D\195\188stermarschen",
		["Eastern Plaguelands"] = "\195\150stliche Pestl\195\164nder",
		["Elwynn Forest"] = "Wald von Elwynn",
		["Eversong Woods"] = "Immersangwald",
		["Felwood"] = "Teufelswald",
--		["Feralas"] = "",
		["Ghostlands"] = "Geisterlande",
--		["Gnomeregan"] = "",
		["Gruul's Lair"] = "Gruuls Unterschlupf",
		["Hall of Legends"] = "Halle der Legenden",
		["Hellfire Ramparts"] = "H\195\182llenfeuerbollwerk",
		["Magtheridon's Lair"] = "Magtheridons Kammer",
		["The Blood Furnace"] = "Der Blutkessel",
		["The Shattered Halls"] = "Die zerschmetterten Hallen",
		["Hellfire Peninsula"] = "H\195\182llenfeuerhalbinsel",
		["Hillsbrad Foothills"] = "Vorgebirge des H\195\188gellands",
		["Ironforge"] = "Eisenschmiede",
--		["Karazhan"] = "",
--		["Loch Modan"] = "",
--		["Maraudon"] = "",
		["Molten Core"] = "Geschmolzener Kern",
		["Moonglade"] = "Mondlichtung",
--		["Mulgore"] = "",
--		["Nagrand"] = "",
--		["Naxxramas"] = "",
		["Netherstorm"] = "Nethersturm",
		["Onyxia's Lair"] = "Onyxias Hort",
--		["Orgrimmar"] = "",
		["Ragefire Chasm"] = "Der Flammenschlund",
		["Razorfen Downs"] = "H\195\188gel der Klingenhauer",
		["Razorfen Kraul"] = "Kral der Klingenhauer",
		["Redridge Mountains"] = "Rotkammgebirge",
		["Ruins of Ahn'Qiraj"] = "Ruinen von Ahn'Qiraj",
		["Scarlet Monastery"] = "Das Scharlachrote Kloster",
--		["Scholomance"] = "",
		["Searing Gorge"] = "Sengende Schlucht",
		["Shadowfang Keep"] = "Burg Schattenfang",
		["Shadowmoon Valley"] = "Schattenmondtal",
		["Shattrath City"] = "Shattrath",
--		["Silithus"] = "",
		["Silvermoon City"] = "Silbermond",
		["Silverpine Forest"] = "Silberwald",
		["Stonetalon Mountains"] = "Steinkrallengebirge",
		["Stormwind City"] = "Sturmwind",
		["Stranglethorn Vale"] = "Schlingendorntal",
--		["Stratholme"] = "",
		["Sunken Temple"] = "Versunkener Tempel",	-- Check
		["The Temple of Atal'Hakkar"] = "Versunkener Tempel", -- Check
		["Swamp of Sorrows"] = "S\195\188mpfe des Elends",
--		["Tanaris"] = "",
--		["Teldrassil"] = "",
		["The Arcatraz"] = "Die Arkatraz",
		["The Botanica"] = "Die Botanika",
		["The Eye"] = "Das Auge",
		["The Mechanar"] = "Die Mechanar",
		["Temple of Ahn'Qiraj"] = "Tempel von Ahn'Qiraj",
		["Terokkar Forest"] = "W\195\164lder von Terokkar",
		["The Barrens"] = "Brachland",
		["The Deadmines"] = "Die Todesminen",
		["The Exodar"] = "Die Exodar",
		["The Hinterlands"] = "Hinterland",
		["The Stockade"] = "Das Verlies",
		["The Veiled Sea"] = "Das verh\195\188llte Meer",
		["Thousand Needles"] = "Tausend Nadeln",
		["Thunder Bluff"] = "Donnerfels",
		["Tirisfal Glades"] = "Tirisfal",
--		["Uldaman"] = "",
		["Un'Goro Crater"] = "Krater von Un'Goro",
		["Undercity"] = "Unterstadt",
		["Wailing Caverns"] = "Die H\195\182hlen des Wehklagens",
		["Western Plaguelands"] = "Westliche Pestl\195\164nder",
--		["Westfall"] = "",
		["Wetlands"] = "Sumpfland",
		["Winterspring"] = "Winterquell",
		["Zangarmarsh"] = "Zangarmarschen",
--		["Zul'Farrak"] = "",
--		["Zul'Gurub"] = "",
--		["Zul'Aman"] = "",
		["Isle of Quel'Danas"] = "Insel von Quel'Danas",
		["Magisters' Terrace"] = "Terrasse der Magister",
		["Sunwell Plateau"] = "Sonnenbrunnenplateau",

		["Alterac Valley"] = "Alteractal",
		["Arathi Basin"] = "Arathibecken",
		["Eye of the Storm"] = "Auge des Sturms",
		["Warsong Gulch"] = "Kriegshymnenschlucht",
		["Blade's Edge Arena"] = "Arena des Schergrats",
		["Nagrand Arena"] = "Arena von Nagrand",
		["Ruins of Lordaeron"] = "Ruinen von Lordaeron",

		["Borean Tundra"] = "Boreanische Tundra",
		["Crystalsong Forest"] = "Kristallsangwald",
--		["Dalaran"] = "",
		["Dragonblight"] = "Drachen\195\182de",
		["Grizzly Hills"] = "Grizzlyh\195\188gel",
		["Howling Fjord"] = "Der heulende Fjord",
		["Icecrown"] = "Eiskrone",
		["Sholazar Basin"] = "Sholazarbecken",
		["The Storm Peaks"] = "Die Sturmgipfel",
		["Wintergrasp"] = "Tausendwintersee",
--		["Zul'Drak"] = "",
		-- Fix
--		["Plaguelands: The Scarlet Enclave"] = "The Scarlet Enclave?",

		-- Fix
		["Ahn'kahet"] = "Ahn'kahet?",
		["Azjol-Nerub"] = "Azjol-Nerub?",
		["Drak'Tharon Keep"] = "Drak'Tharon Keep?",
		["Gundrak"] = "Gundrak?",
		["The Nexus"] = "The Nexus?",
		["The Oculus"] = "The Oculus?",
		["The Violet Hold"] = "The Violet Hold?",
		["Halls of Lightning"] = "Halls of Lightning?",
		["Halls of Stone"] = "Halls of Stone?",
		["Utgarde Keep"] = "Utgarde Keep?",
		["The Culling of Stratholme"] = "The Culling of Stratholme?",
		["The Eye of Eternity"] = "The Eye of Eternity?",
		["The Obsidian Sanctum"] = "The Obsidian Sanctum?",
		["Utgarde Pinnacle"] = "Utgarde Pinnacle?",
	}

else	-- English

	BINDING_NAME_NxMAPTOGORIGINAL		= "Toggle Original Map"
	BINDING_NAME_NxMAPTOGNORMMAX		= "Toggle Normal or Max Map"
	BINDING_NAME_NxMAPTOGNONEMAX		= "Toggle None or Max Map"
	BINDING_NAME_NxMAPTOGNONENORM		= "Toggle None or Normal Map"
	BINDING_NAME_NxMAPSCALERESTORE	= "Restore Saved Map Scale"
	BINDING_NAME_NxMAPTOGMINIFULL		= "Toggle Full Size Minimap"
	BINDING_NAME_NxTOGGLEFAV			= "Toggle Favorites"
	BINDING_NAME_NxTOGGLEGUIDE			= "Toggle Guide"
	BINDING_NAME_NxTOGGLEWAREHOUSE	= "Toggle Warehouse"
	BINDING_NAME_NxTOGGLEWATCHMINI	= "Toggle Watch List Minimize"

	NXLOADING			= "loading"
	NXLOAD_DONE			= "load done"

	NXlEXTRACTGAS		= "Extract Gas"
	NXlFISHING			= "Fishing"
	NXlHERBGATHERING	= "Herb Gathering"
	NXlINCONFLICT		= "In Conflict"
	NXlLEVELSPC			= "Level "
	NXlMINING			= "Mining"
	NXlOpening			= "Opening"
	NXlOpeningNoText	= "Opening - No Text"
	NXlGLOWCAP			= "Glowcap"

	NXlRiding			= "Riding"

	NXlBGMessages = {		-- Battleground messages. Menu text, message text
		"Incoming", "Inc",
		"Clear", "Clear",
		"Help", "Help",
		"Attack", "Attack",
		"Guard", "Guard",
		"Well Defended", "Well Defended",
		"Losing", "Losing",
	}

	NXlBGStatus			= "Report Status"

	NXlMapNames = {	-- Defaults
	}
end

--EOF










