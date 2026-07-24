-- G.B.G (Glayna Better Guild)
-- v1.7.2: lead-controlled guild activity management.
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

local V171_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}
local V171_BG = {0.025, 0.031, 0.052, 0.99}
local V171_PANEL = {0.045, 0.052, 0.082, 0.99}
local V171_PANEL_2 = {0.075, 0.082, 0.125, 0.98}
local V171_BORDER = {0.24, 0.22, 0.38, 1}
local V171_ACCENT = {0.60, 0.42, 1.00, 1}
local V171_ACCENT_SOFT = {0.30, 0.19, 0.52, 0.95}
local V171_TEXT = {0.88, 0.90, 0.96, 1}
local V171_MUTED = {0.48, 0.52, 0.64, 1}
local V171_GREEN = {0.25, 0.90, 0.55, 1}
local V171_RED = {0.95, 0.34, 0.42, 1}

local function VBackdrop(frame, background, border)
    frame:SetBackdrop(V171_BACKDROP)
    frame:SetBackdropColor(unpack(background or V171_BG))
    frame:SetBackdropBorderColor(unpack(border or V171_BORDER))
end

local function VText(parent, fontObject, text, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObject or "GameFontNormal")
    if size then
        local font, _, flags = fs:GetFont()
        if font then fs:SetFont(font, size, flags) end
    end
    fs:SetText(text or "")
    fs:SetTextColor(unpack(V171_TEXT))
    return fs
end

local function VBoundedText(fontString, text, width)
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

local function VButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 110)
    button:SetHeight(height or 28)
    VBackdrop(button, V171_PANEL_2, V171_BORDER)
    button.label = VText(button, "GameFontNormal", text or "", 11)
    button.label:SetPoint("LEFT", 5, 0)
    button.label:SetPoint("RIGHT", -5, 0)
    button.label:SetJustifyH("CENTER")
    button:SetScript("OnEnter", function(self)
        if not self.disabled then
            self:SetBackdropColor(unpack(V171_ACCENT_SOFT))
            self:SetBackdropBorderColor(unpack(V171_ACCENT))
        end
    end)
    button:SetScript("OnLeave", function(self)
        if self.selected then
            self:SetBackdropColor(unpack(V171_ACCENT_SOFT))
            self:SetBackdropBorderColor(unpack(V171_ACCENT))
        else
            self:SetBackdropColor(unpack(V171_PANEL_2))
            self:SetBackdropBorderColor(unpack(V171_BORDER))
        end
    end)
    button:SetScript("OnDisable", function(self) self.disabled = true; self:SetAlpha(0.42) end)
    button:SetScript("OnEnable", function(self) self.disabled = false; self:SetAlpha(1) end)
    return button
end

local function VSelect(button, selected)
    if not button then return end
    button.selected = selected and true or false
    if button.selected then
        button:SetBackdropColor(unpack(V171_ACCENT_SOFT))
        button:SetBackdropBorderColor(unpack(V171_ACCENT))
    else
        button:SetBackdropColor(unpack(V171_PANEL_2))
        button:SetBackdropBorderColor(unpack(V171_BORDER))
    end
end

local function VCheck(parent, label, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 200)
    button:SetHeight(24)
    button.box = CreateFrame("Frame", nil, button)
    button.box:SetWidth(18)
    button.box:SetHeight(18)
    button.box:SetPoint("LEFT", 0, 0)
    VBackdrop(button.box, V171_PANEL, V171_BORDER)
    button.fill = button.box:CreateTexture(nil, "ARTWORK")
    button.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.fill:SetPoint("TOPLEFT", 4, -4)
    button.fill:SetPoint("BOTTOMRIGHT", -4, 4)
    button.fill:SetVertexColor(unpack(V171_ACCENT))
    button.fill:Hide()
    button.label = VText(button, "GameFontNormal", label or "", 11)
    button.label:SetPoint("LEFT", button.box, "RIGHT", 8, 0)
    button.label:SetPoint("RIGHT", 0, 0)
    button.label:SetJustifyH("LEFT")
    function button:SetChecked(value)
        self.checked = value and true or false
        if self.checked then
            self.fill:Show()
            self.box:SetBackdropColor(unpack(V171_ACCENT_SOFT))
            self.box:SetBackdropBorderColor(unpack(V171_ACCENT))
        else
            self.fill:Hide()
            self.box:SetBackdropColor(unpack(V171_PANEL))
            self.box:SetBackdropBorderColor(unpack(V171_BORDER))
        end
    end
    function button:GetChecked() return self.checked end
    button:SetChecked(false)
    button:SetScript("OnClick", function(self) self:SetChecked(not self:GetChecked()) end)
    return button
end

local function V171Escape(value)
    value = tostring(value or "")
    value = string.gsub(value, "%%", "%%25")
    value = string.gsub(value, "|", "%%7C")
    value = string.gsub(value, "\n", "%%0A")
    value = string.gsub(value, "\r", "%%0D")
    return value
end

local function V171Unescape(value)
    value = tostring(value or "")
    value = string.gsub(value, "%%0D", "\r")
    value = string.gsub(value, "%%0A", "\n")
    value = string.gsub(value, "%%7C", "|")
    value = string.gsub(value, "%%25", "%%")
    return value
end

local function V171Split(payload)
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

local function V171Clamp(value, low, high, fallback)
    value = tonumber(value)
    if not value then return fallback end
    value = floor(value)
    if value < low then return low end
    if value > high then return high end
    return value
end

local function V171RoleList(activity)
    local roles = {}
    for role in string.gmatch(activity and activity.roles or "", "[^,]+") do roles[#roles + 1] = role end
    return roles
end

local function V171HasRole(activity, role)
    for _, value in ipairs(V171RoleList(activity)) do if value == role then return true end end
    return false
end

local function V171RoleLabel(self, role)
    local keys = {tank = "DF_ROLE_TANK", heal = "DF_ROLE_HEAL", dps = "DF_ROLE_DPS", support = "DF_ROLE_SUPPORT"}
    return self:L(keys[role] or "DF_ROLE_DPS")
end

local function V171CategoryLabel(self, category)
    return category == "PVP" and self:L("DF_PVP") or self:L("DF_PVE")
end

local V171_EN = {
    DF_EDIT = "Edit",
    DF_SAVE = "Save changes",
    DF_EDIT_TITLE = "Edit activity",
    DF_EDIT_ONLY_LEAD = "Only the activity leader can edit or manage this activity.",
    DF_APPROVAL_MODE = "Registration approval",
    DF_APPROVAL_AUTO = "Automatic: accept valid roles",
    DF_APPROVAL_MANUAL = "Manual validation by the leader",
    DF_AUTO_INVITE_SETTING = "Automatically invite accepted players",
    DF_APPLICANTS = "Applicants (%d)",
    DF_APPLICANTS_TITLE = "Pending applicants",
    DF_NO_APPLICANTS = "No registration is awaiting validation.",
    DF_ACCEPT = "Accept",
    DF_REJECT = "Reject",
    DF_INVITE_ALL = "Invite registered players",
    DF_INVITE_RETRY = "Invitation sent again to %s.",
    DF_PENDING = "Request pending validation",
    DF_CANCEL_REQUEST = "Cancel request",
    DF_REQUEST_SENT = "Registration request sent to the leader.",
    DF_REQUEST_REJECTED = "%s's registration was rejected.",
    DF_REQUEST_ACCEPTED = "%s was accepted as %s.",
    DF_AUTO_GROUP_ACCEPT = "Guild Finder invitation from %s accepted automatically.",
    DF_GROUP_SIZE = "Group: %d/%d — %d place(s) available",
    DF_TARGET_TOO_SMALL = "The target size cannot be lower than the current group/reserved size (%d).",
    DF_FULL_REAL_GROUP = "The real group reached %d players. The activity was closed.",
    DF_NOT_GROUP_LEAD = "You must be the current group leader to manage this activity.",
    DF_ALREADY_PENDING = "Your request is already awaiting validation.",
    DF_NO_PLACE = "No place is currently available.",
    DF_MANUAL = "Manual",
    DF_AUTOMATIC = "Automatic",
    DF_AVAILABLE_SHORT = "%d available",
}
local V171_FR = {
    DF_EDIT = "Modifier",
    DF_SAVE = "Enregistrer les modifications",
    DF_EDIT_TITLE = "Modifier l'activité",
    DF_EDIT_ONLY_LEAD = "Seul le responsable de l'activité peut la modifier ou la gérer.",
    DF_APPROVAL_MODE = "Validation des inscriptions",
    DF_APPROVAL_AUTO = "Automatique : accepter les rôles valides",
    DF_APPROVAL_MANUAL = "Validation manuelle par le responsable",
    DF_AUTO_INVITE_SETTING = "Inviter automatiquement les joueurs acceptés",
    DF_APPLICANTS = "Demandes (%d)",
    DF_APPLICANTS_TITLE = "Demandes en attente",
    DF_NO_APPLICANTS = "Aucune inscription n'attend de validation.",
    DF_ACCEPT = "Accepter",
    DF_REJECT = "Refuser",
    DF_INVITE_ALL = "Inviter les inscrits",
    DF_INVITE_RETRY = "Invitation renvoyée à %s.",
    DF_PENDING = "Demande en attente de validation",
    DF_CANCEL_REQUEST = "Annuler la demande",
    DF_REQUEST_SENT = "Demande d'inscription envoyée au responsable.",
    DF_REQUEST_REJECTED = "L'inscription de %s a été refusée.",
    DF_REQUEST_ACCEPTED = "%s a été accepté en %s.",
    DF_AUTO_GROUP_ACCEPT = "Invitation Dungeon Finder de %s acceptée automatiquement.",
    DF_GROUP_SIZE = "Groupe : %d/%d — %d place(s) disponible(s)",
    DF_TARGET_TOO_SMALL = "La taille cible ne peut pas être inférieure à la taille actuelle du groupe/réservations (%d).",
    DF_FULL_REAL_GROUP = "Le groupe réel a atteint %d joueurs. L'activité a été fermée.",
    DF_NOT_GROUP_LEAD = "Vous devez être le responsable actuel du groupe pour gérer cette activité.",
    DF_ALREADY_PENDING = "Votre demande attend déjà une validation.",
    DF_NO_PLACE = "Aucune place n'est actuellement disponible.",
    DF_MANUAL = "Manuel",
    DF_AUTOMATIC = "Automatique",
    DF_AVAILABLE_SHORT = "%d disponible(s)",
}
GMG.Locales = GMG.Locales or {en = {}, fr = {}}
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(V171_EN) do GMG.Locales.en[key] = value end
for key, value in pairs(V171_FR) do GMG.Locales.fr[key] = value end

function GMG:GetActualGroupMemberSet()
    local members = {}
    local count = 0
    local function Add(name)
        name = self:NormalizeName(name)
        local key = strlower(name or "")
        if name ~= "" and not members[key] then members[key] = name; count = count + 1 end
    end

    local raidCount = GetNumRaidMembers and (GetNumRaidMembers() or 0) or 0
    if raidCount > 0 then
        for index = 1, raidCount do
            local name = GetRaidRosterInfo and GetRaidRosterInfo(index)
            Add(name)
        end
    else
        Add(self:GetPlayerName())
        local partyCount = GetNumPartyMembers and (GetNumPartyMembers() or 0) or 0
        for index = 1, partyCount do Add(UnitName and UnitName("party" .. index)) end
    end
    if count <= 0 then Add(self:GetPlayerName()) end
    return members, count
end

function GMG:GetActualGroupSize()
    local _, count = self:GetActualGroupMemberSet()
    return max(1, count or 1)
end

function GMG:IsCurrentGroupLeader()
    local raidCount = GetNumRaidMembers and (GetNumRaidMembers() or 0) or 0
    if raidCount > 0 then
        if IsRaidLeader then return IsRaidLeader() and true or false end
        if UnitIsGroupLeader then return UnitIsGroupLeader("player") and true or false end
        return false
    end
    local partyCount = GetNumPartyMembers and (GetNumPartyMembers() or 0) or 0
    if partyCount > 0 then
        if IsPartyLeader then return IsPartyLeader() and true or false end
        if UnitIsGroupLeader then return UnitIsGroupLeader("player") and true or false end
        return false
    end
    return true
end

function GMG:CanManageDungeonActivity(activity, silent)
    if not activity or self:NormalizeName(activity.owner) ~= self:GetPlayerName() then
        if not silent then self:Print(self:L("DF_EDIT_ONLY_LEAD")) end
        return false
    end
    if not self:IsCurrentGroupLeader() then
        if not silent then self:Print(self:L("DF_NOT_GROUP_LEAD")) end
        return false
    end
    return true
end

function GMG:SerializeDungeonPending(activity)
    local parts = {}
    for name, role in pairs(activity and activity.pending or {}) do
        parts[#parts + 1] = V171Escape(name) .. "~" .. V171Escape(role)
    end
    sort(parts)
    return table.concat(parts, ";")
end

function GMG:DeserializeDungeonPending(value)
    local pending = {}
    for entry in string.gmatch(value or "", "[^;]+") do
        local separator = string.find(entry, "~", 1, true)
        if separator then
            local name = self:NormalizeName(V171Unescape(string.sub(entry, 1, separator - 1)))
            local role = V171Unescape(string.sub(entry, separator + 1))
            if name ~= "" and role ~= "" then pending[name] = role end
        end
    end
    return pending
end

function GMG:GetDungeonAcceptedOutsideGroup(activity)
    local groupSet = self:GetActualGroupMemberSet()
    local count = 0
    for name, role in pairs(activity and activity.members or {}) do
        if role and not groupSet[strlower(self:NormalizeName(name))] then count = count + 1 end
    end
    return count
end

function GMG:RefreshDungeonOccupancy(activity)
    if not activity then return 1, 1 end
    if self:NormalizeName(activity.owner) == self:GetPlayerName() then
        local groupCount = self:GetActualGroupSize()
        local reserved = self:GetDungeonAcceptedOutsideGroup(activity)
        activity.groupCount = groupCount
        activity.currentCount = groupCount + reserved
    else
        activity.groupCount = max(1, tonumber(activity.groupCount) or 1)
        activity.currentCount = max(activity.groupCount, tonumber(activity.currentCount) or activity.groupCount)
    end
    return activity.currentCount, activity.groupCount
end

function GMG:GetDungeonActivityOccupancy(activity)
    if not activity then return 1 end
    if self:NormalizeName(activity.owner) == self:GetPlayerName() then self:RefreshDungeonOccupancy(activity) end
    return max(1, tonumber(activity.currentCount) or tonumber(activity.groupCount) or 1)
end

function GMG:GetDungeonActivityAvailable(activity)
    if not activity then return 0 end
    return max(0, (tonumber(activity.slots) or 1) - self:GetDungeonActivityOccupancy(activity))
end

function GMG:RemoveDungeonAnnouncement(id, createTombstone)
    if not id or id == "" then return end
    local store = self:GetGuildStore(createTombstone and true or false)
    if not store then return end
    if createTombstone then
        store.closedDungeonActivities = store.closedDungeonActivities or {}
        store.closedDungeonActivities[id] = time() + 14400
    end
    local messageID = "df-" .. id
    local index = 1
    while store.messages and index <= #store.messages do
        if store.messages[index].id == messageID then
            table.remove(store.messages, index)
        else
            index = index + 1
        end
    end
    self.chatDirty = true
    self.guildPageDirty = true
    if self.OnHistoryChanged then self:OnHistoryChanged() end
end

function GMG:UpsertDungeonAnnouncement(activity)
    if not activity or not activity.id then return end
    local store = self:GetGuildStore(true)
    if store.closedDungeonActivities then store.closedDungeonActivities[activity.id] = nil end
    self:RemoveDungeonAnnouncement(activity.id, false)
    local available = self:GetDungeonActivityAvailable(activity)
    local text = self:L("DF_ANNOUNCEMENT", activity.title or "", V171CategoryLabel(self, activity.category), activity.minLevel or 1, activity.maxLevel or 255, available)
    text = "|Hgmgactivity:" .. activity.id .. "|h|cff39ff14" .. text .. "|r|h"
    self:AddHistoryMessage(activity.owner, text, activity.createdAt or time(), "activity", "df-" .. activity.id)
end

local GMGAddHistoryMessageBeforeV171 = GMG.AddHistoryMessage
function GMG:AddHistoryMessage(sender, text, timestamp, source, suppliedID)
    if suppliedID and string.sub(suppliedID, 1, 3) == "df-" then
        local activityID = string.sub(suppliedID, 4)
        local store = self:GetGuildStore(false)
        local expires = store and store.closedDungeonActivities and tonumber(store.closedDungeonActivities[activityID]) or 0
        if expires > time() then return false end
    end
    return GMGAddHistoryMessageBeforeV171(self, sender, text, timestamp, source, suppliedID)
end

function GMG:BuildDungeonActivityPayload(activity)
    self:RefreshDungeonOccupancy(activity)
    return table.concat({
        "DA",
        self:GetGuildHash() or "",
        V171Escape(activity.id),
        tostring(activity.revision or 1),
        tostring(activity.createdAt or time()),
        tostring(activity.updatedAt or time()),
        tostring(activity.expiresAt or (time() + 14400)),
        V171Escape(activity.owner or ""),
        V171Escape(activity.title or ""),
        activity.category == "PVP" and "PVP" or "PVE",
        tostring(activity.minLevel or 1),
        tostring(activity.maxLevel or 255),
        tostring(activity.slots or 1),
        V171Escape(activity.roles or "dps"),
        V171Escape(self:SerializeDungeonMembers(activity)),
        activity.approvalMode == "manual" and "manual" or "auto",
        activity.autoInvite == false and "0" or "1",
        V171Escape(self:SerializeDungeonPending(activity)),
        tostring(activity.currentCount or 1),
        tostring(activity.groupCount or 1),
    }, "|")
end

local GMGStoreDungeonActivityBeforeV171 = GMG.StoreDungeonActivity
function GMG:StoreDungeonActivity(activity, announce)
    if not activity then return false end
    activity.members = activity.members or {}
    activity.pending = activity.pending or {}
    activity.approvalMode = activity.approvalMode == "manual" and "manual" or "auto"
    activity.autoInvite = activity.autoInvite ~= false
    activity.groupCount = max(1, tonumber(activity.groupCount) or 1)
    activity.currentCount = max(activity.groupCount, tonumber(activity.currentCount) or activity.groupCount)
    local stored = GMGStoreDungeonActivityBeforeV171(self, activity, false)
    if stored then
        local me = self:GetPlayerName()
        if activity.members and activity.members[me] and self:NormalizeName(activity.owner) ~= me then
            self.dungeonInviteAuthorizations = self.dungeonInviteAuthorizations or {}
            self.dungeonInviteAuthorizations[strlower(self:NormalizeName(activity.owner))] = time() + 180
        end
        self:UpsertDungeonAnnouncement(activity)
    end
    return stored
end

local GMGRemoveDungeonActivityBeforeV171 = GMG.RemoveDungeonActivity
function GMG:RemoveDungeonActivity(id, reason, silent)
    local activity = self:GetDungeonActivity(id)
    local revision = activity and (tonumber(activity.revision) or 0) or 0
    local removed = GMGRemoveDungeonActivityBeforeV171(self, id, reason, silent)
    local store = self:GetGuildStore(true)
    store.closedDungeonActivityRevisions = store.closedDungeonActivityRevisions or {}
    store.closedDungeonActivityRevisions[id] = max(tonumber(store.closedDungeonActivityRevisions[id]) or 0, revision)
    self:RemoveDungeonAnnouncement(id, true)
    if self.dungeonApplicantPopup and self.dungeonApplicantPopup:IsShown() then self:RefreshDungeonApplicantPopup() end
    return removed
end

function GMG:CreateDungeonActivity(title, category, minLevel, maxLevel, slots, roles, approvalMode, autoInvite)
    if not self:IsInGuild() then self:Print(self:L("NOT_IN_GUILD")); return false end
    title = self:Trim(title or "")
    if title == "" then self:Print(self:L("DF_NAME_REQUIRED")); return false end
    minLevel = V171Clamp(minLevel, 1, 255, 1)
    maxLevel = V171Clamp(maxLevel, 1, 255, 255)
    if maxLevel < minLevel then self:Print(self:L("DF_INVALID_RANGE")); return false end
    slots = V171Clamp(slots, 1, 40, 5)
    local actualGroup = self:GetActualGroupSize()
    if slots < actualGroup then self:Print(self:L("DF_TARGET_TOO_SMALL", actualGroup)); return false end
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
        pending = {},
        approvalMode = approvalMode == "manual" and "manual" or "auto",
        autoInvite = autoInvite ~= false,
        groupCount = actualGroup,
        currentCount = actualGroup,
    }
    self:StoreDungeonActivity(activity, true)
    self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
    self:SendQueuedPackets(8)
    self.dungeonSelectedID = id
    self:Print(self:L("DF_ACTIVITY_CREATED"))
    return true
end

function GMG:UpdateDungeonActivity(activity, title, category, minLevel, maxLevel, slots, roles, approvalMode, autoInvite)
    if not self:CanManageDungeonActivity(activity, false) then return false end
    title = self:Trim(title or "")
    if title == "" then self:Print(self:L("DF_NAME_REQUIRED")); return false end
    minLevel = V171Clamp(minLevel, 1, 255, 1)
    maxLevel = V171Clamp(maxLevel, 1, 255, 255)
    if maxLevel < minLevel then self:Print(self:L("DF_INVALID_RANGE")); return false end
    roles = roles or ""
    if roles == "" then self:Print(self:L("DF_ROLE_MISSING")); return false end
    self:RefreshDungeonOccupancy(activity)
    slots = V171Clamp(slots, 1, 40, activity.slots or 5)
    if slots < self:GetDungeonActivityOccupancy(activity) then
        self:Print(self:L("DF_TARGET_TOO_SMALL", self:GetDungeonActivityOccupancy(activity)))
        return false
    end
    activity.title = string.sub(title, 1, 60)
    activity.category = category == "PVP" and "PVP" or "PVE"
    activity.minLevel = minLevel
    activity.maxLevel = maxLevel
    activity.slots = slots
    activity.roles = roles
    activity.approvalMode = approvalMode == "manual" and "manual" or "auto"
    activity.autoInvite = autoInvite ~= false
    activity.revision = (tonumber(activity.revision) or 1) + 1
    activity.updatedAt = time()
    activity.expiresAt = time() + 14400
    self:StoreDungeonActivity(activity, false)
    self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
    self:SendQueuedPackets(8)
    if activity.approvalMode == "auto" then
        local queued = {}
        for player, role in pairs(activity.pending or {}) do queued[#queued + 1] = {player = player, role = role} end
        sort(queued, function(a, b) return strlower(a.player or "") < strlower(b.player or "") end)
        for _, request in ipairs(queued) do
            if self:GetDungeonActivityAvailable(activity) <= 0 then break end
            self:AcceptDungeonApplicant(activity, request.player, request.role)
        end
    end
    if activity.autoInvite ~= false and self:GetDungeonActivity(activity.id) then self:AutoInviteDungeonMembers(activity) end
    return true
end

function GMG:InviteDungeonMember(activity, player, retry, ignoreCooldown)
    if not activity or not player or player == "" then return false end
    if not self:CanManageDungeonActivity(activity, true) then return false end
    local groupSet = self:GetActualGroupMemberSet()
    local key = strlower(self:NormalizeName(player))
    if groupSet[key] then return false end
    self.dungeonInviteCooldowns = self.dungeonInviteCooldowns or {}
    local cooldownKey = tostring(activity.id or "") .. ":" .. key
    if not ignoreCooldown and (tonumber(self.dungeonInviteCooldowns[cooldownKey]) or 0) > GetTime() then return false end
    if InviteUnit then
        InviteUnit(player)
        self.dungeonInviteCooldowns[cooldownKey] = GetTime() + 15
        self:Print(self:L(retry and "DF_INVITE_RETRY" or "DF_AUTO_INVITE", player))
        return true
    end
    return false
end

function GMG:InviteAllDungeonMembers(activity)
    if not self:CanManageDungeonActivity(activity, false) then return end
    local groupSet = self:GetActualGroupMemberSet()
    for player, role in pairs(activity.members or {}) do
        if role and not groupSet[strlower(self:NormalizeName(player))] then self:InviteDungeonMember(activity, player, true, true) end
    end
end

function GMG:AutoInviteDungeonMembers(activity)
    if not activity or activity.autoInvite == false or not self:CanManageDungeonActivity(activity, true) then return end
    local groupSet = self:GetActualGroupMemberSet()
    for player, role in pairs(activity.members or {}) do
        if role and not groupSet[strlower(self:NormalizeName(player))] then self:InviteDungeonMember(activity, player, false, false) end
    end
end

function GMG:AcceptDungeonApplicant(activity, player, role)
    if not self:CanManageDungeonActivity(activity, false) then return false end
    player = self:NormalizeName(player)
    if player == "" or not V171HasRole(activity, role) then return false end
    if self:GetDungeonActivityAvailable(activity) <= 0 then self:Print(self:L("DF_NO_PLACE")); return false end
    activity.pending = activity.pending or {}
    activity.members = activity.members or {}
    activity.pending[player] = nil
    activity.members[player] = role
    activity.revision = (tonumber(activity.revision) or 1) + 1
    activity.updatedAt = time()
    activity.expiresAt = time() + 14400
    self:RefreshDungeonOccupancy(activity)
    self:StoreDungeonActivity(activity, false)
    self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
    self:Print(self:L("DF_REQUEST_ACCEPTED", player, V171RoleLabel(self, role)))
    if activity.autoInvite ~= false then self:InviteDungeonMember(activity, player, false) end
    self:CheckOwnedDungeonActivityCapacity(activity)
    return true
end

function GMG:RejectDungeonApplicant(activity, player)
    if not self:CanManageDungeonActivity(activity, false) then return false end
    player = self:NormalizeName(player)
    if not activity.pending or not activity.pending[player] then return false end
    activity.pending[player] = nil
    activity.revision = (tonumber(activity.revision) or 1) + 1
    activity.updatedAt = time()
    activity.expiresAt = time() + 14400
    self:StoreDungeonActivity(activity, false)
    self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
    self:Print(self:L("DF_REQUEST_REJECTED", player))
    return true
end

function GMG:RequestDungeonJoin(activity, role, leave)
    if not activity then self:Print(self:L("DF_ACTIVITY_GONE")); return end
    local player = self:GetPlayerName()
    local level = UnitLevel and UnitLevel("player") or 1
    local isMember = activity.members and activity.members[player] ~= nil
    local isPending = activity.pending and activity.pending[player] ~= nil
    if not leave and (level < (activity.minLevel or 1) or level > (activity.maxLevel or 255)) then
        self:Print(self:L("DF_LEVEL_TOO_LOW", activity.minLevel or 1, activity.maxLevel or 255, level))
        return
    end
    if not leave and not V171HasRole(activity, role) then self:Print(self:L("DF_ROLE_REQUIRED")); return end
    if not leave and isPending then self:Print(self:L("DF_ALREADY_PENDING")); return end
    if not leave and self:GetDungeonActivityAvailable(activity) <= 0 then self:Print(self:L("DF_NO_PLACE")); return end
    local action = leave and (isPending and "cancel" or "leave") or "join"
    self:QueuePacket(table.concat({
        "DJ", self:GetGuildHash() or "", V171Escape(activity.id), V171Escape(player), V171Escape(role or ""), action
    }, "|"), "GUILD", nil, true)
    self:SendQueuedPackets(4)
    if self:NormalizeName(activity.owner) == self:GetPlayerName() then
        self:ApplyDungeonJoinRequest(activity.id, player, role, action, player)
    elseif action == "join" then
        self:Print(self:L("DF_REQUEST_SENT"))
    end
end

function GMG:ApplyDungeonJoinRequest(id, player, role, action, sender)
    local activity = self:GetDungeonActivity(id)
    if not activity or not self:CanManageDungeonActivity(activity, true) then return end
    player = self:NormalizeName(player)
    sender = self:NormalizeName(sender)
    if player == "" or sender ~= player or not self:IsGuildMemberName(player) then return end
    activity.members = activity.members or {}
    activity.pending = activity.pending or {}

    if action == "leave" or action == "cancel" then
        local changed = false
        if activity.members[player] then activity.members[player] = nil; changed = true end
        if activity.pending[player] then activity.pending[player] = nil; changed = true end
        if changed then
            activity.revision = (tonumber(activity.revision) or 1) + 1
            activity.updatedAt = time()
            activity.expiresAt = time() + 14400
            self:RefreshDungeonOccupancy(activity)
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
    if not V171HasRole(activity, role) then return end
    if activity.members[player] or activity.pending[player] then return end
    if self:GetDungeonActivityAvailable(activity) <= 0 then return end

    if activity.approvalMode == "manual" then
        activity.pending[player] = role
        activity.revision = (tonumber(activity.revision) or 1) + 1
        activity.updatedAt = time()
        activity.expiresAt = time() + 14400
        self:StoreDungeonActivity(activity, false)
        self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
        if self.dungeonApplicantPopup and self.dungeonApplicantPopup:IsShown() then self:RefreshDungeonApplicantPopup() end
    else
        self:AcceptDungeonApplicant(activity, player, role)
    end
end

function GMG:CheckOwnedDungeonActivityCapacity(activity)
    if not activity or not self:CanManageDungeonActivity(activity, true) then return false end
    local previousCurrent = tonumber(activity.currentCount) or 0
    local previousGroup = tonumber(activity.groupCount) or 0
    self:RefreshDungeonOccupancy(activity)
    local current = self:GetDungeonActivityOccupancy(activity)
    local changed = current ~= previousCurrent or (tonumber(activity.groupCount) or 0) ~= previousGroup
    if current >= (tonumber(activity.slots) or 1) then
        activity.revision = (tonumber(activity.revision) or 1) + 1
        self:BroadcastDungeonClose(activity, "full")
        self:RemoveDungeonActivity(activity.id, "full", true)
        self:Print(self:L("DF_FULL_REAL_GROUP", current))
        return true
    end
    if changed then
        activity.revision = (tonumber(activity.revision) or 1) + 1
        activity.updatedAt = time()
        activity.expiresAt = time() + 14400
        self:StoreDungeonActivity(activity, false)
        self:BroadcastDungeonActivity(activity, "GUILD", nil, false)
    end
    return false
end

function GMG:UpdateOwnedDungeonGroupState()
    for _, activity in ipairs(self:GetDungeonActivities()) do
        if self:NormalizeName(activity.owner) == self:GetPlayerName() then
            self:AutoInviteDungeonMembers(activity)
            self:CheckOwnedDungeonActivityCapacity(activity)
        end
    end
end

function GMG:CloseDungeonActivity(activity)
    if not activity then return end
    if not self:CanManageDungeonActivity(activity, false) then return end
    activity.revision = (tonumber(activity.revision) or 1) + 1
    self:BroadcastDungeonClose(activity, "closed")
    self:RemoveDungeonActivity(activity.id, "closed", true)
    self:Print(self:L("DF_ACTIVITY_CLOSED"))
end

function GMG:ShouldAutoAcceptDungeonInvite(inviter)
    inviter = self:NormalizeName(inviter)
    local inviterKey = strlower(inviter or "")
    local me = self:GetPlayerName()
    for _, activity in ipairs(self:GetDungeonActivities()) do
        if self:NormalizeName(activity.owner) == inviter and activity.members and activity.members[me] then return true end
    end
    local expires = self.dungeonInviteAuthorizations and tonumber(self.dungeonInviteAuthorizations[inviterKey]) or 0
    if expires > time() then return true end
    return false
end

function GMG:PARTY_INVITE_REQUEST(inviter)
    inviter = self:NormalizeName(inviter)
    if inviter == "" or not self:ShouldAutoAcceptDungeonInvite(inviter) then return end
    if AcceptGroup then AcceptGroup() end
    if StaticPopup_Hide then StaticPopup_Hide("PARTY_INVITE") end
    self:Print(self:L("DF_AUTO_GROUP_ACCEPT", inviter))
end

function GMG:PARTY_MEMBERS_CHANGED()
    self:UpdateOwnedDungeonGroupState()
end

function GMG:RAID_ROSTER_UPDATE()
    self:UpdateOwnedDungeonGroupState()
end

function GMG:PARTY_LEADER_CHANGED()
    self:UpdateOwnedDungeonGroupState()
end

function GMG:EnhanceDungeonCreatePopupV171()
    local frame = self.dungeonCreatePopup
    if not frame or frame.v171Enhanced then return end
    frame.v171Enhanced = true
    frame:SetHeight(650)

    frame.approvalLabel = VText(frame, "GameFontNormal", self:L("DF_APPROVAL_MODE"), 12)
    frame.approvalLabel:SetPoint("TOPLEFT", 24, -388)
    frame.approvalAuto = VButton(frame, self:L("DF_APPROVAL_AUTO"), 245, 30)
    frame.approvalAuto:SetPoint("TOPLEFT", 24, -414)
    frame.approvalManual = VButton(frame, self:L("DF_APPROVAL_MANUAL"), 245, 30)
    frame.approvalManual:SetPoint("TOPRIGHT", -24, -414)
    frame.approvalMode = "auto"
    frame.approvalAuto:SetScript("OnClick", function() frame.approvalMode = "auto"; VSelect(frame.approvalAuto, true); VSelect(frame.approvalManual, false) end)
    frame.approvalManual:SetScript("OnClick", function() frame.approvalMode = "manual"; VSelect(frame.approvalAuto, false); VSelect(frame.approvalManual, true) end)

    frame.autoInvite = VCheck(frame, self:L("DF_AUTO_INVITE_SETTING"), 360)
    frame.autoInvite:SetPoint("TOPLEFT", 24, -458)
    frame.autoInvite:SetChecked(true)

    frame.create:SetScript("OnClick", function()
        local selected = {}
        for _, check in ipairs(frame.roleChecks) do if check:GetChecked() then selected[#selected + 1] = check.role end end
        local success
        if frame.editActivityID then
            success = GMG:UpdateDungeonActivity(GMG:GetDungeonActivity(frame.editActivityID), frame.name:GetText(), frame.category,
                frame.minLevel:GetText(), frame.maxLevel:GetText(), frame.slots:GetText(), table.concat(selected, ","),
                frame.approvalMode, frame.autoInvite:GetChecked())
        else
            success = GMG:CreateDungeonActivity(frame.name:GetText(), frame.category, frame.minLevel:GetText(), frame.maxLevel:GetText(),
                frame.slots:GetText(), table.concat(selected, ","), frame.approvalMode, frame.autoInvite:GetChecked())
        end
        if success then frame:Hide(); GMG:ShowTab("dungeon"); GMG:RefreshDungeonFinder(true) end
    end)
end

local GMGCreateDungeonCreatePopupBeforeV171 = GMG.CreateDungeonCreatePopup
function GMG:CreateDungeonCreatePopup()
    GMGCreateDungeonCreatePopupBeforeV171(self)
    self:EnhanceDungeonCreatePopupV171()
end

function GMG:OpenDungeonCreatePopup()
    self:CreateDungeonCreatePopup()
    local frame = self.dungeonCreatePopup
    frame.editActivityID = nil
    frame.title:SetText(self:L("DF_CREATE"))
    frame.create.label:SetText(self:L("DF_CREATE_CONFIRM"))
    frame.name:SetText("")
    frame.minLevel:SetText(tostring(UnitLevel and UnitLevel("player") or 1))
    frame.maxLevel:SetText(tostring(UnitLevel and UnitLevel("player") or 1))
    frame.slots:SetText(tostring(max(5, self:GetActualGroupSize())))
    frame.category = "PVE"
    VSelect(frame.pve, true)
    VSelect(frame.pvp, false)
    for _, check in ipairs(frame.roleChecks) do check:SetChecked(true) end
    frame.approvalMode = "auto"
    VSelect(frame.approvalAuto, true)
    VSelect(frame.approvalManual, false)
    frame.autoInvite:SetChecked(true)
    frame:Show()
    frame.name:SetFocus()
end

function GMG:OpenDungeonEditPopup(activity)
    if not self:CanManageDungeonActivity(activity, false) then return end
    self:CreateDungeonCreatePopup()
    local frame = self.dungeonCreatePopup
    frame.editActivityID = activity.id
    frame.title:SetText(self:L("DF_EDIT_TITLE"))
    frame.create.label:SetText(self:L("DF_SAVE"))
    frame.name:SetText(activity.title or "")
    frame.minLevel:SetText(tostring(activity.minLevel or 1))
    frame.maxLevel:SetText(tostring(activity.maxLevel or 255))
    frame.slots:SetText(tostring(activity.slots or 5))
    frame.category = activity.category == "PVP" and "PVP" or "PVE"
    VSelect(frame.pve, frame.category == "PVE")
    VSelect(frame.pvp, frame.category == "PVP")
    for _, check in ipairs(frame.roleChecks) do check:SetChecked(V171HasRole(activity, check.role)) end
    frame.approvalMode = activity.approvalMode == "manual" and "manual" or "auto"
    VSelect(frame.approvalAuto, frame.approvalMode == "auto")
    VSelect(frame.approvalManual, frame.approvalMode == "manual")
    frame.autoInvite:SetChecked(activity.autoInvite ~= false)
    frame:Show()
end

function GMG:CreateDungeonApplicantPopup()
    if self.dungeonApplicantPopup then return end
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(620)
    frame:SetHeight(510)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    VBackdrop(frame, V171_BG, V171_ACCENT)
    frame:Hide()
    self.dungeonApplicantPopup = frame

    frame.title = VText(frame, "GameFontNormalLarge", self:L("DF_APPLICANTS_TITLE"), 18)
    frame.title:SetPoint("TOPLEFT", 20, -18)
    frame.empty = VText(frame, "GameFontNormal", self:L("DF_NO_APPLICANTS"), 12)
    frame.empty:SetPoint("CENTER", 0, 0)
    frame.empty:SetTextColor(unpack(V171_MUTED))
    frame.rows = {}
    for index = 1, 8 do
        local row = CreateFrame("Frame", nil, frame)
        row:SetHeight(42)
        row:SetPoint("TOPLEFT", 20, -58 - (index - 1) * 48)
        row:SetPoint("TOPRIGHT", -20, -58 - (index - 1) * 48)
        VBackdrop(row, V171_PANEL_2, V171_BORDER)
        row.name = VText(row, "GameFontNormal", "", 12)
        row.name:SetPoint("LEFT", 10, 0)
        row.name:SetPoint("RIGHT", -230, 0)
        row.name:SetJustifyH("LEFT")
        row.accept = VButton(row, self:L("DF_ACCEPT"), 96, 26)
        row.accept:SetPoint("RIGHT", -112, 0)
        row.accept:SetScript("OnClick", function(button)
            local activity = GMG:GetDungeonActivity(frame.activityID)
            if activity and button.playerName then GMG:AcceptDungeonApplicant(activity, button.playerName, button.role); GMG:RefreshDungeonApplicantPopup() end
        end)
        row.reject = VButton(row, self:L("DF_REJECT"), 96, 26)
        row.reject:SetPoint("RIGHT", -8, 0)
        row.reject:SetScript("OnClick", function(button)
            local activity = GMG:GetDungeonActivity(frame.activityID)
            if activity and button.playerName then GMG:RejectDungeonApplicant(activity, button.playerName); GMG:RefreshDungeonApplicantPopup() end
        end)
        row:Hide()
        frame.rows[index] = row
    end
    frame.page = 1
    frame.prev = VButton(frame, "<", 36, 28)
    frame.prev:SetPoint("BOTTOMLEFT", 20, 18)
    frame.prev:SetScript("OnClick", function() frame.page = max(1, (frame.page or 1) - 1); GMG:RefreshDungeonApplicantPopup() end)
    frame.pageLabel = VText(frame, "GameFontNormalSmall", "1 / 1", 10)
    frame.pageLabel:SetWidth(76)
    frame.pageLabel:SetPoint("LEFT", frame.prev, "RIGHT", 6, 0)
    frame.pageLabel:SetJustifyH("CENTER")
    frame.next = VButton(frame, ">", 36, 28)
    frame.next:SetPoint("LEFT", frame.pageLabel, "RIGHT", 6, 0)
    frame.next:SetScript("OnClick", function() frame.page = (frame.page or 1) + 1; GMG:RefreshDungeonApplicantPopup() end)
    frame.close = VButton(frame, self:L("DF_CANCEL"), 130, 32)
    frame.close:SetPoint("BOTTOMRIGHT", -20, 18)
    frame.close:SetScript("OnClick", function() frame:Hide() end)
end

function GMG:RefreshDungeonApplicantPopup()
    local frame = self.dungeonApplicantPopup
    if not frame then return end
    local activity = self:GetDungeonActivity(frame.activityID)
    if not activity or not self:CanManageDungeonActivity(activity, true) then frame:Hide(); return end
    local applicants = {}
    for name, role in pairs(activity.pending or {}) do applicants[#applicants + 1] = {name = name, role = role} end
    sort(applicants, function(a, b) return strlower(a.name or "") < strlower(b.name or "") end)
    local perPage = #frame.rows
    local maxPage = max(1, math.ceil(#applicants / perPage))
    frame.page = max(1, min(maxPage, tonumber(frame.page) or 1))
    local offset = (frame.page - 1) * perPage
    if #applicants == 0 then frame.empty:Show() else frame.empty:Hide() end
    for index, row in ipairs(frame.rows) do
        local applicant = applicants[offset + index]
        if applicant then
            row.name:SetText(applicant.name .. " — " .. V171RoleLabel(self, applicant.role))
            row.accept.playerName = applicant.name
            row.accept.role = applicant.role
            row.reject.playerName = applicant.name
            row:Show()
        else
            row.accept.playerName = nil
            row.reject.playerName = nil
            row:Hide()
        end
    end
    if frame.pageLabel then frame.pageLabel:SetText(frame.page .. " / " .. maxPage) end
    if frame.prev then if frame.page > 1 then frame.prev:Enable() else frame.prev:Disable() end end
    if frame.next then if frame.page < maxPage then frame.next:Enable() else frame.next:Disable() end end
end

function GMG:OpenDungeonApplicantPopup(activity)
    if not self:CanManageDungeonActivity(activity, false) then return end
    self:CreateDungeonApplicantPopup()
    self.dungeonApplicantPopup.activityID = activity.id
    self.dungeonApplicantPopup.page = 1
    self.dungeonApplicantPopup:Show()
    self:RefreshDungeonApplicantPopup()
end

function GMG:InstallDungeonLeadControls()
    local page = self.dungeonPage
    if not page or page.v171LeadControls then return end
    page.v171LeadControls = true
    page.edit = VButton(page.detail, self:L("DF_EDIT"), 72, 30)
    page.edit:SetPoint("BOTTOMLEFT", 18, 20)
    page.edit:SetScript("OnClick", function() GMG:OpenDungeonEditPopup(GMG:GetDungeonActivity(GMG.dungeonSelectedID)) end)
    page.applicants = VButton(page.detail, self:L("DF_APPLICANTS", 0), 96, 30)
    page.applicants:SetPoint("LEFT", page.edit, "RIGHT", 6, 0)
    page.applicants:SetScript("OnClick", function() GMG:OpenDungeonApplicantPopup(GMG:GetDungeonActivity(GMG.dungeonSelectedID)) end)
    page.inviteAll = VButton(page.detail, self:L("DF_INVITE_ALL"), 104, 30)
    page.inviteAll:SetPoint("LEFT", page.applicants, "RIGHT", 6, 0)
    page.inviteAll:SetScript("OnClick", function() GMG:InviteAllDungeonMembers(GMG:GetDungeonActivity(GMG.dungeonSelectedID)) end)
    page.capacity = VText(page.detail, "GameFontNormal", "", 11)
    page.capacity:SetPoint("TOPLEFT", 18, -118)
    page.capacity:SetPoint("TOPRIGHT", -18, -118)
    page.capacity:SetTextColor(unpack(V171_GREEN))
end

local GMGCreateDungeonFinderPageBeforeV171 = GMG.CreateDungeonFinderPage
function GMG:CreateDungeonFinderPage()
    GMGCreateDungeonFinderPageBeforeV171(self)
    self:InstallDungeonLeadControls()
end

local GMGRefreshDungeonFinderBeforeV171 = GMG.RefreshDungeonFinder
function GMG:RefreshDungeonFinder(force)
    GMGRefreshDungeonFinderBeforeV171(self, force)
    local page = self.dungeonPage
    if not page then return end
    self:InstallDungeonLeadControls()
    local activities = self:GetDungeonActivities()
    for index, row in ipairs(page.rows or {}) do
        local activity = activities[index]
        if activity and row:IsShown() then
            local occupancy = self:GetDungeonActivityOccupancy(activity)
            local available = self:GetDungeonActivityAvailable(activity)
            row.meta:SetText(self:L("DF_REQUIRED_LEVEL", activity.minLevel or 1, activity.maxLevel or 255)
                .. "  •  " .. occupancy .. "/" .. (activity.slots or 1) .. "  •  " .. self:L("DF_AVAILABLE_SHORT", available))
        end
    end

    local activity = self:GetDungeonActivity(self.dungeonSelectedID)
    if not activity then
        if page.edit then page.edit:Hide() end
        if page.applicants then page.applicants:Hide() end
        if page.inviteAll then page.inviteAll:Hide() end
        if page.capacity then page.capacity:SetText("") end
        return
    end

    local occupancy = self:GetDungeonActivityOccupancy(activity)
    local available = self:GetDungeonActivityAvailable(activity)
    page.capacity:SetText(self:L("DF_GROUP_SIZE", occupancy, activity.slots or 1, available))
    local me = self:GetPlayerName()
    page.levelWarning:SetTextColor(unpack(V171_RED))
    local owner = self:NormalizeName(activity.owner) == me
    local canManage = owner and self:IsCurrentGroupLeader()
    local pendingCount = 0
    for _ in pairs(activity.pending or {}) do pendingCount = pendingCount + 1 end

    if owner then
        page.join:Hide()
        page.edit:Show()
        page.applicants:Show()
        page.inviteAll:Show()
        page.close:Show()
        page.close:ClearAllPoints()
        page.close:SetWidth(84)
        page.close:SetPoint("BOTTOMRIGHT", -18, 20)
        if canManage then
            page.edit:Enable()
            page.applicants:Enable()
            page.inviteAll:Enable()
            page.close:Enable()
        else
            page.edit:Disable()
            page.applicants:Disable()
            page.inviteAll:Disable()
            page.close:Disable()
        end
        VBoundedText(page.applicants.label, self:L("DF_APPLICANTS", pendingCount), 84)
    else
        page.join:Show()
        page.edit:Hide()
        page.applicants:Hide()
        page.inviteAll:Hide()
        page.close:Hide()
        local isMember = activity.members and activity.members[me] ~= nil
        local isPending = activity.pending and activity.pending[me] ~= nil
        if isPending then
            page.join:Enable()
            page.join.label:SetText(self:L("DF_CANCEL_REQUEST"))
            page.levelWarning:SetText(self:L("DF_PENDING"))
            page.levelWarning:SetTextColor(unpack(V171_GREEN))
        elseif isMember then
            page.join:Enable()
            page.join.label:SetText(self:L("DF_LEAVE"))
            page.levelWarning:SetText("")
        elseif available <= 0 then
            page.join:Disable()
            page.join.label:SetText(self:L("DF_JOIN"))
            page.levelWarning:SetText(self:L("DF_NO_PLACE"))
            page.levelWarning:SetTextColor(unpack(V171_RED))
        end
    end

    local modeLabel = activity.approvalMode == "manual" and self:L("DF_MANUAL") or self:L("DF_AUTOMATIC")
    page.detailInfo:SetText(V171CategoryLabel(self, activity.category) .. "\n"
        .. self:L("DF_REQUIRED_LEVEL", activity.minLevel or 1, activity.maxLevel or 255) .. "\n"
        .. self:L("DF_OWNER", activity.owner or "") .. " — " .. modeLabel .. "\n"
        .. self:L("DF_ROLES") .. ": " .. table.concat((function()
            local labels = {}
            for _, role in ipairs(V171RoleList(activity)) do labels[#labels + 1] = V171RoleLabel(self, role) end
            return labels
        end)(), ", "))
end

local GMGHandleCompletePayloadBeforeV171 = GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload, channel, sender)
    local values = V171Split(payload)
    local command = values[1]
    if command ~= "DA" and command ~= "DJ" and command ~= "DC" and command ~= "DR" then
        return GMGHandleCompletePayloadBeforeV171(self, payload, channel, sender)
    end
    if values[2] ~= self:GetGuildHash() then return end
    sender = self:NormalizeName(sender)
    if sender == self:GetPlayerName() or not self:IsGuildMemberName(sender) then return end

    if command == "DA" then
        local owner = self:NormalizeName(V171Unescape(values[8]))
        if owner ~= sender then return end
        local incomingID = V171Unescape(values[3])
        local incomingRevision = tonumber(values[4]) or 1
        local guildStore = self:GetGuildStore(false)
        local closedRevision = guildStore and guildStore.closedDungeonActivityRevisions and tonumber(guildStore.closedDungeonActivityRevisions[incomingID]) or 0
        if closedRevision >= incomingRevision then return end
        local activity = {
            id = incomingID,
            revision = incomingRevision,
            createdAt = tonumber(values[5]) or time(),
            updatedAt = tonumber(values[6]) or time(),
            expiresAt = tonumber(values[7]) or (time() + 14400),
            owner = owner,
            title = V171Unescape(values[9]),
            category = values[10] == "PVP" and "PVP" or "PVE",
            minLevel = V171Clamp(values[11], 1, 255, 1),
            maxLevel = V171Clamp(values[12], 1, 255, 255),
            slots = V171Clamp(values[13], 1, 40, 5),
            roles = V171Unescape(values[14]),
            members = self:DeserializeDungeonMembers(V171Unescape(values[15])),
            approvalMode = values[16] == "manual" and "manual" or "auto",
            autoInvite = values[17] ~= "0",
            pending = self:DeserializeDungeonPending(V171Unescape(values[18] or "")),
            currentCount = max(1, tonumber(values[19]) or 1),
            groupCount = max(1, tonumber(values[20]) or 1),
        }
        self:StoreDungeonActivity(activity, true)
    elseif command == "DJ" then
        self:ApplyDungeonJoinRequest(V171Unescape(values[3]), self:NormalizeName(V171Unescape(values[4])), V171Unescape(values[5]), values[6], sender)
    elseif command == "DC" then
        local id = V171Unescape(values[3])
        local owner = self:NormalizeName(V171Unescape(values[5]))
        local reason = V171Unescape(values[6])
        local closeRevision = tonumber(values[4]) or 0
        local existing = self:GetDungeonActivity(id)
        if owner == sender and existing and self:NormalizeName(existing.owner) == sender then
            local me = self:GetPlayerName()
            if existing.members and existing.members[me] then
                self.dungeonInviteAuthorizations = self.dungeonInviteAuthorizations or {}
                self.dungeonInviteAuthorizations[strlower(owner)] = time() + 180
            end
            self:RemoveDungeonActivity(id, reason, true)
            local guildStore = self:GetGuildStore(true)
            guildStore.closedDungeonActivityRevisions = guildStore.closedDungeonActivityRevisions or {}
            guildStore.closedDungeonActivityRevisions[id] = max(tonumber(guildStore.closedDungeonActivityRevisions[id]) or 0, closeRevision)
        end
    elseif command == "DR" then
        for _, activity in ipairs(self:GetDungeonActivities()) do
            if self:NormalizeName(activity.owner) == self:GetPlayerName() then self:BroadcastDungeonActivity(activity, "WHISPER", sender, false) end
        end
    end
end

local GMGOnUpdateBeforeV171 = GMG.OnUpdate
function GMG:OnUpdate(elapsed)
    GMGOnUpdateBeforeV171(self, elapsed)
    self.v171GroupPulse = (self.v171GroupPulse or 0) + elapsed
    if self.v171GroupPulse >= 1.0 then
        self.v171GroupPulse = self.v171GroupPulse - 1.0
        self:UpdateOwnedDungeonGroupState()
        if self.dungeonInviteAuthorizations then
            local now = time()
            for key, expires in pairs(self.dungeonInviteAuthorizations) do
                if (tonumber(expires) or 0) <= now then self.dungeonInviteAuthorizations[key] = nil end
            end
        end
    end
end

local GMGRefreshLocalizationBeforeV171 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV171(self, ...)
    local page = self.dungeonPage
    if page then
        if page.edit and page.edit.label then page.edit.label:SetText(self:L("DF_EDIT")) end
        if page.inviteAll and page.inviteAll.label then VBoundedText(page.inviteAll.label, self:L("DF_INVITE_ALL"), 92) end
    end
    local frame = self.dungeonCreatePopup
    if frame and frame.v171Enhanced then
        frame.approvalLabel:SetText(self:L("DF_APPROVAL_MODE"))
        frame.approvalAuto.label:SetText(self:L("DF_APPROVAL_AUTO"))
        frame.approvalManual.label:SetText(self:L("DF_APPROVAL_MANUAL"))
        frame.autoInvite.label:SetText(self:L("DF_AUTO_INVITE_SETTING"))
    end
    local applicants = self.dungeonApplicantPopup
    if applicants then
        applicants.title:SetText(self:L("DF_APPLICANTS_TITLE"))
        applicants.empty:SetText(self:L("DF_NO_APPLICANTS"))
        for _, row in ipairs(applicants.rows or {}) do
            row.accept.label:SetText(self:L("DF_ACCEPT"))
            row.reject.label:SetText(self:L("DF_REJECT"))
        end
    end
end

if GMG.eventFrame then
    GMG.eventFrame:RegisterEvent("PARTY_INVITE_REQUEST")
    GMG.eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    GMG.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    GMG.eventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
end

-- ============================================================================
-- v1.7.2: Ascension activity presets, level 1-60 limits and real group counting.
-- Accepted players are always invited; the redundant auto-invite checkbox is removed.
-- ============================================================================
local V172_ACTIVITY_TYPES = {
    PVE = {
        {id = "XP_DUNGEON", label = "DF_TYPE_XP_DUNGEON", minLevel = 15, maxLevel = 60, slots = 5},
        {id = "NORMAL_DUNGEON", label = "DF_TYPE_NORMAL_DUNGEON", minLevel = 15, maxLevel = 60, slots = 5},
        {id = "HEROIC_DUNGEON", label = "DF_TYPE_HEROIC_DUNGEON", minLevel = 60, maxLevel = 60, slots = 5, fixedLevel = true},
        {id = "MYTHIC_DUNGEON", label = "DF_TYPE_MYTHIC_DUNGEON", minLevel = 60, maxLevel = 60, slots = 5, fixedLevel = true},
        {id = "MYTHIC_PLUS", label = "DF_TYPE_MYTHIC_PLUS", minLevel = 60, maxLevel = 60, slots = 5, fixedLevel = true},
        {id = "RAID", label = "DF_TYPE_RAID", minLevel = 60, maxLevel = 60, slots = 10, fixedLevel = true},
        {id = "WORLD_BOSS", label = "DF_TYPE_WORLD_BOSS", minLevel = 1, maxLevel = 60, slots = 40},
        {id = "OTHER_PVE", label = "DF_TYPE_OTHER_PVE", minLevel = 1, maxLevel = 60, slots = 5},
    },
    PVP = {
        {id = "XP_BATTLEGROUND", label = "DF_TYPE_XP_BATTLEGROUND", minLevel = 10, maxLevel = 59, slots = 10},
        {id = "MAX_BATTLEGROUND", label = "DF_TYPE_MAX_BATTLEGROUND", minLevel = 60, maxLevel = 60, slots = 10, fixedLevel = true},
        {id = "ARENA", label = "DF_TYPE_ARENA", minLevel = 60, maxLevel = 60, slots = 2, fixedLevel = true},
        {id = "WORLD_PVP", label = "DF_TYPE_WORLD_PVP", minLevel = 1, maxLevel = 60, slots = 40},
        {id = "WARGAME", label = "DF_TYPE_WARGAME", minLevel = 10, maxLevel = 60, slots = 10},
        {id = "OTHER_PVP", label = "DF_TYPE_OTHER_PVP", minLevel = 1, maxLevel = 60, slots = 5},
    },
}

local V172_EN = {
    DF_ACTIVITY_SUBTYPE = "Activity",
    DF_TYPE_XP_DUNGEON = "XP Dungeon",
    DF_TYPE_NORMAL_DUNGEON = "Normal Dungeon",
    DF_TYPE_HEROIC_DUNGEON = "Heroic Dungeon",
    DF_TYPE_MYTHIC_DUNGEON = "Mythic Dungeon",
    DF_TYPE_MYTHIC_PLUS = "Mythic+ Dungeon",
    DF_TYPE_RAID = "Raid",
    DF_TYPE_WORLD_BOSS = "World Boss",
    DF_TYPE_OTHER_PVE = "Other PvE",
    DF_TYPE_XP_BATTLEGROUND = "XP Battleground",
    DF_TYPE_MAX_BATTLEGROUND = "Level 60 Battleground",
    DF_TYPE_ARENA = "Arena",
    DF_TYPE_WORLD_PVP = "World PvP",
    DF_TYPE_WARGAME = "Wargame",
    DF_TYPE_OTHER_PVP = "Other PvP",
    DF_IN_GROUP = "Already in group",
    DF_GROUP_MEMBERS_SUMMARY = "%d player(s) are already in the leader's group.",
    DF_APPROVAL_AUTO = "Automatic: accept valid roles",
    DF_APPROVAL_MANUAL = "Manual validation by the leader",
    DF_INVITE_ALL = "Resend invitations",
    DF_ANNOUNCEMENT_TYPED = "[Guild Finder] %s — %s — level %d-%d — %d place(s) — click to register",
}
local V172_FR = {
    DF_ACTIVITY_SUBTYPE = "Activité",
    DF_TYPE_XP_DUNGEON = "Donjon XP",
    DF_TYPE_NORMAL_DUNGEON = "Donjon normal",
    DF_TYPE_HEROIC_DUNGEON = "Donjon héroïque",
    DF_TYPE_MYTHIC_DUNGEON = "Donjon mythique",
    DF_TYPE_MYTHIC_PLUS = "Donjon Mythique+",
    DF_TYPE_RAID = "Raid",
    DF_TYPE_WORLD_BOSS = "Boss mondial",
    DF_TYPE_OTHER_PVE = "Autre activité JcE",
    DF_TYPE_XP_BATTLEGROUND = "Champ de bataille XP",
    DF_TYPE_MAX_BATTLEGROUND = "Champ de bataille niveau 60",
    DF_TYPE_ARENA = "Arène",
    DF_TYPE_WORLD_PVP = "JcJ sauvage",
    DF_TYPE_WARGAME = "Jeu de guerre",
    DF_TYPE_OTHER_PVP = "Autre activité JcJ",
    DF_IN_GROUP = "Déjà dans le groupe",
    DF_GROUP_MEMBERS_SUMMARY = "%d joueur(s) sont déjà dans le groupe du responsable.",
    DF_APPROVAL_AUTO = "Automatique : accepter les rôles valides",
    DF_APPROVAL_MANUAL = "Validation manuelle par le responsable",
    DF_INVITE_ALL = "Renvoyer les invitations",
    DF_ANNOUNCEMENT_TYPED = "[Dungeon Finder] %s — %s — niveaux %d-%d — %d place(s) — cliquez pour vous inscrire",
}
for key, value in pairs(V172_EN) do GMG.Locales.en[key] = value end
for key, value in pairs(V172_FR) do GMG.Locales.fr[key] = value end

local function V172GetTypeDefinition(category, activityType)
    category = category == "PVP" and "PVP" or "PVE"
    for _, definition in ipairs(V172_ACTIVITY_TYPES[category]) do
        if definition.id == activityType then return definition end
    end
    return nil
end

local function V172DefaultType(category, forNew)
    category = category == "PVP" and "PVP" or "PVE"
    if forNew then return V172_ACTIVITY_TYPES[category][1].id end
    return category == "PVP" and "OTHER_PVP" or "OTHER_PVE"
end

local function V172NormalizeType(category, activityType, forNew)
    local definition = V172GetTypeDefinition(category, activityType)
    return definition and definition.id or V172DefaultType(category, forNew)
end

local function V172NormalizeLevels(category, activityType, minLevel, maxLevel)
    local normalizedType = V172NormalizeType(category, activityType, false)
    local definition = V172GetTypeDefinition(category, normalizedType)
    minLevel = V171Clamp(minLevel, 1, 60, definition and definition.minLevel or 1)
    maxLevel = V171Clamp(maxLevel, 1, 60, definition and definition.maxLevel or 60)
    if definition then
        if definition.fixedLevel then
            minLevel = definition.minLevel
            maxLevel = definition.maxLevel
        else
            minLevel = max(definition.minLevel, min(minLevel, definition.maxLevel))
            maxLevel = max(minLevel, min(maxLevel, definition.maxLevel))
        end
    elseif maxLevel < minLevel then
        maxLevel = minLevel
    end
    return minLevel, maxLevel
end

local function V172TypeLabel(self, activity)
    local category = activity and activity.category == "PVP" and "PVP" or "PVE"
    local activityType = V172NormalizeType(category, activity and activity.activityType, false)
    local definition = V172GetTypeDefinition(category, activityType)
    return self:L(definition and definition.label or (category == "PVP" and "DF_TYPE_OTHER_PVP" or "DF_TYPE_OTHER_PVE"))
end

function GMG:NormalizeDungeonActivityV172(activity)
    if not activity then return activity end
    activity.category = activity.category == "PVP" and "PVP" or "PVE"
    activity.activityType = V172NormalizeType(activity.category, activity.activityType, false)
    activity.minLevel, activity.maxLevel = V172NormalizeLevels(activity.category, activity.activityType, activity.minLevel, activity.maxLevel)
    activity.slots = V171Clamp(activity.slots, 1, 40, 5)
    activity.autoInvite = true
    return activity
end

local GMGGetDungeonActivitiesBeforeV172 = GMG.GetDungeonActivities
function GMG:GetDungeonActivities()
    local activities = GMGGetDungeonActivitiesBeforeV172(self)
    for _, activity in ipairs(activities) do self:NormalizeDungeonActivityV172(activity) end
    return activities
end

local GMGStoreDungeonActivityBeforeV172 = GMG.StoreDungeonActivity
function GMG:StoreDungeonActivity(activity, announce)
    if activity and not activity.activityType and self.v172PendingActivityType
        and self:NormalizeName(activity.owner) == self:GetPlayerName() then
        activity.activityType = self.v172PendingActivityType
    end
    self:NormalizeDungeonActivityV172(activity)
    return GMGStoreDungeonActivityBeforeV172(self, activity, announce)
end

local GMGBuildDungeonActivityPayloadBeforeV172 = GMG.BuildDungeonActivityPayload
function GMG:BuildDungeonActivityPayload(activity)
    self:NormalizeDungeonActivityV172(activity)
    return GMGBuildDungeonActivityPayloadBeforeV172(self, activity) .. "|" .. V171Escape(activity.activityType or "")
end

local GMGCreateDungeonActivityBeforeV172 = GMG.CreateDungeonActivity
function GMG:CreateDungeonActivity(title, category, minLevel, maxLevel, slots, roles, approvalMode, autoInvite, activityType)
    category = category == "PVP" and "PVP" or "PVE"
    activityType = V172NormalizeType(category, activityType, true)
    minLevel, maxLevel = V172NormalizeLevels(category, activityType, minLevel, maxLevel)
    self.v172PendingActivityType = activityType
    local success = GMGCreateDungeonActivityBeforeV172(self, title, category, minLevel, maxLevel, slots, roles, approvalMode, true)
    self.v172PendingActivityType = nil
    return success
end

local GMGUpdateDungeonActivityBeforeV172 = GMG.UpdateDungeonActivity
function GMG:UpdateDungeonActivity(activity, title, category, minLevel, maxLevel, slots, roles, approvalMode, autoInvite, activityType)
    category = category == "PVP" and "PVP" or "PVE"
    activityType = V172NormalizeType(category, activityType or (activity and activity.activityType), false)
    minLevel, maxLevel = V172NormalizeLevels(category, activityType, minLevel, maxLevel)
    if activity then activity.activityType = activityType; activity.autoInvite = true end
    return GMGUpdateDungeonActivityBeforeV172(self, activity, title, category, minLevel, maxLevel, slots, roles, approvalMode, true)
end

function GMG:AutoInviteDungeonMembers(activity)
    if not activity or not self:CanManageDungeonActivity(activity, true) then return end
    activity.autoInvite = true
    local groupSet = self:GetActualGroupMemberSet()
    for player, role in pairs(activity.members or {}) do
        if role and not groupSet[strlower(self:NormalizeName(player))] then self:InviteDungeonMember(activity, player, false, false) end
    end
end

function GMG:UpsertDungeonAnnouncement(activity)
    if not activity or not activity.id then return end
    self:NormalizeDungeonActivityV172(activity)
    local store = self:GetGuildStore(true)
    if store.closedDungeonActivities then store.closedDungeonActivities[activity.id] = nil end
    self:RemoveDungeonAnnouncement(activity.id, false)
    local available = self:GetDungeonActivityAvailable(activity)
    local text = self:L("DF_ANNOUNCEMENT_TYPED", activity.title or "", V172TypeLabel(self, activity), activity.minLevel or 1, activity.maxLevel or 60, available)
    text = "|Hgmgactivity:" .. activity.id .. "|h|cff39ff14" .. text .. "|r|h"
    self:AddHistoryMessage(activity.owner, text, activity.createdAt or time(), "activity", "df-" .. activity.id)
end

local GMGHandleCompletePayloadBeforeV172 = GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload, channel, sender)
    local values = V171Split(payload)
    local command = values[1]
    GMGHandleCompletePayloadBeforeV172(self, payload, channel, sender)
    if command == "DA" and values[2] == self:GetGuildHash() then
        local id = V171Unescape(values[3] or "")
        local activity = self:GetDungeonActivity(id)
        if activity then
            activity.activityType = V172NormalizeType(activity.category, V171Unescape(values[21] or ""), false)
            self:NormalizeDungeonActivityV172(activity)
            self:UpsertDungeonAnnouncement(activity)
            self.dungeonDirty = true
            if self.PersistSettings then self:PersistSettings() end
            if self.RefreshDungeonFinder then self:RefreshDungeonFinder(true) end
        end
    end
end

function GMG:ApplyDungeonActivityTypePreset(frame, activityType, applyDefaults)
    if not frame then return end
    frame.activityType = V172NormalizeType(frame.category, activityType, true)
    local definition = V172GetTypeDefinition(frame.category, frame.activityType)
    if definition and applyDefaults then
        frame.minLevel:SetText(tostring(definition.minLevel))
        frame.maxLevel:SetText(tostring(definition.maxLevel))
        frame.slots:SetText(tostring(max(definition.slots or 5, self:GetActualGroupSize())))
    end
    if definition and definition.fixedLevel then
        frame.minLevel:Disable(); frame.maxLevel:Disable()
        frame.minHolder:SetAlpha(0.55); frame.maxHolder:SetAlpha(0.55)
    else
        frame.minLevel:Enable(); frame.maxLevel:Enable()
        frame.minHolder:SetAlpha(1); frame.maxHolder:SetAlpha(1)
    end
    if frame.activityTypeButton and frame.activityTypeButton.label then
        VBoundedText(frame.activityTypeButton.label, self:L(definition and definition.label or "DF_ACTIVITY_SUBTYPE"), 244)
    end
end

function GMG:InitializeDungeonActivityTypeMenu(frame, level)
    if level ~= 1 or not frame then return end
    local category = frame.category == "PVP" and "PVP" or "PVE"
    for _, definition in ipairs(V172_ACTIVITY_TYPES[category]) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = self:L(definition.label)
        info.checked = frame.activityType == definition.id
        info.func = function()
            GMG:ApplyDungeonActivityTypePreset(frame, definition.id, true)
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

function GMG:EnhanceDungeonCreatePopupV172()
    local frame = self.dungeonCreatePopup
    if not frame or frame.v172Enhanced then return end
    frame.v172Enhanced = true
    frame:SetHeight(650)

    frame.activityTypeLabel = VText(frame, "GameFontNormal", self:L("DF_ACTIVITY_SUBTYPE"), 12)
    frame.activityTypeLabel:SetPoint("TOPLEFT", 24, -208)
    frame.activityTypeButton = VButton(frame, "", 260, 30)
    frame.activityTypeButton:SetPoint("TOPLEFT", 24, -232)
    frame.activityTypeMenu = CreateFrame("Frame", "GlaynaBetterGuildActivityTypeMenu", UIParent, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(frame.activityTypeMenu, function(_, level) GMG:InitializeDungeonActivityTypeMenu(frame, level) end, "MENU")
    frame.activityTypeButton:SetScript("OnClick", function(button)
        ToggleDropDownMenu(1, nil, frame.activityTypeMenu, button, 0, 0)
    end)

    local function NormalizeLevelFields()
        local minimum, maximum = V172NormalizeLevels(frame.category, frame.activityType, frame.minLevel:GetText(), frame.maxLevel:GetText())
        frame.minLevel:SetText(tostring(minimum))
        frame.maxLevel:SetText(tostring(maximum))
    end
    frame.minLevel:SetScript("OnEditFocusLost", NormalizeLevelFields)
    frame.maxLevel:SetScript("OnEditFocusLost", NormalizeLevelFields)
    frame.minLevel:SetScript("OnEnterPressed", function(edit) NormalizeLevelFields(); edit:ClearFocus() end)
    frame.maxLevel:SetScript("OnEnterPressed", function(edit) NormalizeLevelFields(); edit:ClearFocus() end)
    frame.slots:SetScript("OnEditFocusLost", function(edit)
        edit:SetText(tostring(max(GMG:GetActualGroupSize(), V171Clamp(edit:GetText(), 1, 40, 5))))
    end)
    frame.slots:SetScript("OnEnterPressed", function(edit)
        edit:SetText(tostring(max(GMG:GetActualGroupSize(), V171Clamp(edit:GetText(), 1, 40, 5))))
        edit:ClearFocus()
    end)

    frame.levelLabel:ClearAllPoints(); frame.levelLabel:SetPoint("TOPLEFT", 24, -282)
    frame.minLabel:ClearAllPoints(); frame.minLabel:SetPoint("TOPLEFT", 24, -307)
    frame.minHolder:ClearAllPoints(); frame.minHolder:SetPoint("TOPLEFT", 24, -326)
    frame.maxLabel:ClearAllPoints(); frame.maxLabel:SetPoint("TOPLEFT", 154, -307)
    frame.maxHolder:ClearAllPoints(); frame.maxHolder:SetPoint("TOPLEFT", 154, -326)
    frame.slotsLabel:ClearAllPoints(); frame.slotsLabel:SetPoint("TOPLEFT", 284, -307)
    frame.slotsHolder:ClearAllPoints(); frame.slotsHolder:SetPoint("TOPLEFT", 284, -326)

    frame.rolesLabel:ClearAllPoints(); frame.rolesLabel:SetPoint("TOPLEFT", 24, -378)
    for index, check in ipairs(frame.roleChecks or {}) do
        check:ClearAllPoints()
        check:SetPoint("TOPLEFT", 24 + (index - 1) * 126, -406)
    end

    frame.approvalLabel:ClearAllPoints(); frame.approvalLabel:SetPoint("TOPLEFT", 24, -456)
    frame.approvalAuto:ClearAllPoints(); frame.approvalAuto:SetPoint("TOPLEFT", 24, -482)
    frame.approvalManual:ClearAllPoints(); frame.approvalManual:SetPoint("TOPRIGHT", -24, -482)
    frame.autoInvite:Hide()

    frame.pve:SetScript("OnClick", function()
        frame.category = "PVE"
        VSelect(frame.pve, true); VSelect(frame.pvp, false)
        GMG:ApplyDungeonActivityTypePreset(frame, V172DefaultType("PVE", true), true)
    end)
    frame.pvp:SetScript("OnClick", function()
        frame.category = "PVP"
        VSelect(frame.pve, false); VSelect(frame.pvp, true)
        GMG:ApplyDungeonActivityTypePreset(frame, V172DefaultType("PVP", true), true)
    end)

    frame.create:SetScript("OnClick", function()
        local selected = {}
        for _, check in ipairs(frame.roleChecks) do if check:GetChecked() then selected[#selected + 1] = check.role end end
        local minLevel, maxLevel = V172NormalizeLevels(frame.category, frame.activityType, frame.minLevel:GetText(), frame.maxLevel:GetText())
        frame.minLevel:SetText(tostring(minLevel)); frame.maxLevel:SetText(tostring(maxLevel))
        local success
        if frame.editActivityID then
            success = GMG:UpdateDungeonActivity(GMG:GetDungeonActivity(frame.editActivityID), frame.name:GetText(), frame.category,
                minLevel, maxLevel, frame.slots:GetText(), table.concat(selected, ","), frame.approvalMode, true, frame.activityType)
        else
            success = GMG:CreateDungeonActivity(frame.name:GetText(), frame.category, minLevel, maxLevel,
                frame.slots:GetText(), table.concat(selected, ","), frame.approvalMode, true, frame.activityType)
        end
        if success then frame:Hide(); GMG:ShowTab("dungeon"); GMG:RefreshDungeonFinder(true) end
    end)
end

local GMGCreateDungeonCreatePopupBeforeV172 = GMG.CreateDungeonCreatePopup
function GMG:CreateDungeonCreatePopup()
    GMGCreateDungeonCreatePopupBeforeV172(self)
    self:EnhanceDungeonCreatePopupV172()
end

function GMG:OpenDungeonCreatePopup()
    self:CreateDungeonCreatePopup()
    local frame = self.dungeonCreatePopup
    frame.editActivityID = nil
    frame.title:SetText(self:L("DF_CREATE"))
    frame.create.label:SetText(self:L("DF_CREATE_CONFIRM"))
    frame.name:SetText("")
    frame.category = "PVE"
    VSelect(frame.pve, true); VSelect(frame.pvp, false)
    for _, check in ipairs(frame.roleChecks) do check:SetChecked(true) end
    frame.approvalMode = "auto"
    VSelect(frame.approvalAuto, true); VSelect(frame.approvalManual, false)
    frame.autoInvite:SetChecked(true); frame.autoInvite:Hide()
    self:ApplyDungeonActivityTypePreset(frame, V172DefaultType("PVE", true), true)
    frame:Show()
    frame.name:SetFocus()
end

function GMG:OpenDungeonEditPopup(activity)
    if not self:CanManageDungeonActivity(activity, false) then return end
    self:CreateDungeonCreatePopup()
    self:NormalizeDungeonActivityV172(activity)
    local frame = self.dungeonCreatePopup
    frame.editActivityID = activity.id
    frame.title:SetText(self:L("DF_EDIT_TITLE"))
    frame.create.label:SetText(self:L("DF_SAVE"))
    frame.name:SetText(activity.title or "")
    frame.category = activity.category == "PVP" and "PVP" or "PVE"
    VSelect(frame.pve, frame.category == "PVE"); VSelect(frame.pvp, frame.category == "PVP")
    frame.activityType = V172NormalizeType(frame.category, activity.activityType, false)
    self:ApplyDungeonActivityTypePreset(frame, frame.activityType, false)
    frame.minLevel:SetText(tostring(activity.minLevel or 1))
    frame.maxLevel:SetText(tostring(activity.maxLevel or 60))
    frame.slots:SetText(tostring(activity.slots or 5))
    for _, check in ipairs(frame.roleChecks) do check:SetChecked(V171HasRole(activity, check.role)) end
    frame.approvalMode = activity.approvalMode == "manual" and "manual" or "auto"
    VSelect(frame.approvalAuto, frame.approvalMode == "auto"); VSelect(frame.approvalManual, frame.approvalMode == "manual")
    frame.autoInvite:SetChecked(true); frame.autoInvite:Hide()
    frame:Show()
end

local GMGRefreshDungeonFinderBeforeV172 = GMG.RefreshDungeonFinder
function GMG:RefreshDungeonFinder(force)
    GMGRefreshDungeonFinderBeforeV172(self, force)
    local page = self.dungeonPage
    if not page then return end
    local activities = self:GetDungeonActivities()
    for index, row in ipairs(page.rows or {}) do
        local activity = activities[index]
        if activity and row:IsShown() then
            VBoundedText(row.name, V172TypeLabel(self, activity) .. " — " .. (activity.title or ""), 310)
        end
    end

    local activity = self:GetDungeonActivity(self.dungeonSelectedID)
    if not activity then return end
    self:NormalizeDungeonActivityV172(activity)
    local occupancy = self:GetDungeonActivityOccupancy(activity)
    page.membersTitle:SetText(self:L("DF_MEMBERS", occupancy, activity.slots or 1))

    local lines, known = {}, {}
    if self:NormalizeName(activity.owner) == self:GetPlayerName() then
        local groupSet = self:GetActualGroupMemberSet()
        local groupNames = {}
        for _, name in pairs(groupSet) do groupNames[#groupNames + 1] = name end
        sort(groupNames, function(a, b) return strlower(a or "") < strlower(b or "") end)
        for _, name in ipairs(groupNames) do
            local key = strlower(self:NormalizeName(name))
            known[key] = true
            local role = activity.members and activity.members[name]
            lines[#lines + 1] = "• " .. name .. " — " .. (role and V171RoleLabel(self, role) or self:L("DF_IN_GROUP"))
        end
    end
    for name, role in pairs(activity.members or {}) do
        local key = strlower(self:NormalizeName(name))
        if not known[key] then lines[#lines + 1] = "• " .. name .. " — " .. V171RoleLabel(self, role) end
    end
    sort(lines)
    if #lines > 0 then
        page.members:SetText(table.concat(lines, "\n"))
    elseif occupancy > 0 then
        page.members:SetText(self:L("DF_GROUP_MEMBERS_SUMMARY", occupancy))
    else
        page.members:SetText(self:L("DF_EMPTY_MEMBERS"))
    end

    local modeLabel = activity.approvalMode == "manual" and self:L("DF_APPROVAL_MANUAL") or self:L("DF_APPROVAL_AUTO")
    local roleLabels = {}
    for _, role in ipairs(V171RoleList(activity)) do roleLabels[#roleLabels + 1] = V171RoleLabel(self, role) end
    page.detailInfo:SetText(V171CategoryLabel(self, activity.category) .. " • " .. V172TypeLabel(self, activity) .. "\n"
        .. self:L("DF_REQUIRED_LEVEL", activity.minLevel or 1, activity.maxLevel or 60) .. "\n"
        .. self:L("DF_OWNER", activity.owner or "") .. " — " .. modeLabel .. "\n"
        .. self:L("DF_ROLES") .. ": " .. table.concat(roleLabels, ", "))
    page.detailInfo:SetHeight(64)
    if page.inviteAll and page.inviteAll.label then VBoundedText(page.inviteAll.label, self:L("DF_INVITE_ALL"), 92) end
end

local GMGRefreshLocalizationBeforeV172 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV172(self, ...)
    local frame = self.dungeonCreatePopup
    if frame and frame.v172Enhanced then
        frame.activityTypeLabel:SetText(self:L("DF_ACTIVITY_SUBTYPE"))
        self:ApplyDungeonActivityTypePreset(frame, frame.activityType, false)
        frame.approvalAuto.label:SetText(self:L("DF_APPROVAL_AUTO"))
        frame.approvalManual.label:SetText(self:L("DF_APPROVAL_MANUAL"))
        frame.autoInvite:Hide()
    end
    local page = self.dungeonPage
    if page and page.inviteAll and page.inviteAll.label then VBoundedText(page.inviteAll.label, self:L("DF_INVITE_ALL"), 92) end
end
