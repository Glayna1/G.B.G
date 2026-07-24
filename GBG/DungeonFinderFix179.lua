-- G.B.G (Glayna Better Guild)
-- v1.8.0: group-leader creation restriction and Finder overlap corrections.
-- WoW 3.3.5a / Ascension Interface 30300.

local GMG = GlaynaBetterGuild
local max = math.max
local min = math.min
local floor = math.floor
local tonumber = tonumber
local tostring = tostring
local strlower = string.lower

local PANEL = {0.045, 0.052, 0.082, 0.99}
local PANEL2 = {0.075, 0.082, 0.125, 0.98}
local BORDER = {0.24, 0.22, 0.38, 1}
local ACCENT = {0.60, 0.42, 1.00, 1}
local TEXT = {0.88, 0.90, 0.96, 1}
local MUTED = {0.48, 0.52, 0.64, 1}
local GREEN = {0.25, 0.90, 0.55, 1}
local RED = {0.95, 0.34, 0.42, 1}

local EN = {
    DF_CREATE_BLOCKED_NOT_LEADER = "Only the current party or raid leader can create a guild activity.",
    DF_CREATE_LEADER_REQUIRED_TITLE = "Group leader required",
    DF_TOOLTIP_CREATE_LEADER = "Only the current party or raid leader may create an activity. A solo player is considered the leader of their future group.",
    DF_ROLE_COUNT_TOOLTIP = "%s: %d/%d place(s) filled.",
}
local FR = {
    DF_CREATE_BLOCKED_NOT_LEADER = "Seul le chef actuel du groupe ou du raid peut créer une activité de guilde.",
    DF_CREATE_LEADER_REQUIRED_TITLE = "Chef de groupe requis",
    DF_TOOLTIP_CREATE_LEADER = "Seul le chef actuel du groupe ou du raid peut créer une activité. Un joueur seul est considéré comme le chef de son futur groupe.",
    DF_ROLE_COUNT_TOOLTIP = "%s : %d/%d place(s) occupée(s).",
}
GMG.Locales = GMG.Locales or {en = {}, fr = {}}
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end

local function NormalizeRole(role)
    role = strlower(tostring(role or ""))
    if role == "tank" then return "tank" end
    if role == "heal" or role == "healer" then return "heal" end
    if role == "dps" or role == "damage" or role == "damager" then return "dps" end
    if role == "support" then return "support" end
    return nil
end

local function RoleLabel(self, role)
    local keys = {
        tank = "DF_ROLE_TANK",
        heal = "DF_ROLE_HEAL",
        dps = "DF_ROLE_DPS",
        support = "DF_ROLE_SUPPORT",
    }
    return self:L(keys[NormalizeRole(role)] or "DF_MEMBER_ROLE_UNKNOWN")
end

local function IsGrouped()
    local raidCount = GetNumRaidMembers and (GetNumRaidMembers() or 0) or 0
    if raidCount > 0 then return true end
    local partyCount = GetNumPartyMembers and (GetNumPartyMembers() or 0) or 0
    return partyCount > 0
end

function GMG:CanCreateDungeonActivityAsLeader()
    -- A solo player is effectively the leader of the group they are about to build.
    if not IsGrouped() then return true end
    if self.IsCurrentGroupLeader then return self:IsCurrentGroupLeader() and true or false end

    local raidCount = GetNumRaidMembers and (GetNumRaidMembers() or 0) or 0
    if raidCount > 0 then
        if IsRaidLeader then return IsRaidLeader() and true or false end
        if UnitIsGroupLeader then return UnitIsGroupLeader("player") and true or false end
        return false
    end
    if IsPartyLeader then return IsPartyLeader() and true or false end
    if UnitIsGroupLeader then return UnitIsGroupLeader("player") and true or false end
    return false
end

function GMG:ShowDungeonLeaderRequiredPopup()
    local message = self:L("DF_CREATE_BLOCKED_NOT_LEADER")
    if StaticPopupDialogs and StaticPopup_Show then
        StaticPopupDialogs.GMG_DF_LEADER_REQUIRED = StaticPopupDialogs.GMG_DF_LEADER_REQUIRED or {
            text = "%s",
            button1 = "OK",
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
            preferredIndex = 3,
        }
        StaticPopupDialogs.GMG_DF_LEADER_REQUIRED.text = "%s"
        StaticPopupDialogs.GMG_DF_LEADER_REQUIRED.button1 = self:L("DF_OK")
        StaticPopup_Show("GMG_DF_LEADER_REQUIRED", message)
    else
        self:Print(message)
    end
end

function GMG:RefreshDungeonCreateLeaderState()
    local page = self.dungeonPage
    if not page or not page.create then return end
    local allowed = self:CanCreateDungeonActivityAsLeader()
    page.create.gmgLeaderAllowed = allowed
    if allowed then
        page.create:SetAlpha(1)
        page.create:SetBackdropColor(unpack(PANEL2))
        page.create:SetBackdropBorderColor(unpack(BORDER))
    else
        page.create:SetAlpha(0.42)
        page.create:SetBackdropColor(0.08, 0.08, 0.10, 0.98)
        page.create:SetBackdropBorderColor(0.28, 0.28, 0.32, 1)
    end
    page.create.gmgTooltipTitle = self:L("DF_CREATE")
    page.create.gmgTooltipHelp = allowed and self:L("DF_TOOLTIP_CREATE") or self:L("DF_TOOLTIP_CREATE_LEADER")
end

function GMG:InstallDungeonLeaderCreateGuard()
    local page = self.dungeonPage
    if not page or not page.create or page.create.gmgV179LeaderGuard then return end
    page.create.gmgV179LeaderGuard = true
    local originalClick = page.create:GetScript("OnClick")
    page.create:SetScript("OnClick", function(button, ...)
        GMG:RefreshDungeonCreateLeaderState()
        if not GMG:CanCreateDungeonActivityAsLeader() then
            GMG:ShowDungeonLeaderRequiredPopup()
            return
        end
        if originalClick then originalClick(button, ...) end
    end)

    local originalUpdate = page.create:GetScript("OnUpdate")
    page.create:SetScript("OnUpdate", function(button, elapsed)
        if originalUpdate then originalUpdate(button, elapsed) end
        button.gmgLeaderElapsed = (button.gmgLeaderElapsed or 0) + (elapsed or 0)
        if button.gmgLeaderElapsed >= 0.5 then
            button.gmgLeaderElapsed = 0
            GMG:RefreshDungeonCreateLeaderState()
        end
    end)
end

local PreviousCreateInvalidReasonV179 = GMG.GetDungeonCreateInvalidReason
function GMG:GetDungeonCreateInvalidReason(...)
    if not self:CanCreateDungeonActivityAsLeader() then
        return self:L("DF_CREATE_BLOCKED_NOT_LEADER")
    end
    if PreviousCreateInvalidReasonV179 then return PreviousCreateInvalidReasonV179(self, ...) end
    return nil
end

local PreviousOpenDungeonCreatePopupV179 = GMG.OpenDungeonCreatePopup
function GMG:OpenDungeonCreatePopup(...)
    if not self:CanCreateDungeonActivityAsLeader() then
        self:ShowDungeonLeaderRequiredPopup()
        self:RefreshDungeonCreateLeaderState()
        return
    end
    return PreviousOpenDungeonCreatePopupV179(self, ...)
end

local PreviousCreateDungeonActivityV179 = GMG.CreateDungeonActivity
function GMG:CreateDungeonActivity(...)
    if not self:CanCreateDungeonActivityAsLeader() then
        self:ShowDungeonLeaderRequiredPopup()
        return false
    end
    return PreviousCreateDungeonActivityV179(self, ...)
end

local function ApplyRoleButtonLayout(self, button)
    if not button or not button.roleIcon or not button.roleStatus or not button.label then return end
    button:SetHeight(38)

    button.roleIcon:ClearAllPoints()
    button.roleIcon:SetWidth(20)
    button.roleIcon:SetHeight(20)
    button.roleIcon:SetPoint("LEFT", 8, 0)

    button.label:ClearAllPoints()
    button.label:SetPoint("LEFT", button.roleIcon, "RIGHT", 7, 0)
    button.label:SetPoint("RIGHT", -48, 0)
    button.label:SetJustifyH("LEFT")
    button.label:SetJustifyV("MIDDLE")
    if button.label.SetWordWrap then button.label:SetWordWrap(false) end
    if button.label.SetNonSpaceWrap then button.label:SetNonSpaceWrap(false) end
    button.label:SetText(RoleLabel(self, button.role))

    button.roleStatus:ClearAllPoints()
    button.roleStatus:SetWidth(38)
    button.roleStatus:SetPoint("RIGHT", -8, 0)
    button.roleStatus:SetJustifyH("RIGHT")
    button.roleStatus:SetJustifyV("MIDDLE")
end

local function ApplyMemberRowLayout(row)
    if not row then return end
    row:SetHeight(38)
    if row.avatar then
        row.avatar:ClearAllPoints()
        row.avatar:SetWidth(30)
        row.avatar:SetHeight(30)
        row.avatar:SetPoint("LEFT", 4, 0)
    end
    if row.roleIcon then
        row.roleIcon:ClearAllPoints()
        row.roleIcon:SetWidth(18)
        row.roleIcon:SetHeight(18)
        row.roleIcon:SetPoint("LEFT", row.avatar, "RIGHT", 7, 0)
    end
    if row.name then
        row.name:ClearAllPoints()
        row.name:SetPoint("LEFT", row.roleIcon, "RIGHT", 7, 0)
        row.name:SetPoint("RIGHT", -175, 0)
        row.name:SetJustifyH("LEFT")
        row.name:SetJustifyV("MIDDLE")
        row.name:SetTextColor(unpack(TEXT))
        if row.name.SetWordWrap then row.name:SetWordWrap(false) end
        if row.name.SetNonSpaceWrap then row.name:SetNonSpaceWrap(false) end
    end
    if row.status then
        row.status:ClearAllPoints()
        row.status:SetWidth(160)
        row.status:SetPoint("RIGHT", -8, 0)
        row.status:SetJustifyH("RIGHT")
        row.status:SetJustifyV("MIDDLE")
        if row.status.SetWordWrap then row.status:SetWordWrap(false) end
        if row.status.SetNonSpaceWrap then row.status:SetNonSpaceWrap(false) end
    end
end

function GMG:ApplyDungeonFinderV179Layout()
    local page = self.dungeonPage
    if not page then return end

    -- Keep each role label and its capacity in separate horizontal columns.
    page.roleTitle:ClearAllPoints()
    page.roleTitle:SetPoint("TOPLEFT", 18, -180)
    for index, button in ipairs(page.roleButtons or {}) do
        local column = (index - 1) % 2
        local roleRow = floor((index - 1) / 2)
        button:ClearAllPoints()
        button:SetWidth(158)
        button:SetPoint("TOPLEFT", 18 + column * 170, -204 - roleRow * 42)
        ApplyRoleButtonLayout(self, button)
    end

    page.membersTitle:ClearAllPoints()
    page.membersTitle:SetPoint("TOPLEFT", 18, -296)
    if page.members then page.members:Hide() end

    for index, row in ipairs(page.memberRows or {}) do
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 18, -320 - (index - 1) * 42)
        row:SetPoint("TOPRIGHT", -18, -320 - (index - 1) * 42)
        ApplyMemberRowLayout(row)
    end

    if page.memberPrev then
        page.memberPrev:ClearAllPoints()
        page.memberPrev:SetPoint("TOPRIGHT", -120, -292)
    end
    if page.memberPageLabel then
        page.memberPageLabel:ClearAllPoints()
        page.memberPageLabel:SetPoint("LEFT", page.memberPrev, "RIGHT", 5, 0)
    end
    if page.memberNext then
        page.memberNext:ClearAllPoints()
        page.memberNext:SetPoint("LEFT", page.memberPageLabel, "RIGHT", 5, 0)
    end
end

function GMG:RefreshDungeonFinderV179Visuals()
    local page = self.dungeonPage
    if not page then return end
    self:ApplyDungeonFinderV179Layout()
    self:InstallDungeonLeaderCreateGuard()
    self:RefreshDungeonCreateLeaderState()
    if page.members then page.members:Hide() end

    local activity = self:GetDungeonActivity(self.dungeonSelectedID)
    if not activity then return end

    -- Replace the two-line role status with a clean right-aligned count.
    for _, button in ipairs(page.roleButtons or {}) do
        if button:IsShown() and button.roleStatus then
            ApplyRoleButtonLayout(self, button)
            local used, cap = 0, 0
            if self.GetDungeonRoleUsage then used, cap = self:GetDungeonRoleUsage(activity, button.role) end
            used = tonumber(used) or 0
            cap = tonumber(cap) or 0
            button.roleStatus:SetText(used .. "/" .. cap)
            button.roleStatus:SetTextColor(unpack((cap <= 0 or used >= cap) and RED or GREEN))
            button.gmgTooltipHelp = self:L("DF_ROLE_COUNT_TOOLTIP", RoleLabel(self, button.role), used, cap)
        end
    end

    -- Member name and green status now use separate columns and can no longer overlap.
    local members = self.BuildDungeonFinderMemberList and self:BuildDungeonFinderMemberList(activity) or {}
    local perPage = #(page.memberRows or {})
    local offset = ((page.memberPage or 1) - 1) * perPage
    for index, row in ipairs(page.memberRows or {}) do
        ApplyMemberRowLayout(row)
        local entry = members[offset + index]
        if entry then
            row.name:SetText(entry.name or "")
            row.name:SetTextColor(unpack(TEXT))
            row.status:SetText(entry.inGroup and self:L("DF_MEMBER_IN_GROUP") or self:L("DF_MEMBER_ACCEPTED"))
            row.status:SetTextColor(unpack(entry.inGroup and GREEN or MUTED))
        end
    end
end

local PreviousCreateDungeonFinderPageV179 = GMG.CreateDungeonFinderPage
function GMG:CreateDungeonFinderPage(...)
    PreviousCreateDungeonFinderPageV179(self, ...)
    self:InstallDungeonLeaderCreateGuard()
    self:ApplyDungeonFinderV179Layout()
    self:RefreshDungeonCreateLeaderState()
end

local PreviousRefreshDungeonFinderV179 = GMG.RefreshDungeonFinder
function GMG:RefreshDungeonFinder(force)
    PreviousRefreshDungeonFinderV179(self, force)
    self:RefreshDungeonFinderV179Visuals()
end

local PreviousRefreshLocalizationV179 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    PreviousRefreshLocalizationV179(self, ...)
    self:RefreshDungeonFinderV179Visuals()
end

local PreviousCreateUIV179 = GMG.CreateUI
function GMG:CreateUI(...)
    PreviousCreateUIV179(self, ...)
    self:RefreshDungeonFinderV179Visuals()
end
