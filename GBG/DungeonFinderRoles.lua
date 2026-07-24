-- G.B.G (Glayna Better Guild)
-- v1.7.5: profile portraits, role logos and role-capacity management for Guild Finder.
-- Compatible with WoW 3.3.5a / Ascension Interface 30300.

local GMG = GlaynaBetterGuild
local floor = math.floor
local max = math.max
local min = math.min
local sort = table.sort
local tonumber = tonumber
local tostring = tostring
local strlower = string.lower

local V174_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}
local V174_PANEL = {0.045, 0.052, 0.082, 0.99}
local V174_PANEL_2 = {0.075, 0.082, 0.125, 0.98}
local V174_BORDER = {0.24, 0.22, 0.38, 1}
local V174_ACCENT = {0.60, 0.42, 1.00, 1}
local V174_TEXT = {0.88, 0.90, 0.96, 1}
local V174_MUTED = {0.48, 0.52, 0.64, 1}
local V174_GREEN = {0.25, 0.90, 0.55, 1}
local V174_RED = {0.95, 0.34, 0.42, 1}

local V174_ROLE_ICONS = {
    tank = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    heal = "Interface\\Icons\\Spell_Holy_GreaterHeal",
    dps = "Interface\\Icons\\Ability_DualWield",
    support = "Interface\\Icons\\Spell_Holy_PowerWordShield",
    unknown = "Interface\\Icons\\INV_Misc_QuestionMark",
}

local V174_EN = {
    DF_ROLE_FULL = "Full",
    DF_ROLE_CAPACITY = "%d/%d",
    DF_ROLE_FULL_MESSAGE = "The %s role is full for this activity.",
    DF_MEMBER_IN_GROUP = "Already in the group",
    DF_MEMBER_ACCEPTED = "Accepted — invitation pending",
    DF_MEMBER_REGISTERED = "Registered",
    DF_MEMBER_ROLE_UNKNOWN = "Role not assigned",
    DF_ROLE_COMPOSITION = "Required composition",
    DF_ROLE_FLEX = "Damage / Support",
}
local V174_FR = {
    DF_ROLE_FULL = "Complet",
    DF_ROLE_CAPACITY = "%d/%d",
    DF_ROLE_FULL_MESSAGE = "Le rôle %s est complet pour cette activité.",
    DF_MEMBER_IN_GROUP = "Déjà dans le groupe",
    DF_MEMBER_ACCEPTED = "Accepté — invitation en attente",
    DF_MEMBER_REGISTERED = "Inscrit",
    DF_MEMBER_ROLE_UNKNOWN = "Rôle non attribué",
    DF_ROLE_COMPOSITION = "Composition requise",
    DF_ROLE_FLEX = "Dégâts / Soutien",
}
GMG.Locales = GMG.Locales or {en = {}, fr = {}}
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(V174_EN) do GMG.Locales.en[key] = value end
for key, value in pairs(V174_FR) do GMG.Locales.fr[key] = value end

local function V174Backdrop(frame, background, border)
    frame:SetBackdrop(V174_BACKDROP)
    frame:SetBackdropColor(unpack(background or V174_PANEL))
    frame:SetBackdropBorderColor(unpack(border or V174_BORDER))
end

local function V174Text(parent, fontObject, text, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObject or "GameFontNormal")
    if size then
        local font, _, flags = fs:GetFont()
        if font then fs:SetFont(font, size, flags) end
    end
    fs:SetText(text or "")
    fs:SetTextColor(unpack(V174_TEXT))
    return fs
end

local function V174RoleLabel(self, role)
    local keys = {
        tank = "DF_ROLE_TANK",
        heal = "DF_ROLE_HEAL",
        dps = "DF_ROLE_DPS",
        support = "DF_ROLE_SUPPORT",
    }
    return self:L(keys[role] or "DF_MEMBER_ROLE_UNKNOWN")
end

local function V174HasRole(activity, role)
    for value in string.gmatch(activity and activity.roles or "", "[^,]+") do
        if value == role then return true end
    end
    return false
end

local function V174NormalizeRole(role)
    role = tostring(role or "")
    if role == "TANK" or role == "tank" then return "tank" end
    if role == "HEALER" or role == "HEAL" or role == "heal" then return "heal" end
    if role == "DAMAGER" or role == "DAMAGE" or role == "DPS" or role == "dps" then return "dps" end
    if role == "SUPPORT" or role == "support" then return "support" end
    return nil
end

local function V174GetStoredMemberRole(activity, name)
    local wanted = strlower(GMG:NormalizeName(name or ""))
    for memberName, role in pairs(activity and activity.members or {}) do
        if strlower(GMG:NormalizeName(memberName or "")) == wanted then return V174NormalizeRole(role) end
    end
    return nil
end

function GMG:GetDungeonRoleIcon(role)
    return V174_ROLE_ICONS[V174NormalizeRole(role) or "unknown"] or V174_ROLE_ICONS.unknown
end

function GMG:GetDungeonRoleCaps(activity)
    local slots = max(1, min(40, tonumber(activity and activity.slots) or 1))
    local allowed = {
        tank = V174HasRole(activity, "tank"),
        heal = V174HasRole(activity, "heal"),
        dps = V174HasRole(activity, "dps"),
        support = V174HasRole(activity, "support"),
    }

    -- PvP does not enforce a fixed tank/healer composition. The global group
    -- size remains the only hard capacity, but the role logos are still shown.
    if activity and activity.category == "PVP" then
        return {
            tank = allowed.tank and slots or 0,
            heal = allowed.heal and slots or 0,
            flex = (allowed.dps or allowed.support) and slots or 0,
            dps = (allowed.dps or allowed.support) and slots or 0,
            support = (allowed.dps or allowed.support) and slots or 0,
        }
    end

    local tankCap = 0
    if allowed.tank and slots >= 2 then
        tankCap = slots >= 10 and 2 or 1
    elseif allowed.tank and slots == 1 then
        tankCap = 1
    end

    local remaining = max(0, slots - tankCap)
    local healCap = 0
    if allowed.heal and remaining > 0 then
        healCap = min(remaining, max(1, math.ceil(slots / 5)))
    end

    local flexAllowed = allowed.dps or allowed.support
    local flexCap = flexAllowed and max(0, slots - tankCap - healCap) or 0

    -- Keep every configured place usable even for unusual role selections.
    local allocated = tankCap + healCap + flexCap
    local extra = slots - allocated
    if extra > 0 then
        if flexAllowed then flexCap = flexCap + extra
        elseif allowed.heal then healCap = healCap + extra
        elseif allowed.tank then tankCap = tankCap + extra end
    end

    return {
        tank = tankCap,
        heal = healCap,
        flex = flexCap,
        dps = flexCap,
        support = flexCap,
    }
end

function GMG:GetActualDungeonGroupRoleMap(activity)
    local roles = {}
    local function Add(unit, suppliedName)
        local name = self:NormalizeName(suppliedName or (UnitName and UnitName(unit)) or "")
        if name == "" then return end
        local role = V174GetStoredMemberRole(activity, name)
        if not role and UnitGroupRolesAssigned then role = V174NormalizeRole(UnitGroupRolesAssigned(unit)) end
        if not role and GetPartyAssignment and GetPartyAssignment("MAINTANK", unit) then role = "tank" end
        roles[strlower(name)] = role
    end

    local raidCount = GetNumRaidMembers and (GetNumRaidMembers() or 0) or 0
    if raidCount > 0 then
        for index = 1, raidCount do
            local name = GetRaidRosterInfo and GetRaidRosterInfo(index)
            Add("raid" .. index, name)
        end
    else
        Add("player", self:GetPlayerName())
        local partyCount = GetNumPartyMembers and (GetNumPartyMembers() or 0) or 0
        for index = 1, partyCount do Add("party" .. index) end
    end
    return roles
end

function GMG:GetDungeonRoleCounts(activity)
    local counts = {tank = 0, heal = 0, dps = 0, support = 0, flex = 0, unknown = 0}
    if not activity then return counts end
    local seen = {}
    local localOwner = self:NormalizeName(activity.owner) == self:GetPlayerName()
    local groupSet = localOwner and self:GetActualGroupMemberSet() or {}
    local groupRoles = localOwner and self:GetActualDungeonGroupRoleMap(activity) or {}

    for key, displayName in pairs(groupSet or {}) do
        local normalized = strlower(self:NormalizeName(displayName or key))
        if normalized ~= "" and not seen[normalized] then
            seen[normalized] = true
            local role = V174GetStoredMemberRole(activity, displayName) or groupRoles[normalized]
            if role then counts[role] = (counts[role] or 0) + 1 else counts.unknown = counts.unknown + 1 end
        end
    end

    for memberName, storedRole in pairs(activity.members or {}) do
        local normalized = strlower(self:NormalizeName(memberName))
        if normalized ~= "" and not seen[normalized] then
            seen[normalized] = true
            local role = V174NormalizeRole(storedRole)
            if role then counts[role] = (counts[role] or 0) + 1 else counts.unknown = counts.unknown + 1 end
        end
    end

    counts.flex = (counts.dps or 0) + (counts.support or 0)
    return counts
end

function GMG:GetDungeonRoleUsage(activity, role)
    role = V174NormalizeRole(role)
    if not role then return 0, 0 end
    local caps = self:GetDungeonRoleCaps(activity)
    local counts = self:GetDungeonRoleCounts(activity)
    if role == "dps" or role == "support" then return counts.flex or 0, caps.flex or 0 end
    return counts[role] or 0, caps[role] or 0
end

function GMG:IsDungeonRoleAvailable(activity, role)
    role = V174NormalizeRole(role)
    if not role or not V174HasRole(activity, role) then return false end
    if self:GetDungeonActivityAvailable(activity) <= 0 then return false end
    local used, cap = self:GetDungeonRoleUsage(activity, role)
    if cap <= 0 then return false end
    return used < cap
end

local GMGRequestDungeonJoinBeforeV174 = GMG.RequestDungeonJoin
function GMG:RequestDungeonJoin(activity, role, leave)
    if activity and not leave then
        local me = self:GetPlayerName()
        local already = activity.members and activity.members[me]
        local pending = activity.pending and activity.pending[me]
        if not already and not pending and not self:IsDungeonRoleAvailable(activity, role) then
            self:Print(self:L("DF_ROLE_FULL_MESSAGE", V174RoleLabel(self, role)))
            return
        end
    end
    return GMGRequestDungeonJoinBeforeV174(self, activity, role, leave)
end

local GMGApplyDungeonJoinRequestBeforeV174 = GMG.ApplyDungeonJoinRequest
function GMG:ApplyDungeonJoinRequest(id, player, role, action, sender)
    local activity = self:GetDungeonActivity(id)
    if activity and action == "join" and not (activity.members and activity.members[player])
        and not (activity.pending and activity.pending[player])
        and not self:IsDungeonRoleAvailable(activity, role) then
        return
    end
    return GMGApplyDungeonJoinRequestBeforeV174(self, id, player, role, action, sender)
end

local GMGAcceptDungeonApplicantBeforeV174 = GMG.AcceptDungeonApplicant
function GMG:AcceptDungeonApplicant(activity, player, role)
    if activity and not self:IsDungeonRoleAvailable(activity, role) then
        self:Print(self:L("DF_ROLE_FULL_MESSAGE", V174RoleLabel(self, role)))
        return false
    end
    return GMGAcceptDungeonApplicantBeforeV174(self, activity, player, role)
end

function GMG:BuildDungeonFinderMemberList(activity)
    local result, seen = {}, {}
    if not activity then return result end
    local localOwner = self:NormalizeName(activity.owner) == self:GetPlayerName()
    local groupSet = localOwner and self:GetActualGroupMemberSet() or {}
    local groupRoles = localOwner and self:GetActualDungeonGroupRoleMap(activity) or {}

    if localOwner then
        for key, displayName in pairs(groupSet or {}) do
            local name = self:NormalizeName(displayName or key)
            local normalized = strlower(name)
            if name ~= "" and not seen[normalized] then
                seen[normalized] = true
                result[#result + 1] = {
                    name = name,
                    role = V174GetStoredMemberRole(activity, name) or groupRoles[normalized],
                    inGroup = true,
                }
            end
        end
    end

    for memberName, role in pairs(activity.members or {}) do
        local name = self:NormalizeName(memberName)
        local normalized = strlower(name)
        if name ~= "" and not seen[normalized] then
            seen[normalized] = true
            result[#result + 1] = {
                name = name,
                role = V174NormalizeRole(role),
                inGroup = groupSet and groupSet[normalized] ~= nil,
            }
        end
    end

    sort(result, function(a, b)
        if a.inGroup ~= b.inGroup then return a.inGroup and not b.inGroup end
        local order = {tank = 1, heal = 2, dps = 3, support = 4}
        local ar, br = order[a.role] or 9, order[b.role] or 9
        if ar ~= br then return ar < br end
        return strlower(a.name or "") < strlower(b.name or "")
    end)
    return result
end

function GMG:InstallDungeonRoleVisuals()
    local page = self.dungeonPage
    if not page or page.v174RoleVisuals then return end
    page.v174RoleVisuals = true

    -- Role composition badges in the activity search/list.
    for _, row in ipairs(page.rows or {}) do
        row.name:ClearAllPoints()
        row.name:SetPoint("TOPLEFT", 66, -8)
        row.name:SetPoint("RIGHT", -142, 0)
        row.meta:ClearAllPoints()
        row.meta:SetPoint("BOTTOMLEFT", 10, 9)
        row.meta:SetPoint("RIGHT", -142, 0)
        row.roleBadges = {}
        local roles = {"tank", "heal", "dps"}
        for index, role in ipairs(roles) do
            local badge = CreateFrame("Frame", nil, row)
            badge:SetWidth(42)
            badge:SetHeight(22)
            badge:SetPoint("TOPRIGHT", -6 - (3 - index) * 43, -6)
            badge.icon = badge:CreateTexture(nil, "ARTWORK")
            badge.icon:SetTexture(self:GetDungeonRoleIcon(role))
            badge.icon:SetWidth(15)
            badge.icon:SetHeight(15)
            badge.icon:SetPoint("LEFT", 0, 0)
            badge.count = V174Text(badge, "GameFontNormalSmall", "0/0", 9)
            badge.count:SetPoint("LEFT", badge.icon, "RIGHT", 2, 0)
            badge.count:SetTextColor(unpack(V174_MUTED))
            badge.role = role
            row.roleBadges[role] = badge
        end
    end

    -- Role logos and live capacity under each role selector.
    for _, button in ipairs(page.roleButtons or {}) do
        button:SetHeight(32)
        button.roleIcon = button:CreateTexture(nil, "ARTWORK")
        button.roleIcon:SetTexture(self:GetDungeonRoleIcon(button.role))
        button.roleIcon:SetWidth(18)
        button.roleIcon:SetHeight(18)
        button.roleIcon:SetPoint("LEFT", 5, 0)
        button.label:ClearAllPoints()
        button.label:SetPoint("TOPLEFT", button.roleIcon, "TOPRIGHT", 4, -1)
        button.label:SetPoint("RIGHT", -3, 0)
        button.label:SetJustifyH("LEFT")
        button.roleStatus = V174Text(button, "GameFontNormalSmall", "", 9)
        button.roleStatus:SetPoint("BOTTOMLEFT", button.roleIcon, "BOTTOMRIGHT", 4, 1)
        button.roleStatus:SetPoint("RIGHT", -3, 0)
        button.roleStatus:SetJustifyH("LEFT")
    end

    if page.members then page.members:Hide() end
    page.memberRows = {}
    page.memberPage = 1
    for index = 1, 6 do
        local row = CreateFrame("Frame", nil, page.detail)
        row:SetHeight(34)
        row:SetPoint("TOPLEFT", 18, -250 - (index - 1) * 38)
        row:SetPoint("TOPRIGHT", -18, -250 - (index - 1) * 38)
        V174Backdrop(row, V174_PANEL_2, V174_BORDER)
        row.avatar = row:CreateTexture(nil, "ARTWORK")
        row.avatar:SetWidth(28)
        row.avatar:SetHeight(28)
        row.avatar:SetPoint("LEFT", 3, 0)
        row.roleIcon = row:CreateTexture(nil, "OVERLAY")
        row.roleIcon:SetWidth(18)
        row.roleIcon:SetHeight(18)
        row.roleIcon:SetPoint("LEFT", row.avatar, "RIGHT", 6, 0)
        row.name = V174Text(row, "GameFontNormal", "", 11)
        row.name:SetPoint("TOPLEFT", row.roleIcon, "TOPRIGHT", 6, -4)
        row.name:SetPoint("RIGHT", -8, 0)
        row.name:SetJustifyH("LEFT")
        row.status = V174Text(row, "GameFontNormalSmall", "", 9)
        row.status:SetPoint("BOTTOMLEFT", row.roleIcon, "BOTTOMRIGHT", 6, 4)
        row.status:SetPoint("RIGHT", -8, 0)
        row.status:SetJustifyH("LEFT")
        row.status:SetTextColor(unpack(V174_MUTED))
        row:Hide()
        page.memberRows[index] = row
    end

    page.memberPrev = CreateFrame("Button", nil, page.detail)
    page.memberPrev:SetWidth(32); page.memberPrev:SetHeight(24)
    V174Backdrop(page.memberPrev, V174_PANEL_2, V174_BORDER)
    page.memberPrev.label = V174Text(page.memberPrev, "GameFontNormal", "<", 11)
    page.memberPrev.label:SetPoint("CENTER")
    page.memberPrev:SetPoint("BOTTOMLEFT", 18, 91)
    page.memberPrev:SetScript("OnClick", function()
        page.memberPage = max(1, (page.memberPage or 1) - 1)
        GMG:RefreshDungeonRoleVisuals()
    end)
    page.memberPageLabel = V174Text(page.detail, "GameFontNormalSmall", "1 / 1", 9)
    page.memberPageLabel:SetWidth(62)
    page.memberPageLabel:SetPoint("LEFT", page.memberPrev, "RIGHT", 5, 0)
    page.memberPageLabel:SetJustifyH("CENTER")
    page.memberNext = CreateFrame("Button", nil, page.detail)
    page.memberNext:SetWidth(32); page.memberNext:SetHeight(24)
    V174Backdrop(page.memberNext, V174_PANEL_2, V174_BORDER)
    page.memberNext.label = V174Text(page.memberNext, "GameFontNormal", ">", 11)
    page.memberNext.label:SetPoint("CENTER")
    page.memberNext:SetPoint("LEFT", page.memberPageLabel, "RIGHT", 5, 0)
    page.memberNext:SetScript("OnClick", function()
        page.memberPage = (page.memberPage or 1) + 1
        GMG:RefreshDungeonRoleVisuals()
    end)
end

function GMG:RefreshDungeonRoleVisuals()
    local page = self.dungeonPage
    if not page or not page.v174RoleVisuals then return end
    if page.members then page.members:Hide() end

    local activities = self:GetDungeonActivities()
    for index, row in ipairs(page.rows or {}) do
        local activity = activities[index]
        if activity and row:IsShown() and row.roleBadges then
            local caps = self:GetDungeonRoleCaps(activity)
            local counts = self:GetDungeonRoleCounts(activity)
            local values = {
                tank = {counts.tank or 0, caps.tank or 0},
                heal = {counts.heal or 0, caps.heal or 0},
                dps = {counts.flex or 0, caps.flex or 0},
            }
            for role, badge in pairs(row.roleBadges) do
                local value = values[role]
                if value and value[2] > 0 then
                    badge.count:SetText(value[1] .. "/" .. value[2])
                    if value[1] >= value[2] then badge.count:SetTextColor(unpack(V174_RED)) else badge.count:SetTextColor(unpack(V174_MUTED)) end
                    badge:Show()
                else
                    badge:Hide()
                end
            end
        elseif row.roleBadges then
            for _, badge in pairs(row.roleBadges) do badge:Hide() end
        end
    end

    local activity = self:GetDungeonActivity(self.dungeonSelectedID)
    if not activity then
        for _, row in ipairs(page.memberRows or {}) do row:Hide() end
        if page.memberPrev then page.memberPrev:Hide(); page.memberNext:Hide(); page.memberPageLabel:Hide() end
        return
    end

    local me = self:GetPlayerName()
    local joined = activity.members and activity.members[me] ~= nil
    local pending = activity.pending and activity.pending[me] ~= nil
    local firstAvailable
    for _, button in ipairs(page.roleButtons or {}) do
        if button:IsShown() then
            local used, cap = self:GetDungeonRoleUsage(activity, button.role)
            local full = cap <= 0 or used >= cap
            button.roleIcon:SetTexture(self:GetDungeonRoleIcon(button.role))
            button.roleStatus:SetText(full and (used .. "/" .. cap .. " • " .. self:L("DF_ROLE_FULL")) or self:L("DF_ROLE_CAPACITY", used, cap))
            if full then button.roleStatus:SetTextColor(unpack(V174_RED)) else button.roleStatus:SetTextColor(unpack(V174_GREEN)) end
            if full and not joined and not pending then button:Disable() else button:Enable() end
            if not full and not firstAvailable then firstAvailable = button.role end
        end
    end

    if not joined and not pending and page.selectedRole and not self:IsDungeonRoleAvailable(activity, page.selectedRole) then
        page.selectedRole = firstAvailable
    end
    if not joined and not pending and page.selectedRole and not self:IsDungeonRoleAvailable(activity, page.selectedRole) then
        page.join:Disable()
        page.levelWarning:SetText(self:L("DF_ROLE_FULL_MESSAGE", V174RoleLabel(self, page.selectedRole)))
        page.levelWarning:SetTextColor(unpack(V174_RED))
    end

    local members = self:BuildDungeonFinderMemberList(activity)
    local perPage = #page.memberRows
    local maxPage = max(1, math.ceil(#members / perPage))
    page.memberPage = max(1, min(maxPage, tonumber(page.memberPage) or 1))
    local offset = (page.memberPage - 1) * perPage
    for index, row in ipairs(page.memberRows) do
        local entry = members[offset + index]
        if entry then
            local rosterMember = self.GetRosterMemberByName and self:GetRosterMemberByName(entry.name)
            row.avatar:SetTexture(self:GetAvatarFor(entry.name, rosterMember and rosterMember.class, rosterMember and rosterMember.classFile, true))
            row.roleIcon:SetTexture(self:GetDungeonRoleIcon(entry.role))
            row.name:SetText(entry.name .. (entry.role and (" — " .. V174RoleLabel(self, entry.role)) or ""))
            row.status:SetText(entry.inGroup and self:L("DF_MEMBER_IN_GROUP") or self:L("DF_MEMBER_ACCEPTED"))
            if entry.inGroup then row.status:SetTextColor(unpack(V174_GREEN)) else row.status:SetTextColor(unpack(V174_MUTED)) end
            row:Show()
        else
            row:Hide()
        end
    end
    page.memberPageLabel:SetText(page.memberPage .. " / " .. maxPage)
    if #members > perPage then
        page.memberPrev:Show(); page.memberNext:Show(); page.memberPageLabel:Show()
        if page.memberPage > 1 then page.memberPrev:Enable() else page.memberPrev:Disable() end
        if page.memberPage < maxPage then page.memberNext:Enable() else page.memberNext:Disable() end
    else
        page.memberPrev:Hide(); page.memberNext:Hide(); page.memberPageLabel:Hide()
    end
end

local GMGCreateDungeonFinderPageBeforeV174 = GMG.CreateDungeonFinderPage
function GMG:CreateDungeonFinderPage()
    GMGCreateDungeonFinderPageBeforeV174(self)
    self:InstallDungeonRoleVisuals()
end

local GMGRefreshDungeonFinderBeforeV174 = GMG.RefreshDungeonFinder
function GMG:RefreshDungeonFinder(force)
    GMGRefreshDungeonFinderBeforeV174(self, force)
    self:InstallDungeonRoleVisuals()
    self:RefreshDungeonRoleVisuals()
end

local GMGCreateDungeonApplicantPopupBeforeV174 = GMG.CreateDungeonApplicantPopup
function GMG:CreateDungeonApplicantPopup()
    GMGCreateDungeonApplicantPopupBeforeV174(self)
    local frame = self.dungeonApplicantPopup
    if not frame or frame.v174ApplicantVisuals then return end
    frame.v174ApplicantVisuals = true
    for _, row in ipairs(frame.rows or {}) do
        row.avatar = row:CreateTexture(nil, "ARTWORK")
        row.avatar:SetWidth(32); row.avatar:SetHeight(32); row.avatar:SetPoint("LEFT", 5, 0)
        row.roleIcon = row:CreateTexture(nil, "OVERLAY")
        row.roleIcon:SetWidth(18); row.roleIcon:SetHeight(18); row.roleIcon:SetPoint("LEFT", row.avatar, "RIGHT", 6, 0)
        row.name:ClearAllPoints()
        row.name:SetPoint("LEFT", row.roleIcon, "RIGHT", 6, 0)
        row.name:SetPoint("RIGHT", -230, 0)
    end
end

local GMGRefreshDungeonApplicantPopupBeforeV174 = GMG.RefreshDungeonApplicantPopup
function GMG:RefreshDungeonApplicantPopup()
    GMGRefreshDungeonApplicantPopupBeforeV174(self)
    local frame = self.dungeonApplicantPopup
    if not frame or not frame:IsShown() then return end
    local activity = self:GetDungeonActivity(frame.activityID)
    for _, row in ipairs(frame.rows or {}) do
        if row:IsShown() and row.accept and row.accept.playerName then
            local name = row.accept.playerName
            local role = row.accept.role
            local member = self.GetRosterMemberByName and self:GetRosterMemberByName(name)
            row.avatar:SetTexture(self:GetAvatarFor(name, member and member.class, member and member.classFile, true))
            row.roleIcon:SetTexture(self:GetDungeonRoleIcon(role))
            row.name:SetText(name .. " — " .. V174RoleLabel(self, role))
            if activity and self:IsDungeonRoleAvailable(activity, role) then row.accept:Enable() else row.accept:Disable() end
        end
    end
end

local GMGRefreshPortraitConsumersBeforeV174 = GMG.RefreshPortraitConsumers
function GMG:RefreshPortraitConsumers()
    GMGRefreshPortraitConsumersBeforeV174(self)
    if self.dungeonPage and self.dungeonPage:IsShown() then self:RefreshDungeonFinder(true) end
    if self.dungeonApplicantPopup and self.dungeonApplicantPopup:IsShown() then self:RefreshDungeonApplicantPopup() end
end

local GMGRefreshLocalizationBeforeV174 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV174(self, ...)
    if self.dungeonPage then self:RefreshDungeonFinder(true) end
end
