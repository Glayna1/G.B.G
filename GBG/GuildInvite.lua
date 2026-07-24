-- G.B.G (Glayna Better Guild)
-- Dedicated guild invitation page.

GlaynaBetterGuild = GlaynaBetterGuild or GlaynasMidnightGuild or {}
GlaynasMidnightGuild = GlaynaBetterGuild
local GMG = GlaynaBetterGuild

GMG.Locales = GMG.Locales or { en = {}, fr = {} }
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}

local EN = {
    GUILD_INVITE_TAB = "Guild Invite",
    GUILD_INVITE_TITLE = "Invite to the guild",
    GUILD_INVITE_INTRO = "Invite a player by entering their character name, or leave the field empty and target the player you want to invite.",
    GUILD_INVITE_MANUAL_TITLE = "Invite by character name",
    GUILD_INVITE_NAME = "Character name",
    GUILD_INVITE_NAME_PLACEHOLDER = "Enter the character name...",
    GUILD_INVITE_TARGET_TITLE = "Current target",
    GUILD_INVITE_NO_TARGET = "No valid player targeted.",
    GUILD_INVITE_TARGET_READY = "%s is ready to be invited.",
    GUILD_INVITE_TARGET_GUILD = "%s is already in the guild: %s.",
    GUILD_INVITE_USE_TARGET = "Use current target",
    GUILD_INVITE_CLEAR = "Clear",
    GUILD_INVITE_BUTTON = "Invite to the guild",
    GUILD_INVITE_BUTTON_HELP = "Uses the entered character name first. If the field is empty, the currently targeted player is invited.",
    GUILD_INVITE_SOURCE_MANUAL = "Invitation source: entered character name",
    GUILD_INVITE_SOURCE_TARGET = "Invitation source: current target",
    GUILD_INVITE_READY = "Enter a name or target a player to send a guild invitation.",
    GUILD_INVITE_SENT = "Guild invitation request sent to %s.",
    GUILD_INVITE_ERROR_TITLE = "Guild invitation unavailable",
    GUILD_INVITE_NOT_IN_GUILD = "You must be in a guild before you can invite another player.",
    GUILD_INVITE_NO_PERMISSION = "Your guild rank does not have permission to invite new members.",
    GUILD_INVITE_NO_NAME = "Enter a character name or target a valid player first.",
    GUILD_INVITE_INVALID_TARGET = "Your current target is not a valid player.",
    GUILD_INVITE_HOSTILE_TARGET = "You cannot invite a hostile player to your guild.",
    GUILD_INVITE_ALREADY_MEMBER = "%s is already a member of your guild.",
    GUILD_INVITE_ALREADY_GUILDED = "%s already belongs to the guild %s.",
    GUILD_INVITE_SELF = "You cannot invite your own character.",
    GUILD_INVITE_API_MISSING = "The guild invitation function is unavailable on this game client.",
    GUILD_INVITE_PERMISSION_STATUS = "Invitation permission: available",
    GUILD_INVITE_PERMISSION_BLOCKED = "Invitation permission: unavailable",
    GUILD_INVITE_TOOLTIP_TITLE = "Guild invitation",
    GUILD_INVITE_TOOLTIP_TEXT = "Open the dedicated page for inviting a targeted player or a character entered manually.",
}

local FR = {
    GUILD_INVITE_TAB = "Invitation",
    GUILD_INVITE_TITLE = "Inviter dans la guilde",
    GUILD_INVITE_INTRO = "Invitez un joueur en écrivant le nom de son personnage, ou laissez le champ vide et ciblez directement le joueur à inviter.",
    GUILD_INVITE_MANUAL_TITLE = "Invitation par pseudo",
    GUILD_INVITE_NAME = "Pseudo du personnage",
    GUILD_INVITE_NAME_PLACEHOLDER = "Écrivez le pseudo du personnage...",
    GUILD_INVITE_TARGET_TITLE = "Cible actuelle",
    GUILD_INVITE_NO_TARGET = "Aucun joueur valide n’est actuellement ciblé.",
    GUILD_INVITE_TARGET_READY = "%s peut être invité dans la guilde.",
    GUILD_INVITE_TARGET_GUILD = "%s appartient déjà à la guilde : %s.",
    GUILD_INVITE_USE_TARGET = "Utiliser la cible",
    GUILD_INVITE_CLEAR = "Effacer",
    GUILD_INVITE_BUTTON = "Inviter dans la guilde",
    GUILD_INVITE_BUTTON_HELP = "Utilise en priorité le pseudo écrit dans le champ. Si le champ est vide, le joueur actuellement ciblé est invité.",
    GUILD_INVITE_SOURCE_MANUAL = "Source de l’invitation : pseudo saisi",
    GUILD_INVITE_SOURCE_TARGET = "Source de l’invitation : cible actuelle",
    GUILD_INVITE_READY = "Écrivez un pseudo ou ciblez un joueur pour envoyer une invitation de guilde.",
    GUILD_INVITE_SENT = "Demande d’invitation de guilde envoyée à %s.",
    GUILD_INVITE_ERROR_TITLE = "Invitation de guilde impossible",
    GUILD_INVITE_NOT_IN_GUILD = "Vous devez appartenir à une guilde avant de pouvoir inviter un joueur.",
    GUILD_INVITE_NO_PERMISSION = "Votre rang de guilde ne possède pas le droit d’inviter de nouveaux membres.",
    GUILD_INVITE_NO_NAME = "Écrivez un pseudo ou ciblez d’abord un joueur valide.",
    GUILD_INVITE_INVALID_TARGET = "Votre cible actuelle n’est pas un joueur valide.",
    GUILD_INVITE_HOSTILE_TARGET = "Vous ne pouvez pas inviter un joueur hostile dans votre guilde.",
    GUILD_INVITE_ALREADY_MEMBER = "%s est déjà membre de votre guilde.",
    GUILD_INVITE_ALREADY_GUILDED = "%s appartient déjà à la guilde %s.",
    GUILD_INVITE_SELF = "Vous ne pouvez pas inviter votre propre personnage.",
    GUILD_INVITE_API_MISSING = "La fonction d’invitation de guilde n’est pas disponible sur ce client de jeu.",
    GUILD_INVITE_PERMISSION_STATUS = "Droit d’invitation : disponible",
    GUILD_INVITE_PERMISSION_BLOCKED = "Droit d’invitation : indisponible",
    GUILD_INVITE_TOOLTIP_TITLE = "Invitation de guilde",
    GUILD_INVITE_TOOLTIP_TEXT = "Ouvre la page dédiée permettant d’inviter la cible actuelle ou un personnage saisi manuellement.",
}

for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
}

local PANEL = {0.025, 0.030, 0.050, 0.98}
local PANEL_2 = {0.040, 0.047, 0.075, 0.98}
local BORDER = {0.18, 0.17, 0.30, 1}
local ACCENT = {0.58, 0.34, 0.94, 1}
local ACCENT_SOFT = {0.20, 0.10, 0.34, 0.96}
local TEXT = {0.88, 0.87, 0.94, 1}
local MUTED = {0.54, 0.56, 0.66, 1}
local GREEN = {0.27, 0.92, 0.48, 1}
local RED = {0.95, 0.34, 0.38, 1}

local function Trim(text)
    text = tostring(text or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function SetBackdrop(frame, color, border)
    frame:SetBackdrop(BACKDROP)
    frame:SetBackdropColor(unpack(color or PANEL))
    frame:SetBackdropBorderColor(unpack(border or BORDER))
end

local function Text(parent, fontObject, value, size)
    local text = parent:CreateFontString(nil, "ARTWORK", fontObject or "GameFontNormal")
    text:SetText(value or "")
    if size and text.SetFont then
        local path, _, flags = text:GetFont()
        if path then text:SetFont(path, size, flags) end
    end
    text:SetTextColor(unpack(TEXT))
    return text
end

local function Button(parent, label, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 180)
    button:SetHeight(height or 34)
    SetBackdrop(button, PANEL_2, BORDER)
    button.label = Text(button, "GameFontNormal", label or "", 12)
    button.label:SetPoint("CENTER", 0, 0)
    button.label:SetPoint("LEFT", 8, 0)
    button.label:SetPoint("RIGHT", -8, 0)
    button.label:SetJustifyH("CENTER")
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(ACCENT_SOFT))
        self:SetBackdropBorderColor(unpack(ACCENT))
    end)
    button:SetScript("OnLeave", function(self)
        if not self.selected then
            self:SetBackdropColor(unpack(PANEL_2))
            self:SetBackdropBorderColor(unpack(BORDER))
        end
        GameTooltip:Hide()
    end)
    return button
end

local function SetButtonSelected(button, selected)
    if not button then return end
    button.selected = selected and true or false
    if button.selected then
        button:SetBackdropColor(unpack(ACCENT_SOFT))
        button:SetBackdropBorderColor(unpack(ACCENT))
    else
        button:SetBackdropColor(unpack(PANEL_2))
        button:SetBackdropBorderColor(unpack(BORDER))
    end
end

local function SetButtonVisualEnabled(button, enabled)
    if not button then return end
    button.visualEnabled = enabled and true or false
    button:SetAlpha(enabled and 1 or 0.46)
end

local function FullName(unit)
    if not UnitExists or not UnitExists(unit) then return nil end
    local name, realm = UnitName(unit)
    if not name or name == "" then return nil end
    if realm and realm ~= "" then return name .. "-" .. realm end
    return name
end

function GMG:ShowGuildInviteError(message)
    StaticPopupDialogs = StaticPopupDialogs or {}
    if not StaticPopupDialogs.GBG_GUILD_INVITE_ERROR then
        StaticPopupDialogs.GBG_GUILD_INVITE_ERROR = {
            text = "%s",
            button1 = OKAY or "OK",
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
            preferredIndex = 3,
        }
    end
    StaticPopup_Show("GBG_GUILD_INVITE_ERROR", tostring(message or ""))
end

function GMG:CanUseGuildInvite()
    if not self:IsInGuild() then return false, self:L("GUILD_INVITE_NOT_IN_GUILD") end
    if CanGuildInvite and not CanGuildInvite() then return false, self:L("GUILD_INVITE_NO_PERMISSION") end
    if not GuildInvite then return false, self:L("GUILD_INVITE_API_MISSING") end
    return true
end

function GMG:GetGuildInviteTargetInfo()
    if not UnitExists or not UnitExists("target") or not UnitIsPlayer or not UnitIsPlayer("target") then
        return nil, self:L("GUILD_INVITE_INVALID_TARGET")
    end
    local name = FullName("target")
    if not name then return nil, self:L("GUILD_INVITE_INVALID_TARGET") end
    if UnitIsUnit and UnitIsUnit("target", "player") then return nil, self:L("GUILD_INVITE_SELF") end
    if UnitCanCooperate and not UnitCanCooperate("player", "target") then
        return nil, self:L("GUILD_INVITE_HOSTILE_TARGET")
    end
    local guildName = GetGuildInfo and GetGuildInfo("target") or nil
    if guildName and guildName ~= "" then
        local ownGuild = GetGuildInfo and GetGuildInfo("player") or nil
        if ownGuild and guildName == ownGuild then
            return nil, self:L("GUILD_INVITE_ALREADY_MEMBER", name), name, guildName
        end
        return nil, self:L("GUILD_INVITE_ALREADY_GUILDED", name, guildName), name, guildName
    end
    return name
end

function GMG:ResolveGuildInviteName()
    local page = self.guildInvitePage
    local typed = page and page.nameInput and Trim(page.nameInput:GetText()) or ""
    if typed ~= "" then
        if strlower and strlower(typed) == strlower(self:GetPlayerName() or "") then
            return nil, self:L("GUILD_INVITE_SELF")
        end
        return typed, nil, "manual"
    end
    local targetName, errorMessage = self:GetGuildInviteTargetInfo()
    if not targetName then return nil, errorMessage or self:L("GUILD_INVITE_NO_NAME") end
    return targetName, nil, "target"
end

function GMG:InvitePlayerToGuild()
    local allowed, reason = self:CanUseGuildInvite()
    if not allowed then
        self:ShowGuildInviteError(reason)
        self:RefreshGuildInvitePage()
        return false
    end

    local name, errorMessage, source = self:ResolveGuildInviteName()
    if not name or name == "" then
        self:ShowGuildInviteError(errorMessage or self:L("GUILD_INVITE_NO_NAME"))
        self:RefreshGuildInvitePage()
        return false
    end

    GuildInvite(name)
    if self.guildInvitePage then
        self.guildInvitePage.status:SetText(self:L("GUILD_INVITE_SENT", name))
        self.guildInvitePage.status:SetTextColor(unpack(GREEN))
        self.guildInvitePage.source:SetText(self:L(source == "manual" and "GUILD_INVITE_SOURCE_MANUAL" or "GUILD_INVITE_SOURCE_TARGET"))
    end
    if self.Print then self:Print(self:L("GUILD_INVITE_SENT", name)) end
    return true
end

function GMG:CreateGuildInvitePage()
    if not self.mainFrame or self.guildInvitePage then return end

    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()
    page:Hide()
    self.guildInvitePage = page

    page.title = Text(page, "GameFontNormalLarge", self:L("GUILD_INVITE_TITLE"), 21)
    page.title:SetPoint("TOPLEFT", 24, -22)
    page.title:SetTextColor(1, 1, 1, 1)

    page.intro = Text(page, "GameFontNormal", self:L("GUILD_INVITE_INTRO"), 12)
    page.intro:SetPoint("TOPLEFT", 24, -58)
    page.intro:SetPoint("TOPRIGHT", -24, -58)
    page.intro:SetHeight(42)
    page.intro:SetJustifyH("LEFT")
    page.intro:SetJustifyV("TOP")
    page.intro:SetTextColor(unpack(MUTED))
    if page.intro.SetWordWrap then page.intro:SetWordWrap(true) end

    page.manualPanel = CreateFrame("Frame", nil, page)
    page.manualPanel:SetPoint("TOPLEFT", 24, -112)
    page.manualPanel:SetPoint("TOPRIGHT", -24, -112)
    page.manualPanel:SetHeight(170)
    SetBackdrop(page.manualPanel, PANEL, BORDER)

    page.manualTitle = Text(page.manualPanel, "GameFontNormal", self:L("GUILD_INVITE_MANUAL_TITLE"), 15)
    page.manualTitle:SetPoint("TOPLEFT", 20, -18)
    page.manualTitle:SetTextColor(1, 1, 1, 1)

    page.nameLabel = Text(page.manualPanel, "GameFontNormalSmall", self:L("GUILD_INVITE_NAME"), 11)
    page.nameLabel:SetPoint("TOPLEFT", 20, -52)
    page.nameLabel:SetTextColor(unpack(MUTED))

    page.inputHolder = CreateFrame("Frame", nil, page.manualPanel)
    page.inputHolder:SetPoint("TOPLEFT", 20, -74)
    page.inputHolder:SetPoint("TOPRIGHT", -210, -74)
    page.inputHolder:SetHeight(38)
    SetBackdrop(page.inputHolder, PANEL_2, BORDER)

    page.nameInput = CreateFrame("EditBox", nil, page.inputHolder)
    page.nameInput:SetPoint("TOPLEFT", 12, -7)
    page.nameInput:SetPoint("BOTTOMRIGHT", -12, 7)
    page.nameInput:SetAutoFocus(false)
    page.nameInput:SetFontObject("ChatFontNormal")
    page.nameInput:SetTextColor(unpack(TEXT))
    page.nameInput:SetMaxLetters(60)

    page.placeholder = Text(page.inputHolder, "GameFontNormalSmall", self:L("GUILD_INVITE_NAME_PLACEHOLDER"), 11)
    page.placeholder:SetPoint("LEFT", 12, 0)
    page.placeholder:SetTextColor(unpack(MUTED))

    page.clear = Button(page.manualPanel, self:L("GUILD_INVITE_CLEAR"), 160, 38)
    page.clear:SetPoint("TOPRIGHT", -20, -74)
    page.clear:SetScript("OnClick", function()
        page.nameInput:SetText("")
        page.nameInput:SetFocus()
        GMG:RefreshGuildInvitePage()
    end)

    page.nameInput:SetScript("OnTextChanged", function(self)
        if Trim(self:GetText()) == "" then page.placeholder:Show() else page.placeholder:Hide() end
        GMG:RefreshGuildInvitePage()
    end)
    page.nameInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        GMG:InvitePlayerToGuild()
    end)
    page.nameInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    page.targetPanel = CreateFrame("Frame", nil, page)
    page.targetPanel:SetPoint("TOPLEFT", 24, -298)
    page.targetPanel:SetPoint("TOPRIGHT", -24, -298)
    page.targetPanel:SetHeight(180)
    SetBackdrop(page.targetPanel, PANEL, BORDER)

    page.targetIcon = page.targetPanel:CreateTexture(nil, "ARTWORK")
    page.targetIcon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
    page.targetIcon:SetWidth(58)
    page.targetIcon:SetHeight(58)
    page.targetIcon:SetPoint("TOPLEFT", 20, -52)

    page.targetTitle = Text(page.targetPanel, "GameFontNormal", self:L("GUILD_INVITE_TARGET_TITLE"), 15)
    page.targetTitle:SetPoint("TOPLEFT", 20, -18)
    page.targetTitle:SetTextColor(1, 1, 1, 1)

    page.targetName = Text(page.targetPanel, "GameFontNormalLarge", self:L("GUILD_INVITE_NO_TARGET"), 17)
    page.targetName:SetPoint("TOPLEFT", 96, -52)
    page.targetName:SetPoint("TOPRIGHT", -210, -52)
    page.targetName:SetJustifyH("LEFT")

    page.targetInfo = Text(page.targetPanel, "GameFontNormalSmall", "", 11)
    page.targetInfo:SetPoint("TOPLEFT", 96, -82)
    page.targetInfo:SetPoint("TOPRIGHT", -210, -82)
    page.targetInfo:SetHeight(46)
    page.targetInfo:SetJustifyH("LEFT")
    page.targetInfo:SetJustifyV("TOP")
    page.targetInfo:SetTextColor(unpack(MUTED))
    if page.targetInfo.SetWordWrap then page.targetInfo:SetWordWrap(true) end

    page.useTarget = Button(page.targetPanel, self:L("GUILD_INVITE_USE_TARGET"), 170, 38)
    page.useTarget:SetPoint("TOPRIGHT", -20, -56)
    page.useTarget:SetScript("OnClick", function()
        local name, errorMessage = GMG:GetGuildInviteTargetInfo()
        if not name then
            GMG:ShowGuildInviteError(errorMessage or GMG:L("GUILD_INVITE_INVALID_TARGET"))
            return
        end
        page.nameInput:SetText(name)
        page.nameInput:ClearFocus()
        GMG:RefreshGuildInvitePage()
    end)

    page.permission = Text(page, "GameFontNormalSmall", "", 11)
    page.permission:SetPoint("TOPLEFT", 30, -504)

    page.source = Text(page, "GameFontNormalSmall", "", 11)
    page.source:SetPoint("TOPRIGHT", -30, -504)
    page.source:SetJustifyH("RIGHT")
    page.source:SetTextColor(unpack(MUTED))

    page.invite = Button(page, self:L("GUILD_INVITE_BUTTON"), 340, 46)
    page.invite:SetPoint("TOP", 0, -542)
    page.invite:SetScript("OnClick", function() GMG:InvitePlayerToGuild() end)
    page.invite:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(ACCENT_SOFT))
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L("GUILD_INVITE_BUTTON"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("GUILD_INVITE_BUTTON_HELP"), 0.75, 0.78, 0.88, true)
        GameTooltip:Show()
    end)
    page.invite:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(PANEL_2))
        self:SetBackdropBorderColor(unpack(BORDER))
        GameTooltip:Hide()
    end)

    page.status = Text(page, "GameFontNormal", self:L("GUILD_INVITE_READY"), 12)
    page.status:SetPoint("TOPLEFT", 50, -604)
    page.status:SetPoint("TOPRIGHT", -50, -604)
    page.status:SetHeight(50)
    page.status:SetJustifyH("CENTER")
    page.status:SetJustifyV("TOP")
    page.status:SetTextColor(unpack(MUTED))
    if page.status.SetWordWrap then page.status:SetWordWrap(true) end

    page.elapsed = 0
    page:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.25 then
            self.elapsed = 0
            GMG:RefreshGuildInvitePage()
        end
    end)

    self:RefreshGuildInvitePage()
end

function GMG:InstallGuildInviteTab()
    if not self.mainFrame or not self.mainFrame.sidebar or self.mainFrame.tabs.guildinvite then return end
    local tab = Button(self.mainFrame.sidebar, self:L("GUILD_INVITE_TAB"), 154, 38)
    tab:SetPoint("TOPLEFT", 18, -48 - 4 * 46)
    tab.localeKey = "GUILD_INVITE_TAB"
    tab:SetScript("OnClick", function() GMG:ShowTab("guildinvite") end)
    tab:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(ACCENT_SOFT))
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L("GUILD_INVITE_TOOLTIP_TITLE"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("GUILD_INVITE_TOOLTIP_TEXT"), 0.75, 0.78, 0.88, true)
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function(self)
        if GMG.db.profile.lastTab ~= "guildinvite" then
            self:SetBackdropColor(unpack(PANEL_2))
            self:SetBackdropBorderColor(unpack(BORDER))
        end
        GameTooltip:Hide()
    end)
    self.mainFrame.tabs.guildinvite = tab
end

function GMG:RefreshGuildInvitePage()
    local page = self.guildInvitePage
    if not page then return end

    local allowed, reason = self:CanUseGuildInvite()
    if allowed then
        page.permission:SetText(self:L("GUILD_INVITE_PERMISSION_STATUS"))
        page.permission:SetTextColor(unpack(GREEN))
    else
        page.permission:SetText(self:L("GUILD_INVITE_PERMISSION_BLOCKED"))
        page.permission:SetTextColor(unpack(RED))
    end

    local targetName, targetError, rawName, guildName = self:GetGuildInviteTargetInfo()
    if targetName then
        page.targetName:SetText(targetName)
        page.targetName:SetTextColor(1, 1, 1, 1)
        page.targetInfo:SetText(self:L("GUILD_INVITE_TARGET_READY", targetName))
        page.targetInfo:SetTextColor(unpack(GREEN))
        page.useTarget:SetAlpha(1)
    else
        local visibleName = rawName or FullName("target")
        if visibleName and guildName then
            page.targetName:SetText(visibleName)
            page.targetInfo:SetText(self:L("GUILD_INVITE_TARGET_GUILD", visibleName, guildName))
        elseif visibleName then
            page.targetName:SetText(visibleName)
            page.targetInfo:SetText(targetError or self:L("GUILD_INVITE_INVALID_TARGET"))
        else
            page.targetName:SetText(self:L("GUILD_INVITE_NO_TARGET"))
            page.targetInfo:SetText("")
        end
        page.targetName:SetTextColor(unpack(MUTED))
        page.targetInfo:SetTextColor(unpack(RED))
        page.useTarget:SetAlpha(0.46)
    end

    local typed = Trim(page.nameInput:GetText())
    if typed ~= "" then
        page.source:SetText(self:L("GUILD_INVITE_SOURCE_MANUAL"))
    elseif targetName then
        page.source:SetText(self:L("GUILD_INVITE_SOURCE_TARGET"))
    else
        page.source:SetText("")
    end

    SetButtonVisualEnabled(page.invite, allowed and (typed ~= "" or targetName ~= nil))
end

function GMG:RefreshGuildInviteLocalization()
    local page = self.guildInvitePage
    if not page then return end
    page.title:SetText(self:L("GUILD_INVITE_TITLE"))
    page.intro:SetText(self:L("GUILD_INVITE_INTRO"))
    page.manualTitle:SetText(self:L("GUILD_INVITE_MANUAL_TITLE"))
    page.nameLabel:SetText(self:L("GUILD_INVITE_NAME"))
    page.placeholder:SetText(self:L("GUILD_INVITE_NAME_PLACEHOLDER"))
    page.targetTitle:SetText(self:L("GUILD_INVITE_TARGET_TITLE"))
    page.clear.label:SetText(self:L("GUILD_INVITE_CLEAR"))
    page.useTarget.label:SetText(self:L("GUILD_INVITE_USE_TARGET"))
    page.invite.label:SetText(self:L("GUILD_INVITE_BUTTON"))
    if Trim(page.nameInput:GetText()) == "" then page.placeholder:Show() else page.placeholder:Hide() end
    self:RefreshGuildInvitePage()
end

local PreviousCreateUI = GMG.CreateUI
function GMG:CreateUI(...)
    local wanted = self.db and self.db.profile and self.db.profile.lastTab
    PreviousCreateUI(self, ...)
    self:CreateGuildInvitePage()
    self:InstallGuildInviteTab()
    if wanted == "guildinvite" then self:ShowTab("guildinvite") end
end

local PreviousShowTab = GMG.ShowTab
function GMG:ShowTab(key, ...)
    if key == "guildinvite" and self.guildInvitePage then
        if self.chatPage then self.chatPage:Hide() end
        if self.rosterPage then self.rosterPage:Hide() end
        if self.guildPage then self.guildPage:Hide() end
        if self.settingsPage then self.settingsPage:Hide() end
        if self.dungeonPage then self.dungeonPage:Hide() end
        self.guildInvitePage:Show()
        if self.db and self.db.profile then
            self.db.profile.lastTab = "guildinvite"
            if self.PersistSettings then self:PersistSettings() end
        end
        if self.RefreshDungeonTabSelection then
            self:RefreshDungeonTabSelection("guildinvite")
        else
            for tabKey, tab in pairs(self.mainFrame.tabs or {}) do SetButtonSelected(tab, tabKey == "guildinvite") end
        end
        self:RefreshGuildInvitePage()
        return
    end
    PreviousShowTab(self, key, ...)
    if self.guildInvitePage then self.guildInvitePage:Hide() end
end

local PreviousRefreshLocalization = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    PreviousRefreshLocalization(self, ...)
    if self.mainFrame and self.mainFrame.tabs and self.mainFrame.tabs.guildinvite then
        self.mainFrame.tabs.guildinvite.label:SetText(self:L("GUILD_INVITE_TAB"))
    end
    self:RefreshGuildInviteLocalization()
end

local PreviousRefreshDynamicUI = GMG.RefreshDynamicUI
function GMG:RefreshDynamicUI(...)
    PreviousRefreshDynamicUI(self, ...)
    if self.mainFrame and self.mainFrame:IsShown() and self.guildInvitePage and self.guildInvitePage:IsShown() then
        self:RefreshGuildInvitePage()
    end
end
