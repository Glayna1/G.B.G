-- G.B.G (Glayna Better Guild)
-- v1.7.8: Dungeon Finder validation, role editing, polished layout and tooltips.
-- WoW 3.3.5a / Ascension Interface 30300.

local GMG = GlaynaBetterGuild
local max, min = math.max, math.min
local floor = math.floor
local tonumber, tostring = tonumber, tostring
local strlower = string.lower
local time = time

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
}
local BG = {0.025, 0.031, 0.052, 0.995}
local PANEL = {0.045, 0.052, 0.082, 0.99}
local PANEL2 = {0.075, 0.082, 0.125, 0.98}
local BORDER = {0.24, 0.22, 0.38, 1}
local ACCENT = {0.60, 0.42, 1.00, 1}
local ACCENTSOFT = {0.30, 0.19, 0.52, 0.95}
local TEXT = {0.88, 0.90, 0.96, 1}
local MUTED = {0.48, 0.52, 0.64, 1}
local GREEN = {0.25, 0.90, 0.55, 1}
local RED = {0.95, 0.34, 0.42, 1}

local EN = {
    DF_CREATE_BLOCKED_TITLE = "Activity cannot be created",
    DF_CREATE_BLOCKED_NAME = "Enter an activity name before creating it.",
    DF_CREATE_BLOCKED_LEVEL = "Your level (%d) does not meet the selected requirement (%d-%d). Change the level range before creating the activity.",
    DF_CREATE_BLOCKED_GROUP_SIZE = "The target size must be at least the current group size (%d).",
    DF_CREATE_BLOCKED_ROLES = "Enable at least one available role.",
    DF_CREATE_BLOCKED_OWN_ROLE = "Choose an enabled role for your own character.",
    DF_CREATE_BLOCKED_ROLE_CAP = "The selected composition has no available place for your own role (%s).",
    DF_CREATE_READY = "All requirements are met. Click to create the activity.",
    DF_CREATE_NOT_READY = "The button is grey because one or more creation requirements are not met. Click it to see the reason.",
    DF_ROLE_CHANGE_TITLE = "Change assigned role",
    DF_ROLE_CHANGE_HELP = "Choose the new role assigned to %s.",
    DF_ROLE_CHANGE_SELF_HINT = "Click to change your registered role.",
    DF_ROLE_CHANGE_LEADER_HINT = "As the activity leader, click to change this registered party member's role.",
    DF_ROLE_CHANGE_DENIED = "You cannot change this player's role.",
    DF_ROLE_CHANGED = "%s is now registered as %s.",
    DF_ROLE_CHANGE_FULL = "This role has no remaining place in the activity composition.",
    DF_TOOLTIP_CREATE = "Open the form used to create a synchronized guild activity.",
    DF_TOOLTIP_REFRESH = "Request the latest open activities from guild members using the addon.",
    DF_TOOLTIP_JOIN = "Register for this activity with the selected role.",
    DF_TOOLTIP_LEAVE = "Leave this activity or cancel your pending request.",
    DF_TOOLTIP_EDIT = "Edit the activity. Only its leader can make changes.",
    DF_TOOLTIP_APPLICANTS = "Review pending registrations when manual approval is enabled.",
    DF_TOOLTIP_INVITE = "Send or resend invitations to accepted players who are not yet in the group.",
    DF_TOOLTIP_CLOSE = "Close the activity and remove it from the Finder and addon guild chat.",
    DF_TOOLTIP_PVE = "Create a PvE activity and display the corresponding PvE activity types.",
    DF_TOOLTIP_PVP = "Create a PvP activity and display the corresponding PvP activity types.",
    DF_TOOLTIP_ACTIVITY_TYPE = "Choose the precise activity type. Its recommended level requirement is applied automatically.",
    DF_TOOLTIP_LEVEL_MIN = "Minimum character level allowed to register.",
    DF_TOOLTIP_LEVEL_MAX = "Maximum character level allowed to register.",
    DF_TOOLTIP_GROUP_SIZE = "Final group size, including players who joined outside the addon.",
    DF_TOOLTIP_AVAILABLE_ROLES = "Enable the roles that players may choose for this activity.",
    DF_TOOLTIP_CREATOR_ROLE = "Choose the role you occupy in the activity composition.",
    DF_TOOLTIP_APPROVAL_AUTO = "Valid registrations are accepted automatically. Accepted players are then invited automatically.",
    DF_TOOLTIP_APPROVAL_MANUAL = "Registrations wait for the activity leader's approval. Accepted players are then invited automatically.",
    DF_TOOLTIP_DESCRIPTION = "Optional description. It is visible in the activity tooltip.",
    DF_TOOLTIP_CREATE_CONFIRM = "Create the activity when every requirement is met.",
    DF_TOOLTIP_SAVE_CONFIRM = "Save the activity changes.",
    DF_TOOLTIP_CANCEL = "Close this window without saving.",
    DF_TOOLTIP_ROLE_BUTTON = "Select %s as your registration role.",
    DF_TOOLTIP_MEMBER_LIST = "Registered players and players already present in the leader's group.",
    DF_TOOLTIP_PREVIOUS = "Previous page.",
    DF_TOOLTIP_NEXT = "Next page.",
    DF_TOOLTIP_FULL_LABEL = "Full button label",
    DF_OK = "OK",
}
local FR = {
    DF_CREATE_BLOCKED_TITLE = "Création de l’activité impossible",
    DF_CREATE_BLOCKED_NAME = "Saisissez un nom d’activité avant de la créer.",
    DF_CREATE_BLOCKED_LEVEL = "Votre niveau (%d) ne correspond pas au prérequis sélectionné (%d-%d). Modifiez la tranche de niveau avant de créer l’activité.",
    DF_CREATE_BLOCKED_GROUP_SIZE = "La taille cible doit être au moins égale à la taille actuelle du groupe (%d).",
    DF_CREATE_BLOCKED_ROLES = "Activez au moins un rôle disponible.",
    DF_CREATE_BLOCKED_OWN_ROLE = "Choisissez pour votre personnage un rôle qui est activé.",
    DF_CREATE_BLOCKED_ROLE_CAP = "La composition sélectionnée ne possède aucune place disponible pour votre rôle (%s).",
    DF_CREATE_READY = "Tous les prérequis sont remplis. Cliquez pour créer l’activité.",
    DF_CREATE_NOT_READY = "Le bouton est grisé, car un ou plusieurs prérequis de création ne sont pas remplis. Cliquez dessus pour connaître la raison.",
    DF_ROLE_CHANGE_TITLE = "Modifier le rôle attribué",
    DF_ROLE_CHANGE_HELP = "Choisissez le nouveau rôle attribué à %s.",
    DF_ROLE_CHANGE_SELF_HINT = "Cliquez pour modifier votre rôle d’inscription.",
    DF_ROLE_CHANGE_LEADER_HINT = "En tant que responsable, cliquez pour modifier le rôle de ce joueur inscrit présent dans votre groupe.",
    DF_ROLE_CHANGE_DENIED = "Vous ne pouvez pas modifier le rôle de ce joueur.",
    DF_ROLE_CHANGED = "%s est désormais inscrit en tant que %s.",
    DF_ROLE_CHANGE_FULL = "Ce rôle ne possède plus de place disponible dans la composition de l’activité.",
    DF_TOOLTIP_CREATE = "Ouvre le formulaire permettant de créer une activité de guilde synchronisée.",
    DF_TOOLTIP_REFRESH = "Demande aux membres de guilde utilisant l’addon la liste la plus récente des activités ouvertes.",
    DF_TOOLTIP_JOIN = "Vous inscrit à cette activité avec le rôle sélectionné.",
    DF_TOOLTIP_LEAVE = "Quitte cette activité ou annule votre demande en attente.",
    DF_TOOLTIP_EDIT = "Modifie l’activité. Seul son responsable peut effectuer les changements.",
    DF_TOOLTIP_APPLICANTS = "Affiche les inscriptions en attente lorsque la validation manuelle est activée.",
    DF_TOOLTIP_INVITE = "Envoie ou renvoie une invitation aux joueurs acceptés qui ne sont pas encore dans le groupe.",
    DF_TOOLTIP_CLOSE = "Ferme l’activité et la retire du Finder ainsi que de la discussion de guilde de l’addon.",
    DF_TOOLTIP_PVE = "Crée une activité JcE et affiche les types d’activités JcE correspondants.",
    DF_TOOLTIP_PVP = "Crée une activité JcJ et affiche les types d’activités JcJ correspondants.",
    DF_TOOLTIP_ACTIVITY_TYPE = "Choisissez le type précis d’activité. Son prérequis de niveau conseillé est appliqué automatiquement.",
    DF_TOOLTIP_LEVEL_MIN = "Niveau minimum autorisé pour s’inscrire.",
    DF_TOOLTIP_LEVEL_MAX = "Niveau maximum autorisé pour s’inscrire.",
    DF_TOOLTIP_GROUP_SIZE = "Taille finale du groupe, y compris les joueurs ayant rejoint sans passer par l’addon.",
    DF_TOOLTIP_AVAILABLE_ROLES = "Activez les rôles que les joueurs pourront choisir pour cette activité.",
    DF_TOOLTIP_CREATOR_ROLE = "Choisissez le rôle que vous occupez dans la composition de l’activité.",
    DF_TOOLTIP_APPROVAL_AUTO = "Les inscriptions valides sont acceptées automatiquement. Les joueurs acceptés sont ensuite invités automatiquement.",
    DF_TOOLTIP_APPROVAL_MANUAL = "Les inscriptions attendent la validation du responsable. Les joueurs acceptés sont ensuite invités automatiquement.",
    DF_TOOLTIP_DESCRIPTION = "Description facultative, visible dans le tooltip de l’activité.",
    DF_TOOLTIP_CREATE_CONFIRM = "Crée l’activité lorsque tous les prérequis sont remplis.",
    DF_TOOLTIP_SAVE_CONFIRM = "Enregistre les modifications de l’activité.",
    DF_TOOLTIP_CANCEL = "Ferme cette fenêtre sans enregistrer.",
    DF_TOOLTIP_ROLE_BUTTON = "Sélectionne %s comme rôle d’inscription.",
    DF_TOOLTIP_MEMBER_LIST = "Joueurs inscrits et joueurs déjà présents dans le groupe du responsable.",
    DF_TOOLTIP_PREVIOUS = "Page précédente.",
    DF_TOOLTIP_NEXT = "Page suivante.",
    DF_TOOLTIP_FULL_LABEL = "Texte complet du bouton",
    DF_OK = "Compris",
}
GMG.Locales = GMG.Locales or {en = {}, fr = {}}
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}
for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end

local function SetBackdrop(frame, background, border)
    frame:SetBackdrop(BACKDROP)
    frame:SetBackdropColor(unpack(background or PANEL))
    frame:SetBackdropBorderColor(unpack(border or BORDER))
end

local function CreateText(parent, fontObject, text, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObject or "GameFontNormal")
    if size then
        local font, _, flags = fs:GetFont()
        if font then fs:SetFont(font, size, flags) end
    end
    fs:SetText(text or "")
    fs:SetTextColor(unpack(TEXT))
    return fs
end

local function SetNoWrap(fontString)
    if not fontString then return end
    if fontString.SetWordWrap then fontString:SetWordWrap(false) end
    if fontString.SetNonSpaceWrap then fontString:SetNonSpaceWrap(false) end
end

local function SetButtonText(button, text, width)
    if not button or not button.label then return end
    text = tostring(text or "")
    button.gmgFullLabel = text
    SetNoWrap(button.label)
    if width then button.label:SetWidth(width) end
    button.label:SetText(text)
    if not width or not button.label.GetStringWidth or button.label:GetStringWidth() <= width then return end
    local shortened = text
    while string.len(shortened) > 1 do
        shortened = string.sub(shortened, 1, string.len(shortened) - 1)
        button.label:SetText(shortened .. "...")
        if button.label:GetStringWidth() <= width then return end
    end
end

local function Resolve(value, owner)
    if type(value) == "function" then return value(owner) end
    return value
end

local function AttachTooltip(frame, title, help)
    if not frame then return end
    frame.gmgTooltipTitle = title
    frame.gmgTooltipHelp = help
    if frame.gmgPolishTooltipInstalled then return end
    frame.gmgPolishTooltipInstalled = true
    if frame.EnableMouse then frame:EnableMouse(true) end
    local function OnEnter(owner)
        local resolvedTitle = Resolve(owner.gmgTooltipTitle, owner)
        local resolvedHelp = Resolve(owner.gmgTooltipHelp, owner)
        local fullLabel = owner.gmgFullLabel
        if (not resolvedTitle or resolvedTitle == "") and fullLabel and fullLabel ~= "" then resolvedTitle = fullLabel end
        if not resolvedTitle or resolvedTitle == "" then return end
        GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
        GameTooltip:AddLine(resolvedTitle, 1, 1, 1, true)
        if resolvedHelp and resolvedHelp ~= "" then GameTooltip:AddLine(resolvedHelp, 0.72, 0.74, 0.84, true) end
        GameTooltip:Show()
    end
    local function OnLeave() GameTooltip:Hide() end
    if frame.HookScript then
        frame:HookScript("OnEnter", OnEnter)
        frame:HookScript("OnLeave", OnLeave)
    else
        local oldEnter = frame:GetScript("OnEnter")
        local oldLeave = frame:GetScript("OnLeave")
        frame:SetScript("OnEnter", function(owner, ...) if oldEnter then oldEnter(owner, ...) end; OnEnter(owner) end)
        frame:SetScript("OnLeave", function(owner, ...) if oldLeave then oldLeave(owner, ...) end; OnLeave(owner) end)
    end
end

local function NormalizeRole(role)
    role = strlower(tostring(role or ""))
    if role == "tank" then return "tank" end
    if role == "heal" or role == "healer" then return "heal" end
    if role == "dps" or role == "damage" or role == "damager" then return "dps" end
    if role == "support" then return "support" end
    return nil
end

local function RoleLabel(self, role)
    local keys = {tank = "DF_ROLE_TANK", heal = "DF_ROLE_HEAL", dps = "DF_ROLE_DPS", support = "DF_ROLE_SUPPORT"}
    return self:L(keys[NormalizeRole(role)] or "DF_MEMBER_ROLE_UNKNOWN")
end

local function HasRole(activity, role)
    role = NormalizeRole(role)
    if not activity or not role then return false end
    for value in string.gmatch(tostring(activity.roles or ""), "[^,]+") do
        if NormalizeRole(value) == role then return true end
    end
    return false
end

local function FindNameKey(source, name)
    local wanted = strlower(GMG:NormalizeName(name or ""))
    for key in pairs(source or {}) do
        if strlower(GMG:NormalizeName(key or "")) == wanted then return key end
    end
    return nil
end

local function IsNameInActualGroup(self, name)
    local wanted = strlower(self:NormalizeName(name or ""))
    local groupSet = self.GetActualGroupMemberSet and self:GetActualGroupMemberSet() or {}
    for key, display in pairs(groupSet or {}) do
        if strlower(self:NormalizeName(display or key or "")) == wanted then return true end
    end
    return false
end

function GMG:GetDungeonCreateInvalidReason()
    local frame = self.dungeonCreatePopup
    if not frame then return nil end
    local title = frame.name and frame.name:GetText() or ""
    title = string.gsub(title, "^%s+", "")
    title = string.gsub(title, "%s+$", "")
    if title == "" then return self:L("DF_CREATE_BLOCKED_NAME") end

    local minimum = max(1, min(60, tonumber(frame.minLevel and frame.minLevel:GetText()) or 1))
    local maximum = max(1, min(60, tonumber(frame.maxLevel and frame.maxLevel:GetText()) or 60))
    if maximum < minimum then maximum = minimum end
    local playerLevel = max(1, min(60, tonumber(UnitLevel and UnitLevel("player")) or 1))
    if playerLevel < minimum or playerLevel > maximum then
        return self:L("DF_CREATE_BLOCKED_LEVEL", playerLevel, minimum, maximum)
    end

    local groupSize = self.GetActualGroupSize and self:GetActualGroupSize() or 1
    local slots = max(1, min(40, tonumber(frame.slots and frame.slots:GetText()) or 1))
    if slots < groupSize then return self:L("DF_CREATE_BLOCKED_GROUP_SIZE", groupSize) end

    local selectedRoles = {}
    local roleCount = 0
    for _, check in ipairs(frame.roleChecks or {}) do
        if check:GetChecked() then
            selectedRoles[check.role] = true
            roleCount = roleCount + 1
        end
    end
    if roleCount == 0 then return self:L("DF_CREATE_BLOCKED_ROLES") end
    local ownRole = NormalizeRole(frame.creatorRole)
    if not ownRole or not selectedRoles[ownRole] then return self:L("DF_CREATE_BLOCKED_OWN_ROLE") end

    local roleList = {}
    for _, check in ipairs(frame.roleChecks or {}) do if check:GetChecked() then roleList[#roleList + 1] = check.role end end
    local temporary = {
        category = frame.category == "PVP" and "PVP" or "PVE",
        slots = slots,
        roles = table.concat(roleList, ","),
        members = {},
    }
    if self.GetDungeonRoleCaps then
        local caps = self:GetDungeonRoleCaps(temporary)
        local cap
        if ownRole == "dps" or ownRole == "support" then cap = caps.flex else cap = caps[ownRole] end
        if not cap or cap <= 0 then return self:L("DF_CREATE_BLOCKED_ROLE_CAP", RoleLabel(self, ownRole)) end
    end
    return nil
end

function GMG:ShowDungeonCreateBlockedPopup(reason)
    reason = reason or self:GetDungeonCreateInvalidReason() or self:L("DF_CREATE_NOT_READY")
    if StaticPopupDialogs and StaticPopup_Show then
        StaticPopupDialogs.GMG_DF_CREATE_BLOCKED = StaticPopupDialogs.GMG_DF_CREATE_BLOCKED or {
            text = "%s",
            button1 = "OK",
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
            preferredIndex = 3,
        }
        StaticPopupDialogs.GMG_DF_CREATE_BLOCKED.text = "%s"
        StaticPopupDialogs.GMG_DF_CREATE_BLOCKED.button1 = self:L("DF_OK")
        StaticPopup_Show("GMG_DF_CREATE_BLOCKED", reason)
    else
        self:Print(reason)
    end
end

function GMG:UpdateDungeonCreateEligibility()
    local frame = self.dungeonCreatePopup
    if not frame or not frame.create then return end
    local reason = self:GetDungeonCreateInvalidReason()
    frame.gmgCreateInvalidReason = reason
    if reason then
        frame.create:SetAlpha(0.48)
        frame.create:SetBackdropColor(0.09, 0.09, 0.11, 0.96)
        frame.create:SetBackdropBorderColor(0.32, 0.32, 0.36, 1)
    else
        frame.create:SetAlpha(1)
        frame.create:SetBackdropColor(unpack(PANEL2))
        frame.create:SetBackdropBorderColor(unpack(ACCENT))
    end
end

function GMG:ApplyDungeonCreatePolishedLayout()
    local frame = self.dungeonCreatePopup
    if not frame or not frame.v175Enhanced then return end
    frame:SetWidth(700)
    frame:SetHeight(790)

    frame.title:ClearAllPoints(); frame.title:SetPoint("TOPLEFT", 24, -20)
    frame.nameLabel:ClearAllPoints(); frame.nameLabel:SetPoint("TOPLEFT", 24, -58)
    frame.nameHolder:ClearAllPoints(); frame.nameHolder:SetWidth(652); frame.nameHolder:SetPoint("TOPLEFT", 24, -82)

    if frame.descriptionLabel then frame.descriptionLabel:ClearAllPoints(); frame.descriptionLabel:SetPoint("TOPLEFT", 24, -126) end
    if frame.descriptionHolder then frame.descriptionHolder:ClearAllPoints(); frame.descriptionHolder:SetWidth(652); frame.descriptionHolder:SetHeight(66); frame.descriptionHolder:SetPoint("TOPLEFT", 24, -148) end

    frame.typeLabel:ClearAllPoints(); frame.typeLabel:SetPoint("TOPLEFT", 24, -230)
    frame.pve:ClearAllPoints(); frame.pve:SetWidth(205); frame.pve:SetPoint("TOPLEFT", 24, -254)
    frame.pvp:ClearAllPoints(); frame.pvp:SetWidth(205); frame.pvp:SetPoint("LEFT", frame.pve, "RIGHT", 14, 0)

    if frame.activityTypeLabel then frame.activityTypeLabel:ClearAllPoints(); frame.activityTypeLabel:SetPoint("TOPLEFT", 24, -302) end
    if frame.activityTypeButton then frame.activityTypeButton:ClearAllPoints(); frame.activityTypeButton:SetWidth(420); frame.activityTypeButton:SetPoint("TOPLEFT", 24, -326) end

    frame.levelLabel:ClearAllPoints(); frame.levelLabel:SetPoint("TOPLEFT", 24, -376)
    frame.minLabel:ClearAllPoints(); frame.minLabel:SetPoint("TOPLEFT", 24, -401)
    frame.minHolder:ClearAllPoints(); frame.minHolder:SetPoint("TOPLEFT", 24, -420)
    frame.maxLabel:ClearAllPoints(); frame.maxLabel:SetPoint("TOPLEFT", 174, -401)
    frame.maxHolder:ClearAllPoints(); frame.maxHolder:SetPoint("TOPLEFT", 174, -420)
    frame.slotsLabel:ClearAllPoints(); frame.slotsLabel:SetPoint("TOPLEFT", 324, -401)
    frame.slotsHolder:ClearAllPoints(); frame.slotsHolder:SetPoint("TOPLEFT", 324, -420)

    frame.rolesLabel:ClearAllPoints(); frame.rolesLabel:SetPoint("TOPLEFT", 24, -468)
    for index, check in ipairs(frame.roleChecks or {}) do
        check:ClearAllPoints(); check:SetWidth(154); check:SetPoint("TOPLEFT", 24 + (index - 1) * 162, -492)
        if check.label then SetNoWrap(check.label) end
    end

    if frame.creatorRoleLabel then frame.creatorRoleLabel:ClearAllPoints(); frame.creatorRoleLabel:SetPoint("TOPLEFT", 24, -540) end
    for index, button in ipairs(frame.creatorRoleButtons or {}) do
        button:ClearAllPoints(); button:SetWidth(154); button:SetHeight(36); button:SetPoint("TOPLEFT", 24 + (index - 1) * 162, -564)
    end

    if frame.approvalLabel then frame.approvalLabel:ClearAllPoints(); frame.approvalLabel:SetPoint("TOPLEFT", 24, -616) end
    if frame.approvalAuto then frame.approvalAuto:ClearAllPoints(); frame.approvalAuto:SetWidth(652); frame.approvalAuto:SetHeight(34); frame.approvalAuto:SetPoint("TOPLEFT", 24, -640) end
    if frame.approvalManual then frame.approvalManual:ClearAllPoints(); frame.approvalManual:SetWidth(652); frame.approvalManual:SetHeight(34); frame.approvalManual:SetPoint("TOPLEFT", 24, -680) end
    if frame.autoInvite then frame.autoInvite:Hide() end

    frame.create:ClearAllPoints(); frame.create:SetWidth(205); frame.create:SetHeight(38); frame.create:SetPoint("BOTTOMLEFT", 24, 22)
    frame.cancel:ClearAllPoints(); frame.cancel:SetWidth(205); frame.cancel:SetHeight(38); frame.cancel:SetPoint("BOTTOMRIGHT", -24, 22)

    SetButtonText(frame.pve, self:L("DF_PVE"), 185)
    SetButtonText(frame.pvp, self:L("DF_PVP"), 185)
    if frame.approvalAuto then SetButtonText(frame.approvalAuto, self:L("DF_APPROVAL_AUTO"), 626) end
    if frame.approvalManual then SetButtonText(frame.approvalManual, self:L("DF_APPROVAL_MANUAL"), 626) end
    SetButtonText(frame.create, frame.editActivityID and self:L("DF_SAVE") or self:L("DF_CREATE_CONFIRM"), 185)
    SetButtonText(frame.cancel, self:L("DF_CANCEL"), 185)

    for _, check in ipairs(frame.roleChecks or {}) do
        if check.label then
            check.gmgFullLabel = RoleLabel(self, check.role)
            SetNoWrap(check.label)
        end
    end
    for _, button in ipairs(frame.creatorRoleButtons or {}) do
        SetButtonText(button, RoleLabel(self, button.role), 112)
    end
end

function GMG:InstallDungeonCreateValidation()
    local frame = self.dungeonCreatePopup
    if not frame or frame.gmgV178ValidationInstalled then return end
    frame.gmgV178ValidationInstalled = true
    self:ApplyDungeonCreatePolishedLayout()

    local originalCreate = frame.create:GetScript("OnClick")
    frame.create:SetScript("OnClick", function(button, ...)
        GMG:UpdateDungeonCreateEligibility()
        if frame.gmgCreateInvalidReason then
            GMG:ShowDungeonCreateBlockedPopup(frame.gmgCreateInvalidReason)
            return
        end
        if originalCreate then originalCreate(button, ...) end
    end)

    local originalUpdate = frame:GetScript("OnUpdate")
    frame:SetScript("OnUpdate", function(owner, elapsed)
        if originalUpdate then originalUpdate(owner, elapsed) end
        owner.gmgValidationElapsed = (owner.gmgValidationElapsed or 0) + elapsed
        if owner.gmgValidationElapsed >= 0.15 then
            owner.gmgValidationElapsed = 0
            GMG:UpdateDungeonCreateEligibility()
        end
    end)

    AttachTooltip(frame.pve, function() return GMG:L("DF_PVE") end, function() return GMG:L("DF_TOOLTIP_PVE") end)
    AttachTooltip(frame.pvp, function() return GMG:L("DF_PVP") end, function() return GMG:L("DF_TOOLTIP_PVP") end)
    AttachTooltip(frame.activityTypeButton, function() return GMG:L("DF_ACTIVITY_SUBTYPE") end, function() return GMG:L("DF_TOOLTIP_ACTIVITY_TYPE") end)
    AttachTooltip(frame.minHolder, function() return GMG:L("DF_MIN_LEVEL") end, function() return GMG:L("DF_TOOLTIP_LEVEL_MIN") end)
    AttachTooltip(frame.maxHolder, function() return GMG:L("DF_MAX_LEVEL") end, function() return GMG:L("DF_TOOLTIP_LEVEL_MAX") end)
    AttachTooltip(frame.slotsHolder, function() return GMG:L("DF_PLACES") end, function() return GMG:L("DF_TOOLTIP_GROUP_SIZE") end)
    AttachTooltip(frame.descriptionHolder, function() return GMG:L("DF_DESCRIPTION") end, function() return GMG:L("DF_TOOLTIP_DESCRIPTION") end)
    AttachTooltip(frame.approvalAuto, function() return GMG:L("DF_APPROVAL_AUTO") end, function() return GMG:L("DF_TOOLTIP_APPROVAL_AUTO") end)
    AttachTooltip(frame.approvalManual, function() return GMG:L("DF_APPROVAL_MANUAL") end, function() return GMG:L("DF_TOOLTIP_APPROVAL_MANUAL") end)
    AttachTooltip(frame.create,
        function() return frame.editActivityID and GMG:L("DF_SAVE") or GMG:L("DF_CREATE_CONFIRM") end,
        function() return frame.gmgCreateInvalidReason or (frame.editActivityID and GMG:L("DF_TOOLTIP_SAVE_CONFIRM") or GMG:L("DF_CREATE_READY")) end)
    AttachTooltip(frame.cancel, function() return GMG:L("DF_CANCEL") end, function() return GMG:L("DF_TOOLTIP_CANCEL") end)

    for _, check in ipairs(frame.roleChecks or {}) do
        AttachTooltip(check, function(owner) return RoleLabel(GMG, owner.role) end, function() return GMG:L("DF_TOOLTIP_AVAILABLE_ROLES") end)
    end
    for _, button in ipairs(frame.creatorRoleButtons or {}) do
        AttachTooltip(button, function(owner) return RoleLabel(GMG, owner.role) end, function() return GMG:L("DF_TOOLTIP_CREATOR_ROLE") end)
    end
    self:UpdateDungeonCreateEligibility()
end

function GMG:CanChangeDungeonMemberRole(activity, target)
    if not activity then return false end
    target = self:NormalizeName(target or "")
    if target == "" then return false end
    local memberKey = FindNameKey(activity.members, target)
    local pendingKey = FindNameKey(activity.pending, target)
    if not memberKey and not pendingKey then return false end
    local me = self:GetPlayerName()
    if strlower(target) == strlower(me) then return true end
    if self:NormalizeName(activity.owner or "") ~= me then return false end
    if not self.CanManageDungeonActivity or not self:CanManageDungeonActivity(activity, true) then return false end
    return memberKey ~= nil and IsNameInActualGroup(self, target)
end

function GMG:IsDungeonRoleAvailableForChange(activity, target, role)
    role = NormalizeRole(role)
    if not activity or not role or not HasRole(activity, role) then return false end
    local memberKey = FindNameKey(activity.members, target)
    local pendingKey = FindNameKey(activity.pending, target)
    local oldRole = memberKey and NormalizeRole(activity.members[memberKey]) or pendingKey and NormalizeRole(activity.pending[pendingKey])
    if oldRole == role then return true end
    if not self.GetDungeonRoleCaps or not self.GetDungeonRoleCounts then return true end
    local caps = self:GetDungeonRoleCaps(activity)
    local counts = self:GetDungeonRoleCounts(activity)
    if oldRole == "tank" then counts.tank = max(0, (counts.tank or 0) - 1) end
    if oldRole == "heal" then counts.heal = max(0, (counts.heal or 0) - 1) end
    if oldRole == "dps" then counts.dps = max(0, (counts.dps or 0) - 1); counts.flex = max(0, (counts.flex or 0) - 1) end
    if oldRole == "support" then counts.support = max(0, (counts.support or 0) - 1); counts.flex = max(0, (counts.flex or 0) - 1) end
    if role == "dps" or role == "support" then return (counts.flex or 0) < (caps.flex or 0) end
    return (counts[role] or 0) < (caps[role] or 0)
end

function GMG:ApplyDungeonRoleChange(activityID, target, role, sender)
    local activity = self:GetDungeonActivity(activityID)
    if not activity or not self.CanManageDungeonActivity or not self:CanManageDungeonActivity(activity, true) then return false end
    target = self:NormalizeName(target or "")
    sender = self:NormalizeName(sender or "")
    role = NormalizeRole(role)
    if target == "" or sender == "" or not role then return false end

    local owner = self:NormalizeName(activity.owner or "")
    local selfRequest = strlower(sender) == strlower(target)
    local leaderRequest = strlower(sender) == strlower(owner)
    if not selfRequest and not leaderRequest then return false end
    if leaderRequest and strlower(target) ~= strlower(owner) then
        if not IsNameInActualGroup(self, target) then return false end
    end
    local memberKey = FindNameKey(activity.members, target)
    local pendingKey = FindNameKey(activity.pending, target)
    if selfRequest then
        if not memberKey and not pendingKey then return false end
    else
        if not memberKey or not IsNameInActualGroup(self, target) then return false end
    end
    if not self:IsDungeonRoleAvailableForChange(activity, target, role) then return false end

    if memberKey then activity.members[memberKey] = role elseif pendingKey then activity.pending[pendingKey] = role else return false end
    if strlower(target) == strlower(owner) then activity.ownerRole = role end
    activity.revision = (tonumber(activity.revision) or 1) + 1
    activity.updatedAt = time()
    self:StoreDungeonActivity(activity, false)
    self:BroadcastDungeonActivity(activity, "GUILD", nil, true)
    self:Print(self:L("DF_ROLE_CHANGED", target, RoleLabel(self, role)))
    self.dungeonDirty = true
    self:RefreshDungeonFinder(true)
    return true
end

function GMG:RequestDungeonRoleChange(activity, target, role)
    if not activity then return false end
    target = self:NormalizeName(target or "")
    role = NormalizeRole(role)
    if not self:CanChangeDungeonMemberRole(activity, target) then self:Print(self:L("DF_ROLE_CHANGE_DENIED")); return false end
    if not self:IsDungeonRoleAvailableForChange(activity, target, role) then self:Print(self:L("DF_ROLE_CHANGE_FULL")); return false end
    local me = self:GetPlayerName()
    if self:NormalizeName(activity.owner or "") == me then
        return self:ApplyDungeonRoleChange(activity.id, target, role, me)
    end
    if strlower(target) ~= strlower(me) then self:Print(self:L("DF_ROLE_CHANGE_DENIED")); return false end
    local function Escape(value)
        value = tostring(value or "")
        value = string.gsub(value, "%%", "%%25")
        value = string.gsub(value, "|", "%%7C")
        return value
    end
    self:QueuePacket(table.concat({"DM", self:GetGuildHash() or "", Escape(activity.id), Escape(target), Escape(role)}, "|"), "GUILD", nil, true)
    self:SendQueuedPackets(4)
    return true
end

function GMG:CreateDungeonRoleChangePopup()
    if self.dungeonRoleChangePopup then return self.dungeonRoleChangePopup end
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(430)
    frame:SetHeight(250)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    SetBackdrop(frame, BG, ACCENT)
    frame:Hide()
    self.dungeonRoleChangePopup = frame

    frame.title = CreateText(frame, "GameFontNormalLarge", self:L("DF_ROLE_CHANGE_TITLE"), 18)
    frame.title:SetPoint("TOPLEFT", 22, -18)
    frame.title:SetPoint("TOPRIGHT", -22, -18)
    frame.title:SetJustifyH("LEFT")
    frame.help = CreateText(frame, "GameFontNormalSmall", "", 11)
    frame.help:SetPoint("TOPLEFT", 22, -52)
    frame.help:SetPoint("TOPRIGHT", -22, -52)
    frame.help:SetHeight(38)
    frame.help:SetJustifyH("LEFT")
    frame.help:SetTextColor(unpack(MUTED))

    frame.buttons = {}
    local roles = {"tank", "heal", "dps", "support"}
    for index, role in ipairs(roles) do
        local button = CreateFrame("Button", nil, frame)
        button:SetWidth(188)
        button:SetHeight(42)
        local column = (index - 1) % 2
        local row = floor((index - 1) / 2)
        button:SetPoint("TOPLEFT", 22 + column * 198, -96 - row * 50)
        SetBackdrop(button, PANEL2, BORDER)
        button.role = role
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetTexture(self:GetDungeonRoleIcon(role))
        button.icon:SetWidth(24); button.icon:SetHeight(24); button.icon:SetPoint("LEFT", 9, 0)
        button.label = CreateText(button, "GameFontNormal", RoleLabel(self, role), 12)
        button.label:SetPoint("LEFT", button.icon, "RIGHT", 8, 0)
        button.label:SetPoint("RIGHT", -7, 0)
        button.label:SetJustifyH("LEFT")
        button:SetScript("OnClick", function(owner)
            if owner.gmgUnavailable then GMG:Print(GMG:L("DF_ROLE_CHANGE_FULL")); return end
            local activity = GMG:GetDungeonActivity(frame.activityID)
            if activity and GMG:RequestDungeonRoleChange(activity, frame.targetName, owner.role) then frame:Hide() end
        end)
        AttachTooltip(button, function(owner) return RoleLabel(GMG, owner.role) end, function(owner)
            return owner.gmgUnavailable and GMG:L("DF_ROLE_CHANGE_FULL") or GMG:L("DF_TOOLTIP_ROLE_BUTTON", RoleLabel(GMG, owner.role))
        end)
        frame.buttons[index] = button
    end

    frame.close = CreateFrame("Button", nil, frame)
    frame.close:SetWidth(120); frame.close:SetHeight(28); frame.close:SetPoint("BOTTOMRIGHT", -22, 18)
    SetBackdrop(frame.close, PANEL2, BORDER)
    frame.close.label = CreateText(frame.close, "GameFontNormal", self:L("DF_CANCEL"), 11)
    frame.close.label:SetPoint("CENTER")
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    AttachTooltip(frame.close, function() return GMG:L("DF_CANCEL") end, function() return GMG:L("DF_TOOLTIP_CANCEL") end)
    return frame
end

function GMG:OpenDungeonRoleChangePopup(activity, target)
    if not self:CanChangeDungeonMemberRole(activity, target) then self:Print(self:L("DF_ROLE_CHANGE_DENIED")); return end
    local frame = self:CreateDungeonRoleChangePopup()
    frame.activityID = activity.id
    frame.targetName = self:NormalizeName(target)
    frame.title:SetText(self:L("DF_ROLE_CHANGE_TITLE"))
    frame.help:SetText(self:L("DF_ROLE_CHANGE_HELP", frame.targetName))
    for _, button in ipairs(frame.buttons) do
        local available = HasRole(activity, button.role) and self:IsDungeonRoleAvailableForChange(activity, frame.targetName, button.role)
        button.gmgUnavailable = not available
        if button.icon.SetDesaturated then button.icon:SetDesaturated(not available) end
        button:SetAlpha(available and 1 or 0.42)
        SetButtonText(button, RoleLabel(self, button.role), 140)
    end
    SetButtonText(frame.close, self:L("DF_CANCEL"), 108)
    frame:Show()
end

function GMG:ApplyDungeonFinderPolishedLayout()
    local page = self.dungeonPage
    if not page then return end
    if self.mainFrame then
        self.mainFrame:SetMinResize(1180, 820)
        if self.mainFrame:GetWidth() < 1180 then self.mainFrame:SetWidth(1180) end
        if self.mainFrame:GetHeight() < 820 then self.mainFrame:SetHeight(820) end
    end
    page.listPanel:SetWidth(430)
    page.detailInfo:ClearAllPoints(); page.detailInfo:SetPoint("TOPLEFT", 18, -66); page.detailInfo:SetPoint("TOPRIGHT", -18, -66); page.detailInfo:SetHeight(82)
    if page.capacity then page.capacity:ClearAllPoints(); page.capacity:SetPoint("TOPLEFT", 18, -154); page.capacity:SetPoint("TOPRIGHT", -18, -154) end
    page.roleTitle:ClearAllPoints(); page.roleTitle:SetPoint("TOPLEFT", 18, -180)
    for index, button in ipairs(page.roleButtons or {}) do
        local column = (index - 1) % 2
        local row = floor((index - 1) / 2)
        button:ClearAllPoints(); button:SetWidth(150); button:SetHeight(34); button:SetPoint("TOPLEFT", 18 + column * 162, -204 - row * 38)
    end
    page.membersTitle:ClearAllPoints(); page.membersTitle:SetPoint("TOPLEFT", 18, -286)
    for index, row in ipairs(page.memberRows or {}) do
        row:ClearAllPoints(); row:SetHeight(32); row:SetPoint("TOPLEFT", 18, -306 - (index - 1) * 36); row:SetPoint("TOPRIGHT", -18, -306 - (index - 1) * 36)
    end
    if page.memberPrev then page.memberPrev:ClearAllPoints(); page.memberPrev:SetPoint("TOPRIGHT", -120, -282) end
    if page.memberPageLabel then page.memberPageLabel:ClearAllPoints(); page.memberPageLabel:SetPoint("LEFT", page.memberPrev, "RIGHT", 5, 0) end
    if page.memberNext then page.memberNext:ClearAllPoints(); page.memberNext:SetPoint("LEFT", page.memberPageLabel, "RIGHT", 5, 0) end
    page.levelWarning:ClearAllPoints(); page.levelWarning:SetPoint("BOTTOMLEFT", 18, 58); page.levelWarning:SetPoint("BOTTOMRIGHT", -18, 58); page.levelWarning:SetHeight(26)

    if page.edit then page.edit:ClearAllPoints(); page.edit:SetWidth(110); page.edit:SetPoint("BOTTOMLEFT", 18, 20) end
    if page.applicants then page.applicants:ClearAllPoints(); page.applicants:SetWidth(125); page.applicants:SetPoint("LEFT", page.edit, "RIGHT", 8, 0) end
    if page.inviteAll then page.inviteAll:ClearAllPoints(); page.inviteAll:SetWidth(140); page.inviteAll:SetPoint("LEFT", page.applicants, "RIGHT", 8, 0) end
    if page.close then page.close:ClearAllPoints(); page.close:SetWidth(115); page.close:SetPoint("BOTTOMRIGHT", -18, 20) end
    if page.join then page.join:ClearAllPoints(); page.join:SetWidth(190); page.join:SetPoint("BOTTOMLEFT", 18, 20) end
end

function GMG:InstallDungeonFinderTooltips()
    local page = self.dungeonPage
    if not page then return end
    AttachTooltip(page.create, function() return GMG:L("DF_CREATE") end, function() return GMG:L("DF_TOOLTIP_CREATE") end)
    AttachTooltip(page.refresh, function() return GMG:L("DF_REFRESH") end, function() return GMG:L("DF_TOOLTIP_REFRESH") end)
    AttachTooltip(page.join,
        function() return page.join.gmgFullLabel or GMG:L("DF_JOIN") end,
        function()
            local activity = GMG:GetDungeonActivity(GMG.dungeonSelectedID)
            local me = GMG:GetPlayerName()
            local joined = activity and FindNameKey(activity.members, me)
            local pending = activity and FindNameKey(activity.pending, me)
            return (joined or pending) and GMG:L("DF_TOOLTIP_LEAVE") or GMG:L("DF_TOOLTIP_JOIN")
        end)
    AttachTooltip(page.edit, function() return GMG:L("DF_EDIT") end, function() return GMG:L("DF_TOOLTIP_EDIT") end)
    AttachTooltip(page.applicants, function() return page.applicants.gmgFullLabel or GMG:L("DF_APPLICANTS", 0) end, function() return GMG:L("DF_TOOLTIP_APPLICANTS") end)
    AttachTooltip(page.inviteAll, function() return GMG:L("DF_INVITE_ALL") end, function() return GMG:L("DF_TOOLTIP_INVITE") end)
    AttachTooltip(page.close, function() return GMG:L("DF_CLOSE") end, function() return GMG:L("DF_TOOLTIP_CLOSE") end)
    AttachTooltip(page.memberPrev, "<", function() return GMG:L("DF_TOOLTIP_PREVIOUS") end)
    AttachTooltip(page.memberNext, ">", function() return GMG:L("DF_TOOLTIP_NEXT") end)
    for _, button in ipairs(page.roleButtons or {}) do
        AttachTooltip(button, function(owner) return RoleLabel(GMG, owner.role) end, function(owner) return GMG:L("DF_TOOLTIP_ROLE_BUTTON", RoleLabel(GMG, owner.role)) end)
    end
end

function GMG:RefreshDungeonFinderPolish()
    local page = self.dungeonPage
    if not page then return end
    self:ApplyDungeonFinderPolishedLayout()
    self:InstallDungeonFinderTooltips()

    SetButtonText(page.create, self:L("DF_CREATE"), 154)
    SetButtonText(page.refresh, self:L("DF_REFRESH"), 100)
    if page.edit and page.edit:IsShown() then SetButtonText(page.edit, self:L("DF_EDIT"), 109) end
    if page.inviteAll and page.inviteAll:IsShown() then SetButtonText(page.inviteAll, self:L("DF_INVITE_ALL"), 144) end
    if page.close and page.close:IsShown() then SetButtonText(page.close, self:L("DF_CLOSE"), 114) end

    local activity = self:GetDungeonActivity(self.dungeonSelectedID)
    if not activity then return end
    local me = self:GetPlayerName()
    local memberKey = FindNameKey(activity.members, me)
    local pendingKey = FindNameKey(activity.pending, me)
    if page.join and page.join:IsShown() then
        local key = (memberKey and "DF_LEAVE") or (pendingKey and "DF_CANCEL_REQUEST") or "DF_JOIN"
        SetButtonText(page.join, self:L(key), 174)
    end
    if page.applicants and page.applicants:IsShown() then
        local count = 0
        for _ in pairs(activity.pending or {}) do count = count + 1 end
        SetButtonText(page.applicants, self:L("DF_APPLICANTS", count), 124)
    end
    for _, button in ipairs(page.roleButtons or {}) do if button:IsShown() then SetButtonText(button, RoleLabel(self, button.role), 112) end end

    local members = self.BuildDungeonFinderMemberList and self:BuildDungeonFinderMemberList(activity) or {}
    local perPage = #(page.memberRows or {})
    local offset = ((page.memberPage or 1) - 1) * perPage
    for index, row in ipairs(page.memberRows or {}) do
        local entry = members[offset + index]
        row.gmgMemberName = entry and entry.name or nil
        row.gmgActivityID = activity.id
        if entry then
            row:EnableMouse(true)
            local canChange = self:CanChangeDungeonMemberRole(activity, entry.name)
            row:SetBackdropBorderColor(unpack(canChange and ACCENT or BORDER))
            row.gmgTooltipTitle = entry.name .. (entry.role and (" — " .. RoleLabel(self, entry.role)) or "")
            if strlower(self:NormalizeName(entry.name)) == strlower(me) then
                row.gmgTooltipHelp = self:L("DF_ROLE_CHANGE_SELF_HINT")
            elseif canChange then
                row.gmgTooltipHelp = self:L("DF_ROLE_CHANGE_LEADER_HINT")
            else
                row.gmgTooltipHelp = self:L("DF_TOOLTIP_MEMBER_LIST")
            end
            if not row.gmgRoleClickInstalled then
                row.gmgRoleClickInstalled = true
                row:SetScript("OnMouseUp", function(owner, button)
                    if button ~= "LeftButton" or not owner.gmgMemberName then return end
                    local selected = GMG:GetDungeonActivity(owner.gmgActivityID)
                    if selected and GMG:CanChangeDungeonMemberRole(selected, owner.gmgMemberName) then
                        GMG:OpenDungeonRoleChangePopup(selected, owner.gmgMemberName)
                    end
                end)
                AttachTooltip(row, function(owner) return owner.gmgTooltipTitle end, function(owner) return owner.gmgTooltipHelp end)
            end
        else
            row.gmgMemberName = nil
        end
    end
end

local PreviousCreatePopup = GMG.CreateDungeonCreatePopup
function GMG:CreateDungeonCreatePopup(...)
    PreviousCreatePopup(self, ...)
    self:InstallDungeonCreateValidation()
    self:ApplyDungeonCreatePolishedLayout()
end

local PreviousOpenCreatePopup = GMG.OpenDungeonCreatePopup
function GMG:OpenDungeonCreatePopup(...)
    PreviousOpenCreatePopup(self, ...)
    self:InstallDungeonCreateValidation()
    self:ApplyDungeonCreatePolishedLayout()
    self:UpdateDungeonCreateEligibility()
end

local PreviousOpenEditPopup = GMG.OpenDungeonEditPopup
function GMG:OpenDungeonEditPopup(activity, ...)
    PreviousOpenEditPopup(self, activity, ...)
    self:InstallDungeonCreateValidation()
    self:ApplyDungeonCreatePolishedLayout()
    self:UpdateDungeonCreateEligibility()
end

local PreviousCreateFinderPage = GMG.CreateDungeonFinderPage
function GMG:CreateDungeonFinderPage(...)
    PreviousCreateFinderPage(self, ...)
    self:ApplyDungeonFinderPolishedLayout()
    self:InstallDungeonFinderTooltips()
end

local PreviousRefreshFinder = GMG.RefreshDungeonFinder
function GMG:RefreshDungeonFinder(force)
    PreviousRefreshFinder(self, force)
    self:RefreshDungeonFinderPolish()
end

local PreviousHandlePayload = GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload, channel, sender)
    local values = {}
    local start = 1
    while true do
        local position = string.find(payload or "", "|", start, true)
        if not position then values[#values + 1] = string.sub(payload or "", start); break end
        values[#values + 1] = string.sub(payload, start, position - 1)
        start = position + 1
    end
    if values[1] ~= "DM" then return PreviousHandlePayload(self, payload, channel, sender) end
    if values[2] ~= self:GetGuildHash() then return end
    sender = self:NormalizeName(sender or "")
    if sender == "" or sender == self:GetPlayerName() or not self:IsGuildMemberName(sender) then return end
    local function Unescape(value)
        value = tostring(value or "")
        value = string.gsub(value, "%%7C", "|")
        value = string.gsub(value, "%%25", "%%")
        return value
    end
    self:ApplyDungeonRoleChange(Unescape(values[3]), self:NormalizeName(Unescape(values[4])), NormalizeRole(Unescape(values[5])), sender)
end

local PreviousRefreshLocalization = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    PreviousRefreshLocalization(self, ...)
    local frame = self.dungeonCreatePopup
    if frame then
        self:ApplyDungeonCreatePolishedLayout()
        self:UpdateDungeonCreateEligibility()
    end
    local rolePopup = self.dungeonRoleChangePopup
    if rolePopup then
        rolePopup.title:SetText(self:L("DF_ROLE_CHANGE_TITLE"))
        if rolePopup.targetName then rolePopup.help:SetText(self:L("DF_ROLE_CHANGE_HELP", rolePopup.targetName)) end
        for _, button in ipairs(rolePopup.buttons or {}) do SetButtonText(button, RoleLabel(self, button.role), 140) end
        SetButtonText(rolePopup.close, self:L("DF_CANCEL"), 108)
    end
    self:RefreshDungeonFinderPolish()
end

-- Additional localized tooltip explanations for manual applicant management.
GMG.Locales.en.DF_TOOLTIP_ACCEPT_APPLICANT = "Accept this registration. The player is then invited automatically when a place is available."
GMG.Locales.en.DF_TOOLTIP_REJECT_APPLICANT = "Reject and remove this pending registration."
GMG.Locales.fr.DF_TOOLTIP_ACCEPT_APPLICANT = "Accepte cette inscription. Le joueur est ensuite invité automatiquement lorsqu’une place est disponible."
GMG.Locales.fr.DF_TOOLTIP_REJECT_APPLICANT = "Refuse et retire cette inscription en attente."

function GMG:InstallDungeonApplicantTooltips()
    local frame = self.dungeonApplicantPopup
    if not frame then return end
    AttachTooltip(frame.prev, "<", function() return GMG:L("DF_TOOLTIP_PREVIOUS") end)
    AttachTooltip(frame.next, ">", function() return GMG:L("DF_TOOLTIP_NEXT") end)
    AttachTooltip(frame.close, function() return GMG:L("DF_CANCEL") end, function() return GMG:L("DF_TOOLTIP_CANCEL") end)
    SetButtonText(frame.close, self:L("DF_CANCEL"), 116)
    for _, row in ipairs(frame.rows or {}) do
        AttachTooltip(row.accept, function() return GMG:L("DF_ACCEPT") end, function() return GMG:L("DF_TOOLTIP_ACCEPT_APPLICANT") end)
        AttachTooltip(row.reject, function() return GMG:L("DF_REJECT") end, function() return GMG:L("DF_TOOLTIP_REJECT_APPLICANT") end)
        SetButtonText(row.accept, self:L("DF_ACCEPT"), 82)
        SetButtonText(row.reject, self:L("DF_REJECT"), 82)
    end
end

local PreviousCreateApplicantPopupV178 = GMG.CreateDungeonApplicantPopup
function GMG:CreateDungeonApplicantPopup(...)
    PreviousCreateApplicantPopupV178(self, ...)
    self:InstallDungeonApplicantTooltips()
end

local PreviousRefreshApplicantPopupV178 = GMG.RefreshDungeonApplicantPopup
function GMG:RefreshDungeonApplicantPopup(...)
    PreviousRefreshApplicantPopupV178(self, ...)
    self:InstallDungeonApplicantTooltips()
end

function GMG:InstallGenericGMGButtonTooltips(root)
    if not root or not root.GetChildren then return end
    local children = {root:GetChildren()}
    for _, child in ipairs(children) do
        if child and child.GetObjectType and child:GetObjectType() == "Button" and child.label then
            local full = nil
            if child.localeKey then full = self:L(child.localeKey) end
            if (not full or full == "") and child.labelKey then full = self:L(child.labelKey) end
            if not full or full == "" then full = child.gmgFullLabel or child.label:GetText() or "" end
            child.gmgFullLabel = full
            if not child.gmgPolishTooltipInstalled then
                AttachTooltip(child, function(owner) return owner.gmgFullLabel or (owner.label and owner.label:GetText()) or "" end, nil)
            end
        end
        self:InstallGenericGMGButtonTooltips(child)
    end
end

local PreviousCreateUIV178 = GMG.CreateUI
function GMG:CreateUI(...)
    PreviousCreateUIV178(self, ...)
    self:InstallGenericGMGButtonTooltips(self.mainFrame)
    self:RefreshDungeonFinderPolish()
end

local PreviousRefreshLocalizationV178Generic = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    PreviousRefreshLocalizationV178Generic(self, ...)
    self:InstallGenericGMGButtonTooltips(self.mainFrame)
    self:InstallDungeonApplicantTooltips()
    self:RefreshDungeonFinderPolish()
end
