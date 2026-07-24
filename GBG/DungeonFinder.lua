-- G.B.G (Glayna Better Guild)
-- Guild Dungeon Finder, temporary mention highlight and movable notification bar.
-- Compatible with WoW 3.3.5a / Ascension Interface 30300.

local GMG = GlaynaBetterGuild
local floor = math.floor
local max = math.max
local min = math.min
local sort = table.sort
local tonumber = tonumber
local tostring = tostring
local strlower = string.lower
local time = time

local DF_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}
local DF_BG = {0.025, 0.031, 0.052, 0.99}
local DF_PANEL = {0.045, 0.052, 0.082, 0.99}
local DF_PANEL_2 = {0.075, 0.082, 0.125, 0.98}
local DF_BORDER = {0.24, 0.22, 0.38, 1}
local DF_ACCENT = {0.60, 0.42, 1.00, 1}
local DF_ACCENT_SOFT = {0.30, 0.19, 0.52, 0.95}
local DF_TEXT = {0.88, 0.90, 0.96, 1}
local DF_MUTED = {0.48, 0.52, 0.64, 1}
local DF_GREEN = {0.25, 0.90, 0.55, 1}
local DF_RED = {0.95, 0.34, 0.42, 1}
local DF_GOLD = {1.00, 0.76, 0.28, 1}

local function DFSetBackdrop(frame, background, border)
    frame:SetBackdrop(DF_BACKDROP)
    frame:SetBackdropColor(unpack(background or DF_BG))
    frame:SetBackdropBorderColor(unpack(border or DF_BORDER))
end

local function DFText(parent, fontObject, text, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObject or "GameFontNormal")
    if size then
        local font, _, flags = fs:GetFont()
        if font then fs:SetFont(font, size, flags) end
    end
    fs:SetText(text or "")
    fs:SetTextColor(unpack(DF_TEXT))
    if fs.SetWordWrap then fs:SetWordWrap(true) end
    return fs
end

local function DFBoundedText(fontString, text, width)
    text = tostring(text or "")
    if width then fontString:SetWidth(width) end
    if fontString.SetWordWrap then fontString:SetWordWrap(false) end
    fontString:SetText(text)
    if not width or not fontString.GetStringWidth or string.find(text, "|", 1, true) then return end
    if fontString:GetStringWidth() <= width then return end
    local shortened = text
    while string.len(shortened) > 1 do
        shortened = string.sub(shortened, 1, string.len(shortened) - 1)
        fontString:SetText(shortened .. "...")
        if fontString:GetStringWidth() <= width then return end
    end
end

local function DFButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 120)
    button:SetHeight(height or 30)
    DFSetBackdrop(button, DF_PANEL_2, DF_BORDER)
    button.label = DFText(button, "GameFontNormal", text or "", 11)
    button.label:SetPoint("LEFT", 6, 0)
    button.label:SetPoint("RIGHT", -6, 0)
    button.label:SetJustifyH("CENTER")
    button:SetScript("OnEnter", function(self)
        if not self.disabled then
            self:SetBackdropColor(unpack(DF_ACCENT_SOFT))
            self:SetBackdropBorderColor(unpack(DF_ACCENT))
        end
    end)
    button:SetScript("OnLeave", function(self)
        if self.selected then
            self:SetBackdropColor(unpack(DF_ACCENT_SOFT))
            self:SetBackdropBorderColor(unpack(DF_ACCENT))
        else
            self:SetBackdropColor(unpack(DF_PANEL_2))
            self:SetBackdropBorderColor(unpack(DF_BORDER))
        end
    end)
    button:SetScript("OnDisable", function(self)
        self.disabled = true
        self:SetAlpha(0.42)
    end)
    button:SetScript("OnEnable", function(self)
        self.disabled = false
        self:SetAlpha(1)
    end)
    return button
end

local function DFSelectButton(button, selected)
    if not button then return end
    button.selected = selected and true or false
    if button.selected then
        button:SetBackdropColor(unpack(DF_ACCENT_SOFT))
        button:SetBackdropBorderColor(unpack(DF_ACCENT))
        if button.label then button.label:SetTextColor(1, 1, 1, 1) end
    else
        button:SetBackdropColor(unpack(DF_PANEL_2))
        button:SetBackdropBorderColor(unpack(DF_BORDER))
        if button.label then button.label:SetTextColor(unpack(DF_TEXT)) end
    end
end

local function DFEdit(parent, width, height, maxLetters)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width or 180)
    holder:SetHeight(height or 30)
    DFSetBackdrop(holder, DF_PANEL, DF_BORDER)
    local edit = CreateFrame("EditBox", nil, holder)
    edit:SetPoint("TOPLEFT", 8, -5)
    edit:SetPoint("BOTTOMRIGHT", -8, 5)
    edit:SetAutoFocus(false)
    edit:SetFontObject("ChatFontNormal")
    edit:SetTextColor(unpack(DF_TEXT))
    edit:SetMaxLetters(maxLetters or 60)
    edit:SetMultiLine(false)
    holder.editBox = edit
    return holder, edit
end

local function DFCheck(parent, label, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 150)
    button:SetHeight(24)
    button.box = CreateFrame("Frame", nil, button)
    button.box:SetWidth(18)
    button.box:SetHeight(18)
    button.box:SetPoint("LEFT", 0, 0)
    DFSetBackdrop(button.box, DF_PANEL, DF_BORDER)
    button.fill = button.box:CreateTexture(nil, "ARTWORK")
    button.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.fill:SetPoint("TOPLEFT", 4, -4)
    button.fill:SetPoint("BOTTOMRIGHT", -4, 4)
    button.fill:SetVertexColor(unpack(DF_ACCENT))
    button.fill:Hide()
    button.label = DFText(button, "GameFontNormal", label or "", 11)
    button.label:SetPoint("LEFT", button.box, "RIGHT", 8, 0)
    button.label:SetPoint("RIGHT", 0, 0)
    button.label:SetJustifyH("LEFT")
    function button:SetChecked(value)
        self.checked = value and true or false
        if self.checked then
            self.fill:Show()
            self.box:SetBackdropColor(unpack(DF_ACCENT_SOFT))
            self.box:SetBackdropBorderColor(unpack(DF_ACCENT))
        else
            self.fill:Hide()
            self.box:SetBackdropColor(unpack(DF_PANEL))
            self.box:SetBackdropBorderColor(unpack(DF_BORDER))
        end
    end
    function button:GetChecked() return self.checked end
    button:SetChecked(false)
    button:SetScript("OnClick", function(self) self:SetChecked(not self:GetChecked()) end)
    return button
end

local function DFEscape(value)
    value = tostring(value or "")
    value = string.gsub(value, "%%", "%%25")
    value = string.gsub(value, "|", "%%7C")
    value = string.gsub(value, "\n", "%%0A")
    value = string.gsub(value, "\r", "%%0D")
    return value
end

local function DFUnescape(value)
    value = tostring(value or "")
    value = string.gsub(value, "%%0D", "\r")
    value = string.gsub(value, "%%0A", "\n")
    value = string.gsub(value, "%%7C", "|")
    value = string.gsub(value, "%%25", "%%")
    return value
end

local function DFSplit(payload)
    local values = {}
    local start = 1
    while true do
        local separator = string.find(payload, "|", start, true)
        if not separator then
            values[#values + 1] = string.sub(payload, start)
            break
        end
        values[#values + 1] = string.sub(payload, start, separator - 1)
        start = separator + 1
    end
    return values
end

local function DFClamp(value, low, high, fallback)
    value = tonumber(value)
    if not value then return fallback end
    value = floor(value)
    if value < low then return low end
    if value > high then return high end
    return value
end

local function DFRoleList(activity)
    local roles = {}
    for role in string.gmatch(activity.roles or "", "[^,]+") do
        roles[#roles + 1] = role
    end
    return roles
end

local function DFHasRole(activity, role)
    for _, value in ipairs(DFRoleList(activity)) do
        if value == role then return true end
    end
    return false
end

local function DFRoleLabel(self, role)
    local keys = {
        tank = "DF_ROLE_TANK",
        heal = "DF_ROLE_HEAL",
        dps = "DF_ROLE_DPS",
        support = "DF_ROLE_SUPPORT",
    }
    return self:L(keys[role] or "DF_ROLE_DPS")
end

local function DFCategoryLabel(self, category)
    return category == "PVP" and self:L("DF_PVP") or self:L("DF_PVE")
end

local DF_EN = {
    DF_TAB = "Guild Dungeon Finder",
    DF_TITLE = "Guild Dungeon Finder",
    DF_CREATE = "Create activity",
    DF_REFRESH = "Refresh",
    DF_NONE = "No activity is currently open.",
    DF_OPEN_COUNT = "%d open",
    DF_ACTIVITY_NAME = "Activity name",
    DF_ACTIVITY_TYPE = "Activity type",
    DF_PVE = "PvE",
    DF_PVP = "PvP",
    DF_LEVEL_RANGE = "Required level range",
    DF_MIN_LEVEL = "Minimum",
    DF_MAX_LEVEL = "Maximum",
    DF_PLACES = "Available places",
    DF_ROLES = "Available roles",
    DF_ROLE_TANK = "Tank",
    DF_ROLE_HEAL = "Healer",
    DF_ROLE_DPS = "Damage",
    DF_ROLE_SUPPORT = "Support",
    DF_CREATE_CONFIRM = "Create",
    DF_CANCEL = "Cancel",
    DF_JOIN = "Join",
    DF_LEAVE = "Leave",
    DF_CLOSE = "Close activity",
    DF_VIEW = "View activity",
    DF_REQUIRED_LEVEL = "Required level: %d-%d",
    DF_LEVEL_TOO_LOW = "You cannot join: required level %d-%d, your level is %d.",
    DF_ROLE_REQUIRED = "Choose a role before joining.",
    DF_ACTIVITY_CREATED = "Activity created and announced to addon users.",
    DF_ACTIVITY_CLOSED = "Activity closed.",
    DF_ACTIVITY_FULL = "The activity is full and has been removed from the list.",
    DF_JOINED = "%s joined as %s.",
    DF_LEFT = "%s left the activity.",
    DF_AUTO_INVITE = "Automatic invitation sent to %s.",
    DF_ANNOUNCEMENT = "[Guild Finder] %s — %s — level %d-%d — %d place(s) — click to register",
    DF_OWNER = "Leader: %s",
    DF_MEMBERS = "Registered players (%d/%d)",
    DF_EMPTY_MEMBERS = "No player registered yet.",
    DF_SELECT_ROLE = "Your role",
    DF_NOT_OWNER = "Only the activity creator can close it.",
    DF_NAME_REQUIRED = "Enter an activity name.",
    DF_INVALID_RANGE = "The maximum level must be greater than or equal to the minimum level.",
    DF_ROLE_MISSING = "Select at least one available role.",
    DF_ACTIVITY_GONE = "This activity is no longer available.",
    DF_ACTIVITY_BADGE_HELP = "%d guild activity/activities open. Click to view.",
    DF_MOVABLE_NOTIFICATION = "Move notification bar",
    DF_LOCK_NOTIFICATION = "Lock notification bar",
    DF_MOVE_NOTIFICATION_HELP = "Drag this notification bar, then right-click it or press the button again to lock it.",
    DF_NOTIFICATION_MOVED = "Notification bar position saved.",
    DF_MENTION_HIGHLIGHT_SETTING = "Temporarily highlight mentioned messages in fluorescent green",
    DF_MENTION_HIGHLIGHT_HELP = "When Guild Chat opens, unread messages that mention you are highlighted for a few seconds, then return to normal.",
}
local DF_FR = {
    DF_TAB = "Dungeon Finder de guilde",
    DF_TITLE = "Dungeon Finder de guilde",
    DF_CREATE = "Créer une activité",
    DF_REFRESH = "Actualiser",
    DF_NONE = "Aucune activité n'est actuellement ouverte.",
    DF_OPEN_COUNT = "%d ouverte(s)",
    DF_ACTIVITY_NAME = "Nom de l'activité",
    DF_ACTIVITY_TYPE = "Type d'activité",
    DF_PVE = "JcE",
    DF_PVP = "JcJ",
    DF_LEVEL_RANGE = "Tranche de niveau requise",
    DF_MIN_LEVEL = "Minimum",
    DF_MAX_LEVEL = "Maximum",
    DF_PLACES = "Places disponibles",
    DF_ROLES = "Rôles disponibles",
    DF_ROLE_TANK = "Tank",
    DF_ROLE_HEAL = "Soigneur",
    DF_ROLE_DPS = "Dégâts",
    DF_ROLE_SUPPORT = "Soutien",
    DF_CREATE_CONFIRM = "Créer",
    DF_CANCEL = "Annuler",
    DF_JOIN = "S'inscrire",
    DF_LEAVE = "Se désinscrire",
    DF_CLOSE = "Fermer l'activité",
    DF_VIEW = "Voir l'activité",
    DF_REQUIRED_LEVEL = "Niveau requis : %d-%d",
    DF_LEVEL_TOO_LOW = "Inscription impossible : niveau requis %d-%d, votre niveau est %d.",
    DF_ROLE_REQUIRED = "Choisissez un rôle avant de vous inscrire.",
    DF_ACTIVITY_CREATED = "Activité créée et annoncée aux utilisateurs de l'addon.",
    DF_ACTIVITY_CLOSED = "Activité fermée.",
    DF_ACTIVITY_FULL = "L'activité est complète et a été retirée de la liste.",
    DF_JOINED = "%s s'est inscrit en %s.",
    DF_LEFT = "%s s'est désinscrit de l'activité.",
    DF_AUTO_INVITE = "Invitation automatique envoyée à %s.",
    DF_ANNOUNCEMENT = "[Dungeon Finder] %s — %s — niveaux %d-%d — %d place(s) — cliquez pour vous inscrire",
    DF_OWNER = "Responsable : %s",
    DF_MEMBERS = "Joueurs inscrits (%d/%d)",
    DF_EMPTY_MEMBERS = "Aucun joueur inscrit pour le moment.",
    DF_SELECT_ROLE = "Votre rôle",
    DF_NOT_OWNER = "Seul le créateur de l'activité peut la fermer.",
    DF_NAME_REQUIRED = "Saisissez un nom d'activité.",
    DF_INVALID_RANGE = "Le niveau maximum doit être supérieur ou égal au niveau minimum.",
    DF_ROLE_MISSING = "Sélectionnez au moins un rôle disponible.",
    DF_ACTIVITY_GONE = "Cette activité n'est plus disponible.",
    DF_ACTIVITY_BADGE_HELP = "%d activité(s) de guilde ouverte(s). Cliquez pour les consulter.",
    DF_MOVABLE_NOTIFICATION = "Déplacer la barre de notification",
    DF_LOCK_NOTIFICATION = "Verrouiller la barre de notification",
    DF_MOVE_NOTIFICATION_HELP = "Faites glisser cette barre, puis faites un clic droit dessus ou rappuyez sur le bouton pour la verrouiller.",
    DF_NOTIFICATION_MOVED = "Position de la barre de notification enregistrée.",
    DF_MENTION_HIGHLIGHT_SETTING = "Surligner temporairement en vert fluo les messages qui me mentionnent",
    DF_MENTION_HIGHLIGHT_HELP = "À l'ouverture de la Discussion de guilde, les messages non lus qui vous mentionnent sont surlignés quelques secondes puis redeviennent normaux.",
}
GMG.Locales = GMG.Locales or { en = {}, fr = {} }
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(DF_EN) do GMG.Locales.en[key] = value end
for key, value in pairs(DF_FR) do GMG.Locales.fr[key] = value end

function GMG:GetDungeonActivityStore(create)
    local store = self:GetGuildStore(create)
    if not store then return nil end
    if create and type(store.dungeonActivities) ~= "table" then store.dungeonActivities = {} end
    return store.dungeonActivities
end

function GMG:GetDungeonActivities()
    local result = {}
    local store = self:GetDungeonActivityStore(false)
    if not store then return result end
    local now = time()
    for id, activity in pairs(store) do
        if type(activity) == "table" and (tonumber(activity.expiresAt) or 0) > now then
            activity.id = activity.id or id
            result[#result + 1] = activity
        end
    end
    sort(result, function(a, b)
        local aType = a.category or "PVE"
        local bType = b.category or "PVE"
        if aType ~= bType then return aType < bType end
        local aTime = tonumber(a.createdAt) or 0
        local bTime = tonumber(b.createdAt) or 0
        if aTime ~= bTime then return aTime > bTime end
        return tostring(a.title or "") < tostring(b.title or "")
    end)
    return result
end

function GMG:GetDungeonActivity(id)
    local store = self:GetDungeonActivityStore(false)
    return store and store[id] or nil
end

function GMG:CountDungeonActivityMembers(activity)
    local count = 0
    for _, role in pairs(activity and activity.members or {}) do
        if role then count = count + 1 end
    end
    return count
end

function GMG:SerializeDungeonMembers(activity)
    local parts = {}
    for name, role in pairs(activity.members or {}) do
        parts[#parts + 1] = DFEscape(name) .. "~" .. DFEscape(role)
    end
    sort(parts)
    return table.concat(parts, ";")
end

function GMG:DeserializeDungeonMembers(value)
    local members = {}
    for entry in string.gmatch(value or "", "[^;]+") do
        local separator = string.find(entry, "~", 1, true)
        if separator then
            local name = DFUnescape(string.sub(entry, 1, separator - 1))
            local role = DFUnescape(string.sub(entry, separator + 1))
            name = self:NormalizeName(name)
            if name ~= "" and role ~= "" then members[name] = role end
        end
    end
    return members
end

function GMG:BuildDungeonActivityPayload(activity)
    return table.concat({
        "DA",
        self:GetGuildHash() or "",
        DFEscape(activity.id),
        tostring(activity.revision or 1),
        tostring(activity.createdAt or time()),
        tostring(activity.updatedAt or time()),
        tostring(activity.expiresAt or (time() + 14400)),
        DFEscape(activity.owner or ""),
        DFEscape(activity.title or ""),
        activity.category == "PVP" and "PVP" or "PVE",
        tostring(activity.minLevel or 1),
        tostring(activity.maxLevel or 255),
        tostring(activity.slots or 1),
        DFEscape(activity.roles or "dps"),
        DFEscape(self:SerializeDungeonMembers(activity)),
    }, "|")
end

function GMG:BroadcastDungeonActivity(activity, channel, target, priority)
    if not activity or not self:IsInGuild() then return end
    self:QueuePacket(self:BuildDungeonActivityPayload(activity), channel or "GUILD", target, priority)
end

function GMG:BroadcastDungeonClose(activity, reason)
    if not activity or not self:IsInGuild() then return end
    self:QueuePacket(table.concat({
        "DC", self:GetGuildHash() or "", DFEscape(activity.id), tostring(activity.revision or 1),
        DFEscape(activity.owner or ""), DFEscape(reason or "closed")
    }, "|"), "GUILD", nil, true)
end

function GMG:AnnounceDungeonActivity(activity)
    if not activity then return end
    local text = self:L("DF_ANNOUNCEMENT", activity.title or "", DFCategoryLabel(self, activity.category), activity.minLevel or 1, activity.maxLevel or 255, activity.slots or 1)
    text = "|Hgmgactivity:" .. activity.id .. "|h|cff39ff14" .. text .. "|r|h"
    self:AddHistoryMessage(activity.owner, text, activity.createdAt or time(), "activity", "df-" .. activity.id)
end

function GMG:StoreDungeonActivity(activity, announce)
    if not activity or not activity.id or activity.id == "" then return false end
    local store = self:GetDungeonActivityStore(true)
    local current = store[activity.id]
    if current ~= activity then
        if current and (tonumber(current.revision) or 0) > (tonumber(activity.revision) or 0) then return false end
        if current and (tonumber(current.revision) or 0) == (tonumber(activity.revision) or 0)
            and (tonumber(current.updatedAt) or 0) >= (tonumber(activity.updatedAt) or 0) then return false end
    end
    local isNew = current == nil
    activity.members = activity.members or {}
    activity.receivedAt = time()
    store[activity.id] = activity
    if isNew and announce then self:AnnounceDungeonActivity(activity) end
    self.dungeonDirty = true
    if self.PersistSettings then self:PersistSettings() end
    if self.RefreshDungeonFinder then self:RefreshDungeonFinder(true) end
    if self.RefreshDungeonActivityBadges then self:RefreshDungeonActivityBadges() end
    return true
end

function GMG:RemoveDungeonActivity(id, reason, silent)
    local store = self:GetDungeonActivityStore(false)
    local activity = store and store[id]
    if not activity then return false end
    store[id] = nil
    if self.PersistSettings then self:PersistSettings() end
    self.dungeonDirty = true
    if self.dungeonSelectedID == id then self.dungeonSelectedID = nil end
    if not silent and reason == "full" then self:Print(self:L("DF_ACTIVITY_FULL")) end
    if self.RefreshDungeonFinder then self:RefreshDungeonFinder(true) end
    if self.RefreshDungeonActivityBadges then self:RefreshDungeonActivityBadges() end
    return true
end

function GMG:CreateDungeonActivity(title, category, minLevel, maxLevel, slots, roles)
    if not self:IsInGuild() then self:Print(self:L("NOT_IN_GUILD")); return false end
    title = self:Trim(title or "")
    if title == "" then self:Print(self:L("DF_NAME_REQUIRED")); return false end
    minLevel = DFClamp(minLevel, 1, 255, 1)
    maxLevel = DFClamp(maxLevel, 1, 255, 255)
    if maxLevel < minLevel then self:Print(self:L("DF_INVALID_RANGE")); return false end
    slots = DFClamp(slots, 1, 40, 5)
    roles = roles or ""
    if roles == "" then self:Print(self:L("DF_ROLE_MISSING")); return false end
    self.dungeonSerial = (self.dungeonSerial or 0) + 1
    local id = self:Hash(self:GetPlayerName() .. ":" .. tostring(time()) .. ":" .. tostring(self.dungeonSerial) .. ":" .. tostring(GetTime()))
    local activity = {
        id = id,
        revision = 1,
        createdAt = time(),
        updatedAt = time(),
        expiresAt = time() + 14400,
        owner = self:GetPlayerName(),
        title = string.sub(title, 1, 60),
        category = category == "PVP" and "PVP" or "PVE",
        minLevel = minLevel,
        maxLevel = maxLevel,
        slots = slots,
        roles = roles,
        members = {},
    }
    self:StoreDungeonActivity(activity, true)
    self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
    self:SendQueuedPackets(8)
    self.dungeonSelectedID = id
    self:Print(self:L("DF_ACTIVITY_CREATED"))
    return true
end

function GMG:RequestDungeonJoin(activity, role, leave)
    if not activity then self:Print(self:L("DF_ACTIVITY_GONE")); return end
    local player = self:GetPlayerName()
    local level = UnitLevel and UnitLevel("player") or 1
    if not leave and (level < (activity.minLevel or 1) or level > (activity.maxLevel or 255)) then
        self:Print(self:L("DF_LEVEL_TOO_LOW", activity.minLevel or 1, activity.maxLevel or 255, level))
        return
    end
    if not leave and not DFHasRole(activity, role) then self:Print(self:L("DF_ROLE_REQUIRED")); return end
    local action = leave and "leave" or "join"
    self:QueuePacket(table.concat({
        "DJ", self:GetGuildHash() or "", DFEscape(activity.id), DFEscape(player), DFEscape(role or ""), action
    }, "|"), "GUILD", nil, true)
    self:SendQueuedPackets(4)
    if self:NormalizeName(activity.owner) == self:GetPlayerName() then
        self:ApplyDungeonJoinRequest(activity.id, player, role, action, player)
    end
end

function GMG:ApplyDungeonJoinRequest(id, player, role, action, sender)
    local activity = self:GetDungeonActivity(id)
    if not activity or self:NormalizeName(activity.owner) ~= self:GetPlayerName() then return end
    player = self:NormalizeName(player)
    sender = self:NormalizeName(sender)
    if player == "" or sender ~= player or not self:IsGuildMemberName(player) then return end
    activity.members = activity.members or {}
    if action == "leave" then
        if activity.members[player] then
            activity.members[player] = nil
            activity.revision = (tonumber(activity.revision) or 1) + 1
            activity.updatedAt = time()
            activity.expiresAt = time() + 14400
            self:StoreDungeonActivity(activity, false)
            self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
            self:Print(self:L("DF_LEFT", player))
        end
        return
    end
    local level = 1
    local member = self.GetRosterMemberByName and self:GetRosterMemberByName(player)
    if member then level = tonumber(member.level) or 1 end
    if level < (activity.minLevel or 1) or level > (activity.maxLevel or 255) then return end
    if not DFHasRole(activity, role) then return end
    if activity.members[player] then return end
    if self:CountDungeonActivityMembers(activity) >= (activity.slots or 1) then return end
    activity.members[player] = role
    activity.revision = (tonumber(activity.revision) or 1) + 1
    activity.updatedAt = time()
    activity.expiresAt = time() + 14400
    if InviteUnit and player ~= self:GetPlayerName() then
        InviteUnit(player)
        self:Print(self:L("DF_AUTO_INVITE", player))
    end
    self:Print(self:L("DF_JOINED", player, DFRoleLabel(self, role)))
    if self:CountDungeonActivityMembers(activity) >= (activity.slots or 1) then
        self:BroadcastDungeonClose(activity, "full")
        self:RemoveDungeonActivity(activity.id, "full", false)
    else
        self:StoreDungeonActivity(activity, false)
        self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
    end
end

function GMG:CloseDungeonActivity(activity)
    if not activity then return end
    if self:NormalizeName(activity.owner) ~= self:GetPlayerName() then self:Print(self:L("DF_NOT_OWNER")); return end
    activity.revision = (tonumber(activity.revision) or 1) + 1
    self:BroadcastDungeonClose(activity, "closed")
    self:RemoveDungeonActivity(activity.id, "closed", true)
    self:Print(self:L("DF_ACTIVITY_CLOSED"))
end

function GMG:PruneDungeonActivities()
    local store = self:GetDungeonActivityStore(false)
    if not store then return end
    local now = time()
    local changed = false
    for id, activity in pairs(store) do
        local owner = type(activity) == "table" and self:NormalizeName(activity.owner) or ""
        local staleRemote = owner ~= "" and owner ~= self:GetPlayerName()
            and now - (tonumber(activity.receivedAt) or tonumber(activity.updatedAt) or 0) > 90
        if type(activity) ~= "table" or (tonumber(activity.expiresAt) or 0) <= now or staleRemote then
            store[id] = nil
            changed = true
        end
    end
    if changed then
        self.dungeonDirty = true
        if self.PersistSettings then self:PersistSettings() end
        if self.RefreshDungeonFinder then self:RefreshDungeonFinder(true) end
        if self.RefreshDungeonActivityBadges then self:RefreshDungeonActivityBadges() end
    end
end

function GMG:CreateDungeonFinderPage()
    if not self.mainFrame or self.dungeonPage then return end
    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()
    page:Hide()
    self.dungeonPage = page

    page.title = DFText(page, "GameFontNormalLarge", self:L("DF_TITLE"), 20)
    page.title:SetPoint("TOPLEFT", 22, -20)
    page.title:SetTextColor(1, 1, 1, 1)

    page.create = DFButton(page, self:L("DF_CREATE"), 170, 32)
    page.create:SetPoint("TOPRIGHT", -154, -14)
    page.create:SetScript("OnClick", function() GMG:OpenDungeonCreatePopup() end)
    page.refresh = DFButton(page, self:L("DF_REFRESH"), 116, 32)
    page.refresh:SetPoint("TOPRIGHT", -22, -14)
    page.refresh:SetScript("OnClick", function()
        GMG:QueuePacket(table.concat({"DR", GMG:GetGuildHash() or ""}, "|"), "GUILD", nil, true)
        GMG:SendQueuedPackets(6)
        GMG:RefreshDungeonFinder(true)
    end)

    page.listPanel = CreateFrame("Frame", nil, page)
    page.listPanel:SetPoint("TOPLEFT", 22, -58)
    page.listPanel:SetPoint("BOTTOMLEFT", 22, 22)
    page.listPanel:SetWidth(405)
    DFSetBackdrop(page.listPanel, DF_PANEL, DF_BORDER)

    page.empty = DFText(page.listPanel, "GameFontNormal", self:L("DF_NONE"), 12)
    page.empty:SetPoint("CENTER", 0, 0)
    page.empty:SetTextColor(unpack(DF_MUTED))

    page.rows = {}
    for index = 1, 8 do
        local row = CreateFrame("Button", nil, page.listPanel)
        row:SetHeight(61)
        row:SetPoint("TOPLEFT", 10, -10 - (index - 1) * 66)
        row:SetPoint("TOPRIGHT", -10, -10 - (index - 1) * 66)
        DFSetBackdrop(row, DF_PANEL_2, DF_BORDER)
        row.type = DFText(row, "GameFontNormalSmall", "", 10)
        row.type:SetWidth(50)
        row.type:SetPoint("TOPLEFT", 10, -9)
        row.type:SetJustifyH("LEFT")
        row.name = DFText(row, "GameFontNormal", "", 12)
        row.name:SetPoint("TOPLEFT", 66, -8)
        row.name:SetPoint("RIGHT", -12, 0)
        row.name:SetJustifyH("LEFT")
        row.meta = DFText(row, "GameFontNormalSmall", "", 10)
        row.meta:SetPoint("BOTTOMLEFT", 10, 9)
        row.meta:SetPoint("RIGHT", -12, 0)
        row.meta:SetJustifyH("LEFT")
        row.meta:SetTextColor(unpack(DF_MUTED))
        row:SetScript("OnClick", function(self)
            if self.activityID then
                GMG.dungeonSelectedID = self.activityID
                GMG:RefreshDungeonFinder(true)
            end
        end)
        page.rows[index] = row
    end

    page.detail = CreateFrame("Frame", nil, page)
    page.detail:SetPoint("TOPLEFT", page.listPanel, "TOPRIGHT", 16, 0)
    page.detail:SetPoint("BOTTOMRIGHT", -22, 22)
    DFSetBackdrop(page.detail, DF_PANEL, DF_BORDER)
    page.detailTitle = DFText(page.detail, "GameFontNormalLarge", "", 17)
    page.detailTitle:SetPoint("TOPLEFT", 18, -18)
    page.detailTitle:SetPoint("TOPRIGHT", -18, -18)
    page.detailTitle:SetJustifyH("LEFT")
    page.detailInfo = DFText(page.detail, "GameFontNormalSmall", "", 11)
    page.detailInfo:SetPoint("TOPLEFT", 18, -52)
    page.detailInfo:SetPoint("TOPRIGHT", -18, -52)
    page.detailInfo:SetHeight(70)
    page.detailInfo:SetJustifyH("LEFT")
    page.detailInfo:SetJustifyV("TOP")
    page.detailInfo:SetTextColor(unpack(DF_MUTED))
    page.roleTitle = DFText(page.detail, "GameFontNormal", self:L("DF_SELECT_ROLE"), 12)
    page.roleTitle:SetPoint("TOPLEFT", 18, -128)
    page.roleButtons = {}
    local roles = {"tank", "heal", "dps", "support"}
    for index, role in ipairs(roles) do
        local button = DFButton(page.detail, DFRoleLabel(self, role), 100, 28)
        local column = (index - 1) % 2
        local row = floor((index - 1) / 2)
        button:SetPoint("TOPLEFT", 18 + column * 112, -152 - row * 34)
        button.role = role
        button:SetScript("OnClick", function(self)
            page.selectedRole = self.role
            GMG:RefreshDungeonFinder(true)
        end)
        page.roleButtons[index] = button
    end
    page.membersTitle = DFText(page.detail, "GameFontNormal", "", 12)
    page.membersTitle:SetPoint("TOPLEFT", 18, -228)
    page.members = DFText(page.detail, "GameFontNormalSmall", "", 11)
    page.members:SetPoint("TOPLEFT", 18, -254)
    page.members:SetPoint("BOTTOMRIGHT", -18, 100)
    page.members:SetJustifyH("LEFT")
    page.members:SetJustifyV("TOP")
    page.members:SetTextColor(unpack(DF_TEXT))
    page.levelWarning = DFText(page.detail, "GameFontNormalSmall", "", 11)
    page.levelWarning:SetPoint("BOTTOMLEFT", 18, 72)
    page.levelWarning:SetPoint("BOTTOMRIGHT", -18, 72)
    page.levelWarning:SetJustifyH("LEFT")
    page.levelWarning:SetTextColor(unpack(DF_RED))
    page.join = DFButton(page.detail, self:L("DF_JOIN"), 150, 34)
    page.join:SetPoint("BOTTOMLEFT", 18, 20)
    page.join:SetScript("OnClick", function()
        local activity = GMG:GetDungeonActivity(GMG.dungeonSelectedID)
        if not activity then return end
        local me = GMG:GetPlayerName()
        local joined = activity.members and activity.members[me] ~= nil
        GMG:RequestDungeonJoin(activity, page.selectedRole, joined)
    end)
    page.close = DFButton(page.detail, self:L("DF_CLOSE"), 150, 34)
    page.close:SetPoint("BOTTOMRIGHT", -18, 20)
    page.close:SetScript("OnClick", function()
        GMG:CloseDungeonActivity(GMG:GetDungeonActivity(GMG.dungeonSelectedID))
    end)
end

function GMG:RefreshDungeonFinder(force)
    local page = self.dungeonPage
    if not page then return end
    if not force and not self.dungeonDirty then return end
    local activities = self:GetDungeonActivities()
    if #activities == 0 then page.empty:Show() else page.empty:Hide() end
    local selectedValid = false
    for _, activity in ipairs(activities) do if activity.id == self.dungeonSelectedID then selectedValid = true end end
    if not selectedValid then self.dungeonSelectedID = activities[1] and activities[1].id or nil end
    for index, row in ipairs(page.rows) do
        local activity = activities[index]
        if activity then
            row.activityID = activity.id
            row:Show()
            row.type:SetText(DFCategoryLabel(self, activity.category))
            row.type:SetTextColor(activity.category == "PVP" and 1.0 or 0.35, activity.category == "PVP" and 0.35 or 0.75, activity.category == "PVP" and 0.42 or 1.0, 1)
            DFBoundedText(row.name, activity.title or "", 310)
            local count = self:CountDungeonActivityMembers(activity)
            row.meta:SetText(self:L("DF_REQUIRED_LEVEL", activity.minLevel or 1, activity.maxLevel or 255) .. "  •  " .. count .. "/" .. (activity.slots or 1))
            if activity.id == self.dungeonSelectedID then
                row:SetBackdropColor(unpack(DF_ACCENT_SOFT))
                row:SetBackdropBorderColor(unpack(DF_ACCENT))
            else
                row:SetBackdropColor(unpack(DF_PANEL_2))
                row:SetBackdropBorderColor(unpack(DF_BORDER))
            end
        else
            row.activityID = nil
            row:Hide()
        end
    end

    local activity = self:GetDungeonActivity(self.dungeonSelectedID)
    if not activity then
        page.detailTitle:SetText(self:L("DF_NONE"))
        page.detailInfo:SetText("")
        page.membersTitle:SetText("")
        page.members:SetText("")
        page.levelWarning:SetText("")
        page.join:Disable()
        page.close:Hide()
        for _, button in ipairs(page.roleButtons) do button:Hide() end
        self.dungeonDirty = false
        return
    end
    page.detailTitle:SetText(activity.title or "")
    local rolesText = {}
    for _, role in ipairs(DFRoleList(activity)) do rolesText[#rolesText + 1] = DFRoleLabel(self, role) end
    page.detailInfo:SetText(DFCategoryLabel(self, activity.category) .. "\n" .. self:L("DF_REQUIRED_LEVEL", activity.minLevel or 1, activity.maxLevel or 255) .. "\n" .. self:L("DF_OWNER", activity.owner or "") .. "\n" .. self:L("DF_ROLES") .. ": " .. table.concat(rolesText, ", "))
    local count = self:CountDungeonActivityMembers(activity)
    page.membersTitle:SetText(self:L("DF_MEMBERS", count, activity.slots or 1))
    local memberLines = {}
    for name, role in pairs(activity.members or {}) do memberLines[#memberLines + 1] = "• " .. name .. " — " .. DFRoleLabel(self, role) end
    sort(memberLines)
    page.members:SetText(#memberLines > 0 and table.concat(memberLines, "\n") or self:L("DF_EMPTY_MEMBERS"))
    local me = self:GetPlayerName()
    local joined = activity.members and activity.members[me] ~= nil
    if joined then page.selectedRole = activity.members[me] end
    local firstRole
    for _, button in ipairs(page.roleButtons) do
        if DFHasRole(activity, button.role) then
            button:Show()
            if not firstRole then firstRole = button.role end
            DFSelectButton(button, page.selectedRole == button.role)
        else
            button:Hide()
        end
    end
    if not page.selectedRole or not DFHasRole(activity, page.selectedRole) then page.selectedRole = firstRole end
    for _, button in ipairs(page.roleButtons) do
        if button:IsShown() then DFSelectButton(button, page.selectedRole == button.role) end
    end
    local level = UnitLevel and UnitLevel("player") or 1
    local eligible = level >= (activity.minLevel or 1) and level <= (activity.maxLevel or 255)
    if eligible then page.levelWarning:SetText("") else page.levelWarning:SetText(self:L("DF_LEVEL_TOO_LOW", activity.minLevel or 1, activity.maxLevel or 255, level)) end
    if joined then
        page.join:Enable()
        page.join.label:SetText(self:L("DF_LEAVE"))
    elseif eligible and page.selectedRole then
        page.join:Enable()
        page.join.label:SetText(self:L("DF_JOIN"))
    else
        page.join:Disable()
        page.join.label:SetText(self:L("DF_JOIN"))
    end
    if self:NormalizeName(activity.owner) == me then page.close:Show() else page.close:Hide() end
    self.dungeonDirty = false
end

function GMG:CreateDungeonCreatePopup()
    if self.dungeonCreatePopup then return end
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(560)
    frame:SetHeight(540)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    DFSetBackdrop(frame, DF_BG, DF_ACCENT)
    frame:Hide()
    self.dungeonCreatePopup = frame
    frame.title = DFText(frame, "GameFontNormalLarge", self:L("DF_CREATE"), 19)
    frame.title:SetPoint("TOPLEFT", 22, -20)

    frame.nameLabel = DFText(frame, "GameFontNormal", self:L("DF_ACTIVITY_NAME"), 12)
    frame.nameLabel:SetPoint("TOPLEFT", 24, -62)
    frame.nameHolder, frame.name = DFEdit(frame, 510, 32, 60)
    frame.nameHolder:SetPoint("TOPLEFT", 24, -86)

    frame.typeLabel = DFText(frame, "GameFontNormal", self:L("DF_ACTIVITY_TYPE"), 12)
    frame.typeLabel:SetPoint("TOPLEFT", 24, -134)
    frame.pve = DFButton(frame, self:L("DF_PVE"), 130, 30)
    frame.pve:SetPoint("TOPLEFT", 24, -158)
    frame.pvp = DFButton(frame, self:L("DF_PVP"), 130, 30)
    frame.pvp:SetPoint("LEFT", frame.pve, "RIGHT", 12, 0)
    frame.category = "PVE"
    frame.pve:SetScript("OnClick", function() frame.category = "PVE"; DFSelectButton(frame.pve, true); DFSelectButton(frame.pvp, false) end)
    frame.pvp:SetScript("OnClick", function() frame.category = "PVP"; DFSelectButton(frame.pve, false); DFSelectButton(frame.pvp, true) end)

    frame.levelLabel = DFText(frame, "GameFontNormal", self:L("DF_LEVEL_RANGE"), 12)
    frame.levelLabel:SetPoint("TOPLEFT", 24, -210)
    frame.minLabel = DFText(frame, "GameFontNormalSmall", self:L("DF_MIN_LEVEL"), 10)
    frame.minLabel:SetPoint("TOPLEFT", 24, -235)
    frame.minHolder, frame.minLevel = DFEdit(frame, 110, 30, 3)
    frame.minHolder:SetPoint("TOPLEFT", 24, -254)
    frame.minLevel:SetNumeric(true)
    frame.maxLabel = DFText(frame, "GameFontNormalSmall", self:L("DF_MAX_LEVEL"), 10)
    frame.maxLabel:SetPoint("TOPLEFT", 154, -235)
    frame.maxHolder, frame.maxLevel = DFEdit(frame, 110, 30, 3)
    frame.maxHolder:SetPoint("TOPLEFT", 154, -254)
    frame.maxLevel:SetNumeric(true)
    frame.slotsLabel = DFText(frame, "GameFontNormalSmall", self:L("DF_PLACES"), 10)
    frame.slotsLabel:SetPoint("TOPLEFT", 284, -235)
    frame.slotsHolder, frame.slots = DFEdit(frame, 110, 30, 2)
    frame.slotsHolder:SetPoint("TOPLEFT", 284, -254)
    frame.slots:SetNumeric(true)

    frame.rolesLabel = DFText(frame, "GameFontNormal", self:L("DF_ROLES"), 12)
    frame.rolesLabel:SetPoint("TOPLEFT", 24, -310)
    frame.roleChecks = {}
    local roles = {"tank", "heal", "dps", "support"}
    for index, role in ipairs(roles) do
        local check = DFCheck(frame, DFRoleLabel(self, role), 120)
        check:SetPoint("TOPLEFT", 24 + (index - 1) * 126, -338)
        check.role = role
        check:SetChecked(true)
        frame.roleChecks[index] = check
    end

    frame.create = DFButton(frame, self:L("DF_CREATE_CONFIRM"), 150, 36)
    frame.create:SetPoint("BOTTOMLEFT", 24, 22)
    frame.create:SetScript("OnClick", function()
        local selected = {}
        for _, check in ipairs(frame.roleChecks) do if check:GetChecked() then selected[#selected + 1] = check.role end end
        if GMG:CreateDungeonActivity(frame.name:GetText(), frame.category, frame.minLevel:GetText(), frame.maxLevel:GetText(), frame.slots:GetText(), table.concat(selected, ",")) then
            frame:Hide()
            GMG:ShowTab("dungeon")
        end
    end)
    frame.cancel = DFButton(frame, self:L("DF_CANCEL"), 150, 36)
    frame.cancel:SetPoint("BOTTOMRIGHT", -24, 22)
    frame.cancel:SetScript("OnClick", function() frame:Hide() end)
end

function GMG:OpenDungeonCreatePopup()
    self:CreateDungeonCreatePopup()
    local frame = self.dungeonCreatePopup
    frame.name:SetText("")
    frame.minLevel:SetText(tostring(UnitLevel and UnitLevel("player") or 1))
    frame.maxLevel:SetText(tostring(UnitLevel and UnitLevel("player") or 1))
    frame.slots:SetText("5")
    frame.category = "PVE"
    DFSelectButton(frame.pve, true)
    DFSelectButton(frame.pvp, false)
    for _, check in ipairs(frame.roleChecks) do check:SetChecked(true) end
    frame:Show()
    frame.name:SetFocus()
end

function GMG:InstallDungeonFinderTab()
    if not self.mainFrame or not self.mainFrame.sidebar or self.mainFrame.tabs.dungeon then return end
    local tab = DFButton(self.mainFrame.sidebar, self:L("DF_TAB"), 154, 38)
    tab:SetPoint("TOPLEFT", 18, -48 - 3 * 46)
    tab.localeKey = "DF_TAB"
    tab:SetScript("OnClick", function() GMG:ShowTab("dungeon") end)
    self.mainFrame.tabs.dungeon = tab
end

function GMG:RefreshDungeonTabSelection(selected)
    if not self.mainFrame or not self.mainFrame.tabs then return end
    for key, tab in pairs(self.mainFrame.tabs) do
        DFSelectButton(tab, key == selected)
    end
end

function GMG:InstallDungeonActivityBadges()
    if self.launcher and not self.launcher.activityBadge then
        local badge = CreateFrame("Button", nil, self.launcher)
        badge:SetWidth(36)
        badge:SetHeight(36)
        badge:SetPoint("LEFT", self.launcher, "RIGHT", 4, 0)
        badge:SetFrameStrata("FULLSCREEN_DIALOG")
        DFSetBackdrop(badge, {0.04, 0.16, 0.09, 0.98}, DF_GREEN)
        badge.icon = badge:CreateTexture(nil, "ARTWORK")
        badge.icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
        badge.icon:SetWidth(20)
        badge.icon:SetHeight(20)
        badge.icon:SetPoint("LEFT", 4, 0)
        badge.count = DFText(badge, "GameFontNormalSmall", "0", 10)
        badge.count:SetPoint("RIGHT", -4, 0)
        badge.count:SetTextColor(unpack(DF_GREEN))
        badge:SetScript("OnClick", function() if not GMG.mainFrame or not GMG.mainFrame:IsShown() then GMG:Toggle() end; GMG:ShowTab("dungeon") end)
        badge:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(GMG:L("DF_TITLE"), 0.60, 1.00, 0.72)
            GameTooltip:AddLine(GMG:L("DF_ACTIVITY_BADGE_HELP", #GMG:GetDungeonActivities()), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        badge:SetScript("OnLeave", function() GameTooltip:Hide() end)
        self.launcher.activityBadge = badge
    end
    if self.mainFrame and self.mainFrame.onlineBadge and not self.mainFrame.activityBadge then
        local badge = CreateFrame("Button", nil, self.mainFrame.header)
        badge:SetWidth(42)
        badge:SetHeight(30)
        badge:SetPoint("RIGHT", self.mainFrame.onlineBadge, "LEFT", -6, 0)
        DFSetBackdrop(badge, {0.04, 0.16, 0.09, 0.98}, DF_GREEN)
        badge.icon = badge:CreateTexture(nil, "ARTWORK")
        badge.icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
        badge.icon:SetWidth(18)
        badge.icon:SetHeight(18)
        badge.icon:SetPoint("LEFT", 4, 0)
        badge.count = DFText(badge, "GameFontNormalSmall", "0", 10)
        badge.count:SetPoint("RIGHT", -4, 0)
        badge.count:SetTextColor(unpack(DF_GREEN))
        badge:SetScript("OnClick", function() GMG:ShowTab("dungeon") end)
        self.mainFrame.activityBadge = badge
    end
end

function GMG:RefreshDungeonActivityBadges()
    self:InstallDungeonActivityBadges()
    local count = #self:GetDungeonActivities()
    if self.launcher and self.launcher.activityBadge then
        self.launcher.activityBadge.count:SetText(tostring(count))
        if count > 0 then self.launcher.activityBadge:Show() else self.launcher.activityBadge:Hide() end
    end
    if self.mainFrame and self.mainFrame.activityBadge then
        self.mainFrame.activityBadge.count:SetText(tostring(count))
        if count > 0 then self.mainFrame.activityBadge:Show() else self.mainFrame.activityBadge:Hide() end
    end
end

function GMG:InstallDungeonChatLinks()
    if not self.chatPage or not self.chatPage.messages then return end
    self.chatPage.messages:SetScript("OnHyperlinkClick", function(_, link, _, button)
        local activityID = string.match(link or "", "^gmgactivity:(.+)$")
        if activityID then
            GMG.dungeonSelectedID = activityID
            GMG:ShowTab("dungeon")
            if not GMG:GetDungeonActivity(activityID) then GMG:Print(GMG:L("DF_ACTIVITY_GONE")) end
            return
        end
        local name = string.match(link or "", "^gmgplayer:(.+)$")
        if name then GMG:OpenChatMemberMenu(name, GMG.chatPage.messages, button); return end
        local urlID = string.match(link or "", "^gmgurl:(.+)$")
        if urlID and GMG.copyableURLs and GMG.copyableURLs[urlID] then GMG:OpenCopyLink(GMG.copyableURLs[urlID]) end
    end)
end

-- Temporary fluorescent mention highlighting.
function GMG:QueueChatMentionHighlight(messageID)
    if not messageID or messageID == "" then return end
    self.pendingChatMentionHighlights = self.pendingChatMentionHighlights or {}
    self.pendingChatMentionHighlights[messageID] = true
end

function GMG:ActivateChatMentionHighlights()
    if not self.db or not self.db.profile or self.db.profile.temporaryMentionHighlight == false then return end
    if not self.pendingChatMentionHighlights then return end
    local active = {}
    local found = false
    for id in pairs(self.pendingChatMentionHighlights) do active[id] = true; found = true end
    if not found then return end
    self.activeChatMentionHighlights = active
    self.pendingChatMentionHighlights = {}
    self.chatMentionHighlightUntil = GetTime() + 5.0
    self.chatDirty = true
    if self.RefreshChat then self:RefreshChat(true) end
end

local GMGFormatHistoryLineBeforeDF = GMG.FormatHistoryLine
function GMG:FormatHistoryLine(message)
    if self.activeChatMentionHighlights and self.activeChatMentionHighlights[message.id]
        and self.chatMentionHighlightUntil and GetTime() < self.chatMentionHighlightUntil then
        local sender = self:NormalizeName(message.sender)
        return "|cff39ff14▰ [" .. date("%H:%M", tonumber(message.ts) or time()) .. "] "
            .. "|Hgmgplayer:" .. sender .. "|h[" .. sender .. "]|h: " .. self:LinkifyText(message.text or "") .. " ▰|r"
    end
    return GMGFormatHistoryLineBeforeDF(self, message)
end

local GMGChatGuildBeforeDF = GMG.CHAT_MSG_GUILD
function GMG:CHAT_MSG_GUILD(message, sender)
    local stamp = time()
    local mentioned = strlower(self:NormalizeName(sender)) ~= strlower(self:GetPlayerName()) and self:IsPlayerMentioned(message)
    GMGChatGuildBeforeDF(self, message, sender)
    if mentioned then
        local id = self:BuildMessageID(sender, message, stamp)
        self:QueueChatMentionHighlight(id)
        if self.mainFrame and self.mainFrame:IsShown() and self.chatPage and self.chatPage:IsShown() then self:ActivateChatMentionHighlights() end
    end
end

local GMGAddHistoryMessageBeforeDF = GMG.AddHistoryMessage
function GMG:AddHistoryMessage(sender, text, timestamp, source, suppliedID)
    local added = GMGAddHistoryMessageBeforeDF(self, sender, text, timestamp, source, suppliedID)
    if added and source == "sync" and (time() - (tonumber(timestamp) or time())) <= 120
        and strlower(self:NormalizeName(sender)) ~= strlower(self:GetPlayerName()) and self:IsPlayerMentioned(text) then
        self:QueueChatMentionHighlight(suppliedID or self:BuildMessageID(sender, text, timestamp))
    end
    return added
end

-- Movable notification bar.
function GMG:SaveNotificationBarPosition()
    if not self.toast or not self.db or not self.db.profile then return end
    local point, _, relativePoint, x, y = self.toast:GetPoint(1)
    self.db.profile.notificationPosition = "custom"
    self.db.profile.notificationCustomPoint = point or "TOP"
    self.db.profile.notificationCustomRelativePoint = relativePoint or "TOP"
    self.db.profile.notificationCustomX = floor(x or 0)
    self.db.profile.notificationCustomY = floor(y or -105)
    if self.PersistSettings then self:PersistSettings() end
end

local GMGApplyNotificationPositionBeforeDF = GMG.ApplyNotificationPosition
function GMG:ApplyNotificationPosition()
    if self.toast and self.db and self.db.profile and self.db.profile.notificationPosition == "custom" then
        self.toast:ClearAllPoints()
        self.toast:SetPoint(self.db.profile.notificationCustomPoint or "TOP", UIParent,
            self.db.profile.notificationCustomRelativePoint or "TOP",
            self.db.profile.notificationCustomX or 0, self.db.profile.notificationCustomY or -105)
        return
    end
    GMGApplyNotificationPositionBeforeDF(self)
end

function GMG:SetNotificationBarUnlocked(unlocked)
    if not self.toast then return end
    self.notificationBarUnlocked = unlocked and true or false
    self.toast:SetMovable(true)
    self.toast:SetClampedToScreen(true)
    self.toast:EnableMouse(self.notificationBarUnlocked)
    self.toast:RegisterForDrag("LeftButton")
    if self.notificationBarUnlocked then
        self.toast:SetAlpha(1)
        self.toast.text:SetText(self:L("DF_MOVE_NOTIFICATION_HELP"))
        self.toast.icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
        self.toast:SetBackdropColor(unpack(DF_PANEL))
        self.toast:SetBackdropBorderColor(unpack(DF_GREEN))
        self.toast:Show()
    elseif not self.toastActive then
        self.toast:Hide()
    end
    if self.notificationSettingsPopup and self.notificationSettingsPopup.moveBar and self.notificationSettingsPopup.moveBar.label then
        self.notificationSettingsPopup.moveBar.label:SetText(self:L(self.notificationBarUnlocked and "DF_LOCK_NOTIFICATION" or "DF_MOVABLE_NOTIFICATION"))
    end
end

function GMG:InstallNotificationBarMovement()
    if not self.toast or self.toast.dfMoveInstalled then return end
    self.toast.dfMoveInstalled = true
    self.toast:SetMovable(true)
    self.toast:SetClampedToScreen(true)
    self.toast:RegisterForDrag("LeftButton")
    self.toast:SetScript("OnDragStart", function(frame)
        if GMG.notificationBarUnlocked then frame:StartMoving() end
    end)
    self.toast:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        GMG:SaveNotificationBarPosition()
        GMG:Print(GMG:L("DF_NOTIFICATION_MOVED"))
    end)
    self.toast:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" and GMG.notificationBarUnlocked then GMG:SetNotificationBarUnlocked(false) end
    end)
    self:ApplyNotificationPosition()
end

local GMGCreateNotificationSettingsBeforeDF = GMG.CreateNotificationSettingsPopup
function GMG:CreateNotificationSettingsPopup()
    GMGCreateNotificationSettingsBeforeDF(self)
    local frame = self.notificationSettingsPopup
    if not frame or frame.moveBar then return end
    frame.moveBar = DFButton(frame, self:L("DF_MOVABLE_NOTIFICATION"), 210, 34)
    frame.moveBar:SetPoint("BOTTOM", 0, 20)
    frame.moveBar:SetScript("OnClick", function() GMG:SetNotificationBarUnlocked(not GMG.notificationBarUnlocked) end)
end

-- Add setting for temporary mention-line highlight.
function GMG:InstallTemporaryMentionSetting()
    local page = self.settingsPage
    if not page or page.temporaryMentionHighlight then return end
    page.temporaryMentionHighlight = DFCheck(page.left, self:L("DF_MENTION_HIGHLIGHT_SETTING"), 360)
    page.temporaryMentionHighlight:SetPoint("TOPLEFT", 18, -296)
    page.temporaryMentionHighlight:SetChecked(self.db.profile.temporaryMentionHighlight ~= false)
    page.temporaryMentionHighlight:SetScript("OnClick", function(button)
        button:SetChecked(not button:GetChecked())
        GMG.db.profile.temporaryMentionHighlight = button:GetChecked()
        GMG:PersistSettings()
    end)
    page.temporaryMentionHighlight:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L("DF_MENTION_HIGHLIGHT_SETTING"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("DF_MENTION_HIGHLIGHT_HELP"), 0.72, 0.74, 0.84, true)
        GameTooltip:Show()
    end)
    page.temporaryMentionHighlight:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local GMGCreateUIBeforeDF = GMG.CreateUI
function GMG:CreateUI(...)
    local wanted = self.db and self.db.profile and self.db.profile.lastTab
    GMGCreateUIBeforeDF(self, ...)
    self:CreateDungeonFinderPage()
    self:InstallDungeonFinderTab()
    self:InstallDungeonActivityBadges()
    self:InstallDungeonChatLinks()
    self:InstallNotificationBarMovement()
    self:InstallTemporaryMentionSetting()
    self:ApplyProfessionalSettingsLayout()
    self.dungeonDirty = true
    self:RefreshDungeonFinder(true)
    self:RefreshDungeonActivityBadges()
    if wanted == "dungeon" then self:ShowTab("dungeon") end
end

local GMGShowTabBeforeDF = GMG.ShowTab
function GMG:ShowTab(key, ...)
    if key == "dungeon" then
        if self.chatPage then self.chatPage:Hide() end
        if self.rosterPage then self.rosterPage:Hide() end
        if self.guildPage then self.guildPage:Hide() end
        if self.settingsPage then self.settingsPage:Hide() end
        if self.dungeonPage then self.dungeonPage:Show() end
        if self.db and self.db.profile then self.db.profile.lastTab = "dungeon" end
        self:RefreshDungeonTabSelection("dungeon")
        self:RefreshDungeonFinder(true)
        return
    end
    GMGShowTabBeforeDF(self, key, ...)
    if self.dungeonPage then self.dungeonPage:Hide() end
    self:RefreshDungeonTabSelection(key == "settings" and "settings" or key)
    if key == "chat" then self:ActivateChatMentionHighlights() end
end


local GMGToggleBeforeDF = GMG.Toggle
function GMG:Toggle(...)
    GMGToggleBeforeDF(self, ...)
    if self.mainFrame and self.mainFrame:IsShown() and self.chatPage and self.chatPage:IsShown() then
        self:ActivateChatMentionHighlights()
    end
end

local GMGRefreshHeaderBeforeDF = GMG.RefreshHeader
function GMG:RefreshHeader(...)
    GMGRefreshHeaderBeforeDF(self, ...)
    self:RefreshDungeonActivityBadges()
end

local GMGRefreshAllBeforeDF = GMG.RefreshAll
function GMG:RefreshAll(...)
    GMGRefreshAllBeforeDF(self, ...)
    self:RefreshDungeonFinder(false)
    self:RefreshDungeonActivityBadges()
    if self.loginMentionManager then self:RefreshLoginMentionManager() end
end

local GMGRefreshLocalizationBeforeDF = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeDF(self, ...)
    if self.mainFrame and self.mainFrame.tabs and self.mainFrame.tabs.dungeon then
        self.mainFrame.tabs.dungeon.label:SetText(self:L("DF_TAB"))
    end
    local page = self.dungeonPage
    if page then
        page.title:SetText(self:L("DF_TITLE"))
        page.create.label:SetText(self:L("DF_CREATE"))
        page.refresh.label:SetText(self:L("DF_REFRESH"))
        page.empty:SetText(self:L("DF_NONE"))
        page.roleTitle:SetText(self:L("DF_SELECT_ROLE"))
        page.join.label:SetText(self:L("DF_JOIN"))
        page.close.label:SetText(self:L("DF_CLOSE"))
        for _, button in ipairs(page.roleButtons or {}) do button.label:SetText(DFRoleLabel(self, button.role)) end
    end
    if self.notificationSettingsPopup and self.notificationSettingsPopup.moveBar and self.notificationSettingsPopup.moveBar.label then
        self.notificationSettingsPopup.moveBar.label:SetText(self:L(self.notificationBarUnlocked and "DF_LOCK_NOTIFICATION" or "DF_MOVABLE_NOTIFICATION"))
    end
    if self.settingsPage and self.settingsPage.temporaryMentionHighlight then
        self.settingsPage.temporaryMentionHighlight.label:SetText(self:L("DF_MENTION_HIGHLIGHT_SETTING"))
    end
    self:RefreshDungeonFinder(true)
end

local GMGRefreshSettingsBeforeDF = GMG.RefreshSettings
function GMG:RefreshSettings(...)
    GMGRefreshSettingsBeforeDF(self, ...)
    self:InstallTemporaryMentionSetting()
    if self.settingsPage and self.settingsPage.temporaryMentionHighlight then
        self.settingsPage.temporaryMentionHighlight:SetChecked(self.db.profile.temporaryMentionHighlight ~= false)
    end
end

local GMGHandleCompletePayloadBeforeDF = GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload, channel, sender)
    local values = DFSplit(payload)
    local command = values[1]
    if command ~= "DA" and command ~= "DJ" and command ~= "DC" and command ~= "DR" then
        return GMGHandleCompletePayloadBeforeDF(self, payload, channel, sender)
    end
    if values[2] ~= self:GetGuildHash() then return end
    sender = self:NormalizeName(sender)
    if sender == self:GetPlayerName() or not self:IsGuildMemberName(sender) then return end
    if command == "DA" then
        local owner = self:NormalizeName(DFUnescape(values[8]))
        if owner ~= sender then return end
        local activity = {
            id = DFUnescape(values[3]),
            revision = tonumber(values[4]) or 1,
            createdAt = tonumber(values[5]) or time(),
            updatedAt = tonumber(values[6]) or time(),
            expiresAt = tonumber(values[7]) or (time() + 14400),
            owner = owner,
            title = DFUnescape(values[9]),
            category = values[10] == "PVP" and "PVP" or "PVE",
            minLevel = DFClamp(values[11], 1, 255, 1),
            maxLevel = DFClamp(values[12], 1, 255, 255),
            slots = DFClamp(values[13], 1, 40, 5),
            roles = DFUnescape(values[14]),
            members = self:DeserializeDungeonMembers(DFUnescape(values[15])),
        }
        self:StoreDungeonActivity(activity, true)
    elseif command == "DJ" then
        local id = DFUnescape(values[3])
        local player = self:NormalizeName(DFUnescape(values[4]))
        local role = DFUnescape(values[5])
        local action = values[6]
        self:ApplyDungeonJoinRequest(id, player, role, action, sender)
    elseif command == "DC" then
        local id = DFUnescape(values[3])
        local owner = self:NormalizeName(DFUnescape(values[5]))
        local reason = DFUnescape(values[6])
        local existing = self:GetDungeonActivity(id)
        if owner == sender and existing and self:NormalizeName(existing.owner) == sender then
            self:RemoveDungeonActivity(id, reason, reason ~= "full")
        end
    elseif command == "DR" then
        for _, activity in ipairs(self:GetDungeonActivities()) do
            if self:NormalizeName(activity.owner) == self:GetPlayerName() then
                self:BroadcastDungeonActivity(activity, "WHISPER", sender, false)
            end
        end
    end
end

local GMGSyncTickBeforeDF = GMG.SyncTick
function GMG:SyncTick(initial)
    GMGSyncTickBeforeDF(self, initial)
    if not self:IsInGuild() then return end
    self:PruneDungeonActivities()
    local now = time()
    if initial or now - (self.lastDungeonRequestAt or 0) >= 30 then
        self.lastDungeonRequestAt = now
        self:QueuePacket(table.concat({"DR", self:GetGuildHash() or ""}, "|"), "GUILD", nil, false)
    end
    if initial or now - (self.lastDungeonBroadcastAt or 0) >= 15 then
        self.lastDungeonBroadcastAt = now
        for _, activity in ipairs(self:GetDungeonActivities()) do
            if self:NormalizeName(activity.owner) == self:GetPlayerName() then self:BroadcastDungeonActivity(activity, "GUILD", nil, false) end
        end
    end
    self:SendQueuedPackets(initial and 20 or 12)
end

local GMGOnUpdateBeforeDF = GMG.OnUpdate
function GMG:OnUpdate(elapsed)
    GMGOnUpdateBeforeDF(self, elapsed)
    if self.chatMentionHighlightUntil and GetTime() >= self.chatMentionHighlightUntil then
        self.chatMentionHighlightUntil = nil
        self.activeChatMentionHighlights = nil
        self.chatDirty = true
        if self.chatPage and self.chatPage:IsShown() then self:RefreshChat(true) end
    end
end

local GMGCreateLauncherBeforeDF = GMG.CreateLauncher
function GMG:CreateLauncher(...)
    local launcher = GMGCreateLauncherBeforeDF(self, ...)
    self:InstallDungeonActivityBadges()
    return launcher
end

local GMGCreateToastBeforeDF = GMG.CreateToast
function GMG:CreateToast(...)
    GMGCreateToastBeforeDF(self, ...)
    self:InstallNotificationBarMovement()
end


local GMGApplyProfessionalSettingsLayoutBeforeDF = GMG.ApplyProfessionalSettingsLayout
function GMG:ApplyProfessionalSettingsLayout(...)
    if GMGApplyProfessionalSettingsLayoutBeforeDF then GMGApplyProfessionalSettingsLayoutBeforeDF(self, ...) end
    local page = self.settingsPage
    if not page then return end
    if page.temporaryMentionHighlight then
        page.temporaryMentionHighlight:ClearAllPoints()
        page.temporaryMentionHighlight:SetPoint("TOPLEFT", 18, -296)
        page.displayTitle:ClearAllPoints(); page.displayTitle:SetPoint("TOPLEFT", 18, -342)
        page.showOffline:ClearAllPoints(); page.showOffline:SetPoint("TOPLEFT", 18, -372)
        page.showLauncher:ClearAllPoints(); page.showLauncher:SetPoint("TOPLEFT", 18, -405)
        page.keyTitle:ClearAllPoints(); page.keyTitle:SetPoint("TOPLEFT", 18, -453)
        page.currentKey:ClearAllPoints(); page.currentKey:SetPoint("TOPLEFT", 18, -481)
        page.changeKey:ClearAllPoints(); page.changeKey:SetPoint("TOPLEFT", 18, -515); page.changeKey:SetWidth(156)
        page.clearKey:ClearAllPoints(); page.clearKey:SetPoint("LEFT", page.changeKey, "RIGHT", 12, 0); page.clearKey:SetWidth(156)
    end
end

local GMGPlayerLogoutBeforeDF = GMG.PLAYER_LOGOUT
function GMG:PLAYER_LOGOUT(...)
    self:SaveNotificationBarPosition()
    return GMGPlayerLogoutBeforeDF(self, ...)
end
