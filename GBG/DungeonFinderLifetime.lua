-- G.B.G (Glayna Better Guild)
-- v1.7.6: fixed 30-minute Guild Finder lifetime and reliable full-group cleanup.
-- Compatible with WoW 3.3.5a / Ascension Interface 30300.

local GMG = GlaynaBetterGuild
local max = math.max
local tonumber = tonumber
local time = time

GMG.DUNGEON_ACTIVITY_LIFETIME = 30 * 60

function GMG:NormalizeDungeonActivityLifetime(activity)
    if type(activity) ~= "table" then return activity end
    local createdAt = tonumber(activity.createdAt) or time()
    activity.createdAt = createdAt
    -- The deadline is always based on the original creation time. Editing,
    -- joining, accepting or group changes must never extend the activity.
    activity.expiresAt = createdAt + self.DUNGEON_ACTIVITY_LIFETIME
    return activity
end

function GMG:RemoveExpiredOrFullDungeonActivity(activity, reason)
    if type(activity) ~= "table" or not activity.id or activity.id == "" then return false end
    local id = activity.id
    self.v176ClosingDungeonActivities = self.v176ClosingDungeonActivities or {}
    if self.v176ClosingDungeonActivities[id] then return false end
    self.v176ClosingDungeonActivities[id] = true

    local current = self:GetDungeonActivity(id)
    if current then activity = current end
    self:NormalizeDungeonActivityLifetime(activity)

    if self:NormalizeName(activity.owner) == self:GetPlayerName() then
        activity.revision = (tonumber(activity.revision) or 1) + 1
        activity.updatedAt = time()
        if self.BroadcastDungeonClose then
            self:BroadcastDungeonClose(activity, reason or "expired")
            if self.SendQueuedPackets then self:SendQueuedPackets(8) end
        end
    end

    local removed = false
    if self:GetDungeonActivity(id) then
        removed = self:RemoveDungeonActivity(id, reason or "expired", true) and true or false
    elseif self.RemoveDungeonAnnouncement then
        self:RemoveDungeonAnnouncement(id, true)
    end

    self.v176ClosingDungeonActivities[id] = nil
    return removed
end

function GMG:EnforceDungeonActivityLifetimeAndCapacity()
    local store = self:GetDungeonActivityStore(false)
    if not store then return end
    local now = time()
    local toExpire, toClose = {}, {}

    for id, activity in pairs(store) do
        if type(activity) == "table" then
            activity.id = activity.id or id
            self:NormalizeDungeonActivityLifetime(activity)
            if (tonumber(activity.expiresAt) or 0) <= now then
                toExpire[#toExpire + 1] = activity
            elseif self:NormalizeName(activity.owner) == self:GetPlayerName() then
                if self.RefreshDungeonOccupancy then self:RefreshDungeonOccupancy(activity) end
                local slots = max(1, tonumber(activity.slots) or 1)
                local occupied
                if self.GetDungeonActivityOccupancy then
                    occupied = self:GetDungeonActivityOccupancy(activity)
                else
                    occupied = self:CountDungeonActivityMembers(activity)
                end
                -- No free place means the listing is finished immediately,
                -- including players who joined the real party outside the addon.
                if (tonumber(occupied) or 0) >= slots then
                    toClose[#toClose + 1] = activity
                end
            end
        end
    end

    for _, activity in ipairs(toClose) do
        self:RemoveExpiredOrFullDungeonActivity(activity, "full")
    end
    for _, activity in ipairs(toExpire) do
        self:RemoveExpiredOrFullDungeonActivity(activity, "expired")
    end
end

local GMGStoreDungeonActivityBeforeV176 = GMG.StoreDungeonActivity
function GMG:StoreDungeonActivity(activity, announce)
    self:NormalizeDungeonActivityLifetime(activity)
    if type(activity) == "table" and (tonumber(activity.expiresAt) or 0) <= time() then
        local current = activity.id and self:GetDungeonActivity(activity.id)
        if current then
            self:RemoveExpiredOrFullDungeonActivity(current, "expired")
        elseif activity.id and self.RemoveDungeonAnnouncement then
            self:RemoveDungeonAnnouncement(activity.id, true)
        end
        return false
    end
    return GMGStoreDungeonActivityBeforeV176(self, activity, announce)
end

local GMGBuildDungeonActivityPayloadBeforeV176 = GMG.BuildDungeonActivityPayload
function GMG:BuildDungeonActivityPayload(activity)
    self:NormalizeDungeonActivityLifetime(activity)
    return GMGBuildDungeonActivityPayloadBeforeV176(self, activity)
end

local GMGGetDungeonActivitiesBeforeV176 = GMG.GetDungeonActivities
function GMG:GetDungeonActivities()
    local store = self:GetDungeonActivityStore(false)
    if store then
        for _, activity in pairs(store) do self:NormalizeDungeonActivityLifetime(activity) end
    end
    return GMGGetDungeonActivitiesBeforeV176(self)
end

local GMGCreateDungeonActivityBeforeV176 = GMG.CreateDungeonActivity
function GMG:CreateDungeonActivity(...)
    local success = GMGCreateDungeonActivityBeforeV176(self, ...)
    if success then self:EnforceDungeonActivityLifetimeAndCapacity() end
    return success
end

local GMGUpdateDungeonActivityBeforeV176 = GMG.UpdateDungeonActivity
function GMG:UpdateDungeonActivity(activity, ...)
    if activity then
        self:NormalizeDungeonActivityLifetime(activity)
        if (tonumber(activity.expiresAt) or 0) <= time() then
            self:RemoveExpiredOrFullDungeonActivity(activity, "expired")
            return false
        end
    end
    local success = GMGUpdateDungeonActivityBeforeV176(self, activity, ...)
    if success then self:EnforceDungeonActivityLifetimeAndCapacity() end
    return success
end

-- Replace the old pruning routine so expiration also removes the clickable
-- guild-chat announcement and the owner broadcasts a close packet.
function GMG:PruneDungeonActivities()
    local store = self:GetDungeonActivityStore(false)
    if not store then return end
    local now = time()
    local expired, stale, invalid = {}, {}, {}

    for id, activity in pairs(store) do
        if type(activity) ~= "table" then
            invalid[#invalid + 1] = id
        else
            activity.id = activity.id or id
            self:NormalizeDungeonActivityLifetime(activity)
            local owner = self:NormalizeName(activity.owner)
            local staleRemote = owner ~= "" and owner ~= self:GetPlayerName()
                and now - (tonumber(activity.receivedAt) or tonumber(activity.updatedAt) or 0) > 90
            if (tonumber(activity.expiresAt) or 0) <= now then
                expired[#expired + 1] = activity
            elseif staleRemote then
                stale[#stale + 1] = id
            end
        end
    end

    for _, activity in ipairs(expired) do
        self:RemoveExpiredOrFullDungeonActivity(activity, "expired")
    end

    local changed = false
    for _, id in ipairs(stale) do
        store[id] = nil
        if self.RemoveDungeonAnnouncement then self:RemoveDungeonAnnouncement(id, false) end
        changed = true
    end
    for _, id in ipairs(invalid) do
        store[id] = nil
        if self.RemoveDungeonAnnouncement then self:RemoveDungeonAnnouncement(id, false) end
        changed = true
    end

    if changed then
        self.dungeonDirty = true
        if self.PersistSettings then self:PersistSettings() end
        if self.RefreshDungeonFinder then self:RefreshDungeonFinder(true) end
        if self.RefreshDungeonActivityBadges then self:RefreshDungeonActivityBadges() end
    end
end

local GMGUpdateOwnedDungeonGroupStateBeforeV176 = GMG.UpdateOwnedDungeonGroupState
function GMG:UpdateOwnedDungeonGroupState(...)
    if GMGUpdateOwnedDungeonGroupStateBeforeV176 then
        GMGUpdateOwnedDungeonGroupStateBeforeV176(self, ...)
    end
    self:EnforceDungeonActivityLifetimeAndCapacity()
end
