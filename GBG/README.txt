G.B.G — GLAYNA BETTER GUILD — v1.8.6
World of Warcraft 3.3.5a / Ascension: Conquest of Azeroth — Interface 30300
Author: Glayna
Website: addon.devquestlog.com

ABOUT
G.B.G replaces the default Blizzard guild window with a complete modern guild hub.
It synchronizes useful guild information only between members who have the addon installed.

COMPLETE OVERVIEW
- Modern replacement for Social > Guild, opened directly through the Blizzard Guild tab.
- Shared guild chat history with clickable names, WoW links, mentions, unread indicators and temporary fluorescent-green mention highlighting.
- Adjustable guild-chat font size and a reliable scroll history with a Latest messages shortcut.
- Full member roster with online/offline state, last connection, ranks, sorting, search and member profiles.
- Shared character portraits, profile images and Main/reroll relationships.
- Private personal notes, ignore controls and per-member login mention alerts.
- Online/offline notifications, highlighted-member alerts and a movable notification bar.
- Guild banner/tabard creator with layered backgrounds, borders, emblems, weapons, colors, sizes, positions, rotations, text and guild-master publishing.
- Guild PvE/PvP Finder with activity categories, descriptions, level ranges, group-size targets, Tank/Heal/DPS/Support roles and profile portraits.
- Automatic or manual applicant validation, automatic invitations after acceptance, role-capacity checks, live party/raid counting and leader-only activity management.
- Finder activities automatically close when full or after 30 minutes.
- Movable launcher with online/activity indicators, configurable opening key and uniform interface scaling.
- Strict French/English localization, persistent settings and automatic newer-version detection through guild synchronization.
- Download/update information through addon.devquestlog.com or the launcher.

INSTALLATION
1. Close World of Warcraft completely.
2. Delete the former folder if it is still installed:
   World of Warcraft\Interface\AddOns\GlaynasMidnightGuild
3. Also replace any existing GBG folder, then extract the new "GBG" folder into:
   World of Warcraft\Interface\AddOns\
4. Start the game and enable the addon.

MAIN FEATURES
- Modern guild interface inspired by Midnight / The War Within.
- Guild chat, shared persistent history, member list and guild information.
- Automatic interface refresh every 1 second.
- Automatic guild-only addon data exchange every 5 seconds.
- English and French interface.
- French is selected automatically on a frFR client; English otherwise.
- Language can be forced in Settings.
- Large white guild name and smaller secondary addon branding.
- Bottom-left gear button for Settings.
- All fixed-width interface labels are constrained or shortened to stay inside their panels.
- Movable "Guild" launcher tab.
- Opening key and every setting persist after logout and /reload.

GUILD CHAT
- Click a player name in guild chat to:
  - Whisper
  - Invite
  - Mention in guild chat
  - Cancel
- Optional single green full-screen pulse when your name or @YourName is mentioned in a live guild message.
- Mention flashes are never triggered by synchronized historical messages.

MEMBER RIGHT-CLICK MENU
- Whisper
- Invite
- Ignore / Unignore
- Set as Main (shown only for characters recognized as belonging to you)
- Personal Note
- Login Alert
- Cancel

MAIN AND REROLLS
- The addon creates an anonymous installation/account identifier shared only through addon messages.
- Every character using the same account-wide SavedVariables is recognized as one of your characters after it has logged in with the addon at least once.
- "Set as Main" is never offered for another player's character.
- Your selected main is displayed to addon users as:
  MAIN
- Your other recognized characters are displayed as:
  Alt of "MainName" / Reroll de "NomDuMain"
- The selected Main and reroll relationship are synchronized automatically with guild addon users.

IMAGES
- Categorized portrait gallery: Heroes, Bosses, Races and Emblems.
- Includes Jaina, Sylvanas, Thrall, Varian, Tyrande, Velen, Arthas, Illidan and many more.
- Character avatars are shared automatically with guild addon users.
- The guild master can select a shared guild image.
- A custom texture path can be used when every member has the exact same file installed at the same path.

NOTIFICATIONS
- Optional notification when a guild member comes online.
- Optional notification when a guild member goes offline.
- Per-player Login Alert with a large notification.
- Login Alert selection remains private and local.

PRIVATE LOCAL DATA
- Personal notes are visible only to you.
- Ignore state is handled by the WoW client.
- Notification settings, highlighted players, window positions and opening key remain local.

SHARED GUILD DATA
- Guild chat history.
- Character avatar and anonymous character-family identifier.
- Main/reroll relationship.
- Guild image selected by the guild master.

COMMANDS
/gmg              Open or close the interface.
/gmg reset        Reset the window and movable Guild tab positions.

HOTFIX HISTORY
- v1.1.1 embedded localization in Core.lua and fixed nil method errors for L and ApplyBindingLocale.
- v1.2.0 adds portrait categories, settings gear, bounded texts, clickable chat names, mention flash, persistent settings/binding, and synchronized Main/reroll relationships restricted to your own characters.


FIXES IN v1.2.1
- Opening key is preserved in SavedVariables and automatically restored after /reload.
- Prevents UPDATE_BINDINGS during startup from erasing the saved key.
- Fixes the chat scrollbar SetVerticalScroll nil error.
- Removes Personal Note and Login Alert buttons from the center of the profile panel; both remain in the member right-click menu.
- Member profile name now uses the player's class color.
- Member profile now shows the last connection date and a localized "time ago" value.


Custom portraits integrated in v1.2.2+: 132 addon-ready portraits in Media/Characters (40 original + 92 extra from the new profile pack).

v1.3.0
------
- Only the 40 user-supplied portraits remain in the image picker.
- Portraits are optimized as 256x256 RGB TGA textures to reduce loading time and addon weight.
- Automatic default portrait mapping for standard classes and Conquest of Azeroth custom classes.
- Full guild MOTD and guild information are readable in scrollable copy-friendly text areas.
- Discord/web links found in guild information and guild chat are clickable and open a Ctrl+C copy box.
- Advanced notification settings: size, duration, opacity, shadow, position, animation, style and color.
- Window themes, accent colors and solid/glass/soft window styles.
- Member sorting by name, level, class, zone or guild rank, ascending or descending.
- Guild rank lexicon, ordered highest-to-lowest or lowest-to-highest, with member lists per rank.
- Escape closes the main guild window.
- Optional semi-transparency while moving and/or in combat.
- Header layout updated: smaller addon brand above a larger guild name.


v1.3.1: fixed nil-safe roster sorting and merged all 40 custom portraits into one unified gallery.

- v1.3.2 uses the Alliance or Horde crest as the default guild image.

- v1.3.3 aligns the addon title and guild name directly to the right of the faction crest, with true left text justification.


Version 1.3.5 SAFE
- Rebuilt from the stable 1.3.3 base.
- Fixes the malformed Lua texture path from 1.3.4.
- Replaces the 32-bit alpha logo with an opaque 24-bit TGA matching the stable portrait format.


Version 1.3.6
- Native WoW item, spell, quest, achievement and talent links remain clickable in guild chat.
- Native tooltips appear on hover and through Blizzard's standard click handler.


Version 1.3.7 CRASHFIX
- Converts all 40 character portraits and the guild crest to native BLP1 textures.
- Removes all TGA textures from the addon.
- Delays full interface construction until the first manual opening.
- Prevents external portrait textures from loading during PLAYER_LOGIN.


Version 1.3.8
- Hides the guild image completely when the character is not in a guild.


Version 1.3.9
- Replaces broken green portrait blocks with stable class icons in roster/profile displays.


Version 1.4.0
- Replaces unsupported green BLP portraits with 64x64 opaque TGA textures.
- Loads the guild crest first, online-member portraits next, then one new offline portrait per second.
- Uses the native question-mark icon until each portrait is ready, so no green blocks are shown.


Version 1.5.0
- Adds a layered guild banner/tabard creator with 10 backgrounds, 10 borders, 10 shields and 10 weapons.
- Every layer has an independent color selector.
- Adds initials (6 characters), text color, size and placement controls.
- Adds local test mode and guild-master-only publication.
- Synchronizes the compact recipe by guild and realm; every member relays the newest GM version.
- Displays the rebuilt banner in the guild header and Guild page.
- Rank lexicon now keeps every member and supports mouse-wheel/arrow scrolling.


Version 1.5.1
- Moves the banner/tabard creator into Settings.
- Adds 10-200% sizes and rotation controls for layers.
- Adds font selection, larger text sizes and text rotation.
- Adds persistent unread guild-message badges and mention glow.


Version 1.5.2
- Banner draft editing is available to every player; only the guild master can Apply.
- Removed local-test mode and explanatory layer/size message.
- Added yellow GM permission guidance with a clickable whisper target.
- Official banner records are continuously relayed; timestamp and revision prevent stale overwrite.
- No guild/faction/banner image is displayed until an official banner has been applied.


Version 1.5.3
- Replaced all 40 former profile/class portrait TGAs with the newly supplied Ascension portrait pack.
- Converted portraits to client-safe 256x256 RGB 24-bit TGA files.
- Updated default class associations for Conquest of Azeroth and standard classes.
- New portraits remain loaded progressively only when actually displayed.


Version 1.5.4
- Enlarged the profile/class image picker to 950 x 590.
- Added a dedicated right-side preview panel.
- A clicked portrait is now previewed at 256 x 256 before it is applied.
- Apply and Close controls remain directly below the large preview.

Version 1.5.5
- Les calques de bannière dépassant 100 % sont désormais réellement agrandis jusqu’à 200 % puis découpés aux limites du logo.
- Le nom du maître de guilde dans le message du créateur est affiché en blanc et reste cliquable pour ouvrir un /w.
- « Initiales » devient « Lettrages », avec espaces et points autorisés et une limite portée à 30 caractères.
- La taille du lettrage peut maintenant monter jusqu’à 300 avec un rendu agrandi et recadré dans la bannière.

Version 1.5.6
- Added 20 pure-white recolorable emblem assets (Emblem/Shield 11-30).
- Added 10 pure-white recolorable border assets (Border 11-20).
- Asset counts are now independent per layer: 10 backgrounds, 20 borders, 30 emblems/shields and 10 weapons.


v1.5.9: portrait picker now uses a true 256x256 preview, six spacious pages for all 132 packaged portraits, mouse-wheel paging, and a less cramped two-panel layout.


v1.6.1: compact 192x192 Change Character Image preview; banner layer color/size/rotation controls are hidden while asset is 0. Portrait source files remain TGA 256x256.


Version 1.6.2
- Restores the Change Character Image preview to a true 256x256 display with improved spacing and pagination retained.

Version 1.6.2
- Reduced the right-side character image preview in Change Character Image.
- Removed displayed image names from the preview pane.
- Kept the packaged portrait assets in full-quality TGA 256x256.

Version 1.6.3
- Restored the floating online/notification launcher at login.
- Launcher now loads independently from the full guild window.
- Restored online count, unread badge and mention glow on the launcher.


Version 1.6.4
- Fixed launcher title rendering crash caused by passing localized text as SetWidth value.
- The launcher online count and notification badge are restored safely.


Version 1.6.5
- Per-member Mention when online from Guild Chat names, independent from global online notifications.
- Reliable offline roster polling and red offline notification border.
- Green explicit-member online notifications.
- Editable selected-member list in Settings.
- Guild-chat mouse-wheel history navigation and Latest messages button.
- Optional persistent green pulsing border for unread mentions.


Version 1.7.0
- Adds a synchronized guild Dungeon Finder tab for addon users.
- Activities support PvE/PvP, level ranges, 1-40 available places and selectable roles.
- Players can register with a role; the activity owner automatically invites them.
- Activities are announced as clickable addon-only Guild Chat messages and disappear when full.
- Adds open-activity badges beside the online member counters.
- Adds temporary fluorescent-green highlighting for messages that mention the current player.
- Adds a movable and persistent notification bar position from Notification settings.

Version 1.7.1
- Activity creator/leader can edit the title, PvE/PvP type, level range, target group size, roles, approval mode and automatic invitation setting.
- Added automatic validation for matching roles or manual applicant approval.
- Added applicant manager with accept/reject and pagination.
- Accepted players are invited automatically and automatically accept invitations from the activity leader.
- Added Invite registered players to retry all missing invitations.
- Target size now represents the real final group size (1-40). Existing party/raid members and players joining outside the addon reduce available places.
- Activities close when the real group plus reserved accepted players reaches the target size.
- Dungeon Finder announcement messages are removed from addon guild chat when an activity closes or becomes full, with close revision tombstones preventing stale announcements from reappearing.


Version 1.7.2
- Registered-player count now includes every player already present in the real party or raid.
- Level fields are strictly limited to 1-60.
- Added PvE/PvP activity presets for XP, Normal, Heroic, Mythic, Mythic+, Raid, World Boss, Battleground, Arena, World PvP and Wargame activities.
- XP Dungeon presets require level 15 minimum; level-cap activities use level 60.
- Removed the redundant automatic-invite checkbox: every accepted player is now invited automatically in both automatic and manual validation modes.
- Added synchronized activity subtype labels to the list, details and clickable guild announcement.


Version 1.7.3
- Adds persistent A-/A+ controls for guild-chat message font size (9 to 24).
- Displays the addon version directly beside G.B.G (Glayna Better Guild) in the header.
- Exchanges addon versions through guild sync and shows a popup when a newer version is detected, with addon.devquestlog.com and launcher instructions.


Version 1.7.4
- Guild Finder member list now displays each player profile portrait and a Tank/Healer/Damage/Support role logo.
- Activity search rows show live Tank, Healer and Damage/Support composition counters.
- Standard PvE role capacity is enforced (for 5 players: 1 Tank, 1 Healer, 3 Damage/Support). A full role is marked Full/Complet and cannot receive new registrations.
- Applicant rows also display profile portraits and role logos.


Version 1.7.6
- Guild Finder activities have a fixed maximum lifetime of 30 minutes from creation.
- Editing, joining or accepting players no longer extends that deadline.
- Listings close and disappear immediately when the real group/reserved occupancy reaches the configured capacity.
- Expired/full listings and their clickable addon-chat announcements are removed for all synchronized users.


Version 1.7.7
- Social > Guild now opens G.B.G (Glayna Better Guild) instead of the Blizzard guild interface.
- Redirects the Guild social tab, ToggleFriendsFrame(3), ToggleGuildFrame and direct Blizzard Guild frame openings.


v1.7.8:
- The Create/Save button is visibly greyed when the form requirements are not met, while remaining clickable to display the exact blocking reason in a popup.
- Rebuilds the activity form with wider, non-overlapping sections and vertically separated automatic/manual approval choices.
- Registered players can click their own Finder entry to change role. The activity leader can change roles only for registered players currently present in that leader's own party/raid.
- Role changes are synchronized to addon users and still respect role capacity limits.
- Adds detailed localized tooltips to Finder controls, form fields, role controls, applicant actions and pagination. Truncated Finder button labels are shown in full in their tooltips.
- Adds generic full-label tooltips to the remaining GMG interface buttons.
- All new interface strings are fully localized in English and French.


v1.7.9:
- Only the current party or raid leader can create a Guild Finder activity; solo players remain allowed.
- The Create button is greyed while the player is not leader and displays a localized popup when clicked.
- Role capacity counters are moved to a dedicated right-hand column so 0/1 no longer overlaps Tank/Healer/Damage/Support.
- Finder member names and green group-status text now use separate columns and cannot overlap.


v1.8.0:
- Adds a uniform GMG interface scale control from 60% to 110% in Settings > Window Appearance.
- The main window, launcher and independent GMG dialogs all use the saved scale.
- Scaling preserves all internal proportions and relative positions.


v1.8.1:
- Moves the uniform interface-size control directly into the main sidebar above the settings cog.
- Adds simple minus/percentage/plus controls from 60% to 110% in 5% steps.
- Removes the duplicate interface-scale slider from Window Appearance.
- Fixes the guild-chat side scrollbar being permanently reset to the middle; it now follows the actual browsing direction from oldest to latest messages.

v1.8.1 portrait safety update:
- Prevents GMG guild artwork from ever being used by Blizzard player, target, pet or party portrait regions.
- Separates the default guild image from the progressive character-portrait preload queue.
- Repairs native unit portraits after target, party, raid and model updates on modified Ascension clients.


v1.8.2 branding update:
- Renames the visible addon to G.B.G (Glayna Better Guild).
- Sets the addon author to Glayna.
- Adds a complete localized About window with the full feature overview, synchronization/privacy information, version and update website.
- Expands the AddOns-list Notes/About metadata in English and French.
- Adds /gbg as the primary slash command while keeping /gmg and /midnightguild for compatibility.


v1.8.3 technical rename:
- Renames the installed addon folder from GlaynasMidnightGuild to GBG.
- Renames the table-of-contents file from GlaynasMidnightGuild.toc to GBG.toc.
- Renames the internal addon object and frame identifiers to GlaynaBetterGuild.
- Updates every bundled media path to Interface\AddOns\GBG.
- Migrates existing GlaynasMidnightGuildDB settings into GBGDB automatically.
- Keeps the former global object and slash commands as compatibility aliases only.

v1.8.4 image path repair:
- Corrects all bundled portrait, guild-logo and banner paths to Interface\AddOns\GBG\Media.
- Automatically migrates saved image paths from GlaynasMidnightGuild and GlaynaBetterGuild.
- Normalizes image paths received from older addon users during synchronization.

v1.8.6 guild invitation page:
- Added a dedicated Invitation / Guild Invite tab.
- Invite by manually entered character name or directly from the current target with the same button.
- Permission, guild membership, hostile target, self-target and already-guilded checks.
- Strict French/English localization, contextual tooltips and clear error pop-ups.


VERSION 1.8.6 — GUILD SEARCH & RECRUITMENT
- Adds a Guild Search tab visible to guildless players.
- Recruiting guilds publish their official G.B.G banner, PvE/PvP goal, description, recommended levels and live total/online member counts.
- Guildless players can apply with a personal message; their G.B.G profile portrait, class and level are included.
- Adds a Pending tab visible only to members with guild-invite permission.
- Authorized members can accept, retry invitations, refuse with a visible reason, and configure manual or automatic handling.
- Accepted applications remain pending and invitations are retried while the applicant is detected online; records are removed from the waiting list only after the player really joins or is refused.
- Uses a hidden same-realm/faction G.B.G recruitment channel for cross-guild discovery and applications while internal decisions remain synchronized inside the guild.
- Fully localized in French and English.
