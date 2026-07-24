-- G.B.G (Glayna Better Guild)
-- Automatic guild-only data exchange every 5 seconds

local GMG = GlaynaBetterGuild
local max = math.max
local min = math.min
local floor = math.floor
local time = time
local tostring = tostring
local tonumber = tonumber
local strlower = string.lower

local function Escape(value)
    value = tostring(value or "")
    value = string.gsub(value, "%%", "%%25")
    value = string.gsub(value, "|", "%%7C")
    value = string.gsub(value, "\n", "%%0A")
    value = string.gsub(value, "\r", "%%0D")
    return value
end

local function Unescape(value)
    value = tostring(value or "")
    value = string.gsub(value, "%%0D", "\r")
    value = string.gsub(value, "%%0A", "\n")
    value = string.gsub(value, "%%7C", "|")
    value = string.gsub(value, "%%25", "%%")
    return value
end

local function Split(payload)
    local values = {}
    local start = 1
    while true do
        local separator = string.find(payload, "|", start, true)
        if not separator then
            values[#values + 1] = string.sub(payload, start)
            break
        end
        values[#values + 1] = string.sub(payload, start, separator - 1)
        start = separator + 1
    end
    return values
end

function GMG:NewPacketID()
    self.packetSerial = (self.packetSerial or 0) + 1
    return self:Hash(self:GetPlayerName() .. ":" .. tostring(time()) .. ":" .. tostring(self.packetSerial) .. ":" .. tostring(GetTime()))
end

function GMG:QueueRawPayload(payload, channel, target, priority)
    self.commQueue = self.commQueue or {}
    local item = { payload = payload, channel = channel or "GUILD", target = target }
    if priority then table.insert(self.commQueue, 1, item) else table.insert(self.commQueue, item) end
end

function GMG:QueuePacket(payload, channel, target, priority)
    if not payload or payload == "" then return end
    if string.len(payload) <= 235 then
        self:QueueRawPayload(payload, channel, target, priority)
        return
    end
    local packetID = self:NewPacketID()
    local chunkSize = 170
    local total = math.ceil(string.len(payload) / chunkSize)
    for index = 1, total do
        local chunk = string.sub(payload, (index - 1) * chunkSize + 1, index * chunkSize)
        local fragment = table.concat({"F", packetID, tostring(index), tostring(total), chunk}, "|")
        self:QueueRawPayload(fragment, channel, target, priority and index == 1)
    end
end

function GMG:SendQueuedPackets(limit)
    if not self.commQueue or #self.commQueue == 0 then return end
    limit = tonumber(limit) or 12
    local sent = 0
    while #self.commQueue > 0 and sent < limit do
        local item = table.remove(self.commQueue, 1)
        if SendAddonMessage then
            SendAddonMessage(self.commPrefix, item.payload, item.channel, item.target)
        end
        sent = sent + 1
    end
end

function GMG:BuildStatePayload()
    local oldest, latest, count = self:GetHistoryBounds()
    local character = self:GetCharacterStore(true)
    local guildImage = self:GetGuildImage()
    return table.concat({
        "S",
        self:GetGuildHash() or "",
        tostring(self.protocolVersion),
        tostring(oldest),
        tostring(latest),
        tostring(count),
        tostring(character.avatarRevision or 1),
        self:Hash(character.avatar or self.DEFAULT_AVATAR),
        tostring(guildImage and guildImage.revision or 0),
        self:Hash(guildImage and guildImage.texture or ""),
    }, "|")
end

function GMG:BuildProfilePayload(name, profile)
    local ownerID = tostring(profile.ownerID or "")
    local mainRecord = ownerID ~= "" and self:GetOwnerMainRecord(ownerID) or nil
    return table.concat({
        "P",
        self:GetGuildHash() or "",
        Escape(name),
        tostring(profile.revision or 0),
        Escape(profile.texture or self.DEFAULT_AVATAR),
        Escape(ownerID),
        tostring(mainRecord and mainRecord.revision or 0),
        Escape(mainRecord and mainRecord.name or ""),
    }, "|")
end

function GMG:QueueProfileBroadcast(priority)
    if not self:IsInGuild() then return end
    local character = self:GetCharacterStore(true)
    local name = self:GetPlayerName()
    self:StoreProfile(name, character.avatar, character.avatarRevision, name, self:GetOwnerID())
    local profile = self:GetProfile(name)
    if profile then self:QueuePacket(self:BuildProfilePayload(name, profile), "GUILD", nil, priority) end
end

function GMG:QueueOwnProfilesBroadcast(priority)
    if not self:IsInGuild() then return end
    local store = self:GetGuildStore(false)
    local ownerID = self:GetOwnerID()
    local queued = 0
    if store and store.profiles then
        for name, profile in pairs(store.profiles) do
            if profile.ownerID == ownerID or self:IsOwnCharacter(profile.name or name) then
                profile.ownerID = ownerID
                self:QueuePacket(self:BuildProfilePayload(profile.name or name, profile), "GUILD", nil, priority and queued == 0)
                queued = queued + 1
            end
        end
    end
    if queued == 0 then self:QueueProfileBroadcast(priority) end
end

function GMG:BuildGuildImagePayload()
    local image = self:GetGuildImage()
    if not image then return nil end
    return table.concat({
        "G",
        self:GetGuildHash() or "",
        tostring(image.revision or 0),
        Escape(image.author or ""),
        Escape(image.texture or self.DEFAULT_GUILD_IMAGE),
    }, "|")
end

function GMG:QueueGuildImageBroadcast(priority, channel, target)
    local payload = self:BuildGuildImagePayload()
    if payload then self:QueuePacket(payload, channel or "GUILD", target, priority) end
end

function GMG:QueueHistoryFor(target, afterTimestamp, beforeTimestamp)
    if not target or target == "" then return end
    afterTimestamp = tonumber(afterTimestamp) or 0
    beforeTimestamp = tonumber(beforeTimestamp) or 0
    local messages = self:GetMessages()
    local candidates = {}
    for index = 1, #messages do
        local message = messages[index]
        local stamp = tonumber(message.ts) or 0
        if stamp >= afterTimestamp - 30 and (beforeTimestamp == 0 or stamp < beforeTimestamp) then
            candidates[#candidates + 1] = message
        end
    end

    local pageSize = 100
    local hasMore = #candidates > pageSize
    local first = max(1, #candidates - pageSize + 1)
    local nextBefore = 0
    for index = first, #candidates do
        local message = candidates[index]
        if nextBefore == 0 then nextBefore = tonumber(message.ts) or 0 end
        local payload = table.concat({
            "H",
            self:GetGuildHash() or "",
            Escape(message.id or self:BuildMessageID(message.sender, message.text, message.ts)),
            tostring(message.ts or 0),
            Escape(message.sender or ""),
            Escape(message.text or ""),
        }, "|")
        self:QueuePacket(payload, "WHISPER", target, false)
    end
    self:QueuePacket(table.concat({
        "E",
        self:GetGuildHash() or "",
        tostring(#candidates),
        hasMore and "1" or "0",
        tostring(nextBefore),
        tostring(afterTimestamp),
    }, "|"), "WHISPER", target, false)
end

function GMG:QueueProfilesFor(target)
    local store = self:GetGuildStore(false)
    if not store or not target then return end
    local queued = 0
    for _, profile in pairs(store.profiles) do
        self:QueuePacket(self:BuildProfilePayload(profile.name, profile), "WHISPER", target, false)
        queued = queued + 1
        if queued >= 120 then break end
    end
end

function GMG:RequestHistory(target, latest, beforeTimestamp)
    self:QueuePacket(table.concat({"RH", self:GetGuildHash() or "", tostring(latest or 0), tostring(beforeTimestamp or 0)}, "|"), "WHISPER", target, true)
end

function GMG:RequestProfiles(target)
    self:QueuePacket(table.concat({"RP", self:GetGuildHash() or ""}, "|"), "WHISPER", target, true)
end

function GMG:RequestGuildImage(target)
    self:QueuePacket(table.concat({"RG", self:GetGuildHash() or ""}, "|"), "WHISPER", target, true)
end

function GMG:SyncTick(initial)
    if not self:IsInGuild() then
        self.syncStatus = self:L("SYNC_WAITING")
        if self.RefreshSyncStatus then self:RefreshSyncStatus() end
        return
    end
    if GuildRoster then GuildRoster() end

    self:QueuePacket(self:BuildStatePayload(), "GUILD", nil, true)
    self:QueueProfileBroadcast(false)
    if self:CanEditGuildImage() and self:GetGuildImage() then self:QueueGuildImageBroadcast(false) end
    self:SendQueuedPackets(initial and 20 or 12)

    self.syncStatus = self:L("SYNC_READY")
    if self.RefreshSyncStatus then self:RefreshSyncStatus() end

    local now = time()
    self.incomingFragments = self.incomingFragments or {}
    for key, fragment in pairs(self.incomingFragments) do
        if now - (fragment.at or now) > 30 then self.incomingFragments[key] = nil end
    end
end

function GMG:HandleCompletePayload(payload, channel, sender)
    local values = Split(payload)
    local command = values[1]
    local guildHash = values[2]
    if guildHash ~= self:GetGuildHash() then return end
    sender = self:NormalizeName(sender)
    if sender == self:GetPlayerName() then return end
    if not self:IsGuildMemberName(sender) then return end

    if command == "S" then
        self.syncPeers = self.syncPeers or {}
        self.syncPeers[strlower(sender)] = { name = sender, seenAt = time(), version = values[3] }
        local remoteOldest = tonumber(values[4]) or 0
        local remoteLatest = tonumber(values[5]) or 0
        local remoteCount = tonumber(values[6]) or 0
        local remoteGuildRevision = tonumber(values[9]) or 0
        local localOldest, localLatest, localCount = self:GetHistoryBounds()
        if remoteLatest > localLatest or remoteCount > localCount
            or (remoteOldest > 0 and (localOldest == 0 or remoteOldest < localOldest)) then
            local key = "history-request-" .. strlower(sender)
            if not self.lastRequests then self.lastRequests = {} end
            if time() - (self.lastRequests[key] or 0) >= 15 then
                self.lastRequests[key] = time()
                local requestAfter = (remoteOldest > 0 and (localOldest == 0 or remoteOldest < localOldest)) and 0 or localLatest
                self:RequestHistory(sender, requestAfter)
            end
        end
        local localImage = self:GetGuildImage()
        local localRevision = localImage and tonumber(localImage.revision) or 0
        if remoteGuildRevision > localRevision then
            local key = "guild-image-request-" .. strlower(sender)
            self.lastRequests = self.lastRequests or {}
            if time() - (self.lastRequests[key] or 0) >= 15 then
                self.lastRequests[key] = time()
                self:RequestGuildImage(sender)
            end
        end
        local profileKey = "profile-request-" .. strlower(sender)
        self.lastRequests = self.lastRequests or {}
        if time() - (self.lastRequests[profileKey] or 0) >= 300 then
            self.lastRequests[profileKey] = time()
            self:RequestProfiles(sender)
        end

    elseif command == "P" then
        local name = Unescape(values[3])
        local revision = tonumber(values[4]) or 0
        local texture = Unescape(values[5])
        local ownerID = Unescape(values[6] or "")
        local mainRevision = tonumber(values[7]) or 0
        local mainName = Unescape(values[8] or "")
        self:StoreProfile(name, texture, revision, sender, ownerID, mainName, mainRevision)

    elseif command == "G" then
        local revision = tonumber(values[3]) or 0
        local author = Unescape(values[4])
        local texture = Unescape(values[5])
        if self:StoreGuildImage(texture, revision, author) and self.RefreshAll then self:RefreshAll(true) end

    elseif command == "H" then
        local messageID = Unescape(values[3])
        local timestamp = tonumber(values[4]) or time()
        local author = Unescape(values[5])
        local text = Unescape(values[6])
        self:AddHistoryMessage(author, text, timestamp, "sync", messageID)

    elseif command == "RH" and channel == "WHISPER" then
        self:QueueHistoryFor(sender, tonumber(values[3]) or 0, tonumber(values[4]) or 0)

    elseif command == "RP" and channel == "WHISPER" then
        self:QueueProfilesFor(sender)

    elseif command == "RG" and channel == "WHISPER" then
        self:QueueGuildImageBroadcast(true, "WHISPER", sender)

    elseif command == "E" then
        local hasMore = values[4] == "1"
        local nextBefore = tonumber(values[5]) or 0
        local originalAfter = tonumber(values[6]) or 0
        self:PruneHistory(true)
        self.chatDirty = true
        self.guildPageDirty = true
        if hasMore and nextBefore > 0 then
            self:RequestHistory(sender, originalAfter, nextBefore)
        end
    end
end

function GMG:HandleFragment(packetID, index, total, chunk, channel, sender)
    index = tonumber(index) or 0
    total = tonumber(total) or 0
    chunk = chunk or ""
    if packetID == "" or index < 1 or total < 1 or index > total or total > 20 then return end
    self.incomingFragments = self.incomingFragments or {}
    local key = strlower(self:NormalizeName(sender)) .. ":" .. packetID
    local record = self.incomingFragments[key]
    if not record then
        record = { parts = {}, count = 0, total = total, at = time(), channel = channel, sender = sender }
        self.incomingFragments[key] = record
    end
    if record.total ~= total then self.incomingFragments[key] = nil; return end
    if not record.parts[index] then
        record.parts[index] = chunk
        record.count = record.count + 1
    end
    if record.count >= record.total then
        local completed = {}
        for part = 1, record.total do
            if not record.parts[part] then return end
            completed[#completed + 1] = record.parts[part]
        end
        self.incomingFragments[key] = nil
        self:HandleCompletePayload(table.concat(completed), channel, sender)
    end
end

function GMG:CHAT_MSG_ADDON(prefix, payload, channel, sender)
    if prefix ~= self.commPrefix or not payload or payload == "" or not self:IsInGuild() then return end
    if string.sub(payload, 1, 2) == "F|" then
        local packetID, index, total, chunk = string.match(payload, "^F|([^|]+)|(%d+)|(%d+)|(.*)$")
        if packetID then self:HandleFragment(packetID, index, total, chunk, channel, sender) end
    else
        self:HandleCompletePayload(payload, channel, sender)
    end
end


-- ==========================================================================
-- v1.7.3: exchange the actual addon version and warn about newer releases.
-- ==========================================================================
local function GMGV173Split(payload)
    local values = {}
    local start = 1
    while true do
        local separator = string.find(payload or "", "|", start, true)
        if not separator then
            values[#values + 1] = string.sub(payload or "", start)
            break
        end
        values[#values + 1] = string.sub(payload, start, separator - 1)
        start = separator + 1
    end
    return values
end

function GMG:CompareAddonVersions(left, right)
    local function Parts(value)
        local result = {}
        value = tostring(value or "")
        for number in string.gmatch(value, "(%d+)") do
            result[#result + 1] = tonumber(number) or 0
            if #result >= 4 then break end
        end
        while #result < 4 do result[#result + 1] = 0 end
        return result
    end
    local a, b = Parts(left), Parts(right)
    for index = 1, 4 do
        if a[index] > b[index] then return 1 end
        if a[index] < b[index] then return -1 end
    end
    return 0
end

function GMG:CheckRemoteAddonVersion(remoteVersion, sender)
    remoteVersion = tostring(remoteVersion or "")
    if remoteVersion == "" or not string.find(remoteVersion, "%d") then return end
    if self:CompareAddonVersions(remoteVersion, self.version) <= 0 then return end

    self.updateVersionNotifiedThisSession = self.updateVersionNotifiedThisSession or {}
    if self.updateVersionNotifiedThisSession[remoteVersion] then return end
    self.updateVersionNotifiedThisSession[remoteVersion] = true

    if self.ShowUpdateAvailablePopup then
        self:ShowUpdateAvailablePopup(remoteVersion, self:NormalizeName(sender))
    else
        self:Print("A newer addon version (" .. remoteVersion .. ") is available on addon.devquestlog.com or through the launcher.")
    end
end

local GMGBuildStatePayloadBeforeV173 = GMG.BuildStatePayload
function GMG:BuildStatePayload(...)
    local payload = GMGBuildStatePayloadBeforeV173(self, ...)
    return tostring(payload or "") .. "|" .. tostring(self.version or "")
end

local GMGHandleCompletePayloadBeforeV173 = GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload, channel, sender)
    local values = GMGV173Split(payload)
    if values[1] == "S" and values[2] == self:GetGuildHash() and values[11] and values[11] ~= "" then
        local normalizedSender = self:NormalizeName(sender)
        if normalizedSender ~= self:GetPlayerName() and self:IsGuildMemberName(normalizedSender) then
            self:CheckRemoteAddonVersion(values[11], normalizedSender)
        end
    end
    return GMGHandleCompletePayloadBeforeV173(self, payload, channel, sender)
end
