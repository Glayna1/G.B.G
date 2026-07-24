-- G.B.G (Glayna Better Guild)
-- v1.5.1 - unread guild-message badge and persistent mention glow

local GMG = GlaynaBetterGuild
if not GMG then return end

local floor = math.floor
local max = math.max
local min = math.min
local sin = math.sin
local strlower = string.lower
local unpack = unpack

local EN = {
    UNREAD_GUILD_MESSAGES = "%d unread guild message(s)",
    UNREAD_GUILD_MESSAGES_SHORT = "%d unread",
    UNREAD_MENTION = "Your name was mentioned in guild chat.",
}
local FR = {
    UNREAD_GUILD_MESSAGES = "%d message(s) de guilde non lu(s)",
    UNREAD_GUILD_MESSAGES_SHORT = "%d non lu(s)",
    UNREAD_MENTION = "Votre pseudo a été mentionné dans la messagerie de guilde.",
}
GMG.Locales = GMG.Locales or { en = {}, fr = {} }
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end

local function SetBackdrop(frame, background, border)
    if not frame or not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(background))
    frame:SetBackdropBorderColor(unpack(border))
end

function GMG:GetUnreadGuildState(create)
    local store = self:GetGuildStore(create)
    if not store then return nil end
    if store.unreadGuildMessages == nil then store.unreadGuildMessages = 0 end
    if store.unreadGuildMention == nil then store.unreadGuildMention = false end
    return store
end

function GMG:IsGuildChatVisible()
    return self.mainFrame and self.mainFrame:IsShown() and self.chatPage and self.chatPage:IsShown()
end

function GMG:GetUnreadGuildCount()
    local store = self:GetUnreadGuildState(false)
    return store and max(0, tonumber(store.unreadGuildMessages) or 0) or 0
end

function GMG:MarkGuildChatRead()
    local store = self:GetUnreadGuildState(false)
    if not store then return end
    if (tonumber(store.unreadGuildMessages) or 0) == 0 and not store.unreadGuildMention then return end
    store.unreadGuildMessages = 0
    store.unreadGuildMention = false
    if self.PersistSettings then self:PersistSettings() end
    self:RefreshUnreadGuildIndicators()
end

function GMG:AddUnreadGuildMessage(isMention)
    local store = self:GetUnreadGuildState(true)
    if not store then return end
    store.unreadGuildMessages = min(999, (tonumber(store.unreadGuildMessages) or 0) + 1)
    if isMention then store.unreadGuildMention = true end
    if self.PersistSettings then self:PersistSettings() end
    self:RefreshUnreadGuildIndicators()
end

local function CreateBadge(parent, point, relative, relativePoint, x, y)
    local badge = CreateFrame("Frame", nil, parent)
    badge:SetWidth(30)
    badge:SetHeight(19)
    badge:SetPoint(point, relative, relativePoint, x, y)
    badge:SetFrameLevel((parent:GetFrameLevel() or 1) + 5)
    SetBackdrop(badge, { 0.70, 0.06, 0.10, 0.98 }, { 1.00, 0.32, 0.38, 1 })
    badge.text = badge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    badge.text:SetPoint("CENTER", 0, 0)
    badge.text:SetTextColor(1, 1, 1, 1)
    badge:Hide()
    return badge
end

local function CreateGlow(parent)
    local glow = CreateFrame("Frame", nil, parent)
    glow:SetPoint("TOPLEFT", -3, 3)
    glow:SetPoint("BOTTOMRIGHT", 3, -3)
    glow:SetFrameLevel((parent:GetFrameLevel() or 1) + 2)
    glow:EnableMouse(false)
    SetBackdrop(glow, { 0, 0, 0, 0 }, { 0.18, 1.00, 0.42, 1 })
    glow:SetAlpha(0)
    glow:Hide()
    glow:SetScript("OnUpdate", function(self)
        local store = GMG:GetUnreadGuildState(false)
        if not store or not store.unreadGuildMention or not (GMG.db and GMG.db.profile and GMG.db.profile.mentionUnreadGlow ~= false) then self:Hide(); self:SetAlpha(0); return end
        local now = GetTime and GetTime() or 0
        self:SetAlpha(0.35 + 0.65 * ((sin(now * 5.5) + 1) / 2))
    end)
    return glow
end

function GMG:EnsureLauncherUnreadIndicators()
    if not self.launcher then return end
    if not self.launcher.unreadBadge then
        self.launcher.unreadBadge = CreateBadge(self.launcher, "TOPRIGHT", self.launcher, "TOPRIGHT", 5, 7)
    end
    if not self.launcher.mentionGlow then
        self.launcher.mentionGlow = CreateGlow(self.launcher)
    end
end

function GMG:CreateUnreadGuildIndicators()
    self:EnsureLauncherUnreadIndicators()
    if not self.mainFrame or self.unreadIndicatorsCreated then
        self:RefreshUnreadGuildIndicators()
        return
    end
    local tab = self.mainFrame.tabs and self.mainFrame.tabs.chat
    if tab then
        tab.unreadBadge = CreateBadge(tab, "RIGHT", tab, "RIGHT", -8, 0)
        tab.mentionGlow = CreateGlow(tab)
        tab:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(0.58, 0.34, 0.92, 1)
            local count = GMG:GetUnreadGuildCount()
            if count > 0 then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(GMG:L("UNREAD_GUILD_MESSAGES", count), 1, 1, 1)
                local store = GMG:GetUnreadGuildState(false)
                if store and store.unreadGuildMention then GameTooltip:AddLine(GMG:L("UNREAD_MENTION"), 0.75, 0.45, 1, true) end
                GameTooltip:Show()
            end
        end)
        tab:SetScript("OnLeave", function(self)
            if not self.selected then self:SetBackdropBorderColor(0.17, 0.17, 0.27, 1) end
            GameTooltip:Hide()
        end)
    end
    self:EnsureLauncherUnreadIndicators()
    self.unreadIndicatorsCreated = true
    self:RefreshUnreadGuildIndicators()
end

function GMG:RefreshUnreadGuildIndicators()
    self:EnsureLauncherUnreadIndicators()
    if not self.unreadIndicatorsCreated and not (self.launcher and self.launcher.unreadBadge) then return end
    local count = self:GetUnreadGuildCount()
    local display = count > 99 and "99+" or tostring(count)
    local store = self:GetUnreadGuildState(false)
    local mention = store and store.unreadGuildMention and self.db and self.db.profile and self.db.profile.mentionUnreadGlow ~= false

    local tab = self.mainFrame and self.mainFrame.tabs and self.mainFrame.tabs.chat
    if tab and tab.unreadBadge then
        if count > 0 then tab.unreadBadge.text:SetText(display); tab.unreadBadge:Show() else tab.unreadBadge:Hide() end
        if tab.mentionGlow then if mention then tab.mentionGlow:Show() else tab.mentionGlow:Hide(); tab.mentionGlow:SetAlpha(0) end end
    end
    if self.launcher and self.launcher.unreadBadge then
        if count > 0 then self.launcher.unreadBadge.text:SetText(display); self.launcher.unreadBadge:Show() else self.launcher.unreadBadge:Hide() end
        if self.launcher.mentionGlow then if mention then self.launcher.mentionGlow:Show() else self.launcher.mentionGlow:Hide(); self.launcher.mentionGlow:SetAlpha(0) end end
    end
end

local GMGCreateUIBeforeUnread = GMG.CreateUI
function GMG:CreateUI(...)
    GMGCreateUIBeforeUnread(self, ...)
    self:CreateUnreadGuildIndicators()
    if self:IsGuildChatVisible() then self:MarkGuildChatRead() end
end

local GMGShowTabBeforeUnread = GMG.ShowTab
function GMG:ShowTab(key, ...)
    GMGShowTabBeforeUnread(self, key, ...)
    if key == "chat" and self.mainFrame and self.mainFrame:IsShown() then self:MarkGuildChatRead() end
end

local GMGToggleBeforeUnread = GMG.Toggle
function GMG:Toggle(...)
    GMGToggleBeforeUnread(self, ...)
    if self:IsGuildChatVisible() then self:MarkGuildChatRead() end
    self:RefreshUnreadGuildIndicators()
end

local GMGChatMsgGuildBeforeUnread = GMG.CHAT_MSG_GUILD
function GMG:CHAT_MSG_GUILD(message, sender, ...)
    local senderName = self:NormalizeName(sender)
    local isOther = strlower(senderName or "") ~= strlower(self:GetPlayerName() or "")
    local mentioned = isOther and self:IsPlayerMentioned(message)
    GMGChatMsgGuildBeforeUnread(self, message, sender, ...)
    if isOther and not self:IsGuildChatVisible() then self:AddUnreadGuildMessage(mentioned) end
end

local GMGPlayerGuildUpdateBeforeUnread = GMG.PLAYER_GUILD_UPDATE
function GMG:PLAYER_GUILD_UPDATE(...)
    GMGPlayerGuildUpdateBeforeUnread(self, ...)
    self:RefreshUnreadGuildIndicators()
end

local GMGRefreshLocalizationBeforeUnread = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeUnread(self, ...)
    self:RefreshUnreadGuildIndicators()
end


-- v1.6.3: create the notification badge on the lightweight launcher even when
-- the full guild interface has not been opened yet.
local GMGPlayerLoginBeforeUnreadLauncherV163 = GMG.PLAYER_LOGIN
function GMG:PLAYER_LOGIN(...)
    if GMGPlayerLoginBeforeUnreadLauncherV163 then GMGPlayerLoginBeforeUnreadLauncherV163(self, ...) end
    if self.CreateLauncher then self:CreateLauncher() end
    self:EnsureLauncherUnreadIndicators()
    self:RefreshUnreadGuildIndicators()
end


-- v1.6.5: request a fresh guild roster while the main window is closed so
-- online and offline transitions remain reliable instead of depending solely
-- on server-pushed roster events.
local GMGOnUpdateBeforeReliableRosterV165 = GMG.OnUpdate
function GMG:OnUpdate(elapsed)
    GMGOnUpdateBeforeReliableRosterV165(self, elapsed)
    self.rosterNotificationPulse = (self.rosterNotificationPulse or 0) + elapsed
    if self.rosterNotificationPulse < 4 then return end
    self.rosterNotificationPulse = self.rosterNotificationPulse - 4
    if not self:IsInGuild() then return end
    if self.mainFrame and self.mainFrame:IsShown() then return end
    if GuildRoster then GuildRoster() end
    if self.Schedule then
        self:Schedule("reliable-roster-transition-v165", 0.65, function()
            if GMG:IsInGuild() and GMG.RebuildRosterCache then GMG:RebuildRosterCache(true) end
        end)
    end
end
