-- G.B.G (Glayna Better Guild)
-- Midnight / The War Within inspired interface for WoW 3.3.5a

local GMG = GlaynaBetterGuild
local floor = math.floor
local max = math.max
local min = math.min
local sort = table.sort
local strlower = string.lower
local tostring = tostring
local format = string.format
local date = date
local time = time

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local PANEL_BG = {0.025, 0.031, 0.052, 0.99}
local PANEL_2 = {0.045, 0.052, 0.082, 0.99}
local PANEL_3 = {0.075, 0.082, 0.125, 0.98}
local PANEL_4 = {0.105, 0.112, 0.165, 0.98}
local BORDER = {0.24, 0.22, 0.38, 1}
local ACCENT = {0.60, 0.42, 1.00, 1}
local ACCENT_SOFT = {0.30, 0.19, 0.52, 0.95}
local TEXT = {0.88, 0.90, 0.96, 1}
local MUTED = {0.48, 0.52, 0.64, 1}
local GREEN = {0.25, 0.90, 0.55, 1}
local RED = {0.95, 0.34, 0.42, 1}
local GOLD = {1.00, 0.76, 0.28, 1}

local function SetBackdrop(frame, background, border)
    frame:SetBackdrop(BACKDROP)
    frame:SetBackdropColor(unpack(background or PANEL_BG))
    frame:SetBackdropBorderColor(unpack(border or BORDER))
end

local function CreateText(parent, fontObject, text, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObject or "GameFontNormal")
    if size then
        local font, _, flags = fs:GetFont()
        fs:SetFont(font, size, flags)
    end
    fs:SetText(text or "")
    fs:SetTextColor(unpack(TEXT))
    if fs.SetNonSpaceWrap then fs:SetNonSpaceWrap(false) end
    return fs
end

local function SetOneLine(fontString, width)
    if width then fontString:SetWidth(width) end
    if fontString.SetWordWrap then fontString:SetWordWrap(false) end
    if fontString.SetNonSpaceWrap then fontString:SetNonSpaceWrap(false) end
end

local function SetBoundedText(fontString, text, width)
    text = tostring(text or "")
    SetOneLine(fontString, width)
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

local function CreateFlatButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 120)
    button:SetHeight(height or 30)
    SetBackdrop(button, PANEL_3, BORDER)
    button.label = CreateText(button, "GameFontNormal", text or "", 12)
    button.label:SetPoint("LEFT", 6, 0)
    button.label:SetPoint("RIGHT", -6, 0)
    button.label:SetJustifyH("CENTER")
    SetBoundedText(button.label, text or "", (width or 120) - 12)
    button:SetScript("OnEnter", function(self)
        if not self.disabled then
            self:SetBackdropColor(unpack(ACCENT_SOFT))
            self:SetBackdropBorderColor(unpack(ACCENT))
        end
    end)
    button:SetScript("OnLeave", function(self)
        if self.selected then
            self:SetBackdropColor(unpack(ACCENT_SOFT))
            self:SetBackdropBorderColor(unpack(ACCENT))
        else
            self:SetBackdropColor(unpack(PANEL_3))
            self:SetBackdropBorderColor(unpack(BORDER))
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

local function SetButtonSelected(button, selected)
    button.selected = selected and true or false
    if button.selected then
        button:SetBackdropColor(unpack(ACCENT_SOFT))
        button:SetBackdropBorderColor(unpack(ACCENT))
        button.label:SetTextColor(1, 1, 1, 1)
    else
        button:SetBackdropColor(unpack(PANEL_3))
        button:SetBackdropBorderColor(unpack(BORDER))
        button.label:SetTextColor(unpack(TEXT))
    end
end

local function CreateEditBox(parent, width, height, multiline)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width or 200)
    holder:SetHeight(height or 30)
    SetBackdrop(holder, PANEL_2, BORDER)
    local edit = CreateFrame("EditBox", nil, holder)
    edit:SetPoint("TOPLEFT", 10, -6)
    edit:SetPoint("BOTTOMRIGHT", -10, 6)
    edit:SetAutoFocus(false)
    edit:SetFontObject("ChatFontNormal")
    edit:SetTextColor(unpack(TEXT))
    edit:SetMaxLetters(multiline and 500 or 255)
    edit:SetMultiLine(multiline and true or false)
    holder.editBox = edit
    return holder, edit
end

local function CreateCheck(parent, label, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 300)
    button:SetHeight(24)
    button.box = CreateFrame("Frame", nil, button)
    button.box:SetWidth(18)
    button.box:SetHeight(18)
    button.box:SetPoint("LEFT", 0, 0)
    SetBackdrop(button.box, PANEL_2, BORDER)

    button.fill = button.box:CreateTexture(nil, "ARTWORK")
    button.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.fill:SetPoint("TOPLEFT", 4, -4)
    button.fill:SetPoint("BOTTOMRIGHT", -4, 4)
    button.fill:SetVertexColor(unpack(ACCENT))
    button.fill:Hide()
    button.mark = button.fill

    button.label = CreateText(button, "GameFontNormal", label or "", 12)
    button.label:SetPoint("LEFT", button.box, "RIGHT", 9, 0)
    button.label:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    button.label:SetJustifyH("LEFT")
    SetBoundedText(button.label, label or "", (width or 300) - 27)

    function button:SetChecked(value)
        self.checked = value and true or false
        if self.checked then
            self.fill:Show()
            self.box:SetBackdropColor(unpack(ACCENT_SOFT))
            self.box:SetBackdropBorderColor(unpack(ACCENT))
        else
            self.fill:Hide()
            self.box:SetBackdropColor(unpack(PANEL_2))
            self.box:SetBackdropBorderColor(unpack(BORDER))
        end
    end
    function button:GetChecked() return self.checked end
    button:SetChecked(false)
    button:SetScript("OnEnter", function(self)
        self.label:SetTextColor(1, 1, 1, 1)
        if self.checked then
            self.box:SetBackdropBorderColor(unpack(ACCENT))
        else
            self.box:SetBackdropBorderColor(0.72, 0.68, 0.96, 1)
        end
    end)
    button:SetScript("OnLeave", function(self)
        self.label:SetTextColor(unpack(TEXT))
        if self.checked then
            self.box:SetBackdropBorderColor(unpack(ACCENT))
        else
            self.box:SetBackdropBorderColor(unpack(BORDER))
        end
    end)
    return button
end

local function MakeDraggable(frame, handle)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    handle:EnableMouse(true)
    handle:RegisterForDrag("LeftButton")
    handle:SetScript("OnDragStart", function() frame:StartMoving() end)
    handle:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        GMG:SaveMainPosition()
    end)
end

function GMG:SaveMainPosition()
    if not self.mainFrame then return end
    local point, _, relativePoint, x, y = self.mainFrame:GetPoint(1)
    self.db.profile.mainPoint = point or "CENTER"
    self.db.profile.mainRelativePoint = relativePoint or "CENTER"
    self.db.profile.mainX = floor(x or 0)
    self.db.profile.mainY = floor(y or 0)
    self.db.profile.mainWidth = floor(self.mainFrame:GetWidth())
    self.db.profile.mainHeight = floor(self.mainFrame:GetHeight())
    if self.PersistSettings then self:PersistSettings() end
end

function GMG:SaveLauncherPosition()
    if not self.launcher then return end
    local point, _, relativePoint, x, y = self.launcher:GetPoint(1)
    self.db.profile.launcherPoint = point or "LEFT"
    self.db.profile.launcherRelativePoint = relativePoint or "LEFT"
    self.db.profile.launcherX = floor(x or 0)
    self.db.profile.launcherY = floor(y or 0)
    if self.PersistSettings then self:PersistSettings() end
end

function GMG:CreateToast()
    local toast = CreateFrame("Frame", "GlaynaBetterGuildToast", UIParent)
    toast:SetWidth(480)
    toast:SetHeight(66)
    toast:SetPoint("TOP", UIParent, "TOP", 0, -105)
    toast:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(toast, PANEL_2, ACCENT)
    toast.icon = toast:CreateTexture(nil, "ARTWORK")
    toast.icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
    toast.icon:SetWidth(42)
    toast.icon:SetHeight(42)
    toast.icon:SetPoint("LEFT", 13, 0)
    toast.text = CreateText(toast, "GameFontNormalLarge", "", 17)
    toast.text:SetPoint("LEFT", toast.icon, "RIGHT", 14, 0)
    toast.text:SetPoint("RIGHT", -16, 0)
    toast.text:SetJustifyH("LEFT")
    toast:Hide()
    self.toast = toast
    self.toastQueue = {}
end

function GMG:ShowToast(text, super)
    self.toastQueue = self.toastQueue or {}
    table.insert(self.toastQueue, { text = text, super = super and true or false })
    if not self.toastActive then self:StartNextToast() end
end

function GMG:StartNextToast()
    if not self.toast or not self.toastQueue or #self.toastQueue == 0 then
        self.toastActive = nil
        if self.toast then self.toast:Hide() end
        return
    end
    local data = table.remove(self.toastQueue, 1)
    self.toastActive = data
    self.toastElapsed = 0
    self.toast:SetAlpha(0)
    self.toast:SetHeight(data.super and 82 or 66)
    self.toast:SetWidth(data.super and 590 or 480)
    local toastFont = self.toast.text:GetFont()
    self.toast.text:SetFont(toastFont, data.super and 22 or 17, "OUTLINE")
    SetBoundedText(self.toast.text, data.text, data.super and 510 or 400)
    self.toast.icon:SetTexture(data.super and "Interface\\Icons\\Spell_Holy_InnerFire" or "Interface\\Icons\\INV_Misc_GroupNeedMore")
    if data.super then
        self.toast:SetBackdropColor(0.12, 0.055, 0.22, 0.99)
        self.toast:SetBackdropBorderColor(0.82, 0.52, 1, 1)
        self.toast.text:SetTextColor(1, 0.86, 1, 1)
        if PlaySound then PlaySound("RaidWarning") end
    else
        self.toast:SetBackdropColor(unpack(PANEL_2))
        self.toast:SetBackdropBorderColor(unpack(ACCENT))
        self.toast.text:SetTextColor(unpack(TEXT))
        if PlaySound then PlaySound("FriendJoinGame") end
    end
    self.toast:Show()
end

function GMG:UpdateToast(elapsed)
    if not self.toastActive or not self.toast then return end
    self.toastElapsed = (self.toastElapsed or 0) + elapsed
    local alpha = 1
    if self.toastElapsed < 0.22 then alpha = self.toastElapsed / 0.22 end
    if self.toastElapsed > 3.7 then alpha = max(0, (4.2 - self.toastElapsed) / 0.5) end
    self.toast:SetAlpha(alpha)
    if self.toastElapsed >= 4.2 then
        self.toast:Hide()
        self.toastActive = nil
        self:StartNextToast()
    end
end

function GMG:CreateMentionFlash()
    local frame = CreateFrame("Frame", "GlaynaBetterGuildMentionFlash", UIParent)
    frame:SetAllPoints(UIParent)
    frame:SetFrameStrata("FULLSCREEN")
    frame:EnableMouse(false)
    frame.texture = frame:CreateTexture(nil, "BACKGROUND")
    frame.texture:SetAllPoints(frame)
    frame.texture:SetTexture(0.15, 1.00, 0.42, 1)
    frame:SetAlpha(0)
    frame:Hide()
    self.mentionFlashFrame = frame
end

function GMG:ShowMentionFlash()
    if not self.db or not self.db.profile.mentionFlash or not self.mentionFlashFrame then return end
    self.mentionFlashElapsed = 0
    self.mentionFlashActive = true
    self.mentionFlashFrame:SetAlpha(0)
    self.mentionFlashFrame:Show()
end

function GMG:UpdateMentionFlash(elapsed)
    if not self.mentionFlashActive or not self.mentionFlashFrame then return end
    self.mentionFlashElapsed = (self.mentionFlashElapsed or 0) + elapsed
    local duration = 0.72
    local peak = 0.16
    local alpha
    if self.mentionFlashElapsed <= peak then
        alpha = (self.mentionFlashElapsed / peak) * 0.42
    else
        alpha = max(0, ((duration - self.mentionFlashElapsed) / (duration - peak)) * 0.42)
    end
    self.mentionFlashFrame:SetAlpha(alpha)
    if self.mentionFlashElapsed >= duration then
        self.mentionFlashFrame:Hide()
        self.mentionFlashFrame:SetAlpha(0)
        self.mentionFlashActive = nil
    end
end

function GMG:CreateLauncher()
    if self.launcher then
        if self.db and self.db.profile and self.db.profile.launcherShown ~= false then
            self.launcher:Show()
        end
        return self.launcher
    end
    local launcher = CreateFrame("Button", "GlaynaBetterGuildLauncher", UIParent)
    launcher:SetWidth(122)
    launcher:SetHeight(36)
    launcher:SetFrameStrata("FULLSCREEN_DIALOG")
    launcher:SetClampedToScreen(true)
    launcher:SetToplevel(true)
    SetBackdrop(launcher, PANEL_2, ACCENT_SOFT)
    launcher.title = CreateText(launcher, "GameFontNormal", self:L("LAUNCHER"), 13)
    launcher.title:SetPoint("LEFT", 13, 1)
    SetOneLine(launcher.title, 72)
    launcher.count = CreateText(launcher, "GameFontNormalSmall", "0", 11)
    launcher.count:SetPoint("RIGHT", -12, 1)
    launcher.count:SetTextColor(unpack(GREEN))
    launcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    launcher:SetScript("OnClick", function(_, button) if button == "LeftButton" then GMG:Toggle() end end)
    launcher:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("G.B.G (Glayna Better Guild)", 0.75, 0.55, 1)
        GameTooltip:AddLine(GMG:L("LAUNCHER_OPEN"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("LAUNCHER_MOVE"), 0.65, 0.68, 0.78)
        GameTooltip:Show()
    end)
    launcher:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(ACCENT_SOFT))
        GameTooltip:Hide()
    end)
    launcher:SetMovable(true)
    launcher:RegisterForDrag("RightButton")
    launcher:SetScript("OnDragStart", function(self) self:StartMoving() end)
    launcher:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        GMG:SaveLauncherPosition()
    end)
    local profile = self.db.profile
    launcher:SetPoint(profile.launcherPoint or "LEFT", UIParent, profile.launcherRelativePoint or "LEFT", profile.launcherX or 0, profile.launcherY or 110)
    if profile.launcherShown == false then launcher:Hide() else launcher:Show() end
    self.launcher = launcher
end

function GMG:CreateMainFrame()
    local profile = self.db.profile
    local frame = CreateFrame("Frame", "GlaynaBetterGuildFrame", UIParent)
    frame:SetWidth(profile.mainWidth or 1040)
    frame:SetHeight(profile.mainHeight or 650)
    frame:SetPoint(profile.mainPoint or "CENTER", UIParent, profile.mainRelativePoint or "CENTER", profile.mainX or 0, profile.mainY or 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetResizable(true)
    frame:SetMinResize(1000, 600)
    SetBackdrop(frame, PANEL_BG, BORDER)
    frame:Hide()

    frame.header = CreateFrame("Frame", nil, frame)
    frame.header:SetPoint("TOPLEFT", 1, -1)
    frame.header:SetPoint("TOPRIGHT", -1, -1)
    frame.header:SetHeight(76)
    SetBackdrop(frame.header, PANEL_2, {0.16, 0.14, 0.28, 1})
    MakeDraggable(frame, frame.header)

    frame.guildImage = frame.header:CreateTexture(nil, "ARTWORK")
    frame.guildImage:SetWidth(54)
    frame.guildImage:SetHeight(54)
    frame.guildImage:SetPoint("LEFT", 14, 0)
    frame.guildImage:SetTexture(self:GetGuildImageTexture())

    frame.brand = CreateText(frame.header, "GameFontNormalSmall", self:L("BRAND"), 9)
    frame.brand:SetPoint("TOPLEFT", frame.guildImage, "TOPRIGHT", 8, -1)
    frame.brand:SetJustifyH("LEFT")
    frame.brand:SetTextColor(0.63, 0.52, 0.82, 1)
    SetOneLine(frame.brand, 650)

    frame.guildName = CreateText(frame.header, "GameFontNormalLarge", self:L("GUILD"), 25)
    frame.guildName:SetPoint("TOPLEFT", frame.guildImage, "TOPRIGHT", 8, -19)
    frame.guildName:SetJustifyH("LEFT")
    frame.guildName:SetTextColor(1, 1, 1, 1)
    SetOneLine(frame.guildName, 650)

    frame.onlineBadge = CreateFrame("Frame", nil, frame.header)
    frame.onlineBadge:SetWidth(132)
    frame.onlineBadge:SetHeight(30)
    frame.onlineBadge:SetPoint("RIGHT", -56, 0)
    SetBackdrop(frame.onlineBadge, PANEL_3, {0.15, 0.35, 0.27, 1})
    frame.onlineDot = frame.onlineBadge:CreateTexture(nil, "ARTWORK")
    frame.onlineDot:SetTexture(unpack(GREEN))
    frame.onlineDot:SetWidth(8)
    frame.onlineDot:SetHeight(8)
    frame.onlineDot:SetPoint("LEFT", 12, 0)
    frame.onlineText = CreateText(frame.onlineBadge, "GameFontNormalSmall", self:L("ONLINE", 0), 11)
    frame.onlineText:SetPoint("LEFT", frame.onlineDot, "RIGHT", 8, 0)
    SetOneLine(frame.onlineText, 92)

    frame.close = CreateFrame("Button", nil, frame.header)
    frame.close:SetWidth(30)
    frame.close:SetHeight(30)
    frame.close:SetPoint("TOPRIGHT", -12, -12)
    frame.close.text = CreateText(frame.close, "GameFontNormalLarge", "×", 21)
    frame.close.text:SetPoint("CENTER", 0, 1)
    frame.close.text:SetTextColor(unpack(MUTED))
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    frame.close:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 1, 1, 1) end)
    frame.close:SetScript("OnLeave", function(self) self.text:SetTextColor(unpack(MUTED)) end)

    frame.sidebar = CreateFrame("Frame", nil, frame)
    frame.sidebar:SetPoint("TOPLEFT", 1, -78)
    frame.sidebar:SetPoint("BOTTOMLEFT", 1, 1)
    frame.sidebar:SetWidth(190)
    SetBackdrop(frame.sidebar, {0.032, 0.038, 0.062, 0.99}, {0.12, 0.12, 0.20, 1})

    frame.sidebarTitle = CreateText(frame.sidebar, "GameFontNormalSmall", self:L("GUILD_SPACE"), 10)
    frame.sidebarTitle:SetPoint("TOPLEFT", 20, -21)
    frame.sidebarTitle:SetTextColor(unpack(MUTED))
    SetOneLine(frame.sidebarTitle, 154)

    frame.tabs = {}
    local tabDefs = {
        {"chat", "CHAT"},
        {"roster", "MEMBERS"},
        {"guild", "GUILD"},
    }
    for index, def in ipairs(tabDefs) do
        local key = def[1]
        local tab = CreateFlatButton(frame.sidebar, self:L(def[2]), 154, 38)
        tab:SetPoint("TOPLEFT", 18, -48 - (index - 1) * 46)
        tab.localeKey = def[2]
        tab:SetScript("OnClick", function() GMG:ShowTab(key) end)
        frame.tabs[key] = tab
    end

    frame.settingsButton = CreateFrame("Button", nil, frame.sidebar)
    frame.settingsButton:SetWidth(38)
    frame.settingsButton:SetHeight(38)
    frame.settingsButton:SetPoint("BOTTOMLEFT", 18, 18)
    SetBackdrop(frame.settingsButton, PANEL_3, BORDER)
    frame.settingsButton.icon = frame.settingsButton:CreateTexture(nil, "ARTWORK")
    frame.settingsButton.icon:SetTexture("Interface\\Icons\\Trade_Engineering")
    frame.settingsButton.icon:SetPoint("TOPLEFT", 5, -5)
    frame.settingsButton.icon:SetPoint("BOTTOMRIGHT", -5, 5)
    frame.settingsButton:SetScript("OnClick", function() GMG:ShowTab("settings") end)
    frame.settingsButton:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L("SETTINGS"), 1, 1, 1)
        GameTooltip:Show()
    end)
    frame.settingsButton:SetScript("OnLeave", function(self)
        if GMG.db.profile.lastTab ~= "settings" then self:SetBackdropBorderColor(unpack(BORDER)) end
        GameTooltip:Hide()
    end)

    frame.syncText = CreateText(frame.sidebar, "GameFontNormalSmall", self:L("SYNC_WAITING"), 10)
    frame.syncText:SetPoint("BOTTOMLEFT", 66, 45)
    frame.syncText:SetPoint("BOTTOMRIGHT", -12, 45)
    frame.syncText:SetHeight(34)
    frame.syncText:SetJustifyH("LEFT")
    frame.syncText:SetJustifyV("BOTTOM")
    frame.syncText:SetTextColor(unpack(MUTED))
    if frame.syncText.SetWordWrap then frame.syncText:SetWordWrap(true) end

    frame.versionText = CreateText(frame.sidebar, "GameFontNormalSmall", self:L("VERSION", self.version), 9)
    frame.versionText:SetPoint("BOTTOMLEFT", 66, 23)
    frame.versionText:SetPoint("BOTTOMRIGHT", -12, 23)
    frame.versionText:SetTextColor(0.35, 0.38, 0.48, 1)
    SetOneLine(frame.versionText, 112)

    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetPoint("TOPLEFT", 192, -78)
    frame.content:SetPoint("BOTTOMRIGHT", -1, 1)

    frame.resize = CreateFrame("Button", nil, frame)
    frame.resize:SetWidth(18)
    frame.resize:SetHeight(18)
    frame.resize:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.resize:RegisterForDrag("LeftButton")
    frame.resize:SetScript("OnDragStart", function() frame:StartSizing("BOTTOMRIGHT") end)
    frame.resize:SetScript("OnDragStop", function() frame:StopMovingOrSizing(); GMG:SaveMainPosition(); GMG:LayoutRosterRows() end)

    frame:SetScript("OnShow", function()
        GMG:RefreshGuildData()
        GMG:RefreshAll(true)
    end)
    self.mainFrame = frame
end

function GMG:CreateChatPage()
    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()

    page.title = CreateText(page, "GameFontNormalLarge", self:L("CHAT"), 20)
    page.title:SetPoint("TOPLEFT", 22, -20)
    SetOneLine(page.title, 600)

    page.history = CreateFrame("Frame", nil, page)
    page.history:SetPoint("TOPLEFT", 22, -58)
    page.history:SetPoint("BOTTOMRIGHT", -22, 66)
    SetBackdrop(page.history, PANEL_2, {0.12, 0.12, 0.20, 1})

    page.messages = CreateFrame("ScrollingMessageFrame", nil, page.history)
    page.messages:SetPoint("TOPLEFT", 14, -12)
    page.messages:SetPoint("BOTTOMRIGHT", -32, 12)
    page.messages:SetFontObject("ChatFontNormal")
    page.messages:SetJustifyH("LEFT")
    page.messages:SetFading(false)
    page.messages:SetMaxLines(1200)
    if page.messages.SetHyperlinksEnabled then page.messages:SetHyperlinksEnabled(true) end
    page.messages:SetScript("OnHyperlinkClick", function(_, link, _, button)
        local name = string.match(link or "", "^gmgplayer:(.+)$")
        if name then GMG:OpenChatMemberMenu(name, page.messages, button) end
    end)

    page.scroll = CreateFrame("Slider", nil, page.history, "UIPanelScrollBarTemplate")
    page.scroll:SetPoint("TOPRIGHT", -7, -20)
    page.scroll:SetPoint("BOTTOMRIGHT", -7, 20)
    -- UIPanelScrollBarTemplate installs an inherited OnValueChanged handler
    -- that calls SetVerticalScroll on its parent. The parent here is a normal
    -- frame, so replace that handler before the first SetValue call.
    page.scroll:SetScript("OnValueChanged", function(_, value)
        if value <= 0 then page.messages:ScrollToTop() else page.messages:ScrollToBottom() end
    end)
    page.scroll:SetMinMaxValues(0, 1)
    page.scroll:SetValueStep(1)
    page.scroll:SetValue(1)

    page.empty = CreateText(page.history, "GameFontNormal", self:L("NO_MESSAGES"), 13)
    page.empty:SetPoint("CENTER", 0, 0)
    page.empty:SetTextColor(unpack(MUTED))
    SetOneLine(page.empty, 620)

    page.inputHolder, page.input = CreateEditBox(page, 500, 38, false)
    page.inputHolder:SetPoint("BOTTOMLEFT", 22, 18)
    page.inputHolder:SetPoint("BOTTOMRIGHT", -132, 18)
    page.input.placeholder = CreateText(page.inputHolder, "GameFontNormal", self:L("TYPE_MESSAGE"), 12)
    page.input.placeholder:SetPoint("LEFT", 11, 0)
    page.input.placeholder:SetPoint("RIGHT", -11, 0)
    page.input.placeholder:SetJustifyH("LEFT")
    page.input.placeholder:SetTextColor(unpack(MUTED))
    page.input:SetScript("OnTextChanged", function(self) if self:GetText() == "" then self.placeholder:Show() else self.placeholder:Hide() end end)
    page.input:SetScript("OnEnterPressed", function(self)
        GMG:SendGuildChat(self:GetText())
        self:SetText("")
    end)
    page.input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    page.send = CreateFlatButton(page, self:L("SEND"), 100, 38)
    page.send:SetPoint("BOTTOMRIGHT", -22, 18)
    page.send:SetScript("OnClick", function()
        GMG:SendGuildChat(page.input:GetText())
        page.input:SetText("")
        page.input:SetFocus()
    end)

    page.menu = CreateFrame("Frame", "GlaynaBetterGuildChatMemberMenu", UIParent, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(page.menu, function(_, level) GMG:InitializeChatMemberMenu(level) end, "MENU")
    self.chatPage = page
end

function GMG:CreateRosterPage()
    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()
    page.rowHeight = 42

    page.title = CreateText(page, "GameFontNormalLarge", self:L("MEMBERS"), 20)
    page.title:SetPoint("TOPLEFT", 22, -20)

    page.searchHolder, page.search = CreateEditBox(page, 300, 32, false)
    page.searchHolder:SetPoint("TOPLEFT", 22, -52)
    page.search.placeholder = CreateText(page.searchHolder, "GameFontNormal", self:L("SEARCH_MEMBER"), 11)
    page.search.placeholder:SetPoint("LEFT", 10, 0)
    page.search.placeholder:SetTextColor(unpack(MUTED))
    page.search:SetScript("OnTextChanged", function(self)
        if self:GetText() == "" then self.placeholder:Show() else self.placeholder:Hide() end
        GMG.rosterDirty = true
    end)

    page.onlyOnline = CreateCheck(page, self:L("ONLINE_ONLY"), 190)
    page.onlyOnline:SetPoint("LEFT", page.searchHolder, "RIGHT", 18, 0)
    page.onlyOnline:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        GMG.rosterDirty = true
    end)

    page.list = CreateFrame("Frame", nil, page)
    page.list:SetPoint("TOPLEFT", 22, -94)
    page.list:SetPoint("BOTTOMLEFT", 22, 22)
    page.list:SetWidth(560)
    SetBackdrop(page.list, PANEL_2, {0.12, 0.12, 0.20, 1})

    page.header = CreateFrame("Frame", nil, page.list)
    page.header:SetPoint("TOPLEFT", 1, -1)
    page.header:SetPoint("TOPRIGHT", -1, -1)
    page.header:SetHeight(28)
    SetBackdrop(page.header, PANEL_3, {0.12, 0.12, 0.20, 1})
    page.nameHeader = CreateText(page.header, "GameFontNormalSmall", self:L("MEMBERS"), 10)
    page.nameHeader:SetPoint("LEFT", 48, 0)
    page.levelHeader = CreateText(page.header, "GameFontNormalSmall", self:L("LEVEL"), 10)
    page.levelHeader:SetPoint("LEFT", 250, 0)
    page.classHeader = CreateText(page.header, "GameFontNormalSmall", self:L("CLASS"), 10)
    page.classHeader:SetPoint("LEFT", 302, 0)
    page.zoneHeader = CreateText(page.header, "GameFontNormalSmall", self:L("ZONE"), 10)
    page.zoneHeader:SetPoint("LEFT", 408, 0)
    for _, fs in ipairs({page.nameHeader, page.levelHeader, page.classHeader, page.zoneHeader}) do fs:SetTextColor(unpack(MUTED)) end

    page.scroll = CreateFrame("ScrollFrame", "GlaynaBetterGuildRosterScroll", page.list, "FauxScrollFrameTemplate")
    page.scroll:SetPoint("TOPLEFT", 0, -29)
    page.scroll:SetPoint("BOTTOMRIGHT", -26, 3)
    page.scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, page.rowHeight, function() GMG:RefreshRoster() end)
    end)

    page.rows = {}
    for index = 1, 14 do
        local row = CreateFrame("Button", nil, page.list)
        row:SetHeight(page.rowHeight)
        row:SetPoint("TOPLEFT", 3, -30 - (index - 1) * page.rowHeight)
        row:SetPoint("RIGHT", -27, 0)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        row.bg:SetTexture(1, 1, 1, index % 2 == 0 and 0.035 or 0.015)
        row.avatar = row:CreateTexture(nil, "ARTWORK")
        row.avatar:SetWidth(28)
        row.avatar:SetHeight(28)
        row.avatar:SetPoint("LEFT", 7, 0)
        row.dot = row:CreateTexture(nil, "OVERLAY")
        row.dot:SetTexture(unpack(GREEN))
        row.dot:SetWidth(7)
        row.dot:SetHeight(7)
        row.dot:SetPoint("BOTTOMRIGHT", row.avatar, "BOTTOMRIGHT", 1, -1)
        row.name = CreateText(row, "GameFontNormal", "", 12)
        row.name:SetPoint("TOPLEFT", 45, -5)
        row.name:SetWidth(190)
        row.name:SetJustifyH("LEFT")
        SetOneLine(row.name, 190)
        row.relation = CreateText(row, "GameFontNormalSmall", "", 9)
        row.relation:SetPoint("BOTTOMLEFT", 45, 5)
        row.relation:SetWidth(190)
        row.relation:SetJustifyH("LEFT")
        SetOneLine(row.relation, 190)
        row.level = CreateText(row, "GameFontNormalSmall", "", 11)
        row.level:SetPoint("LEFT", 248, 0)
        row.level:SetWidth(44)
        row.level:SetJustifyH("CENTER")
        row.class = CreateText(row, "GameFontNormalSmall", "", 10)
        row.class:SetPoint("LEFT", 301, 0)
        row.class:SetWidth(96)
        row.class:SetJustifyH("LEFT")
        SetOneLine(row.class, 96)
        row.zone = CreateText(row, "GameFontNormalSmall", "", 10)
        row.zone:SetPoint("LEFT", 407, 0)
        row.zone:SetWidth(108)
        row.zone:SetJustifyH("LEFT")
        SetOneLine(row.zone, 108)
        row.noteMark = CreateText(row, "GameFontNormal", "", 13)
        row.noteMark:SetPoint("RIGHT", -4, 0)
        row.noteMark:SetTextColor(unpack(ACCENT))
        row:SetScript("OnEnter", function(self)
            self.bg:SetTexture(0.40, 0.28, 0.65, 0.18)
            if self.member then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self.member.simpleName, 1, 1, 1)
                GameTooltip:AddLine(self.member.rank .. " · " .. self.member.class, 0.72, 0.74, 0.84)
                local relationText, relationType = GMG:GetCharacterRoleText(self.member.simpleName)
                if relationText ~= "" then
                    if relationType == "main" then GameTooltip:AddLine(relationText, 1.00, 0.76, 0.28)
                    else GameTooltip:AddLine(relationText, 0.72, 0.56, 1.00) end
                end
                if GMG:GetPersonalNote(self.member.simpleName) ~= "" then
                    GameTooltip:AddLine(GMG:GetPersonalNote(self.member.simpleName), 0.75, 0.58, 1, true)
                end
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function(self)
            self.bg:SetTexture(1, 1, 1, self.rowIndex % 2 == 0 and 0.035 or 0.015)
            GameTooltip:Hide()
        end)
        row:SetScript("OnClick", function(self, button)
            if not self.member then return end
            GMG:SelectRosterMember(self.member)
            if button == "RightButton" then GMG:OpenMemberMenu(self.member, self) end
        end)
        row:SetScript("OnDoubleClick", function(self, button)
            if button == "LeftButton" and self.member and ChatFrame_SendTell then ChatFrame_SendTell(self.member.simpleName) end
        end)
        row.rowIndex = index
        page.rows[index] = row
    end

    page.empty = CreateText(page.list, "GameFontNormal", self:L("NO_MEMBER"), 13)
    page.empty:SetPoint("CENTER", 0, -10)
    page.empty:SetTextColor(unpack(MUTED))

    page.profile = CreateFrame("Frame", nil, page)
    page.profile:SetPoint("TOPLEFT", page.list, "TOPRIGHT", 16, 0)
    page.profile:SetPoint("BOTTOMRIGHT", -22, 22)
    SetBackdrop(page.profile, PANEL_2, {0.12, 0.12, 0.20, 1})
    page.profileTitle = CreateText(page.profile, "GameFontNormalSmall", self:L("PLAYER_PROFILE"), 10)
    page.profileTitle:SetPoint("TOPLEFT", 18, -16)
    page.profileTitle:SetTextColor(unpack(MUTED))
    page.profileAvatar = page.profile:CreateTexture(nil, "ARTWORK")
    page.profileAvatar:SetWidth(106)
    page.profileAvatar:SetHeight(106)
    page.profileAvatar:SetPoint("TOP", 0, -48)
    page.profileName = CreateText(page.profile, "GameFontNormalLarge", "", 18)
    page.profileName:SetPoint("TOP", page.profileAvatar, "BOTTOM", 0, -13)
    SetOneLine(page.profileName, 230)
    page.profileRelation = CreateText(page.profile, "GameFontNormalSmall", "", 11)
    page.profileRelation:SetPoint("TOP", page.profileName, "BOTTOM", 0, -5)
    SetOneLine(page.profileRelation, 230)
    page.profileStatus = CreateText(page.profile, "GameFontNormal", "", 12)
    page.profileStatus:SetPoint("TOP", page.profileRelation, "BOTTOM", 0, -5)
    page.profileMeta = CreateText(page.profile, "GameFontNormalSmall", "", 11)
    page.profileMeta:SetPoint("TOP", page.profileStatus, "BOTTOM", 0, -7)
    page.profileMeta:SetWidth(230)
    page.profileMeta:SetJustifyH("CENTER")
    page.profileLastTitle = CreateText(page.profile, "GameFontNormalSmall", self:L("LAST_CONNECTION"), 10)
    page.profileLastTitle:SetPoint("TOPLEFT", 18, -255)
    page.profileLastTitle:SetPoint("TOPRIGHT", -18, -255)
    page.profileLastTitle:SetTextColor(unpack(MUTED))
    SetOneLine(page.profileLastTitle, 230)
    page.profileLastDate = CreateText(page.profile, "GameFontNormal", "", 11)
    page.profileLastDate:SetPoint("TOPLEFT", 18, -278)
    page.profileLastDate:SetPoint("TOPRIGHT", -18, -278)
    page.profileLastDate:SetJustifyH("LEFT")
    SetOneLine(page.profileLastDate, 230)
    page.profileLastAgo = CreateText(page.profile, "GameFontNormalSmall", "", 10)
    page.profileLastAgo:SetPoint("TOPLEFT", 18, -298)
    page.profileLastAgo:SetPoint("TOPRIGHT", -18, -298)
    page.profileLastAgo:SetJustifyH("LEFT")
    page.profileLastAgo:SetTextColor(unpack(ACCENT))
    SetOneLine(page.profileLastAgo, 230)

    page.profileNoteTitle = CreateText(page.profile, "GameFontNormalSmall", self:L("LOCAL_DATA"), 10)
    page.profileNoteTitle:SetPoint("TOPLEFT", 18, -334)
    page.profileNoteTitle:SetTextColor(unpack(MUTED))
    page.profileNote = CreateText(page.profile, "GameFontNormal", self:L("SELECT_MEMBER"), 11)
    page.profileNote:SetPoint("TOPLEFT", 18, -357)
    page.profileNote:SetPoint("BOTTOMRIGHT", -18, 18)
    page.profileNote:SetJustifyH("LEFT")
    page.profileNote:SetJustifyV("TOP")
    page.profileNote:SetTextColor(0.72, 0.74, 0.84, 1)
    if page.profileNote.SetWordWrap then page.profileNote:SetWordWrap(true) end
    if page.profileNote.SetNonSpaceWrap then page.profileNote:SetNonSpaceWrap(false) end

    page.menu = CreateFrame("Frame", "GlaynaBetterGuildMemberMenu", UIParent, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(page.menu, function(_, level) GMG:InitializeMemberMenu(level) end, "MENU")
    self.rosterPage = page
end

function GMG:CreateGuildPage()
    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()
    page.title = CreateText(page, "GameFontNormalLarge", self:L("GUILD"), 20)
    page.title:SetPoint("TOPLEFT", 22, -20)

    page.imagePanel = CreateFrame("Frame", nil, page)
    page.imagePanel:SetPoint("TOPLEFT", 22, -58)
    page.imagePanel:SetWidth(230)
    page.imagePanel:SetHeight(260)
    SetBackdrop(page.imagePanel, PANEL_2, {0.12, 0.12, 0.20, 1})
    page.imageTitle = CreateText(page.imagePanel, "GameFontNormal", self:L("GUILD_IMAGE"), 14)
    page.imageTitle:SetPoint("TOP", 0, -16)
    page.image = page.imagePanel:CreateTexture(nil, "ARTWORK")
    page.image:SetWidth(142)
    page.image:SetHeight(142)
    page.image:SetPoint("TOP", 0, -48)
    page.image:SetTexture(self:GetGuildImageTexture())
    page.changeImage = CreateFlatButton(page.imagePanel, self:L("CHANGE_GUILD_IMAGE"), 194, 34)
    page.changeImage:SetPoint("BOTTOM", 0, 16)
    page.changeImage:SetScript("OnClick", function() GMG:OpenImagePicker("guild") end)

    page.guildTextPanel = CreateFrame("Frame", nil, page)
    page.guildTextPanel:SetPoint("TOPLEFT", page.imagePanel, "TOPRIGHT", 16, 0)
    page.guildTextPanel:SetPoint("TOPRIGHT", -22, 0)
    page.guildTextPanel:SetHeight(260)
    SetBackdrop(page.guildTextPanel, PANEL_2, {0.12, 0.12, 0.20, 1})
    page.motdTitle = CreateText(page.guildTextPanel, "GameFontNormalSmall", self:L("GUILD_MOTD"), 10)
    page.motdTitle:SetPoint("TOPLEFT", 18, -16)
    page.motdTitle:SetTextColor(unpack(MUTED))
    page.motd = CreateText(page.guildTextPanel, "GameFontNormal", "", 13)
    page.motd:SetPoint("TOPLEFT", 18, -39)
    page.motd:SetPoint("TOPRIGHT", -18, -39)
    page.motd:SetHeight(54)
    page.motd:SetJustifyH("LEFT")
    page.motd:SetJustifyV("TOP")
    page.infoTitle = CreateText(page.guildTextPanel, "GameFontNormalSmall", self:L("GUILD_INFO"), 10)
    page.infoTitle:SetPoint("TOPLEFT", 18, -112)
    page.infoTitle:SetTextColor(unpack(MUTED))
    page.info = CreateText(page.guildTextPanel, "GameFontNormal", "", 11)
    page.info:SetPoint("TOPLEFT", 18, -135)
    page.info:SetPoint("BOTTOMRIGHT", -18, 15)
    page.info:SetJustifyH("LEFT")
    page.info:SetJustifyV("TOP")
    page.info:SetTextColor(0.74, 0.77, 0.86, 1)

    page.historyPanel = CreateFrame("Frame", nil, page)
    page.historyPanel:SetPoint("TOPLEFT", 22, -334)
    page.historyPanel:SetPoint("BOTTOMRIGHT", -22, 22)
    SetBackdrop(page.historyPanel, PANEL_2, {0.12, 0.12, 0.20, 1})
    page.historyTitle = CreateText(page.historyPanel, "GameFontNormal", self:L("SHARED_HISTORY"), 14)
    page.historyTitle:SetPoint("TOPLEFT", 18, -18)
    page.historyStats = CreateText(page.historyPanel, "GameFontNormal", "", 12)
    page.historyStats:SetPoint("TOPLEFT", 18, -50)
    page.historyStats:SetTextColor(0.76, 0.78, 0.86, 1)
    page.historyOldest = CreateText(page.historyPanel, "GameFontNormalSmall", "", 11)
    page.historyOldest:SetPoint("TOPLEFT", 18, -80)
    page.historyOldest:SetTextColor(unpack(MUTED))
    page.historyLatest = CreateText(page.historyPanel, "GameFontNormalSmall", "", 11)
    page.historyLatest:SetPoint("TOPLEFT", 18, -103)
    page.historyLatest:SetTextColor(unpack(MUTED))
    page.help = CreateText(page.historyPanel, "GameFontNormalSmall", self:L("GUILD_IMAGE_HELP"), 10)
    page.help:SetPoint("BOTTOMLEFT", 18, 18)
    page.help:SetPoint("BOTTOMRIGHT", -18, 18)
    page.help:SetJustifyH("LEFT")
    page.help:SetTextColor(unpack(MUTED))
    self.guildPage = page
end

function GMG:CreateSettingsPage()
    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()
    page.title = CreateText(page, "GameFontNormalLarge", self:L("SETTINGS"), 20)
    page.title:SetPoint("TOPLEFT", 22, -20)
    SetOneLine(page.title, 600)

    page.left = CreateFrame("Frame", nil, page)
    page.left:SetPoint("TOPLEFT", 22, -58)
    page.left:SetPoint("BOTTOMLEFT", 22, 22)
    page.left:SetWidth(400)
    SetBackdrop(page.left, PANEL_2, {0.12, 0.12, 0.20, 1})

    page.languageTitle = CreateText(page.left, "GameFontNormal", self:L("LANGUAGE"), 14)
    page.languageTitle:SetPoint("TOPLEFT", 18, -18)
    page.languageHelp = CreateText(page.left, "GameFontNormalSmall", self:L("LANGUAGE_HELP"), 10)
    page.languageHelp:SetPoint("TOPLEFT", 18, -45)
    page.languageHelp:SetPoint("TOPRIGHT", -18, -45)
    page.languageHelp:SetHeight(28)
    page.languageHelp:SetJustifyH("LEFT")
    page.languageHelp:SetJustifyV("TOP")
    page.languageHelp:SetTextColor(unpack(MUTED))
    page.languageButtons = {}
    local languageDefs = {{"auto", "AUTO"}, {"en", "ENGLISH"}, {"fr", "FRENCH"}}
    for index, def in ipairs(languageDefs) do
        local code = def[1]
        local button = CreateFlatButton(page.left, self:L(def[2]), 108, 32)
        button:SetPoint("TOPLEFT", 18 + (index - 1) * 118, -82)
        button.languageCode = code
        button.localeKey = def[2]
        button:SetScript("OnClick", function(self)
            GMG.db.profile.language = self.languageCode
            GMG:PersistSettings()
            GMG:ApplyBindingLocale()
            GMG:RefreshLocalization()
            GMG:RefreshAll(true)
        end)
        page.languageButtons[index] = button
    end

    page.notificationsTitle = CreateText(page.left, "GameFontNormal", self:L("NOTIFICATIONS"), 14)
    page.notificationsTitle:SetPoint("TOPLEFT", 18, -132)
    page.notifyOnline = CreateCheck(page.left, self:L("NOTIFY_ONLINE"), 360)
    page.notifyOnline:SetPoint("TOPLEFT", 18, -162)
    page.notifyOnline:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        GMG.db.profile.notifyOnline = self:GetChecked()
        GMG:PersistSettings()
    end)
    page.notifyOffline = CreateCheck(page.left, self:L("NOTIFY_OFFLINE"), 360)
    page.notifyOffline:SetPoint("TOPLEFT", 18, -192)
    page.notifyOffline:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        GMG.db.profile.notifyOffline = self:GetChecked()
        GMG:PersistSettings()
    end)
    page.mentionFlash = CreateCheck(page.left, self:L("MENTION_FLASH"), 360)
    page.mentionFlash:SetPoint("TOPLEFT", 18, -222)
    page.mentionFlash:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        GMG.db.profile.mentionFlash = self:GetChecked()
        GMG:PersistSettings()
        if not self:GetChecked() and GMG.mentionFlashFrame then
            GMG.mentionFlashActive = nil
            GMG.mentionFlashFrame:Hide()
        end
    end)
    page.mentionFlash:SetScript("OnEnter", function(self)
        self.label:SetTextColor(1, 1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L("MENTION_FLASH"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("MENTION_FLASH_HELP"), 0.72, 0.74, 0.84, true)
        GameTooltip:Show()
    end)
    page.mentionFlash:SetScript("OnLeave", function(self)
        self.label:SetTextColor(unpack(TEXT))
        GameTooltip:Hide()
    end)

    page.displayTitle = CreateText(page.left, "GameFontNormal", self:L("DISPLAY"), 14)
    page.displayTitle:SetPoint("TOPLEFT", 18, -262)
    page.showOffline = CreateCheck(page.left, self:L("SHOW_OFFLINE"), 360)
    page.showOffline:SetPoint("TOPLEFT", 18, -292)
    page.showOffline:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        GMG.db.profile.showOffline = self:GetChecked()
        GMG:PersistSettings()
        GMG.rosterDirty = true
    end)
    page.showLauncher = CreateCheck(page.left, self:L("SHOW_LAUNCHER"), 360)
    page.showLauncher:SetPoint("TOPLEFT", 18, -322)
    page.showLauncher:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        GMG.db.profile.launcherShown = self:GetChecked()
        GMG:PersistSettings()
        if self:GetChecked() then GMG.launcher:Show() else GMG.launcher:Hide() end
    end)

    page.keyTitle = CreateText(page.left, "GameFontNormal", self:L("KEYBIND"), 14)
    page.keyTitle:SetPoint("TOPLEFT", 18, -363)
    page.currentKey = CreateText(page.left, "GameFontNormal", "", 12)
    page.currentKey:SetPoint("TOPLEFT", 18, -391)
    page.currentKey:SetTextColor(0.76, 0.78, 0.86, 1)
    SetOneLine(page.currentKey, 360)
    page.changeKey = CreateFlatButton(page.left, self:L("CHANGE_KEY"), 160, 32)
    page.changeKey:SetPoint("TOPLEFT", 18, -421)
    page.changeKey:SetScript("OnClick", function() GMG:OpenKeyCapture() end)
    page.clearKey = CreateFlatButton(page.left, self:L("CLEAR_KEY"), 160, 32)
    page.clearKey:SetPoint("LEFT", page.changeKey, "RIGHT", 12, 0)
    page.clearKey:SetScript("OnClick", function() GMG:SetOpeningBinding(nil) end)

    page.info = CreateText(page.left, "GameFontNormalSmall", self:L("SETTINGS_INFO"), 10)
    page.info:SetPoint("BOTTOMLEFT", 18, 16)
    page.info:SetPoint("BOTTOMRIGHT", -18, 16)
    page.info:SetHeight(34)
    page.info:SetJustifyH("LEFT")
    page.info:SetJustifyV("BOTTOM")
    page.info:SetTextColor(unpack(MUTED))

    page.right = CreateFrame("Frame", nil, page)
    page.right:SetPoint("TOPLEFT", page.left, "TOPRIGHT", 16, 0)
    page.right:SetPoint("BOTTOMRIGHT", -22, 22)
    SetBackdrop(page.right, PANEL_2, {0.12, 0.12, 0.20, 1})
    page.avatarTitle = CreateText(page.right, "GameFontNormal", self:L("CHARACTER_IMAGE"), 14)
    page.avatarTitle:SetPoint("TOPLEFT", 20, -20)
    page.avatarTitle:SetPoint("TOPRIGHT", -20, -20)
    page.avatarTitle:SetJustifyH("CENTER")
    SetOneLine(page.avatarTitle, 300)
    page.avatar = page.right:CreateTexture(nil, "ARTWORK")
    page.avatar:SetWidth(160)
    page.avatar:SetHeight(160)
    page.avatar:SetPoint("TOP", 0, -58)
    page.avatarHelp = CreateText(page.right, "GameFontNormalSmall", self:L("CHARACTER_IMAGE_HELP"), 10)
    page.avatarHelp:SetPoint("TOPLEFT", 28, -236)
    page.avatarHelp:SetPoint("TOPRIGHT", -28, -236)
    page.avatarHelp:SetHeight(38)
    page.avatarHelp:SetJustifyH("CENTER")
    page.avatarHelp:SetJustifyV("TOP")
    page.avatarHelp:SetTextColor(unpack(MUTED))
    page.changeAvatar = CreateFlatButton(page.right, self:L("CHANGE_CHARACTER_IMAGE"), 250, 36)
    page.changeAvatar:SetPoint("TOP", 0, -292)
    page.changeAvatar:SetScript("OnClick", function() GMG:OpenImagePicker("avatar") end)
    page.sharedLabel = CreateText(page.right, "GameFontNormalSmall", self:L("SHARED_DATA"), 10)
    page.sharedLabel:SetPoint("TOPLEFT", 20, -350)
    page.sharedLabel:SetPoint("TOPRIGHT", -20, -350)
    page.sharedLabel:SetJustifyH("CENTER")
    page.sharedLabel:SetTextColor(unpack(GREEN))
    SetOneLine(page.sharedLabel, 300)
    self.settingsPage = page
end

function GMG:CreateNoteEditor()
    local frame = CreateFrame("Frame", "GlaynaBetterGuildNoteEditor", UIParent)
    frame:SetWidth(480)
    frame:SetHeight(290)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(frame, PANEL_BG, ACCENT)
    frame:Hide()
    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("NOTE_TITLE"), 18)
    frame.title:SetPoint("TOPLEFT", 20, -18)
    frame.help = CreateText(frame, "GameFontNormalSmall", self:L("NOTE_HELP"), 10)
    frame.help:SetPoint("TOPLEFT", 20, -48)
    frame.help:SetTextColor(unpack(MUTED))
    frame.holder, frame.edit = CreateEditBox(frame, 440, 150, true)
    frame.holder:SetPoint("TOPLEFT", 20, -75)
    frame.edit:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.save = CreateFlatButton(frame, self:L("SAVE"), 120, 34)
    frame.save:SetPoint("BOTTOMLEFT", 20, 18)
    frame.save:SetScript("OnClick", function()
        if frame.memberName then GMG:SetPersonalNote(frame.memberName, frame.edit:GetText()) end
        frame:Hide()
        GMG:RefreshRoster()
        GMG:RefreshMemberProfile()
    end)
    frame.clear = CreateFlatButton(frame, self:L("CLEAR"), 120, 34)
    frame.clear:SetPoint("LEFT", frame.save, "RIGHT", 10, 0)
    frame.clear:SetScript("OnClick", function() frame.edit:SetText("") end)
    frame.cancel = CreateFlatButton(frame, self:L("CANCEL"), 120, 34)
    frame.cancel:SetPoint("BOTTOMRIGHT", -20, 18)
    frame.cancel:SetScript("OnClick", function() frame:Hide() end)
    self.noteEditor = frame
end

function GMG:CreateImagePicker()
    local frame = CreateFrame("Frame", "GlaynaBetterGuildImagePicker", UIParent)
    frame:SetWidth(660)
    frame:SetHeight(540)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(frame, PANEL_BG, ACCENT)
    frame:Hide()
    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("IMAGE_PICKER"), 18)
    frame.title:SetPoint("TOPLEFT", 20, -18)
    SetOneLine(frame.title, 610)

    frame.categoryButtons = {}

    frame.builtinTitle = CreateText(frame, "GameFontNormalSmall", self:L("BUILTIN_IMAGES"), 10)
    frame.builtinTitle:SetPoint("TOPLEFT", 20, -50)
    frame.builtinTitle:SetTextColor(unpack(MUTED))
    frame.buttons = {}
    for index = 1, 40 do
        local button = CreateFrame("Button", nil, frame)
        button:SetWidth(68)
        button:SetHeight(68)
        local column = (index - 1) % 8
        local row = floor((index - 1) / 8)
        button:SetPoint("TOPLEFT", 20 + column * 77, -72 - row * 77)
        SetBackdrop(button, PANEL_3, BORDER)
        button.texture = button:CreateTexture(nil, "ARTWORK")
        button.texture:SetPoint("TOPLEFT", 4, -4)
        button.texture:SetPoint("BOTTOMRIGHT", -4, 4)
        button:SetScript("OnClick", function(self)
            if not self.texturePath then return end
            frame.selectedTexture = self.texturePath
            GMG:RefreshImagePickerSelection()
        end)
        button:SetScript("OnEnter", function(self)
            if not self.texturePath then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.presetName or "", 1, 1, 1)
            GameTooltip:AddLine(GMG:L("PORTRAIT_TOOLTIP"), 0.72, 0.74, 0.84)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        frame.buttons[index] = button
    end

    frame.customTitle = CreateText(frame, "GameFontNormal", self:L("CUSTOM_TEXTURE"), 13)
    frame.customTitle:SetPoint("TOPLEFT", 20, -430)
    SetOneLine(frame.customTitle, 610)
    frame.customHolder, frame.custom = CreateEditBox(frame, 620, 34, false)
    frame.customHolder:SetPoint("TOPLEFT", 20, -456)
    frame.customHelp = CreateText(frame, "GameFontNormalSmall", self:L("CUSTOM_TEXTURE_HELP"), 10)
    frame.customHelp:SetPoint("TOPLEFT", 20, -499)
    frame.customHelp:SetPoint("TOPRIGHT", -20, -499)
    frame.customHelp:SetHeight(38)
    frame.customHelp:SetJustifyH("LEFT")
    frame.customHelp:SetJustifyV("TOP")
    frame.customHelp:SetTextColor(unpack(MUTED))
    frame.preview = frame:CreateTexture(nil, "ARTWORK")
    frame.preview:SetWidth(78)
    frame.preview:SetHeight(78)
    frame.preview:SetPoint("BOTTOMLEFT", 20, 22)
    frame.apply = CreateFlatButton(frame, self:L("APPLY"), 150, 36)
    frame.apply:SetPoint("BOTTOMRIGHT", -180, 20)
    frame.apply:SetScript("OnClick", function()
        local custom = GMG:Trim(frame.custom:GetText())
        local texture = custom ~= "" and custom or frame.selectedTexture
        if not texture or texture == "" then GMG:Print(GMG:L("IMAGE_INVALID")); return end
        if frame.mode == "guild" then
            if GMG:SetGuildImage(texture) then frame:Hide() end
        else
            if GMG:SetOwnAvatar(texture) then frame:Hide() end
        end
        if custom ~= "" then GMG:Print(GMG:L("CUSTOM_NOT_SHARED")) end
    end)
    frame.close = CreateFlatButton(frame, self:L("CLOSE"), 140, 36)
    frame.close:SetPoint("BOTTOMRIGHT", -20, 20)
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    frame.category = "heroes"
    self.imagePicker = frame
end

function GMG:CreateKeyCapture()
    local frame = CreateFrame("Frame", "GlaynaBetterGuildKeyCapture", UIParent)
    frame:SetAllPoints(UIParent)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:EnableMouse(true)
    frame:EnableKeyboard(true)
    SetBackdrop(frame, {0.01, 0.01, 0.02, 0.88}, {0, 0, 0, 0})
    frame:Hide()
    frame.panel = CreateFrame("Frame", nil, frame)
    frame.panel:SetWidth(520)
    frame.panel:SetHeight(150)
    frame.panel:SetPoint("CENTER", 0, 0)
    SetBackdrop(frame.panel, PANEL_2, ACCENT)
    frame.title = CreateText(frame.panel, "GameFontNormalLarge", self:L("PRESS_KEY"), 19)
    frame.title:SetPoint("TOP", 0, -30)
    SetOneLine(frame.title, 470)
    frame.help = CreateText(frame.panel, "GameFontNormal", self:L("PRESS_KEY_HELP"), 11)
    frame.help:SetPoint("TOP", frame.title, "BOTTOM", 0, -18)
    SetOneLine(frame.help, 470)
    frame.help:SetTextColor(unpack(MUTED))
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then self:Hide(); return end
        if key == "BACKSPACE" then GMG:SetOpeningBinding(nil); self:Hide(); return end
        if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then return end
        local binding = ""
        if IsControlKeyDown and IsControlKeyDown() then binding = binding .. "CTRL-" end
        if IsAltKeyDown and IsAltKeyDown() then binding = binding .. "ALT-" end
        if IsShiftKeyDown and IsShiftKeyDown() then binding = binding .. "SHIFT-" end
        binding = binding .. key
        GMG:SetOpeningBinding(binding)
        self:Hide()
    end)
    self.keyCapture = frame
end

function GMG:CreateUI()
    if self.mainFrame then return end
    self:CreateToast()
    self:CreateMentionFlash()
    self:CreateLauncher()
    self:CreateMainFrame()
    self:CreateChatPage()
    self:CreateRosterPage()
    self:CreateGuildPage()
    self:CreateSettingsPage()
    self:CreateNoteEditor()
    self:CreateImagePicker()
    self:CreateKeyCapture()
    self:ShowTab(self.db.profile.lastTab or "chat")
    self:RefreshAll(true)
end

function GMG:ShowTab(key)
    key = (key == "roster" or key == "guild" or key == "settings") and key or "chat"
    self.db.profile.lastTab = key
    if self.PersistSettings then self:PersistSettings() end
    if key == "chat" then self.chatPage:Show() else self.chatPage:Hide() end
    if key == "roster" then self.rosterPage:Show() else self.rosterPage:Hide() end
    if key == "guild" then self.guildPage:Show() else self.guildPage:Hide() end
    if key == "settings" then self.settingsPage:Show() else self.settingsPage:Hide() end
    for tabKey, button in pairs(self.mainFrame.tabs) do SetButtonSelected(button, tabKey == key) end
    if self.mainFrame.settingsButton then
        if key == "settings" then
            self.mainFrame.settingsButton:SetBackdropColor(unpack(ACCENT_SOFT))
            self.mainFrame.settingsButton:SetBackdropBorderColor(unpack(ACCENT))
        else
            self.mainFrame.settingsButton:SetBackdropColor(unpack(PANEL_3))
            self.mainFrame.settingsButton:SetBackdropBorderColor(unpack(BORDER))
        end
    end
    if key == "chat" then self:RefreshChat(true)
    elseif key == "roster" then self:RefreshRoster()
    elseif key == "guild" then self:RefreshGuildPage()
    elseif key == "settings" then self:RefreshSettings() end
end

function GMG:Toggle()
    if not self.mainFrame then return end
    if self.mainFrame:IsShown() then self.mainFrame:Hide() else self.mainFrame:Show() end
end

function GMG:RefreshHeader()
    if not self.mainFrame then return end
    local guildName = self:GetGuildName()
    local headerWidth = max(300, self.mainFrame:GetWidth() - 330)
    SetBoundedText(self.mainFrame.guildName, guildName or self:L("NOT_IN_GUILD"), headerWidth)
    SetBoundedText(self.mainFrame.brand, self:L("BRAND"), headerWidth)
    self.mainFrame.guildImage:SetTexture(self:GetGuildImageTexture())
    local online = 0
    for _, member in ipairs(self.rosterMembers or {}) do if member.online then online = online + 1 end end
    SetBoundedText(self.mainFrame.onlineText, self:L("ONLINE", online), 92)
    if self.launcher then self.launcher.count:SetText(tostring(online)) end
end

function GMG:RefreshSyncStatus()
    if not self.mainFrame then return end
    self.mainFrame.syncText:SetText(self.syncStatus or self:L("SYNC_WAITING"))
    self.mainFrame.syncText:SetTextColor(self:IsInGuild() and 0.64 or MUTED[1], self:IsInGuild() and 0.52 or MUTED[2], self:IsInGuild() and 0.86 or MUTED[3], 1)
end

function GMG:RefreshChat(force)
    if not self.chatPage then return end
    if not force and not self.chatDirty then return end
    local page = self.chatPage
    page.messages:Clear()
    if not self:IsInGuild() then
        page.empty:SetText(self:L("JOIN_GUILD"))
        page.empty:Show()
        page.input:Disable()
        page.send:Disable()
        self.chatDirty = false
        return
    end
    page.input:Enable()
    page.send:Enable()
    local messages = self:GetMessages()
    if #messages == 0 then page.empty:Show() else page.empty:Hide() end
    page.empty:SetText(self:L("NO_MESSAGES"))
    local lastDay
    for index = 1, #messages do
        local message = messages[index]
        local day = date("%Y%m%d", tonumber(message.ts) or time())
        if day ~= lastDay then
            local label = date(self:GetLanguage() == "fr" and "%d/%m/%Y" or "%m/%d/%Y", tonumber(message.ts) or time())
            page.messages:AddMessage(" ")
            page.messages:AddMessage("|cff6d5a94— " .. label .. " —|r")
            lastDay = day
        end
        page.messages:AddMessage(self:FormatHistoryLine(message))
    end
    page.messages:ScrollToBottom()
    self.chatDirty = false
end

function GMG:OnHistoryChanged()
    if self.chatPage and self.chatPage:IsShown() then self:RefreshChat(true) end
    if self.guildPage and self.guildPage:IsShown() then self:RefreshGuildPage() end
end

function GMG:GetFilteredRoster()
    local filtered = {}
    local searchText = self.rosterPage and strlower(self.rosterPage.search:GetText() or "") or ""
    local onlyOnline = self.rosterPage and self.rosterPage.onlyOnline:GetChecked()
    for _, member in ipairs(self.rosterMembers or {}) do
        local visibleOffline = self.db.profile.showOffline or member.online
        local haystack = strlower((member.simpleName or "") .. " " .. (member.class or "") .. " " .. (member.rank or "") .. " " .. (member.zone or ""))
        if visibleOffline and (not onlyOnline or member.online) and (searchText == "" or string.find(haystack, searchText, 1, true)) then
            filtered[#filtered + 1] = member
        end
    end
    sort(filtered, function(a, b)
        if a.online ~= b.online then return a.online end
        return strlower(a.simpleName or "") < strlower(b.simpleName or "")
    end)
    return filtered
end

function GMG:LayoutRosterRows()
    if not self.rosterPage then return end
    for index, row in ipairs(self.rosterPage.rows) do
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 3, -30 - (index - 1) * self.rosterPage.rowHeight)
        row:SetPoint("RIGHT", -27, 0)
    end
end

function GMG:RefreshRoster()
    if not self.rosterPage then return end
    local page = self.rosterPage
    if not self:IsInGuild() then
        for _, row in ipairs(page.rows) do row:Hide() end
        page.empty:SetText(self:L("NOT_IN_GUILD"))
        page.empty:Show()
        return
    end
    local members = self:GetFilteredRoster()
    local visibleRows = min(#page.rows, max(1, floor((page.list:GetHeight() - 33) / page.rowHeight)))
    FauxScrollFrame_Update(page.scroll, #members, visibleRows, page.rowHeight)
    local offset = FauxScrollFrame_GetOffset(page.scroll)
    if #members == 0 then page.empty:Show() else page.empty:Hide() end
    page.empty:SetText(self:L("NO_MEMBER"))
    for rowIndex, row in ipairs(page.rows) do
        local member = rowIndex <= visibleRows and members[offset + rowIndex] or nil
        if member then
            row.member = member
            row:Show()
            row.avatar:SetTexture(self:GetAvatarFor(member.simpleName, member.class, member.classFile, true))
            if member.online then row.dot:SetTexture(unpack(GREEN)) else row.dot:SetTexture(0.28, 0.30, 0.36, 1) end
            local classColor = member.classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[member.classFile]
            if classColor then
                row.name:SetTextColor(classColor.r, classColor.g, classColor.b, member.online and 1 or 0.58)
            else
                row.name:SetTextColor(member.online and 0.88 or 0.50, member.online and 0.90 or 0.53, member.online and 0.96 or 0.62, 1)
            end
            SetBoundedText(row.name, member.simpleName, 190)
            local relationText, relationType = self:GetCharacterRoleText(member.simpleName)
            if self:IsHighlighted(member.simpleName) then relationText = "★ " .. relationText end
            SetBoundedText(row.relation, relationText, 190)
            if relationType == "main" then row.relation:SetTextColor(unpack(GOLD))
            elseif relationType == "reroll" then row.relation:SetTextColor(0.72, 0.56, 1.00, 1)
            else row.relation:SetTextColor(unpack(ACCENT)) end
            row.level:SetText(tostring(member.level or ""))
            row.class:SetText(member.class or "")
            row.zone:SetText(member.online and (member.zone or "") or self:L("OFFLINE"))
            row.noteMark:SetText(self:GetPersonalNote(member.simpleName) ~= "" and "●" or "")
            local alpha = member.online and 1 or 0.56
            row.level:SetAlpha(alpha); row.class:SetAlpha(alpha); row.zone:SetAlpha(alpha)
        else
            row.member = nil
            row:Hide()
        end
    end
    self.rosterDirty = false
    self:RefreshMemberProfile()
end

function GMG:SelectRosterMember(member)
    self.selectedRosterMember = member
    self:RefreshMemberProfile()
end

function GMG:RefreshMemberProfile()
    local page = self.rosterPage
    if not page then return end
    local member = self.selectedRosterMember
    if not member then
        page.profileAvatar:SetTexture(self.DEFAULT_AVATAR)
        page.profileName:SetText("")
        page.profileName:SetTextColor(unpack(TEXT))
        page.profileRelation:SetText("")
        page.profileStatus:SetText("")
        page.profileMeta:SetText("")
        page.profileLastDate:SetText("")
        page.profileLastAgo:SetText("")
        page.profileNote:SetText(self:L("SELECT_MEMBER"))
        return
    end
    page.profileAvatar:SetTexture(self:GetAvatarFor(member.simpleName, member.class, member.classFile, true))
    SetBoundedText(page.profileName, member.simpleName, 230)
    local classColor = member.classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[member.classFile]
    if classColor then
        page.profileName:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
    else
        page.profileName:SetTextColor(unpack(TEXT))
    end
    local relationText, relationType = self:GetCharacterRoleText(member.simpleName)
    SetBoundedText(page.profileRelation, relationText, 230)
    if relationType == "main" then page.profileRelation:SetTextColor(unpack(GOLD))
    elseif relationType == "reroll" then page.profileRelation:SetTextColor(0.72, 0.56, 1.00, 1)
    else page.profileRelation:SetTextColor(unpack(MUTED)) end
    page.profileStatus:SetText(member.online and "|cff55e693" .. self:L("ONLINE_NOW") .. "|r" or "|cff777b8c" .. self:L("OFFLINE") .. "|r")
    SetBoundedText(page.profileMeta, (member.rank or "") .. " · " .. (member.class or "") .. " · " .. tostring(member.level or ""), 230)
    local dateText, agoText = self:GetLastConnectionTexts(member)
    SetBoundedText(page.profileLastDate, dateText, 230)
    SetBoundedText(page.profileLastAgo, agoText, 230)
    local note = self:GetPersonalNote(member.simpleName)
    page.profileNote:SetText(note ~= "" and note or "—")
end

function GMG:MentionPlayer(name)
    if not self.chatPage or not self.chatPage.input then return end
    name = self:NormalizeName(name)
    if name == "" then return end
    local current = self:Trim(self.chatPage.input:GetText())
    local prefix = current ~= "" and (current .. " ") or ""
    self.chatPage.input:SetText(prefix .. "@" .. name .. " ")
    self.chatPage.input:SetFocus()
    self.chatPage.input:SetCursorPosition(string.len(self.chatPage.input:GetText()))
end

function GMG:OpenChatMemberMenu(name, anchor)
    name = self:NormalizeName(name)
    if name == "" or not self.chatPage or not self.chatPage.menu then return end
    self.contextChatName = name
    ToggleDropDownMenu(1, nil, self.chatPage.menu, anchor or UIParent, 0, 0)
end

function GMG:InitializeChatMemberMenu(level)
    if level ~= 1 or not self.contextChatName then return end
    local name = self.contextChatName
    local function Add(text, func)
        local info = UIDropDownMenu_CreateInfo()
        info.text = text
        info.func = func
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
    end
    Add(self:L("WHISPER"), function() if ChatFrame_SendTell then ChatFrame_SendTell(name) end end)
    Add(self:L("INVITE"), function() if InviteUnit then InviteUnit(name); GMG:Print(GMG:L("INVITED", name)) end end)
    Add(self:L("MENTION"), function() GMG:ShowTab("chat"); GMG:MentionPlayer(name) end)
    Add(self:L("CANCEL"), function() CloseDropDownMenus() end)
end

function GMG:OpenMemberMenu(member, anchor)
    self.contextMember = member
    ToggleDropDownMenu(1, nil, self.rosterPage.menu, anchor, 0, 0)
end

function GMG:InitializeMemberMenu(level)
    if level ~= 1 or not self.contextMember then return end
    local member = self.contextMember
    local name = member.simpleName
    local function Add(text, func, checked)
        local info = UIDropDownMenu_CreateInfo()
        info.text = text
        info.func = func
        info.notCheckable = checked == nil
        if checked ~= nil then info.checked = checked end
        UIDropDownMenu_AddButton(info, level)
    end
    Add(self:L("WHISPER"), function() if ChatFrame_SendTell then ChatFrame_SendTell(name) end end)
    Add(self:L("INVITE"), function() if InviteUnit then InviteUnit(name); GMG:Print(GMG:L("INVITED", name)) end end)
    Add(self:L(self:IsIgnored(name) and "UNIGNORE" or "IGNORE"), function() GMG:ToggleIgnore(name) end)
    if self:IsOwnCharacter(name) then
        Add(self:L("SET_MAIN"), function() GMG:SetOwnMain(name); GMG:RefreshRoster() end, self:IsMainCharacter(name))
    end
    Add(self:L("PERSONAL_NOTE"), function() GMG:OpenNoteEditor(name) end)
    Add(self:L("LOGIN_ALERT"), function() GMG:ToggleHighlighted(name); GMG:RefreshRoster() end, self:IsHighlighted(name))
    local info = UIDropDownMenu_CreateInfo()
    info.text = self:L("CANCEL")
    info.notCheckable = true
    info.func = function() CloseDropDownMenus() end
    UIDropDownMenu_AddButton(info, level)
end

function GMG:OpenNoteEditor(name)
    self.noteEditor.memberName = self:NormalizeName(name)
    SetBoundedText(self.noteEditor.title, self:L("NOTE_TITLE") .. " — " .. self.noteEditor.memberName, 430)
    self.noteEditor.edit:SetText(self:GetPersonalNote(name))
    self.noteEditor:Show()
    self.noteEditor.edit:SetFocus()
end

function GMG:RefreshGuildPage()
    if not self.guildPage then return end
    local page = self.guildPage
    page.image:SetTexture(self:GetGuildImageTexture())
    local motd = GetGuildRosterMOTD and GetGuildRosterMOTD() or ""
    local info = GetGuildInfoText and GetGuildInfoText() or ""
    page.motd:SetText(motd ~= "" and motd or self:L("NO_MOTD"))
    page.info:SetText(info ~= "" and info or self:L("NO_GUILD_INFO"))
    local oldest, latest, count = self:GetHistoryBounds()
    page.historyStats:SetText(self:L("HISTORY_STATS", count, self.db.profile.retentionDays or 30))
    local datePattern = self:GetLanguage() == "fr" and "%d/%m/%Y %H:%M" or "%m/%d/%Y %I:%M %p"
    page.historyOldest:SetText(self:L("HISTORY_OLDEST", oldest > 0 and date(datePattern, oldest) or self:L("NEVER")))
    page.historyLatest:SetText(self:L("HISTORY_LATEST", latest > 0 and date(datePattern, latest) or self:L("NEVER")))
    if self:CanEditGuildImage() then
        page.changeImage:Enable()
        page.changeImage.label:SetText(self:L("CHANGE_GUILD_IMAGE"))
    else
        page.changeImage:Disable()
        page.changeImage.label:SetText(self:L("GUILD_MASTER_ONLY"))
    end
    self.guildPageDirty = false
end

function GMG:RefreshSettings()
    if not self.settingsPage then return end
    local page = self.settingsPage
    for _, button in ipairs(page.languageButtons) do SetButtonSelected(button, self.db.profile.language == button.languageCode) end
    page.notifyOnline:SetChecked(self.db.profile.notifyOnline)
    page.notifyOffline:SetChecked(self.db.profile.notifyOffline)
    page.mentionFlash:SetChecked(self.db.profile.mentionFlash)
    page.showOffline:SetChecked(self.db.profile.showOffline)
    page.showLauncher:SetChecked(self.db.profile.launcherShown)
    SetBoundedText(page.currentKey, self:L("CURRENT_KEY", self:GetOpeningBinding()), 360)
    page.avatar:SetTexture(self:GetOwnAvatar())
end

function GMG:OpenImagePicker(mode)
    if mode == "guild" and not self:CanEditGuildImage() then self:Print(self:L("GUILD_MASTER_ONLY")); return end
    local frame = self.imagePicker
    frame.mode = mode
    frame.selectedTexture = mode == "guild" and self:GetGuildImageTexture() or self:GetOwnAvatar()
    frame.custom:SetText("")
    SetBoundedText(frame.title, mode == "guild" and self:L("CHANGE_GUILD_IMAGE") or self:L("CHANGE_CHARACTER_IMAGE"), 610)
    frame.category = "all"
    self:RefreshImagePickerCategory()
    frame:Show()
end

function GMG:RefreshImagePickerSelection()
    local frame = self.imagePicker
    if not frame then return end
    frame.preview:SetTexture(frame.selectedTexture or self.DEFAULT_AVATAR)
    for _, button in ipairs(frame.buttons) do
        if button.texturePath and button.texturePath == frame.selectedTexture then
            button:SetBackdropBorderColor(unpack(ACCENT))
            button:SetBackdropColor(unpack(ACCENT_SOFT))
        else
            button:SetBackdropBorderColor(unpack(BORDER))
            button:SetBackdropColor(unpack(PANEL_3))
        end
    end
end

function GMG:RefreshImagePickerCategory()
    local frame = self.imagePicker
    if not frame then return end
    local filtered = {}
    for _, preset in ipairs(self.IMAGE_PRESETS) do
        filtered[#filtered + 1] = preset
    end
    for index, button in ipairs(frame.buttons) do
        local preset = filtered[index]
        if preset then
            button.texturePath = preset.texture
            button.presetName = preset.name
            button.texture:SetTexture(preset.texture)
            button:Show()
        else
            button.texturePath = nil
            button.presetName = nil
            button:Hide()
        end
    end
    for _, button in ipairs(frame.categoryButtons) do
        SetButtonSelected(button, button.categoryKey == frame.category)
    end
    self:RefreshImagePickerSelection()
end

function GMG:OpenKeyCapture()
    if InCombatLockdown and InCombatLockdown() then self:Print(self:L("KEY_COMBAT")); return end
    self.keyCapture:Show()
end

function GMG:RefreshLocalization()
    if not self.mainFrame then return end
    SetBoundedText(self.launcher.title, self:L("LAUNCHER"), 72)
    SetBoundedText(self.mainFrame.brand, self:L("BRAND"), max(300, self.mainFrame:GetWidth() - 330))
    SetBoundedText(self.mainFrame.sidebarTitle, self:L("GUILD_SPACE"), 154)
    SetBoundedText(self.mainFrame.versionText, self:L("VERSION", self.version), 112)
    for _, button in pairs(self.mainFrame.tabs) do SetBoundedText(button.label, self:L(button.localeKey), 142) end
    SetBoundedText(self.chatPage.title, self:L("CHAT"), 600); SetBoundedText(self.chatPage.input.placeholder, self:L("TYPE_MESSAGE"), max(220, self.chatPage.inputHolder:GetWidth() - 22)); SetBoundedText(self.chatPage.send.label, self:L("SEND"), 88)
    SetBoundedText(self.rosterPage.title, self:L("MEMBERS"), 600); SetBoundedText(self.rosterPage.search.placeholder, self:L("SEARCH_MEMBER"), 280); SetBoundedText(self.rosterPage.onlyOnline.label, self:L("ONLINE_ONLY"), 173)
    self.rosterPage.nameHeader:SetText(self:L("MEMBERS")); self.rosterPage.levelHeader:SetText(self:L("LEVEL")); self.rosterPage.classHeader:SetText(self:L("CLASS")); self.rosterPage.zoneHeader:SetText(self:L("ZONE"))
    SetBoundedText(self.rosterPage.profileTitle, self:L("PLAYER_PROFILE"), 230); SetBoundedText(self.rosterPage.profileLastTitle, self:L("LAST_CONNECTION"), 230); SetBoundedText(self.rosterPage.profileNoteTitle, self:L("LOCAL_DATA"), 230)
    self.guildPage.title:SetText(self:L("GUILD")); self.guildPage.imageTitle:SetText(self:L("GUILD_IMAGE")); self.guildPage.motdTitle:SetText(self:L("GUILD_MOTD")); self.guildPage.infoTitle:SetText(self:L("GUILD_INFO")); self.guildPage.historyTitle:SetText(self:L("SHARED_HISTORY")); self.guildPage.help:SetText(self:L("GUILD_IMAGE_HELP"))
    local settings = self.settingsPage
    settings.title:SetText(self:L("SETTINGS")); settings.languageTitle:SetText(self:L("LANGUAGE")); settings.languageHelp:SetText(self:L("LANGUAGE_HELP"))
    for _, button in ipairs(settings.languageButtons) do SetBoundedText(button.label, self:L(button.localeKey), 96) end
    settings.notificationsTitle:SetText(self:L("NOTIFICATIONS")); SetBoundedText(settings.notifyOnline.label, self:L("NOTIFY_ONLINE"), 333); SetBoundedText(settings.notifyOffline.label, self:L("NOTIFY_OFFLINE"), 333); SetBoundedText(settings.mentionFlash.label, self:L("MENTION_FLASH"), 333)
    settings.displayTitle:SetText(self:L("DISPLAY")); SetBoundedText(settings.showOffline.label, self:L("SHOW_OFFLINE"), 333); SetBoundedText(settings.showLauncher.label, self:L("SHOW_LAUNCHER"), 333)
    settings.keyTitle:SetText(self:L("KEYBIND")); SetBoundedText(settings.changeKey.label, self:L("CHANGE_KEY"), 148); SetBoundedText(settings.clearKey.label, self:L("CLEAR_KEY"), 148); settings.info:SetText(self:L("SETTINGS_INFO"))
    SetBoundedText(settings.avatarTitle, self:L("CHARACTER_IMAGE"), 300); settings.avatarHelp:SetText(self:L("CHARACTER_IMAGE_HELP")); SetBoundedText(settings.changeAvatar.label, self:L("CHANGE_CHARACTER_IMAGE"), 238); SetBoundedText(settings.sharedLabel, self:L("SHARED_DATA"), 300)
    self.noteEditor.help:SetText(self:L("NOTE_HELP")); SetBoundedText(self.noteEditor.save.label, self:L("SAVE"), 108); SetBoundedText(self.noteEditor.clear.label, self:L("CLEAR"), 108); SetBoundedText(self.noteEditor.cancel.label, self:L("CANCEL"), 108)
    self.imagePicker.builtinTitle:SetText(self:L("BUILTIN_IMAGES")); SetBoundedText(self.imagePicker.customTitle, self:L("CUSTOM_TEXTURE"), 610); self.imagePicker.customHelp:SetText(self:L("CUSTOM_TEXTURE_HELP")); SetBoundedText(self.imagePicker.apply.label, self:L("APPLY"), 138); SetBoundedText(self.imagePicker.close.label, self:L("CLOSE"), 128)
    for _, button in ipairs(self.imagePicker.categoryButtons) do SetBoundedText(button.label, self:L(button.localeKey), 130) end
    SetBoundedText(self.keyCapture.title, self:L("PRESS_KEY"), 470); SetBoundedText(self.keyCapture.help, self:L("PRESS_KEY_HELP"), 470)
    self.syncStatus = self:IsInGuild() and self:L("SYNC_READY") or self:L("SYNC_WAITING")
    self:RefreshSettings(); self:RefreshHeader(); self:RefreshSyncStatus(); self:RefreshRoster(); self:RefreshGuildPage(); self:RefreshChat(true)
end

function GMG:RefreshDynamicUI()
    if not self.mainFrame then return end
    self:RefreshHeader()
    self:RefreshSyncStatus()
    if not self.mainFrame:IsShown() then return end
    local tab = self.db.profile.lastTab
    if tab == "chat" then self:RefreshChat(false)
    elseif tab == "roster" then self:RefreshRoster()
    elseif tab == "guild" then self:RefreshGuildPage()
    elseif tab == "settings" then self:RefreshSettings() end
end

function GMG:RefreshAll(force)
    if not self.mainFrame then return end
    self:RefreshHeader()
    self:RefreshSyncStatus()
    self:RefreshChat(force)
    self:RefreshRoster()
    self:RefreshGuildPage()
    self:RefreshSettings()
end

-- ================================================================
-- v1.3.0 UI enhancements
-- ================================================================

local V130OriginalCreateUI = GMG.CreateUI
local V130OriginalRefreshHeader = GMG.RefreshHeader
local V130OriginalRefreshSettings = GMG.RefreshSettings
local V130OriginalRefreshGuildPage = GMG.RefreshGuildPage
local V130OriginalRefreshRoster = GMG.RefreshRoster
local V130OriginalRefreshLocalization = GMG.RefreshLocalization
local V130OriginalStartNextToast = GMG.StartNextToast
local V130OriginalUpdateToast = GMG.UpdateToast
local V130OriginalOnUpdate = GMG.OnUpdate
local V130OriginalOpenImagePicker = GMG.OpenImagePicker

local function V130SetFontSize(fontString, size, flags)
    if not fontString or not fontString.GetFont then return end
    local font, _, currentFlags = fontString:GetFont()
    fontString:SetFont(font, size, flags or currentFlags)
end

local function V130ContainsValue(list, value)
    for _, item in ipairs(list or {}) do if item == value then return true end end
    return false
end

local V130SliderCounter = 0
local function V130CreateSlider(parent, title, minValue, maxValue, step, width)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetWidth(width or 520)
    holder:SetHeight(58)
    holder.title = CreateText(holder, "GameFontNormal", title or "", 12)
    holder.title:SetPoint("TOPLEFT", 0, 0)
    holder.value = CreateText(holder, "GameFontNormalSmall", "", 10)
    holder.value:SetPoint("TOPRIGHT", 0, 0)
    holder.value:SetTextColor(unpack(ACCENT))
    V130SliderCounter = V130SliderCounter + 1
    holder.slider = CreateFrame("Slider", "GlaynaBetterGuildSlider" .. V130SliderCounter, holder, "OptionsSliderTemplate")
    holder.slider:SetPoint("TOPLEFT", 4, -23)
    holder.slider:SetPoint("TOPRIGHT", -4, -23)
    holder.slider:SetHeight(18)
    holder.slider:SetMinMaxValues(minValue, maxValue)
    holder.slider:SetValueStep(step)
    if holder.slider.SetObeyStepOnDrag then holder.slider:SetObeyStepOnDrag(true) end
    return holder
end

local function V130CreateChoiceButton(parent, text, width, settingKey, settingValue, callback)
    local button = CreateFlatButton(parent, text, width, 30)
    button.settingKey = settingKey
    button.settingValue = settingValue
    button:SetScript("OnClick", function(self)
        GMG.db.profile[self.settingKey] = self.settingValue
        GMG:PersistSettings()
        if callback then callback(GMG) end
    end)
    return button
end

local function V130RefreshChoiceButtons(buttons)
    for _, button in ipairs(buttons or {}) do
        SetButtonSelected(button, GMG.db.profile[button.settingKey] == button.settingValue)
    end
end

local function V130CreateReadOnlyTextArea(parent)
    local frame = CreateFrame("Frame", nil, parent)
    SetBackdrop(frame, PANEL_3, BORDER)
    frame.scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 8, -7)
    frame.scroll:SetPoint("BOTTOMRIGHT", -27, 7)
    frame.edit = CreateFrame("EditBox", nil, frame.scroll)
    frame.edit:SetMultiLine(true)
    frame.edit:SetAutoFocus(false)
    frame.edit:SetFontObject("ChatFontNormal")
    frame.edit:SetTextColor(unpack(TEXT))
    frame.edit:SetWidth(480)
    frame.edit:SetHeight(80)
    frame.edit:SetMaxLetters(8000)
    frame.edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    frame.edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput and not self._settingReadOnly then
            self._settingReadOnly = true
            self:SetText(self._readOnlyText or "")
            self._settingReadOnly = false
        end
    end)
    frame.scroll:SetScrollChild(frame.edit)
    function frame:SetReadOnlyText(text)
        text = tostring(text or "")
        self.edit._readOnlyText = text
        self.edit._settingReadOnly = true
        self.edit:SetText(text)
        self.edit._settingReadOnly = false
        self.edit:SetCursorPosition(0)
        local lines = 1
        for _ in string.gmatch(text, "\n") do lines = lines + 1 end
        lines = lines + floor(string.len(text) / 72)
        self.edit:SetHeight(max(self:GetHeight() - 14, lines * 15 + 20))
        self.scroll:SetVerticalScroll(0)
    end
    frame:SetScript("OnSizeChanged", function(self)
        self.edit:SetWidth(max(120, self:GetWidth() - 42))
    end)
    return frame
end

function GMG:ExtractURLs(text)
    local urls, seen = {}, {}
    text = tostring(text or "")
    local function Add(url)
        while string.find(url, "[%)%]%}%.,;!]+$") do url = string.sub(url, 1, -2) end
        if url ~= "" and not seen[url] then
            seen[url] = true
            urls[#urls + 1] = url
        end
    end
    for url in string.gmatch(text, "https?://[^%s]+") do Add(url) end
    for url in string.gmatch(text, "discord%.gg/[^%s]+") do Add(url) end
    return urls
end

function GMG:CreateCopyLinkPopup()
    if self.copyLinkPopup then return end
    local frame = CreateFrame("Frame", "GlaynaBetterGuildCopyLink", UIParent)
    frame:SetWidth(560)
    frame:SetHeight(150)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(frame, PANEL_BG, ACCENT)
    frame:Hide()
    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("COPY_LINK"), 18)
    frame.title:SetPoint("TOPLEFT", 20, -20)
    frame.help = CreateText(frame, "GameFontNormalSmall", self:L("COPY_LINK_HELP"), 10)
    frame.help:SetPoint("TOPLEFT", 20, -48)
    frame.help:SetTextColor(unpack(MUTED))
    frame.holder, frame.edit = CreateEditBox(frame, 520, 34, false)
    frame.holder:SetPoint("TOPLEFT", 20, -73)
    frame.edit:SetMaxLetters(2048)
    frame.edit:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.close = CreateFlatButton(frame, self:L("CLOSE"), 110, 30)
    frame.close:SetPoint("BOTTOMRIGHT", -20, 14)
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    self.copyLinkPopup = frame
end

function GMG:OpenCopyLink(url)
    self:CreateCopyLinkPopup()
    local frame = self.copyLinkPopup
    frame.edit:SetText(tostring(url or ""))
    frame:Show()
    frame.edit:SetFocus()
    frame.edit:HighlightText()
end

function GMG:ApplyNotificationPosition()
    if not self.toast then return end
    local position = self.db.profile.notificationPosition or "top"
    self.toast:ClearAllPoints()
    if position == "topleft" then self.toast:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 36, -80)
    elseif position == "topright" then self.toast:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -36, -80)
    elseif position == "center" then self.toast:SetPoint("CENTER", UIParent, "CENTER", 0, 130)
    elseif position == "bottom" then self.toast:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 125)
    else self.toast:SetPoint("TOP", UIParent, "TOP", 0, -105) end
end

function GMG:GetNotificationColor()
    local key = self.db.profile.notificationColor or "accent"
    if key == "blue" then return {0.30, 0.62, 1.00, 1}
    elseif key == "green" then return {0.25, 0.90, 0.55, 1}
    elseif key == "red" then return {0.95, 0.34, 0.42, 1}
    elseif key == "gold" then return {1.00, 0.76, 0.28, 1}
    end
    return {ACCENT[1], ACCENT[2], ACCENT[3], 1}
end

function GMG:CreateNotificationSettingsPopup()
    if self.notificationSettingsPopup then return end
    local frame = CreateFrame("Frame", "GlaynaBetterGuildNotificationSettings", UIParent)
    frame:SetWidth(700)
    frame:SetHeight(650)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(frame, PANEL_BG, ACCENT)
    frame:Hide()
    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("ADVANCED_NOTIFICATIONS"), 19)
    frame.title:SetPoint("TOPLEFT", 22, -20)

    frame.size = V130CreateSlider(frame, self:L("NOTIFICATION_SIZE"), 0.7, 1.6, 0.1, 650)
    frame.size:SetPoint("TOPLEFT", 24, -58)
    frame.duration = V130CreateSlider(frame, self:L("NOTIFICATION_DURATION"), 1.5, 10, 0.5, 650)
    frame.duration:SetPoint("TOPLEFT", 24, -118)
    frame.opacity = V130CreateSlider(frame, self:L("NOTIFICATION_OPACITY"), 0.25, 1, 0.05, 650)
    frame.opacity:SetPoint("TOPLEFT", 24, -178)

    local function SliderChanged(holder, key, value, formatPattern)
        if holder._refreshing then return end
        GMG.db.profile[key] = value
        holder.value:SetText(format(formatPattern, value))
        GMG:PersistSettings()
    end
    frame.size.slider:SetScript("OnValueChanged", function(_, value) SliderChanged(frame.size, "notificationSize", value, "%.1fx") end)
    frame.duration.slider:SetScript("OnValueChanged", function(_, value) SliderChanged(frame.duration, "notificationDuration", value, "%.1f s") end)
    frame.opacity.slider:SetScript("OnValueChanged", function(_, value) SliderChanged(frame.opacity, "notificationOpacity", value, "%d%%") frame.opacity.value:SetText(format("%d%%", value * 100)) end)

    frame.shadow = CreateCheck(frame, self:L("NOTIFICATION_SHADOW"), 430)
    frame.shadow:SetPoint("TOPLEFT", 24, -242)
    frame.shadow:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        GMG.db.profile.notificationShadow = self:GetChecked()
        GMG:PersistSettings()
    end)

    frame.positionTitle = CreateText(frame, "GameFontNormal", self:L("NOTIFICATION_POSITION"), 13)
    frame.positionTitle:SetPoint("TOPLEFT", 24, -282)
    frame.positionButtons = {}
    local posDefs = {{"top","POSITION_TOP"},{"topleft","POSITION_TOPLEFT"},{"topright","POSITION_TOPRIGHT"},{"center","POSITION_CENTER"},{"bottom","POSITION_BOTTOM"}}
    for i, def in ipairs(posDefs) do
        local b = V130CreateChoiceButton(frame, self:L(def[2]), 120, "notificationPosition", def[1], function(g) g:ApplyNotificationPosition(); g:RefreshNotificationSettingsPopup() end)
        b:SetPoint("TOPLEFT", 24 + (i - 1) * 130, -306)
        frame.positionButtons[#frame.positionButtons + 1] = b
    end

    frame.animationTitle = CreateText(frame, "GameFontNormal", self:L("NOTIFICATION_ANIMATION"), 13)
    frame.animationTitle:SetPoint("TOPLEFT", 24, -350)
    frame.animationButtons = {}
    local animDefs = {{"fade","ANIM_FADE"},{"slide","ANIM_SLIDE"},{"pulse","ANIM_PULSE"}}
    for i, def in ipairs(animDefs) do
        local b = V130CreateChoiceButton(frame, self:L(def[2]), 150, "notificationAnimation", def[1], function(g) g:RefreshNotificationSettingsPopup() end)
        b:SetPoint("TOPLEFT", 24 + (i - 1) * 160, -374)
        frame.animationButtons[#frame.animationButtons + 1] = b
    end

    frame.styleTitle = CreateText(frame, "GameFontNormal", self:L("NOTIFICATION_STYLE"), 13)
    frame.styleTitle:SetPoint("TOPLEFT", 24, -418)
    frame.styleButtons = {}
    local styleDefs = {{"banner","STYLE_BANNER"},{"compact","STYLE_COMPACT"},{"minimal","STYLE_MINIMAL"}}
    for i, def in ipairs(styleDefs) do
        local b = V130CreateChoiceButton(frame, self:L(def[2]), 150, "notificationStyle", def[1], function(g) g:RefreshNotificationSettingsPopup() end)
        b:SetPoint("TOPLEFT", 24 + (i - 1) * 160, -442)
        frame.styleButtons[#frame.styleButtons + 1] = b
    end

    frame.colorTitle = CreateText(frame, "GameFontNormal", self:L("ACCENT_COLOR"), 13)
    frame.colorTitle:SetPoint("TOPLEFT", 24, -486)
    frame.colorButtons = {}
    local colorDefs = {{"accent","ACCENT_VIOLET"},{"blue","ACCENT_BLUE"},{"green","ACCENT_GREEN"},{"red","ACCENT_RED"},{"gold","ACCENT_GOLD"}}
    for i, def in ipairs(colorDefs) do
        local b = V130CreateChoiceButton(frame, self:L(def[2]), 120, "notificationColor", def[1], function(g) g:RefreshNotificationSettingsPopup() end)
        b:SetPoint("TOPLEFT", 24 + (i - 1) * 130, -510)
        frame.colorButtons[#frame.colorButtons + 1] = b
    end

    frame.preview = CreateFlatButton(frame, self:L("PREVIEW_NOTIFICATION"), 210, 34)
    frame.preview:SetPoint("BOTTOMLEFT", 24, 20)
    frame.preview:SetScript("OnClick", function() GMG:ShowToast(GMG:L("SUPER_CONNECTED", GMG:GetPlayerName()), true) end)
    frame.close = CreateFlatButton(frame, self:L("CLOSE"), 120, 34)
    frame.close:SetPoint("BOTTOMRIGHT", -24, 20)
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    self.notificationSettingsPopup = frame
end

function GMG:RefreshNotificationSettingsPopup()
    local frame = self.notificationSettingsPopup
    if not frame then return end
    local p = self.db.profile
    for _, holder in ipairs({frame.size, frame.duration, frame.opacity}) do holder._refreshing = true end
    frame.size.slider:SetValue(p.notificationSize or 1)
    frame.duration.slider:SetValue(p.notificationDuration or 4.2)
    frame.opacity.slider:SetValue(p.notificationOpacity or 1)
    for _, holder in ipairs({frame.size, frame.duration, frame.opacity}) do holder._refreshing = nil end
    frame.size.value:SetText(format("%.1fx", p.notificationSize or 1))
    frame.duration.value:SetText(format("%.1f s", p.notificationDuration or 4.2))
    frame.opacity.value:SetText(format("%d%%", (p.notificationOpacity or 1) * 100))
    frame.shadow:SetChecked(p.notificationShadow)
    V130RefreshChoiceButtons(frame.positionButtons)
    V130RefreshChoiceButtons(frame.animationButtons)
    V130RefreshChoiceButtons(frame.styleButtons)
    V130RefreshChoiceButtons(frame.colorButtons)
end

function GMG:OpenNotificationSettingsPopup()
    self:CreateNotificationSettingsPopup()
    self:RefreshNotificationSettingsPopup()
    self.notificationSettingsPopup:Show()
end

function GMG:CreateAppearancePopup()
    if self.appearancePopup then return end
    local frame = CreateFrame("Frame", "GlaynaBetterGuildAppearance", UIParent)
    frame:SetWidth(640)
    frame:SetHeight(420)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(frame, PANEL_BG, ACCENT)
    frame:Hide()
    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("WINDOW_APPEARANCE"), 19)
    frame.title:SetPoint("TOPLEFT", 22, -20)

    frame.themeTitle = CreateText(frame, "GameFontNormal", self:L("THEME"), 13)
    frame.themeTitle:SetPoint("TOPLEFT", 24, -66)
    frame.themeButtons = {}
    local themes = {{"midnight","THEME_MIDNIGHT"},{"frost","THEME_FROST"},{"fel","THEME_FEL"},{"ember","THEME_EMBER"}}
    for i, def in ipairs(themes) do
        local b = V130CreateChoiceButton(frame, self:L(def[2]), 135, "windowTheme", def[1], function(g) g:ApplyTheme(); g:RefreshAppearancePopup() end)
        b:SetPoint("TOPLEFT", 24 + (i - 1) * 145, -92)
        frame.themeButtons[#frame.themeButtons + 1] = b
    end

    frame.accentTitle = CreateText(frame, "GameFontNormal", self:L("ACCENT_COLOR"), 13)
    frame.accentTitle:SetPoint("TOPLEFT", 24, -142)
    frame.accentButtons = {}
    local accents = {{"violet","ACCENT_VIOLET"},{"blue","ACCENT_BLUE"},{"green","ACCENT_GREEN"},{"red","ACCENT_RED"},{"gold","ACCENT_GOLD"}}
    for i, def in ipairs(accents) do
        local b = V130CreateChoiceButton(frame, self:L(def[2]), 108, "accentColor", def[1], function(g) g:ApplyTheme(); g:RefreshAppearancePopup() end)
        b:SetPoint("TOPLEFT", 24 + (i - 1) * 118, -168)
        frame.accentButtons[#frame.accentButtons + 1] = b
    end

    frame.styleTitle = CreateText(frame, "GameFontNormal", self:L("WINDOW_STYLE"), 13)
    frame.styleTitle:SetPoint("TOPLEFT", 24, -218)
    frame.styleButtons = {}
    local styles = {{"solid","WINDOW_SOLID"},{"glass","WINDOW_GLASS"},{"soft","WINDOW_SOFT"}}
    for i, def in ipairs(styles) do
        local b = V130CreateChoiceButton(frame, self:L(def[2]), 160, "windowStyle", def[1], function(g) g:ApplyTheme(); g:RefreshAppearancePopup() end)
        b:SetPoint("TOPLEFT", 24 + (i - 1) * 170, -244)
        frame.styleButtons[#frame.styleButtons + 1] = b
    end

    frame.fadeAlpha = V130CreateSlider(frame, self:L("FADE_ALPHA"), 0.2, 0.8, 0.05, 590)
    frame.fadeAlpha:SetPoint("TOPLEFT", 24, -294)
    frame.fadeAlpha.slider:SetScript("OnValueChanged", function(_, value)
        if frame.fadeAlpha._refreshing then return end
        GMG.db.profile.contextFadeAlpha = value
        frame.fadeAlpha.value:SetText(format("%d%%", value * 100))
        GMG:PersistSettings()
    end)

    frame.close = CreateFlatButton(frame, self:L("CLOSE"), 120, 34)
    frame.close:SetPoint("BOTTOMRIGHT", -24, 20)
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    self.appearancePopup = frame
end

function GMG:RefreshAppearancePopup()
    local frame = self.appearancePopup
    if not frame then return end
    V130RefreshChoiceButtons(frame.themeButtons)
    V130RefreshChoiceButtons(frame.accentButtons)
    V130RefreshChoiceButtons(frame.styleButtons)
    frame.fadeAlpha._refreshing = true
    frame.fadeAlpha.slider:SetValue(self.db.profile.contextFadeAlpha or 0.48)
    frame.fadeAlpha._refreshing = nil
    frame.fadeAlpha.value:SetText(format("%d%%", (self.db.profile.contextFadeAlpha or 0.48) * 100))
end

function GMG:OpenAppearancePopup()
    self:CreateAppearancePopup()
    self:RefreshAppearancePopup()
    self.appearancePopup:Show()
end

function GMG:ApplyTheme()
    if not self.db or not self.db.profile then return end
    local p = self.db.profile
    local themes = {
        midnight = {{0.025,0.031,0.052},{0.045,0.052,0.082},{0.075,0.082,0.125},{0.24,0.22,0.38}},
        frost = {{0.020,0.045,0.070},{0.035,0.070,0.105},{0.055,0.105,0.150},{0.18,0.38,0.55}},
        fel = {{0.025,0.050,0.030},{0.040,0.080,0.045},{0.060,0.120,0.065},{0.20,0.48,0.24}},
        ember = {{0.060,0.028,0.020},{0.095,0.045,0.030},{0.135,0.065,0.040},{0.48,0.22,0.15}},
    }
    local accents = {
        violet = {0.60,0.42,1.00}, blue = {0.30,0.62,1.00}, green = {0.25,0.90,0.55},
        red = {0.95,0.34,0.42}, gold = {1.00,0.76,0.28},
    }
    local theme = themes[p.windowTheme or "midnight"] or themes.midnight
    local accent = accents[p.accentColor or "violet"] or accents.violet
    local alpha = p.windowStyle == "glass" and 0.84 or (p.windowStyle == "soft" and 0.94 or 0.99)
    PANEL_BG[1],PANEL_BG[2],PANEL_BG[3],PANEL_BG[4] = theme[1][1],theme[1][2],theme[1][3],alpha
    PANEL_2[1],PANEL_2[2],PANEL_2[3],PANEL_2[4] = theme[2][1],theme[2][2],theme[2][3],alpha
    PANEL_3[1],PANEL_3[2],PANEL_3[3],PANEL_3[4] = theme[3][1],theme[3][2],theme[3][3],max(0.86,alpha)
    BORDER[1],BORDER[2],BORDER[3],BORDER[4] = theme[4][1],theme[4][2],theme[4][3],1
    ACCENT[1],ACCENT[2],ACCENT[3],ACCENT[4] = accent[1],accent[2],accent[3],1
    ACCENT_SOFT[1],ACCENT_SOFT[2],ACCENT_SOFT[3],ACCENT_SOFT[4] = accent[1]*0.48,accent[2]*0.48,accent[3]*0.48,0.95

    local function RecolorTree(frame, depth)
        if not frame or (depth or 0) > 7 then return end
        if frame.SetBackdropColor then
            frame:SetBackdropColor(unpack(PANEL_2))
            frame:SetBackdropBorderColor(unpack(BORDER))
        end
        if frame.GetChildren then
            local children = {frame:GetChildren()}
            for _, child in ipairs(children) do RecolorTree(child, (depth or 0) + 1) end
        end
    end
    if self.mainFrame then
        RecolorTree(self.mainFrame, 0)
        self.mainFrame:SetBackdropColor(unpack(PANEL_BG))
        self.mainFrame.header:SetBackdropColor(unpack(PANEL_2))
        self.mainFrame.header:SetBackdropBorderColor(unpack(ACCENT_SOFT))
        self.mainFrame.sidebar:SetBackdropColor(PANEL_2[1]*0.75, PANEL_2[2]*0.75, PANEL_2[3]*0.75, PANEL_2[4])
        for key, button in pairs(self.mainFrame.tabs or {}) do SetButtonSelected(button, self.db.profile.lastTab == key) end
    end
    if self.launcher then SetBackdrop(self.launcher, PANEL_2, ACCENT_SOFT) end
    if self.notificationSettingsPopup then SetBackdrop(self.notificationSettingsPopup, PANEL_BG, ACCENT) end
    if self.appearancePopup then SetBackdrop(self.appearancePopup, PANEL_BG, ACCENT) end
    if self.copyLinkPopup then SetBackdrop(self.copyLinkPopup, PANEL_BG, ACCENT) end
end

function GMG:EnhanceGuildTextPanel()
    local page = self.guildPage
    if not page or page.v130Enhanced then return end
    page.v130Enhanced = true
    page.imagePanel:SetHeight(300)
    page.guildTextPanel:SetHeight(300)
    page.historyPanel:ClearAllPoints()
    page.historyPanel:SetPoint("TOPLEFT", 22, -374)
    page.historyPanel:SetPoint("BOTTOMRIGHT", -22, 22)
    page.motd:Hide()
    page.info:Hide()
    page.motdArea = V130CreateReadOnlyTextArea(page.guildTextPanel)
    page.motdArea:SetPoint("TOPLEFT", 16, -34)
    page.motdArea:SetPoint("TOPRIGHT", -16, -34)
    page.motdArea:SetHeight(72)
    page.infoTitle:ClearAllPoints()
    page.infoTitle:SetPoint("TOPLEFT", 18, -116)
    page.infoArea = V130CreateReadOnlyTextArea(page.guildTextPanel)
    page.infoArea:SetPoint("TOPLEFT", 16, -136)
    page.infoArea:SetPoint("TOPRIGHT", -16, -136)
    page.infoArea:SetHeight(112)
    page.linksTitle = CreateText(page.guildTextPanel, "GameFontNormalSmall", self:L("GUILD_LINKS"), 9)
    page.linksTitle:SetPoint("BOTTOMLEFT", 18, 28)
    page.linksTitle:SetTextColor(unpack(MUTED))
    page.linkButtons = {}
    for i = 1, 3 do
        local button = CreateFlatButton(page.guildTextPanel, "", 150, 24)
        button:SetPoint("BOTTOMLEFT", 18 + (i - 1) * 158, 4)
        button:SetScript("OnClick", function(self) if self.url then GMG:OpenCopyLink(self.url) end end)
        page.linkButtons[i] = button
    end
end

function GMG:RefreshGuildLinks()
    local page = self.guildPage
    if not page or not page.v130Enhanced then return end
    local motd = GetGuildRosterMOTD and GetGuildRosterMOTD() or ""
    local info = GetGuildInfoText and GetGuildInfoText() or ""
    page.motdArea:SetReadOnlyText(motd ~= "" and motd or self:L("NO_MOTD"))
    page.infoArea:SetReadOnlyText(info ~= "" and info or self:L("NO_GUILD_INFO"))
    local urls = self:ExtractURLs(motd .. "\n" .. info)
    page.linksTitle:SetText(#urls > 0 and self:L("GUILD_LINKS") or self:L("NO_LINK"))
    for i, button in ipairs(page.linkButtons) do
        local url = urls[i]
        if url then
            button.url = url
            SetBoundedText(button.label, url, 138)
            button:Show()
        else
            button.url = nil
            button:Hide()
        end
    end
end

function GMG:CreateRankLexicon()
    local page = self.rosterPage
    if not page or page.rankLexicon then return end
    local frame = CreateFrame("Frame", nil, page)
    frame:SetPoint("TOPLEFT", 22, -94)
    frame:SetPoint("BOTTOMRIGHT", -22, 22)
    SetBackdrop(frame, PANEL_BG, ACCENT)
    frame:SetFrameLevel(page:GetFrameLevel() + 10)
    frame:Hide()
    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("RANK_LEXICON"), 18)
    frame.title:SetPoint("TOPLEFT", 18, -16)
    frame.order = CreateFlatButton(frame, self:L("HIGH_TO_LOW"), 180, 30)
    frame.order:SetPoint("TOPRIGHT", -150, -12)
    frame.order:SetScript("OnClick", function()
        GMG.db.profile.rankLexiconAscending = not GMG.db.profile.rankLexiconAscending
        GMG:PersistSettings()
        GMG:RefreshRankLexicon()
    end)
    frame.close = CreateFlatButton(frame, self:L("CLOSE"), 110, 30)
    frame.close:SetPoint("TOPRIGHT", -18, -12)
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    frame.left = CreateFrame("Frame", nil, frame)
    frame.left:SetPoint("TOPLEFT", 18, -58)
    frame.left:SetPoint("BOTTOMLEFT", 18, 18)
    frame.left:SetWidth(250)
    SetBackdrop(frame.left, PANEL_2, BORDER)
    frame.right = CreateFrame("Frame", nil, frame)
    frame.right:SetPoint("TOPLEFT", frame.left, "TOPRIGHT", 14, 0)
    frame.right:SetPoint("BOTTOMRIGHT", -18, 18)
    SetBackdrop(frame.right, PANEL_2, BORDER)
    frame.memberTitle = CreateText(frame.right, "GameFontNormal", self:L("RANK_MEMBERS"), 13)
    frame.memberTitle:SetPoint("TOPLEFT", 16, -16)
    frame.members = CreateFrame("ScrollingMessageFrame", nil, frame.right)
    frame.members:SetPoint("TOPLEFT", 16, -44)
    frame.members:SetPoint("BOTTOMRIGHT", -16, 16)
    frame.members:SetFontObject("ChatFontNormal")
    frame.members:SetFading(false)
    frame.members:SetJustifyH("LEFT")
    frame.gradeButtons = {}
    for i = 1, 12 do
        local b = CreateFlatButton(frame.left, "", 218, 30)
        b:SetPoint("TOPLEFT", 16, -16 - (i - 1) * 34)
        b:SetScript("OnClick", function(self)
            frame.selectedRankIndex = self.rankIndex
            GMG:RefreshRankLexiconMembers()
            for _, other in ipairs(frame.gradeButtons) do SetButtonSelected(other, other.rankIndex == frame.selectedRankIndex) end
        end)
        frame.gradeButtons[i] = b
    end
    page.rankLexicon = frame
end

function GMG:GetGuildRanksFromRoster()
    local map, ranks = {}, {}
    for _, member in ipairs(self.rosterMembers or {}) do
        local index = tonumber(member.rankIndex) or 99
        if not map[index] then
            map[index] = {index = index, name = member.rank or self:L("SORT_RANK"), count = 0}
            ranks[#ranks + 1] = map[index]
        end
        map[index].count = map[index].count + 1
    end
    sort(ranks, function(a,b)
        if self.db.profile.rankLexiconAscending then return a.index < b.index else return a.index > b.index end
    end)
    return ranks
end

function GMG:RefreshRankLexiconMembers()
    local frame = self.rosterPage and self.rosterPage.rankLexicon
    if not frame then return end
    frame.members:Clear()
    local selected = frame.selectedRankIndex
    local members = {}
    for _, member in ipairs(self.rosterMembers or {}) do
        if tonumber(member.rankIndex) == tonumber(selected) then members[#members + 1] = member end
    end
    sort(members, function(a,b) return strlower(a.simpleName or "") < strlower(b.simpleName or "") end)
    for _, member in ipairs(members) do
        local color = member.classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[member.classFile]
        local name = member.simpleName
        if color then name = format("|cff%02x%02x%02x%s|r", floor(color.r*255), floor(color.g*255), floor(color.b*255), name) end
        frame.members:AddMessage((member.online and "|cff55e693●|r " or "|cff777b8c●|r ") .. name .. "  |cff788094" .. (member.class or "") .. " · " .. tostring(member.level or "") .. "|r")
    end
end

function GMG:RefreshRankLexicon()
    local frame = self.rosterPage and self.rosterPage.rankLexicon
    if not frame then return end
    local ranks = self:GetGuildRanksFromRoster()
    frame.order.label:SetText(self:L(self.db.profile.rankLexiconAscending and "HIGH_TO_LOW" or "LOW_TO_HIGH"))
    for i, button in ipairs(frame.gradeButtons) do
        local rank = ranks[i]
        if rank then
            button.rankIndex = rank.index
            SetBoundedText(button.label, rank.name .. "  (" .. rank.count .. ")", 206)
            button:Show()
        else button.rankIndex = nil; button:Hide() end
    end
    local valid = false
    for _, rank in ipairs(ranks) do if rank.index == frame.selectedRankIndex then valid = true end end
    if not valid then frame.selectedRankIndex = ranks[1] and ranks[1].index or nil end
    for _, button in ipairs(frame.gradeButtons) do SetButtonSelected(button, button.rankIndex == frame.selectedRankIndex) end
    self:RefreshRankLexiconMembers()
end

function GMG:OpenRankLexicon()
    self:CreateRankLexicon()
    self:RefreshRankLexicon()
    self.rosterPage.rankLexicon:Show()
end

function GMG:InitializeSortMenu(level)
    if level ~= 1 then return end
    local defs = {{"name","SORT_NAME"},{"level","SORT_LEVEL"},{"class","SORT_CLASS"},{"zone","SORT_ZONE"},{"rank","SORT_RANK"}}
    for _, def in ipairs(defs) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = self:L(def[2])
        info.checked = self.db.profile.rosterSortKey == def[1]
        info.func = function()
            GMG.db.profile.rosterSortKey = def[1]
            GMG:PersistSettings()
            GMG.rosterDirty = true
            GMG:RefreshRoster()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

function GMG:GetFilteredRoster()
    local filtered = {}
    local searchText = self.rosterPage and strlower(self.rosterPage.search:GetText() or "") or ""
    local onlyOnline = self.rosterPage and self.rosterPage.onlyOnline:GetChecked()
    for _, member in ipairs(self.rosterMembers or {}) do
        local visibleOffline = self.db.profile.showOffline or member.online
        local haystack = strlower((member.simpleName or "") .. " " .. (member.class or "") .. " " .. (member.rank or "") .. " " .. (member.zone or ""))
        if visibleOffline and (not onlyOnline or member.online) and (searchText == "" or string.find(haystack, searchText, 1, true)) then
            filtered[#filtered + 1] = member
        end
    end
    local key = self.db.profile.rosterSortKey or "name"
    local ascending = self.db.profile.rosterSortAscending ~= false
    local function Value(member)
        if key == "level" then return tonumber(member.level) or 0 end
        if key == "class" then return strlower(member.class or "") end
        if key == "zone" then return strlower(member.zone or "") end
        if key == "rank" then return tonumber(member.rankIndex) or 99 end
        return strlower(member.simpleName or "")
    end
    -- Some 3.3.5/private-server roster refreshes can mutate the source list
    -- while the UI is rebuilding it. Keep the comparator strictly defensive.
    local compact = {}
    for index = 1, #filtered do
        local member = filtered[index]
        if type(member) == "table" then compact[#compact + 1] = member end
    end
    filtered = compact
    sort(filtered, function(a, b)
        if a == b then return false end
        if type(a) ~= "table" then return false end
        if type(b) ~= "table" then return true end

        local aOnline = a.online and true or false
        local bOnline = b.online and true or false
        if aOnline ~= bOnline then return aOnline end

        local av, bv = Value(a), Value(b)
        if av == bv then
            local an = strlower(a.simpleName or "")
            local bn = strlower(b.simpleName or "")
            if an == bn then return (tonumber(a.index) or 0) < (tonumber(b.index) or 0) end
            return an < bn
        end
        if ascending then return av < bv end
        return av > bv
    end)
    return filtered
end

function GMG:EnhanceRosterControls()
    local page = self.rosterPage
    if not page or page.v130Enhanced then return end
    page.v130Enhanced = true
    page.searchHolder:SetWidth(230)
    page.onlyOnline:ClearAllPoints()
    page.onlyOnline:SetWidth(150)
    page.onlyOnline:SetPoint("LEFT", page.searchHolder, "RIGHT", 10, 0)
    page.sortButton = CreateFlatButton(page, "", 150, 32)
    page.sortButton:SetPoint("LEFT", page.onlyOnline, "RIGHT", 10, 0)
    page.sortButton:SetScript("OnClick", function(self) ToggleDropDownMenu(1, nil, page.sortMenu, self, 0, 0) end)
    page.sortDirection = CreateFlatButton(page, "↑", 38, 32)
    page.sortDirection:SetPoint("LEFT", page.sortButton, "RIGHT", 7, 0)
    page.sortDirection:SetScript("OnClick", function()
        GMG.db.profile.rosterSortAscending = not GMG.db.profile.rosterSortAscending
        GMG:PersistSettings()
        GMG.rosterDirty = true
        GMG:RefreshRoster()
    end)
    page.sortMenu = CreateFrame("Frame", "GlaynaBetterGuildSortMenu", UIParent, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(page.sortMenu, function(_, level) GMG:InitializeSortMenu(level) end, "MENU")
    page.rankLexiconButton = CreateFlatButton(page, self:L("RANK_LEXICON"), 160, 30)
    page.rankLexiconButton:SetPoint("TOPRIGHT", -22, -14)
    page.rankLexiconButton:SetScript("OnClick", function() GMG:OpenRankLexicon() end)
end

function GMG:RefreshRosterSortControls()
    local page = self.rosterPage
    if not page or not page.v130Enhanced then return end
    local keyMap = {name="SORT_NAME",level="SORT_LEVEL",class="SORT_CLASS",zone="SORT_ZONE",rank="SORT_RANK"}
    SetBoundedText(page.sortButton.label, self:L("SORT") .. ": " .. self:L(keyMap[self.db.profile.rosterSortKey or "name"]), 138)
    page.sortDirection.label:SetText(self.db.profile.rosterSortAscending ~= false and "↑" or "↓")
    SetBoundedText(page.rankLexiconButton.label, self:L("RANK_LEXICON"), 148)
    if page.rankLexicon and page.rankLexicon:IsShown() then self:RefreshRankLexicon() end
end

function GMG:EnhanceSettingsPage()
    local page = self.settingsPage
    if not page or page.v130Enhanced then return end
    page.v130Enhanced = true
    page.keyTitle:ClearAllPoints(); page.keyTitle:SetPoint("TOPLEFT", 18, -350)
    page.currentKey:ClearAllPoints(); page.currentKey:SetPoint("TOPLEFT", 18, -377)
    page.changeKey:ClearAllPoints(); page.changeKey:SetPoint("TOPLEFT", 18, -406)
    page.clearKey:ClearAllPoints(); page.clearKey:SetPoint("LEFT", page.changeKey, "RIGHT", 12, 0)
    page.info:ClearAllPoints(); page.info:SetPoint("BOTTOMLEFT", 18, 10); page.info:SetPoint("BOTTOMRIGHT", -18, 10); page.info:SetHeight(40)

    page.fadeInCombat = CreateCheck(page.right, self:L("FADE_IN_COMBAT"), 315)
    page.fadeInCombat:SetPoint("TOPLEFT", 20, -372)
    page.fadeInCombat:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked()); GMG.db.profile.fadeInCombat = self:GetChecked(); GMG:PersistSettings()
    end)
    page.fadeWhileMoving = CreateCheck(page.right, self:L("FADE_WHILE_MOVING"), 315)
    page.fadeWhileMoving:SetPoint("TOPLEFT", 20, -402)
    page.fadeWhileMoving:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked()); GMG.db.profile.fadeWhileMoving = self:GetChecked(); GMG:PersistSettings()
    end)
    page.notificationAdvanced = CreateFlatButton(page.right, self:L("ADVANCED_NOTIFICATIONS"), 150, 32)
    page.notificationAdvanced:SetPoint("BOTTOMLEFT", 20, 18)
    page.notificationAdvanced:SetScript("OnClick", function() GMG:OpenNotificationSettingsPopup() end)
    page.appearanceAdvanced = CreateFlatButton(page.right, self:L("WINDOW_APPEARANCE"), 150, 32)
    page.appearanceAdvanced:SetPoint("BOTTOMRIGHT", -20, 18)
    page.appearanceAdvanced:SetScript("OnClick", function() GMG:OpenAppearancePopup() end)
end

function GMG:RefreshV130Settings()
    local page = self.settingsPage
    if not page or not page.v130Enhanced then return end
    page.fadeInCombat:SetChecked(self.db.profile.fadeInCombat)
    page.fadeWhileMoving:SetChecked(self.db.profile.fadeWhileMoving)
    SetBoundedText(page.fadeInCombat.label, self:L("FADE_IN_COMBAT"), 288)
    SetBoundedText(page.fadeWhileMoving.label, self:L("FADE_WHILE_MOVING"), 288)
    SetBoundedText(page.notificationAdvanced.label, self:L("ADVANCED_NOTIFICATIONS"), 138)
    SetBoundedText(page.appearanceAdvanced.label, self:L("WINDOW_APPEARANCE"), 138)
end

function GMG:EnhanceImagePicker()
    local frame = self.imagePicker
    if not frame then return end
    if frame.v130Enhanced then
        if frame.largePreviewTitle then
            SetBoundedText(frame.largePreviewTitle, self:L("CHARACTER_IMAGE"), 226)
        end
        return
    end
    frame.v130Enhanced = true

    -- v1.5.4: give the clicked profile/class logo a real large preview.
    -- The portrait sources are 128x128, but the preview is deliberately shown
    -- at 256x256 so the player can inspect the selected artwork before applying.
    frame:SetWidth(950)
    frame:SetHeight(590)
    frame.customTitle:Hide(); frame.customHolder:Hide(); frame.customHelp:Hide()

    SetOneLine(frame.title, 900)
    frame.builtinTitle:ClearAllPoints()
    frame.builtinTitle:SetPoint("TOPLEFT", 20, -50)

    if not frame.largePreviewPanel then
        frame.largePreviewPanel = CreateFrame("Frame", nil, frame)
        frame.largePreviewPanel:SetWidth(282)
        frame.largePreviewPanel:SetHeight(430)
        frame.largePreviewPanel:SetPoint("TOPRIGHT", -18, -54)
        SetBackdrop(frame.largePreviewPanel, PANEL_2, BORDER)

        frame.largePreviewTitle = CreateText(frame.largePreviewPanel, "GameFontNormal", self:L("CHARACTER_IMAGE"), 13)
        frame.largePreviewTitle:SetPoint("TOPLEFT", 12, -14)
        frame.largePreviewTitle:SetPoint("TOPRIGHT", -12, -14)
        frame.largePreviewTitle:SetJustifyH("CENTER")
        SetOneLine(frame.largePreviewTitle, 308)

        frame.largePreviewBackdrop = CreateFrame("Frame", nil, frame.largePreviewPanel)
        frame.largePreviewBackdrop:SetWidth(212)
        frame.largePreviewBackdrop:SetHeight(212)
        frame.largePreviewBackdrop:SetPoint("TOP", 0, -48)
        SetBackdrop(frame.largePreviewBackdrop, PANEL_3, ACCENT)
    end

    frame.preview:SetParent(frame.largePreviewBackdrop)
    frame.preview:ClearAllPoints()
    frame.preview:SetWidth(192)
    frame.preview:SetHeight(192)
    frame.preview:SetPoint("CENTER", frame.largePreviewBackdrop, "CENTER", 0, 0)

    frame.apply:SetParent(frame.largePreviewPanel)
    frame.apply:ClearAllPoints()
    frame.apply:SetWidth(250)
    frame.apply:SetPoint("BOTTOM", 0, 58)

    frame.close:SetParent(frame.largePreviewPanel)
    frame.close:ClearAllPoints()
    frame.close:SetWidth(250)
    frame.close:SetPoint("BOTTOM", 0, 16)
end

function GMG:EnhanceMainWindow()
    local frame = self.mainFrame
    if not frame or frame.v130Enhanced then return end
    frame.v130Enhanced = true
    frame:SetMinResize(1000, 680)
    if frame:GetHeight() < 680 then frame:SetHeight(720); self:SaveMainPosition() end
    if frame.syncText then frame.syncText:Hide() end
    if frame.versionText then
        frame.versionText:ClearAllPoints()
        frame.versionText:SetPoint("BOTTOMLEFT", 66, 24)
    end
    frame.brand:ClearAllPoints(); frame.brand:SetPoint("TOPLEFT", frame.guildImage, "TOPRIGHT", 8, -1); frame.brand:SetJustifyH("LEFT"); V130SetFontSize(frame.brand, 9)
    frame.guildName:ClearAllPoints(); frame.guildName:SetPoint("TOPLEFT", frame.guildImage, "TOPRIGHT", 8, -19); frame.guildName:SetJustifyH("LEFT"); V130SetFontSize(frame.guildName, 25)
    if UISpecialFrames and not V130ContainsValue(UISpecialFrames, "GlaynaBetterGuildFrame") then
        table.insert(UISpecialFrames, "GlaynaBetterGuildFrame")
    end
    self:EnhanceRosterControls()
    self:EnhanceGuildTextPanel()
    self:EnhanceSettingsPage()
    self:EnhanceImagePicker()
    if self.chatPage and self.chatPage.messages then
        self.chatPage.messages:SetScript("OnHyperlinkClick", function(_, link, _, button)
            local name = string.match(link or "", "^gmgplayer:(.+)$")
            if name then GMG:OpenChatMemberMenu(name, GMG.chatPage.messages, button); return end
            local id = string.match(link or "", "^gmgurl:(.+)$")
            if id and GMG.copyableURLs and GMG.copyableURLs[id] then GMG:OpenCopyLink(GMG.copyableURLs[id]) end
        end)
    end
    self:ApplyTheme()
end

function GMG:UpdateAdaptiveWindowAlpha(elapsed)
    local frame = self.mainFrame
    if not frame then return end
    if not frame:IsShown() then frame:SetAlpha(1); self.v130WindowAlpha = 1; return end
    local p = self.db.profile
    local inCombat = p.fadeInCombat and ((UnitAffectingCombat and UnitAffectingCombat("player")) or (InCombatLockdown and InCombatLockdown()))
    local moving = p.fadeWhileMoving and GetUnitSpeed and (GetUnitSpeed("player") or 0) > 0
    local target = (inCombat or moving) and (p.contextFadeAlpha or 0.48) or 1
    local current = self.v130WindowAlpha or frame:GetAlpha() or 1
    current = current + (target - current) * min(1, elapsed * 8)
    if math.abs(current - target) < 0.01 then current = target end
    self.v130WindowAlpha = current
    frame:SetAlpha(current)
end

function GMG:CreateUI()
    V130OriginalCreateUI(self)
    self:EnhanceMainWindow()
    self:RefreshAll(true)
end

function GMG:RefreshHeader()
    V130OriginalRefreshHeader(self)
    if not self.mainFrame then return end
    local width = max(260, self.mainFrame:GetWidth() - 340)
    SetBoundedText(self.mainFrame.brand, self:L("BRAND"), width)
    SetBoundedText(self.mainFrame.guildName, self:GetGuildName() or self:L("NOT_IN_GUILD"), width)
end

function GMG:RefreshSettings()
    V130OriginalRefreshSettings(self)
    self:RefreshV130Settings()
end

function GMG:RefreshGuildPage()
    V130OriginalRefreshGuildPage(self)
    self:RefreshGuildLinks()
end

function GMG:RefreshRoster()
    V130OriginalRefreshRoster(self)
    self:RefreshRosterSortControls()
end

function GMG:RefreshV130PopupLocalization()
    if self.copyLinkPopup then
        self.copyLinkPopup.title:SetText(self:L("COPY_LINK"))
        self.copyLinkPopup.help:SetText(self:L("COPY_LINK_HELP"))
        SetBoundedText(self.copyLinkPopup.close.label, self:L("CLOSE"), 98)
    end
    local n = self.notificationSettingsPopup
    if n then
        n.title:SetText(self:L("ADVANCED_NOTIFICATIONS"))
        n.size.title:SetText(self:L("NOTIFICATION_SIZE")); n.duration.title:SetText(self:L("NOTIFICATION_DURATION")); n.opacity.title:SetText(self:L("NOTIFICATION_OPACITY"))
        SetBoundedText(n.shadow.label, self:L("NOTIFICATION_SHADOW"), 403)
        n.positionTitle:SetText(self:L("NOTIFICATION_POSITION")); n.animationTitle:SetText(self:L("NOTIFICATION_ANIMATION")); n.styleTitle:SetText(self:L("NOTIFICATION_STYLE")); n.colorTitle:SetText(self:L("ACCENT_COLOR"))
        local posKeys={"POSITION_TOP","POSITION_TOPLEFT","POSITION_TOPRIGHT","POSITION_CENTER","POSITION_BOTTOM"}
        local animKeys={"ANIM_FADE","ANIM_SLIDE","ANIM_PULSE"}
        local styleKeys={"STYLE_BANNER","STYLE_COMPACT","STYLE_MINIMAL"}
        local colorKeys={"ACCENT_VIOLET","ACCENT_BLUE","ACCENT_GREEN","ACCENT_RED","ACCENT_GOLD"}
        for i,b in ipairs(n.positionButtons) do SetBoundedText(b.label,self:L(posKeys[i]),108) end
        for i,b in ipairs(n.animationButtons) do SetBoundedText(b.label,self:L(animKeys[i]),138) end
        for i,b in ipairs(n.styleButtons) do SetBoundedText(b.label,self:L(styleKeys[i]),138) end
        for i,b in ipairs(n.colorButtons) do SetBoundedText(b.label,self:L(colorKeys[i]),108) end
        SetBoundedText(n.preview.label,self:L("PREVIEW_NOTIFICATION"),198); SetBoundedText(n.close.label,self:L("CLOSE"),108)
    end
    local a = self.appearancePopup
    if a then
        a.title:SetText(self:L("WINDOW_APPEARANCE")); a.themeTitle:SetText(self:L("THEME")); a.accentTitle:SetText(self:L("ACCENT_COLOR")); a.styleTitle:SetText(self:L("WINDOW_STYLE")); a.fadeAlpha.title:SetText(self:L("FADE_ALPHA"))
        local themeKeys={"THEME_MIDNIGHT","THEME_FROST","THEME_FEL","THEME_EMBER"}
        local accentKeys={"ACCENT_VIOLET","ACCENT_BLUE","ACCENT_GREEN","ACCENT_RED","ACCENT_GOLD"}
        local styleKeys={"WINDOW_SOLID","WINDOW_GLASS","WINDOW_SOFT"}
        for i,b in ipairs(a.themeButtons) do SetBoundedText(b.label,self:L(themeKeys[i]),123) end
        for i,b in ipairs(a.accentButtons) do SetBoundedText(b.label,self:L(accentKeys[i]),96) end
        for i,b in ipairs(a.styleButtons) do SetBoundedText(b.label,self:L(styleKeys[i]),148) end
        SetBoundedText(a.close.label,self:L("CLOSE"),108)
    end
    local r = self.rosterPage and self.rosterPage.rankLexicon
    if r then
        r.title:SetText(self:L("RANK_LEXICON")); r.memberTitle:SetText(self:L("RANK_MEMBERS")); SetBoundedText(r.close.label,self:L("CLOSE"),98)
    end
end

function GMG:RefreshLocalization()
    V130OriginalRefreshLocalization(self)
    self:RefreshV130PopupLocalization()
    if self.notificationSettingsPopup then self:RefreshNotificationSettingsPopup() end
    if self.appearancePopup then self:RefreshAppearancePopup() end
    self:RefreshV130Settings()
    self:RefreshRosterSortControls()
    self:RefreshGuildLinks()
end

function GMG:OpenImagePicker(mode)
    V130OriginalOpenImagePicker(self, mode)
    self:EnhanceImagePicker()
end

function GMG:StartNextToast()
    V130OriginalStartNextToast(self)
    if not self.toastActive or not self.toast then return end
    local p = self.db.profile
    local data = self.toastActive
    local scale = p.notificationSize or 1
    local style = p.notificationStyle or "banner"
    local width, height, fontSize
    if style == "compact" then width,height,fontSize = 390,54,(data.super and 18 or 14); self.toast.icon:Show()
    elseif style == "minimal" then width,height,fontSize = 430,48,(data.super and 19 or 15); self.toast.icon:Hide()
    else width,height,fontSize = (data.super and 590 or 480),(data.super and 82 or 66),(data.super and 22 or 17); self.toast.icon:Show() end
    self.toast:SetWidth(width * scale); self.toast:SetHeight(height * scale)
    V130SetFontSize(self.toast.text, fontSize * scale, p.notificationShadow and "OUTLINE" or "")
    self.toast.text:ClearAllPoints()
    if self.toast.icon:IsShown() then
        self.toast.icon:SetWidth(42 * scale); self.toast.icon:SetHeight(42 * scale)
        self.toast.icon:ClearAllPoints(); self.toast.icon:SetPoint("LEFT", 13 * scale, 0)
        self.toast.text:SetPoint("LEFT", self.toast.icon, "RIGHT", 14 * scale, 0)
    else self.toast.text:SetPoint("LEFT", 16 * scale, 0) end
    self.toast.text:SetPoint("RIGHT", -16 * scale, 0)
    local color = self:GetNotificationColor()
    if style == "minimal" then
        self.toast:SetBackdropColor(0,0,0,0.55)
        self.toast:SetBackdropBorderColor(0,0,0,0)
    else
        self.toast:SetBackdropColor(PANEL_2[1],PANEL_2[2],PANEL_2[3],0.98)
        self.toast:SetBackdropBorderColor(color[1],color[2],color[3],1)
    end
    self.toast.text:SetTextColor(data.super and 1 or TEXT[1], data.super and 0.90 or TEXT[2], data.super and 1 or TEXT[3], 1)
    self:ApplyNotificationPosition()
    self.toast:SetAlpha(0)
end

function GMG:UpdateToast(elapsed)
    if not self.toastActive or not self.toast then return end
    self.toastElapsed = (self.toastElapsed or 0) + elapsed
    local p = self.db.profile
    local duration = p.notificationDuration or 4.2
    local opacity = p.notificationOpacity or 1
    local animation = p.notificationAnimation or "fade"
    local fadeIn, fadeOut = min(0.35,duration*0.16), min(0.6,duration*0.20)
    local alpha = opacity
    if self.toastElapsed < fadeIn then alpha = opacity * (self.toastElapsed / fadeIn) end
    if self.toastElapsed > duration - fadeOut then alpha = opacity * max(0, (duration - self.toastElapsed) / fadeOut) end
    if animation == "pulse" then alpha = alpha * (0.84 + 0.16 * math.abs(math.sin(self.toastElapsed * 7))) end
    self.toast:SetAlpha(alpha)
    if animation == "slide" then
        local progress = min(1, self.toastElapsed / fadeIn)
        local offset = (1 - progress) * 45
        self:ApplyNotificationPosition()
        local point, relativeTo, relativePoint, x, y = self.toast:GetPoint(1)
        if point then self.toast:ClearAllPoints() end
        if point and self.db.profile.notificationPosition == "topleft" then self.toast:SetPoint(point, relativeTo, relativePoint, (x or 0) - offset, y or 0)
        elseif point and self.db.profile.notificationPosition == "topright" then self.toast:SetPoint(point, relativeTo, relativePoint, (x or 0) + offset, y or 0)
        elseif point then self.toast:SetPoint(point, relativeTo, relativePoint, x or 0, (y or 0) + offset) end
    end
    if self.toastElapsed >= duration then
        self.toast:Hide(); self.toastActive = nil; self:StartNextToast()
    end
end

function GMG:OnUpdate(elapsed)
    V130OriginalOnUpdate(self, elapsed)
    self:UpdateAdaptiveWindowAlpha(elapsed)
end

-- v1.3.6: preserve native World of Warcraft hyperlinks in the shared guild chat.
-- Items, spells, quests, achievements, talents and other native links use the
-- normal Blizzard SetItemRef handler. Addon-only player and URL links keep
-- their custom behaviour.
function GMG:InstallGuildChatHyperlinkHandlers()
    local messages = self.chatPage and self.chatPage.messages
    if not messages then return end

    if messages.SetHyperlinksEnabled then messages:SetHyperlinksEnabled(true) end

    messages:SetScript("OnHyperlinkClick", function(frame, link, displayText, button)
        link = tostring(link or "")

        local playerName = string.match(link, "^gmgplayer:(.+)$")
        if playerName then
            GMG:OpenChatMemberMenu(playerName, frame, button)
            return
        end

        local urlID = string.match(link, "^gmgurl:(.+)$")
        if urlID then
            if GMG.copyableURLs and GMG.copyableURLs[urlID] then
                GMG:OpenCopyLink(GMG.copyableURLs[urlID])
            end
            return
        end

        -- Delegate all native WoW links to Blizzard's standard link handler.
        -- This opens item/spell/quest/etc. tooltips and keeps shift-click and
        -- modified-click behaviour compatible with the 3.3.5a client.
        if SetItemRef then
            SetItemRef(link, displayText or link, button or "LeftButton")
        elseif ChatFrame_OnHyperlinkShow then
            ChatFrame_OnHyperlinkShow(frame, link, displayText or link, button or "LeftButton")
        end
    end)

    messages:SetScript("OnHyperlinkEnter", function(frame, link)
        link = tostring(link or "")
        if string.find(link, "^gmgplayer:") or string.find(link, "^gmgurl:") then return end
        if not GameTooltip or not GameTooltip.SetHyperlink then return end

        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
        local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
        if ok then
            GameTooltip:Show()
        else
            GameTooltip:Hide()
        end
    end)

    messages:SetScript("OnHyperlinkLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)
end

local GMGCreateUIBeforeNativeLinksV136 = GMG.CreateUI
function GMG:CreateUI(...)
    GMGCreateUIBeforeNativeLinksV136(self, ...)
    self:InstallGuildChatHyperlinkHandlers()
end


-- v1.3.7 crash-safe lazy interface creation.
-- The complete UI and its external textures are no longer loaded during PLAYER_LOGIN.
local GMGToggleBeforeLazyV137 = GMG.Toggle
function GMG:Toggle()
    if not self.mainFrame then
        if self.CreateUI then self:CreateUI() end
        self.uiPending = nil
    end
    if not self.mainFrame then return end
    if self.mainFrame:IsShown() then self.mainFrame:Hide() else self.mainFrame:Show() end
end


-- v1.3.8: hide every guild-logo region when the player is guildless.
local GMGOriginalRefreshHeaderV138 = GMG.RefreshHeader
function GMG:RefreshHeader()
    GMGOriginalRefreshHeaderV138(self)
    if not self.mainFrame or not self.mainFrame.guildImage then return end

    self.mainFrame.brand:ClearAllPoints()
    self.mainFrame.guildName:ClearAllPoints()

    if self:IsInGuild() then
        self.mainFrame.guildImage:SetTexture(self:GetGuildImageTexture())
        self.mainFrame.guildImage:Show()
        self.mainFrame.brand:SetPoint("TOPLEFT", self.mainFrame.guildImage, "TOPRIGHT", 8, -1)
        self.mainFrame.guildName:SetPoint("TOPLEFT", self.mainFrame.guildImage, "TOPRIGHT", 8, -19)
    else
        self.mainFrame.guildImage:SetTexture(nil)
        self.mainFrame.guildImage:Hide()
        self.mainFrame.brand:SetPoint("TOPLEFT", self.mainFrame.header, "TOPLEFT", 14, -13)
        self.mainFrame.guildName:SetPoint("TOPLEFT", self.mainFrame.header, "TOPLEFT", 14, -31)
    end
end

local GMGOriginalRefreshGuildPageV138 = GMG.RefreshGuildPage
function GMG:RefreshGuildPage()
    GMGOriginalRefreshGuildPageV138(self)
    if not self.guildPage or not self.guildPage.image then return end
    if self:IsInGuild() then
        self.guildPage.image:SetTexture(self:GetGuildImageTexture())
        self.guildPage.image:Show()
    else
        self.guildPage.image:SetTexture(nil)
        self.guildPage.image:Hide()
    end
end


-- ============================================================================
-- v1.4.0 progressive portrait presentation.
-- Visible widgets receive only the built-in placeholder until a 64x64 TGA has
-- been preloaded. This prevents the bright-green missing-texture blocks.
-- ============================================================================
function GMG:RefreshImagePickerSelection()
    local frame = self.imagePicker
    if not frame then return end
    local selected = frame.selectedTexture
    local display = selected
    if self:IsProgressivePortraitTexture(selected) and not self.portraitReady[selected] then
        self:QueuePortraitTexture(selected, true)
        display = self.SAFE_PORTRAIT_PLACEHOLDER
    end
    frame.preview:SetTexture(display or self.SAFE_PORTRAIT_PLACEHOLDER)
    for _, button in ipairs(frame.buttons) do
        if button.texturePath and button.texturePath == selected then
            button:SetBackdropBorderColor(unpack(ACCENT))
            button:SetBackdropColor(unpack(ACCENT_SOFT))
        else
            button:SetBackdropBorderColor(unpack(BORDER))
            button:SetBackdropColor(unpack(PANEL_3))
        end
    end
end

function GMG:RefreshImagePickerCategory()
    local frame = self.imagePicker
    if not frame then return end
    for index, button in ipairs(frame.buttons) do
        local preset = self.IMAGE_PRESETS[index]
        if preset then
            button.texturePath = preset.texture
            button.presetName = preset.name
            self:QueuePortraitTexture(preset.texture, false)
            if self.portraitReady[preset.texture] then
                button.texture:SetTexture(preset.texture)
            else
                button.texture:SetTexture(self.SAFE_PORTRAIT_PLACEHOLDER)
            end
            button:Show()
        else
            button.texturePath = nil
            button.presetName = nil
            button:Hide()
        end
    end
    self:RefreshImagePickerSelection()
end

function GMG:OpenImagePicker(mode)
    if mode == "guild" and not self:CanEditGuildImage() then self:Print(self:L("GUILD_MASTER_ONLY")); return end
    self:StartPortraitLoading()
    local frame = self.imagePicker
    frame.mode = mode
    frame.selectedTexture = mode == "guild" and self:GetDesiredGuildImageTexture() or self:GetDesiredOwnAvatar()
    frame.custom:SetText("")
    SetBoundedText(frame.title, mode == "guild" and self:L("CHANGE_GUILD_IMAGE") or self:L("CHANGE_CHARACTER_IMAGE"), 610)
    frame.category = "all"
    self:RefreshImagePickerCategory()
    frame:Show()
    if self.EnhanceImagePicker then self:EnhanceImagePicker() end
end

local GMGToggleBeforeProgressiveV140 = GMG.Toggle
function GMG:Toggle()
    GMGToggleBeforeProgressiveV140(self)
    if self.mainFrame and self.mainFrame:IsShown() then
        self:StartPortraitLoading()
        self:RefreshHeader()
        self:RefreshRoster()
    end
end

local GMGRefreshHeaderBeforeProgressiveV140 = GMG.RefreshHeader
function GMG:RefreshHeader()
    GMGRefreshHeaderBeforeProgressiveV140(self)
    if not self.mainFrame or not self.mainFrame.guildImage then return end
    local texture = self:GetGuildImageTexture()
    self.mainFrame.brand:ClearAllPoints()
    self.mainFrame.guildName:ClearAllPoints()
    if self:IsInGuild() and texture then
        self.mainFrame.guildImage:SetTexture(texture)
        self.mainFrame.guildImage:Show()
        self.mainFrame.brand:SetPoint("TOPLEFT", self.mainFrame.guildImage, "TOPRIGHT", 8, -1)
        self.mainFrame.guildName:SetPoint("TOPLEFT", self.mainFrame.guildImage, "TOPRIGHT", 8, -19)
    else
        self.mainFrame.guildImage:SetTexture(nil)
        self.mainFrame.guildImage:Hide()
        self.mainFrame.brand:SetPoint("TOPLEFT", self.mainFrame.header, "TOPLEFT", 14, -13)
        self.mainFrame.guildName:SetPoint("TOPLEFT", self.mainFrame.header, "TOPLEFT", 14, -31)
    end
end

local GMGRefreshGuildPageBeforeProgressiveV140 = GMG.RefreshGuildPage
function GMG:RefreshGuildPage()
    GMGRefreshGuildPageBeforeProgressiveV140(self)
    if not self.guildPage or not self.guildPage.image then return end
    local texture = self:GetGuildImageTexture()
    if self:IsInGuild() and texture then
        self.guildPage.image:SetTexture(texture)
        self.guildPage.image:Show()
    else
        self.guildPage.image:SetTexture(nil)
        self.guildPage.image:Hide()
    end
end

-- ============================================================================
-- v1.6.2: paginated portrait picker with a more compact preview while keeping full-quality 256x256 source assets for every packaged
-- profile image. Only portraits on the active page are queued for loading.
-- ============================================================================
local GMGEnhanceImagePickerBeforeV159 = GMG.EnhanceImagePicker
function GMG:EnhanceImagePicker()
    GMGEnhanceImagePickerBeforeV159(self)
    local frame = self.imagePicker
    if not frame then return end

    frame:SetWidth(1060)
    frame:SetHeight(720)
    SetOneLine(frame.title, 1008)
    frame.title:ClearAllPoints()
    frame.title:SetPoint("TOPLEFT", 26, -22)

    frame.customTitle:Hide()
    frame.customHolder:Hide()
    frame.customHelp:Hide()

    if not frame.v159GridPanel then
        frame.v159GridPanel = CreateFrame("Frame", nil, frame)
        frame.v159GridPanel:SetWidth(660)
        frame.v159GridPanel:SetHeight(610)
        frame.v159GridPanel:SetPoint("TOPLEFT", 24, -76)
        SetBackdrop(frame.v159GridPanel, PANEL_2, BORDER)
    end

    frame.builtinTitle:SetParent(frame.v159GridPanel)
    frame.builtinTitle:ClearAllPoints()
    frame.builtinTitle:SetPoint("TOPLEFT", 18, -18)
    SetOneLine(frame.builtinTitle, 620)

    frame.portraitsPerPage = 24
    frame.portraitPage = frame.portraitPage or 1

    for index, button in ipairs(frame.buttons) do
        button:SetParent(frame.v159GridPanel)
        button:ClearAllPoints()
        if index <= frame.portraitsPerPage then
            local column = (index - 1) % 6
            local row = floor((index - 1) / 6)
            button:SetWidth(80)
            button:SetHeight(80)
            button:SetPoint("TOPLEFT", 24 + column * 102, -64 - row * 104)
            button.texture:ClearAllPoints()
            button.texture:SetPoint("TOPLEFT", 5, -5)
            button.texture:SetPoint("BOTTOMRIGHT", -5, 5)
        else
            button:Hide()
        end
    end

    if not frame.pagePrevious then
        frame.pagePrevious = CreateFlatButton(frame.v159GridPanel, "<", 52, 34)
        frame.pagePrevious:SetPoint("BOTTOM", frame.v159GridPanel, "BOTTOM", -170, 20)
        frame.pagePrevious:SetScript("OnClick", function()
            GMG:SetImagePickerPage((frame.portraitPage or 1) - 1)
        end)

        frame.pageLabel = CreateText(frame.v159GridPanel, "GameFontNormal", "Page 1 / 1", 12)
        frame.pageLabel:SetWidth(290)
        frame.pageLabel:SetHeight(34)
        frame.pageLabel:SetPoint("CENTER", frame.v159GridPanel, "BOTTOM", 0, 38)
        frame.pageLabel:SetJustifyH("CENTER")
        frame.pageLabel:SetJustifyV("MIDDLE")

        frame.pageNext = CreateFlatButton(frame.v159GridPanel, ">", 52, 34)
        frame.pageNext:SetPoint("BOTTOM", frame.v159GridPanel, "BOTTOM", 170, 20)
        frame.pageNext:SetScript("OnClick", function()
            GMG:SetImagePickerPage((frame.portraitPage or 1) + 1)
        end)

        frame:EnableMouseWheel(true)
        frame:SetScript("OnMouseWheel", function(_, delta)
            if delta > 0 then
                GMG:SetImagePickerPage((frame.portraitPage or 1) - 1)
            elseif delta < 0 then
                GMG:SetImagePickerPage((frame.portraitPage or 1) + 1)
            end
        end)
    end

    frame.largePreviewPanel:ClearAllPoints()
    frame.largePreviewPanel:SetWidth(300)
    frame.largePreviewPanel:SetHeight(610)
    frame.largePreviewPanel:SetPoint("TOPRIGHT", -24, -76)

    frame.largePreviewTitle:ClearAllPoints()
    frame.largePreviewTitle:SetPoint("TOPLEFT", 18, -18)
    frame.largePreviewTitle:SetPoint("TOPRIGHT", -18, -18)
    SetOneLine(frame.largePreviewTitle, 308)

    frame.largePreviewBackdrop:ClearAllPoints()
    frame.largePreviewBackdrop:SetWidth(276)
    frame.largePreviewBackdrop:SetHeight(276)
    frame.largePreviewBackdrop:SetPoint("TOP", 0, -62)

    frame.preview:SetParent(frame.largePreviewBackdrop)
    frame.preview:ClearAllPoints()
    frame.preview:SetWidth(192)
    frame.preview:SetHeight(192)
    frame.preview:SetPoint("CENTER", frame.largePreviewBackdrop, "CENTER", 0, 0)
    frame.preview:SetTexCoord(0, 1, 0, 1)

    if not frame.selectedImageName then
        frame.selectedImageName = CreateText(frame.largePreviewPanel, "GameFontNormalSmall", "", 11)
        frame.selectedImageName:SetPoint("TOPLEFT", 20, -270)
        frame.selectedImageName:SetPoint("TOPRIGHT", -20, -270)
        frame.selectedImageName:SetHeight(1)
        frame.selectedImageName:SetJustifyH("CENTER")
        frame.selectedImageName:SetJustifyV("TOP")
        frame.selectedImageName:SetTextColor(unpack(MUTED))
    end
    frame.selectedImageName:SetText("")
    frame.selectedImageName:Hide()

    frame.apply:ClearAllPoints()
    frame.apply:SetWidth(268)
    frame.apply:SetHeight(38)
    frame.apply:SetPoint("BOTTOM", frame.largePreviewPanel, "BOTTOM", 0, 72)

    frame.close:ClearAllPoints()
    frame.close:SetWidth(268)
    frame.close:SetHeight(38)
    frame.close:SetPoint("BOTTOM", frame.largePreviewPanel, "BOTTOM", 0, 24)

    frame.v159Enhanced = true
end

function GMG:SetImagePickerPage(page)
    local frame = self.imagePicker
    if not frame then return end
    local perPage = frame.portraitsPerPage or 24
    local total = #self.IMAGE_PRESETS
    local maxPage = max(1, math.ceil(total / perPage))
    page = max(1, min(maxPage, tonumber(page) or 1))
    if frame.portraitPage == page and frame.v159PageDrawn then return end
    frame.portraitPage = page
    frame.v159PageDrawn = true
    self:RefreshImagePickerCategory()
end

function GMG:RefreshImagePickerCategory()
    local frame = self.imagePicker
    if not frame then return end
    local perPage = frame.portraitsPerPage or 24
    local total = #self.IMAGE_PRESETS
    local maxPage = max(1, math.ceil(total / perPage))
    frame.portraitPage = max(1, min(maxPage, tonumber(frame.portraitPage) or 1))
    local firstPreset = (frame.portraitPage - 1) * perPage

    for slot, button in ipairs(frame.buttons) do
        local preset = slot <= perPage and self.IMAGE_PRESETS[firstPreset + slot] or nil
        if preset then
            button.texturePath = preset.texture
            button.presetName = preset.name
            self:QueuePortraitTexture(preset.texture, false)
            if self.portraitReady[preset.texture] then
                button.texture:SetTexture(preset.texture)
            else
                button.texture:SetTexture(self.SAFE_PORTRAIT_PLACEHOLDER)
            end
            button:Show()
        else
            button.texturePath = nil
            button.presetName = nil
            button.texture:SetTexture(nil)
            button:Hide()
        end
    end

    if frame.pageLabel then
        frame.pageLabel:SetText("Page " .. frame.portraitPage .. " / " .. maxPage .. "  |  " .. total .. " images")
    end
    if frame.pagePrevious then
        if frame.portraitPage > 1 then frame.pagePrevious:Enable() else frame.pagePrevious:Disable() end
    end
    if frame.pageNext then
        if frame.portraitPage < maxPage then frame.pageNext:Enable() else frame.pageNext:Disable() end
    end

    self:RefreshImagePickerSelection()
end

local GMGRefreshImagePickerSelectionBeforeV159 = GMG.RefreshImagePickerSelection
function GMG:RefreshImagePickerSelection()
    GMGRefreshImagePickerSelectionBeforeV159(self)
    local frame = self.imagePicker
    if not frame then return end
    if frame.preview then
        frame.preview:SetWidth(192)
        frame.preview:SetHeight(192)
        frame.preview:SetTexCoord(0, 1, 0, 1)
    end
    if frame.selectedImageName then
        local selectedName = ""
        for _, preset in ipairs(self.IMAGE_PRESETS) do
            if preset.texture == frame.selectedTexture then
                selectedName = preset.name or ""
                break
            end
        end
        frame.selectedImageName:SetText("")
        frame.selectedImageName:Hide()
    end
end

local GMGOpenImagePickerBeforeV159 = GMG.OpenImagePicker
function GMG:OpenImagePicker(mode)
    GMGOpenImagePickerBeforeV159(self, mode)
    local frame = self.imagePicker
    if not frame then return end
    self:EnhanceImagePicker()

    local selectedIndex = 1
    for index, preset in ipairs(self.IMAGE_PRESETS) do
        if preset.texture == frame.selectedTexture then
            selectedIndex = index
            break
        end
    end
    local perPage = frame.portraitsPerPage or 24
    frame.portraitPage = max(1, math.ceil(selectedIndex / perPage))
    frame.v159PageDrawn = nil
    self:RefreshImagePickerCategory()
end


-- ============================================================================
-- v1.6.4: restore the lightweight online/notification launcher at login and fix its title width.
-- The launcher must not depend on opening the full guild window.
-- ============================================================================
function GMG:RefreshLauncherStatus()
    if not self.launcher then return end
    local online = 0
    for _, member in ipairs(self.rosterMembers or {}) do
        if member.online then online = online + 1 end
    end
    if self.launcher.count then self.launcher.count:SetText(tostring(online)) end
    if self.launcher.title then SetBoundedText(self.launcher.title, self:L("LAUNCHER"), 72) end
    if self.db and self.db.profile and self.db.profile.launcherShown ~= false then
        self.launcher:Show()
    end
end

local GMGRefreshAllBeforeLauncherV163 = GMG.RefreshAll
function GMG:RefreshAll(force)
    if GMGRefreshAllBeforeLauncherV163 then GMGRefreshAllBeforeLauncherV163(self, force) end
    self:RefreshLauncherStatus()
    if self.RefreshUnreadGuildIndicators then self:RefreshUnreadGuildIndicators() end
end

local GMGPlayerLoginBeforeLauncherV163 = GMG.PLAYER_LOGIN
function GMG:PLAYER_LOGIN(...)
    if GMGPlayerLoginBeforeLauncherV163 then GMGPlayerLoginBeforeLauncherV163(self, ...) end

    self.db.profile.launcherVisibilityFixRevision = tonumber(self.db.profile.launcherVisibilityFixRevision) or 0
    if self.db.profile.launcherVisibilityFixRevision < 163 then
        self.db.profile.launcherVisibilityFixRevision = 163
        self.db.profile.launcherShown = true
        self.db.profile.launcherPoint = "LEFT"
        self.db.profile.launcherRelativePoint = "LEFT"
        self.db.profile.launcherX = 0
        self.db.profile.launcherY = 110
    end

    self:CreateLauncher()
    self:RefreshLauncherStatus()

    self:Schedule("launcher-roster-refresh-v163", 2.2, function()
        if GMG.RebuildRosterCache then GMG:RebuildRosterCache(false) end
        if GMG.RefreshLauncherStatus then GMG:RefreshLauncherStatus() end
        if GMG.RefreshUnreadGuildIndicators then GMG:RefreshUnreadGuildIndicators() end
    end)
end


-- ============================================================================
-- v1.6.5: member-online mention list, colored connection notifications,
-- persistent green unread-mention glow setting, and usable guild-chat history.
-- ============================================================================

-- Preserve compatibility with older calls that passed true/false as the second
-- argument while allowing explicit notification kinds.
function GMG:ShowToast(text, kind)
    self.toastQueue = self.toastQueue or {}
    local resolvedKind = kind
    if kind == true then resolvedKind = "highlight"
    elseif kind == false or kind == nil then resolvedKind = "normal" end
    table.insert(self.toastQueue, {
        text = text,
        kind = resolvedKind,
        super = resolvedKind == "highlight",
    })
    if not self.toastActive then self:StartNextToast() end
end

local GMGStartNextToastBeforeV165 = GMG.StartNextToast
function GMG:StartNextToast()
    GMGStartNextToastBeforeV165(self)
    local data = self.toastActive
    if not data or not self.toast then return end
    if data.kind == "offline" then
        self.toast:SetBackdropColor(0.20, 0.035, 0.045, 0.98)
        self.toast:SetBackdropBorderColor(1.00, 0.16, 0.20, 1)
        self.toast.text:SetTextColor(1.00, 0.74, 0.76, 1)
        self.toast.icon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathScream")
    elseif data.kind == "highlight" then
        self.toast:SetBackdropColor(0.025, 0.18, 0.075, 0.98)
        self.toast:SetBackdropBorderColor(0.18, 1.00, 0.42, 1)
        self.toast.text:SetTextColor(0.78, 1.00, 0.84, 1)
        self.toast.icon:SetTexture("Interface\\Icons\\Spell_Nature_NatureBlessing")
    end
end

local GMGInitializeChatMemberMenuBeforeV165 = GMG.InitializeChatMemberMenu
function GMG:InitializeChatMemberMenu(level)
    if level ~= 1 or not self.contextChatName then return end
    local name = self.contextChatName
    local function Add(text, func, checked)
        local info = UIDropDownMenu_CreateInfo()
        info.text = text
        info.func = func
        info.notCheckable = checked == nil
        if checked ~= nil then info.checked = checked end
        UIDropDownMenu_AddButton(info, level)
    end
    Add(self:L("WHISPER"), function() if ChatFrame_SendTell then ChatFrame_SendTell(name) end end)
    Add(self:L("INVITE"), function() if InviteUnit then InviteUnit(name); GMG:Print(GMG:L("INVITED", name)) end end)
    Add(self:L("MENTION"), function() GMG:ShowTab("chat"); GMG:MentionPlayer(name) end)
    Add(self:L("LOGIN_ALERT"), function()
        GMG:ToggleHighlighted(name)
        if GMG.RefreshSettings then GMG:RefreshSettings() end
        CloseDropDownMenus()
    end, self:IsHighlighted(name))
    Add(self:L("CANCEL"), function() CloseDropDownMenus() end)
end

local GMGCreateSettingsPageBeforeV165 = GMG.CreateSettingsPage
function GMG:CreateSettingsPage()
    GMGCreateSettingsPageBeforeV165(self)
    local page = self.settingsPage
    if not page or page.v165MentionSettings then return end
    page.v165MentionSettings = true

    -- Extra unread-mention glow setting in the Notifications section.
    page.mentionUnreadGlow = CreateCheck(page.left, self:L("MENTION_UNREAD_GLOW"), 360)
    page.mentionUnreadGlow:SetPoint("TOPLEFT", 18, -252)
    page.mentionUnreadGlow:SetScript("OnClick", function(button)
        button:SetChecked(not button:GetChecked())
        GMG.db.profile.mentionUnreadGlow = button:GetChecked()
        GMG:PersistSettings()
        if GMG.RefreshUnreadGuildIndicators then GMG:RefreshUnreadGuildIndicators() end
    end)
    page.mentionUnreadGlow:SetScript("OnEnter", function(button)
        button.label:SetTextColor(1, 1, 1, 1)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L("MENTION_UNREAD_GLOW"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("MENTION_UNREAD_GLOW_HELP"), 0.72, 0.74, 0.84, true)
        GameTooltip:Show()
    end)
    page.mentionUnreadGlow:SetScript("OnLeave", function(button)
        button.label:SetTextColor(unpack(TEXT))
        GameTooltip:Hide()
    end)

    -- Move the sections below it down so nothing overlaps.
    page.displayTitle:ClearAllPoints(); page.displayTitle:SetPoint("TOPLEFT", 18, -292)
    page.showOffline:ClearAllPoints(); page.showOffline:SetPoint("TOPLEFT", 18, -322)
    page.showLauncher:ClearAllPoints(); page.showLauncher:SetPoint("TOPLEFT", 18, -352)
    page.keyTitle:ClearAllPoints(); page.keyTitle:SetPoint("TOPLEFT", 18, -393)
    page.currentKey:ClearAllPoints(); page.currentKey:SetPoint("TOPLEFT", 18, -421)
    page.changeKey:ClearAllPoints(); page.changeKey:SetPoint("TOPLEFT", 18, -451)
    page.clearKey:ClearAllPoints(); page.clearKey:SetPoint("LEFT", page.changeKey, "RIGHT", 12, 0)

    -- Per-guild list of members selected for an online mention.
    page.loginMentionTitle = CreateText(page.right, "GameFontNormal", self:L("LOGIN_MENTION_LIST"), 13)
    page.loginMentionTitle:SetPoint("TOPLEFT", 20, -382)
    page.loginMentionTitle:SetPoint("TOPRIGHT", -20, -382)
    page.loginMentionTitle:SetJustifyH("LEFT")
    SetOneLine(page.loginMentionTitle, 330)

    page.loginMentionRows = {}
    for index = 1, 4 do
        local row = CreateFrame("Frame", nil, page.right)
        row:SetHeight(28)
        row:SetPoint("TOPLEFT", 20, -408 - (index - 1) * 31)
        row:SetPoint("TOPRIGHT", -20, -408 - (index - 1) * 31)
        SetBackdrop(row, PANEL_3, BORDER)
        row.name = CreateText(row, "GameFontNormalSmall", "", 11)
        row.name:SetPoint("LEFT", 9, 0)
        row.name:SetPoint("RIGHT", -42, 0)
        row.name:SetJustifyH("LEFT")
        row.remove = CreateFlatButton(row, "X", 30, 22)
        row.remove:SetPoint("RIGHT", -3, 0)
        row.remove:SetScript("OnClick", function(button)
            if button.memberName then GMG:RemoveHighlighted(button.memberName) end
        end)
        row:Hide()
        page.loginMentionRows[index] = row
    end

    page.loginMentionEmpty = CreateText(page.right, "GameFontNormalSmall", self:L("LOGIN_MENTION_LIST_EMPTY"), 11)
    page.loginMentionEmpty:SetPoint("TOPLEFT", 28, -416)
    page.loginMentionEmpty:SetPoint("TOPRIGHT", -28, -416)
    page.loginMentionEmpty:SetTextColor(unpack(MUTED))
    page.loginMentionEmpty:SetJustifyH("LEFT")

    page.loginMentionPage = 1
    page.loginMentionPrev = CreateFlatButton(page.right, "<", 32, 26)
    page.loginMentionPrev:SetPoint("BOTTOMLEFT", 20, 14)
    page.loginMentionPrev:SetScript("OnClick", function()
        page.loginMentionPage = max(1, (page.loginMentionPage or 1) - 1)
        GMG:RefreshMentionWatchList()
    end)
    page.loginMentionPageLabel = CreateText(page.right, "GameFontNormalSmall", "1 / 1", 10)
    page.loginMentionPageLabel:SetWidth(80)
    page.loginMentionPageLabel:SetPoint("LEFT", page.loginMentionPrev, "RIGHT", 6, 0)
    page.loginMentionPageLabel:SetJustifyH("CENTER")
    page.loginMentionNext = CreateFlatButton(page.right, ">", 32, 26)
    page.loginMentionNext:SetPoint("LEFT", page.loginMentionPageLabel, "RIGHT", 6, 0)
    page.loginMentionNext:SetScript("OnClick", function()
        page.loginMentionPage = (page.loginMentionPage or 1) + 1
        GMG:RefreshMentionWatchList()
    end)
    page.clearLoginMentions = CreateFlatButton(page.right, self:L("CLEAR_LOGIN_MENTION_LIST"), 132, 26)
    page.clearLoginMentions:SetPoint("BOTTOMRIGHT", -20, 14)
    page.clearLoginMentions:SetScript("OnClick", function() GMG:ClearHighlighted() end)

    self:RefreshMentionWatchList()
end

function GMG:RefreshMentionWatchList()
    local page = self.settingsPage
    if not page or not page.loginMentionRows then return end
    local names = self:GetHighlightedNames()
    local perPage = #page.loginMentionRows
    local maxPage = max(1, math.ceil(#names / perPage))
    page.loginMentionPage = max(1, min(maxPage, tonumber(page.loginMentionPage) or 1))
    local offset = (page.loginMentionPage - 1) * perPage
    for index, row in ipairs(page.loginMentionRows) do
        local name = names[offset + index]
        if name then
            row.memberName = name
            row.remove.memberName = name
            SetBoundedText(row.name, name, 250)
            row:Show()
        else
            row.memberName = nil
            row.remove.memberName = nil
            row:Hide()
        end
    end
    if #names == 0 then page.loginMentionEmpty:Show() else page.loginMentionEmpty:Hide() end
    page.loginMentionPageLabel:SetText(page.loginMentionPage .. " / " .. maxPage)
    if page.loginMentionPage > 1 then page.loginMentionPrev:Enable() else page.loginMentionPrev:Disable() end
    if page.loginMentionPage < maxPage then page.loginMentionNext:Enable() else page.loginMentionNext:Disable() end
    if #names > 0 then page.clearLoginMentions:Enable() else page.clearLoginMentions:Disable() end
end

local GMGRefreshSettingsBeforeV165 = GMG.RefreshSettings
function GMG:RefreshSettings(...)
    GMGRefreshSettingsBeforeV165(self, ...)
    local page = self.settingsPage
    if not page then return end
    if page.mentionUnreadGlow then page.mentionUnreadGlow:SetChecked(self.db.profile.mentionUnreadGlow ~= false) end
    self:RefreshMentionWatchList()
end

local GMGRefreshLocalizationBeforeV165 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV165(self, ...)
    local page = self.settingsPage
    if page and page.mentionUnreadGlow then
        SetBoundedText(page.mentionUnreadGlow.label, self:L("MENTION_UNREAD_GLOW"), 333)
        page.loginMentionTitle:SetText(self:L("LOGIN_MENTION_LIST"))
        page.loginMentionEmpty:SetText(self:L("LOGIN_MENTION_LIST_EMPTY"))
        SetBoundedText(page.clearLoginMentions.label, self:L("CLEAR_LOGIN_MENTION_LIST"), 120)
    end
    if self.chatPage and self.chatPage.latestMessages then
        SetBoundedText(self.chatPage.latestMessages.label, self:L("LATEST_MESSAGES"), 126)
    end
end

local GMGCreateChatPageBeforeV165 = GMG.CreateChatPage
function GMG:CreateChatPage()
    GMGCreateChatPageBeforeV165(self)
    local page = self.chatPage
    if not page or page.v165HistoryScrolling then return end
    page.v165HistoryScrolling = true
    page.userReadingHistory = false

    page.latestMessages = CreateFlatButton(page.history, self:L("LATEST_MESSAGES"), 138, 25)
    page.latestMessages:SetPoint("BOTTOMRIGHT", -39, 8)
    page.latestMessages:SetFrameLevel(page.history:GetFrameLevel() + 4)
    page.latestMessages:SetScript("OnClick", function()
        page.userReadingHistory = false
        page.latestMessages:Hide()
        GMG:RefreshChat(true)
        page.messages:ScrollToBottom()
        page.scroll:SetValue(1)
    end)
    page.latestMessages:Hide()

    local function ScrollHistory(delta)
        if delta > 0 then
            page.userReadingHistory = true
            page.latestMessages:Show()
            if IsShiftKeyDown and IsShiftKeyDown() then
                page.messages:ScrollToTop()
            else
                for _ = 1, 4 do if page.messages.ScrollUp then page.messages:ScrollUp() end end
            end
        elseif delta < 0 then
            for _ = 1, 4 do if page.messages.ScrollDown then page.messages:ScrollDown() end end
        end
    end
    page.messages:EnableMouseWheel(true)
    page.messages:SetScript("OnMouseWheel", function(_, delta) ScrollHistory(delta) end)
    page.history:EnableMouseWheel(true)
    page.history:SetScript("OnMouseWheel", function(_, delta) ScrollHistory(delta) end)
    page.scroll:SetScript("OnValueChanged", function(_, value)
        if value <= 0 then
            page.userReadingHistory = true
            page.latestMessages:Show()
            page.messages:ScrollToTop()
        else
            page.userReadingHistory = false
            page.latestMessages:Hide()
            if GMG.chatDirty then GMG:RefreshChat(true) end
            page.messages:ScrollToBottom()
        end
    end)
end

local GMGOnHistoryChangedBeforeV165 = GMG.OnHistoryChanged
function GMG:OnHistoryChanged()
    if self.chatPage and self.chatPage:IsShown() and self.chatPage.userReadingHistory then
        -- Keep the current historical view stable. The latest button applies all
        -- messages accumulated while the player was reading older lines.
        self.chatDirty = true
        if self.chatPage.latestMessages then self.chatPage.latestMessages:Show() end
        if self.guildPage and self.guildPage:IsShown() then self:RefreshGuildPage() end
        return
    end
    GMGOnHistoryChangedBeforeV165(self)
end


-- v1.7.0: cleaner professional settings layout and filled theme-color toggles.
function GMG:ApplyProfessionalSettingsLayout()
    local page = self.settingsPage
    if not page or not page.left or not page.right then return end

    page.left:ClearAllPoints()
    page.left:SetPoint("TOPLEFT", 22, -58)
    page.left:SetPoint("BOTTOMLEFT", 22, 22)
    page.left:SetWidth(412)

    page.right:ClearAllPoints()
    page.right:SetPoint("TOPLEFT", page.left, "TOPRIGHT", 16, 0)
    page.right:SetPoint("BOTTOMRIGHT", -22, 22)

    page.title:ClearAllPoints()
    page.title:SetPoint("TOPLEFT", 22, -20)

    page.languageTitle:ClearAllPoints(); page.languageTitle:SetPoint("TOPLEFT", 18, -18)
    page.languageHelp:ClearAllPoints(); page.languageHelp:SetPoint("TOPLEFT", 18, -44); page.languageHelp:SetPoint("TOPRIGHT", -18, -44); page.languageHelp:SetHeight(30)
    if page.languageButtons then
        for index, button in ipairs(page.languageButtons) do
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", 18 + (index - 1) * 118, -84)
        end
    end

    page.notificationsTitle:ClearAllPoints(); page.notificationsTitle:SetPoint("TOPLEFT", 18, -132)
    page.notifyOnline:ClearAllPoints(); page.notifyOnline:SetPoint("TOPLEFT", 18, -162)
    page.notifyOffline:ClearAllPoints(); page.notifyOffline:SetPoint("TOPLEFT", 18, -194)
    page.mentionFlash:ClearAllPoints(); page.mentionFlash:SetPoint("TOPLEFT", 18, -226)
    if page.mentionUnreadGlow then page.mentionUnreadGlow:ClearAllPoints(); page.mentionUnreadGlow:SetPoint("TOPLEFT", 18, -258) end

    page.displayTitle:ClearAllPoints(); page.displayTitle:SetPoint("TOPLEFT", 18, -302)
    page.showOffline:ClearAllPoints(); page.showOffline:SetPoint("TOPLEFT", 18, -332)
    page.showLauncher:ClearAllPoints(); page.showLauncher:SetPoint("TOPLEFT", 18, -364)

    page.keyTitle:ClearAllPoints(); page.keyTitle:SetPoint("TOPLEFT", 18, -408)
    page.currentKey:ClearAllPoints(); page.currentKey:SetPoint("TOPLEFT", 18, -436)
    page.changeKey:ClearAllPoints(); page.changeKey:SetPoint("TOPLEFT", 18, -468)
    page.changeKey:SetWidth(165)
    page.clearKey:ClearAllPoints(); page.clearKey:SetPoint("LEFT", page.changeKey, "RIGHT", 12, 0)
    page.clearKey:SetWidth(165)
    if page.info then page.info:Hide() end

    page.avatarTitle:ClearAllPoints(); page.avatarTitle:SetPoint("TOPLEFT", 20, -18); page.avatarTitle:SetPoint("TOPRIGHT", -20, -18)
    page.avatar:SetWidth(132); page.avatar:SetHeight(132); page.avatar:ClearAllPoints(); page.avatar:SetPoint("TOP", 0, -52)
    page.avatarHelp:ClearAllPoints(); page.avatarHelp:SetPoint("TOPLEFT", 28, -194); page.avatarHelp:SetPoint("TOPRIGHT", -28, -194); page.avatarHelp:SetHeight(30)
    page.changeAvatar:ClearAllPoints(); page.changeAvatar:SetWidth(260); page.changeAvatar:SetPoint("TOP", 0, -236)
    page.sharedLabel:ClearAllPoints(); page.sharedLabel:SetPoint("TOPLEFT", 24, -282); page.sharedLabel:SetPoint("TOPRIGHT", -24, -282)

    if page.fadeInCombat then page.fadeInCombat:ClearAllPoints(); page.fadeInCombat:SetPoint("TOPLEFT", 20, -322) end
    if page.fadeWhileMoving then page.fadeWhileMoving:ClearAllPoints(); page.fadeWhileMoving:SetPoint("TOPLEFT", 20, -354) end

    if page.notificationAdvanced then
        page.notificationAdvanced:ClearAllPoints()
        page.notificationAdvanced:SetWidth(150)
        page.notificationAdvanced:SetPoint("TOPLEFT", 20, -396)
    end
    if page.appearanceAdvanced then
        page.appearanceAdvanced:ClearAllPoints()
        page.appearanceAdvanced:SetWidth(150)
        page.appearanceAdvanced:SetPoint("TOPRIGHT", -20, -396)
    end

    if page.loginMentionRows and page.loginMentionRows[4] then
        page.loginMentionRows[4]:Hide()
        page.loginMentionRows[4] = nil
    end
    if page.loginMentionTitle then
        page.loginMentionTitle:ClearAllPoints()
        page.loginMentionTitle:SetPoint("BOTTOMLEFT", 20, 144)
        page.loginMentionTitle:SetPoint("BOTTOMRIGHT", -20, 144)
    end
    if page.loginMentionEmpty then
        page.loginMentionEmpty:ClearAllPoints()
        page.loginMentionEmpty:SetPoint("BOTTOMLEFT", 28, 82)
        page.loginMentionEmpty:SetPoint("BOTTOMRIGHT", -28, 82)
    end
    local rowY = {108, 76, 44}
    if page.loginMentionRows then
        for index, row in ipairs(page.loginMentionRows) do
            row:ClearAllPoints()
            row:SetHeight(28)
            row:SetPoint("BOTTOMLEFT", 20, rowY[index] or 44)
            row:SetPoint("BOTTOMRIGHT", -20, rowY[index] or 44)
            if row.name then row.name:SetPoint("LEFT", 9, 0); row.name:SetPoint("RIGHT", -44, 0) end
            if row.remove then
                row.remove:ClearAllPoints()
                row.remove:SetWidth(28)
                row.remove:SetHeight(22)
                row.remove:SetPoint("RIGHT", -3, 0)
                if row.remove.label then row.remove.label:SetText("×") end
            end
        end
    end
    if page.loginMentionPrev then page.loginMentionPrev:ClearAllPoints(); page.loginMentionPrev:SetPoint("BOTTOMLEFT", 20, 12) end
    if page.loginMentionPageLabel then page.loginMentionPageLabel:ClearAllPoints(); page.loginMentionPageLabel:SetWidth(80); page.loginMentionPageLabel:SetPoint("LEFT", page.loginMentionPrev, "RIGHT", 6, 0) end
    if page.loginMentionNext then page.loginMentionNext:ClearAllPoints(); page.loginMentionNext:SetPoint("LEFT", page.loginMentionPageLabel, "RIGHT", 6, 0) end
    if page.clearLoginMentions then page.clearLoginMentions:ClearAllPoints(); page.clearLoginMentions:SetWidth(132); page.clearLoginMentions:SetPoint("BOTTOMRIGHT", -20, 12) end

    SetBoundedText(page.notifyOnline.label, self:L("NOTIFY_ONLINE"), 338)
    SetBoundedText(page.notifyOffline.label, self:L("NOTIFY_OFFLINE"), 338)
    SetBoundedText(page.mentionFlash.label, self:L("MENTION_FLASH"), 338)
    if page.mentionUnreadGlow then SetBoundedText(page.mentionUnreadGlow.label, self:L("MENTION_UNREAD_GLOW"), 338) end
    SetBoundedText(page.showOffline.label, self:L("SHOW_OFFLINE"), 338)
    SetBoundedText(page.showLauncher.label, self:L("SHOW_LAUNCHER"), 338)
    if page.fadeInCombat then SetBoundedText(page.fadeInCombat.label, self:L("FADE_IN_COMBAT"), 292) end
    if page.fadeWhileMoving then SetBoundedText(page.fadeWhileMoving.label, self:L("FADE_WHILE_MOVING"), 292) end
    if page.notificationAdvanced and page.notificationAdvanced.label then SetBoundedText(page.notificationAdvanced.label, self:L("ADVANCED_NOTIFICATIONS"), 138) end
    if page.appearanceAdvanced and page.appearanceAdvanced.label then SetBoundedText(page.appearanceAdvanced.label, self:L("WINDOW_APPEARANCE"), 138) end
    if page.clearLoginMentions and page.clearLoginMentions.label then SetBoundedText(page.clearLoginMentions.label, self:L("CLEAR_LOGIN_MENTION_LIST"), 120) end
end

local GMGCreateSettingsPageBeforeV166 = GMG.CreateSettingsPage
function GMG:CreateSettingsPage(...)
    GMGCreateSettingsPageBeforeV166(self, ...)
    self:ApplyProfessionalSettingsLayout()
end

local GMGEnhanceMainWindowBeforeV166 = GMG.EnhanceMainWindow
function GMG:EnhanceMainWindow(...)
    GMGEnhanceMainWindowBeforeV166(self, ...)
    self:ApplyProfessionalSettingsLayout()
end

local GMGRefreshSettingsBeforeV166 = GMG.RefreshSettings
function GMG:RefreshSettings(...)
    GMGRefreshSettingsBeforeV166(self, ...)
    self:ApplyProfessionalSettingsLayout()
end

local GMGRefreshLocalizationBeforeV166 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV166(self, ...)
    self:ApplyProfessionalSettingsLayout()
end


-- v1.7.0: refined professional settings layout with no overlapping blocks.
function GMG:ApplyProfessionalSettingsLayout()
    local page = self.settingsPage
    if not page or not page.left or not page.right then return end

    -- Left panel: clean spacing.
    page.left:ClearAllPoints()
    page.left:SetPoint("TOPLEFT", 22, -58)
    page.left:SetPoint("BOTTOMLEFT", 22, 22)
    page.left:SetWidth(424)

    page.right:ClearAllPoints()
    page.right:SetPoint("TOPLEFT", page.left, "TOPRIGHT", 16, 0)
    page.right:SetPoint("BOTTOMRIGHT", -22, 22)

    page.title:ClearAllPoints()
    page.title:SetPoint("TOPLEFT", 22, -20)

    page.languageTitle:ClearAllPoints(); page.languageTitle:SetPoint("TOPLEFT", 18, -18)
    page.languageHelp:ClearAllPoints(); page.languageHelp:SetPoint("TOPLEFT", 18, -44); page.languageHelp:SetPoint("TOPRIGHT", -18, -44); page.languageHelp:SetHeight(30)
    if page.languageButtons then
        for index, button in ipairs(page.languageButtons) do
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", 18 + (index - 1) * 120, -84)
        end
    end

    page.notificationsTitle:ClearAllPoints(); page.notificationsTitle:SetPoint("TOPLEFT", 18, -134)
    page.notifyOnline:ClearAllPoints(); page.notifyOnline:SetPoint("TOPLEFT", 18, -164)
    page.notifyOffline:ClearAllPoints(); page.notifyOffline:SetPoint("TOPLEFT", 18, -198)
    page.mentionFlash:ClearAllPoints(); page.mentionFlash:SetPoint("TOPLEFT", 18, -232)
    if page.mentionUnreadGlow then page.mentionUnreadGlow:ClearAllPoints(); page.mentionUnreadGlow:SetPoint("TOPLEFT", 18, -266) end

    page.displayTitle:ClearAllPoints(); page.displayTitle:SetPoint("TOPLEFT", 18, -316)
    page.showOffline:ClearAllPoints(); page.showOffline:SetPoint("TOPLEFT", 18, -346)
    page.showLauncher:ClearAllPoints(); page.showLauncher:SetPoint("TOPLEFT", 18, -380)

    page.keyTitle:ClearAllPoints(); page.keyTitle:SetPoint("TOPLEFT", 18, -428)
    page.currentKey:ClearAllPoints(); page.currentKey:SetPoint("TOPLEFT", 18, -456)
    page.changeKey:ClearAllPoints(); page.changeKey:SetPoint("TOPLEFT", 18, -490); page.changeKey:SetWidth(166)
    page.clearKey:ClearAllPoints(); page.clearKey:SetPoint("LEFT", page.changeKey, "RIGHT", 12, 0); page.clearKey:SetWidth(166)
    if page.info then page.info:Hide() end

    -- Right panel: split into clear stacked sections.
    page.avatarTitle:ClearAllPoints(); page.avatarTitle:SetPoint("TOPLEFT", 18, -18); page.avatarTitle:SetPoint("TOPRIGHT", -18, -18)
    page.avatar:SetWidth(118); page.avatar:SetHeight(118); page.avatar:ClearAllPoints(); page.avatar:SetPoint("TOP", 0, -48)
    page.avatarHelp:ClearAllPoints(); page.avatarHelp:SetPoint("TOPLEFT", 26, -172); page.avatarHelp:SetPoint("TOPRIGHT", -26, -172); page.avatarHelp:SetHeight(28)
    page.changeAvatar:ClearAllPoints(); page.changeAvatar:SetWidth(252); page.changeAvatar:SetPoint("TOP", 0, -212)
    page.sharedLabel:ClearAllPoints(); page.sharedLabel:SetPoint("TOPLEFT", 20, -256); page.sharedLabel:SetPoint("TOPRIGHT", -20, -256)

    if page.fadeInCombat then page.fadeInCombat:ClearAllPoints(); page.fadeInCombat:SetPoint("TOPLEFT", 18, -300) end
    if page.fadeWhileMoving then page.fadeWhileMoving:ClearAllPoints(); page.fadeWhileMoving:SetPoint("TOPLEFT", 18, -332) end

    if page.notificationAdvanced then
        page.notificationAdvanced:ClearAllPoints()
        page.notificationAdvanced:SetWidth(136)
        page.notificationAdvanced:SetPoint("TOPLEFT", 18, -370)
    end
    if page.appearanceAdvanced then
        page.appearanceAdvanced:ClearAllPoints()
        page.appearanceAdvanced:SetWidth(136)
        page.appearanceAdvanced:SetPoint("TOPRIGHT", -18, -370)
    end

    -- Dedicated mention-watch area with only 2 visible rows to avoid crowding.
    if page.loginMentionTitle then
        page.loginMentionTitle:ClearAllPoints()
        page.loginMentionTitle:SetPoint("TOPLEFT", 18, -414)
        page.loginMentionTitle:SetPoint("TOPRIGHT", -18, -414)
    end
    if page.loginMentionRows then
        for index, row in ipairs(page.loginMentionRows) do
            if index <= 2 then
                row:ClearAllPoints()
                row:SetHeight(26)
                row:SetPoint("TOPLEFT", 18, -438 - (index - 1) * 30)
                row:SetPoint("TOPRIGHT", -18, -438 - (index - 1) * 30)
                if row.name then row.name:ClearAllPoints(); row.name:SetPoint("LEFT", 8, 0); row.name:SetPoint("RIGHT", -36, 0) end
                if row.remove then
                    row.remove:ClearAllPoints()
                    row.remove:SetWidth(24)
                    row.remove:SetHeight(20)
                    row.remove:SetPoint("RIGHT", -2, 0)
                    if row.remove.label then row.remove.label:SetText("×") end
                end
                row:Show()
            else
                row:Hide()
            end
        end
    end
    if page.loginMentionEmpty then
        page.loginMentionEmpty:ClearAllPoints()
        page.loginMentionEmpty:SetPoint("TOPLEFT", 24, -442)
        page.loginMentionEmpty:SetPoint("TOPRIGHT", -24, -442)
        page.loginMentionEmpty:SetHeight(48)
    end
    if page.loginMentionPrev then page.loginMentionPrev:ClearAllPoints(); page.loginMentionPrev:SetPoint("BOTTOMLEFT", 18, 14); page.loginMentionPrev:SetWidth(32) end
    if page.loginMentionPageLabel then page.loginMentionPageLabel:ClearAllPoints(); page.loginMentionPageLabel:SetWidth(62); page.loginMentionPageLabel:SetPoint("LEFT", page.loginMentionPrev, "RIGHT", 6, 0) end
    if page.loginMentionNext then page.loginMentionNext:ClearAllPoints(); page.loginMentionNext:SetPoint("LEFT", page.loginMentionPageLabel, "RIGHT", 6, 0); page.loginMentionNext:SetWidth(32) end
    if page.clearLoginMentions then page.clearLoginMentions:ClearAllPoints(); page.clearLoginMentions:SetWidth(104); page.clearLoginMentions:SetPoint("BOTTOMRIGHT", -18, 14) end

    -- Text bounds.
    SetBoundedText(page.notifyOnline.label, self:L("NOTIFY_ONLINE"), 350)
    SetBoundedText(page.notifyOffline.label, self:L("NOTIFY_OFFLINE"), 350)
    SetBoundedText(page.mentionFlash.label, self:L("MENTION_FLASH"), 350)
    if page.mentionUnreadGlow then SetBoundedText(page.mentionUnreadGlow.label, self:L("MENTION_UNREAD_GLOW"), 350) end
    SetBoundedText(page.showOffline.label, self:L("SHOW_OFFLINE"), 350)
    SetBoundedText(page.showLauncher.label, self:L("SHOW_LAUNCHER"), 350)
    if page.fadeInCombat then SetBoundedText(page.fadeInCombat.label, self:L("FADE_IN_COMBAT"), 250) end
    if page.fadeWhileMoving then SetBoundedText(page.fadeWhileMoving.label, self:L("FADE_WHILE_MOVING"), 250) end
    if page.notificationAdvanced and page.notificationAdvanced.label then SetBoundedText(page.notificationAdvanced.label, self:L("ADVANCED_NOTIFICATIONS"), 124) end
    if page.appearanceAdvanced and page.appearanceAdvanced.label then SetBoundedText(page.appearanceAdvanced.label, self:L("WINDOW_APPEARANCE"), 124) end
    if page.clearLoginMentions and page.clearLoginMentions.label then SetBoundedText(page.clearLoginMentions.label, self:L("CLEAR_LOGIN_MENTION_LIST"), 94) end
end


local GMGRefreshMentionWatchListBeforeV167 = GMG.RefreshMentionWatchList
function GMG:RefreshMentionWatchList()
    local page = self.settingsPage
    if not page or not page.loginMentionRows then
        return GMGRefreshMentionWatchListBeforeV167(self)
    end
    local names = self:GetHighlightedNames()
    local rows = {page.loginMentionRows[1], page.loginMentionRows[2]}
    local perPage = 2
    local maxPage = max(1, math.ceil(#names / perPage))
    page.loginMentionPage = max(1, min(maxPage, tonumber(page.loginMentionPage) or 1))
    local offset = (page.loginMentionPage - 1) * perPage
    for index, row in ipairs(page.loginMentionRows) do
        if index > 2 then
            row:Hide()
        end
    end
    for index, row in ipairs(rows) do
        local name = names[offset + index]
        if row then
            if name then
                row.memberName = name
                row.remove.memberName = name
                SetBoundedText(row.name, name, 214)
                row:Show()
            else
                row.memberName = nil
                row.remove.memberName = nil
                row:Hide()
            end
        end
    end
    if page.loginMentionEmpty then
        if #names == 0 then page.loginMentionEmpty:Show() else page.loginMentionEmpty:Hide() end
    end
    if page.loginMentionPageLabel then page.loginMentionPageLabel:SetText(page.loginMentionPage .. " / " .. maxPage) end
    if page.loginMentionPrev then if page.loginMentionPage > 1 then page.loginMentionPrev:Enable() else page.loginMentionPrev:Disable() end end
    if page.loginMentionNext then if page.loginMentionPage < maxPage then page.loginMentionNext:Enable() else page.loginMentionNext:Disable() end end
    if page.clearLoginMentions then if #names > 0 then page.clearLoginMentions:Enable() else page.clearLoginMentions:Disable() end end
end


-- v1.7.0: premium settings layout fix with dedicated placement for banner access and mention list.
local GMGEnhanceMainWindowBeforeV168 = GMG.EnhanceMainWindow
function GMG:EnhanceMainWindow(...)
    GMGEnhanceMainWindowBeforeV168(self, ...)
    local frame = self.mainFrame
    if frame then
        frame:SetMinResize(1080, 740)
        if frame:GetHeight() < 740 then
            frame:SetHeight(760)
            if self.SaveMainPosition then self:SaveMainPosition() end
        end
    end
    self:ApplyProfessionalSettingsLayout()
end

function GMG:ApplyProfessionalSettingsLayout()
    local page = self.settingsPage
    if not page or not page.left or not page.right then return end

    -- Give more room to the right side where the extra settings live.
    page.left:ClearAllPoints()
    page.left:SetPoint("TOPLEFT", 22, -58)
    page.left:SetPoint("BOTTOMLEFT", 22, 22)
    page.left:SetWidth(398)

    page.right:ClearAllPoints()
    page.right:SetPoint("TOPLEFT", page.left, "TOPRIGHT", 16, 0)
    page.right:SetPoint("BOTTOMRIGHT", -22, 22)

    page.title:ClearAllPoints()
    page.title:SetPoint("TOPLEFT", 22, -20)

    -- LEFT COLUMN
    page.languageTitle:ClearAllPoints(); page.languageTitle:SetPoint("TOPLEFT", 18, -18)
    page.languageHelp:ClearAllPoints(); page.languageHelp:SetPoint("TOPLEFT", 18, -44); page.languageHelp:SetPoint("TOPRIGHT", -18, -44); page.languageHelp:SetHeight(30)
    if page.languageButtons then
        for index, button in ipairs(page.languageButtons) do
            button:ClearAllPoints()
            button:SetWidth(110)
            button:SetPoint("TOPLEFT", 18 + (index - 1) * 116, -84)
        end
    end

    page.notificationsTitle:ClearAllPoints(); page.notificationsTitle:SetPoint("TOPLEFT", 18, -134)
    page.notifyOnline:ClearAllPoints(); page.notifyOnline:SetPoint("TOPLEFT", 18, -164)
    page.notifyOffline:ClearAllPoints(); page.notifyOffline:SetPoint("TOPLEFT", 18, -197)
    page.mentionFlash:ClearAllPoints(); page.mentionFlash:SetPoint("TOPLEFT", 18, -230)
    if page.mentionUnreadGlow then page.mentionUnreadGlow:ClearAllPoints(); page.mentionUnreadGlow:SetPoint("TOPLEFT", 18, -263) end

    page.displayTitle:ClearAllPoints(); page.displayTitle:SetPoint("TOPLEFT", 18, -311)
    page.showOffline:ClearAllPoints(); page.showOffline:SetPoint("TOPLEFT", 18, -341)
    page.showLauncher:ClearAllPoints(); page.showLauncher:SetPoint("TOPLEFT", 18, -374)

    page.keyTitle:ClearAllPoints(); page.keyTitle:SetPoint("TOPLEFT", 18, -422)
    page.currentKey:ClearAllPoints(); page.currentKey:SetPoint("TOPLEFT", 18, -450)
    page.changeKey:ClearAllPoints(); page.changeKey:SetPoint("TOPLEFT", 18, -484); page.changeKey:SetWidth(156)
    page.clearKey:ClearAllPoints(); page.clearKey:SetPoint("LEFT", page.changeKey, "RIGHT", 12, 0); page.clearKey:SetWidth(156)
    if page.info then page.info:Hide() end

    -- RIGHT COLUMN: clear sections from top to bottom.
    page.avatarTitle:ClearAllPoints(); page.avatarTitle:SetPoint("TOPLEFT", 18, -18); page.avatarTitle:SetPoint("TOPRIGHT", -18, -18)
    page.avatar:SetWidth(112); page.avatar:SetHeight(112); page.avatar:ClearAllPoints(); page.avatar:SetPoint("TOP", 0, -46)
    page.avatarHelp:ClearAllPoints(); page.avatarHelp:SetPoint("TOPLEFT", 22, -164); page.avatarHelp:SetPoint("TOPRIGHT", -22, -164); page.avatarHelp:SetHeight(28)
    page.changeAvatar:ClearAllPoints(); page.changeAvatar:SetWidth(278); page.changeAvatar:SetPoint("TOP", 0, -204)
    page.sharedLabel:ClearAllPoints(); page.sharedLabel:SetPoint("TOPLEFT", 22, -248); page.sharedLabel:SetPoint("TOPRIGHT", -22, -248)

    if page.fadeInCombat then page.fadeInCombat:ClearAllPoints(); page.fadeInCombat:SetPoint("TOPLEFT", 18, -284) end
    if page.fadeWhileMoving then page.fadeWhileMoving:ClearAllPoints(); page.fadeWhileMoving:SetPoint("TOPLEFT", 18, -316) end

    if page.notificationAdvanced then
        page.notificationAdvanced:ClearAllPoints()
        page.notificationAdvanced:SetWidth(145)
        page.notificationAdvanced:SetPoint("TOPLEFT", 18, -356)
    end
    if page.appearanceAdvanced then
        page.appearanceAdvanced:ClearAllPoints()
        page.appearanceAdvanced:SetWidth(145)
        page.appearanceAdvanced:SetPoint("TOPRIGHT", -18, -356)
    end
    if page.bannerCreator then
        page.bannerCreator:ClearAllPoints()
        page.bannerCreator:SetWidth(308)
        page.bannerCreator:SetPoint("TOP", 0, -396)
    end

    if page.loginMentionTitle then
        page.loginMentionTitle:ClearAllPoints()
        page.loginMentionTitle:SetPoint("TOPLEFT", 18, -444)
        page.loginMentionTitle:SetPoint("TOPRIGHT", -18, -444)
    end
    if page.loginMentionEmpty then
        page.loginMentionEmpty:ClearAllPoints()
        page.loginMentionEmpty:SetPoint("TOPLEFT", 24, -472)
        page.loginMentionEmpty:SetPoint("TOPRIGHT", -24, -472)
        page.loginMentionEmpty:SetHeight(42)
    end
    if page.loginMentionRows then
        for index, row in ipairs(page.loginMentionRows) do
            if index <= 2 then
                row:ClearAllPoints()
                row:SetHeight(28)
                row:SetPoint("TOPLEFT", 18, -470 - (index - 1) * 32)
                row:SetPoint("TOPRIGHT", -18, -470 - (index - 1) * 32)
                if row.name then row.name:ClearAllPoints(); row.name:SetPoint("LEFT", 8, 0); row.name:SetPoint("RIGHT", -38, 0) end
                if row.remove then
                    row.remove:ClearAllPoints()
                    row.remove:SetWidth(24)
                    row.remove:SetHeight(20)
                    row.remove:SetPoint("RIGHT", -2, 0)
                    if row.remove.label then row.remove.label:SetText("×") end
                end
                row:Show()
            else
                row:Hide()
            end
        end
    end
    if page.loginMentionPrev then page.loginMentionPrev:ClearAllPoints(); page.loginMentionPrev:SetWidth(32); page.loginMentionPrev:SetPoint("BOTTOMLEFT", 18, 14) end
    if page.loginMentionPageLabel then page.loginMentionPageLabel:ClearAllPoints(); page.loginMentionPageLabel:SetWidth(62); page.loginMentionPageLabel:SetPoint("LEFT", page.loginMentionPrev, "RIGHT", 6, 0) end
    if page.loginMentionNext then page.loginMentionNext:ClearAllPoints(); page.loginMentionNext:SetWidth(32); page.loginMentionNext:SetPoint("LEFT", page.loginMentionPageLabel, "RIGHT", 6, 0) end
    if page.clearLoginMentions then page.clearLoginMentions:ClearAllPoints(); page.clearLoginMentions:SetWidth(110); page.clearLoginMentions:SetPoint("BOTTOMRIGHT", -18, 14) end

    -- Consistent bounded labels.
    SetBoundedText(page.notifyOnline.label, self:L("NOTIFY_ONLINE"), 324)
    SetBoundedText(page.notifyOffline.label, self:L("NOTIFY_OFFLINE"), 324)
    SetBoundedText(page.mentionFlash.label, self:L("MENTION_FLASH"), 324)
    if page.mentionUnreadGlow then SetBoundedText(page.mentionUnreadGlow.label, self:L("MENTION_UNREAD_GLOW"), 324) end
    SetBoundedText(page.showOffline.label, self:L("SHOW_OFFLINE"), 324)
    SetBoundedText(page.showLauncher.label, self:L("SHOW_LAUNCHER"), 324)
    if page.fadeInCombat then SetBoundedText(page.fadeInCombat.label, self:L("FADE_IN_COMBAT"), 286) end
    if page.fadeWhileMoving then SetBoundedText(page.fadeWhileMoving.label, self:L("FADE_WHILE_MOVING"), 286) end
    if page.notificationAdvanced and page.notificationAdvanced.label then SetBoundedText(page.notificationAdvanced.label, self:L("ADVANCED_NOTIFICATIONS"), 133) end
    if page.appearanceAdvanced and page.appearanceAdvanced.label then SetBoundedText(page.appearanceAdvanced.label, self:L("WINDOW_APPEARANCE"), 133) end
    if page.bannerCreator and page.bannerCreator.label then SetBoundedText(page.bannerCreator.label, self:L("BANNER_SETTINGS_BUTTON"), 296) end
    if page.clearLoginMentions and page.clearLoginMentions.label then SetBoundedText(page.clearLoginMentions.label, self:L("CLEAR_LOGIN_MENTION_LIST"), 100) end
end


-- ==========================================================================
-- v1.7.0: dedicated login-mention manager page opened from Settings.
-- Replaces the overcrowded inline list with a dedicated, more reliable panel.
-- ==========================================================================
do
    GMG.Locales = GMG.Locales or { en = {}, fr = {} }
    GMG.Locales.en = GMG.Locales.en or {}
    GMG.Locales.fr = GMG.Locales.fr or {}
    local EN = {
        LOGIN_MENTION_MANAGER_BUTTON = "Members to mention on login",
        LOGIN_MENTION_MANAGER_TITLE = "Members to mention on login",
        LOGIN_MENTION_MANAGER_HELP = "Choose which guild members should always trigger a dedicated green connection notification.",
        LOGIN_MENTION_SEARCH = "Search for a member...",
        LOGIN_MENTION_STATUS_ON = "Active",
        LOGIN_MENTION_STATUS_OFF = "Inactive",
        LOGIN_MENTION_ADD = "Enable",
        LOGIN_MENTION_REMOVE = "Remove",
        LOGIN_MENTION_SELECTED_ONLY = "Selected only",
        LOGIN_MENTION_SELECTED = "Selected: %d",
        LOGIN_MENTION_CLOSE = "Close",
        LOGIN_MENTION_EMPTY = "No guild member matches this filter.",
        LOGIN_MENTION_ONLINE = "Online",
        LOGIN_MENTION_OFFLINE = "Offline",
    }
    local FR = {
        LOGIN_MENTION_MANAGER_BUTTON = "Membres à mentionner lors de la connexion",
        LOGIN_MENTION_MANAGER_TITLE = "Membres à mentionner lors de la connexion",
        LOGIN_MENTION_MANAGER_HELP = "Choisissez les membres de guilde qui doivent toujours déclencher une notification verte dédiée lors de leur connexion.",
        LOGIN_MENTION_SEARCH = "Rechercher un membre...",
        LOGIN_MENTION_STATUS_ON = "Activé",
        LOGIN_MENTION_STATUS_OFF = "Désactivé",
        LOGIN_MENTION_ADD = "Activer",
        LOGIN_MENTION_REMOVE = "Retirer",
        LOGIN_MENTION_SELECTED_ONLY = "Sélection uniquement",
        LOGIN_MENTION_SELECTED = "Sélectionnés : %d",
        LOGIN_MENTION_CLOSE = "Fermer",
        LOGIN_MENTION_EMPTY = "Aucun membre de guilde ne correspond à ce filtre.",
        LOGIN_MENTION_ONLINE = "En ligne",
        LOGIN_MENTION_OFFLINE = "Hors ligne",
    }
    for key, value in pairs(EN) do GMG.Locales.en[key] = value end
    for key, value in pairs(FR) do GMG.Locales.fr[key] = value end
end

function GMG:GetMentionManagerMembers()
    local result, seen = {}, {}
    for _, member in ipairs(self.rosterMembers or {}) do
        local name = self:NormalizeName(member.simpleName or member.name or "")
        local key = strlower(name or "")
        if name ~= "" and not seen[key] then
            seen[key] = true
            result[#result + 1] = {
                name = name,
                online = member.online and true or false,
                level = tonumber(member.level) or 0,
                class = member.class or member.classFile or "",
            }
        end
    end
    for _, name in ipairs(self:GetHighlightedNames()) do
        local norm = self:NormalizeName(name)
        local key = strlower(norm or "")
        if norm ~= "" and not seen[key] then
            seen[key] = true
            result[#result + 1] = {
                name = norm,
                online = false,
                level = 0,
                class = "",
            }
        end
    end
    sort(result, function(a, b)
        if a.online ~= b.online then return a.online and not b.online end
        return strlower(a.name or "") < strlower(b.name or "")
    end)
    return result
end

function GMG:CreateLoginMentionManager()
    if self.loginMentionManager then return self.loginMentionManager end
    local parent = self.mainFrame
    if not parent then return nil end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(parent:GetFrameLevel() + 40)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 34, -34)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -34, 34)
    SetBackdrop(frame, PANEL_BG, BORDER)
    frame:Hide()
    self.loginMentionManager = frame

    frame.title = CreateText(frame, "GameFontHighlightLarge", self:L("LOGIN_MENTION_MANAGER_TITLE"), 18)
    frame.title:SetPoint("TOPLEFT", 22, -18)
    frame.title:SetTextColor(unpack(TEXT))

    frame.help = CreateText(frame, "GameFontNormalSmall", self:L("LOGIN_MENTION_MANAGER_HELP"), 11)
    frame.help:SetPoint("TOPLEFT", 22, -44)
    frame.help:SetPoint("TOPRIGHT", -170, -44)
    frame.help:SetJustifyH("LEFT")
    frame.help:SetTextColor(unpack(MUTED))

    frame.closeButton = CreateFlatButton(frame, self:L("LOGIN_MENTION_CLOSE"), 120, 28)
    frame.closeButton:SetPoint("TOPRIGHT", -18, -18)
    frame.closeButton:SetScript("OnClick", function() frame:Hide() end)

    frame.searchLabel = CreateText(frame, "GameFontNormalSmall", self:L("SEARCH"), 11)
    frame.searchLabel:SetPoint("TOPLEFT", 22, -88)
    frame.searchHolder, frame.search = CreateEditBox(frame, 260, 30, false)
    frame.searchHolder:SetPoint("TOPLEFT", 22, -108)
    frame.search:SetScript("OnTextChanged", function()
        frame.page = 1
        GMG:RefreshLoginMentionManager()
    end)

    frame.selectedOnly = CreateCheck(frame, self:L("LOGIN_MENTION_SELECTED_ONLY"), 170)
    frame.selectedOnly:SetPoint("TOPLEFT", 298, -111)
    frame.selectedOnly:SetScript("OnClick", function(button)
        button:SetChecked(not button:GetChecked())
        frame.page = 1
        GMG:RefreshLoginMentionManager()
    end)

    frame.selectedCount = CreateText(frame, "GameFontNormal", "", 12)
    frame.selectedCount:SetPoint("TOPRIGHT", -18, -111)
    frame.selectedCount:SetTextColor(unpack(ACCENT))

    frame.list = CreateFrame("Frame", nil, frame)
    frame.list:SetPoint("TOPLEFT", 22, -146)
    frame.list:SetPoint("BOTTOMRIGHT", -22, 58)
    SetBackdrop(frame.list, PANEL_2, BORDER)

    frame.rows = {}
    for index = 1, 10 do
        local row = CreateFrame("Button", nil, frame.list)
        row:SetHeight(40)
        row:SetPoint("TOPLEFT", 10, -10 - (index - 1) * 43)
        row:SetPoint("TOPRIGHT", -10, -10 - (index - 1) * 43)
        SetBackdrop(row, PANEL_3, BORDER)

        row.dot = row:CreateTexture(nil, "ARTWORK")
        row.dot:SetTexture("Interface\\Buttons\\WHITE8X8")
        row.dot:SetWidth(8)
        row.dot:SetHeight(8)
        row.dot:SetPoint("LEFT", 10, 0)

        row.name = CreateText(row, "GameFontNormal", "", 12)
        row.name:SetPoint("TOPLEFT", 24, -7)
        row.name:SetPoint("RIGHT", -240, 0)
        row.name:SetJustifyH("LEFT")

        row.meta = CreateText(row, "GameFontNormalSmall", "", 10)
        row.meta:SetPoint("BOTTOMLEFT", 24, 8)
        row.meta:SetPoint("RIGHT", -240, 0)
        row.meta:SetJustifyH("LEFT")
        row.meta:SetTextColor(unpack(MUTED))

        row.state = CreateText(row, "GameFontNormalSmall", "", 10)
        row.state:SetWidth(80)
        row.state:SetPoint("RIGHT", -104, 0)
        row.state:SetJustifyH("CENTER")

        row.toggle = CreateFlatButton(row, self:L("LOGIN_MENTION_ADD"), 90, 24)
        row.toggle:SetPoint("RIGHT", -8, 0)
        row.toggle:SetScript("OnClick", function(button)
            if button.memberName and button.memberName ~= "" then
                GMG:ToggleHighlighted(button.memberName)
                GMG:RefreshLoginMentionManager()
            end
        end)

        row:SetScript("OnClick", function(button)
            if button.memberName and button.memberName ~= "" then
                GMG:ToggleHighlighted(button.memberName)
                GMG:RefreshLoginMentionManager()
            end
        end)

        frame.rows[index] = row
    end

    frame.empty = CreateText(frame.list, "GameFontNormal", self:L("LOGIN_MENTION_EMPTY"), 12)
    frame.empty:SetPoint("CENTER", 0, 0)
    frame.empty:SetTextColor(unpack(MUTED))

    frame.prev = CreateFlatButton(frame, "<", 36, 26)
    frame.prev:SetPoint("BOTTOMLEFT", 22, 18)
    frame.prev:SetScript("OnClick", function()
        frame.page = max(1, (frame.page or 1) - 1)
        GMG:RefreshLoginMentionManager()
    end)

    frame.pageLabel = CreateText(frame, "GameFontNormalSmall", "1 / 1", 10)
    frame.pageLabel:SetWidth(80)
    frame.pageLabel:SetPoint("LEFT", frame.prev, "RIGHT", 8, 0)
    frame.pageLabel:SetJustifyH("CENTER")

    frame.next = CreateFlatButton(frame, ">", 36, 26)
    frame.next:SetPoint("LEFT", frame.pageLabel, "RIGHT", 8, 0)
    frame.next:SetScript("OnClick", function()
        frame.page = (frame.page or 1) + 1
        GMG:RefreshLoginMentionManager()
    end)

    frame.clear = CreateFlatButton(frame, self:L("CLEAR_LOGIN_MENTION_LIST"), 150, 26)
    frame.clear:SetPoint("BOTTOMRIGHT", -18, 18)
    frame.clear:SetScript("OnClick", function()
        GMG:ClearHighlighted()
        GMG:RefreshLoginMentionManager()
    end)

    frame.page = 1
    return frame
end

function GMG:RefreshLoginMentionManager()
    local frame = self.loginMentionManager
    if not frame then return end
    local search = strlower((frame.search and frame.search:GetText()) or "")
    local selectedOnly = frame.selectedOnly and frame.selectedOnly:GetChecked()
    local members = self:GetMentionManagerMembers()
    local filtered = {}
    for _, member in ipairs(members) do
        local isSelected = self:IsHighlighted(member.name)
        local haystack = strlower((member.name or "") .. " " .. (member.class or ""))
        if (not selectedOnly or isSelected) and (search == "" or string.find(haystack, search, 1, true)) then
            filtered[#filtered + 1] = member
        end
    end

    local perPage = #frame.rows
    local maxPage = max(1, math.ceil(#filtered / perPage))
    frame.page = max(1, min(maxPage, tonumber(frame.page) or 1))
    local offset = (frame.page - 1) * perPage

    for index, row in ipairs(frame.rows) do
        local member = filtered[offset + index]
        if member then
            local selected = self:IsHighlighted(member.name)
            row.memberName = member.name
            row:Show()
            row.dot:SetVertexColor(member.online and 0.20 or 0.55, member.online and 0.90 or 0.55, member.online and 0.30 or 0.55, 1)
            row.name:SetText(member.name)
            if selected then row.name:SetTextColor(0.78, 0.92, 0.35, 1) else row.name:SetTextColor(unpack(TEXT)) end
            local meta = (member.online and self:L("LOGIN_MENTION_ONLINE") or self:L("LOGIN_MENTION_OFFLINE"))
            if member.level and member.level > 0 then meta = meta .. "  •  " .. member.level end
            if member.class and member.class ~= "" then meta = meta .. "  •  " .. member.class end
            row.meta:SetText(meta)
            row.state:SetText(selected and self:L("LOGIN_MENTION_STATUS_ON") or self:L("LOGIN_MENTION_STATUS_OFF"))
            row.state:SetTextColor(selected and 0.40 or 0.70, selected and 0.95 or 0.70, selected and 0.45 or 0.70, 1)
            if row.toggle and row.toggle.label then
                SetBoundedText(row.toggle.label, self:L(selected and "LOGIN_MENTION_REMOVE" or "LOGIN_MENTION_ADD"), 76)
            end
        else
            row.memberName = nil
            row:Hide()
        end
    end

    if #filtered == 0 then frame.empty:Show() else frame.empty:Hide() end
    frame.pageLabel:SetText(frame.page .. " / " .. maxPage)
    frame.selectedCount:SetText(self:L("LOGIN_MENTION_SELECTED", #self:GetHighlightedNames()))
    if frame.prev then if frame.page > 1 then frame.prev:Enable() else frame.prev:Disable() end end
    if frame.next then if frame.page < maxPage then frame.next:Enable() else frame.next:Disable() end end
    if frame.clear then if #self:GetHighlightedNames() > 0 then frame.clear:Enable() else frame.clear:Disable() end end
end

function GMG:OpenLoginMentionManager()
    local frame = self:CreateLoginMentionManager()
    if not frame then return end
    frame:Show()
    frame.page = 1
    self:RefreshLoginMentionManager()
end

local GMGCreateSettingsPageBeforeV169 = GMG.CreateSettingsPage
function GMG:CreateSettingsPage()
    GMGCreateSettingsPageBeforeV169(self)
    local page = self.settingsPage
    if not page or page.v169LoginMentionManager then return end
    page.v169LoginMentionManager = true

    page.loginMentionManagerButton = CreateFlatButton(page.right, self:L("LOGIN_MENTION_MANAGER_BUTTON"), 308, 28)
    page.loginMentionManagerButton:SetPoint("TOP", 0, -444)
    page.loginMentionManagerButton:SetScript("OnClick", function() GMG:OpenLoginMentionManager() end)

    if page.loginMentionTitle then page.loginMentionTitle:Hide() end
    if page.loginMentionEmpty then page.loginMentionEmpty:Hide() end
    if page.loginMentionPrev then page.loginMentionPrev:Hide() end
    if page.loginMentionPageLabel then page.loginMentionPageLabel:Hide() end
    if page.loginMentionNext then page.loginMentionNext:Hide() end
    if page.clearLoginMentions then page.clearLoginMentions:Hide() end
    if page.loginMentionRows then for _, row in ipairs(page.loginMentionRows) do row:Hide() end end

    self:ApplyProfessionalSettingsLayout()
end

local GMGRefreshMentionWatchListBeforeV169 = GMG.RefreshMentionWatchList
function GMG:RefreshMentionWatchList(...)
    if GMGRefreshMentionWatchListBeforeV169 then GMGRefreshMentionWatchListBeforeV169(self, ...) end
    local page = self.settingsPage
    if page and page.loginMentionManagerButton then
        if page.loginMentionTitle then page.loginMentionTitle:Hide() end
        if page.loginMentionEmpty then page.loginMentionEmpty:Hide() end
        if page.loginMentionPrev then page.loginMentionPrev:Hide() end
        if page.loginMentionPageLabel then page.loginMentionPageLabel:Hide() end
        if page.loginMentionNext then page.loginMentionNext:Hide() end
        if page.clearLoginMentions then page.clearLoginMentions:Hide() end
        if page.loginMentionRows then for _, row in ipairs(page.loginMentionRows) do row:Hide() end end
        if page.loginMentionManagerButton.label then
            SetBoundedText(page.loginMentionManagerButton.label, self:L("LOGIN_MENTION_MANAGER_BUTTON"), 292)
        end
    end
    self:RefreshLoginMentionManager()
end

local GMGRefreshLocalizationBeforeV169 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV169(self, ...)
    local page = self.settingsPage
    if page and page.loginMentionManagerButton and page.loginMentionManagerButton.label then
        SetBoundedText(page.loginMentionManagerButton.label, self:L("LOGIN_MENTION_MANAGER_BUTTON"), 292)
    end
    local frame = self.loginMentionManager
    if frame then
        frame.title:SetText(self:L("LOGIN_MENTION_MANAGER_TITLE"))
        frame.help:SetText(self:L("LOGIN_MENTION_MANAGER_HELP"))
        frame.searchLabel:SetText(self:L("SEARCH"))
        frame.selectedOnly.label:SetText(self:L("LOGIN_MENTION_SELECTED_ONLY"))
        if frame.closeButton and frame.closeButton.label then SetBoundedText(frame.closeButton.label, self:L("LOGIN_MENTION_CLOSE"), 108) end
        if frame.clear and frame.clear.label then SetBoundedText(frame.clear.label, self:L("CLEAR_LOGIN_MENTION_LIST"), 138) end
        for _, row in ipairs(frame.rows or {}) do
            if row.toggle and row.toggle.label then SetBoundedText(row.toggle.label, self:L("LOGIN_MENTION_ADD"), 76) end
        end
    end
    self:RefreshLoginMentionManager()
end

local GMGApplyProfessionalSettingsLayoutBeforeV169 = GMG.ApplyProfessionalSettingsLayout
function GMG:ApplyProfessionalSettingsLayout(...)
    if GMGApplyProfessionalSettingsLayoutBeforeV169 then GMGApplyProfessionalSettingsLayoutBeforeV169(self, ...) end
    local page = self.settingsPage
    if not page then return end

    -- Remove the old inline mention list from the settings page.
    if page.loginMentionTitle then page.loginMentionTitle:Hide() end
    if page.loginMentionEmpty then page.loginMentionEmpty:Hide() end
    if page.loginMentionPrev then page.loginMentionPrev:Hide() end
    if page.loginMentionPageLabel then page.loginMentionPageLabel:Hide() end
    if page.loginMentionNext then page.loginMentionNext:Hide() end
    if page.clearLoginMentions then page.clearLoginMentions:Hide() end
    if page.loginMentionRows then for _, row in ipairs(page.loginMentionRows) do row:Hide() end end

    if page.loginMentionManagerButton then
        page.loginMentionManagerButton:ClearAllPoints()
        page.loginMentionManagerButton:SetWidth(308)
        page.loginMentionManagerButton:SetPoint("TOP", 0, -444)
        if page.loginMentionManagerButton.label then
            SetBoundedText(page.loginMentionManagerButton.label, self:L("LOGIN_MENTION_MANAGER_BUTTON"), 292)
        end
    end
end


-- ==========================================================================
-- v1.7.3: guild-chat font controls, visible header version and update popup.
-- ==========================================================================
do
    GMG.Locales = GMG.Locales or { en = {}, fr = {} }
    GMG.Locales.en = GMG.Locales.en or {}
    GMG.Locales.fr = GMG.Locales.fr or {}

    local EN = {
        CHAT_FONT_SIZE = "Guild message font size",
        CHAT_FONT_SMALLER = "Decrease guild message font size",
        CHAT_FONT_LARGER = "Increase guild message font size",
        UPDATE_AVAILABLE_TITLE = "A newer version is available",
        UPDATE_AVAILABLE_BODY = "Version %s was detected on %s. You are currently using version %s.\n\nDownload the update from addon.devquestlog.com or install it through the launcher.",
        UPDATE_AVAILABLE_COPY = "Copy address",
        UPDATE_AVAILABLE_CLOSE = "Close",
    }
    local FR = {
        CHAT_FONT_SIZE = "Taille de la police des messages de guilde",
        CHAT_FONT_SMALLER = "Diminuer la taille des messages de guilde",
        CHAT_FONT_LARGER = "Augmenter la taille des messages de guilde",
        UPDATE_AVAILABLE_TITLE = "Une version plus récente est disponible",
        UPDATE_AVAILABLE_BODY = "La version %s a été détectée chez %s. Vous utilisez actuellement la version %s.\n\nTéléchargez la mise à jour sur addon.devquestlog.com ou installez-la via le launcher.",
        UPDATE_AVAILABLE_COPY = "Copier l'adresse",
        UPDATE_AVAILABLE_CLOSE = "Fermer",
    }
    for key, value in pairs(EN) do GMG.Locales.en[key] = value end
    for key, value in pairs(FR) do GMG.Locales.fr[key] = value end
end

function GMG:GetGuildChatFontSize()
    local value = tonumber(self.db and self.db.profile and self.db.profile.chatFontSize) or 12
    value = max(9, min(24, floor(value + 0.5)))
    if self.db and self.db.profile then self.db.profile.chatFontSize = value end
    return value
end

function GMG:ApplyGuildChatFontSize()
    local page = self.chatPage
    if not page or not page.messages then return end
    local size = self:GetGuildChatFontSize()
    local font, _, flags
    if ChatFontNormal and ChatFontNormal.GetFont then
        font, _, flags = ChatFontNormal:GetFont()
    end
    font = font or "Fonts\\FRIZQT__.TTF"
    flags = flags or ""
    pcall(page.messages.SetFont, page.messages, font, size, flags)
    if page.fontSizeValue then page.fontSizeValue:SetText(tostring(size)) end
end

function GMG:ChangeGuildChatFontSize(delta)
    if not self.db or not self.db.profile then return end
    local old = self:GetGuildChatFontSize()
    local value = max(9, min(24, old + (tonumber(delta) or 0)))
    if value == old then return end
    self.db.profile.chatFontSize = value
    if self.PersistSettings then self:PersistSettings() end
    self:ApplyGuildChatFontSize()
end

local GMGCreateChatPageBeforeV173 = GMG.CreateChatPage
function GMG:CreateChatPage(...)
    GMGCreateChatPageBeforeV173(self, ...)
    local page = self.chatPage
    if not page or page.v173FontControls then return end
    page.v173FontControls = true

    page.fontMinus = CreateFlatButton(page, "A−", 38, 28)
    page.fontMinus:SetPoint("TOPRIGHT", -126, -14)
    page.fontMinus:SetScript("OnClick", function() GMG:ChangeGuildChatFontSize(-1) end)
    page.fontMinus:SetScript("OnEnter", function(button)
        button:SetBackdropColor(unpack(ACCENT_SOFT))
        button:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(GMG:L("CHAT_FONT_SMALLER"), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    page.fontMinus:SetScript("OnLeave", function(button)
        button:SetBackdropColor(unpack(PANEL_3))
        button:SetBackdropBorderColor(unpack(BORDER))
        GameTooltip:Hide()
    end)

    page.fontSizeValue = CreateText(page, "GameFontNormal", tostring(self:GetGuildChatFontSize()), 12)
    page.fontSizeValue:SetWidth(42)
    page.fontSizeValue:SetPoint("LEFT", page.fontMinus, "RIGHT", 5, 0)
    page.fontSizeValue:SetJustifyH("CENTER")
    page.fontSizeValue:SetTextColor(unpack(ACCENT))

    page.fontPlus = CreateFlatButton(page, "A+", 38, 28)
    page.fontPlus:SetPoint("LEFT", page.fontSizeValue, "RIGHT", 5, 0)
    page.fontPlus:SetScript("OnClick", function() GMG:ChangeGuildChatFontSize(1) end)
    page.fontPlus:SetScript("OnEnter", function(button)
        button:SetBackdropColor(unpack(ACCENT_SOFT))
        button:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(GMG:L("CHAT_FONT_LARGER"), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    page.fontPlus:SetScript("OnLeave", function(button)
        button:SetBackdropColor(unpack(PANEL_3))
        button:SetBackdropBorderColor(unpack(BORDER))
        GameTooltip:Hide()
    end)

    self:ApplyGuildChatFontSize()
end

function GMG:RefreshHeaderAddonVersion()
    if not self.mainFrame or not self.mainFrame.brand then return end
    local text = self:L("BRAND") .. "  |cff54e6a1v" .. tostring(self.version or "") .. "|r"
    SetBoundedText(self.mainFrame.brand, text, max(300, self.mainFrame:GetWidth() - 330))
end

local GMGCreateMainFrameBeforeV173 = GMG.CreateMainFrame
function GMG:CreateMainFrame(...)
    GMGCreateMainFrameBeforeV173(self, ...)
    self:RefreshHeaderAddonVersion()
end

function GMG:CreateUpdateAvailablePopup()
    if self.updateAvailablePopup then return end
    local frame = CreateFrame("Frame", "GlaynaBetterGuildUpdateAvailable", UIParent)
    frame:SetWidth(590)
    frame:SetHeight(230)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 110)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(frame, PANEL_BG, ACCENT)
    frame:Hide()

    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("UPDATE_AVAILABLE_TITLE"), 19)
    frame.title:SetPoint("TOPLEFT", 22, -20)
    frame.title:SetPoint("TOPRIGHT", -22, -20)
    frame.title:SetJustifyH("CENTER")
    frame.title:SetTextColor(0.55, 1.00, 0.70, 1)

    frame.body = CreateText(frame, "GameFontNormal", "", 12)
    frame.body:SetPoint("TOPLEFT", 30, -62)
    frame.body:SetPoint("TOPRIGHT", -30, -62)
    frame.body:SetHeight(92)
    frame.body:SetJustifyH("CENTER")
    frame.body:SetJustifyV("TOP")
    if frame.body.SetWordWrap then frame.body:SetWordWrap(true) end

    frame.url = CreateText(frame, "GameFontNormal", "addon.devquestlog.com", 13)
    frame.url:SetPoint("TOP", frame.body, "BOTTOM", 0, -8)
    frame.url:SetTextColor(0.55, 0.82, 1.00, 1)

    frame.copy = CreateFlatButton(frame, self:L("UPDATE_AVAILABLE_COPY"), 180, 32)
    frame.copy:SetPoint("BOTTOMLEFT", 30, 20)
    frame.copy:SetScript("OnClick", function()
        GMG:OpenCopyLink("https://addon.devquestlog.com")
    end)

    frame.close = CreateFlatButton(frame, self:L("UPDATE_AVAILABLE_CLOSE"), 140, 32)
    frame.close:SetPoint("BOTTOMRIGHT", -30, 20)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    self.updateAvailablePopup = frame
end

function GMG:ShowUpdateAvailablePopup(remoteVersion, sender)
    self:CreateUpdateAvailablePopup()
    local frame = self.updateAvailablePopup
    if not frame then return end
    frame.remoteVersion = remoteVersion
    frame.sender = sender
    frame.title:SetText(self:L("UPDATE_AVAILABLE_TITLE"))
    frame.body:SetText(self:L("UPDATE_AVAILABLE_BODY", tostring(remoteVersion or "?"), tostring(sender or "?"), tostring(self.version or "?")))
    SetBoundedText(frame.copy.label, self:L("UPDATE_AVAILABLE_COPY"), 168)
    SetBoundedText(frame.close.label, self:L("UPDATE_AVAILABLE_CLOSE"), 128)
    frame:Show()
end

local GMGRefreshLocalizationBeforeV173 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV173(self, ...)
    self:RefreshHeaderAddonVersion()
    self:ApplyGuildChatFontSize()
    local frame = self.updateAvailablePopup
    if frame then
        frame.title:SetText(self:L("UPDATE_AVAILABLE_TITLE"))
        frame.body:SetText(self:L("UPDATE_AVAILABLE_BODY", tostring(frame.remoteVersion or "?"), tostring(frame.sender or "?"), tostring(self.version or "?")))
        SetBoundedText(frame.copy.label, self:L("UPDATE_AVAILABLE_COPY"), 168)
        SetBoundedText(frame.close.label, self:L("UPDATE_AVAILABLE_CLOSE"), 128)
    end
end


-- ==========================================================================
-- v1.7.5: robust guild-chat history scrolling for WoW 3.3.5a.
-- The message frame now owns the mouse, keeps its historical position during
-- forced refreshes and provides dedicated scroll controls as a fallback.
-- ==========================================================================
function GMG:InstallGuildChatHistoryScrollFix()
    local page = self.chatPage
    if not page or not page.messages or page.v175ScrollFix then return end
    page.v175ScrollFix = true

    page.messages:SetMaxLines(5000)
    page.messages:EnableMouse(true)
    page.messages:EnableMouseWheel(true)
    page.history:EnableMouse(true)
    page.history:EnableMouseWheel(true)

    local function ShowHistoryMode()
        page.userReadingHistory = true
        if page.latestMessages then page.latestMessages:Show() end
    end

    local function ReturnToLatest()
        page.userReadingHistory = false
        if page.latestMessages then page.latestMessages:Hide() end
        if GMG.chatDirty then
            GMG:RefreshChat(true)
        end
        page.messages:ScrollToBottom()
    end

    local function IsAtBottom()
        if page.messages.AtBottom then
            local ok, value = pcall(page.messages.AtBottom, page.messages)
            if ok then return value and true or false end
        end
        return false
    end

    local function ScrollHistory(direction, amount)
        amount = max(1, tonumber(amount) or 4)
        if direction > 0 then
            ShowHistoryMode()
            if IsShiftKeyDown and IsShiftKeyDown() then
                page.messages:ScrollToTop()
            elseif IsControlKeyDown and IsControlKeyDown() and page.messages.PageUp then
                page.messages:PageUp()
            else
                for _ = 1, amount do
                    if page.messages.ScrollUp then page.messages:ScrollUp() end
                end
            end
        elseif direction < 0 then
            if IsShiftKeyDown and IsShiftKeyDown() then
                ReturnToLatest()
                return
            elseif IsControlKeyDown and IsControlKeyDown() and page.messages.PageDown then
                page.messages:PageDown()
            else
                for _ = 1, amount do
                    if page.messages.ScrollDown then page.messages:ScrollDown() end
                end
            end
            if IsAtBottom() then ReturnToLatest() end
        end
    end

    page.v175ScrollHistory = ScrollHistory
    page.messages:SetScript("OnMouseWheel", function(_, delta)
        ScrollHistory(delta, 5)
    end)
    page.history:SetScript("OnMouseWheel", function(_, delta)
        ScrollHistory(delta, 5)
    end)

    page.historyScrollUp = CreateFlatButton(page.history, "▲", 25, 28)
    page.historyScrollUp:SetPoint("TOPRIGHT", -4, -4)
    page.historyScrollUp:SetFrameLevel(page.history:GetFrameLevel() + 5)
    page.historyScrollUp:SetScript("OnClick", function()
        ScrollHistory(1, 6)
    end)

    page.historyScrollDown = CreateFlatButton(page.history, "▼", 25, 28)
    page.historyScrollDown:SetPoint("BOTTOMRIGHT", -4, 4)
    page.historyScrollDown:SetFrameLevel(page.history:GetFrameLevel() + 5)
    page.historyScrollDown:SetScript("OnClick", function()
        ScrollHistory(-1, 6)
    end)

    -- Convert the old binary slider into a relative scroll controller.
    if page.scroll then
        page.scroll:SetMinMaxValues(0, 100)
        page.scroll:SetValueStep(10)
        page.scroll.v175Internal = true
        page.scroll:SetValue(50)
        page.scroll.v175Internal = nil
        page.scroll:SetScript("OnValueChanged", function(slider, value)
            if slider.v175Internal then return end
            if value < 50 then
                ScrollHistory(1, max(1, floor((50 - value) / 5)))
            elseif value > 50 then
                ScrollHistory(-1, max(1, floor((value - 50) / 5)))
            end
            slider.v175Internal = true
            slider:SetValue(50)
            slider.v175Internal = nil
        end)
    end

    if page.latestMessages then
        page.latestMessages:SetScript("OnClick", function()
            page.userReadingHistory = false
            page.latestMessages:Hide()
            GMG:RefreshChat(true)
            page.messages:ScrollToBottom()
            if page.scroll then
                page.scroll.v175Internal = true
                page.scroll:SetValue(50)
                page.scroll.v175Internal = nil
            end
        end)
    end
end

local GMGCreateChatPageBeforeV175 = GMG.CreateChatPage
function GMG:CreateChatPage(...)
    GMGCreateChatPageBeforeV175(self, ...)
    self:InstallGuildChatHistoryScrollFix()
end

local GMGRefreshChatBeforeV175 = GMG.RefreshChat
function GMG:RefreshChat(force)
    local page = self.chatPage
    if page and page.userReadingHistory then
        -- Never rebuild the ScrollingMessageFrame while the player is reading
        -- older messages; rebuilding always forces the frame back to the bottom.
        if force or self.chatDirty then
            self.chatDirty = true
            if page.latestMessages then page.latestMessages:Show() end
        end
        return
    end
    return GMGRefreshChatBeforeV175(self, force)
end

-- ============================================================================
-- v1.8.2: G.B.G branding and complete localized About window.
-- ============================================================================
do
    GMG.Locales = GMG.Locales or { en = {}, fr = {} }
    GMG.Locales.en = GMG.Locales.en or {}
    GMG.Locales.fr = GMG.Locales.fr or {}

    local EN = {
        ABOUT = "About",
        ABOUT_TITLE = "G.B.G — Glayna Better Guild",
        ABOUT_AUTHOR = "Author: Glayna",
        ABOUT_VERSION = "Version %s",
        ABOUT_INTRO = "G.B.G replaces the default Blizzard guild window with a complete modern guild hub for World of Warcraft 3.3.5a and Ascension: Conquest of Azeroth.",
        ABOUT_FEATURES_TITLE = "Main features",
        ABOUT_FEATURES = "- Shared guild chat history, clickable names, mentions, unread indicators and temporary fluorescent-green mention highlighting.\n- Complete member roster with profiles, shared portraits, Main/alt relationships, private notes, ranks, sorting and last connection.\n- Online/offline alerts, per-member login mentions and a movable notification bar.\n- Dedicated guild-invitation page using either a manually entered character name or the current target.\n- Layered guild banner/tabard creator published by the guild master.\n- Guild PvE/PvP Finder with activity types, descriptions, level ranges, group-size targets, Tank/Heal/DPS/Support roles and profile portraits.\n- Automatic or manual validation, automatic invitations after acceptance, live party/raid counting, role-capacity checks and leader-only editing.\n- Finder activities close automatically when full or after 30 minutes.\n- Movable launcher, interface scaling, adjustable guild-chat font, Social > Guild redirection and persistent settings.\n- Strict English/French localization and automatic newer-version detection.",
        ABOUT_SYNC_TITLE = "Synchronization and privacy",
        ABOUT_SYNC = "Addon data is exchanged only between guild members who also use G.B.G. Personal notes, local preferences and private alert selections remain stored locally.",
        ABOUT_DOWNLOAD = "Updates: addon.devquestlog.com or the launcher",
        ABOUT_CLOSE = "Close",
        ABOUT_TOOLTIP = "Open the complete addon description, version and author information.",
    }

    local FR = {
        ABOUT = "À propos",
        ABOUT_TITLE = "G.B.G — Glayna Better Guild",
        ABOUT_AUTHOR = "Auteur : Glayna",
        ABOUT_VERSION = "Version %s",
        ABOUT_INTRO = "G.B.G remplace la fenêtre de guilde Blizzard par un espace de guilde moderne et complet pour World of Warcraft 3.3.5a et Ascension: Conquest of Azeroth.",
        ABOUT_FEATURES_TITLE = "Fonctionnalités principales",
        ABOUT_FEATURES = "- Discussion et historique de guilde partagés, noms cliquables, mentions, indicateurs non lus et surbrillance temporaire vert fluorescent.\n- Liste complète des membres avec profils, portraits partagés, relations Main/rerolls, notes privées, rangs, tri et dernière connexion.\n- Alertes de connexion/déconnexion, mentions individuelles à la connexion et barre de notification déplaçable.\n- Onglet dédié aux invitations de guilde, par pseudo saisi ou directement avec la cible actuelle.\n- Créateur de bannière/tabard par calques, publié par le chef de guilde.\n- Finder de guilde JcE/JcJ avec types d’activités, descriptions, tranches de niveaux, taille cible, rôles Tank/Heal/DPS/Soutien et portraits.\n- Validation automatique ou manuelle, invitation automatique après acceptation, comptage réel du groupe/raid, limites de rôles et édition réservée au responsable.\n- Fermeture automatique des activités quand le groupe est complet ou après 30 minutes.\n- Lanceur déplaçable, taille globale réglable, police du tchat ajustable, redirection Social > Guilde et réglages persistants.\n- Localisation française/anglaise stricte et détection automatique des versions plus récentes.",
        ABOUT_SYNC_TITLE = "Synchronisation et confidentialité",
        ABOUT_SYNC = "Les données de l’addon sont échangées uniquement entre les membres de la guilde qui utilisent aussi G.B.G. Les notes personnelles, préférences locales et sélections d’alertes privées restent enregistrées localement.",
        ABOUT_DOWNLOAD = "Mises à jour : addon.devquestlog.com ou le launcher",
        ABOUT_CLOSE = "Fermer",
        ABOUT_TOOLTIP = "Ouvre la description complète de l’addon, sa version et les informations sur l’auteur.",
    }

    for key, value in pairs(EN) do GMG.Locales.en[key] = value end
    for key, value in pairs(FR) do GMG.Locales.fr[key] = value end
end

function GMG:CreateAboutPopup()
    if self.aboutPopup then return self.aboutPopup end

    local frame = CreateFrame("Frame", "GlaynaBetterGuildAboutPopup", UIParent)
    frame:SetWidth(730)
    frame:SetHeight(610)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetClampedToScreen(true)
    SetBackdrop(frame, PANEL_BG, ACCENT)
    if self.GetInterfaceScale and frame.SetScale then frame:SetScale(self:GetInterfaceScale()) end
    frame:Hide()

    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("ABOUT_TITLE"), 21)
    frame.title:SetPoint("TOPLEFT", 28, -24)
    frame.title:SetPoint("TOPRIGHT", -28, -24)
    frame.title:SetJustifyH("CENTER")
    frame.title:SetTextColor(0.72, 0.58, 1.00, 1)

    frame.meta = CreateText(frame, "GameFontNormal", "", 12)
    frame.meta:SetPoint("TOPLEFT", 28, -58)
    frame.meta:SetPoint("TOPRIGHT", -28, -58)
    frame.meta:SetJustifyH("CENTER")
    frame.meta:SetTextColor(unpack(MUTED))

    frame.separator = frame:CreateTexture(nil, "ARTWORK")
    frame.separator:SetTexture("Interface\\Buttons\\WHITE8X8")
    frame.separator:SetHeight(1)
    frame.separator:SetPoint("TOPLEFT", 28, -84)
    frame.separator:SetPoint("TOPRIGHT", -28, -84)
    frame.separator:SetVertexColor(0.30, 0.22, 0.48, 1)

    frame.intro = CreateText(frame, "GameFontNormal", self:L("ABOUT_INTRO"), 12)
    frame.intro:SetPoint("TOPLEFT", 34, -104)
    frame.intro:SetPoint("TOPRIGHT", -34, -104)
    frame.intro:SetHeight(52)
    frame.intro:SetJustifyH("LEFT")
    frame.intro:SetJustifyV("TOP")
    frame.intro:SetTextColor(0.90, 0.92, 0.98, 1)
    if frame.intro.SetWordWrap then frame.intro:SetWordWrap(true) end

    frame.featuresTitle = CreateText(frame, "GameFontNormal", self:L("ABOUT_FEATURES_TITLE"), 14)
    frame.featuresTitle:SetPoint("TOPLEFT", 34, -166)
    frame.featuresTitle:SetTextColor(0.72, 0.58, 1.00, 1)

    frame.featuresPanel = CreateFrame("Frame", nil, frame)
    frame.featuresPanel:SetPoint("TOPLEFT", 28, -192)
    frame.featuresPanel:SetPoint("TOPRIGHT", -28, -192)
    frame.featuresPanel:SetHeight(282)
    SetBackdrop(frame.featuresPanel, PANEL_2, BORDER)

    frame.features = CreateText(frame.featuresPanel, "GameFontNormalSmall", self:L("ABOUT_FEATURES"), 11)
    frame.features:SetPoint("TOPLEFT", 16, -14)
    frame.features:SetPoint("BOTTOMRIGHT", -16, 14)
    frame.features:SetJustifyH("LEFT")
    frame.features:SetJustifyV("TOP")
    frame.features:SetTextColor(0.84, 0.87, 0.94, 1)
    if frame.features.SetWordWrap then frame.features:SetWordWrap(true) end

    frame.syncTitle = CreateText(frame, "GameFontNormal", self:L("ABOUT_SYNC_TITLE"), 13)
    frame.syncTitle:SetPoint("TOPLEFT", 34, -488)
    frame.syncTitle:SetTextColor(0.72, 0.58, 1.00, 1)

    frame.sync = CreateText(frame, "GameFontNormalSmall", self:L("ABOUT_SYNC"), 10)
    frame.sync:SetPoint("TOPLEFT", 34, -510)
    frame.sync:SetPoint("TOPRIGHT", -34, -510)
    frame.sync:SetHeight(42)
    frame.sync:SetJustifyH("LEFT")
    frame.sync:SetJustifyV("TOP")
    frame.sync:SetTextColor(unpack(MUTED))
    if frame.sync.SetWordWrap then frame.sync:SetWordWrap(true) end

    frame.download = CreateText(frame, "GameFontNormal", self:L("ABOUT_DOWNLOAD"), 11)
    frame.download:SetPoint("BOTTOMLEFT", 30, 25)
    frame.download:SetTextColor(0.55, 0.82, 1.00, 1)

    frame.close = CreateFlatButton(frame, self:L("ABOUT_CLOSE"), 130, 32)
    frame.close:SetPoint("BOTTOMRIGHT", -28, 18)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    if UISpecialFrames then
        local found = false
        for _, name in ipairs(UISpecialFrames) do
            if name == "GlaynaBetterGuildAboutPopup" then found = true break end
        end
        if not found then table.insert(UISpecialFrames, "GlaynaBetterGuildAboutPopup") end
    end

    self.aboutPopup = frame
    self:RefreshAboutPopup()
    return frame
end

function GMG:RefreshAboutPopup()
    local frame = self.aboutPopup
    if not frame then return end
    frame.title:SetText(self:L("ABOUT_TITLE"))
    frame.meta:SetText(self:L("ABOUT_AUTHOR") .. "  •  " .. self:L("ABOUT_VERSION", tostring(self.version or "?")))
    frame.intro:SetText(self:L("ABOUT_INTRO"))
    frame.featuresTitle:SetText(self:L("ABOUT_FEATURES_TITLE"))
    frame.features:SetText(self:L("ABOUT_FEATURES"))
    frame.syncTitle:SetText(self:L("ABOUT_SYNC_TITLE"))
    frame.sync:SetText(self:L("ABOUT_SYNC"))
    frame.download:SetText(self:L("ABOUT_DOWNLOAD"))
    SetBoundedText(frame.close.label, self:L("ABOUT_CLOSE"), 118)
end

function GMG:OpenAboutPopup()
    local frame = self:CreateAboutPopup()
    if not frame then return end
    self:RefreshAboutPopup()
    frame:Show()
end

local GMGCreateSettingsPageBeforeV182 = GMG.CreateSettingsPage
function GMG:CreateSettingsPage(...)
    GMGCreateSettingsPageBeforeV182(self, ...)
    local page = self.settingsPage
    if not page or page.v182AboutButton then return end
    page.v182AboutButton = true

    page.aboutButton = CreateFlatButton(page, self:L("ABOUT"), 120, 30)
    page.aboutButton:SetPoint("TOPRIGHT", -22, -14)
    page.aboutButton:SetScript("OnClick", function() GMG:OpenAboutPopup() end)
    page.aboutButton:SetScript("OnEnter", function(button)
        button:SetBackdropColor(unpack(ACCENT_SOFT))
        button:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(GMG:L("ABOUT"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("ABOUT_TOOLTIP"), 0.75, 0.78, 0.88, true)
        GameTooltip:Show()
    end)
    page.aboutButton:SetScript("OnLeave", function(button)
        button:SetBackdropColor(unpack(PANEL_3))
        button:SetBackdropBorderColor(unpack(BORDER))
        GameTooltip:Hide()
    end)
end

local GMGRefreshLocalizationBeforeV182 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    GMGRefreshLocalizationBeforeV182(self, ...)
    local page = self.settingsPage
    if page and page.aboutButton and page.aboutButton.label then
        SetBoundedText(page.aboutButton.label, self:L("ABOUT"), 108)
    end
    self:RefreshAboutPopup()
    self:RefreshHeaderAddonVersion()
end
