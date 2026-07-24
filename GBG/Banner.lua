-- G.B.G (Glayna Better Guild)
-- v1.5.6 - expanded emblem and border asset catalog

local GMG = GlaynaBetterGuild
if not GMG then return end

local floor = math.floor
local max = math.max
local min = math.min
local abs = math.abs
local pi = math.pi
local tostring = tostring
local tonumber = tonumber
local strlower = string.lower
local tinsert = table.insert
local sort = table.sort
local unpack = unpack

GMG.BANNER_CONFIG_VERSION = 4
GMG.BANNER_ASSET_COUNTS = { background = 10, border = 20, shield = 30, weapon = 10 }
GMG.BANNER_ASSET_COUNT = 30 -- legacy maximum; use GetBannerAssetCount for each layer
GMG.BANNER_PATH = "Interface\\AddOns\\GBG\\Media\\Banner\\"

function GMG:GetBannerAssetCount(kind)
    local counts = self.BANNER_ASSET_COUNTS or {}
    return tonumber(counts[kind]) or 10
end

GMG.BANNER_PALETTE = {
    { key = "WHITE",   r = 1.00, g = 1.00, b = 1.00 },
    { key = "BLACK",   r = 0.08, g = 0.08, b = 0.11 },
    { key = "RED",     r = 0.86, g = 0.10, b = 0.12 },
    { key = "BLUE",    r = 0.10, g = 0.34, b = 0.92 },
    { key = "GREEN",   r = 0.10, g = 0.72, b = 0.30 },
    { key = "PURPLE",  r = 0.54, g = 0.18, b = 0.92 },
    { key = "GOLD",    r = 0.95, g = 0.67, b = 0.10 },
    { key = "SILVER",  r = 0.72, g = 0.76, b = 0.84 },
    { key = "ORANGE",  r = 1.00, g = 0.34, b = 0.06 },
    { key = "PINK",    r = 0.96, g = 0.28, b = 0.62 },
    { key = "CYAN",    r = 0.10, g = 0.86, b = 0.96 },
    { key = "TEAL",    r = 0.06, g = 0.58, b = 0.56 },
    { key = "BURGUNDY",r = 0.45, g = 0.05, b = 0.12 },
    { key = "NAVY",    r = 0.04, g = 0.10, b = 0.34 },
    { key = "LIME",    r = 0.55, g = 0.92, b = 0.08 },
    { key = "BROWN",   r = 0.36, g = 0.20, b = 0.08 },
}

GMG.DEFAULT_BANNER_CONFIG = {
    version = GMG.BANNER_CONFIG_VERSION,
    background = 0,
    backgroundColor = 6,
    border = 0,
    borderColor = 8,
    shield = 0,
    shieldColor = 2,
    weapon = 0,
    weaponColor = 7,
    text = "",
    textColor = 1,
    textSize = 22,
    textX = 0,
    textY = -32,
    shieldScale = 72,
    shieldX = 0,
    shieldY = 2,
    weaponScale = 58,
    weaponX = 0,
    weaponY = 4,
    weaponRotation = 0,
}

-- ---------------------------------------------------------------------------
-- Localization
-- ---------------------------------------------------------------------------
local EN = {
    BANNER = "Banner",
    BANNER_EDITOR = "Guild banner / tabard creator",
    BANNER_HELP = "Layers are rebuilt locally. Only this lightweight configuration is shared with members of the same guild and realm.",
    BANNER_BACKGROUND = "Background",
    BANNER_BACKGROUND_COLOR = "Background color",
    BANNER_BORDER = "Border",
    BANNER_BORDER_COLOR = "Border color",
    BANNER_SHIELD = "Emblem / Shield",
    BANNER_SHIELD_COLOR = "Emblem color",
    BANNER_WEAPON = "Weapon",
    BANNER_WEAPON_COLOR = "Weapon color",
    BANNER_NONE = "None",
    BANNER_ASSET = "Asset %d",
    BANNER_INITIALS = "Lettering",
    BANNER_TEXT_COLOR = "Text color",
    BANNER_TEXT_SIZE = "Size",
    BANNER_TEXT_X = "Text X",
    BANNER_TEXT_Y = "Text Y",
    BANNER_SHIELD_SCALE = "Emblem size",
    BANNER_WEAPON_SCALE = "Weapon size",
    BANNER_WEAPON_ROTATION = "Weapon rotation",
    BANNER_PREVIEW = "Live preview",
    BANNER_RESET = "Reset",
    BANNER_TEST = "Test locally",
    BANNER_STOP_TEST = "Stop local test",
    BANNER_PUBLISH = "Publish for guild",
    BANNER_PUBLISHED = "Guild banner published.",
    BANNER_TEST_ACTIVE = "Local test active. Nothing has been sent to the guild.",
    BANNER_TEST_STOPPED = "Local test stopped.",
    BANNER_GM_ONLY = "Only the guild master can edit and publish the official guild banner.",
    BANNER_GUILDLESS = "No guild: creator available in local test mode only.",
    BANNER_READ_ONLY = "Official guild banner — read only.",
    BANNER_NOT_PUBLISHED = "No official banner has been published for this guild yet.",
    BANNER_UPDATED = "Last official update: %s by %s",
    BANNER_OPEN_EDITOR = "Open banner creator",
    BANNER_VIEW = "View guild banner",
    BANNER_SYNCED = "A newer guild banner has been received from %s.",
    BANNER_COLOR_WHITE = "White", BANNER_COLOR_BLACK = "Black", BANNER_COLOR_RED = "Red",
    BANNER_COLOR_BLUE = "Blue", BANNER_COLOR_GREEN = "Green", BANNER_COLOR_PURPLE = "Purple",
    BANNER_COLOR_GOLD = "Gold", BANNER_COLOR_SILVER = "Silver", BANNER_COLOR_ORANGE = "Orange",
    BANNER_COLOR_PINK = "Pink", BANNER_COLOR_CYAN = "Cyan", BANNER_COLOR_TEAL = "Teal",
    BANNER_COLOR_BURGUNDY = "Burgundy", BANNER_COLOR_NAVY = "Navy", BANNER_COLOR_LIME = "Lime",
    BANNER_COLOR_BROWN = "Brown",
    RANK_SCROLL_HINT = "Mouse wheel or arrows to browse every member of this rank.",
}

local FR = {
    BANNER = "Bannière",
    BANNER_EDITOR = "Créateur de bannière / tabard de guilde",
    BANNER_HELP = "Les calques sont reconstruits localement. Seule cette configuration légère est partagée avec les membres de la même guilde et du même serveur.",
    BANNER_BACKGROUND = "Fond",
    BANNER_BACKGROUND_COLOR = "Couleur fond",
    BANNER_BORDER = "Bordure",
    BANNER_BORDER_COLOR = "Couleur bordure",
    BANNER_SHIELD = "Emblème / Bouclier",
    BANNER_SHIELD_COLOR = "Couleur emblème",
    BANNER_WEAPON = "Arme",
    BANNER_WEAPON_COLOR = "Couleur arme",
    BANNER_NONE = "Aucun",
    BANNER_ASSET = "Asset %d",
    BANNER_INITIALS = "Lettrages",
    BANNER_TEXT_COLOR = "Couleur texte",
    BANNER_TEXT_SIZE = "Taille",
    BANNER_TEXT_X = "Texte X",
    BANNER_TEXT_Y = "Texte Y",
    BANNER_SHIELD_SCALE = "Taille emblème",
    BANNER_WEAPON_SCALE = "Taille arme",
    BANNER_WEAPON_ROTATION = "Rotation arme",
    BANNER_PREVIEW = "Aperçu en direct",
    BANNER_RESET = "Réinitialiser",
    BANNER_TEST = "Tester localement",
    BANNER_STOP_TEST = "Arrêter le test",
    BANNER_PUBLISH = "Publier pour la guilde",
    BANNER_PUBLISHED = "La bannière de guilde a été publiée.",
    BANNER_TEST_ACTIVE = "Test local actif. Rien n'a été envoyé à la guilde.",
    BANNER_TEST_STOPPED = "Le test local est arrêté.",
    BANNER_GM_ONLY = "Seul le chef de guilde peut modifier et publier la bannière officielle.",
    BANNER_GUILDLESS = "Sans guilde : créateur disponible uniquement en mode test local.",
    BANNER_READ_ONLY = "Bannière officielle de guilde — lecture seule.",
    BANNER_NOT_PUBLISHED = "Aucune bannière officielle n'a encore été publiée pour cette guilde.",
    BANNER_UPDATED = "Dernière mise à jour officielle : %s par %s",
    BANNER_OPEN_EDITOR = "Ouvrir le créateur",
    BANNER_VIEW = "Voir la bannière de guilde",
    BANNER_SYNCED = "Une bannière de guilde plus récente a été reçue de %s.",
    BANNER_COLOR_WHITE = "Blanc", BANNER_COLOR_BLACK = "Noir", BANNER_COLOR_RED = "Rouge",
    BANNER_COLOR_BLUE = "Bleu", BANNER_COLOR_GREEN = "Vert", BANNER_COLOR_PURPLE = "Violet",
    BANNER_COLOR_GOLD = "Or", BANNER_COLOR_SILVER = "Argent", BANNER_COLOR_ORANGE = "Orange",
    BANNER_COLOR_PINK = "Rose", BANNER_COLOR_CYAN = "Cyan", BANNER_COLOR_TEAL = "Sarcelle",
    BANNER_COLOR_BURGUNDY = "Bordeaux", BANNER_COLOR_NAVY = "Marine", BANNER_COLOR_LIME = "Citron vert",
    BANNER_COLOR_BROWN = "Brun",
    RANK_SCROLL_HINT = "Molette ou flèches pour parcourir tous les membres de ce grade.",
}

GMG.Locales = GMG.Locales or { en = {}, fr = {} }
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end

-- ---------------------------------------------------------------------------
-- Configuration and persistence
-- ---------------------------------------------------------------------------
local function CopyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

local function ClampNumber(value, low, high, fallback)
    value = tonumber(value)
    if not value then value = fallback end
    return max(low, min(high, floor(value + 0.5)))
end

function GMG:SanitizeBannerText(value)
    value = tostring(value or "")
    value = string.upper(value)
    value = string.gsub(value, "[^%w%. ]", "")
    return string.sub(value, 1, 30)
end

function GMG:NormalizeBannerConfig(config)
    config = CopyTable(config or self.DEFAULT_BANNER_CONFIG)
    config.version = self.BANNER_CONFIG_VERSION
    config.background = ClampNumber(config.background, 0, self:GetBannerAssetCount("background"), 0)
    config.backgroundColor = ClampNumber(config.backgroundColor, 1, #self.BANNER_PALETTE, 6)
    config.border = ClampNumber(config.border, 0, self:GetBannerAssetCount("border"), 0)
    config.borderColor = ClampNumber(config.borderColor, 1, #self.BANNER_PALETTE, 8)
    config.shield = ClampNumber(config.shield, 0, self:GetBannerAssetCount("shield"), 0)
    config.shieldColor = ClampNumber(config.shieldColor, 1, #self.BANNER_PALETTE, 2)
    config.weapon = ClampNumber(config.weapon, 0, self:GetBannerAssetCount("weapon"), 0)
    config.weaponColor = ClampNumber(config.weaponColor, 1, #self.BANNER_PALETTE, 7)
    config.text = self:SanitizeBannerText(config.text or "")
    config.textColor = ClampNumber(config.textColor, 1, #self.BANNER_PALETTE, 1)
    config.textSize = ClampNumber(config.textSize, 10, 300, 40)
    config.textX = ClampNumber(config.textX, -70, 70, 0)
    config.textY = ClampNumber(config.textY, -70, 70, -32)
    config.shieldScale = ClampNumber(config.shieldScale, 35, 120, 72)
    config.shieldX = ClampNumber(config.shieldX, -60, 60, 0)
    config.shieldY = ClampNumber(config.shieldY, -60, 60, 2)
    config.weaponScale = ClampNumber(config.weaponScale, 35, 120, 58)
    config.weaponX = ClampNumber(config.weaponX, -60, 60, 0)
    config.weaponY = ClampNumber(config.weaponY, -60, 60, 4)
    config.weaponRotation = ClampNumber(config.weaponRotation, 0, 7, 0)
    return config
end

function GMG:GetBannerDraft()
    if not self.db or not self.db.profile then return self:NormalizeBannerConfig(self.DEFAULT_BANNER_CONFIG) end
    if type(self.db.profile.bannerDraft) ~= "table" then
        local record = self:GetGuildBannerRecord()
        self.db.profile.bannerDraft = self:NormalizeBannerConfig(record and record.config or self.DEFAULT_BANNER_CONFIG)
    else
        self.db.profile.bannerDraft = self:NormalizeBannerConfig(self.db.profile.bannerDraft)
    end
    return self.db.profile.bannerDraft
end

function GMG:SetBannerDraft(config)
    if not self.db or not self.db.profile then return end
    self.db.profile.bannerDraft = self:NormalizeBannerConfig(config)
    if self.PersistSettings then self:PersistSettings() end
end

function GMG:GetGuildBannerRecord()
    local store = self:GetGuildStore(false)
    if not store or type(store.guildBanner) ~= "table" then return nil end
    if type(store.guildBanner.config) ~= "table" then return nil end
    store.guildBanner.config = self:NormalizeBannerConfig(store.guildBanner.config)
    return store.guildBanner
end

function GMG:IsBannerRecordNewer(incoming, current)
    if not current then return true end
    local incomingTime = tonumber(incoming.updatedAt) or 0
    local currentTime = tonumber(current.updatedAt) or 0
    if incomingTime ~= currentTime then return incomingTime > currentTime end
    local incomingRevision = tonumber(incoming.revision) or 0
    local currentRevision = tonumber(current.revision) or 0
    if incomingRevision ~= currentRevision then return incomingRevision > currentRevision end
    -- Same publication date and same revision means the record is identical in
    -- authority. Never replace it with a divergent stale relay/hash tie-breaker.
    return false
end

function GMG:StoreGuildBanner(record, source)
    if not self:IsInGuild() or type(record) ~= "table" then return false end
    record.config = self:NormalizeBannerConfig(record.config)
    record.updatedAt = tonumber(record.updatedAt) or 0
    record.revision = tonumber(record.revision) or 0
    record.author = self:NormalizeName(record.author or "")
    if record.updatedAt <= 0 or record.revision <= 0 then return false end
    local store = self:GetGuildStore(true)
    local current = store.guildBanner
    if not self:IsBannerRecordNewer(record, current) then return false end
    store.guildBanner = {
        config = CopyTable(record.config),
        updatedAt = record.updatedAt,
        revision = record.revision,
        author = record.author,
        receivedFrom = self:NormalizeName(source or record.author or ""),
    }
    self.bannerOfficialChanged = true
    if self.db and self.db.profile and (not self.bannerPage or not self.bannerPage.dirty) then
        self.db.profile.bannerDraft = CopyTable(store.guildBanner.config)
    end
    return true
end

function GMG:CanEditGuildBanner()
    if not self:IsInGuild() then return true end
    return self:CanEditGuildImage()
end

function GMG:CanPublishGuildBanner()
    return self:IsInGuild() and self:CanEditGuildImage()
end

function GMG:GetDisplayedBannerConfig()
    -- Only an officially applied guild record is displayed outside the editor.
    local record = self:GetGuildBannerRecord()
    return record and record.config or nil
end

-- ---------------------------------------------------------------------------
-- Serialization and guild relay
-- ---------------------------------------------------------------------------
function GMG:EncodeBannerConfig(config)
    config = self:NormalizeBannerConfig(config)
    return table.concat({
        tostring(config.version), tostring(config.background), tostring(config.backgroundColor),
        tostring(config.border), tostring(config.borderColor), tostring(config.shield),
        tostring(config.shieldColor), tostring(config.weapon), tostring(config.weaponColor),
        config.text, tostring(config.textColor), tostring(config.textSize),
        tostring(config.textX), tostring(config.textY), tostring(config.shieldScale),
        tostring(config.shieldX), tostring(config.shieldY), tostring(config.weaponScale),
        tostring(config.weaponX), tostring(config.weaponY), tostring(config.weaponRotation),
    }, ",")
end

local function SplitSimple(value, separator)
    local result = {}
    local start = 1
    separator = separator or "|"
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
    if #fields < 21 then return nil end
    return self:NormalizeBannerConfig({
        version = fields[1], background = fields[2], backgroundColor = fields[3],
        border = fields[4], borderColor = fields[5], shield = fields[6],
        shieldColor = fields[7], weapon = fields[8], weaponColor = fields[9],
        text = fields[10], textColor = fields[11], textSize = fields[12],
        textX = fields[13], textY = fields[14], shieldScale = fields[15],
        shieldX = fields[16], shieldY = fields[17], weaponScale = fields[18],
        weaponX = fields[19], weaponY = fields[20], weaponRotation = fields[21],
    })
end

function GMG:BuildGuildBannerPayload()
    local record = self:GetGuildBannerRecord()
    if not record then return nil end
    return table.concat({
        "B",
        self:GetGuildHash() or "",
        tostring(record.updatedAt or 0),
        tostring(record.revision or 0),
        self:NormalizeName(record.author or ""),
        self:EncodeBannerConfig(record.config),
    }, "|")
end

function GMG:QueueGuildBannerBroadcast(priority, channel, target)
    local payload = self:BuildGuildBannerPayload()
    if payload and self.QueuePacket then
        self:QueuePacket(payload, channel or "GUILD", target, priority)
    end
end

function GMG:PublishGuildBanner(config)
    if not self:CanPublishGuildBanner() then
        self:Print(self:L("BANNER_GM_ONLY"))
        return false
    end
    local current = self:GetGuildBannerRecord()
    local now = time()
    if current and now <= (tonumber(current.updatedAt) or 0) then now = (tonumber(current.updatedAt) or 0) + 1 end
    local record = {
        config = self:NormalizeBannerConfig(config),
        updatedAt = now,
        revision = (current and tonumber(current.revision) or 0) + 1,
        author = self:GetPlayerName(),
    }
    local store = self:GetGuildStore(true)
    store.guildBanner = record
    self.bannerTestActive = nil
    self.bannerTestConfig = nil
    if self.SetBannerDraft then self:SetBannerDraft(record.config)
    elseif self.db and self.db.profile then self.db.profile.bannerDraft = CopyTable(record.config) end
    if self.QueueGuildBannerBroadcast then self:QueueGuildBannerBroadcast(true) end
    if self.SendQueuedPackets then self:SendQueuedPackets(20) end
    self:Print(self:L("BANNER_PUBLISHED"))
    if self.RefreshAll then self:RefreshAll(true) end
    return true
end

local GMGSyncTickBeforeBannerV150 = GMG.SyncTick
function GMG:SyncTick(initial)
    if self:IsInGuild() and self:GetGuildBannerRecord() then
        self:QueueGuildBannerBroadcast(false)
    end
    return GMGSyncTickBeforeBannerV150(self, initial)
end

local GMGHandlePayloadBeforeBannerV150 = GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload, channel, sender)
    local command = string.match(tostring(payload or ""), "^([^|]+)")
    if command ~= "B" then return GMGHandlePayloadBeforeBannerV150(self, payload, channel, sender) end

    local values = SplitSimple(payload, "|")
    if values[2] ~= self:GetGuildHash() then return end
    sender = self:NormalizeName(sender)
    if sender == "" or strlower(sender) == strlower(self:GetPlayerName()) then return end
    if not self:IsGuildMemberName(sender) then return end
    local config = self:DecodeBannerConfig(values[6])
    if not config then return end
    local record = {
        updatedAt = tonumber(values[3]) or 0,
        revision = tonumber(values[4]) or 0,
        author = self:NormalizeName(values[5]),
        config = config,
    }
    if self:StoreGuildBanner(record, sender) then
        -- Every holder becomes a relay. This keeps the newest GM publication
        -- available even while the guild master is offline.
        if self.QueueGuildBannerBroadcast then self:QueueGuildBannerBroadcast(true) end
        if self.RefreshAll then self:RefreshAll(true) end
        if self.mainFrame and self.mainFrame:IsShown() then self:Print(self:L("BANNER_SYNCED", sender)) end
    end
end

-- ---------------------------------------------------------------------------
-- Layered banner renderer
-- ---------------------------------------------------------------------------
function GMG:GetBannerAssetPath(kind, index)
    index = tonumber(index) or 0
    local assetCount = self:GetBannerAssetCount(kind)
    if index < 1 or index > assetCount then return nil end
    local folder, prefix
    if kind == "background" then folder, prefix = "Backgrounds", "background_"
    elseif kind == "border" then folder, prefix = "Borders", "border_"
    elseif kind == "shield" then folder, prefix = "Shields", "shield_"
    elseif kind == "weapon" then folder, prefix = "Weapons", "weapon_"
    else return nil end
    return self.BANNER_PATH .. folder .. "\\" .. prefix .. string.format("%02d", index)
end

function GMG:GetBannerColor(index)
    return self.BANNER_PALETTE[ClampNumber(index, 1, #self.BANNER_PALETTE, 1)] or self.BANNER_PALETTE[1]
end

local function ApplyTextureLayer(texture, path, color)
    if not path then
        texture:SetTexture(nil)
        texture:Hide()
        return
    end
    texture:SetTexture(path)
    texture:SetVertexColor(color.r, color.g, color.b, 1)
    texture:Show()
end

function GMG:CreateBannerVisual(parent, size)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(size)
    frame:SetHeight(size)
    frame.bannerSize = size
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.shield = frame:CreateTexture(nil, "ARTWORK")
    frame.weapon = frame:CreateTexture(nil, "OVERLAY")
    frame.border = frame:CreateTexture(nil, "OVERLAY")
    frame.border:SetAllPoints()
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetJustifyH("CENTER")
    frame.text:SetJustifyV("MIDDLE")
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
    local backgroundColor = self:GetBannerColor(config.backgroundColor)
    local borderColor = self:GetBannerColor(config.borderColor)
    local shieldColor = self:GetBannerColor(config.shieldColor)
    local weaponColor = self:GetBannerColor(config.weaponColor)
    local textColor = self:GetBannerColor(config.textColor)

    ApplyTextureLayer(visual.background, self:GetBannerAssetPath("background", config.background), backgroundColor)
    ApplyTextureLayer(visual.border, self:GetBannerAssetPath("border", config.border), borderColor)
    ApplyTextureLayer(visual.shield, self:GetBannerAssetPath("shield", config.shield), shieldColor)
    ApplyTextureLayer(visual.weapon, self:GetBannerAssetPath("weapon", config.weapon), weaponColor)

    local shieldSize = max(8, floor(size * config.shieldScale / 100))
    visual.shield:ClearAllPoints()
    visual.shield:SetWidth(shieldSize)
    visual.shield:SetHeight(shieldSize)
    visual.shield:SetPoint("CENTER", visual, "CENTER", floor(config.shieldX * size / 256), floor(config.shieldY * size / 256))

    local weaponSize = max(8, floor(size * config.weaponScale / 100))
    visual.weapon:ClearAllPoints()
    visual.weapon:SetWidth(weaponSize)
    visual.weapon:SetHeight(weaponSize)
    visual.weapon:SetPoint("CENTER", visual, "CENTER", floor(config.weaponX * size / 256), floor(config.weaponY * size / 256))
    if visual.weapon.SetRotation then
        pcall(visual.weapon.SetRotation, visual.weapon, (config.weaponRotation or 0) * pi / 4)
    end

    visual.text:ClearAllPoints()
    visual.text:SetPoint("CENTER", visual, "CENTER", floor(config.textX * size / 256), floor(config.textY * size / 256))
    local fontSize = max(6, floor(config.textSize * size / 256 + 0.5))
    pcall(visual.text.SetFont, visual.text, "Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    visual.text:SetTextColor(textColor.r, textColor.g, textColor.b, 1)
    visual.text:SetText(config.text or "")
    visual:Show()
end

function GMG:EnsureHeaderBannerVisual()
    if not self.mainFrame or self.mainFrame.bannerVisual then return end
    local visual = self:CreateBannerVisual(self.mainFrame.header, 54)
    visual:SetPoint("LEFT", 14, 0)
    self.mainFrame.bannerVisual = visual
end

function GMG:EnsureGuildPageBannerVisual()
    if not self.guildPage or self.guildPage.bannerVisual then return end
    local visual = self:CreateBannerVisual(self.guildPage.imagePanel, 142)
    visual:SetPoint("TOP", 0, -48)
    self.guildPage.bannerVisual = visual
end

function GMG:RefreshDisplayedBannerVisuals()
    local config = self:GetDisplayedBannerConfig()
    if self.mainFrame then
        self:EnsureHeaderBannerVisual()
        local visual = self.mainFrame.bannerVisual
        self.mainFrame.brand:ClearAllPoints()
        self.mainFrame.guildName:ClearAllPoints()
        if self:IsInGuild() and config then
            self.mainFrame.guildImage:SetTexture(nil)
            self.mainFrame.guildImage:Hide()
            self:ApplyBannerToVisual(visual, config)
            self.mainFrame.brand:SetPoint("TOPLEFT", visual, "TOPRIGHT", 8, -1)
            self.mainFrame.guildName:SetPoint("TOPLEFT", visual, "TOPRIGHT", 8, -19)
        else
            -- No official banner yet: show no faction logo, no legacy guild
            -- image and no placeholder. Keep the titles aligned to the left.
            self:ApplyBannerToVisual(visual, nil)
            self.mainFrame.guildImage:SetTexture(nil)
            self.mainFrame.guildImage:Hide()
            self.mainFrame.brand:SetPoint("TOPLEFT", self.mainFrame.header, "TOPLEFT", 14, -13)
            self.mainFrame.guildName:SetPoint("TOPLEFT", self.mainFrame.header, "TOPLEFT", 14, -31)
        end
    end
    if self.guildPage then
        self:EnsureGuildPageBannerVisual()
        if self:IsInGuild() and config then
            self.guildPage.image:SetTexture(nil)
            self.guildPage.image:Hide()
            self:ApplyBannerToVisual(self.guildPage.bannerVisual, config)
        else
            self:ApplyBannerToVisual(self.guildPage.bannerVisual, nil)
            if self.guildPage.image then
                self.guildPage.image:SetTexture(nil)
                self.guildPage.image:Hide()
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Banner editor UI
-- ---------------------------------------------------------------------------
local UI_BG = { 0.026, 0.032, 0.052, 0.98 }
local UI_PANEL = { 0.045, 0.052, 0.082, 0.98 }
local UI_PANEL_2 = { 0.065, 0.070, 0.105, 0.98 }
local UI_BORDER = { 0.17, 0.17, 0.27, 1 }
local UI_ACCENT = { 0.58, 0.34, 0.92, 1 }
local UI_MUTED = { 0.52, 0.54, 0.64, 1 }

local function SetBackdrop(frame, background, border)
    if not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(background or UI_PANEL))
    frame:SetBackdropBorderColor(unpack(border or UI_BORDER))
end

local function CreateLabel(parent, text, template)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
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
    button:SetScript("OnLeave", function(self)
        if not self.selected then self:SetBackdropBorderColor(unpack(UI_BORDER)) end
    end)
    return button
end

local function SetButtonEnabled(button, enabled)
    if not button then return end
    if enabled then
        button:Enable()
        button:SetAlpha(1)
    else
        button:Disable()
        button:SetAlpha(0.42)
    end
end

function GMG:BannerEditAllowedOrWarn()
    if self:CanEditGuildBanner() then return true end
    self:Print(self:L("BANNER_GM_ONLY"))
    return false
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
    if self.bannerPage then self.bannerPage.dirty = true end
    self:RefreshBannerPage()
end

function GMG:CreateBannerSelector(parent, x, y, width, field, low, high, step, isColor)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetPoint("TOPLEFT", x, y)
    holder:SetWidth(width)
    holder:SetHeight(28)
    holder.field = field
    holder.low = low
    holder.high = high
    holder.step = step or 1
    holder.isColor = isColor
    holder.left = CreateButton(holder, "<", 28, 26)
    holder.left:SetPoint("LEFT", 0, 0)
    holder.right = CreateButton(holder, ">", 28, 26)
    holder.right:SetPoint("RIGHT", 0, 0)
    holder.value = CreateLabel(holder, "", "GameFontNormalSmall")
    holder.value:SetPoint("LEFT", holder.left, "RIGHT", 4, 0)
    holder.value:SetPoint("RIGHT", holder.right, "LEFT", -4, 0)
    holder.value:SetJustifyH("CENTER")
    holder.swatch = holder:CreateTexture(nil, "ARTWORK")
    holder.swatch:SetWidth(10)
    holder.swatch:SetHeight(10)
    holder.swatch:SetPoint("LEFT", holder.left, "RIGHT", 8, 0)
    if not isColor then holder.swatch:Hide() end
    holder.left:SetScript("OnClick", function()
        GMG:AdjustBannerDraft(field, -holder.step, low, high, true)
    end)
    holder.right:SetScript("OnClick", function()
        GMG:AdjustBannerDraft(field, holder.step, low, high, true)
    end)
    return holder
end

function GMG:CreateBannerMiniSelector(parent, x, y, labelKey, field, low, high, step, width)
    local label = CreateLabel(parent, self:L(labelKey), "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", x, y)
    label:SetTextColor(unpack(UI_MUTED))
    local selector = self:CreateBannerSelector(parent, x, y - 18, width or 118, field, low, high, step, false)
    selector.labelKey = labelKey
    selector.headerLabel = label
    return selector
end

function GMG:CreateBannerPage()
    if not self.mainFrame or self.bannerPage then return end
    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()
    page.title = CreateLabel(page, self:L("BANNER_EDITOR"), "GameFontNormalLarge")
    page.title:SetPoint("TOPLEFT", 22, -18)
    page.help = CreateLabel(page, self:L("BANNER_HELP"), "GameFontNormalSmall")
    page.help:SetPoint("TOPLEFT", 22, -48)
    page.help:SetPoint("TOPRIGHT", -22, -48)
    page.help:SetJustifyH("LEFT")
    page.help:SetTextColor(unpack(UI_MUTED))

    page.editor = CreateFrame("Frame", nil, page)
    page.editor:SetPoint("TOPLEFT", 22, -78)
    page.editor:SetPoint("BOTTOMLEFT", 22, 22)
    page.editor:SetWidth(500)
    SetBackdrop(page.editor, UI_PANEL, UI_BORDER)

    page.previewPanel = CreateFrame("Frame", nil, page)
    page.previewPanel:SetPoint("TOPLEFT", page.editor, "TOPRIGHT", 16, 0)
    page.previewPanel:SetPoint("BOTTOMRIGHT", -22, 22)
    SetBackdrop(page.previewPanel, UI_PANEL, UI_BORDER)
    page.previewTitle = CreateLabel(page.previewPanel, self:L("BANNER_PREVIEW"), "GameFontNormal")
    page.previewTitle:SetPoint("TOP", 0, -16)
    page.preview = self:CreateBannerVisual(page.previewPanel, 256)
    page.preview:SetPoint("TOP", 0, -48)
    SetBackdrop(page.preview, {0.025, 0.022, 0.045, 1}, UI_BORDER)

    local rowKeys = {
        { "BANNER_BACKGROUND", "background", "BANNER_BACKGROUND_COLOR", "backgroundColor" },
        { "BANNER_BORDER", "border", "BANNER_BORDER_COLOR", "borderColor" },
        { "BANNER_SHIELD", "shield", "BANNER_SHIELD_COLOR", "shieldColor" },
        { "BANNER_WEAPON", "weapon", "BANNER_WEAPON_COLOR", "weaponColor" },
    }
    page.assetRows = {}
    for index, def in ipairs(rowKeys) do
        local y = -22 - (index - 1) * 46
        local label = CreateLabel(page.editor, self:L(def[1]), "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", 16, y)
        label:SetTextColor(unpack(UI_MUTED))
        local selector = self:CreateBannerSelector(page.editor, 96, y + 7, 132, def[2], 0, self:GetBannerAssetCount(def[2]), 1, false)
        local colorLabel = CreateLabel(page.editor, self:L(def[3]), "GameFontNormalSmall")
        colorLabel:SetPoint("TOPLEFT", 246, y)
        colorLabel:SetTextColor(unpack(UI_MUTED))
        local colorSelector = self:CreateBannerSelector(page.editor, 354, y + 7, 126, def[4], 1, #self.BANNER_PALETTE, 1, true)
        page.assetRows[index] = {
            label = label, labelKey = def[1], selector = selector,
            colorLabel = colorLabel, colorLabelKey = def[3], colorSelector = colorSelector,
        }
    end

    page.textTitle = CreateLabel(page.editor, self:L("BANNER_INITIALS"), "GameFontNormalSmall")
    page.textTitle:SetPoint("TOPLEFT", 16, -212)
    page.textTitle:SetTextColor(unpack(UI_MUTED))
    page.textEdit = CreateFrame("EditBox", nil, page.editor)
    page.textEdit:SetPoint("TOPLEFT", 16, -232)
    page.textEdit:SetWidth(160)
    page.textEdit:SetHeight(28)
    page.textEdit:SetAutoFocus(false)
    page.textEdit:SetMaxLetters(30)
    page.textEdit:SetFontObject("ChatFontNormal")
    if page.textEdit.SetTextInsets then page.textEdit:SetTextInsets(8, 8, 0, 0) end
    SetBackdrop(page.textEdit, UI_BG, UI_BORDER)
    page.textEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    page.textEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    page.textEdit:SetScript("OnTextChanged", function(self, userInput)
        if not userInput or GMG.bannerRefreshingEdit then return end
        if not GMG:BannerEditAllowedOrWarn() then
            GMG:RefreshBannerPage()
            return
        end
        local clean = GMG:SanitizeBannerText(self:GetText())
        if clean ~= self:GetText() then
            GMG.bannerRefreshingEdit = true
            self:SetText(clean)
            GMG.bannerRefreshingEdit = nil
        end
        local draft = CopyTable(GMG:GetBannerDraft())
        draft.text = clean
        GMG:SetBannerDraft(draft)
        page.dirty = true
        GMG:RefreshBannerPage(true)
    end)

    page.textColorLabel = CreateLabel(page.editor, self:L("BANNER_TEXT_COLOR"), "GameFontNormalSmall")
    page.textColorLabel:SetPoint("TOPLEFT", 194, -212)
    page.textColorLabel:SetTextColor(unpack(UI_MUTED))
    page.textColorSelector = self:CreateBannerSelector(page.editor, 194, -225, 154, "textColor", 1, #self.BANNER_PALETTE, 1, true)

    page.textSizeSelector = self:CreateBannerMiniSelector(page.editor, 16, -278, "BANNER_TEXT_SIZE", "textSize", 10, 300, 10, 132)
    page.textXSelector = self:CreateBannerMiniSelector(page.editor, 170, -278, "BANNER_TEXT_X", "textX", -70, 70, 2, 132)
    page.textYSelector = self:CreateBannerMiniSelector(page.editor, 324, -278, "BANNER_TEXT_Y", "textY", -70, 70, 2, 132)

    page.shieldScaleSelector = self:CreateBannerMiniSelector(page.editor, 16, -342, "BANNER_SHIELD_SCALE", "shieldScale", 35, 120, 5, 132)
    page.weaponScaleSelector = self:CreateBannerMiniSelector(page.editor, 170, -342, "BANNER_WEAPON_SCALE", "weaponScale", 35, 120, 5, 132)
    page.weaponRotationSelector = self:CreateBannerMiniSelector(page.editor, 324, -342, "BANNER_WEAPON_ROTATION", "weaponRotation", 0, 7, 1, 132)

    page.reset = CreateButton(page.editor, self:L("BANNER_RESET"), 138, 30)
    page.reset:SetPoint("BOTTOMLEFT", 16, 16)
    page.reset:SetScript("OnClick", function()
        if not GMG:BannerEditAllowedOrWarn() then return end
        GMG:SetBannerDraft(CopyTable(GMG.DEFAULT_BANNER_CONFIG))
        page.dirty = true
        GMG:RefreshBannerPage()
    end)
    page.test = CreateButton(page.editor, self:L("BANNER_TEST"), 150, 30)
    page.test:SetPoint("BOTTOM", 0, 16)
    page.test:SetScript("OnClick", function()
        if not GMG:BannerEditAllowedOrWarn() then return end
        if GMG.bannerTestActive then
            GMG.bannerTestActive = nil
            GMG.bannerTestConfig = nil
            GMG:Print(GMG:L("BANNER_TEST_STOPPED"))
        else
            GMG.bannerTestActive = true
            GMG.bannerTestConfig = CopyTable(GMG:GetBannerDraft())
            GMG:Print(GMG:L("BANNER_TEST_ACTIVE"))
        end
        GMG:RefreshAll(true)
        GMG:RefreshBannerPage()
    end)
    page.publish = CreateButton(page.editor, self:L("BANNER_PUBLISH"), 166, 30)
    page.publish:SetPoint("BOTTOMRIGHT", -16, 16)
    page.publish:SetScript("OnClick", function() GMG:PublishGuildBanner(GMG:GetBannerDraft()) end)

    page.status = CreateLabel(page.previewPanel, "", "GameFontNormalSmall")
    page.status:SetPoint("TOPLEFT", 16, -320)
    page.status:SetPoint("TOPRIGHT", -16, -320)
    page.status:SetHeight(70)
    page.status:SetJustifyH("LEFT")
    page.status:SetJustifyV("TOP")
    page.status:SetTextColor(unpack(UI_MUTED))
    if page.status.SetWordWrap then page.status:SetWordWrap(true) end

    page.syncInfo = CreateLabel(page.previewPanel, "", "GameFontNormalSmall")
    page.syncInfo:SetPoint("BOTTOMLEFT", 16, 18)
    page.syncInfo:SetPoint("BOTTOMRIGHT", -16, 18)
    page.syncInfo:SetJustifyH("LEFT")
    page.syncInfo:SetTextColor(0.36, 0.78, 0.52, 1)

    self.bannerPage = page
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
    elseif field == "weaponRotation" then
        return tostring((tonumber(value) or 0) * 45) .. "°"
    elseif field == "shieldScale" or field == "weaponScale" then
        return tostring(value) .. "%"
    end
    return tostring(value)
end

function GMG:RefreshOneBannerSelector(selector, draft, editable)
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

function GMG:RefreshBannerPage(keepEditText)
    local page = self.bannerPage
    if not page then return end
    local editable = self:CanEditGuildBanner()
    local draft
    if editable then
        draft = self:GetBannerDraft()
    else
        local record = self:GetGuildBannerRecord()
        draft = self:NormalizeBannerConfig(record and record.config or self.DEFAULT_BANNER_CONFIG)
    end

    for _, row in ipairs(page.assetRows or {}) do
        self:RefreshOneBannerSelector(row.selector, draft, editable)
        self:RefreshOneBannerSelector(row.colorSelector, draft, editable)
    end
    self:RefreshOneBannerSelector(page.textColorSelector, draft, editable)
    self:RefreshOneBannerSelector(page.textSizeSelector, draft, editable)
    self:RefreshOneBannerSelector(page.textXSelector, draft, editable)
    self:RefreshOneBannerSelector(page.textYSelector, draft, editable)
    self:RefreshOneBannerSelector(page.shieldScaleSelector, draft, editable)
    self:RefreshOneBannerSelector(page.weaponScaleSelector, draft, editable)
    self:RefreshOneBannerSelector(page.weaponRotationSelector, draft, editable)

    if not keepEditText then
        self.bannerRefreshingEdit = true
        page.textEdit:SetText(draft.text or "")
        self.bannerRefreshingEdit = nil
    end
    if editable then page.textEdit:Enable(); page.textEdit:SetAlpha(1) else page.textEdit:Disable(); page.textEdit:SetAlpha(0.45) end
    SetButtonEnabled(page.reset, editable)
    SetButtonEnabled(page.test, editable)
    if self:CanPublishGuildBanner() then page.publish:Show() else page.publish:Hide() end
    page.test.label:SetText(self:L(self.bannerTestActive and "BANNER_STOP_TEST" or "BANNER_TEST"))

    self:ApplyBannerToVisual(page.preview, draft)
    local record = self:GetGuildBannerRecord()
    if not self:IsInGuild() then
        page.status:SetText(self:L("BANNER_GUILDLESS"))
        page.syncInfo:SetText(self:L("BANNER_TEST_ACTIVE"))
    elseif not editable then
        page.status:SetText(self:L("BANNER_READ_ONLY"))
        if record then
            page.syncInfo:SetText(self:L("BANNER_UPDATED", date("%d/%m/%Y %H:%M", record.updatedAt), record.author or "?"))
        else
            page.syncInfo:SetText(self:L("BANNER_NOT_PUBLISHED"))
        end
    elseif record then
        page.status:SetText(self.bannerTestActive and self:L("BANNER_TEST_ACTIVE") or self:L("BANNER_HELP"))
        page.syncInfo:SetText(self:L("BANNER_UPDATED", date("%d/%m/%Y %H:%M", record.updatedAt), record.author or "?"))
    else
        page.status:SetText(self:L("BANNER_NOT_PUBLISHED"))
        page.syncInfo:SetText(self:L("BANNER_HELP"))
    end
end

function GMG:CreateBannerSidebarTab()
    if not self.mainFrame or self.mainFrame.tabs.banner then return end
    local tab = CreateButton(self.mainFrame.sidebar, self:L("BANNER"), 154, 38)
    tab:SetPoint("TOPLEFT", 18, -186)
    tab.localeKey = "BANNER"
    tab:SetScript("OnClick", function() GMG:ShowTab("banner") end)
    self.mainFrame.tabs.banner = tab
end

local GMGShowTabBeforeBannerV150 = GMG.ShowTab
function GMG:ShowTab(key)
    if key ~= "banner" then
        if self.bannerPage then self.bannerPage:Hide() end
        return GMGShowTabBeforeBannerV150(self, key)
    end
    if not self.bannerPage then return GMGShowTabBeforeBannerV150(self, "chat") end
    self.db.profile.lastTab = "banner"
    if self.PersistSettings then self:PersistSettings() end
    if self.chatPage then self.chatPage:Hide() end
    if self.rosterPage then self.rosterPage:Hide() end
    if self.guildPage then self.guildPage:Hide() end
    if self.settingsPage then self.settingsPage:Hide() end
    self.bannerPage:Show()
    for tabKey, button in pairs(self.mainFrame.tabs or {}) do
        button.selected = tabKey == "banner"
        if tabKey == "banner" then
            button:SetBackdropColor(0.28, 0.16, 0.48, 1)
            button:SetBackdropBorderColor(unpack(UI_ACCENT))
        else
            button:SetBackdropColor(unpack(UI_PANEL_2))
            button:SetBackdropBorderColor(unpack(UI_BORDER))
        end
    end
    if self.mainFrame.settingsButton then
        self.mainFrame.settingsButton:SetBackdropColor(unpack(UI_PANEL_2))
        self.mainFrame.settingsButton:SetBackdropBorderColor(unpack(UI_BORDER))
    end
    self:RefreshBannerPage()
end

local GMGCreateUIBeforeBannerV150 = GMG.CreateUI
function GMG:CreateUI(...)
    local desiredTab = self.db and self.db.profile and self.db.profile.lastTab
    GMGCreateUIBeforeBannerV150(self, ...)
    self:CreateBannerPage()
    self:CreateBannerSidebarTab()
    self:EnsureHeaderBannerVisual()
    self:EnsureGuildPageBannerVisual()
    if desiredTab == "banner" then self:ShowTab("banner") end
    self:RefreshBannerPage()
    self:RefreshDisplayedBannerVisuals()
end

local GMGRefreshAllBeforeBannerV150 = GMG.RefreshAll
function GMG:RefreshAll(force)
    GMGRefreshAllBeforeBannerV150(self, force)
    if self.bannerPage then self:RefreshBannerPage() end
    self:RefreshDisplayedBannerVisuals()
end

local GMGRefreshHeaderBeforeBannerV150 = GMG.RefreshHeader
function GMG:RefreshHeader()
    GMGRefreshHeaderBeforeBannerV150(self)
    self:RefreshDisplayedBannerVisuals()
end

local GMGRefreshGuildPageBeforeBannerV150 = GMG.RefreshGuildPage
function GMG:RefreshGuildPage()
    GMGRefreshGuildPageBeforeBannerV150(self)
    if self.guildPage then
        self.guildPage.imageTitle:SetText(self:L("BANNER"))
        if self.guildPage.changeImage and self.guildPage.changeImage.label then
            self.guildPage.changeImage.label:SetText(self:L(self:CanEditGuildBanner() and "BANNER_OPEN_EDITOR" or "BANNER_VIEW"))
            self.guildPage.changeImage:SetScript("OnClick", function() GMG:ShowTab("banner") end)
        end
    end
    self:RefreshDisplayedBannerVisuals()
end

local GMGRefreshLocalizationBeforeBannerV150 = GMG.RefreshLocalization
function GMG:RefreshLocalization()
    GMGRefreshLocalizationBeforeBannerV150(self)
    if self.mainFrame and self.mainFrame.tabs and self.mainFrame.tabs.banner then
        self.mainFrame.tabs.banner.label:SetText(self:L("BANNER"))
    end
    local page = self.bannerPage
    if page then
        page.title:SetText(self:L("BANNER_EDITOR"))
        page.help:SetText(self:L("BANNER_HELP"))
        page.previewTitle:SetText(self:L("BANNER_PREVIEW"))
        for _, row in ipairs(page.assetRows or {}) do
            row.label:SetText(self:L(row.labelKey))
            row.colorLabel:SetText(self:L(row.colorLabelKey))
        end
        page.textTitle:SetText(self:L("BANNER_INITIALS"))
        page.textColorLabel:SetText(self:L("BANNER_TEXT_COLOR"))
        local minis = { page.textSizeSelector, page.textXSelector, page.textYSelector, page.shieldScaleSelector, page.weaponScaleSelector, page.weaponRotationSelector }
        for _, selector in ipairs(minis) do if selector and selector.headerLabel then selector.headerLabel:SetText(self:L(selector.labelKey)) end end
        page.reset.label:SetText(self:L("BANNER_RESET"))
        page.publish.label:SetText(self:L("BANNER_PUBLISH"))
        self:RefreshBannerPage()
    end
end

-- ---------------------------------------------------------------------------
-- Rank lexicon: every member retained, mouse-wheel and visible scroll controls
-- ---------------------------------------------------------------------------
local GMGCreateRankLexiconBeforeBannerV150 = GMG.CreateRankLexicon
function GMG:CreateRankLexicon()
    GMGCreateRankLexiconBeforeBannerV150(self)
    local frame = self.rosterPage and self.rosterPage.rankLexicon
    if not frame or frame.v150ScrollEnhanced then return end
    frame.v150ScrollEnhanced = true
    if frame.members.SetMaxLines then frame.members:SetMaxLines(2000) end
    frame.members:EnableMouseWheel(true)
    frame.members:SetScript("OnMouseWheel", function(self, delta)
        local steps = IsShiftKeyDown and IsShiftKeyDown() and 12 or 4
        for _ = 1, steps do
            if delta > 0 then self:ScrollUp() else self:ScrollDown() end
        end
    end)
    frame.members:ClearAllPoints()
    frame.members:SetPoint("TOPLEFT", 16, -58)
    frame.members:SetPoint("BOTTOMRIGHT", -38, 34)
    frame.scrollUp = CreateButton(frame.right, "▲", 24, 24)
    frame.scrollUp:SetPoint("TOPRIGHT", -8, -46)
    frame.scrollUp:SetScript("OnClick", function()
        for _ = 1, 5 do frame.members:ScrollUp() end
    end)
    frame.scrollDown = CreateButton(frame.right, "▼", 24, 24)
    frame.scrollDown:SetPoint("BOTTOMRIGHT", -8, 14)
    frame.scrollDown:SetScript("OnClick", function()
        for _ = 1, 5 do frame.members:ScrollDown() end
    end)
    frame.scrollHint = CreateLabel(frame.right, self:L("RANK_SCROLL_HINT"), "GameFontNormalSmall")
    frame.scrollHint:SetPoint("BOTTOMLEFT", 16, 13)
    frame.scrollHint:SetPoint("BOTTOMRIGHT", -40, 13)
    frame.scrollHint:SetJustifyH("LEFT")
    frame.scrollHint:SetTextColor(unpack(UI_MUTED))
end

local GMGRefreshRankMembersBeforeBannerV150 = GMG.RefreshRankLexiconMembers
function GMG:RefreshRankLexiconMembers()
    GMGRefreshRankMembersBeforeBannerV150(self)
    local frame = self.rosterPage and self.rosterPage.rankLexicon
    if not frame then return end
    local count = 0
    for _, member in ipairs(self.rosterMembers or {}) do
        if tonumber(member.rankIndex) == tonumber(frame.selectedRankIndex) then count = count + 1 end
    end
    frame.memberTitle:SetText(self:L("RANK_MEMBERS") .. "  (" .. tostring(count) .. ")")
    if frame.members.ScrollToTop then frame.members:ScrollToTop() end
end

-- Reset draft association when the character changes guild. Official records remain
-- safely separated because GetGuildStore uses Realm::GuildName.
local GMGPlayerGuildUpdateBeforeBannerV150 = GMG.PLAYER_GUILD_UPDATE
function GMG:PLAYER_GUILD_UPDATE(...)
    GMGPlayerGuildUpdateBeforeBannerV150(self, ...)
    self.bannerTestActive = nil
    self.bannerTestConfig = nil
    if self.db and self.db.profile then self.db.profile.bannerDraft = nil end
    if self.bannerPage then self.bannerPage.dirty = nil; self:RefreshBannerPage() end
end
