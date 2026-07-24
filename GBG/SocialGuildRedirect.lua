-- G.B.G (Glayna Better Guild)
-- Redirects Blizzard Social -> Guild to the GMG interface on WoW 3.3.5a.

local GMG = GlaynaBetterGuild
if not GMG then return end

local redirecting = false
local installedTabs = setmetatable({}, { __mode = "k" })

local function IsGuildSubFrame(frame)
    if not frame then return false end
    if frame == _G.GuildFrame or frame == _G.FriendsFrameGuildFrame then return true end
    local name = frame.GetName and frame:GetName() or tostring(frame)
    name = string.lower(tostring(name or ""))
    return string.find(name, "guild", 1, true) ~= nil
end

local function HideBlizzardGuildUI()
    local friends = _G.FriendsFrame
    if friends and friends:IsShown() then
        if _G.HideUIPanel then
            _G.HideUIPanel(friends)
        else
            friends:Hide()
        end
    end

    local guildFrames = {
        _G.GuildFrame,
        _G.FriendsFrameGuildFrame,
        _G.GuildControlUI,
        _G.GuildMemberDetailFrame,
    }
    for _, frame in ipairs(guildFrames) do
        if frame and frame.Hide and frame:IsShown() then frame:Hide() end
    end
end

function GMG:OpenFromBlizzardGuild()
    if redirecting then return end
    redirecting = true

    HideBlizzardGuildUI()

    if not self.mainFrame and self.CreateUI then self:CreateUI() end
    if self.mainFrame then
        -- The Blizzard Guild tab is closest to GMG's member roster.
        if self.ShowTab then self:ShowTab("roster") end
        self.mainFrame:Show()
        if self.StartPortraitLoading then self:StartPortraitLoading() end
        if self.RefreshHeader then self:RefreshHeader() end
        if self.RefreshRoster then self:RefreshRoster() end
    end

    redirecting = false
end

local function InstallGuildTab(tab)
    if not tab then return end
    local handler = installedTabs[tab]
    if not handler then
        handler = function()
            GMG:OpenFromBlizzardGuild()
        end
        installedTabs[tab] = handler
    end
    if tab.RegisterForClicks then tab:RegisterForClicks("LeftButtonUp") end
    if tab.GetScript and tab:GetScript("OnClick") ~= handler then
        tab:SetScript("OnClick", handler)
    end
end

local function InstallKnownGuildTabs()
    -- 3.3.5a normally uses FriendsFrameTab3 for Guild. Alternative names are
    -- included for Ascension/client UI variations.
    InstallGuildTab(_G.FriendsFrameTab3)
    InstallGuildTab(_G.FriendsFrameGuildTab)
    InstallGuildTab(_G.GuildFrameTab)
end

local wrappedToggleFriendsFrame
local wrappedFriendsFrameShowSubFrame
local wrappedToggleGuildFrame

local function IsGuildTabRequest(tab)
    if tonumber(tab) == 3 then return true end
    if type(tab) == "string" then
        return string.find(string.lower(tab), "guild", 1, true) ~= nil
    end
    return IsGuildSubFrame(tab)
end

local function InstallFunctionRedirects()
    if type(_G.ToggleFriendsFrame) == "function" and _G.ToggleFriendsFrame ~= wrappedToggleFriendsFrame then
        local original = _G.ToggleFriendsFrame
        wrappedToggleFriendsFrame = function(tab, ...)
            if IsGuildTabRequest(tab) then
                GMG:OpenFromBlizzardGuild()
                return
            end
            return original(tab, ...)
        end
        _G.ToggleFriendsFrame = wrappedToggleFriendsFrame
    end

    if type(_G.FriendsFrame_ShowSubFrame) == "function" and _G.FriendsFrame_ShowSubFrame ~= wrappedFriendsFrameShowSubFrame then
        local original = _G.FriendsFrame_ShowSubFrame
        wrappedFriendsFrameShowSubFrame = function(subFrame, ...)
            if IsGuildSubFrame(subFrame) then
                GMG:OpenFromBlizzardGuild()
                return
            end
            return original(subFrame, ...)
        end
        _G.FriendsFrame_ShowSubFrame = wrappedFriendsFrameShowSubFrame
    end

    if type(_G.ToggleGuildFrame) == "function" and _G.ToggleGuildFrame ~= wrappedToggleGuildFrame then
        wrappedToggleGuildFrame = function(...)
            GMG:OpenFromBlizzardGuild()
        end
        _G.ToggleGuildFrame = wrappedToggleGuildFrame
    end
end

local function HookGuildFrameOnShow(frame)
    if not frame or frame.GMGRedirectHooked then return end
    frame.GMGRedirectHooked = true
    if frame.HookScript then
        frame:HookScript("OnShow", function(self)
            if redirecting then return end
            self:Hide()
            GMG:OpenFromBlizzardGuild()
        end)
    end
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:RegisterEvent("ADDON_LOADED")
watcher.elapsed = 0
watcher:SetScript("OnEvent", function(_, event, addonName)
    if event == "PLAYER_LOGIN"
        or addonName == "Blizzard_GuildUI"
        or addonName == "Blizzard_FriendsFrame"
        or addonName == "Blizzard_SocialUI" then
        InstallFunctionRedirects()
        InstallKnownGuildTabs()
        HookGuildFrameOnShow(_G.GuildFrame)
        HookGuildFrameOnShow(_G.FriendsFrameGuildFrame)
    end
end)

-- Some Ascension UI packs create or replace Social tabs after PLAYER_LOGIN.
-- Re-check occasionally and redirect if the Blizzard Guild subframe appears.
watcher:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < 0.25 then return end
    self.elapsed = 0

    InstallFunctionRedirects()
    InstallKnownGuildTabs()
    HookGuildFrameOnShow(_G.GuildFrame)
    HookGuildFrameOnShow(_G.FriendsFrameGuildFrame)

    local guildFrame = _G.GuildFrame or _G.FriendsFrameGuildFrame
    if guildFrame and guildFrame:IsShown() and not redirecting then
        guildFrame:Hide()
        GMG:OpenFromBlizzardGuild()
    end
end)
