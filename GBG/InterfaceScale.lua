-- G.B.G (Glayna Better Guild)
-- v1.8.1: direct +/- interface scaling and reliable guild-chat scrollbar.

local GMG = GlaynaBetterGuild
local floor = math.floor
local max = math.max
local min = math.min
local abs = math.abs
local format = string.format

GMG.Locales = GMG.Locales or { en = {}, fr = {} }
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}

local EN = {
    INTERFACE_SCALE = "Interface size",
    INTERFACE_SCALE_HELP = "Uniformly scales the complete GMG interface.",
    INTERFACE_SCALE_DECREASE = "Reduce interface size",
    INTERFACE_SCALE_INCREASE = "Increase interface size",
    INTERFACE_SCALE_CURRENT = "Current size: %d%%",
    CHAT_SCROLL_HELP = "Drag the bar or use the mouse wheel to browse guild messages.",
}
local FR = {
    INTERFACE_SCALE = "Taille de l'interface",
    INTERFACE_SCALE_HELP = "Réduit ou agrandit uniformément toute l'interface GMG.",
    INTERFACE_SCALE_DECREASE = "Réduire la taille de l'interface",
    INTERFACE_SCALE_INCREASE = "Agrandir la taille de l'interface",
    INTERFACE_SCALE_CURRENT = "Taille actuelle : %d%%",
    CHAT_SCROLL_HELP = "Faites glisser la barre ou utilisez la molette pour parcourir les messages de guilde.",
}
for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end

local SCALE_MIN = 0.60
local SCALE_MAX = 1.10
local SCALE_STEP = 0.05

local BUTTON_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local function ClampScale(value)
    value = tonumber(value) or 1
    return max(SCALE_MIN, min(SCALE_MAX, value))
end

local function RoundScale(value)
    return floor(ClampScale(value) / SCALE_STEP + 0.5) * SCALE_STEP
end

function GMG:GetInterfaceScale()
    if not self.db or not self.db.profile then return 1 end
    return RoundScale(self.db.profile.interfaceScale)
end

function GMG:SetInterfaceScale(value, persist)
    if not self.db or not self.db.profile then return end
    value = RoundScale(value)
    self.db.profile.interfaceScale = value
    if persist ~= false and self.PersistSettings then self:PersistSettings() end
    self:ApplyInterfaceScale()
    self:RefreshMainInterfaceScaleControl()
end

local function ApplyScale(frame, scale)
    if frame and frame.SetScale then frame:SetScale(scale) end
end

function GMG:ApplyInterfaceScale()
    local scale = self:GetInterfaceScale()

    ApplyScale(self.mainFrame, scale)
    ApplyScale(self.launcher, scale)

    -- Independent UIParent dialogs do not inherit the main-window scale.
    ApplyScale(self.noteEditor, scale)
    ApplyScale(self.imagePicker, scale)
    ApplyScale(self.keyCapture, scale)
    ApplyScale(self.copyLinkPopup, scale)
    ApplyScale(self.notificationSettingsPopup, scale)
    ApplyScale(self.appearancePopup, scale)
    ApplyScale(self.bannerSettingsPopup, scale)
    ApplyScale(self.updateAvailablePopup, scale)
    ApplyScale(self.aboutPopup, scale)
    ApplyScale(self.dungeonCreatePopup, scale)
    ApplyScale(self.dungeonApplicantPopup, scale)
    ApplyScale(self.dungeonRoleChangePopup, scale)
end

local function SetButtonVisual(button, enabled)
    if not button then return end
    button.scaleEnabled = enabled and true or false
    button:SetAlpha(enabled and 1 or 0.42)
    if enabled then
        button:SetBackdropColor(0.075, 0.082, 0.125, 0.98)
        button:SetBackdropBorderColor(0.24, 0.22, 0.38, 1)
    else
        button:SetBackdropColor(0.045, 0.052, 0.082, 0.98)
        button:SetBackdropBorderColor(0.12, 0.12, 0.20, 1)
    end
end

local function CreateScaleButton(parent, text)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(32)
    button:SetHeight(28)
    button:SetBackdrop(BUTTON_BACKDROP)
    button:SetBackdropColor(0.075, 0.082, 0.125, 0.98)
    button:SetBackdropBorderColor(0.24, 0.22, 0.38, 1)
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    button.label:SetPoint("CENTER", 0, 1)
    button.label:SetText(text)
    button.label:SetTextColor(0.88, 0.90, 0.96, 1)
    return button
end

function GMG:InstallMainInterfaceScaleControl()
    local frame = self.mainFrame
    if not frame or not frame.sidebar or frame.interfaceScaleControl then return end

    local holder = CreateFrame("Frame", nil, frame.sidebar)
    holder:SetWidth(154)
    holder:SetHeight(30)
    holder:SetPoint("BOTTOMLEFT", 18, 64)
    frame.interfaceScaleControl = holder

    holder.minus = CreateScaleButton(holder, "−")
    holder.minus:SetPoint("LEFT", 0, 0)

    holder.value = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    holder.value:SetWidth(82)
    holder.value:SetHeight(28)
    holder.value:SetPoint("LEFT", holder.minus, "RIGHT", 4, 0)
    holder.value:SetJustifyH("CENTER")
    holder.value:SetTextColor(0.60, 0.42, 1.00, 1)

    holder.plus = CreateScaleButton(holder, "+")
    holder.plus:SetPoint("LEFT", holder.value, "RIGHT", 4, 0)

    holder.minus:SetScript("OnClick", function(button)
        if not button.scaleEnabled then return end
        GMG:SetInterfaceScale(GMG:GetInterfaceScale() - SCALE_STEP, true)
    end)
    holder.plus:SetScript("OnClick", function(button)
        if not button.scaleEnabled then return end
        GMG:SetInterfaceScale(GMG:GetInterfaceScale() + SCALE_STEP, true)
    end)

    local function ShowScaleTooltip(button, titleKey)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L(titleKey), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("INTERFACE_SCALE_CURRENT", floor(GMG:GetInterfaceScale() * 100 + 0.5)), 0.60, 0.42, 1.00)
        GameTooltip:AddLine(GMG:L("INTERFACE_SCALE_HELP"), 0.75, 0.78, 0.88, true)
        GameTooltip:Show()
    end

    holder.minus:SetScript("OnEnter", function(button)
        if button.scaleEnabled then button:SetBackdropBorderColor(0.60, 0.42, 1.00, 1) end
        ShowScaleTooltip(button, "INTERFACE_SCALE_DECREASE")
    end)
    holder.minus:SetScript("OnLeave", function(button)
        SetButtonVisual(button, button.scaleEnabled)
        GameTooltip:Hide()
    end)
    holder.plus:SetScript("OnEnter", function(button)
        if button.scaleEnabled then button:SetBackdropBorderColor(0.60, 0.42, 1.00, 1) end
        ShowScaleTooltip(button, "INTERFACE_SCALE_INCREASE")
    end)
    holder.plus:SetScript("OnLeave", function(button)
        SetButtonVisual(button, button.scaleEnabled)
        GameTooltip:Hide()
    end)

    holder:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L("INTERFACE_SCALE"), 1, 1, 1)
        GameTooltip:AddLine(GMG:L("INTERFACE_SCALE_CURRENT", floor(GMG:GetInterfaceScale() * 100 + 0.5)), 0.60, 0.42, 1.00)
        GameTooltip:AddLine(GMG:L("INTERFACE_SCALE_HELP"), 0.75, 0.78, 0.88, true)
        GameTooltip:Show()
    end)
    holder:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self:RefreshMainInterfaceScaleControl()
end

function GMG:RefreshMainInterfaceScaleControl()
    local frame = self.mainFrame
    local holder = frame and frame.interfaceScaleControl
    if not holder then return end
    local scale = self:GetInterfaceScale()
    holder.value:SetText(format("%d%%", floor(scale * 100 + 0.5)))
    SetButtonVisual(holder.minus, scale > SCALE_MIN + 0.001)
    SetButtonVisual(holder.plus, scale < SCALE_MAX - 0.001)
end

-- The former appearance-window slider is intentionally removed. Scaling is now
-- available directly from the main sidebar above the settings cog.
function GMG:InstallInterfaceScaleControl()
    local frame = self.appearancePopup
    if not frame then return end
    if frame.interfaceScaleHolder then frame.interfaceScaleHolder:Hide() end
    frame:SetHeight(420)
    if frame.close then
        frame.close:ClearAllPoints()
        frame.close:SetPoint("BOTTOMRIGHT", -24, 20)
    end
end

function GMG:RefreshInterfaceScaleControl()
    self:RefreshMainInterfaceScaleControl()
end

-- ============================================================================
-- Guild-chat scrollbar: no longer remains artificially locked at the middle.
-- The thumb now follows the user's position from 0% (oldest) to 100% (latest).
-- ============================================================================
function GMG:SetGuildChatScrollValue(value)
    local page = self.chatPage
    if not page or not page.scroll then return end
    value = max(0, min(100, tonumber(value) or 100))
    page.v181ScrollValue = value
    page.v181ScrollInternal = true
    page.scroll:SetValue(value)
    page.v181ScrollInternal = nil
end

function GMG:InstallGuildChatScrollbarV181()
    local page = self.chatPage
    if not page or not page.scroll or not page.messages or page.v181ScrollbarInstalled then return end
    page.v181ScrollbarInstalled = true

    local function AtTop()
        if page.messages.AtTop then
            local ok, result = pcall(page.messages.AtTop, page.messages)
            if ok then return result and true or false end
        end
        return false
    end

    local function AtBottom()
        if page.messages.AtBottom then
            local ok, result = pcall(page.messages.AtBottom, page.messages)
            if ok then return result and true or false end
        end
        return false
    end

    local function FinishScroll(requestedValue)
        local top = AtTop()
        local bottom = AtBottom()
        if top and bottom then
            page.userReadingHistory = false
            if page.latestMessages then page.latestMessages:Hide() end
            GMG:SetGuildChatScrollValue(100)
        elseif top then
            page.userReadingHistory = true
            if page.latestMessages then page.latestMessages:Show() end
            GMG:SetGuildChatScrollValue(0)
        elseif bottom then
            page.userReadingHistory = false
            if page.latestMessages then page.latestMessages:Hide() end
            GMG:SetGuildChatScrollValue(100)
        else
            GMG:SetGuildChatScrollValue(requestedValue)
        end
    end

    local function PerformScroll(direction, amount, requestedValue)
        amount = max(1, floor(tonumber(amount) or 1))
        if direction > 0 then
            page.userReadingHistory = true
            if page.latestMessages then page.latestMessages:Show() end
            if requestedValue <= 0 and page.messages.ScrollToTop then
                page.messages:ScrollToTop()
            elseif IsControlKeyDown and IsControlKeyDown() and page.messages.PageUp then
                page.messages:PageUp()
            else
                for _ = 1, amount do
                    if page.messages.ScrollUp then page.messages:ScrollUp() end
                end
            end
        elseif direction < 0 then
            if requestedValue >= 100 and page.messages.ScrollToBottom then
                page.messages:ScrollToBottom()
            elseif IsControlKeyDown and IsControlKeyDown() and page.messages.PageDown then
                page.messages:PageDown()
            else
                for _ = 1, amount do
                    if page.messages.ScrollDown then page.messages:ScrollDown() end
                end
            end
        end
        FinishScroll(requestedValue)
    end

    page.scroll:SetMinMaxValues(0, 100)
    page.scroll:SetValueStep(1)
    if page.scroll.SetObeyStepOnDrag then page.scroll:SetObeyStepOnDrag(true) end
    GMG:SetGuildChatScrollValue(page.userReadingHistory and 50 or 100)

    page.scroll:SetScript("OnValueChanged", function(_, value)
        if page.v181ScrollInternal then return end
        local previous = tonumber(page.v181ScrollValue) or 100
        local delta = value - previous
        if abs(delta) < 0.5 then return end
        local amount = max(1, floor(abs(delta) / 4 + 0.5))
        PerformScroll(delta < 0 and 1 or -1, amount, value)
    end)

    local function WheelScroll(delta)
        local current = tonumber(page.v181ScrollValue) or 100
        if IsShiftKeyDown and IsShiftKeyDown() then
            local target = delta > 0 and 0 or 100
            PerformScroll(delta > 0 and 1 or -1, 30, target)
            return
        end
        local target = max(0, min(100, current + (delta > 0 and -8 or 8)))
        PerformScroll(delta > 0 and 1 or -1, 5, target)
    end

    page.messages:EnableMouseWheel(true)
    page.messages:SetScript("OnMouseWheel", function(_, delta) WheelScroll(delta) end)
    page.history:EnableMouseWheel(true)
    page.history:SetScript("OnMouseWheel", function(_, delta) WheelScroll(delta) end)

    if page.historyScrollUp then
        page.historyScrollUp:SetScript("OnClick", function()
            local current = tonumber(page.v181ScrollValue) or 100
            PerformScroll(1, 6, max(0, current - 10))
        end)
    end
    if page.historyScrollDown then
        page.historyScrollDown:SetScript("OnClick", function()
            local current = tonumber(page.v181ScrollValue) or 100
            PerformScroll(-1, 6, min(100, current + 10))
        end)
    end

    if page.latestMessages then
        page.latestMessages:SetScript("OnClick", function()
            page.userReadingHistory = false
            page.latestMessages:Hide()
            GMG:RefreshChat(true)
            page.messages:ScrollToBottom()
            GMG:SetGuildChatScrollValue(100)
        end)
    end

    page.v175ScrollHistory = function(direction, amount)
        local current = tonumber(page.v181ScrollValue) or 100
        local target = max(0, min(100, current + (direction > 0 and -5 or 5) * max(1, tonumber(amount) or 1)))
        PerformScroll(direction, amount, target)
    end

    page.scroll:SetScript("OnEnter", function(slider)
        GameTooltip:SetOwner(slider, "ANCHOR_LEFT")
        GameTooltip:AddLine(GMG:L("CHAT_SCROLL_HELP"), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    page.scroll:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Install controls whenever their owning frames are created.
local CreateAppearancePopupBeforeV181 = GMG.CreateAppearancePopup
function GMG:CreateAppearancePopup(...)
    CreateAppearancePopupBeforeV181(self, ...)
    self:InstallInterfaceScaleControl()
    self:ApplyInterfaceScale()
end

local RefreshAppearancePopupBeforeV181 = GMG.RefreshAppearancePopup
function GMG:RefreshAppearancePopup(...)
    RefreshAppearancePopupBeforeV181(self, ...)
    self:RefreshMainInterfaceScaleControl()
end

local RefreshLocalizationBeforeV181 = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    RefreshLocalizationBeforeV181(self, ...)
    self:RefreshMainInterfaceScaleControl()
end

local CreateUIBeforeV181 = GMG.CreateUI
function GMG:CreateUI(...)
    CreateUIBeforeV181(self, ...)
    self:InstallMainInterfaceScaleControl()
    self:InstallGuildChatScrollbarV181()
    self:ApplyInterfaceScale()
end

local RefreshChatBeforeV181 = GMG.RefreshChat
function GMG:RefreshChat(...)
    local result = RefreshChatBeforeV181(self, ...)
    local page = self.chatPage
    if page and page.v181ScrollbarInstalled and not page.userReadingHistory then
        self:SetGuildChatScrollValue(100)
    end
    return result
end

-- Ensure every independently-created popup immediately uses the saved scale.
local function WrapPopupCreator(methodName)
    local original = GMG[methodName]
    if type(original) ~= "function" then return end
    GMG[methodName] = function(self, ...)
        local result = original(self, ...)
        self:ApplyInterfaceScale()
        return result
    end
end

WrapPopupCreator("CreateNotificationSettingsPopup")
WrapPopupCreator("CreateBannerSettingsPopup")
WrapPopupCreator("CreateUpdateAvailablePopup")
WrapPopupCreator("CreateDungeonCreatePopup")
WrapPopupCreator("CreateDungeonApplicantPopup")
WrapPopupCreator("CreateDungeonRoleChangePopup")
WrapPopupCreator("CreateImagePicker")
WrapPopupCreator("CreateNoteEditor")
WrapPopupCreator("CreateKeyCapture")
WrapPopupCreator("CreateCopyLinkPopup")

local AddonLoadedBeforeV181 = GMG.ADDON_LOADED
function GMG:ADDON_LOADED(addonName)
    AddonLoadedBeforeV181(self, addonName)
    if addonName ~= self.name or not self.db or not self.db.profile then return end
    if self.db.profile.interfaceScale == nil then self.db.profile.interfaceScale = 1 end
    self.db.profile.interfaceScale = RoundScale(self.db.profile.interfaceScale)
    if self.PersistSettings then self:PersistSettings() end
    self:ApplyInterfaceScale()
    self:RefreshMainInterfaceScaleControl()
end
