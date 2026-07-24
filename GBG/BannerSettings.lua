-- G.B.G (Glayna Better Guild)
-- v1.5.6 - 20 new emblems and 10 new borders

local GMG = GlaynaBetterGuild
if not GMG then return end

local floor = math.floor
local max = math.max
local min = math.min
local abs = math.abs
local cos = math.cos
local sin = math.sin
local pi = math.pi
local tonumber = tonumber
local tostring = tostring
local unpack = unpack

GMG.version = "1.8.6"
GMG.BANNER_CONFIG_VERSION = 4
GMG.BANNER_ROTATION_STEPS = 24
GMG.BANNER_ROTATION_DEGREES = 15
GMG.BANNER_FONTS = {
    { key = "FRIZ", nameEN = "Friz Quadrata", nameFR = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF" },
    { key = "ARIAL", nameEN = "Arial Narrow", nameFR = "Arial étroite", path = "Fonts\\ARIALN.TTF" },
    { key = "MORPHEUS", nameEN = "Morpheus", nameFR = "Morpheus", path = "Fonts\\MORPHEUS.TTF" },
    { key = "SKURRI", nameEN = "Skurri", nameFR = "Skurri", path = "Fonts\\SKURRI.TTF" },
}

GMG.DEFAULT_BANNER_CONFIG.version = GMG.BANNER_CONFIG_VERSION
GMG.DEFAULT_BANNER_CONFIG.backgroundScale = 100
GMG.DEFAULT_BANNER_CONFIG.backgroundRotation = 0
GMG.DEFAULT_BANNER_CONFIG.borderScale = 100
GMG.DEFAULT_BANNER_CONFIG.borderRotation = 0
GMG.DEFAULT_BANNER_CONFIG.shieldScale = 72
GMG.DEFAULT_BANNER_CONFIG.shieldRotation = 0
GMG.DEFAULT_BANNER_CONFIG.weaponScale = 58
GMG.DEFAULT_BANNER_CONFIG.weaponRotation = 0
GMG.DEFAULT_BANNER_CONFIG.textFont = 1
GMG.DEFAULT_BANNER_CONFIG.textRotation = 0
GMG.DEFAULT_BANNER_CONFIG.textSize = 40

local EN = {
    BANNER_SETTINGS_BUTTON = "Guild banner / tabard creator",
    BANNER_SETTINGS_TITLE = "Guild banner / tabard creator",
    BANNER_SETTINGS_HELP = "",
    BANNER_LAYER = "Layer",
    BANNER_COLOR = "Color",
    BANNER_SIZE = "Size",
    BANNER_ROTATION = "Rotation",
    BANNER_POSITION = "Position",
    BANNER_POSITION_X = "Position X",
    BANNER_POSITION_Y = "Position Y",
    BANNER_FONT = "Font",
    BANNER_CLOSE = "Close",
    BANNER_APPLY = "Apply",
    BANNER_GM_REQUIRED = "You must be the guild master to modify the official guild banner through the addon.",
    BANNER_ASK_GM = "Ask",
    BANNER_GM_UNKNOWN = "Guild Master",
    BANNER_BACKGROUND_SIZE = "Background size",
    BANNER_BORDER_SIZE = "Border size",
    BANNER_BORDER_ROTATION = "Border rotation",
    BANNER_SHIELD_ROTATION = "Emblem rotation",
    BANNER_TEXT_ROTATION = "Text rotation",
    BANNER_TEXT_FONT = "Text font",
    BANNER_INITIALS = "Lettering",
}
local FR = {
    BANNER_SETTINGS_BUTTON = "Créateur de bannière / tabard",
    BANNER_SETTINGS_TITLE = "Créateur de bannière / tabard de guilde",
    BANNER_SETTINGS_HELP = "",
    BANNER_LAYER = "Calque",
    BANNER_COLOR = "Couleur",
    BANNER_SIZE = "Taille",
    BANNER_ROTATION = "Rotation",
    BANNER_POSITION = "Position",
    BANNER_POSITION_X = "Position X",
    BANNER_POSITION_Y = "Position Y",
    BANNER_FONT = "Police",
    BANNER_CLOSE = "Fermer",
    BANNER_APPLY = "Appliquer",
    BANNER_GM_REQUIRED = "Il faut être chef de guilde pour modifier la bannière de guilde via l’addon.",
    BANNER_ASK_GM = "Demandez à",
    BANNER_GM_UNKNOWN = "Maître de guilde",
    BANNER_BACKGROUND_SIZE = "Taille fond",
    BANNER_BORDER_SIZE = "Taille bordure",
    BANNER_BORDER_ROTATION = "Rotation bordure",
    BANNER_SHIELD_ROTATION = "Rotation emblème",
    BANNER_TEXT_ROTATION = "Rotation texte",
    BANNER_TEXT_FONT = "Police du texte",
    BANNER_INITIALS = "Lettrages",
}
GMG.Locales = GMG.Locales or { en = {}, fr = {} }
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end


function GMG:GetGuildMasterName()
    local members = self.rosterMembers or {}
    if #members == 0 and self:IsInGuild() and self.RebuildRosterCache and GetNumGuildMembers and GetNumGuildMembers() > 0 then
        self:RebuildRosterCache(false)
        members = self.rosterMembers or {}
    end
    for index = 1, #members do
        local member = members[index]
        if member and tonumber(member.rankIndex) == 0 then
            return self:NormalizeName(member.simpleName or member.name or "")
        end
    end
    if self:CanEditGuildImage() then return self:GetPlayerName() end
    if self:IsInGuild() and GuildRoster then GuildRoster() end
    return nil
end

function GMG:OpenWhisperTo(name)
    name = self:NormalizeName(name or "")
    if name == "" then return end
    if ChatFrame_SendTell then
        ChatFrame_SendTell(name)
    elseif ChatFrame_OpenChat then
        ChatFrame_OpenChat("/w " .. name .. " ")
    end
end

-- Draft controls are a visual sandbox for every player. Only Apply is gated.
function GMG:BannerEditAllowedOrWarn()
    return true
end

local function CopyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

local function ClampNumber(value, low, high, fallback)
    value = tonumber(value)
    if value == nil then value = fallback end
    return max(low, min(high, floor(value + 0.5)))
end

function GMG:GetBannerDraftStorageKey()
    local guildKey = self:GetGuildKey()
    if guildKey then return guildKey end
    local realm = GetRealmName and GetRealmName() or "UnknownRealm"
    return tostring(realm) .. "::__NO_GUILD__::" .. tostring(self:GetPlayerName() or "UnknownPlayer")
end

function GMG:GetBannerDraft()
    if not self.db or not self.db.profile then return self:NormalizeBannerConfig(self.DEFAULT_BANNER_CONFIG) end
    self.db.profile.bannerDrafts = self.db.profile.bannerDrafts or {}
    local key = self:GetBannerDraftStorageKey()
    local draft = self.db.profile.bannerDrafts[key]
    if type(draft) ~= "table" then
        local record = self:GetGuildBannerRecord()
        draft = self:NormalizeBannerConfig(record and record.config or self.DEFAULT_BANNER_CONFIG)
        self.db.profile.bannerDrafts[key] = CopyTable(draft)
    else
        draft = self:NormalizeBannerConfig(draft)
        self.db.profile.bannerDrafts[key] = CopyTable(draft)
    end
    return self.db.profile.bannerDrafts[key]
end

function GMG:SetBannerDraft(config)
    if not self.db or not self.db.profile then return end
    self.db.profile.bannerDrafts = self.db.profile.bannerDrafts or {}
    local normalized = self:NormalizeBannerConfig(config)
    self.db.profile.bannerDrafts[self:GetBannerDraftStorageKey()] = CopyTable(normalized)
    -- Legacy compatibility for older code paths; official association remains
    -- in bannerDrafts[guild+realm].
    self.db.profile.bannerDraft = CopyTable(normalized)
    if self.PersistSettings then self:PersistSettings() end
end

local function ReverseText(value)
    value = tostring(value or "")
    local output = ""
    for index = string.len(value), 1, -1 do
        output = output .. string.sub(value, index, index)
    end
    return output
end

local function VerticalText(value, reverse)
    value = tostring(value or "")
    if reverse then value = ReverseText(value) end
    local output = ""
    for index = 1, string.len(value) do
        if output ~= "" then output = output .. "\n" end
        output = output .. string.sub(value, index, index)
    end
    return output
end

function GMG:SanitizeBannerText(value)
    value = tostring(value or "")
    value = string.upper(value)
    -- Lettering may contain letters, numbers, spaces and periods. Commas stay
    -- forbidden because the compact guild synchronization format uses them as
    -- field separators.
    value = string.gsub(value, "[^%w%. ]", "")
    return string.sub(value, 1, 30)
end

function GMG:NormalizeBannerConfig(config)
    config = CopyTable(config or self.DEFAULT_BANNER_CONFIG)
    local oldVersion = tonumber(config.version) or 1
    if oldVersion < 2 then
        config.weaponRotation = ClampNumber(config.weaponRotation, 0, 7, 0) * 3
    end

    config.version = self.BANNER_CONFIG_VERSION
    config.background = ClampNumber(config.background, 0, self:GetBannerAssetCount("background"), 0)
    config.backgroundColor = ClampNumber(config.backgroundColor, 1, #self.BANNER_PALETTE, 6)
    config.backgroundScale = ClampNumber(config.backgroundScale, 10, 200, 100)
    config.backgroundRotation = ClampNumber(config.backgroundRotation, 0, self.BANNER_ROTATION_STEPS - 1, 0)

    config.border = ClampNumber(config.border, 0, self:GetBannerAssetCount("border"), 0)
    config.borderColor = ClampNumber(config.borderColor, 1, #self.BANNER_PALETTE, 8)
    config.borderScale = ClampNumber(config.borderScale, 10, 200, 100)
    config.borderRotation = ClampNumber(config.borderRotation, 0, self.BANNER_ROTATION_STEPS - 1, 0)

    config.shield = ClampNumber(config.shield, 0, self:GetBannerAssetCount("shield"), 0)
    config.shieldColor = ClampNumber(config.shieldColor, 1, #self.BANNER_PALETTE, 2)
    config.shieldScale = ClampNumber(config.shieldScale, 10, 200, 72)
    config.shieldRotation = ClampNumber(config.shieldRotation, 0, self.BANNER_ROTATION_STEPS - 1, 0)
    config.shieldX = ClampNumber(config.shieldX, -128, 128, 0)
    config.shieldY = ClampNumber(config.shieldY, -128, 128, 2)

    config.weapon = ClampNumber(config.weapon, 0, self:GetBannerAssetCount("weapon"), 0)
    config.weaponColor = ClampNumber(config.weaponColor, 1, #self.BANNER_PALETTE, 7)
    config.weaponScale = ClampNumber(config.weaponScale, 10, 200, 58)
    config.weaponRotation = ClampNumber(config.weaponRotation, 0, self.BANNER_ROTATION_STEPS - 1, 0)
    config.weaponX = ClampNumber(config.weaponX, -128, 128, 0)
    config.weaponY = ClampNumber(config.weaponY, -128, 128, 4)

    config.text = self:SanitizeBannerText(config.text or "")
    config.textColor = ClampNumber(config.textColor, 1, #self.BANNER_PALETTE, 1)
    config.textSize = ClampNumber(config.textSize, 10, 300, 40)
    config.textX = ClampNumber(config.textX, -128, 128, 0)
    config.textY = ClampNumber(config.textY, -128, 128, -32)
    config.textFont = ClampNumber(config.textFont, 1, #self.BANNER_FONTS, 1)
    config.textRotation = ClampNumber(config.textRotation, 0, self.BANNER_ROTATION_STEPS - 1, 0)
    return config
end

function GMG:EncodeBannerConfig(config)
    config = self:NormalizeBannerConfig(config)
    return table.concat({
        tostring(config.version),
        tostring(config.background), tostring(config.backgroundColor), tostring(config.backgroundScale), tostring(config.backgroundRotation),
        tostring(config.border), tostring(config.borderColor), tostring(config.borderScale), tostring(config.borderRotation),
        tostring(config.shield), tostring(config.shieldColor), tostring(config.shieldScale), tostring(config.shieldRotation), tostring(config.shieldX), tostring(config.shieldY),
        tostring(config.weapon), tostring(config.weaponColor), tostring(config.weaponScale), tostring(config.weaponRotation), tostring(config.weaponX), tostring(config.weaponY),
        config.text, tostring(config.textColor), tostring(config.textSize), tostring(config.textX), tostring(config.textY), tostring(config.textFont), tostring(config.textRotation),
    }, ",")
end

local function SplitSimple(value, separator)
    local result = {}
    local start = 1
    separator = separator or ","
    while true do
        local found = string.find(value, separator, start, true)
        if not found then
            result[#result + 1] = string.sub(value, start)
            break
        end
        result[#result + 1] = string.sub(value, start, found - 1)
        start = found + string.len(separator)
    end
    return result
end

function GMG:DecodeBannerConfig(value)
    local fields = SplitSimple(tostring(value or ""), ",")
    local version = tonumber(fields[1]) or 1
    if version < 2 then
        if #fields < 21 then return nil end
        return self:NormalizeBannerConfig({
            version = 1,
            background = fields[2], backgroundColor = fields[3],
            border = fields[4], borderColor = fields[5],
            shield = fields[6], shieldColor = fields[7],
            weapon = fields[8], weaponColor = fields[9],
            text = fields[10], textColor = fields[11], textSize = fields[12],
            textX = fields[13], textY = fields[14], shieldScale = fields[15],
            shieldX = fields[16], shieldY = fields[17], weaponScale = fields[18],
            weaponX = fields[19], weaponY = fields[20], weaponRotation = fields[21],
        })
    end
    if #fields < 28 then return nil end
    return self:NormalizeBannerConfig({
        version = fields[1],
        background = fields[2], backgroundColor = fields[3], backgroundScale = fields[4], backgroundRotation = fields[5],
        border = fields[6], borderColor = fields[7], borderScale = fields[8], borderRotation = fields[9],
        shield = fields[10], shieldColor = fields[11], shieldScale = fields[12], shieldRotation = fields[13], shieldX = fields[14], shieldY = fields[15],
        weapon = fields[16], weaponColor = fields[17], weaponScale = fields[18], weaponRotation = fields[19], weaponX = fields[20], weaponY = fields[21],
        text = fields[22], textColor = fields[23], textSize = fields[24], textX = fields[25], textY = fields[26], textFont = fields[27], textRotation = fields[28],
    })
end

local function ResetTexCoord(texture)
    if texture and texture.SetTexCoord then texture:SetTexCoord(0, 1, 0, 1) end
end

local function ApplyLayer(GMGObject, visual, texture, kind, assetIndex, colorIndex, scalePercent, rotationStep, x, y)
    local path = GMGObject:GetBannerAssetPath(kind, assetIndex)
    if not path then
        texture:SetTexture(nil)
        texture:Hide()
        return
    end

    local color = GMGObject:GetBannerColor(colorIndex)
    local size = visual.bannerSize or visual:GetWidth() or 128
    local scale = ClampNumber(scalePercent, 10, 200, 100)
    local rotation = ClampNumber(rotationStep, 0, GMGObject.BANNER_ROTATION_STEPS - 1, 0)
    local radians = rotation * GMGObject.BANNER_ROTATION_DEGREES * pi / 180

    texture:SetTexture(path)
    texture:SetVertexColor(color.r, color.g, color.b, 1)
    texture:ClearAllPoints()
    ResetTexCoord(texture)

    -- The visual now uses a ScrollFrame as a real clipping viewport. This lets
    -- every layer genuinely grow from 101% to 200% while everything outside
    -- the square banner is cut instead of being displayed.
    local drawSize = max(8, floor(size * scale / 100 + 0.5))
    local content = visual.canvas or visual
    texture:SetWidth(drawSize)
    texture:SetHeight(drawSize)
    texture:SetPoint("CENTER", content, "CENTER", floor((tonumber(x) or 0) * size / 256), floor((tonumber(y) or 0) * size / 256))
    if texture.SetRotation then pcall(texture.SetRotation, texture, radians) end
    texture:Show()
end

function GMG:CreateBannerVisual(parent, size)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(size)
    frame:SetHeight(size)
    frame.bannerSize = size

    -- ScrollFrame clipping is available on the 3.3.5 client and reliably cuts
    -- oversized/rotated layers at the exact banner limits. The large centered
    -- canvas leaves enough room for a 200% layer even when rotated diagonally.
    frame.clip = CreateFrame("ScrollFrame", nil, frame)
    frame.clip:SetAllPoints(frame)
    frame.canvasSize = size * 4
    frame.canvas = CreateFrame("Frame", nil, frame.clip)
    frame.canvas:SetWidth(frame.canvasSize)
    frame.canvas:SetHeight(frame.canvasSize)
    frame.canvas:SetPoint("TOPLEFT", frame.clip, "TOPLEFT", 0, 0)
    frame.clip:SetScrollChild(frame.canvas)
    frame.centerScroll = floor((frame.canvasSize - size) / 2 + 0.5)
    frame.clip:SetHorizontalScroll(frame.centerScroll)
    frame.clip:SetVerticalScroll(frame.centerScroll)
    frame.clip:SetScript("OnShow", function(self)
        self:SetHorizontalScroll(frame.centerScroll)
        self:SetVerticalScroll(frame.centerScroll)
    end)

    frame.background = frame.canvas:CreateTexture(nil, "BACKGROUND")
    frame.shield = frame.canvas:CreateTexture(nil, "ARTWORK")
    frame.weapon = frame.canvas:CreateTexture(nil, "OVERLAY")
    frame.border = frame.canvas:CreateTexture(nil, "OVERLAY")

    frame.textAnchor = CreateFrame("Frame", nil, frame.canvas)
    frame.textAnchor:SetWidth(1)
    frame.textAnchor:SetHeight(1)
    frame.text = frame.textAnchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("CENTER", frame.textAnchor, "CENTER", 0, 0)
    frame.text:SetJustifyH("CENTER")
    frame.text:SetJustifyV("MIDDLE")
    frame.text:SetWidth(frame.canvasSize)
    frame.text:SetHeight(frame.canvasSize)
    if frame.text.SetWordWrap then frame.text:SetWordWrap(false) end
    if frame.text.SetNonSpaceWrap then frame.text:SetNonSpaceWrap(false) end
    frame.text:SetShadowColor(0, 0, 0, 0.95)
    frame.text:SetShadowOffset(1, -1)
    frame:Hide()
    return frame
end

function GMG:ApplyBannerToVisual(visual, config)
    if not visual then return end
    if not config then
        visual.background:SetTexture(nil)
        visual.border:SetTexture(nil)
        visual.shield:SetTexture(nil)
        visual.weapon:SetTexture(nil)
        visual.text:SetText("")
        visual:Hide()
        return
    end

    config = self:NormalizeBannerConfig(config)
    local size = visual.bannerSize or visual:GetWidth() or 128
    if visual.clip and visual.centerScroll then
        visual.clip:SetHorizontalScroll(visual.centerScroll)
        visual.clip:SetVerticalScroll(visual.centerScroll)
    end
    ApplyLayer(self, visual, visual.background, "background", config.background, config.backgroundColor, config.backgroundScale, config.backgroundRotation, 0, 0)
    ApplyLayer(self, visual, visual.border, "border", config.border, config.borderColor, config.borderScale, config.borderRotation, 0, 0)
    ApplyLayer(self, visual, visual.shield, "shield", config.shield, config.shieldColor, config.shieldScale, config.shieldRotation, config.shieldX, config.shieldY)
    ApplyLayer(self, visual, visual.weapon, "weapon", config.weapon, config.weaponColor, config.weaponScale, config.weaponRotation, config.weaponX, config.weaponY)

    local textColor = self:GetBannerColor(config.textColor)
    local font = self.BANNER_FONTS[config.textFont] or self.BANNER_FONTS[1]
    local requestedFontSize = max(6, floor(config.textSize * size / 256 + 0.5))
    local baseFontSize = min(requestedFontSize, 64)
    local textScale = requestedFontSize / baseFontSize
    local content = visual.canvas or visual
    local anchor = visual.textAnchor or visual

    anchor:ClearAllPoints()
    anchor:SetPoint("CENTER", content, "CENTER", floor(config.textX * size / 256), floor(config.textY * size / 256))
    visual.text:ClearAllPoints()
    visual.text:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    if visual.text.SetScale then visual.text:SetScale(textScale) end
    -- Compensate the font-string bounds for its scale so long lettering stays
    -- on one line; the ScrollFrame viewport performs the final visible crop.
    local textBounds = (visual.canvasSize or (size * 4)) / textScale
    visual.text:SetWidth(textBounds)
    visual.text:SetHeight(textBounds)
    pcall(visual.text.SetFont, visual.text, font.path, baseFontSize, "OUTLINE")
    visual.text:SetTextColor(textColor.r, textColor.g, textColor.b, 1)

    local textValue = config.text or ""
    local radians = config.textRotation * self.BANNER_ROTATION_DEGREES * pi / 180
    local rotated = false
    if visual.text.SetRotation then rotated = pcall(visual.text.SetRotation, visual.text, radians) end
    if not rotated then
        local cardinal = config.textRotation % self.BANNER_ROTATION_STEPS
        if cardinal == 6 then textValue = VerticalText(textValue, false)
        elseif cardinal == 18 then textValue = VerticalText(textValue, true)
        elseif cardinal == 12 then textValue = ReverseText(textValue) end
    end
    visual.text:SetText(textValue)
    visual:Show()
end

-- The editor is no longer a sidebar/content tab. Banner.lua's CreateUI wrapper
-- calls these methods dynamically, so replacing them before UI creation keeps
-- the old page and sidebar button from being created at all.
function GMG:CreateBannerPage() end
function GMG:CreateBannerSidebarTab() end

local UI_BG = { 0.026, 0.032, 0.052, 0.99 }
local UI_PANEL = { 0.045, 0.052, 0.082, 0.99 }
local UI_PANEL_2 = { 0.065, 0.070, 0.105, 0.99 }
local UI_BORDER = { 0.17, 0.17, 0.27, 1 }
local UI_ACCENT = { 0.58, 0.34, 0.92, 1 }
local UI_MUTED = { 0.52, 0.54, 0.64, 1 }

local function SetBackdrop(frame, background, border)
    if not frame or not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(background or UI_PANEL))
    frame:SetBackdropBorderColor(unpack(border or UI_BORDER))
end

local function CreateLabel(parent, text, template)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormalSmall")
    label:SetText(text or "")
    label:SetTextColor(0.88, 0.89, 0.96, 1)
    return label
end

local function CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 100)
    button:SetHeight(height or 28)
    SetBackdrop(button, UI_PANEL_2, UI_BORDER)
    button.label = CreateLabel(button, text or "", "GameFontNormalSmall")
    button.label:SetPoint("CENTER")
    button:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(UI_ACCENT)) end)
    button:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(UI_BORDER)) end)
    return button
end

local function SetButtonEnabled(button, enabled)
    if not button then return end
    if enabled then button:Enable(); button:SetAlpha(1) else button:Disable(); button:SetAlpha(0.42) end
end

function GMG:GetBannerFontName(index)
    local font = self.BANNER_FONTS[ClampNumber(index, 1, #self.BANNER_FONTS, 1)] or self.BANNER_FONTS[1]
    return self:GetLanguage() == "fr" and font.nameFR or font.nameEN
end

function GMG:GetBannerSelectorDisplay(field, value, isColor)
    if isColor then
        local color = self:GetBannerColor(value)
        local name = self:L("BANNER_COLOR_" .. color.key)
        return tostring(value) .. " · " .. name, color
    end
    if field == "background" or field == "border" or field == "shield" or field == "weapon" then
        if tonumber(value) == 0 then return "0 · " .. self:L("BANNER_NONE") end
        return tostring(value) .. " · " .. self:L("BANNER_ASSET", value)
    elseif field == "backgroundScale" or field == "borderScale" or field == "shieldScale" or field == "weaponScale" then
        return tostring(value) .. "%"
    elseif field == "backgroundRotation" or field == "borderRotation" or field == "shieldRotation" or field == "weaponRotation" or field == "textRotation" then
        return tostring((tonumber(value) or 0) * self.BANNER_ROTATION_DEGREES) .. "°"
    elseif field == "textFont" then
        return self:GetBannerFontName(value)
    end
    return tostring(value)
end

function GMG:AdjustBannerDraft(field, delta, low, high, wrap)
    if not self:BannerEditAllowedOrWarn() then return end
    local draft = CopyTable(self:GetBannerDraft())
    local value = tonumber(draft[field]) or low
    value = value + delta
    if wrap then
        if value > high then value = low elseif value < low then value = high end
    else
        value = max(low, min(high, value))
    end
    draft[field] = value
    self:SetBannerDraft(draft)
    if self.bannerSettingsPopup then self.bannerSettingsPopup.dirty = true end
    self:RefreshBannerSettingsPopup()
end

function GMG:CreateBannerSettingsSelector(parent, x, y, width, field, low, high, step, isColor)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetPoint("TOPLEFT", x, y)
    holder:SetWidth(width)
    holder:SetHeight(27)
    holder.field = field
    holder.isColor = isColor
    holder.left = CreateButton(holder, "<", 26, 25)
    holder.left:SetPoint("LEFT", 0, 0)
    holder.right = CreateButton(holder, ">", 26, 25)
    holder.right:SetPoint("RIGHT", 0, 0)
    holder.value = CreateLabel(holder, "", "GameFontNormalSmall")
    holder.value:SetPoint("LEFT", holder.left, "RIGHT", 3, 0)
    holder.value:SetPoint("RIGHT", holder.right, "LEFT", -3, 0)
    holder.value:SetJustifyH("CENTER")
    holder.swatch = holder:CreateTexture(nil, "ARTWORK")
    holder.swatch:SetWidth(9)
    holder.swatch:SetHeight(9)
    holder.swatch:SetPoint("LEFT", holder.left, "RIGHT", 5, 0)
    if not isColor then holder.swatch:Hide() end
    holder.left:SetScript("OnClick", function() GMG:AdjustBannerDraft(field, -(step or 1), low, high, true) end)
    holder.right:SetScript("OnClick", function() GMG:AdjustBannerDraft(field, step or 1, low, high, true) end)
    return holder
end

local function CreateColumnHeader(parent, text, x, y, width)
    local label = CreateLabel(parent, text, "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", x, y)
    label:SetWidth(width)
    label:SetJustifyH("CENTER")
    label:SetTextColor(unpack(UI_MUTED))
    return label
end

function GMG:CreateBannerSettingsPopup()
    if not self.mainFrame or self.bannerSettingsPopup then return end
    local frame = CreateFrame("Frame", "GlaynaBetterGuildBannerSettings", self.mainFrame)
    frame:SetWidth(980)
    frame:SetHeight(620)
    frame:SetPoint("CENTER", self.mainFrame, "CENTER", 0, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetClampedToScreen(true)
    SetBackdrop(frame, UI_BG, UI_ACCENT)
    frame:Hide()

    frame.title = CreateLabel(frame, self:L("BANNER_SETTINGS_TITLE"), "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 20, -16)
    frame.help = CreateLabel(frame, "", "GameFontNormalSmall")
    frame.help:Hide()

    frame.close = CreateButton(frame, "×", 28, 28)
    frame.close:SetPoint("TOPRIGHT", -12, -12)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    frame.editor = CreateFrame("Frame", nil, frame)
    frame.editor:SetPoint("TOPLEFT", 18, -50)
    frame.editor:SetPoint("BOTTOMLEFT", 18, 18)
    frame.editor:SetWidth(650)
    SetBackdrop(frame.editor, UI_PANEL, UI_BORDER)

    frame.previewPanel = CreateFrame("Frame", nil, frame)
    frame.previewPanel:SetPoint("TOPLEFT", frame.editor, "TOPRIGHT", 14, 0)
    frame.previewPanel:SetPoint("BOTTOMRIGHT", -18, 18)
    SetBackdrop(frame.previewPanel, UI_PANEL, UI_BORDER)
    frame.previewTitle = CreateLabel(frame.previewPanel, self:L("BANNER_PREVIEW"), "GameFontNormal")
    frame.previewTitle:SetPoint("TOP", 0, -16)
    frame.preview = self:CreateBannerVisual(frame.previewPanel, 250)
    frame.preview:SetPoint("TOP", 0, -48)
    SetBackdrop(frame.preview, { 0.02, 0.02, 0.035, 1 }, UI_BORDER)

    CreateColumnHeader(frame.editor, self:L("BANNER_LAYER"), 92, -18, 126)
    CreateColumnHeader(frame.editor, self:L("BANNER_COLOR"), 228, -18, 126)
    CreateColumnHeader(frame.editor, self:L("BANNER_SIZE"), 364, -18, 116)
    CreateColumnHeader(frame.editor, self:L("BANNER_ROTATION"), 490, -18, 116)

    frame.rows = {}
    local rowDefs = {
        { label = "BANNER_BACKGROUND", asset = "background", color = "backgroundColor", scale = "backgroundScale", rotation = nil },
        { label = "BANNER_BORDER", asset = "border", color = "borderColor", scale = "borderScale", rotation = "borderRotation" },
        { label = "BANNER_SHIELD", asset = "shield", color = "shieldColor", scale = "shieldScale", rotation = "shieldRotation" },
        { label = "BANNER_WEAPON", asset = "weapon", color = "weaponColor", scale = "weaponScale", rotation = "weaponRotation" },
    }
    for index, def in ipairs(rowDefs) do
        local y = -52 - (index - 1) * 66
        local row = CreateFrame("Frame", nil, frame.editor)
        row:SetPoint("TOPLEFT", 10, y)
        row:SetWidth(630)
        row:SetHeight(54)
        SetBackdrop(row, UI_PANEL_2, { 0.11, 0.11, 0.18, 1 })
        row.label = CreateLabel(row, self:L(def.label), "GameFontNormal")
        row.label:SetPoint("LEFT", 10, 0)
        row.label:SetWidth(70)
        row.label:SetJustifyH("LEFT")
        row.labelKey = def.label
        row.asset = self:CreateBannerSettingsSelector(row, 82, -13, 126, def.asset, 0, self:GetBannerAssetCount(def.asset), 1, false)
        row.color = self:CreateBannerSettingsSelector(row, 218, -13, 126, def.color, 1, #self.BANNER_PALETTE, 1, true)
        row.scale = self:CreateBannerSettingsSelector(row, 354, -13, 116, def.scale, 10, 200, 10, false)
        if def.rotation then
            row.rotation = self:CreateBannerSettingsSelector(row, 480, -13, 116, def.rotation, 0, self.BANNER_ROTATION_STEPS - 1, 1, false)
        else
            row.rotation = nil
            row.rotationEmpty = CreateLabel(row, "—", "GameFontNormalSmall")
            row.rotationEmpty:SetPoint("CENTER", row, "LEFT", 538, 0)
            row.rotationEmpty:SetTextColor(unpack(UI_MUTED))
        end
        frame.rows[index] = row
    end

    local textY = -322
    frame.textRow = CreateFrame("Frame", nil, frame.editor)
    frame.textRow:SetPoint("TOPLEFT", 10, textY)
    frame.textRow:SetWidth(630)
    frame.textRow:SetHeight(116)
    SetBackdrop(frame.textRow, UI_PANEL_2, { 0.11, 0.11, 0.18, 1 })
    frame.textRow.label = CreateLabel(frame.textRow, self:L("BANNER_INITIALS"), "GameFontNormal")
    frame.textRow.label:SetPoint("TOPLEFT", 10, -18)
    frame.textEdit = CreateFrame("EditBox", nil, frame.textRow)
    frame.textEdit:SetPoint("TOPLEFT", 82, -12)
    frame.textEdit:SetWidth(126)
    frame.textEdit:SetHeight(27)
    frame.textEdit:SetAutoFocus(false)
    frame.textEdit:SetMaxLetters(30)
    frame.textEdit:SetFontObject("ChatFontNormal")
    if frame.textEdit.SetTextInsets then frame.textEdit:SetTextInsets(8, 8, 0, 0) end
    SetBackdrop(frame.textEdit, UI_BG, UI_BORDER)
    frame.textEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    frame.textEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    frame.textEdit:SetScript("OnTextChanged", function(self, userInput)
        if not userInput or GMG.bannerSettingsRefreshingText then return end
        if not GMG:BannerEditAllowedOrWarn() then GMG:RefreshBannerSettingsPopup(); return end
        local clean = GMG:SanitizeBannerText(self:GetText())
        if clean ~= self:GetText() then
            GMG.bannerSettingsRefreshingText = true
            self:SetText(clean)
            GMG.bannerSettingsRefreshingText = nil
        end
        local draft = CopyTable(GMG:GetBannerDraft())
        draft.text = clean
        GMG:SetBannerDraft(draft)
        frame.dirty = true
        GMG:RefreshBannerSettingsPopup(true)
    end)
    frame.textColor = self:CreateBannerSettingsSelector(frame.textRow, 218, -12, 126, "textColor", 1, #self.BANNER_PALETTE, 1, true)
    frame.textSize = self:CreateBannerSettingsSelector(frame.textRow, 354, -12, 116, "textSize", 10, 300, 10, false)

    frame.positionLabel = CreateLabel(frame.textRow, self:L("BANNER_POSITION"), "GameFontNormalSmall")
    frame.positionLabel:SetPoint("TOPLEFT", 480, -4)
    frame.positionLabel:SetTextColor(unpack(UI_MUTED))
    frame.textX = self:CreateBannerSettingsSelector(frame.textRow, 480, -24, 116, "textX", -128, 128, 4, false)
    frame.textY = self:CreateBannerSettingsSelector(frame.textRow, 480, -54, 116, "textY", -128, 128, 4, false)

    frame.fontLabel = CreateLabel(frame.textRow, self:L("BANNER_FONT"), "GameFontNormalSmall")
    frame.fontLabel:SetPoint("TOPLEFT", 82, -62)
    frame.fontLabel:SetTextColor(unpack(UI_MUTED))
    frame.textFont = self:CreateBannerSettingsSelector(frame.textRow, 128, -68, 216, "textFont", 1, #self.BANNER_FONTS, 1, false)
    frame.rotationLabel = CreateLabel(frame.textRow, self:L("BANNER_TEXT_ROTATION"), "GameFontNormalSmall")
    frame.rotationLabel:SetPoint("TOPLEFT", 354, -62)
    frame.rotationLabel:SetTextColor(unpack(UI_MUTED))
    frame.textRotation = self:CreateBannerSettingsSelector(frame.textRow, 430, -68, 166, "textRotation", 0, self.BANNER_ROTATION_STEPS - 1, 1, false)

    frame.reset = CreateButton(frame.editor, self:L("BANNER_RESET"), 132, 30)
    frame.reset:SetPoint("BOTTOMLEFT", 12, 12)
    frame.reset:SetScript("OnClick", function()
        if not GMG:BannerEditAllowedOrWarn() then return end
        GMG:SetBannerDraft(CopyTable(GMG.DEFAULT_BANNER_CONFIG))
        frame.dirty = true
        GMG:RefreshBannerSettingsPopup()
    end)
    frame.apply = CreateButton(frame.editor, self:L("BANNER_APPLY"), 160, 30)
    frame.apply:SetPoint("LEFT", frame.reset, "RIGHT", 10, 0)
    frame.apply:SetScript("OnClick", function()
        if not GMG:CanPublishGuildBanner() then return end
        if GMG:PublishGuildBanner(GMG:GetBannerDraft()) then
            frame.dirty = nil
            GMG:RefreshBannerSettingsPopup()
        end
    end)
    -- Compatibility alias for older refresh/localization code paths.
    frame.publish = frame.apply
    frame.closeBottom = CreateButton(frame.editor, self:L("BANNER_CLOSE"), 132, 30)
    frame.closeBottom:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.closeBottom:SetScript("OnClick", function() frame:Hide() end)

    frame.status = CreateLabel(frame.previewPanel, "", "GameFontNormalSmall")
    frame.status:SetPoint("TOPLEFT", 16, -322)
    frame.status:SetPoint("TOPRIGHT", -16, -322)
    frame.status:SetHeight(36)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetJustifyV("TOP")
    frame.status:SetTextColor(unpack(UI_MUTED))
    if frame.status.SetWordWrap then frame.status:SetWordWrap(true) end

    frame.permissionText = CreateLabel(frame.previewPanel, "", "GameFontNormalSmall")
    frame.permissionText:SetPoint("TOPLEFT", 16, -360)
    frame.permissionText:SetPoint("TOPRIGHT", -16, -360)
    frame.permissionText:SetHeight(44)
    frame.permissionText:SetJustifyH("LEFT")
    frame.permissionText:SetJustifyV("TOP")
    frame.permissionText:SetTextColor(1, 0.82, 0.16, 1)
    if frame.permissionText.SetWordWrap then frame.permissionText:SetWordWrap(true) end

    frame.askGM = CreateLabel(frame.previewPanel, "", "GameFontNormalSmall")
    frame.askGM:SetPoint("TOPLEFT", 16, -410)
    frame.askGM:SetTextColor(1, 0.82, 0.16, 1)

    frame.gmWhisper = CreateFrame("Button", nil, frame.previewPanel)
    frame.gmWhisper:SetPoint("LEFT", frame.askGM, "RIGHT", 5, 0)
    frame.gmWhisper:SetWidth(190)
    frame.gmWhisper:SetHeight(22)
    frame.gmWhisper.label = CreateLabel(frame.gmWhisper, "", "GameFontNormal")
    frame.gmWhisper.label:SetPoint("LEFT")
    frame.gmWhisper.label:SetTextColor(1, 1, 1, 1)
    frame.gmWhisper:SetScript("OnClick", function(self)
        if self.playerName then GMG:OpenWhisperTo(self.playerName) end
    end)
    frame.gmWhisper:SetScript("OnEnter", function(self)
        if not self.playerName then return end
        self.label:SetTextColor(1, 1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("/w " .. self.playerName, 1, 1, 1)
        GameTooltip:Show()
    end)
    frame.gmWhisper:SetScript("OnLeave", function(self)
        self.label:SetTextColor(1, 1, 1, 1)
        GameTooltip:Hide()
    end)

    frame.syncInfo = CreateLabel(frame.previewPanel, "", "GameFontNormalSmall")
    frame.syncInfo:SetPoint("BOTTOMLEFT", 16, 18)
    frame.syncInfo:SetPoint("BOTTOMRIGHT", -16, 18)
    frame.syncInfo:SetJustifyH("LEFT")
    frame.syncInfo:SetTextColor(0.36, 0.78, 0.52, 1)

    self.bannerSettingsPopup = frame
end

function GMG:RefreshBannerSettingsSelector(selector, draft, editable)
    if not selector then return end
    local value = draft[selector.field]
    local text, color = self:GetBannerSelectorDisplay(selector.field, value, selector.isColor)
    selector.value:SetText(text)
    if selector.isColor and color then
        selector.swatch:SetTexture("Interface\\Buttons\\WHITE8X8")
        selector.swatch:SetVertexColor(color.r, color.g, color.b, 1)
        selector.value:SetTextColor(color.r, color.g, color.b, 1)
    else
        selector.value:SetTextColor(0.9, 0.9, 0.96, 1)
    end
    SetButtonEnabled(selector.left, editable)
    SetButtonEnabled(selector.right, editable)
end

function GMG:RefreshBannerSettingsPopup(keepEditText)
    local frame = self.bannerSettingsPopup
    if not frame then return end
    local draft = self:GetBannerDraft()
    local previewEditable = true
    local canApply = self:CanPublishGuildBanner()

    for _, row in ipairs(frame.rows or {}) do
        self:RefreshBannerSettingsSelector(row.asset, draft, previewEditable)

        -- v1.6.0: when a layer has no selected asset (value 0), only its
        -- asset selector remains visible. Color, size and rotation become
        -- available again as soon as a real asset is selected.
        local layerEnabled = (tonumber(draft[row.asset.field]) or 0) > 0
        local function SetLayerControlVisible(control, visible)
            if not control then return end
            if visible then control:Show() else control:Hide() end
        end

        SetLayerControlVisible(row.color, layerEnabled)
        SetLayerControlVisible(row.scale, layerEnabled)
        SetLayerControlVisible(row.rotation, layerEnabled)
        SetLayerControlVisible(row.rotationEmpty, layerEnabled)

        if layerEnabled then
            self:RefreshBannerSettingsSelector(row.color, draft, previewEditable)
            self:RefreshBannerSettingsSelector(row.scale, draft, previewEditable)
            self:RefreshBannerSettingsSelector(row.rotation, draft, previewEditable)
        end
    end
    self:RefreshBannerSettingsSelector(frame.textColor, draft, previewEditable)
    self:RefreshBannerSettingsSelector(frame.textSize, draft, previewEditable)
    self:RefreshBannerSettingsSelector(frame.textX, draft, previewEditable)
    self:RefreshBannerSettingsSelector(frame.textY, draft, previewEditable)
    self:RefreshBannerSettingsSelector(frame.textFont, draft, previewEditable)
    self:RefreshBannerSettingsSelector(frame.textRotation, draft, previewEditable)

    if not keepEditText then
        self.bannerSettingsRefreshingText = true
        frame.textEdit:SetText(draft.text or "")
        self.bannerSettingsRefreshingText = nil
    end
    frame.textEdit:Enable()
    frame.textEdit:SetAlpha(1)
    SetButtonEnabled(frame.reset, true)
    frame.apply:Show()
    SetButtonEnabled(frame.apply, canApply)
    self:ApplyBannerToVisual(frame.preview, draft)

    local record = self:GetGuildBannerRecord()
    local guildMaster = self:GetGuildMasterName()
    frame.permissionText:SetText("")
    frame.askGM:SetText("")
    frame.gmWhisper.playerName = nil
    frame.gmWhisper.label:SetText("")
    frame.gmWhisper:Hide()

    if not self:IsInGuild() then
        frame.status:SetText(self:L("BANNER_NOT_PUBLISHED"))
        frame.permissionText:SetText(self:L("BANNER_GM_REQUIRED"))
        frame.syncInfo:SetText("")
    elseif not canApply then
        frame.status:SetText(self:L("BANNER_READ_ONLY"))
        frame.permissionText:SetText(self:L("BANNER_GM_REQUIRED"))
        frame.askGM:SetText(self:L("BANNER_ASK_GM") .. " ")
        frame.gmWhisper.playerName = guildMaster
        local displayName = guildMaster or self:L("BANNER_GM_UNKNOWN")
        frame.gmWhisper.label:SetText("[@" .. displayName .. "]")
        frame.gmWhisper:Show()
        if record then
            frame.syncInfo:SetText(self:L("BANNER_UPDATED", date("%d/%m/%Y %H:%M", record.updatedAt), record.author or "?"))
        else
            frame.syncInfo:SetText(self:L("BANNER_NOT_PUBLISHED"))
        end
    elseif record then
        frame.status:SetText("")
        frame.syncInfo:SetText(self:L("BANNER_UPDATED", date("%d/%m/%Y %H:%M", record.updatedAt), record.author or "?"))
    else
        frame.status:SetText(self:L("BANNER_NOT_PUBLISHED"))
        frame.syncInfo:SetText("")
    end
end

function GMG:OpenBannerSettings()
    if not self.mainFrame then return end
    if self.ShowTab then self:ShowTab("settings", true) end
    self:CreateBannerSettingsPopup()
    self:RefreshBannerSettingsPopup()
    self.bannerSettingsPopup:Show()
end

function GMG:InstallBannerSettingsAccess()
    local page = self.settingsPage
    if not page or page.bannerCreator then return end
    page.bannerCreator = CreateButton(page.right, self:L("BANNER_SETTINGS_BUTTON"), 310, 34)
    page.bannerCreator:SetPoint("BOTTOM", 0, 58)
    page.bannerCreator:SetScript("OnClick", function() GMG:OpenBannerSettings() end)
end

local GMGCreateUIBeforeBannerSettings = GMG.CreateUI
function GMG:CreateUI(...)
    if self.db and self.db.profile and self.db.profile.lastTab == "banner" then self.db.profile.lastTab = "settings" end
    GMGCreateUIBeforeBannerSettings(self, ...)
    if self.mainFrame and self.mainFrame.tabs and self.mainFrame.tabs.banner then
        self.mainFrame.tabs.banner:Hide()
        self.mainFrame.tabs.banner = nil
    end
    if self.bannerPage then self.bannerPage:Hide(); self.bannerPage = nil end
    self:InstallBannerSettingsAccess()
    self:CreateBannerSettingsPopup()
    self:RefreshBannerSettingsPopup()
end

local GMGShowTabBeforeBannerSettings = GMG.ShowTab
function GMG:ShowTab(key, internal)
    if key == "banner" then
        GMGShowTabBeforeBannerSettings(self, "settings")
        if not internal then
            self:CreateBannerSettingsPopup()
            self:RefreshBannerSettingsPopup()
            self.bannerSettingsPopup:Show()
        end
        return
    end
    GMGShowTabBeforeBannerSettings(self, key)
end

local GMGRefreshSettingsBeforeBannerSettings = GMG.RefreshSettings
function GMG:RefreshSettings()
    GMGRefreshSettingsBeforeBannerSettings(self)
    self:InstallBannerSettingsAccess()
    if self.settingsPage and self.settingsPage.bannerCreator then
        self.settingsPage.bannerCreator.label:SetText(self:L("BANNER_SETTINGS_BUTTON"))
    end
    if self.bannerSettingsPopup and self.bannerSettingsPopup:IsShown() then self:RefreshBannerSettingsPopup() end
end

local GMGRefreshLocalizationBeforeBannerSettings = GMG.RefreshLocalization
function GMG:RefreshLocalization()
    GMGRefreshLocalizationBeforeBannerSettings(self)
    if self.settingsPage and self.settingsPage.bannerCreator then self.settingsPage.bannerCreator.label:SetText(self:L("BANNER_SETTINGS_BUTTON")) end
    local frame = self.bannerSettingsPopup
    if frame then
        frame.title:SetText(self:L("BANNER_SETTINGS_TITLE"))
        frame.help:SetText("")
        frame.previewTitle:SetText(self:L("BANNER_PREVIEW"))
        for _, row in ipairs(frame.rows or {}) do row.label:SetText(self:L(row.labelKey)) end
        frame.textRow.label:SetText(self:L("BANNER_INITIALS"))
        frame.positionLabel:SetText(self:L("BANNER_POSITION"))
        frame.fontLabel:SetText(self:L("BANNER_FONT"))
        frame.rotationLabel:SetText(self:L("BANNER_TEXT_ROTATION"))
        frame.reset.label:SetText(self:L("BANNER_RESET"))
        frame.apply.label:SetText(self:L("BANNER_APPLY"))
        frame.closeBottom.label:SetText(self:L("BANNER_CLOSE"))
        self:RefreshBannerSettingsPopup()
    end
end

local GMGStoreGuildBannerBeforeBannerSettings = GMG.StoreGuildBanner
function GMG:StoreGuildBanner(record, source)
    local preserveDraft = self.bannerSettingsPopup and self.bannerSettingsPopup.dirty and CopyTable(self:GetBannerDraft())
    local result = GMGStoreGuildBannerBeforeBannerSettings(self, record, source)
    if result then
        if preserveDraft then self:SetBannerDraft(preserveDraft)
        elseif record and record.config then self:SetBannerDraft(record.config) end
    end
    if result and self.bannerSettingsPopup and self.bannerSettingsPopup:IsShown() then self:RefreshBannerSettingsPopup() end
    return result
end

local GMGPlayerGuildUpdateBeforeBannerSettings = GMG.PLAYER_GUILD_UPDATE
function GMG:PLAYER_GUILD_UPDATE(...)
    GMGPlayerGuildUpdateBeforeBannerSettings(self, ...)
    if self.bannerSettingsPopup then self.bannerSettingsPopup.dirty = nil; self:RefreshBannerSettingsPopup() end
end


-- v1.5.2: everyone may open and visually edit the draft; Apply remains GM-only.
local GMGRefreshGuildPageBeforeBannerSettingsV152 = GMG.RefreshGuildPage
function GMG:RefreshGuildPage()
    GMGRefreshGuildPageBeforeBannerSettingsV152(self)
    if self.guildPage and self.guildPage.changeImage and self.guildPage.changeImage.label then
        self.guildPage.changeImage.label:SetText(self:L("BANNER_OPEN_EDITOR"))
        self.guildPage.changeImage:SetScript("OnClick", function() GMG:OpenBannerSettings() end)
    end
end
