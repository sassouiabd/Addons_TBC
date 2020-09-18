
 CARBONITE and CARBONITE Quest
 Addons for World of Warcraft(tm)

 Copyright 2007-2008 Carbon Based Creations, LLC
 CARBONITE(tm) is a registered trademark of Carbon Based Creations, LLC.

 World of Warcraft(tm) and "WOW" are trademarks owned by Blizzard Entertainment, Inc.
 The CARBONITE addon is not endorsed by or affiliated with Blizzard Entertainment, Inc.

 Website: carboniteaddon.com

----------------------------------------------------------

 CARBONITE and CARBONITE Quest are two different products. This file
 has information on both.

----------------------------------------------------------

Common Installation Instructions

 This zip file contains

   Carbonite (a folder)
   CarboniteTransfer (a folder)
   CarboniteLicenseAgreement.txt
   CarboniteReadMe.txt

 The Carbonite folder needs to be dragged from the zip file or the zip file
 extracted to the Warcraft AddOns folder. An existing Carbonite folder in
 the addons folder should be deleted first. This should be done while the
 game is not running.

 You can look at the shortcut (right click and select properties) you use to
 launch Warcraft to get the path to where it is installed.

 So if the shortcut says "C:\Program Files\World of Warcraft\Launcher.exe",
 then your addon path is "C:\Program Files\World of Warcraft\Interface\AddOns".
 Vista's path might be "C:\Users\Public\Games\World of Warcraft\Interface\AddOns".
 Apple computers would have a different path.

 Delete any existing Carbonite folders in the AddOns folder before you unzip a
 new version.

 If you have Warcraft installed at "C:\Program Files", then you would put
 the Carbonite folder at:

   "C:\Program Files\World of Warcraft\Interface\AddOns"

 Now you would have:

   "C:\Program Files\World of Warcraft\Interface\AddOns\Carbonite"

 Which contains:

  Bindings.xml
  Carbonite.lua
  Carbonite.toc
  Carbonite.xml
  CarboniteLicenseAgreement.txt
  CarboniteReadMe.txt
  Gfx (a folder)
  
 A common error is to create a Carbonite folder in AddOns and unzip to the folder.
 This would leave you with

   "C:\Program Files\World of Warcraft\Interface\AddOns\Carbonite\Carbonite" (WRONG)

 which will not work!

 Some users have found two AddOns directories on their computers.
 This may be caused by having installed both a downloaded and CD version of Warcraft or
 if Vista's Virtual Store is enabled.
 
 When properly installed, the Carbonite logo will appear on login.
 If the Carbonite logo does not appear, then the AddOns folder you are using is the wrong one.
 You would then use your computer's "file search" to find the actual folder.

----------------------------------------------------------

Here are some additional Vista specific install instructions:
 
 When you download an addon it will be in a zip file.

 When you click the "Download" button a dialog box should ask to
 "Open" or "Save". If you click "Open", then it will download the
 file and then show the contents. Near the top of the window that
 shows the file contents is a "Extract all files" button.
 Left click that and then click "Browse..." in the new window that opens.

 If you don't know the addon folder location, then look at the shortcut
 (right click and select properties) you use to launch Warcraft to
 get the path to where it is installed.

 Use the "Select a destination" window that opened to left click on
 "Computer" then (C:) or whatever drive it is installed on.
 Continue to click until you are at the game's "Interface\AddOns" folder.
 
 "C:\Program Files\World of Warcraft\Interface\AddOns" or
 "C:\Users\Public\Games\World of Warcraft\Interface\AddOns"
 are common locations for the game using Vista.
 
 Now left click "OK" at the bottom of the window and you should see
 "(the game path)\Interface\AddOns" in the
 "Files will be extracted to this folder:" line. Now click the
 "Extract" button at the bottom of the window. If it asks to overwrite
 files, which it will the next time you install another version of
 Carbonite and you did not delete the existing folder, then click "Yes".

 You would now have a
 "(the game path)\Interface\AddOns\Carbonite" folder.

 Installation is now complete and you can run World of Warcraft(tm).

----------------------------------------------------------

Carbonite Quest upgrade

 Carbonite Quest is a lite version of Carbonite. The full version has
 enhanced questing and map features. It also contains many other features.
 Visit carboniteaddon.com for details.

----------------------------------------------------------

Carbonite

 The full Carbonite is only downloaded from the Carbonite website.
 After you sign up in and go to the download page, you can download
 a version as a zip file. You should delete the Carbonite folder from the
 Warcraft Interface\AddOns folder before you unzip the downloaded file to
 ensure a good install and that any old files are removed. You should see
 the Carbonite logo on startup.

----------------------------------------------------------

Carbonite Start Up

 When you start the game, you should log in first using the realm and character
 that you used to create your Carbonite account. You will see a Carbonite Logo
 appear and the addon will validate itself in a few seconds. Once validated
 you can switch servers or characters and Carbonite will stay validated.
 When you update your version of Carbonite you will need to validate again.

 Carbonite Quest does not have any validation process.

 If the Carbonite Logo does not appear, then you have installed it incorrectly
 or it is disabled. Check if the addon is enabled by using the AddOns button on
 the character selection screen. If it does not appear in the list of addons,
 then repeat the installation instructions.

----------------------------------------------------------

** Carbonite User Guide **

Note: Many of these features are not in Carbonite Quest


-- General User Interface

Most windows can be moved, sized, scaled & locked.
To move a window, Left Click the title bar and drag.
To size a window, Left Click and drag any window edge.
To scale a window, Right Click the title bar or close button and adjust the Scale slider.
To close a window, Left Click the close button.
To lock a window, Right Click the title bar or close button and check lock.
To unlock a window, Right Click the close button which appears as a lock icon when locked.

Transparency:  Each window has two transparency settings. Fade in and fade out.  Each setting controls the transparency level for the window borders & background.
- The fade in setting is used when the window has mouse focus.
- The fade out setting is use when the mouse leaves the window
You can change these settings by Right Clicking the window title bar

When using a slider control if you hold down shift all units are snapped to 0.1.  Pressing ALT while on a slider will set its value to 1.0


-- Minimap Carbonite Icon

This icon is found at the top left of the minimap or at the top of the minimap docking window.

Left Clicking will show or hide the map.
Right Clicking will open the main Carbonite menu. The menu can be used to open the help or options windows.


-- Map

Left Click and drag to move the map around inside the window
Roll your mouse wheel to zoom in/out at the current mouse position on the map.
Pressing M will toggle the map between normal mode and full-screen mode.

The size, position and settings for the map are saved.  These settings are also saved independently for each battleground. 

The "Follow You" option is on by default for the normal map.  As you move about, the map will adjust to keep you in the center of the screen.  Various battleground maps have this setting off by default as you will typically want to view the entire map and not have it scrolling as you move.

The map has two additional fade settings.  These control the transparency level of the map itself and can be adjusted by Right Clicking in the map window.

The map title shows the zone you are currently in, your map coordinates and your movement speed as a percentage of normal walk speed.

The map tooltip will show you the level range of the map and is color coded based on faction (Yellow = contested, Green = friendly, Red = enemy)

Party/Raid members will show up as blue dots on your map.  Friends and guild mates running Carbonite will show up on your map as yellow and green dots respectively.  Other Carbonite users in your zone will show up as gray dots on the map.

The tooltip of any Carbonite user on the map will show you their coordinates, health, target name and target health.  Right Clicking their icon will allow you to whisper, retrieve quests and GOTO them.

For users wishing to see your original map, it is accessible by pressing ALT+M)


-- Quests

The quest log replaces the original quest log.  Like most windows it is fully sizeable.
You can Click the button or Shift Click any quest title in the quest log to add it to the watch list.  When you pick up a new quest it will be automatically added to the watch list.  Any quest can be watched including quests with no objectives.  You can add as many quests to the watch list as you like. If you Shift Click a quest category header it will add/remove all quests under that category.

The quest log has 3 additional tabs:
- History: a history of completed quests
- Database: a searchable list of quests in the database (shows current map zone by default)
- Player: You can Right Click another Carbonite user's map icon to retrieve their quests.  Their quests will show up in this tab.


Quest Watch List

The watch window is draggable but not sizeable.  It grows and shrinks as needed based on the quests you are currently watching.  The purple "Auto Track" button at the top of the list will target the highest priority quest objective and updates dynamically as you move. Priority is based on distance, quest level and if the quest is complete. The green button toggles if all watched quests will be shown on the map and is on by default.

The window can be made into a sizeable scrolling list if "Use fixed size list" is checked in the Quest Watch page of the Options window.


Objective Buttons

The buttons to the left of the quests/objectives have several functions.

Left Click will activate "GOTO" mode.  This display the location and direction of the objective on the world map.  The map will scale so that you and your target are always visible.

Shift Left Click will toggle the display of quest objectives on/off.

Right Clicking the quest log or the objective buttons will bring up a menu with additional options.


-- HUD

The HUD arrow turns on whenever you are using the GOTO feature.  The arrow will point to the target and show you the name, distance and estimated arrival time.  The HUD arrow can be moved by dragging the title bar.

Left Clicking the arrow will target a player if it is pointing at a player.
Right Clicking the arrow will target the target of a player if it is pointing at a player.


-- Guide

The guide is your in-game GPS with the location of various points of interest.  You can bring up the Guide by Clicking the Guide button on the map window (Question Icon).  By default the map will show you common POIs such as mailbox, bank, flight path, etc. when the map is zoomed in to a certain level.

You can Right Click any POI icon to GOTO it or paste the name & coordinates into a chat message.

Clicking any guide button will display the POI on the map and activate the GOTO mode where appropriate.  

Some guide categories have subcategories ( >>> after the text).  If you Click the text it will open up the subcategory.  Pressing the back button will move back up one level. 

We plan to add new categories based on user feedback, such as browsing honor/arena rewards.


-- Warehouse

The Warehouse enables you to browse the equipment and information of every one of your characters at one time.  You can bring up the Warehouse by clicking the Warehouse button in the map window (Chest Icon at bottom of map).

The Warehouse window has a list of your characters on the left side and items on the right side. You can select your characters in the left panel while the right panel displays their inventory, bank or profession items. Clicking a name in the left shows the items. Clicking a profession shows what can be make or done using the profession. You have to open each profession window for the data to get recorded in the Warehouse. This also records a profession link, if it has a link. You can the left click the chain icon to paste the link into an open chat edit box.

You can link items from the warehouse by clicking the item icon.

There is a search field at the top right of the window.  You can type any text into this field and it will display matching items below. 

You can click on "All Characters" and it will display all the items of all your characters at once. This is a useful feature when you are trying to track down specific items.

Equipped items are listed first; other items follow grouped by category. The number in front of an item name shows the total number that the current character or all characters have. It will be blank if the count is one. The numbers after the name are the amounts in inventory and bank.

Right click the list for a popup menu that allows you to turn off the category headers.
If you left click on an item it will display the names and total count of any characters with the item. Click the names to hide them.

After installing Carbonite for the first time, it is a good idea to open up the bank with each of your characters to populate the warehouse data.

The sync command in the Warehouse menu imports characters from other accounts in the transfer file that match the current server and exports all current server character data as recorded in the Warehouse. Every character stat that the Warehouse tracks is transfered. You would then copy the CarboniteTransfer.lua file from the SavedVariables folder of the current account to the other account's SavedVariables folder.

The only requirement is that the "Remember Account Name" setting at the account login screen be checked when you login, so Carbonite can know which account you are on when you sync. That is stored in the CVars if it is checked.


Transfering settings to other characters:

You can move the window layouts and other settings from a character to all your other characters. You would login with the character that is setup the way you like. Open the Warehouse. Right click the list on the right half of the window. Select "Export current settings to all characters" and click "Export" on the message box.
 
You can also do it the opposite way using "Import settings" from the same menu, but you would have to do that on each character.


-- Social window

The Social window is opened by pressing the O key and contains the normal friends window tabs and the Carbonite "Pals" and "Punks" tabs.

The "Pals" tab keeps track of your friends across all your characters and lets you add them as friends on any character you log in with. It also lets you assign a character to a person, so you can group characters according to the player that owns them. Right click the list for a menu of commands.

The "Punks" tab is for finding enemy players and keeping notes on them. The list has a top and bottom section divided by a blue "-- Active --" line of text. The top lists the names of enemies you have manually added to the list and when detected you will get a message and the area of the map they were seen at will have a large green glowing circle around it and a red icon near the middle of the area. The bottom of the list shows recent punk detections. Those punk areas will show a red glow on the map. Right click the list for the popup menu. When you use "Add Character" from the menu it will add an enemy player to the top section of the list. If an enemy player is targeted it will use that name, otherwise an edit box will open and be filled with the name of the most recent punk personally detected near you. A chat message will show if a new punk is detected near you.

Punks list options are in the "Social & Punks" page in the Options window.

The Social window can be disabled, right click the Carbonite minimap icon and select "Options". Click "Social & Punks" in the left side list, uncheck the box on the right side and reload UI when asked.


-- Favorites window

The Favorites window has a left and right side.

The left side shows a tree of folders and favorites. You can put folders inside of folders. This works like a computer file system. You select a favorite for viewing or editing by left clicking it.

The right side shows the list of items that belong to the currently selected favorite.

There are 4 item types you can put in a favorite.

1. Comment. Just a line of text that shows in the favorite item list. Create by right clicking the item list and selecting "Add Comment".

2. Note. An item that has an icon, text and map location. Create by right clicking the map and selecting "Add Note". The note will be created in a favorite with the name of the zone. The favorite will be in the "Notes" folder. The note will set to the map location where you right clicked and will be set to the Star icon. Notes can be put inside of favorites that are not in the notes folder, but they will not automatically show on the map when the zone is selected. The point of that is so you can make a favorite with you own set of steps (dailies, quest guide) and have notes mixed with targets. When the "Record" button is on the note will go into the selected favorite instead of the favorite in the notes folder.

3. Target 1st. This is the first part of a path or a single destination. Has a name and a map location. These are created when the "Record" button is on and you ctrl click the map or right click the map and select "Goto".

4. Target. This is the next part of a path. Has a name and a map location. These are created when the "Record" button is on and you ctrl shift click the map.

Record Mode:

This is on when the Record button is pressed. The button will glow red. Any map targets created (goto, guide or quest selection) will be added to the currently selected favorite below the selected item. Record mode is canceled when a different favorite is selected.

Viewing:

Note items inside of favorites in the "Notes" folder will be automatically drawn on the map if the the selected zone name matches the favorite name. Notes in favorites in any other folder will only be drawn when selected in the item list. The Notes folder is meant to mimic how notes are managed in other addons. Generally you should not put items other than notes inside the favorites in the notes folder.

Targets are drawn on the map when selected in the item list. Each target after the selected one will also be drawn until a "Target 1st" or a non target is reached. This lets you see a whole path or part of a path.


-- Battlegrounds

Carbonite adds clickable objective icons right onto your Battleground map.
Timer bars are displayed under each objective and you can mouse over to see the exact times.
Right Click on any objective to issue orders such as attack, defend, incoming, and to report time status.
Shift Click an objective to send an ‘incoming’ message.  Each Click adds one to the count.  E.g. Shift Click 3 times on the Lumber Mill icon and you will say “Incoming Lumber Mill: 3”

Hold down ALT to display player names (works anywhere, not just battlegrounds).
Hold down Shift to draw objectives on top of the player icons.

When a player is in combat his icon has an X in the middle.
The icon for each player has a health bar along the top and his target's health bar is displayed down the left side.

The HUD arrow will display the closest teammate that is in combat.  It will also point out friends/guildmates in the same battleground. When left clicked it will target that player and right click will target the target of that player.


-- Keyboard modifiers

Map:

 Shift down - Makes player arrow small. Draws BG objectives on top
 Shift click - Pings minimap if click is near the player arrow on the map
 Ctrl left click - Sets goto
 Alt down - Shows player icon names and makes icons draw on top

Minimap (in Carbonite map):

 Shift click - Pings
 Ctrl down - Makes integrated minimap draw on top or bottom if already on top
 Alt down - Makes docked minimap transparency 50%

List:

 Shift down - Makes mouse wheel scroll 5 times faster
 Shift + ctrl down - Makes mouse wheel scroll 100 times faster

Quest Watch:

 Alt left click button - Send quest status to party
 Alt right click button - Open quest window with quest selected

Keybindings you can set:

 Toggle Original Map
 Toggle Normal or Max Map
 Toggle None or Max Map
 Toggle None or Normal Map
 Restore Saved Map Scale
 Toggle Full Size Minimap
 Toggle Favorites
 Toggle Guide
 Toggle Warehouse
 Toggle Watch List Minimize

-- Map Icons

 Round solid icons are players:

  Yellow - friend
  Green - guild
  Blue - party
  Grey - non of the above

  Top Horizontal Bar - player health
  Mid Horizontal Bar - friendly target health
  Left Vertical Bar - enemy health (red glow if a player)
  x in center - in combat
  red in center - health low
  black in center - dead

 Round icons with black centers are for quests:

  White - quest ender if quest is simply to get to the end location

  By default there are 12 quest colors. Each quest starting at the top of the quest log has a different color. Once the 12 colors are used it repeats.

  Red - first quest in quest log
  Green - second quest in quest log
  Blue - third quest in quest log
  Yellow - forth quest and so on

  If "Use one color per quest" is off then
   Red - objective #1 or #4
	Green - objective #2 or #5
	Blue - objective #3 or #6

 Yellow ! - quest starter when you add a goto quest giver
 Yellow ? - quest ender

 Square icons with 4 black arrows are the closest point to reach a quest area:

  White color - is being tracked
  Non white colors match the same quest colors as described above.

-- Carbonite Transfer

CarboniteTransfer is a simple addon that is used to move Warehouse data between accounts. It will also be used to send and receive favorites in the future. You can delete it or disable it, although it takes almost no memory since it is empty until used.

In the Warehouse you right click the character list and select "Sync account transfer file" and any characters from your other synced accounts are imported from the CarboniteTransfer.lua file and characters in the current account are exported to the CarboniteTransfer.lua file. The file is then copied to the Savedvariables folder of another account, so you can sync the Warehouse data when you login with that account.



----------------------------------------------------------





