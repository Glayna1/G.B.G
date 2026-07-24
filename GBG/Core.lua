-- G.B.G (Glayna Better Guild)
-- Core, persistence, guild roster tracking and notifications

GlaynaBetterGuild = GlaynaBetterGuild or GlaynasMidnightGuild or {}
-- Legacy alias kept only so existing installations and external references continue to work.
GlaynasMidnightGuild = GlaynaBetterGuild
local GMG = GlaynaBetterGuild

-- Embedded localization fallback.
-- Kept inside Core.lua so the addon remains functional even when an older
-- .toc file omits Locale.lua or a partial installation changes load order.
GMG.Locales = GMG.Locales or {
    en = {
        BINDING_TOGGLE = "Open / close the guild interface",
        LAUNCHER = "Guild",
        LAUNCHER_OPEN = "Left-click: open / close",
        LAUNCHER_MOVE = "Right-click + drag: move",
        CHAT = "Guild Chat",
        MEMBERS = "Members",
        GUILD = "Guild",
        SETTINGS = "Settings",
        GUILD_SPACE = "GUILD SPACE",
        ONLINE = "%d online",
        NOT_IN_GUILD = "You are not in a guild.",
        JOIN_GUILD = "Join a guild to use this interface.",
        NO_MESSAGES = "No guild message has been recorded.",
        TYPE_MESSAGE = "Write a guild message...",
        SEND = "Send",
        SEARCH_MEMBER = "Search a member...",
        ONLINE_ONLY = "Online only",
        NO_MEMBER = "No member found.",
        LEVEL = "Level",
        CLASS = "Class",
        RANK = "Rank",
        ZONE = "Zone",
        OFFLINE = "Offline",
        ONLINE_NOW = "Online now",
        LAST_CONNECTION = "Last connection",
        LAST_CONNECTION_UNKNOWN = "Last connection unknown",
        AGO = "%s ago",
        TIME_YEAR = "%d year",
        TIME_YEARS = "%d years",
        TIME_MONTH = "%d month",
        TIME_MONTHS = "%d months",
        TIME_DAY = "%d day",
        TIME_DAYS = "%d days",
        TIME_HOUR = "%d hour",
        TIME_HOURS = "%d hours",
        MAIN = "MAIN",
        WHISPER = "Whisper",
        INVITE = "Invite",
        IGNORE = "Ignore",
        UNIGNORE = "Unignore",
        SET_MAIN = "Set as Main",
        REROLL_OF = "Alt of \"%s\"",
        OWN_CHARACTER_ONLY = "Only characters from your own account can be set as Main.",
        PERSONAL_NOTE = "Personal Note...",
        LOGIN_ALERT = "Mention when online",
        CANCEL = "Cancel",
        NOTE_TITLE = "Personal note",
        NOTE_HELP = "This note is stored locally and is visible only to you.",
        NOTE_PLACEHOLDER = "Write a private note about this guild member...",
        SAVE = "Save",
        CLEAR = "Clear",
        PLAYER_CONNECTED = "%s has come online.",
        PLAYER_DISCONNECTED = "%s has gone offline.",
        SUPER_CONNECTED = "Player: %s has just come online!",
        GUILD_MOTD = "Message of the day",
        GUILD_INFO = "Guild information",
        NO_MOTD = "No message of the day.",
        NO_GUILD_INFO = "No guild description has been set.",
        SHARED_HISTORY = "Shared guild history",
        HISTORY_STATS = "%d saved message(s) · %d day retention",
        GUILD_IMAGE = "Guild image",
        GUILD_IMAGE_HELP = "The guild master can choose a built-in image shared automatically with addon users.",
        CHANGE_GUILD_IMAGE = "Change guild image",
        GUILD_MASTER_ONLY = "Only the guild master can change the shared guild image.",
        CHARACTER_IMAGE = "Character image",
        CHARACTER_IMAGE_HELP = "Choose an avatar that other guild members using the addon will see.",
        CHANGE_CHARACTER_IMAGE = "Change character image",
        IMAGE_PICKER = "Choose an image",
        BUILTIN_IMAGES = "Built-in images",
        CUSTOM_TEXTURE = "Custom texture path",
        CUSTOM_TEXTURE_HELP = "Custom files are visible only if every player has the same file installed. Enter the texture path without .tga or .blp.",
        APPLY = "Apply",
        CLOSE = "Close",
        LANGUAGE = "Language",
        LANGUAGE_HELP = "Automatic uses French on a French client and English on every other client.",
        AUTO = "Automatic",
        ENGLISH = "English",
        FRENCH = "Français",
        NOTIFICATIONS = "Notifications",
        NOTIFY_ONLINE = "Notify when a guild member comes online",
        NOTIFY_OFFLINE = "Notify when a guild member goes offline",
        DISPLAY = "Display",
        SHOW_OFFLINE = "Show offline members",
        SHOW_LAUNCHER = "Show movable Guild tab",
        KEYBIND = "Opening key",
        CURRENT_KEY = "Current key: %s",
        CHANGE_KEY = "Change key",
        CLEAR_KEY = "Clear key",
        PRESS_KEY = "Press the new key now",
        PRESS_KEY_HELP = "Escape cancels. Backspace clears the binding.",
        KEY_CHANGED = "The opening key is now %s.",
        KEY_CLEARED = "The opening key has been cleared.",
        KEY_COMBAT = "A key binding cannot be changed during combat.",
        SETTINGS_INFO = "The interface refreshes every second. Addon data is exchanged automatically every 5 seconds.",
        SYNC_READY = "Automatic sync active · every 5 sec",
        SYNC_WAITING = "Waiting for guild data",
        IMAGE_UPDATED = "The shared guild image has been updated.",
        AVATAR_UPDATED = "Your character image has been updated.",
        NOTE_SAVED = "Personal note saved for %s.",
        MAIN_SET = "%s is now your shared Main for this guild.",
        ALERT_ENABLED = "Mention when online enabled for %s.",
        ALERT_DISABLED = "Mention when online disabled for %s.",
        DEFAULT_G_SET = "G now opens G.B.G (Glayna Better Guild).",
        DEFAULT_G_BUSY = "G already has a custom binding. Change the addon key in Settings.",
        RESET_DONE = "Window positions have been reset.",
        HISTORY_OLDEST = "Oldest: %s",
        HISTORY_LATEST = "Latest: %s",
        NEVER = "Never",
        CUSTOM_NOT_SHARED = "The path is synchronized, but the image file itself cannot be transferred by a WoW addon.",
        IMAGE_INVALID = "Enter a valid texture path.",
        IGNORED = "%s has been added to your ignore list.",
        UNIGNORED = "%s has been removed from your ignore list.",
        INVITED = "Invitation sent to %s.",
        BRAND = "G.B.G — GLAYNA BETTER GUILD",
        VERSION = "Version %s",
        PLAYER_PROFILE = "Member profile",
        SELECT_MEMBER = "Select a guild member to view their profile.",
        LOCAL_DATA = "Local information",
        SHARED_DATA = "Shared with addon users",
        MENTION = "Mention in guild chat",
        MENTION_FLASH = "Full-screen flash when you are mentioned",
        MENTION_FLASH_HELP = "Shows one green pulse when your name or @YourName appears in a live guild message.",
        MENTION_UNREAD_GLOW = "Pulse the Guild notification border for unread mentions",
        MENTION_UNREAD_GLOW_HELP = "Keeps the Guild tab and notification launcher glowing green until you open Guild Chat.",
        LOGIN_MENTION_LIST = "Members mentioned when online",
        LOGIN_MENTION_LIST_EMPTY = "No member selected.",
        CLEAR_LOGIN_MENTION_LIST = "Clear list",
        REMOVE_LOGIN_MENTION = "Remove",
        LATEST_MESSAGES = "Latest messages",
        PORTRAIT_HEROES = "Heroes",
        PORTRAIT_BOSSES = "Bosses",
        PORTRAIT_RACES = "Races",
        PORTRAIT_EMBLEMS = "Emblems",
        PORTRAIT_TOOLTIP = "Click to use this portrait",
    },
    fr = {
        BINDING_TOGGLE = "Ouvrir / fermer l'interface de guilde",
        LAUNCHER = "Guilde",
        LAUNCHER_OPEN = "Clic gauche : ouvrir / fermer",
        LAUNCHER_MOVE = "Clic droit + glisser : déplacer",
        CHAT = "Discussion de guilde",
        MEMBERS = "Membres",
        GUILD = "Guilde",
        SETTINGS = "Paramètres",
        GUILD_SPACE = "ESPACE DE GUILDE",
        ONLINE = "%d en ligne",
        NOT_IN_GUILD = "Vous n'êtes pas dans une guilde.",
        JOIN_GUILD = "Rejoignez une guilde pour utiliser cette interface.",
        NO_MESSAGES = "Aucun message de guilde enregistré.",
        TYPE_MESSAGE = "Écrire un message de guilde...",
        SEND = "Envoyer",
        SEARCH_MEMBER = "Rechercher un membre...",
        ONLINE_ONLY = "En ligne uniquement",
        NO_MEMBER = "Aucun membre trouvé.",
        LEVEL = "Niveau",
        CLASS = "Classe",
        RANK = "Rang",
        ZONE = "Zone",
        OFFLINE = "Hors ligne",
        ONLINE_NOW = "En ligne maintenant",
        LAST_CONNECTION = "Dernière connexion",
        LAST_CONNECTION_UNKNOWN = "Dernière connexion inconnue",
        AGO = "Il y a %s",
        TIME_YEAR = "%d an",
        TIME_YEARS = "%d ans",
        TIME_MONTH = "%d mois",
        TIME_MONTHS = "%d mois",
        TIME_DAY = "%d jour",
        TIME_DAYS = "%d jours",
        TIME_HOUR = "%d heure",
        TIME_HOURS = "%d heures",
        MAIN = "MAIN",
        WHISPER = "Chuchoter",
        INVITE = "Inviter",
        IGNORE = "Ignorer",
        UNIGNORE = "Ne plus ignorer",
        SET_MAIN = "Définir comme Main",
        REROLL_OF = "Reroll de \"%s\"",
        OWN_CHARACTER_ONLY = "Seuls les personnages de votre propre compte peuvent être définis comme Main.",
        PERSONAL_NOTE = "Note personnelle...",
        LOGIN_ALERT = "Mentionner lors de la connexion",
        CANCEL = "Annuler",
        NOTE_TITLE = "Note personnelle",
        NOTE_HELP = "Cette note reste locale et n'est visible que par vous.",
        NOTE_PLACEHOLDER = "Écrire une note privée sur ce membre de guilde...",
        SAVE = "Enregistrer",
        CLEAR = "Effacer",
        PLAYER_CONNECTED = "%s vient de se connecter.",
        PLAYER_DISCONNECTED = "%s vient de se déconnecter.",
        SUPER_CONNECTED = "Le joueur : %s vient de se connecter !",
        GUILD_MOTD = "Message du jour",
        GUILD_INFO = "Informations de guilde",
        NO_MOTD = "Aucun message du jour.",
        NO_GUILD_INFO = "Aucune présentation de guilde n'a été renseignée.",
        SHARED_HISTORY = "Historique de guilde partagé",
        HISTORY_STATS = "%d message(s) conservé(s) · rétention %d jours",
        GUILD_IMAGE = "Image de guilde",
        GUILD_IMAGE_HELP = "Le chef de guilde peut choisir une image intégrée, automatiquement partagée avec les utilisateurs de l'addon.",
        CHANGE_GUILD_IMAGE = "Changer l'image de guilde",
        GUILD_MASTER_ONLY = "Seul le chef de guilde peut modifier l'image de guilde partagée.",
        CHARACTER_IMAGE = "Image du personnage",
        CHARACTER_IMAGE_HELP = "Choisissez un avatar visible par les autres membres utilisant l'addon.",
        CHANGE_CHARACTER_IMAGE = "Changer l'image du personnage",
        IMAGE_PICKER = "Choisir une image",
        BUILTIN_IMAGES = "Images intégrées",
        CUSTOM_TEXTURE = "Chemin de texture personnalisé",
        CUSTOM_TEXTURE_HELP = "Un fichier personnalisé est visible seulement si chaque joueur possède le même fichier. Saisissez le chemin sans .tga ni .blp.",
        APPLY = "Appliquer",
        CLOSE = "Fermer",
        LANGUAGE = "Langue",
        LANGUAGE_HELP = "Automatique utilise le français sur un client français et l'anglais sur tous les autres clients.",
        AUTO = "Automatique",
        ENGLISH = "English",
        FRENCH = "Français",
        NOTIFICATIONS = "Notifications",
        NOTIFY_ONLINE = "Notifier la connexion d'un membre de guilde",
        NOTIFY_OFFLINE = "Notifier la déconnexion d'un membre de guilde",
        DISPLAY = "Affichage",
        SHOW_OFFLINE = "Afficher les membres hors ligne",
        SHOW_LAUNCHER = "Afficher l'onglet Guilde déplaçable",
        KEYBIND = "Touche d'ouverture",
        CURRENT_KEY = "Touche actuelle : %s",
        CHANGE_KEY = "Changer la touche",
        CLEAR_KEY = "Effacer la touche",
        PRESS_KEY = "Appuyez maintenant sur la nouvelle touche",
        PRESS_KEY_HELP = "Échap annule. Retour arrière efface le raccourci.",
        KEY_CHANGED = "La touche d'ouverture est maintenant %s.",
        KEY_CLEARED = "Le raccourci d'ouverture a été effacé.",
        KEY_COMBAT = "Impossible de modifier un raccourci en combat.",
        SETTINGS_INFO = "L'interface se rafraîchit chaque seconde. Les données addon sont échangées automatiquement toutes les 5 secondes.",
        SYNC_READY = "Synchronisation automatique active · toutes les 5 s",
        SYNC_WAITING = "En attente des données de guilde",
        IMAGE_UPDATED = "L'image de guilde partagée a été mise à jour.",
        AVATAR_UPDATED = "L'image de votre personnage a été mise à jour.",
        NOTE_SAVED = "Note personnelle enregistrée pour %s.",
        MAIN_SET = "%s est maintenant votre Main partagé pour cette guilde.",
        ALERT_ENABLED = "Mention lors de la connexion activée pour %s.",
        ALERT_DISABLED = "Mention lors de la connexion désactivée pour %s.",
        DEFAULT_G_SET = "G ouvre maintenant G.B.G (Glayna Better Guild).",
        DEFAULT_G_BUSY = "G possède déjà un raccourci personnalisé. Changez la touche dans les paramètres.",
        RESET_DONE = "La position des fenêtres a été réinitialisée.",
        HISTORY_OLDEST = "Plus ancien : %s",
        HISTORY_LATEST = "Plus récent : %s",
        NEVER = "Jamais",
        CUSTOM_NOT_SHARED = "Le chemin est synchronisé, mais le fichier image lui-même ne peut pas être transféré par un addon WoW.",
        IMAGE_INVALID = "Saisissez un chemin de texture valide.",
        IGNORED = "%s a été ajouté à votre liste d'ignorés.",
        UNIGNORED = "%s a été retiré de votre liste d'ignorés.",
        INVITED = "Invitation envoyée à %s.",
        BRAND = "G.B.G — GLAYNA BETTER GUILD",
        VERSION = "Version %s",
        PLAYER_PROFILE = "Profil du membre",
        SELECT_MEMBER = "Sélectionnez un membre de guilde pour afficher son profil.",
        LOCAL_DATA = "Informations locales",
        SHARED_DATA = "Partagé avec les utilisateurs de l'addon",
        MENTION = "Mentionner dans le chat de guilde",
        MENTION_FLASH = "Flash plein écran quand vous êtes mentionné",
        MENTION_FLASH_HELP = "Affiche une seule pulsation verte lorsque votre nom ou @VotreNom apparaît dans un message de guilde reçu en direct.",
        MENTION_UNREAD_GLOW = "Faire pulser les notifications lors d’une mention non lue",
        MENTION_UNREAD_GLOW_HELP = "Maintient l’onglet Guilde et son lanceur en surbrillance verte jusqu’à l’ouverture de la Discussion de guilde.",
        LOGIN_MENTION_LIST = "Membres à mentionner lors de la connexion",
        LOGIN_MENTION_LIST_EMPTY = "Aucun membre sélectionné.",
        CLEAR_LOGIN_MENTION_LIST = "Vider la liste",
        REMOVE_LOGIN_MENTION = "Supprimer",
        LATEST_MESSAGES = "Derniers messages",
        PORTRAIT_HEROES = "Héros",
        PORTRAIT_BOSSES = "Boss",
        PORTRAIT_RACES = "Races",
        PORTRAIT_EMBLEMS = "Emblèmes",
        PORTRAIT_TOOLTIP = "Cliquer pour utiliser ce portrait",
    },
}

if not GMG.GetLanguage then
function GMG:GetLanguage()
    local forced = self.db and self.db.profile and self.db.profile.language or "auto"
    if forced == "fr" or forced == "en" then return forced end
    return GetLocale and GetLocale() == "frFR" and "fr" or "en"
end
end

if not GMG.L then
function GMG:L(key, ...)
    local language = self:GetLanguage()
    local dictionary = self.Locales[language] or self.Locales.en
    local value = dictionary[key] or self.Locales.en[key] or key
    if select("#", ...) > 0 then
        return string.format(value, ...)
    end
    return value
end
end

if not GMG.ApplyBindingLocale then
function GMG:ApplyBindingLocale()
    BINDING_HEADER_GLAYNABETTERGUILD = "G.B.G (Glayna Better Guild)"
    BINDING_NAME_GMG_TOGGLE = self:L("BINDING_TOGGLE")
end
end

GMG.name = "GBG"
GMG.displayName = "G.B.G (Glayna Better Guild)"
GMG.version = "1.8.6"
GMG.commPrefix = "GMG2"
GMG.protocolVersion = 4
GMG.historyVersion = 2
GMG.refreshInterval = 1
GMG.syncInterval = 5

local floor = math.floor
local max = math.max
local min = math.min
local sort = table.sort
local tinsert = table.insert
local tremove = table.remove
local tostring = tostring
local tonumber = tonumber
local strlower = string.lower
local format = string.format
local time = time
local date = date

GMG.DEFAULT_AVATAR = "Interface\\Icons\\INV_Misc_QuestionMark"
GMG.DEFAULT_GUILD_IMAGE = "Interface\\Icons\\INV_BannerPVP_02"
GMG.IMAGE_CATEGORIES = {}

GMG.IMAGE_PRESETS = {
    { category = "all", name = "Arcane Mist Ranger", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_01" },
    { category = "all", name = "Void Elf Assassin", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_02" },
    { category = "all", name = "Crimson Shadow Hunter", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_03" },
    { category = "all", name = "Broken Demon Knight", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_04" },
    { category = "all", name = "Cosmic Dark Elf", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_05" },
    { category = "all", name = "Violet Shadow Elf", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_06" },
    { category = "all", name = "Golden Cosmic Guardian", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_07" },
    { category = "all", name = "Stormcoil Tinker", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_08" },
    { category = "all", name = "Overcharged Goblin Tinker", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_09" },
    { category = "all", name = "Spirit Wolf Shaman", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_10" },
    { category = "all", name = "Felsworn Demon Warrior", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_11" },
    { category = "all", name = "Spectral Beast Warrior", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_12" },
    { category = "all", name = "Arcane Vortex Spellblade", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_13" },
    { category = "all", name = "Runic Mystic Warrior", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_14" },
    { category = "all", name = "Dragon Spirit Dark Knight", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_15" },
    { category = "all", name = "Stonewood Elementalist", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_16" },
    { category = "all", name = "Mad Goblin Alchemist", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_17" },
    { category = "all", name = "Mystic Brewmaster", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_18" },
    { category = "all", name = "Astral Starcaller", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_19" },
    { category = "all", name = "Celestial Chronomancer", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_20" },
    { category = "all", name = "Legendary Flame Mage", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_21" },
    { category = "all", name = "Heroic Arcane Bard", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_22" },
    { category = "all", name = "Jade Spirit Monk", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_23" },
    { category = "all", name = "Plague Doctor Alchemist", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_24" },
    { category = "all", name = "Lost Souls Necromancer", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_25" },
    { category = "all", name = "Radiant Sun Paladin", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_26" },
    { category = "all", name = "Flame Orc Warlord", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_27" },
    { category = "all", name = "Dread Orc Shaman", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_28" },
    { category = "all", name = "Spectral Companion Ranger", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_29" },
    { category = "all", name = "Frozen Runeblade King", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_30" },
    { category = "all", name = "Elemental Fury Shaman", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_31" },
    { category = "all", name = "Mystic Runeblade Sorcerer", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_32" },
    { category = "all", name = "Frost Archmage", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_33" },
    { category = "all", name = "Majestic Sea Witch", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_34" },
    { category = "all", name = "Tempest Sea Sorceress", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_35" },
    { category = "all", name = "Voodoo Soul Witch", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_36" },
    { category = "all", name = "Necrotic Sovereign", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_37" },
    { category = "all", name = "Infernal Gunslinger", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_38" },
    { category = "all", name = "Flame Dragon", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_39" },
    { category = "all", name = "Cosmic Void Eye", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_40" },
    { category = "all", name = "A Dark Fantasy Close Up Portrait Icon Overall A S", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_41" },
    { category = "all", name = "A Dramatic Fantasy Game Icon Style Close Up Port", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_42" },
    { category = "all", name = "A Dramatic Fantasy Game Style Portrait Icon A Clo", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_43" },
    { category = "all", name = "A Highly Detailed Fantasy Dark Rpg Icon Portrait", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_44" },
    { category = "all", name = "Alchimiste De La Peste Lumineuse", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_45" },
    { category = "all", name = "Alchimiste De La Toxicite Eclatee", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_46" },
    { category = "all", name = "Archere Magique Dans Une Brume Pourpre", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_47" },
    { category = "all", name = "Assassin Elf Dans L Energie Violette", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_48" },
    { category = "all", name = "Assassin Elfe Et Magie Violette", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_49" },
    { category = "all", name = "Assassin Spirit Et Energie Verte", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_50" },
    { category = "all", name = "Chasseur De L Ombre Et Magie Rouge", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_51" },
    { category = "all", name = "Chevalier Demoniaque En Armure Brisee", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_52" },
    { category = "all", name = "Combat Feerique Dans Un Atelier En Ruines", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_53" },
    { category = "all", name = "Elfe Mystique Sous La Lueur Lunaire", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_54" },
    { category = "all", name = "Elfe Noir Dans L Energie Cosmique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_55" },
    { category = "all", name = "Elfe Sombre Et Magie Violet", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_56" },
    { category = "all", name = "Furie D Une Mage Sanguinaire", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_57" },
    { category = "all", name = "Gardien Cosmique Aux Ailes D Or", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_58" },
    { category = "all", name = "Gobelin Steampunk Eclatant D Energie", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_59" },
    { category = "all", name = "Gobelins Et Eclats D Energie Steampunk", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_60" },
    { category = "all", name = "Guerrier Chaman Mystique Et Esprits", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_61" },
    { category = "all", name = "Guerrier Chamanique Sous L Orage Electrique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_62" },
    { category = "all", name = "Guerrier Demoniaque Sous Energie Verdoyante", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_63" },
    { category = "all", name = "Guerrier Elfe Entoure D Energie Magique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_64" },
    { category = "all", name = "Guerrier Et Bete Spectrale Enragee", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_65" },
    { category = "all", name = "Guerrier Magique Dans Un Vortex Energetique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_66" },
    { category = "all", name = "Guerrier Mystique Dans Une Aura Magique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_67" },
    { category = "all", name = "Guerrier Mystique Et Dragon Spectral", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_68" },
    { category = "all", name = "Guerrier Mystique Et Loup Spectral", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_69" },
    { category = "all", name = "Guerrier Shamanique Sous Une Tempete Electrique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_70" },
    { category = "all", name = "Guerrier Sombre Et Esprit Draconique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_71" },
    { category = "all", name = "Guerrier Sombre Et Energie Verte", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_72" },
    { category = "all", name = "Guerrier Elementaire De Pierre Et Bois", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_73" },
    { category = "all", name = "Guerriere Elfe Et Esprit Felin", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_74" },
    { category = "all", name = "Guerriere Necromancienne Sur Champ De Bataille", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_75" },
    { category = "all", name = "Guerriere Sacree Rayonnante En Or", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_76" },
    { category = "all", name = "Guerriere Sinistre Et Magie Sanglante", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_77" },
    { category = "all", name = "Icones De Sorts Fantastiques Lumineuses", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_78" },
    { category = "all", name = "Laboratoire Alchimique Du Gobelin Fou", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_79" },
    { category = "all", name = "Le Docteur De La Peste Toxique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_80" },
    { category = "all", name = "Le Maitre Brasseur Et Sa Magie", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_81" },
    { category = "all", name = "Le Paladin Lumineux Et Puissant", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_82" },
    { category = "all", name = "Mage Astral Mystique Dans L Univers", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_83" },
    { category = "all", name = "Mage Du Temps Et L Horloger Celeste", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_84" },
    { category = "all", name = "Mage Du Temps Et Magie Mystique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_85" },
    { category = "all", name = "Mage Legendaire Au Coeur Du Feu", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_86" },
    { category = "all", name = "Magie Dechainee Sous La Tempete", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_87" },
    { category = "all", name = "Magie Musicale Du Barde Heroique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_88" },
    { category = "all", name = "Moine Panda En Pleine Action Magique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_89" },
    { category = "all", name = "Medecin De Peste Alchimiste Dans L Ombre", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_90" },
    { category = "all", name = "Necromancien Au Regard Percant", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_91" },
    { category = "all", name = "Necromancien Des Ames Perdues", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_92" },
    { category = "all", name = "Necromancienne Dans Une Explosion Magique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_93" },
    { category = "all", name = "Paladine Sacree De La Lumiere Doree", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_94" },
    { category = "all", name = "Portait Sombre D Un Assassin Magique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_95" },
    { category = "all", name = "Portrait D Elfe Mystique En Violet", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_96" },
    { category = "all", name = "Portrait D Elfe Mystique Et Enigmatique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_97" },
    { category = "all", name = "Portrait D Inventrice Steampunk Flamboyante", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_98" },
    { category = "all", name = "Portrait D Orc Guerrier Enflamme", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_99" },
    { category = "all", name = "Portrait D Un Mage Mysterieux", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_100" },
    { category = "all", name = "Portrait D Un Necromancien Furieux", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_101" },
    { category = "all", name = "Portrait D Une Chasseuse De Demons", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_102" },
    { category = "all", name = "Portrait D Une Guerriere Enflammee", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_103" },
    { category = "all", name = "Portrait D Une Ingenieure Steampunk Lumineuse", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_104" },
    { category = "all", name = "Portrait D Une Sorciere Maudite", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_105" },
    { category = "all", name = "Portrait De Sorcier Au Feu Sacre", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_106" },
    { category = "all", name = "Portrait Heroique De Lumiere Doree", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_107" },
    { category = "all", name = "Portrait Menacant D Un Chaman Orc", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_108" },
    { category = "all", name = "Puissante Maitresse Des Arts Martiaux", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_109" },
    { category = "all", name = "Ranger Druid And Spectral Companion", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_110" },
    { category = "all", name = "Reine Des Tempetes Et De La Foudre", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_111" },
    { category = "all", name = "Rituel Chaotique De La Sorciere", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_112" },
    { category = "all", name = "Roi Des Glaces Et Son Epee", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_113" },
    { category = "all", name = "Shaman Orc En Pleine Furie", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_114" },
    { category = "all", name = "Sorcier Des Flammes En Fusion", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_115" },
    { category = "all", name = "Sorcier Guerrier En Energie Mystique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_116" },
    { category = "all", name = "Sorcier Mystique Aux Yeux Lumineux", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_117" },
    { category = "all", name = "Sorciere De Feu Dans Un Cadre Mystique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_118" },
    { category = "all", name = "Sorciere De Glace En Action", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_119" },
    { category = "all", name = "Sorciere Des Mers En Majeste", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_120" },
    { category = "all", name = "Sorciere Des Tempetes Et Des Mers", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_121" },
    { category = "all", name = "Sorciere En Flammes Sur Un Champ De Ruines", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_122" },
    { category = "all", name = "Sorciere En Pleine Bataille Magique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_123" },
    { category = "all", name = "Sorciere Mystique Aux Runes Brillantes", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_124" },
    { category = "all", name = "Sorciere Mystique Et Magie Temporelle", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_125" },
    { category = "all", name = "Sorciere Necromancienne Et Energie Spectrale", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_126" },
    { category = "all", name = "Sorciere Sombre Et Energie Magique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_127" },
    { category = "all", name = "Sorciere Vampirique Aux Pouvoirs Occultes", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_128" },
    { category = "all", name = "Sorciere Vaudou En Pleine Invocation", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_129" },
    { category = "all", name = "Souverain Des Morts Et Energie Necrotique", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_130" },
    { category = "all", name = "Tireur D Elite En Flammes", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_131" },
    { category = "all", name = "Tete De Dragon Enflammee", texture = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_132" },

}

local DEFAULTS = {
    profile = {
        language = "auto",
        mainPoint = "CENTER",
        mainRelativePoint = "CENTER",
        mainX = 0,
        mainY = 0,
        mainWidth = 1080,
        mainHeight = 760,
        launcherPoint = "LEFT",
        launcherRelativePoint = "LEFT",
        launcherX = 0,
        launcherY = 110,
        launcherShown = true,
        showOffline = true,
        notifyOnline = true,
        notifyOffline = false,
        mentionFlash = true,
        mentionUnreadGlow = true,
        temporaryMentionHighlight = true,
        chatFontSize = 12,
        hideIneligibleDungeonGroups = false,
        retentionDays = 30,
        maxHistory = 1000,
        defaultGBindingHandled = false,
        openingKey = false,
        openingBindingSet = 0,
        settingsRevision = 1,
        lastTab = "chat",
    },
    account = {
        ownerID = "",
        identityRevision = 1,
    },
    guilds = {},
    characters = {},
}

local function CopyDefaults(source, destination)
    if type(destination) ~= "table" then destination = {} end
    for key, value in pairs(source) do
        if type(value) == "table" then
            destination[key] = CopyDefaults(value, destination[key])
        elseif destination[key] == nil then
            destination[key] = value
        end
    end
    return destination
end

function GMG:Trim(text)
    if not text then return "" end
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

function GMG:GetOfflineDurationSeconds(years, months, days, hours)
    years = max(0, tonumber(years) or 0)
    months = max(0, tonumber(months) or 0)
    days = max(0, tonumber(days) or 0)
    hours = max(0, tonumber(hours) or 0)
    -- The 3.3.5 roster API exposes elapsed calendar units rather than a timestamp.
    -- A 30-day month gives a stable estimated date while preserving the exact
    -- human-readable years/months/days/hours returned by the client.
    return (((years * 12 + months) * 30 + days) * 24 + hours) * 3600
end

function GMG:FormatOfflineDuration(years, months, days, hours)
    years = max(0, tonumber(years) or 0)
    months = max(0, tonumber(months) or 0)
    days = max(0, tonumber(days) or 0)
    hours = max(0, tonumber(hours) or 0)
    local parts = {}
    local function Add(value, singularKey, pluralKey)
        if value > 0 and #parts < 2 then
            parts[#parts + 1] = self:L(value == 1 and singularKey or pluralKey, value)
        end
    end
    Add(years, "TIME_YEAR", "TIME_YEARS")
    Add(months, "TIME_MONTH", "TIME_MONTHS")
    Add(days, "TIME_DAY", "TIME_DAYS")
    Add(hours, "TIME_HOUR", "TIME_HOURS")
    if #parts == 0 then return self:L("TIME_HOUR", 1) end
    return table.concat(parts, " ")
end

function GMG:GetLastConnectionTexts(member)
    if not member then return "", "" end
    if member.online then return self:L("ONLINE_NOW"), "" end
    local duration = self:FormatOfflineDuration(member.yearsOffline, member.monthsOffline, member.daysOffline, member.hoursOffline)
    local ago = self:L("AGO", duration)
    if member.lastOnlineAt and member.lastOnlineAt > 0 then
        return date("%d/%m/%Y %H:%M", member.lastOnlineAt), ago
    end
    return "—", ago
end

function GMG:Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff9a7cffGMG|r  " .. tostring(message))
    end
end

function GMG:Hash(text)
    local hash = 5381
    text = tostring(text or "")
    for index = 1, string.len(text) do
        hash = (hash * 33 + string.byte(text, index)) % 4294967296
    end
    return format("%08x", hash)
end

function GMG:NormalizeName(name)
    if not name then return "" end
    name = string.gsub(name, "%s", "")
    return string.match(name, "^[^-]+") or name
end

function GMG:GetPlayerName()
    return self:NormalizeName(UnitName and UnitName("player") or "")
end

function GMG:GetCharacterKeyFor(name)
    local realm = GetRealmName and GetRealmName() or "UnknownRealm"
    return tostring(realm) .. "::" .. self:NormalizeName(name)
end

function GMG:GetCharacterKey()
    return self:GetCharacterKeyFor(self:GetPlayerName())
end

function GMG:EnsureOwnerID()
    if not self.db then return "" end
    self.db.account = self.db.account or {}
    local ownerID = tostring(self.db.account.ownerID or "")
    if ownerID == "" then
        local seed = table.concat({
            tostring(GetRealmName and GetRealmName() or "UnknownRealm"),
            tostring(self:GetPlayerName()),
            tostring(time()),
            tostring(floor((GetTime and GetTime() or 0) * 1000)),
            tostring(math.random and math.random(1, 99999999) or 1),
        }, ":")
        ownerID = self:Hash(seed) .. self:Hash(seed .. ":GlaynaBetterGuild")
        self.db.account.ownerID = ownerID
        self.db.account.identityRevision = max(1, tonumber(self.db.account.identityRevision) or 1)
    end
    return ownerID
end

function GMG:GetOwnerID()
    return self:EnsureOwnerID()
end

function GMG:GetGuildName()
    local guildName = GetGuildInfo and GetGuildInfo("player")
    return guildName
end

function GMG:GetGuildKey()
    local guildName = self:GetGuildName()
    if not guildName or guildName == "" then return nil end
    local realm = GetRealmName and GetRealmName() or "UnknownRealm"
    return tostring(realm) .. "::" .. tostring(guildName)
end

function GMG:GetGuildHash()
    local key = self:GetGuildKey()
    return key and self:Hash(key) or nil
end

function GMG:IsInGuild()
    return self:GetGuildKey() ~= nil
end

function GMG:GetGuildStore(create)
    local key = self:GetGuildKey()
    if not key or not self.db then return nil end
    local store = self.db.guilds[key]
    if not store and create then
        store = {
            version = self.historyVersion,
            messages = {},
            lastPrune = 0,
            notes = {},
            highlighted = {},
            localMainName = nil,
            profiles = {},
            ownerMains = {},
            guildImage = nil,
        }
        self.db.guilds[key] = store
    end
    if store then
        store.messages = store.messages or {}
        store.notes = store.notes or {}
        store.highlighted = store.highlighted or {}
        store.profiles = store.profiles or {}
        store.ownerMains = store.ownerMains or {}
    end
    return store
end

function GMG:GetCharacterStoreFor(name, create)
    if not self.db then return nil end
    local key = self:GetCharacterKeyFor(name)
    local store = self.db.characters[key]
    if not store and create then
        store = { avatar = self.DEFAULT_AVATAR, avatarRevision = 1, ownerID = self:GetOwnerID() }
        self.db.characters[key] = store
    end
    if store then
        if not store.avatar or store.avatar == "" then store.avatar = self.DEFAULT_AVATAR end
        if not store.ownerID or store.ownerID == "" then store.ownerID = self:GetOwnerID() end
    end
    return store
end

function GMG:GetCharacterStore(create)
    return self:GetCharacterStoreFor(self:GetPlayerName(), create)
end

function GMG:GetOwnAvatar()
    local store = self:GetCharacterStore(true)
    return store and store.avatar or self.DEFAULT_AVATAR
end

function GMG:SetOwnAvatar(texture)
    texture = self:Trim(texture)
    if texture == "" then return false end
    local store = self:GetCharacterStore(true)
    store.avatar = texture
    store.avatarRevision = max((tonumber(store.avatarRevision) or 0) + 1, time())
    self:StoreProfile(self:GetPlayerName(), texture, store.avatarRevision, self:GetPlayerName(), self:GetOwnerID())
    if self.QueueProfileBroadcast then self:QueueProfileBroadcast(true) end
    if self.RefreshAll then self:RefreshAll(true) end
    self:Print(self:L("AVATAR_UPDATED"))
    return true
end

function GMG:GetProfile(name)
    local guildStore = self:GetGuildStore(false)
    if not guildStore then return nil end
    return guildStore.profiles[strlower(self:NormalizeName(name))]
end

function GMG:GetAvatarFor(name)
    local profile = self:GetProfile(name)
    return profile and profile.texture or self.DEFAULT_AVATAR
end

function GMG:StoreOwnerMain(ownerID, mainName, revision, source)
    local guildStore = self:GetGuildStore(true)
    if not guildStore then return false end
    ownerID = self:Trim(ownerID)
    mainName = self:NormalizeName(mainName)
    revision = tonumber(revision) or 0
    if ownerID == "" or mainName == "" then return false end
    guildStore.ownerMains = guildStore.ownerMains or {}
    local current = guildStore.ownerMains[ownerID]
    if current and (tonumber(current.revision) or 0) > revision then return false end
    if current and current.name == mainName and (tonumber(current.revision) or 0) == revision then return false end
    guildStore.ownerMains[ownerID] = {
        name = mainName,
        revision = revision,
        source = source,
        seenAt = time(),
    }
    self.rosterDirty = true
    return true
end

function GMG:GetOwnerMainRecord(ownerID)
    local guildStore = self:GetGuildStore(false)
    if not guildStore or not guildStore.ownerMains then return nil end
    return guildStore.ownerMains[self:Trim(ownerID)]
end

function GMG:GetOwnerMainName(ownerID)
    local record = self:GetOwnerMainRecord(ownerID)
    return record and self:NormalizeName(record.name) or ""
end

function GMG:GetProfileOwnerID(name)
    local profile = self:GetProfile(name)
    return profile and tostring(profile.ownerID or "") or ""
end

function GMG:IsOwnCharacter(name)
    name = self:NormalizeName(name)
    if name == "" then return false end
    if strlower(name) == strlower(self:GetPlayerName()) then return true end
    local profileOwner = self:GetProfileOwnerID(name)
    if profileOwner ~= "" and profileOwner == self:GetOwnerID() then return true end
    return self.db and self.db.characters and self.db.characters[self:GetCharacterKeyFor(name)] ~= nil
end

function GMG:GetMainNameForCharacter(name)
    local ownerID = self:GetProfileOwnerID(name)
    if ownerID == "" and self:IsOwnCharacter(name) then ownerID = self:GetOwnerID() end
    if ownerID == "" then return "" end
    return self:GetOwnerMainName(ownerID)
end

function GMG:IsMainCharacter(name)
    local mainName = self:GetMainNameForCharacter(name)
    return mainName ~= "" and strlower(mainName) == strlower(self:NormalizeName(name))
end

function GMG:GetCharacterRoleText(name)
    local mainName = self:GetMainNameForCharacter(name)
    if mainName == "" then return "", nil end
    if strlower(mainName) == strlower(self:NormalizeName(name)) then
        return self:L("MAIN"), "main"
    end
    return self:L("REROLL_OF", mainName), "reroll"
end

function GMG:StoreProfile(name, texture, revision, source, ownerID, mainName, mainRevision)
    local guildStore = self:GetGuildStore(true)
    if not guildStore then return false end
    name = self:NormalizeName(name)
    texture = self:Trim(texture)
    revision = tonumber(revision) or 0
    ownerID = self:Trim(ownerID)
    mainName = self:NormalizeName(mainName)
    mainRevision = tonumber(mainRevision) or 0
    if name == "" or texture == "" then return false end

    local key = strlower(name)
    local current = guildStore.profiles[key]
    local changed = false
    if not current then
        current = { name = name, texture = texture, revision = revision }
        guildStore.profiles[key] = current
        changed = true
    elseif (tonumber(current.revision) or 0) <= revision then
        if current.texture ~= texture or (tonumber(current.revision) or 0) ~= revision then
            current.texture = texture
            current.revision = revision
            changed = true
        end
    end

    current.name = name
    if ownerID ~= "" and (not current.ownerID or current.ownerID == "" or current.ownerID == ownerID) then
        if current.ownerID ~= ownerID then changed = true end
        current.ownerID = ownerID
    end
    current.source = source
    current.seenAt = time()

    if ownerID ~= "" and mainName ~= "" then
        if self:StoreOwnerMain(ownerID, mainName, mainRevision, source) then changed = true end
    end
    if changed then self.rosterDirty = true end
    return changed
end

function GMG:EnsureOwnProfileIdentity(name)
    name = self:NormalizeName(name or self:GetPlayerName())
    if name == "" then return nil end
    local character = self:GetCharacterStoreFor(name, true)
    local profile = self:GetProfile(name)
    local revision = character and tonumber(character.avatarRevision) or (profile and tonumber(profile.revision)) or 1
    local texture = character and character.avatar or (profile and profile.texture) or self.DEFAULT_AVATAR
    self:StoreProfile(name, texture, revision, self:GetPlayerName(), self:GetOwnerID())
    return self:GetProfile(name)
end

function GMG:GetGuildImage()
    local store = self:GetGuildStore(false)
    return store and store.guildImage or nil
end

function GMG:GetGuildImageTexture()
    local image = self:GetGuildImage()
    return image and image.texture or self.DEFAULT_GUILD_IMAGE
end

function GMG:IsGuildMemberName(name)
    name = strlower(self:NormalizeName(name))
    if name == "" then return false end
    for index = 1, #(self.rosterMembers or {}) do
        if strlower(self:NormalizeName(self.rosterMembers[index].name)) == name then return true end
    end
    return false
end

function GMG:IsGuildMasterName(name)
    name = strlower(self:NormalizeName(name))
    if name == "" then return false end
    local members = self.rosterMembers or {}
    for index = 1, #members do
        local member = members[index]
        if strlower(self:NormalizeName(member.name)) == name then
            return tonumber(member.rankIndex) == 0
        end
    end
    return false
end

function GMG:CanEditGuildImage()
    local _, _, rankIndex = GetGuildInfo and GetGuildInfo("player")
    return tonumber(rankIndex) == 0
end

function GMG:SetGuildImage(texture)
    texture = self:Trim(texture)
    if texture == "" or not self:CanEditGuildImage() then return false end
    local store = self:GetGuildStore(true)
    if not store then return false end
    local currentRevision = store.guildImage and tonumber(store.guildImage.revision) or 0
    store.guildImage = {
        texture = texture,
        revision = max(currentRevision + 1, time()),
        author = self:GetPlayerName(),
    }
    if self.QueueGuildImageBroadcast then self:QueueGuildImageBroadcast(true) end
    if self.RefreshAll then self:RefreshAll(true) end
    self:Print(self:L("IMAGE_UPDATED"))
    return true
end

function GMG:StoreGuildImage(texture, revision, author)
    local store = self:GetGuildStore(true)
    if not store then return false end
    texture = self:Trim(texture)
    revision = tonumber(revision) or 0
    author = self:NormalizeName(author)
    if texture == "" or author == "" then return false end
    if not self:IsGuildMasterName(author) then return false end
    local currentRevision = store.guildImage and tonumber(store.guildImage.revision) or 0
    if currentRevision > revision then return false end
    if store.guildImage and store.guildImage.texture == texture and currentRevision == revision then return false end
    store.guildImage = { texture = texture, revision = revision, author = author }
    self.guildPageDirty = true
    return true
end

function GMG:GetMessages()
    local store = self:GetGuildStore(false)
    return store and store.messages or {}
end

function GMG:SortMessages()
    local store = self:GetGuildStore(false)
    if not store then return end
    sort(store.messages, function(a, b)
        if (a.ts or 0) == (b.ts or 0) then return tostring(a.id or "") < tostring(b.id or "") end
        return (a.ts or 0) < (b.ts or 0)
    end)
end

function GMG:IsDuplicateMessage(sender, text, timestamp)
    sender = self:NormalizeName(sender)
    text = tostring(text or "")
    timestamp = tonumber(timestamp) or time()
    local messages = self:GetMessages()
    for index = #messages, 1, -1 do
        local item = messages[index]
        local itemTime = tonumber(item.ts) or 0
        if itemTime < timestamp - 30 then break end
        if math.abs(itemTime - timestamp) <= 30
            and self:NormalizeName(item.sender) == sender
            and tostring(item.text or "") == text then
            return true
        end
    end
    return false
end

function GMG:BuildMessageID(sender, text, timestamp)
    local bucket = floor((tonumber(timestamp) or time()) / 10)
    return self:Hash(self:NormalizeName(sender) .. "\031" .. tostring(text or "") .. "\031" .. bucket)
end

function GMG:AddHistoryMessage(sender, text, timestamp, source, suppliedID)
    if not self:IsInGuild() then return false end
    sender = self:NormalizeName(sender)
    text = self:Trim(text)
    timestamp = tonumber(timestamp) or time()
    if sender == "" or text == "" then return false end

    local store = self:GetGuildStore(true)
    if suppliedID then
        for index = 1, #store.messages do
            if store.messages[index].id == suppliedID then return false end
        end
    end
    if self:IsDuplicateMessage(sender, text, timestamp) then return false end

    tinsert(store.messages, {
        id = suppliedID or self:BuildMessageID(sender, text, timestamp),
        ts = timestamp,
        sender = sender,
        text = text,
        source = source or "local",
    })
    self:SortMessages()
    self:PruneHistory(false)
    self.chatDirty = true
    self.guildPageDirty = true
    if self.OnHistoryChanged then self:OnHistoryChanged() end
    return true
end

function GMG:PruneHistory(force)
    local store = self:GetGuildStore(false)
    if not store then return end
    local now = time()
    if not force and now - (store.lastPrune or 0) < 300 then return end
    store.lastPrune = now
    local cutoff = now - max(1, tonumber(self.db.profile.retentionDays) or 30) * 86400
    local index = 1
    while index <= #store.messages do
        if (tonumber(store.messages[index].ts) or 0) < cutoff then
            tremove(store.messages, index)
        else
            index = index + 1
        end
    end
    local maximum = max(100, tonumber(self.db.profile.maxHistory) or 1000)
    while #store.messages > maximum do tremove(store.messages, 1) end
end

function GMG:GetHistoryBounds()
    local messages = self:GetMessages()
    if #messages == 0 then return 0, 0, 0 end
    return tonumber(messages[1].ts) or 0, tonumber(messages[#messages].ts) or 0, #messages
end

function GMG:GetPlayerClass(sender)
    local key = strlower(self:NormalizeName(sender))
    return self.rosterClassCache and self.rosterClassCache[key] or nil
end

function GMG:FormatPlayerName(sender)
    local name = self:NormalizeName(sender)
    local classFile = self:GetPlayerClass(sender)
    local color = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if color then
        return format("|cff%02x%02x%02x%s|r", floor(color.r * 255), floor(color.g * 255), floor(color.b * 255), name)
    end
    return "|cffc9d1e4" .. name .. "|r"
end

function GMG:FormatPlayerLink(sender)
    local name = self:NormalizeName(sender)
    return "|Hgmgplayer:" .. name .. "|h[" .. self:FormatPlayerName(name) .. "]|h"
end

function GMG:FormatHistoryLine(message)
    return "|cff687087[" .. date("%H:%M", tonumber(message.ts) or time()) .. "]|r "
        .. self:FormatPlayerLink(message.sender) .. ": " .. tostring(message.text or "")
end

function GMG:IsPlayerMentioned(text)
    local playerName = strlower(self:GetPlayerName() or "")
    if playerName == "" then return false end
    local message = strlower(tostring(text or ""))
    if string.find(message, "@" .. playerName, 1, true) then return true end
    local normalized = string.gsub(message, "[%c%p]", " ")
    normalized = " " .. normalized .. " "
    return string.find(normalized, " " .. playerName .. " ", 1, true) ~= nil
end

function GMG:SendGuildChat(text)
    text = self:Trim(text)
    if text == "" then return end
    if not self:IsInGuild() then self:Print(self:L("NOT_IN_GUILD")); return end
    SendChatMessage(text, "GUILD")
end

function GMG:GetPersonalNote(name)
    local store = self:GetGuildStore(false)
    if not store then return "" end
    return store.notes[strlower(self:NormalizeName(name))] or ""
end

function GMG:SetPersonalNote(name, text)
    local store = self:GetGuildStore(true)
    if not store then return end
    name = self:NormalizeName(name)
    store.notes[strlower(name)] = self:Trim(text)
    self.rosterDirty = true
    self:Print(self:L("NOTE_SAVED", name))
end

function GMG:SetOwnMain(name)
    local store = self:GetGuildStore(true)
    if not store then return false end
    name = self:NormalizeName(name)
    if not self:IsOwnCharacter(name) then
        self:Print(self:L("OWN_CHARACTER_ONLY"))
        return false
    end

    local ownerID = self:GetOwnerID()
    local current = self:GetOwnerMainRecord(ownerID)
    local revision = max((current and tonumber(current.revision) or 0) + 1, time())
    store.localMainName = name -- migration compatibility with v1.1.x
    self:EnsureOwnProfileIdentity(name)
    self:StoreOwnerMain(ownerID, name, revision, self:GetPlayerName())
    if self.QueueOwnProfilesBroadcast then self:QueueOwnProfilesBroadcast(true)
    elseif self.QueueProfileBroadcast then self:QueueProfileBroadcast(true) end
    self.rosterDirty = true
    self:Print(self:L("MAIN_SET", name))
    if self.RefreshRoster then self:RefreshRoster() end
    return true
end

function GMG:SetLocalMain(name)
    return self:SetOwnMain(name)
end

function GMG:IsLocalMain(name)
    return self:IsOwnCharacter(name) and self:IsMainCharacter(name)
end

function GMG:IsHighlighted(name)
    local store = self:GetGuildStore(false)
    return store and store.highlighted[strlower(self:NormalizeName(name))] and true or false
end

function GMG:ToggleHighlighted(name)
    local store = self:GetGuildStore(true)
    if not store then return false end
    name = self:NormalizeName(name)
    local key = strlower(name)
    store.highlighted[key] = not store.highlighted[key]
    self.rosterDirty = true
    self:Print(self:L(store.highlighted[key] and "ALERT_ENABLED" or "ALERT_DISABLED", name))
    return store.highlighted[key]
end

function GMG:IsIgnored(name)
    name = strlower(self:NormalizeName(name))
    local total = GetNumIgnores and GetNumIgnores() or 0
    for index = 1, total do
        local ignored = GetIgnoreName and GetIgnoreName(index)
        if ignored and strlower(self:NormalizeName(ignored)) == name then return true end
    end
    return false
end

function GMG:ToggleIgnore(name)
    name = self:NormalizeName(name)
    if self:IsIgnored(name) then
        if DelIgnore then DelIgnore(name) end
        self:Print(self:L("UNIGNORED", name))
    else
        if AddIgnore then AddIgnore(name) end
        self:Print(self:L("IGNORED", name))
    end
end

function GMG:Schedule(key, delay, callback)
    self.timers = self.timers or {}
    self.timers[key] = { at = GetTime() + (tonumber(delay) or 0), callback = callback }
end

function GMG:RunTimers()
    if not self.timers then return end
    local now = GetTime()
    for key, timerData in pairs(self.timers) do
        if now >= timerData.at then
            self.timers[key] = nil
            local ok, errorMessage = pcall(timerData.callback)
            if not ok then self:Print("Internal error: " .. tostring(errorMessage)) end
        end
    end
end

function GMG:PersistSettings()
    if not self.db or not self.db.profile then return end
    self.db.profile.settingsRevision = max(1, tonumber(self.db.profile.settingsRevision) or 1)
    self.db.profile.lastSavedAt = time and time() or 0
end

function GMG:RememberOpeningBinding(allowEmpty)
    if not self.db or not self.db.profile then return false end
    local key = GetBindingKey and GetBindingKey("GMG_TOGGLE")
    if key and key ~= "" then
        self.db.profile.openingKey = key
        self.db.profile.openingBindingSet = GetCurrentBindingSet and GetCurrentBindingSet() or 0
        self:PersistSettings()
        return true
    end
    if allowEmpty then
        self.db.profile.openingKey = ""
        self.db.profile.openingBindingSet = GetCurrentBindingSet and GetCurrentBindingSet() or 0
        self:PersistSettings()
        return true
    end
    return false
end

function GMG:SaveCurrentBindings()
    if not SaveBindings then return end
    local set = GetCurrentBindingSet and GetCurrentBindingSet() or 1
    if set ~= 1 and set ~= 2 then set = 1 end
    SaveBindings(set)
end

function GMG:EnsureBindingOwner()
    if not self.bindingOwner then
        self.bindingOwner = CreateFrame("Frame", "GlaynaBetterGuildBindingOwner", UIParent)
    end
    return self.bindingOwner
end

function GMG:ApplyOpeningBindingOverride(key)
    if InCombatLockdown and InCombatLockdown() then
        self:Schedule("restore-opening-binding-override", 2, function() GMG:ApplyOpeningBindingOverride(key) end)
        return false
    end
    local owner = self:EnsureBindingOwner()
    if ClearOverrideBindings then ClearOverrideBindings(owner) end
    key = key and tostring(key) or ""
    if key ~= "" and SetOverrideBinding then
        SetOverrideBinding(owner, true, key, "GMG_TOGGLE")
    end
    return true
end

function GMG:RestoreOpeningBinding()
    if not self.db or not self.db.profile then return false end
    if InCombatLockdown and InCombatLockdown() then
        self:Schedule("restore-opening-binding", 2, function() GMG:RestoreOpeningBinding() end)
        return false
    end

    local stored = self.db.profile.openingKey
    local existing1, existing2 = GetBindingKey and GetBindingKey("GMG_TOGGLE")
    if stored == false or stored == nil then
        if existing1 and existing1 ~= "" then
            self:RememberOpeningBinding(false)
            self.db.profile.defaultGBindingHandled = true
            return true
        end
        return false
    end

    self.restoringBinding = true
    if existing1 and SetBinding then SetBinding(existing1) end
    if existing2 and SetBinding then SetBinding(existing2) end
    if stored ~= "" and SetBinding then SetBinding(stored, "GMG_TOGGLE") end
    self:SaveCurrentBindings()
    self.restoringBinding = false
    self.bindingReady = true
    self:ApplyOpeningBindingOverride(stored)

    -- Verify after the client has finished rebuilding its binding cache. Some
    -- private 3.3.5 clients briefly clear addon bindings during /reload.
    local applied = GetBindingKey and GetBindingKey("GMG_TOGGLE")
    if stored ~= "" and applied ~= stored then
        self:Schedule("verify-opening-binding", 0.5, function()
            if GMG.db and GMG.db.profile and GMG.db.profile.openingKey == stored then
                GMG.restoringBinding = true
                local key1, key2 = GetBindingKey and GetBindingKey("GMG_TOGGLE")
                if key1 and SetBinding then SetBinding(key1) end
                if key2 and SetBinding then SetBinding(key2) end
                if SetBinding then SetBinding(stored, "GMG_TOGGLE") end
                GMG:SaveCurrentBindings()
                GMG.restoringBinding = false
                GMG.bindingReady = true
                GMG:ApplyOpeningBindingOverride(stored)
                if GMG.RefreshSettings then GMG:RefreshSettings() end
            end
        end)
    end
    return true
end

function GMG:TryDefaultGBinding()
    if self.db.profile.defaultGBindingHandled then
        self.bindingReady = true
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        self:Schedule("default-g-binding", 3, function() GMG:TryDefaultGBinding() end)
        return
    end
    if GetBindingKey and GetBindingKey("GMG_TOGGLE") then
        self.db.profile.defaultGBindingHandled = true
        self:RememberOpeningBinding(false)
        self.bindingReady = true
        return
    end
    local currentAction = GetBindingAction and GetBindingAction("G") or ""
    local replaceable = {
        [""] = true,
        ["TOGGLEGUILDTAB"] = true,
        ["TOGGLEGUILDFRAME"] = true,
        ["TOGGLESOCIAL"] = true,
        ["TOGGLESOCIALFRAME"] = true,
    }
    if replaceable[currentAction] and SetBinding then
        self.restoringBinding = true
        local ok = SetBinding("G", "GMG_TOGGLE")
        if ok then self:SaveCurrentBindings() end
        self.restoringBinding = false
        if ok then
            self:RememberOpeningBinding(false)
            self:ApplyOpeningBindingOverride("G")
        end
        self:Print(self:L("DEFAULT_G_SET"))
    else
        self:Print(self:L("DEFAULT_G_BUSY"))
    end
    self.db.profile.defaultGBindingHandled = true
    self.bindingReady = true
    self:PersistSettings()
end

function GMG:SetOpeningBinding(key)
    if InCombatLockdown and InCombatLockdown() then
        self.pendingBindingKey = key or ""
        self:Print(self:L("KEY_COMBAT"))
        return false
    end
    key = key and tostring(key) or ""

    -- Store the requested key before touching WoW's binding cache. This makes
    -- SavedVariables the authoritative backup even if UPDATE_BINDINGS fires
    -- with an empty value during /reload.
    self.db.profile.openingKey = key
    self.db.profile.openingBindingSet = GetCurrentBindingSet and GetCurrentBindingSet() or 0
    self.db.profile.defaultGBindingHandled = true
    self:PersistSettings()

    self.restoringBinding = true
    local old1, old2 = GetBindingKey and GetBindingKey("GMG_TOGGLE")
    if old1 and SetBinding then SetBinding(old1) end
    if old2 and SetBinding then SetBinding(old2) end
    if key ~= "" and SetBinding then SetBinding(key, "GMG_TOGGLE") end
    self:SaveCurrentBindings()
    self.restoringBinding = false
    self.bindingReady = true
    self:ApplyOpeningBindingOverride(key)

    self:Schedule("save-opening-binding", 0.25, function()
        if GMG.db and GMG.db.profile and GMG.db.profile.openingKey == key then
            GMG.restoringBinding = true
            if key ~= "" and GetBindingKey and GetBindingKey("GMG_TOGGLE") ~= key and SetBinding then
                local one, two = GetBindingKey("GMG_TOGGLE")
                if one then SetBinding(one) end
                if two then SetBinding(two) end
                SetBinding(key, "GMG_TOGGLE")
            end
            GMG:SaveCurrentBindings()
            GMG.restoringBinding = false
            GMG:ApplyOpeningBindingOverride(key)
            if GMG.RefreshSettings then GMG:RefreshSettings() end
        end
    end)

    if key ~= "" then self:Print(self:L("KEY_CHANGED", key)) else self:Print(self:L("KEY_CLEARED")) end
    if self.RefreshSettings then self:RefreshSettings() end
    return true
end

function GMG:GetOpeningBinding()
    local key = GetBindingKey and GetBindingKey("GMG_TOGGLE")
    if key and key ~= "" then return key end
    local stored = self.db and self.db.profile and self.db.profile.openingKey
    if stored and stored ~= "" and stored ~= false then return stored end
    return "—"
end

function GMG:RefreshGuildData()
    if SetGuildRosterShowOffline then SetGuildRosterShowOffline(true) end
    if self:IsInGuild() and GuildRoster then GuildRoster() end
end

function GMG:NotifyRosterTransition(name, online)
    if online then
        if self:IsHighlighted(name) then
            if self.ShowToast then self:ShowToast(self:L("SUPER_CONNECTED", name), true) end
        elseif self.db.profile.notifyOnline and self.ShowToast then
            self:ShowToast(self:L("PLAYER_CONNECTED", name), false)
        end
    elseif self.db.profile.notifyOffline and self.ShowToast then
        self:ShowToast(self:L("PLAYER_DISCONNECTED", name), false)
    end
end

function GMG:RebuildRosterCache(detectTransitions)
    self.rosterClassCache = {}
    self.rosterMembers = {}
    if not self:IsInGuild() then
        self.rosterState = {}
        self.rosterStateReady = false
        return
    end

    local newState = {}
    local total = GetNumGuildMembers and GetNumGuildMembers() or 0
    for index = 1, total do
        local name, rank, rankIndex, level, class, zone, note, officerNote, online, status, classFile = GetGuildRosterInfo(index)
        if name then
            local simpleName = self:NormalizeName(name)
            local key = strlower(simpleName)
            local yearsOffline, monthsOffline, daysOffline, hoursOffline = 0, 0, 0, 0
            if not online and GetGuildRosterLastOnline then
                yearsOffline, monthsOffline, daysOffline, hoursOffline = GetGuildRosterLastOnline(index)
            end
            yearsOffline = max(0, tonumber(yearsOffline) or 0)
            monthsOffline = max(0, tonumber(monthsOffline) or 0)
            daysOffline = max(0, tonumber(daysOffline) or 0)
            hoursOffline = max(0, tonumber(hoursOffline) or 0)
            local offlineSeconds = self:GetOfflineDurationSeconds(yearsOffline, monthsOffline, daysOffline, hoursOffline)
            local lastOnlineAt = (not online and offlineSeconds > 0) and max(0, time() - offlineSeconds) or nil
            if classFile and classFile ~= "" then self.rosterClassCache[key] = classFile end
            newState[key] = online and true or false
            tinsert(self.rosterMembers, {
                index = index,
                name = name,
                simpleName = simpleName,
                rank = rank or "",
                rankIndex = tonumber(rankIndex) or 99,
                level = tonumber(level) or 0,
                class = class or "",
                classFile = classFile,
                zone = zone or "",
                note = note or "",
                officerNote = officerNote or "",
                online = online and true or false,
                status = status or 0,
                yearsOffline = yearsOffline,
                monthsOffline = monthsOffline,
                daysOffline = daysOffline,
                hoursOffline = hoursOffline,
                offlineSeconds = offlineSeconds,
                lastOnlineAt = lastOnlineAt,
                avatar = self:GetAvatarFor(simpleName, class, classFile),
            })
        end
    end

    if detectTransitions and self.rosterStateReady then
        for key, isOnline in pairs(newState) do
            local wasOnline = self.rosterState and self.rosterState[key]
            if wasOnline ~= nil and wasOnline ~= isOnline then
                local displayName = key
                for index = 1, #self.rosterMembers do
                    if strlower(self.rosterMembers[index].simpleName) == key then
                        displayName = self.rosterMembers[index].simpleName
                        break
                    end
                end
                self:NotifyRosterTransition(displayName, isOnline)
            end
        end
    end
    self.rosterState = newState
    self.rosterStateReady = true
    self.rosterDirty = true
end

function GMG:RefreshTick()
    -- Large private-server guilds can contain 500+ members. Do not rebuild the
    -- complete roster every second while the guild window has not been opened
    -- or is hidden. Server roster events and the scheduled initial refresh
    -- still keep the cache available for synchronization and notifications.
    if not self.mainFrame or not self.mainFrame:IsShown() then return end
    self:RebuildRosterCache(true)
    if self.RefreshDynamicUI then self:RefreshDynamicUI() end
end

function GMG:ResetWindowPositions()
    if self.mainFrame then
        self.mainFrame:ClearAllPoints()
        self.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        self.mainFrame:SetWidth(1040)
        self.mainFrame:SetHeight(650)
    end
    if self.launcher then
        self.launcher:ClearAllPoints()
        self.launcher:SetPoint("LEFT", UIParent, "LEFT", 0, 110)
    end
    if self.SaveMainPosition then self:SaveMainPosition() end
    if self.SaveLauncherPosition then self:SaveLauncherPosition() end
    self:Print(self:L("RESET_DONE"))
end

function GMG:ADDON_LOADED(addonName)
    if addonName ~= self.name then return end
    -- One-time migration from the former addon/SavedVariables name.
    local legacyDB = type(GlaynasMidnightGuildDB) == "table" and GlaynasMidnightGuildDB or nil
    GBGDB = CopyDefaults(DEFAULTS, GBGDB or legacyDB or {})
    self.db = GBGDB
    -- Stop writing the obsolete SavedVariables table after migration.
    GlaynasMidnightGuildDB = nil
    self.db.account = self.db.account or { ownerID = "", identityRevision = 1 }
    self:EnsureOwnerID()
    if self.db.profile.openingKey == nil then self.db.profile.openingKey = false end
    self.bindingReady = false
    self.restoringBinding = false
    self:PersistSettings()
    if self.ApplyBindingLocale then
        self:ApplyBindingLocale()
    else
        BINDING_HEADER_GLAYNABETTERGUILD = "G.B.G (Glayna Better Guild)"
        BINDING_NAME_GMG_TOGGLE = "Open / close the guild interface"
    end
    self:PruneHistory(true)

    SLASH_GBG1 = "/gbg"
    SLASH_GBG2 = "/gmg"
    SLASH_GBG3 = "/midnightguild"
    SlashCmdList.GBG = function(message)
        message = strlower(GMG:Trim(message))
        if message == "reset" then GMG:ResetWindowPositions() else GMG:Toggle() end
    end
end

function GMG:PLAYER_LOGIN()
    if RegisterAddonMessagePrefix then RegisterAddonMessagePrefix(self.commPrefix) end
    self:GetCharacterStore(true)
    self:EnsureOwnProfileIdentity(self:GetPlayerName())
    local guildStore = self:GetGuildStore(true)
    if guildStore and guildStore.localMainName and self:IsOwnCharacter(guildStore.localMainName)
        and self:GetOwnerMainName(self:GetOwnerID()) == "" then
        self:SetOwnMain(guildStore.localMainName)
    end
    -- Crash-safe startup: build the heavy interface only when the player opens it.
    self.uiPending = true
    self:RefreshGuildData()
    self:Schedule("initial-roster", 2, function() GMG:RebuildRosterCache(false); GMG:RefreshAll(true) end)
    self:Schedule("restore-opening-binding", 0.35, function()
        if not GMG:RestoreOpeningBinding() then GMG:TryDefaultGBinding() end
        GMG.bindingReady = true
    end)
    self:Schedule("restore-opening-binding-late", 2.5, function()
        if GMG.db and GMG.db.profile and GMG.db.profile.openingKey ~= false then GMG:RestoreOpeningBinding() end
    end)
    self:Schedule("initial-sync", 5, function() if GMG.SyncTick then GMG:SyncTick(true) end end)
end

function GMG:PLAYER_GUILD_UPDATE()
    self.rosterStateReady = false
    self:RefreshGuildData()
    self:Schedule("guild-refresh", 2, function() GMG:RebuildRosterCache(false); GMG:RefreshAll(true) end)
end

function GMG:GUILD_ROSTER_UPDATE()
    self:RebuildRosterCache(true)
    if self.RefreshDynamicUI then self:RefreshDynamicUI() end
end

function GMG:CHAT_MSG_GUILD(message, sender)
    self:AddHistoryMessage(sender, message, time(), "guild")
    if strlower(self:NormalizeName(sender)) ~= strlower(self:GetPlayerName())
        and self.db.profile.mentionFlash
        and self:IsPlayerMentioned(message)
        and self.ShowMentionFlash then
        self:ShowMentionFlash()
    end
end

function GMG:UPDATE_BINDINGS()
    if self.restoringBinding or not self.bindingReady or not self.db or not self.db.profile then return end
    local current = GetBindingKey and GetBindingKey("GMG_TOGGLE")
    if current and current ~= "" then
        self:RememberOpeningBinding(false)
        self:ApplyOpeningBindingOverride(current)
    elseif self.db.profile.openingKey and self.db.profile.openingKey ~= "" and self.db.profile.openingKey ~= false then
        self:ApplyOpeningBindingOverride(self.db.profile.openingKey)
        self:Schedule("restore-opening-binding-update", 0.2, function() GMG:RestoreOpeningBinding() end)
    end
    if self.RefreshSettings then self:RefreshSettings() end
end

function GMG:PLAYER_ENTERING_WORLD()
    if not self.db or not self.db.profile then return end
    self:Schedule("restore-opening-binding-world", 0.8, function()
        if GMG.db.profile.openingKey ~= false then GMG:RestoreOpeningBinding() end
        GMG.bindingReady = true
    end)
end

function GMG:PLAYER_REGEN_ENABLED()
    if self.pendingBindingKey ~= nil then
        local key = self.pendingBindingKey
        self.pendingBindingKey = nil
        self:SetOpeningBinding(key ~= "" and key or nil)
    elseif self.db and self.db.profile and self.db.profile.openingKey ~= false then
        self:RestoreOpeningBinding()
    end
end

function GMG:PLAYER_LOGOUT()
    if self.SaveMainPosition then self:SaveMainPosition() end
    if self.SaveLauncherPosition then self:SaveLauncherPosition() end
    if self.db and self.db.profile and (not self.db.profile.openingKey or self.db.profile.openingKey == false) then
        self:RememberOpeningBinding(false)
    end
    self:PersistSettings()
    self:PruneHistory(true)
end

function GMG:OnUpdate(elapsed)
    self:RunTimers()
    self.refreshPulse = (self.refreshPulse or 0) + elapsed
    self.syncPulse = (self.syncPulse or 0) + elapsed
    if self.refreshPulse >= self.refreshInterval then
        self.refreshPulse = self.refreshPulse - self.refreshInterval
        self:RefreshTick()
    end
    if self.syncPulse >= self.syncInterval then
        self.syncPulse = self.syncPulse - self.syncInterval
        if self.SyncTick then self:SyncTick(false) end
    end
    if self.UpdateToast then self:UpdateToast(elapsed) end
    if self.UpdateMentionFlash then self:UpdateMentionFlash(elapsed) end
end

GMG.eventFrame = GMG.eventFrame or CreateFrame("Frame")
GMG.eventFrame:RegisterEvent("ADDON_LOADED")
GMG.eventFrame:RegisterEvent("PLAYER_LOGIN")
GMG.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
GMG.eventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
GMG.eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
GMG.eventFrame:RegisterEvent("CHAT_MSG_GUILD")
GMG.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
GMG.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
GMG.eventFrame:RegisterEvent("UPDATE_BINDINGS")
GMG.eventFrame:RegisterEvent("PLAYER_LOGOUT")
GMG.eventFrame:SetScript("OnEvent", function(_, event, ...)
    if GMG[event] then GMG[event](GMG, ...) end
end)
GMG.eventFrame:SetScript("OnUpdate", function(_, elapsed) GMG:OnUpdate(elapsed) end)

-- ================================================================
-- v1.3.0: lightweight custom portraits, class defaults, URL links,
-- sorting/appearance/notification persistence.
-- ================================================================

GMG.CUSTOM_PORTRAIT_PREFIX = "Interface\\AddOns\\GBG\\Media\\Characters\\custom_"
GMG.DEFAULT_CUSTOM_AVATAR = GMG.CUSTOM_PORTRAIT_PREFIX .. "03"

local function GMGClassKey(value)
    value = string.upper(tostring(value or ""))
    return string.gsub(value, "[^A-Z0-9]", "")
end


GMG.CLASS_ICON_MAP = {
    NECROMANCER = "Interface\\Icons\\Spell_Shadow_RaiseDead",
    TINKER = "Interface\\Icons\\INV_Gizmo_02",
    FELSWORN = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
    STARCALLER = "Interface\\Icons\\Spell_Arcane_StarFire",
    CULTIST = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
    REAPER = "Interface\\Icons\\Ability_Rogue_ShadowDance",
    TEMPLAR = "Interface\\Icons\\Spell_Holy_DevotionAura",
    BARBARIAN = "Interface\\Icons\\Ability_Warrior_BattleShout",
    KNIGHTOFXOROTH = "Interface\\Icons\\INV_Sword_53",
    ALCHEMIST = "Interface\\Icons\\INV_Potion_83",
    BARD = "Interface\\Icons\\INV_Misc_Drum_01",
    WITCHHUNTER = "Interface\\Icons\\INV_Weapon_Rifle_01",
    RANGER = "Interface\\Icons\\Ability_Hunter_AimedShot",
    SPELLBLADE = "Interface\\Icons\\Spell_Holy_WeaponMastery",
    ASTROMANCER = "Interface\\Icons\\Spell_Arcane_Arcane02",
    PLAGUEDOCTOR = "Interface\\Icons\\Spell_Shadow_CorpseExplode",
    WARRIOR = "Interface\\Icons\\Ability_Warrior_BattleShout",
    PALADIN = "Interface\\Icons\\Spell_Holy_AvengersShield",
    HUNTER = "Interface\\Icons\\Ability_Hunter_BeastTaming",
    ROGUE = "Interface\\Icons\\Ability_BackStab",
    PRIEST = "Interface\\Icons\\Spell_Holy_PowerWordShield",
    DEATHKNIGHT = "Interface\\Icons\\Spell_DeathKnight_ClassIcon",
    SHAMAN = "Interface\\Icons\\Spell_Nature_BloodLust",
    MAGE = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    WARLOCK = "Interface\\Icons\\Spell_Shadow_DemonicTactics",
    MONK = "Interface\\Icons\\Ability_MeleeDamage",
    DRUID = "Interface\\Icons\\Spell_Nature_ForceOfNature",
    DEMONHUNTER = "Interface\\Icons\\Ability_Warlock_EverlastingAffliction",
    EVOKER = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
}

GMG.CLASS_AVATAR_MAP = {    -- Ascension / Conquest of Azeroth classes.
    NECROMANCER = 25,
    TINKER = 8,
    FELSWORN = 11,
    STARCALLER = 19,
    CULTIST = 36,
    REAPER = 2,
    TEMPLAR = 7,
    BARBARIAN = 27,
    KNIGHTOFXOROTH = 4,
    ALCHEMIST = 17,
    BARD = 22,
    WITCHHUNTER = 3,
    RANGER = 1,
    SPELLBLADE = 32,
    ASTROMANCER = 19,
    CHRONOMANCER = 20,
    PLAGUEDOCTOR = 24,
    WITCHDOCTOR = 36,
    SUNCLERIC = 26,
    BREWMASTER = 18,
    SHADOWHUNTER = 3,
    ELEMENTALIST = 16,

    -- Standard class identifiers and localized class-name fallbacks.
    WARRIOR = 27,
    PALADIN = 26,
    HUNTER = 29,
    ROGUE = 2,
    PRIEST = 26,
    DEATHKNIGHT = 30,
    SHAMAN = 10,
    MAGE = 33,
    WARLOCK = 6,
    MONK = 23,
    DRUID = 16,
    DEMONHUNTER = 11,
    EVOKER = 39,
}

function GMG:IsCustomPortraitTexture(texture)
    texture = tostring(texture or "")
    return string.find(texture, self.CUSTOM_PORTRAIT_PREFIX, 1, true) == 1
end

function GMG:GetDefaultAvatarForClass(className, classFile)
    local index = self.CLASS_AVATAR_MAP[GMGClassKey(classFile)] or self.CLASS_AVATAR_MAP[GMGClassKey(className)]
    if index then return self.CUSTOM_PORTRAIT_PREFIX .. format("%02d", index) end
    local icon = self.CLASS_ICON_MAP[GMGClassKey(classFile)] or self.CLASS_ICON_MAP[GMGClassKey(className)]
    if icon and icon ~= "" then return icon end
    return self.DEFAULT_CUSTOM_AVATAR
end

function GMG:GetRosterMemberByName(name)
    name = strlower(self:NormalizeName(name))
    for _, member in ipairs(self.rosterMembers or {}) do
        if strlower(self:NormalizeName(member.simpleName)) == name then return member end
    end
    return nil
end

function GMG:EnsureDefaultOwnAvatar()
    local store = self:GetCharacterStore(true)
    if not store then return self.DEFAULT_CUSTOM_AVATAR end
    if self:IsCustomPortraitTexture(store.avatar) then return store.avatar end
    local className, classFile = UnitClass and UnitClass("player")
    local texture = self:GetDefaultAvatarForClass(className, classFile)
    store.avatar = texture
    store.avatarRevision = max((tonumber(store.avatarRevision) or 0) + 1, time())
    self:StoreProfile(self:GetPlayerName(), texture, store.avatarRevision, self:GetPlayerName(), self:GetOwnerID())
    if self.QueueProfileBroadcast then self:QueueProfileBroadcast(true) end
    return texture
end

function GMG:GetOwnAvatar()
    return self:EnsureDefaultOwnAvatar()
end

function GMG:GetAvatarFor(name, className, classFile)
    local profile = self:GetProfile(name)
    if profile and profile.texture and not self:IsCustomPortraitTexture(profile.texture) then return profile.texture end
    if not className and not classFile then
        local member = self:GetRosterMemberByName(name)
        if member then
            className = member.class
            classFile = member.classFile
        end
    end
    return self:GetDefaultAvatarForClass(className, classFile)
end

-- Only the forty packaged portraits are accepted as shared avatars in v1.3.0.
local GMGOriginalSetOwnAvatar = GMG.SetOwnAvatar
function GMG:SetOwnAvatar(texture)
    if not self:IsCustomPortraitTexture(texture) then return false end
    return GMGOriginalSetOwnAvatar(self, texture)
end

-- Convert plain web/Discord addresses into addon hyperlinks. Clicking one opens
-- a copy box in the UI; no external browser is launched by the addon.
function GMG:LinkifyText(text)
    text = tostring(text or "")
    self.copyableURLs = self.copyableURLs or {}
    local function Link(url)
        local trailing = ""
        while string.find(url, "[%)%]%}%.,;!]+$") do
            trailing = string.sub(url, -1) .. trailing
            url = string.sub(url, 1, -2)
        end
        local id = self:Hash(url)
        self.copyableURLs[id] = url
        return "|Hgmgurl:" .. id .. "|h|cff68a8ff" .. url .. "|r|h" .. trailing
    end
    text = string.gsub(text, "(https?://[^%s]+)", Link)
    text = string.gsub(text, "([^:/%w])(discord%.gg/[^%s]+)", function(prefix, url)
        return prefix .. Link(url)
    end)
    text = string.gsub(text, "^(discord%.gg/[^%s]+)", Link, 1)
    return text
end

function GMG:FormatHistoryLine(message)
    return "|cff687087[" .. date("%H:%M", tonumber(message.ts) or time()) .. "]|r "
        .. self:FormatPlayerLink(message.sender) .. ": " .. self:LinkifyText(message.text or "")
end

-- Extra localization strings used by the v1.3.0 controls.
local extraEN = {
    SORT = "Sort", SORT_NAME = "Name", SORT_LEVEL = "Level", SORT_CLASS = "Class",
    SORT_ZONE = "Zone", SORT_RANK = "Guild rank", SORT_ASC = "Ascending", SORT_DESC = "Descending",
    RANK_LEXICON = "Guild rank list", RANK_MEMBERS = "Members with this rank", CLOSE = "Close",
    COPY_LINK = "Copy link", COPY_LINK_HELP = "Press Ctrl+C to copy this address.",
    ADVANCED_NOTIFICATIONS = "Notification settings", WINDOW_APPEARANCE = "Window appearance",
    FADE_IN_COMBAT = "Semi-transparent while in combat", FADE_WHILE_MOVING = "Semi-transparent while moving",
    FADE_ALPHA = "Transparency amount", NOTIFICATION_SIZE = "Size", NOTIFICATION_DURATION = "Duration",
    NOTIFICATION_OPACITY = "Opacity", NOTIFICATION_SHADOW = "Text shadow / outline",
    NOTIFICATION_POSITION = "Position", NOTIFICATION_ANIMATION = "Animation", NOTIFICATION_STYLE = "Style",
    POSITION_TOP = "Top", POSITION_TOPLEFT = "Top left", POSITION_TOPRIGHT = "Top right",
    POSITION_CENTER = "Center", POSITION_BOTTOM = "Bottom", ANIM_FADE = "Fade", ANIM_SLIDE = "Slide",
    ANIM_PULSE = "Pulse", STYLE_BANNER = "Banner", STYLE_COMPACT = "Compact", STYLE_MINIMAL = "Minimal",
    THEME = "Theme", ACCENT_COLOR = "Accent color", WINDOW_STYLE = "Window style",
    THEME_MIDNIGHT = "Midnight", THEME_FROST = "Frost", THEME_FEL = "Fel", THEME_EMBER = "Ember",
    ACCENT_VIOLET = "Violet", ACCENT_BLUE = "Blue", ACCENT_GREEN = "Green", ACCENT_RED = "Red", ACCENT_GOLD = "Gold",
    WINDOW_SOLID = "Solid", WINDOW_GLASS = "Glass", WINDOW_SOFT = "Soft",
    PREVIEW_NOTIFICATION = "Preview notification", GUILD_LINKS = "Links found — click to copy",
    NO_LINK = "No link found in the guild message.", HIGH_TO_LOW = "Highest to lowest", LOW_TO_HIGH = "Lowest to highest",
}
local extraFR = {
    SORT = "Trier", SORT_NAME = "Nom", SORT_LEVEL = "Niveau", SORT_CLASS = "Classe",
    SORT_ZONE = "Zone", SORT_RANK = "Grade de guilde", SORT_ASC = "Croissant", SORT_DESC = "Décroissant",
    RANK_LEXICON = "Liste des grades", RANK_MEMBERS = "Membres associés à ce grade", CLOSE = "Fermer",
    COPY_LINK = "Copier le lien", COPY_LINK_HELP = "Appuyez sur Ctrl+C pour copier cette adresse.",
    ADVANCED_NOTIFICATIONS = "Paramètres des notifications", WINDOW_APPEARANCE = "Apparence de la fenêtre",
    FADE_IN_COMBAT = "Semi-transparente pendant les combats", FADE_WHILE_MOVING = "Semi-transparente pendant les déplacements",
    FADE_ALPHA = "Niveau de transparence", NOTIFICATION_SIZE = "Taille", NOTIFICATION_DURATION = "Durée",
    NOTIFICATION_OPACITY = "Opacité", NOTIFICATION_SHADOW = "Ombre / contour du texte",
    NOTIFICATION_POSITION = "Position", NOTIFICATION_ANIMATION = "Animation", NOTIFICATION_STYLE = "Style",
    POSITION_TOP = "Haut", POSITION_TOPLEFT = "Haut gauche", POSITION_TOPRIGHT = "Haut droite",
    POSITION_CENTER = "Centre", POSITION_BOTTOM = "Bas", ANIM_FADE = "Fondu", ANIM_SLIDE = "Glissement",
    ANIM_PULSE = "Pulsation", STYLE_BANNER = "Bannière", STYLE_COMPACT = "Compact", STYLE_MINIMAL = "Minimal",
    THEME = "Thème", ACCENT_COLOR = "Couleur principale", WINDOW_STYLE = "Style de fenêtre",
    THEME_MIDNIGHT = "Midnight", THEME_FROST = "Givre", THEME_FEL = "Gangrène", THEME_EMBER = "Braises",
    ACCENT_VIOLET = "Violet", ACCENT_BLUE = "Bleu", ACCENT_GREEN = "Vert", ACCENT_RED = "Rouge", ACCENT_GOLD = "Or",
    WINDOW_SOLID = "Solide", WINDOW_GLASS = "Verre", WINDOW_SOFT = "Doux",
    PREVIEW_NOTIFICATION = "Tester la notification", GUILD_LINKS = "Liens détectés — cliquez pour copier",
    NO_LINK = "Aucun lien détecté dans le message de guilde.", HIGH_TO_LOW = "Du plus haut au plus bas", LOW_TO_HIGH = "Du plus bas au plus haut",
}
for key, value in pairs(extraEN) do GMG.Locales.en[key] = value end
for key, value in pairs(extraFR) do GMG.Locales.fr[key] = value end

local GMGOriginalAddonLoadedV130 = GMG.ADDON_LOADED
function GMG:ADDON_LOADED(addonName)
    GMGOriginalAddonLoadedV130(self, addonName)
    if addonName ~= self.name or not self.db or not self.db.profile then return end
    local p = self.db.profile
    local defaults = {
        rosterSortKey = "name", rosterSortAscending = true,
        rankLexiconAscending = true,
        fadeInCombat = true, fadeWhileMoving = true, contextFadeAlpha = 0.48,
        notificationSize = 1.0, notificationDuration = 4.2, notificationOpacity = 1.0,
        notificationShadow = true, notificationPosition = "top", notificationAnimation = "fade",
        notificationStyle = "banner", notificationColor = "accent",
        windowTheme = "midnight", accentColor = "violet", windowStyle = "solid",
    }
    for key, value in pairs(defaults) do if p[key] == nil then p[key] = value end end
    self:PersistSettings()
end

local GMGOriginalPlayerLoginV130 = GMG.PLAYER_LOGIN
function GMG:PLAYER_LOGIN(...)
    GMGOriginalPlayerLoginV130(self, ...)
    self:EnsureDefaultOwnAvatar()
end

-- Use the player's faction crest until the guild master chooses one of the
-- forty shared custom images. These textures are built into the 3.3.5a client,
-- so they do not add any weight to the addon archive.
GMG.DEFAULT_ALLIANCE_GUILD_IMAGE = "Interface\\TargetingFrame\\UI-PVP-Alliance"
GMG.DEFAULT_HORDE_GUILD_IMAGE = "Interface\\TargetingFrame\\UI-PVP-Horde"

function GMG:GetDefaultFactionGuildImage()
    local faction = UnitFactionGroup and UnitFactionGroup("player") or nil
    if faction == "Horde" then
        return self.DEFAULT_HORDE_GUILD_IMAGE
    elseif faction == "Alliance" then
        return self.DEFAULT_ALLIANCE_GUILD_IMAGE
    end
    return self.DEFAULT_GUILD_IMAGE
end

function GMG:GetGuildImageTexture()
    local image = self:GetGuildImage()
    if image and self:IsCustomPortraitTexture(image.texture) then return image.texture end
    return self:GetDefaultFactionGuildImage()
end

local GMGOriginalSetGuildImageV130 = GMG.SetGuildImage
function GMG:SetGuildImage(texture)
    if not self:IsCustomPortraitTexture(texture) then return false end
    return GMGOriginalSetGuildImageV130(self, texture)
end

local GMGOriginalStoreGuildImageV130 = GMG.StoreGuildImage
function GMG:StoreGuildImage(texture, revision, author)
    if not self:IsCustomPortraitTexture(texture) then return false end
    return GMGOriginalStoreGuildImageV130(self, texture, revision, author)
end


-- v1.3.5: safe dedicated guild crest.
-- Uses an opaque 24-bit TGA and a correctly escaped addon texture path.
GMG.DEFAULT_CUSTOM_GUILD_IMAGE = "Interface\\AddOns\\GBG\\Media\\Guild\\midnight_guild_logo"

function GMG:GetGuildImageTexture()
    local image = self:GetGuildImage()
    if image and self:IsCustomPortraitTexture(image.texture) then return image.texture end
    return self.DEFAULT_CUSTOM_GUILD_IMAGE
end


-- v1.3.8: never expose a guild image when the character has no guild.
local GMGOriginalGetGuildImageTextureV138 = GMG.GetGuildImageTexture
function GMG:GetGuildImageTexture()
    if not self:IsInGuild() then return nil end
    return GMGOriginalGetGuildImageTextureV138(self)
end


-- ============================================================================
-- v1.4.0: safe progressive portrait loader for modified 3.3.5a clients.
-- The BLP textures used by v1.3.7-v1.3.9 displayed as bright green blocks on
-- some Ascension clients. Portraits are now packaged as opaque 64x64 TGA files
-- and are never assigned to visible widgets before their progressive preload.
-- ============================================================================
GMG.PORTRAIT_LOAD_INTERVAL = 0.10
GMG.PORTRAIT_SETTLE_TIME = 0.10
GMG.SAFE_PORTRAIT_PLACEHOLDER = "Interface\\Icons\\INV_Misc_QuestionMark"
GMG.DEFAULT_CUSTOM_GUILD_IMAGE = "Interface\\AddOns\\GBG\\Media\\Guild\\midnight_guild_logo"
GMG.portraitLoadQueue = GMG.portraitLoadQueue or {}
GMG.portraitQueued = GMG.portraitQueued or {}
GMG.portraitReady = GMG.portraitReady or {}

function GMG:IsProgressivePortraitTexture(texture)
    texture = tostring(texture or "")
    return self:IsCustomPortraitTexture(texture) or texture == self.DEFAULT_CUSTOM_GUILD_IMAGE
end

function GMG:GetDesiredAvatarFor(name, className, classFile)
    local profile = self:GetProfile(name)
    if profile and self:IsCustomPortraitTexture(profile.texture) then
        return profile.texture
    end
    if not className and not classFile then
        local member = self:GetRosterMemberByName(name)
        if member then
            className = member.class
            classFile = member.classFile
        end
    end
    local index = self.CLASS_AVATAR_MAP[GMGClassKey(classFile)]
        or self.CLASS_AVATAR_MAP[GMGClassKey(className)]
        or 3
    return self.CUSTOM_PORTRAIT_PREFIX .. format("%02d", index)
end

function GMG:GetDesiredOwnAvatar()
    local store = self:GetCharacterStore(true)
    if not store then return self.CUSTOM_PORTRAIT_PREFIX .. "03" end
    if not self:IsCustomPortraitTexture(store.avatar) then
        local className, classFile = UnitClass and UnitClass("player")
        store.avatar = self:GetDesiredAvatarFor(self:GetPlayerName(), className, classFile)
    end
    return store.avatar
end

function GMG:GetDesiredGuildImageTexture()
    if not self:IsInGuild() then return nil end
    local image = self:GetGuildImage()
    if image and self:IsCustomPortraitTexture(image.texture) then return image.texture end
    return self.DEFAULT_CUSTOM_GUILD_IMAGE
end

function GMG:EnsurePortraitLoader()
    if self.portraitLoaderFrame then return end
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(2)
    frame:SetHeight(2)
    frame:SetPoint("BOTTOMLEFT", UIParent, "TOPRIGHT", 16, 16)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetAlpha(0.01)
    frame:Show()
    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(frame)
    texture:SetTexture(self.SAFE_PORTRAIT_PLACEHOLDER)
    self.portraitLoaderFrame = frame
    self.portraitLoaderTexture = texture
end

function GMG:QueuePortraitTexture(texture, priority)
    if not self:IsProgressivePortraitTexture(texture) then return end
    if self.portraitReady[texture] or self.portraitQueued[texture] or self.portraitPending == texture then return end
    self.portraitQueued[texture] = true
    if priority then
        tinsert(self.portraitLoadQueue, 1, texture)
    else
        tinsert(self.portraitLoadQueue, texture)
    end
end

function GMG:QueueRosterPortraits()
    -- v1.4.1: do not preload the entire roster anymore.
    -- Portraits are queued only when they are actually displayed
    -- (visible roster rows, selected member profile, visible picker icons).
    return
end

function GMG:StartPortraitLoading()
    if self.portraitLoadingStarted then return end
    self.portraitLoadingStarted = true
    self:EnsurePortraitLoader()
    local guildTexture = self:GetDesiredGuildImageTexture()
    if guildTexture then self:QueuePortraitTexture(guildTexture, true) end
end

function GMG:RefreshPortraitConsumers()
    if not self.mainFrame or not self.mainFrame:IsShown() then return end
    if self.RefreshHeader then self:RefreshHeader() end
    if self.RefreshRoster then self:RefreshRoster() end
    if self.RefreshMemberProfile then self:RefreshMemberProfile() end
    if self.RefreshGuildPage and self.guildPage and self.guildPage:IsShown() then self:RefreshGuildPage() end
    if self.RefreshSettings and self.settingsPage and self.settingsPage:IsShown() then self:RefreshSettings() end
    if self.imagePicker and self.imagePicker:IsShown() and self.RefreshImagePickerCategory then
        self:RefreshImagePickerCategory()
    end
end

function GMG:ProcessPortraitLoader(elapsed)
    if not self.portraitLoadingStarted then return end
    self:EnsurePortraitLoader()

    if self.portraitPending then
        self.portraitPendingElapsed = (self.portraitPendingElapsed or 0) + elapsed
        if self.portraitPendingElapsed >= self.PORTRAIT_SETTLE_TIME then
            local texture = self.portraitPending
            self.portraitPending = nil
            self.portraitPendingElapsed = 0
            self.portraitReady[texture] = true
            self.portraitQueued[texture] = nil
            self:RefreshPortraitConsumers()
        end
        return
    end

    self.portraitLoadElapsed = (self.portraitLoadElapsed or 0) + elapsed
    if self.portraitLoadElapsed < self.PORTRAIT_LOAD_INTERVAL then return end
    self.portraitLoadElapsed = self.portraitLoadElapsed - self.PORTRAIT_LOAD_INTERVAL

    local texture = tremove(self.portraitLoadQueue, 1)
    if not texture then return end
    self.portraitQueued[texture] = nil
    self.portraitLoaderTexture:SetTexture(nil)
    self.portraitLoaderTexture:SetTexture(texture)
    self.portraitPending = texture
    self.portraitPendingElapsed = 0
end

function GMG:GetAvatarFor(name, className, classFile, priority)
    local desired = self:GetDesiredAvatarFor(name, className, classFile)
    if self.portraitReady[desired] then return desired end
    if not self.suppressPortraitQueue then self:QueuePortraitTexture(desired, priority) end
    return self.SAFE_PORTRAIT_PLACEHOLDER
end

function GMG:GetOwnAvatar()
    local desired = self:GetDesiredOwnAvatar()
    if self.portraitReady[desired] then return desired end
    self:QueuePortraitTexture(desired, true)
    return self.SAFE_PORTRAIT_PLACEHOLDER
end

function GMG:GetGuildImageTexture()
    local desired = self:GetDesiredGuildImageTexture()
    if not desired then return nil end
    if self.portraitReady[desired] then return desired end
    self:QueuePortraitTexture(desired, true)
    return nil
end

local GMGSetOwnAvatarBeforeProgressiveV140 = GMG.SetOwnAvatar
function GMG:SetOwnAvatar(texture)
    local result = GMGSetOwnAvatarBeforeProgressiveV140(self, texture)
    if result then
        self:QueuePortraitTexture(texture, true)
        self:StartPortraitLoading()
    end
    return result
end

local GMGSetGuildImageBeforeProgressiveV140 = GMG.SetGuildImage
function GMG:SetGuildImage(texture)
    local result = GMGSetGuildImageBeforeProgressiveV140(self, texture)
    if result then
        self:QueuePortraitTexture(texture, true)
        self:StartPortraitLoading()
    end
    return result
end

local GMGRebuildRosterBeforeProgressiveV140 = GMG.RebuildRosterCache
function GMG:RebuildRosterCache(detectTransitions)
    self.suppressPortraitQueue = true
    GMGRebuildRosterBeforeProgressiveV140(self, detectTransitions)
    self.suppressPortraitQueue = nil
end

local GMGOnUpdateBeforeProgressiveV140 = GMG.OnUpdate
function GMG:OnUpdate(elapsed)
    GMGOnUpdateBeforeProgressiveV140(self, elapsed)
    self:ProcessPortraitLoader(elapsed)
end


-- ============================================================================
-- v1.7.2: independent per-member online mentions and reliable roster transitions.
-- The selected-member list is stored per guild and remains active even when the
-- global online notification option is disabled.
-- ============================================================================
function GMG:GetHighlightedNames()
    local result = {}
    local store = self:GetGuildStore(false)
    if not store or not store.highlighted then return result end
    for key, value in pairs(store.highlighted) do
        if value then
            local displayName = type(value) == "string" and self:NormalizeName(value) or ""
            if displayName == "" then
                for _, member in ipairs(self.rosterMembers or {}) do
                    if strlower(self:NormalizeName(member.simpleName)) == key then
                        displayName = self:NormalizeName(member.simpleName)
                        break
                    end
                end
            end
            if displayName == "" then displayName = key end
            result[#result + 1] = displayName
        end
    end
    sort(result, function(a, b) return strlower(a or "") < strlower(b or "") end)
    return result
end

function GMG:RemoveHighlighted(name, silent)
    local store = self:GetGuildStore(false)
    if not store or not store.highlighted then return false end
    name = self:NormalizeName(name)
    local key = strlower(name)
    if not store.highlighted[key] then return false end
    store.highlighted[key] = nil
    self.rosterDirty = true
    if self.PersistSettings then self:PersistSettings() end
    if not silent then self:Print(self:L("ALERT_DISABLED", name)) end
    if self.RefreshSettings then self:RefreshSettings() end
    if self.RefreshRoster then self:RefreshRoster() end
    return true
end

function GMG:ClearHighlighted()
    local store = self:GetGuildStore(false)
    if not store then return end
    store.highlighted = {}
    self.rosterDirty = true
    if self.PersistSettings then self:PersistSettings() end
    if self.RefreshSettings then self:RefreshSettings() end
    if self.RefreshRoster then self:RefreshRoster() end
end

function GMG:ToggleHighlighted(name)
    local store = self:GetGuildStore(true)
    if not store then return false end
    name = self:NormalizeName(name)
    local key = strlower(name)
    if store.highlighted[key] then
        store.highlighted[key] = nil
    else
        -- Keep the original capitalization for the settings list.
        store.highlighted[key] = name
    end
    self.rosterDirty = true
    if self.PersistSettings then self:PersistSettings() end
    self:Print(self:L(store.highlighted[key] and "ALERT_ENABLED" or "ALERT_DISABLED", name))
    if self.RefreshSettings then self:RefreshSettings() end
    return store.highlighted[key] and true or false
end

function GMG:NotifyRosterTransition(name, online)
    name = self:NormalizeName(name)
    if name == "" or strlower(name) == strlower(self:GetPlayerName() or "") then return end
    if online then
        if self:IsHighlighted(name) then
            -- Explicit per-member mention: always shown, independently from notifyOnline.
            if self.ShowToast then self:ShowToast(self:L("SUPER_CONNECTED", name), "highlight") end
        elseif self.db and self.db.profile and self.db.profile.notifyOnline and self.ShowToast then
            self:ShowToast(self:L("PLAYER_CONNECTED", name), "online")
        end
    elseif self.db and self.db.profile and self.db.profile.notifyOffline and self.ShowToast then
        self:ShowToast(self:L("PLAYER_DISCONNECTED", name), "offline")
    end
end

-- ============================================================================
-- v1.8.4: bundled-media path repair after the technical folder rename to GBG.
-- Older builds stored paths using GlaynasMidnightGuild or GlaynaBetterGuild.
-- Normalize both legacy forms so portraits and guild images keep working.
-- ============================================================================
GMG.MEDIA_ROOT = "Interface\\AddOns\\GBG\\Media\\"

function GMG:NormalizeBundledMediaPath(texture)
    texture = tostring(texture or "")
    if texture == "" then return texture end

    local currentPrefix = "Interface\\AddOns\\GBG\\"
    local legacyPrefixes = {
        "Interface\\AddOns\\GlaynasMidnightGuild\\",
        "Interface\\AddOns\\GlaynaBetterGuild\\",
    }

    for _, prefix in ipairs(legacyPrefixes) do
        if string.find(texture, prefix, 1, true) == 1 then
            return currentPrefix .. string.sub(texture, string.len(prefix) + 1)
        end
    end
    return texture
end

function GMG:MigrateBundledMediaPaths(root)
    if type(root) ~= "table" then return false end
    local visited = {}
    local changed = false

    local function Walk(tbl)
        if type(tbl) ~= "table" or visited[tbl] then return end
        visited[tbl] = true
        for key, value in pairs(tbl) do
            if type(value) == "string" then
                local normalized = GMG:NormalizeBundledMediaPath(value)
                if normalized ~= value then
                    tbl[key] = normalized
                    changed = true
                end
            elseif type(value) == "table" then
                Walk(value)
            end
        end
    end

    Walk(root)
    return changed
end

local GBGAddonLoadedBeforeV184 = GMG.ADDON_LOADED
function GMG:ADDON_LOADED(addonName)
    GBGAddonLoadedBeforeV184(self, addonName)
    if addonName ~= self.name or not self.db then return end
    if self:MigrateBundledMediaPaths(self.db) and self.PersistSettings then
        self:PersistSettings()
    end
end

local GBGGetCharacterStoreForBeforeV184 = GMG.GetCharacterStoreFor
function GMG:GetCharacterStoreFor(name, create)
    local store = GBGGetCharacterStoreForBeforeV184(self, name, create)
    if store and store.avatar then
        store.avatar = self:NormalizeBundledMediaPath(store.avatar)
    end
    return store
end

local GBGGetProfileBeforeV184 = GMG.GetProfile
function GMG:GetProfile(name)
    local profile = GBGGetProfileBeforeV184(self, name)
    if profile and profile.texture then
        profile.texture = self:NormalizeBundledMediaPath(profile.texture)
    end
    return profile
end

local GBGStoreProfileBeforeV184 = GMG.StoreProfile
function GMG:StoreProfile(name, texture, ...)
    return GBGStoreProfileBeforeV184(self, name, self:NormalizeBundledMediaPath(texture), ...)
end

local GBGSetOwnAvatarBeforeV184 = GMG.SetOwnAvatar
function GMG:SetOwnAvatar(texture)
    return GBGSetOwnAvatarBeforeV184(self, self:NormalizeBundledMediaPath(texture))
end

local GBGGetGuildImageBeforeV184 = GMG.GetGuildImage
function GMG:GetGuildImage()
    local image = GBGGetGuildImageBeforeV184(self)
    if image and image.texture then
        image.texture = self:NormalizeBundledMediaPath(image.texture)
    end
    return image
end

local GBGStoreGuildImageBeforeV184 = GMG.StoreGuildImage
function GMG:StoreGuildImage(texture, ...)
    return GBGStoreGuildImageBeforeV184(self, self:NormalizeBundledMediaPath(texture), ...)
end

local GBGSetGuildImageBeforeV184 = GMG.SetGuildImage
function GMG:SetGuildImage(texture)
    return GBGSetGuildImageBeforeV184(self, self:NormalizeBundledMediaPath(texture))
end
