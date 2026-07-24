-- G.B.G (Glayna Better Guild)
-- v1.8.1: native unit-frame portrait safety.
-- GMG artwork must never replace Blizzard player, target, pet or party portraits.

local GMG = GlaynaBetterGuild
local tostring = tostring
local strlower = string.lower
local string_find = string.find
local max = math.max

local GMG_MEDIA_MARKERS = {
    "gbg\\media\\",
    "glaynasmidnightguild\\media\\",
    "glaynabetterguild\\media\\",
}
local DEFAULT_GUILD_IMAGE = GMG.DEFAULT_CUSTOM_GUILD_IMAGE
    or "Interface\\AddOns\\GBG\\Media\\Guild\\midnight_guild_logo"

local function IsGMGMediaPath(value)
    if type(value) ~= "string" then return false end
    local normalized = strlower(value):gsub("/", "\\")
    for _, marker in ipairs(GMG_MEDIA_MARKERS) do
        if string_find(normalized, marker, 1, true) ~= nil then return true end
    end
    return false
end

-- The default guild logo is not a character portrait. Do not pass it through
-- the progressive character-portrait preloader used by roster/profile images.
-- Keeping those two pipelines separate prevents modified 3.3.5 clients from
-- reusing the guild texture in native unit portrait regions.
local QueuePortraitTextureBeforeV181Safety = GMG.QueuePortraitTexture
function GMG:QueuePortraitTexture(texture, priority)
    if texture == DEFAULT_GUILD_IMAGE then
        self.portraitReady = self.portraitReady or {}
        self.portraitQueued = self.portraitQueued or {}
        self.portraitReady[texture] = true
        self.portraitQueued[texture] = nil
        return
    end
    return QueuePortraitTextureBeforeV181Safety(self, texture, priority)
end

-- If the default guild image was already queued by an earlier initialization
-- path, remove it before the portrait loader can assign it to its preload region.
function GMG:RemoveGuildImageFromPortraitQueue()
    local queue = self.portraitLoadQueue
    if type(queue) == "table" then
        for index = #queue, 1, -1 do
            if queue[index] == DEFAULT_GUILD_IMAGE then
                table.remove(queue, index)
            end
        end
    end
    if self.portraitQueued then self.portraitQueued[DEFAULT_GUILD_IMAGE] = nil end
    if self.portraitPending == DEFAULT_GUILD_IMAGE then
        self.portraitPending = nil
        self.portraitPendingElapsed = 0
    end
    self.portraitReady = self.portraitReady or {}
    self.portraitReady[DEFAULT_GUILD_IMAGE] = true
end

local NATIVE_PORTRAITS = {
    { "PlayerFramePortrait", "player" },
    { "PetFramePortrait", "pet" },
    { "TargetFramePortrait", "target" },
    { "TargetFrameToTPortrait", "targettarget" },
    { "FocusFramePortrait", "focus" },
    { "FocusFrameToTPortrait", "focustarget" },
    { "PartyMemberFrame1Portrait", "party1" },
    { "PartyMemberFrame2Portrait", "party2" },
    { "PartyMemberFrame3Portrait", "party3" },
    { "PartyMemberFrame4Portrait", "party4" },
    { "PartyMemberFrame1PetFramePortrait", "partypet1" },
    { "PartyMemberFrame2PetFramePortrait", "partypet2" },
    { "PartyMemberFrame3PetFramePortrait", "partypet3" },
    { "PartyMemberFrame4PetFramePortrait", "partypet4" },
}

local function RepairPortrait(texture, unit, force)
    if not texture or not texture.GetTexture or not texture.SetTexture then return end
    if not UnitExists or not UnitExists(unit) then return end

    local current = texture:GetTexture()
    if not force and not IsGMGMediaPath(current) then return end

    if SetPortraitTexture then
        SetPortraitTexture(texture, unit)
    end
end

function GMG:RepairNativeUnitPortraits(force)
    self:RemoveGuildImageFromPortraitQueue()
    for _, definition in ipairs(NATIVE_PORTRAITS) do
        RepairPortrait(_G[definition[1]], definition[2], force)
    end
end

function GMG:ScheduleNativePortraitRepair(force)
    local watcher = self.nativePortraitSafetyWatcher
    if not watcher then return end
    watcher.repairRemaining = max(tonumber(watcher.repairRemaining) or 0, 1.25)
    watcher.repairElapsed = 0
    if force then watcher.forceNextRepair = true end
end

local watcher = CreateFrame("Frame", nil, UIParent)
GMG.nativePortraitSafetyWatcher = watcher
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("PLAYER_TARGET_CHANGED")
watcher:RegisterEvent("PLAYER_FOCUS_CHANGED")
watcher:RegisterEvent("PARTY_MEMBERS_CHANGED")
watcher:RegisterEvent("RAID_ROSTER_UPDATE")
watcher:RegisterEvent("UNIT_PORTRAIT_UPDATE")
watcher:RegisterEvent("UNIT_MODEL_CHANGED")
watcher:RegisterEvent("UNIT_NAME_UPDATE")
watcher:SetScript("OnEvent", function(_, event)
    GMG:ScheduleNativePortraitRepair(event == "PLAYER_ENTERING_WORLD")
end)
watcher:SetScript("OnUpdate", function(self, elapsed)
    if not self.repairRemaining or self.repairRemaining <= 0 then return end
    self.repairRemaining = self.repairRemaining - elapsed
    self.repairElapsed = (self.repairElapsed or 0) + elapsed
    if self.repairElapsed < 0.10 then return end
    self.repairElapsed = 0
    GMG:RepairNativeUnitPortraits(self.forceNextRepair)
    self.forceNextRepair = nil
end)

-- Repair again after the client refreshes its native unit frames. These hooks
-- are optional because Ascension builds do not all expose the same functions.
local function HookPortraitUpdater(functionName)
    if not hooksecurefunc or type(_G[functionName]) ~= "function" then return end
    hooksecurefunc(functionName, function()
        GMG:ScheduleNativePortraitRepair(false)
    end)
end

HookPortraitUpdater("TargetFrame_Update")
HookPortraitUpdater("TargetFrame_UpdatePortrait")
HookPortraitUpdater("PartyMemberFrame_UpdateMember")
HookPortraitUpdater("PartyMemberFrame_UpdatePet")
HookPortraitUpdater("PlayerFrame_Update")
HookPortraitUpdater("PetFrame_Update")

local CreateUIBeforeV181PortraitSafety = GMG.CreateUI
function GMG:CreateUI(...)
    local result = CreateUIBeforeV181PortraitSafety(self, ...)
    self:RemoveGuildImageFromPortraitQueue()
    self:ScheduleNativePortraitRepair(true)
    return result
end

local SetGuildImageBeforeV181PortraitSafety = GMG.SetGuildImage
function GMG:SetGuildImage(...)
    local result = SetGuildImageBeforeV181PortraitSafety(self, ...)
    self:RemoveGuildImageFromPortraitQueue()
    self:ScheduleNativePortraitRepair(false)
    return result
end
