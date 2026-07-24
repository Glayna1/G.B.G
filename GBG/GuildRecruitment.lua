-- G.B.G (Glayna Better Guild)
-- Cross-guild recruitment, guild search and persistent applications.

GlaynaBetterGuild = GlaynaBetterGuild or GlaynasMidnightGuild or {}
GlaynasMidnightGuild = GlaynaBetterGuild
local GMG = GlaynaBetterGuild

local max = math.max
local min = math.min
local floor = math.floor
local sort = table.sort
local time = time
local tostring = tostring
local tonumber = tonumber
local strlower = string.lower
local format = string.format

GMG.Locales = GMG.Locales or { en = {}, fr = {} }
GMG.Locales.en = GMG.Locales.en or {}
GMG.Locales.fr = GMG.Locales.fr or {}

local EN = {
    GUILD_SEARCH_TAB = "Guild Search",
    GUILD_SEARCH_TITLE = "Find a guild",
    GUILD_SEARCH_INTRO = "Browse recruiting guilds using G.B.G, read their goals and apply directly.",
    GUILD_SEARCH_REFRESH = "Refresh guilds",
    GUILD_SEARCH_EMPTY = "No recruiting guild has been detected yet. Guild advertisements appear when at least one of their G.B.G users is online.",
    GUILD_SEARCH_OBJECTIVE = "Goal",
    GUILD_SEARCH_MEMBERS = "%d members • %d online",
    GUILD_SEARCH_LEVELS = "Recommended levels: %d–%d",
    GUILD_SEARCH_DESCRIPTION = "Guild presentation",
    GUILD_SEARCH_BANNER = "Guild banner",
    GUILD_SEARCH_APPLY_MESSAGE = "Application message",
    GUILD_SEARCH_APPLY_PLACEHOLDER = "Introduce yourself, explain what you play and what you are looking for...",
    GUILD_SEARCH_APPLY = "Apply",
    GUILD_SEARCH_REAPPLY = "Apply again",
    GUILD_SEARCH_UPDATE_APPLICATION = "Update application",
    GUILD_SEARCH_ALREADY_GUILDED = "You must leave your current guild before applying to another guild.",
    GUILD_SEARCH_SELECT = "Select a guild to view its full recruitment advertisement.",
    GUILD_SEARCH_STATUS = "Application status",
    GUILD_SEARCH_STATUS_NONE = "No application sent to this guild.",
    GUILD_SEARCH_STATUS_PENDING = "Pending review",
    GUILD_SEARCH_STATUS_ACCEPTED = "Accepted — waiting for the guild invitation or for you to join",
    GUILD_SEARCH_STATUS_DECLINED = "Declined",
    GUILD_SEARCH_STATUS_JOINED = "Joined",
    GUILD_SEARCH_DECLINE_REASON = "Reason: %s",
    GUILD_SEARCH_SENT = "Your application was sent to %s.",
    GUILD_SEARCH_UPDATED = "Your application to %s was updated.",
    GUILD_SEARCH_MESSAGE_REQUIRED = "Write a short application message before applying.",
    GUILD_SEARCH_DISCOVERY_SENT = "Guild discovery request sent.",
    GUILD_SEARCH_PVE = "PvE",
    GUILD_SEARCH_PVP = "PvP",
    GUILD_SEARCH_MIXED = "PvE & PvP",
    GUILD_SEARCH_ALL = "All",
    GUILD_SEARCH_FILTER_HELP = "Filter the guild list by recruitment goal.",
    GUILD_SEARCH_STALE = "This guild advertisement is temporarily offline. Your application status is still preserved.",

    PENDING_TAB = "Pending",
    PENDING_TITLE = "Pending applications",
    PENDING_INTRO = "Review applicants, read their message and invite or decline them. Accepted applications remain here until the player actually joins the guild.",
    PENDING_EMPTY = "There are currently no pending or accepted applications.",
    PENDING_APPLICATION = "Application",
    PENDING_PROFILE = "Applicant profile",
    PENDING_LEVEL_CLASS = "Level %d • %s",
    PENDING_APPLIED_AT = "Applied: %s",
    PENDING_LAST_SEEN = "Last addon contact: %s",
    PENDING_ONLINE_NOW = "Online through G.B.G now",
    PENDING_OFFLINE = "Not currently detected through G.B.G",
    PENDING_ACCEPT = "Accept and invite",
    PENDING_DECLINE = "Decline",
    PENDING_RETRY = "Retry invitation",
    PENDING_ACCEPTED_WAITING = "Accepted — invitation/join pending",
    PENDING_PENDING = "Waiting for review",
    PENDING_JOINED = "The player has joined the guild.",
    PENDING_DECLINED = "Application declined.",
    PENDING_ACCEPTED_NOTICE = "%s's application was accepted. It will remain pending until the player joins the guild.",
    PENDING_INVITE_RETRIED = "A guild invitation was sent again to %s.",
    PENDING_DECLINE_TITLE = "Decline %s's application",
    PENDING_DECLINE_HELP = "Enter the reason that the applicant will be able to read.",
    PENDING_DECLINE_PLACEHOLDER = "Reason for refusal...",
    PENDING_CONFIRM_DECLINE = "Confirm refusal",
    PENDING_CANCEL = "Cancel",
    PENDING_REASON_DEFAULT = "The guild decided not to accept this application.",
    PENDING_SETTINGS = "Recruitment settings",
    PENDING_MODE_MANUAL = "Manual review",
    PENDING_MODE_AUTO = "Automatic invitation",
    PENDING_MODE_LABEL = "Application handling: %s",
    PENDING_PERMISSION = "Only members with guild-invite permission can access this page.",
    PENDING_INVITE_FAILED_KEEP = "The application was kept because the player has not joined the guild yet.",

    RECRUIT_SETTINGS_TITLE = "Guild recruitment settings",
    RECRUIT_SETTINGS_INTRO = "Publish your guild in the G.B.G guild search and choose how applications are handled.",
    RECRUIT_SETTINGS_ENABLED = "Recruitment advertisement enabled",
    RECRUIT_SETTINGS_DISABLED = "Recruitment advertisement disabled",
    RECRUIT_SETTINGS_OBJECTIVE = "Main guild goal",
    RECRUIT_SETTINGS_LEVELS = "Recommended level range",
    RECRUIT_SETTINGS_DESCRIPTION = "Guild presentation and objectives",
    RECRUIT_SETTINGS_DESCRIPTION_PLACEHOLDER = "Describe your guild, schedule, atmosphere, PvE/PvP goals and what kind of members you are looking for...",
    RECRUIT_SETTINGS_MODE = "Application handling",
    RECRUIT_SETTINGS_MODE_MANUAL = "Manual: officers review each application",
    RECRUIT_SETTINGS_MODE_AUTO = "Automatic: invite every applicant",
    RECRUIT_SETTINGS_AUTO_WARNING = "Automatic mode immediately marks new applications as accepted and keeps retrying the invitation whenever the applicant is detected online. The application is never removed until the player really joins or is refused.",
    RECRUIT_SETTINGS_SAVE = "Save and publish",
    RECRUIT_SETTINGS_CLOSE = "Close",
    RECRUIT_SETTINGS_SAVED = "Guild recruitment settings saved.",
    RECRUIT_SETTINGS_BANNER_HELP = "The official G.B.G guild banner is displayed in the guild search. Publish a banner from the banner creator to update it.",
    RECRUIT_SETTINGS_NO_BANNER = "No official banner published",
    RECRUIT_SETTINGS_DESCRIPTION_REQUIRED = "Add a guild presentation before publishing recruitment.",
    RECRUIT_SETTINGS_LEVEL_ERROR = "The minimum level cannot be higher than the maximum level.",

    RECRUIT_POPUP_TITLE = "Guild recruitment",
    RECRUIT_APPLICATION_RECEIVED = "New application from %s for %s.",
    RECRUIT_APPLICATION_ACCEPTED = "Your application to %s was accepted. The guild will keep trying to invite you until you join.",
    RECRUIT_APPLICATION_DECLINED = "Your application to %s was declined. Reason: %s",
    RECRUIT_APPLICATION_JOINED = "Your application to %s is complete: you joined the guild.",
    RECRUIT_CHANNEL_HELP = "G.B.G uses a hidden shared channel to discover guilds and exchange applications between addon users. Encoded traffic is removed from normal chat windows.",
    RECRUIT_BANNER_TOOLTIP = "Official guild banner published through G.B.G.",
    RECRUIT_PROFILE_TOOLTIP = "Profile portrait selected by the applicant in G.B.G.",
    RECRUIT_AUTO_TOOLTIP = "Automatically accepts every new application and retries the guild invite while the applicant is online. Records remain until the player actually joins.",
    RECRUIT_MANUAL_TOOLTIP = "Applications wait for an authorized guild member to accept or refuse them.",
    GUILD_SEARCH_REFRESH_HELP = "Asks online G.B.G users to resend their current guild recruitment advertisements.",
    GUILD_SEARCH_APPLY_HELP = "Sends your character name, level, class, selected G.B.G profile portrait and application message to the guild.",
    PENDING_SETTINGS_HELP = "Configure the public guild advertisement and choose manual or automatic application handling.",
    PENDING_ACCEPT_HELP = "Accepts the application, immediately tries a guild invitation and keeps retrying until the player actually joins.",
    PENDING_DECLINE_HELP_TOOLTIP = "Declines the application and lets you write a reason that the applicant can read.",
    PENDING_RETRY_HELP = "Sends another guild invitation without removing the application if the player is offline or cannot be invited yet.",
    RECRUIT_SETTINGS_SAVE_HELP = "Saves the advertisement, shares it inside the guild and publishes it to guildless G.B.G users.",
}

local FR = {
    GUILD_SEARCH_TAB = "Recherche de guilde",
    GUILD_SEARCH_TITLE = "Rechercher une guilde",
    GUILD_SEARCH_INTRO = "Consultez les guildes qui recrutent avec G.B.G, découvrez leurs objectifs et postulez directement.",
    GUILD_SEARCH_REFRESH = "Actualiser les guildes",
    GUILD_SEARCH_EMPTY = "Aucune guilde en recrutement n’a encore été détectée. Les annonces apparaissent lorsqu’au moins un de leurs utilisateurs de G.B.G est connecté.",
    GUILD_SEARCH_OBJECTIVE = "Objectif",
    GUILD_SEARCH_MEMBERS = "%d membres • %d en ligne",
    GUILD_SEARCH_LEVELS = "Niveaux conseillés : %d–%d",
    GUILD_SEARCH_DESCRIPTION = "Présentation de la guilde",
    GUILD_SEARCH_BANNER = "Bannière de guilde",
    GUILD_SEARCH_APPLY_MESSAGE = "Message de candidature",
    GUILD_SEARCH_APPLY_PLACEHOLDER = "Présentez-vous, expliquez ce que vous jouez et ce que vous recherchez...",
    GUILD_SEARCH_APPLY = "Postuler",
    GUILD_SEARCH_REAPPLY = "Postuler à nouveau",
    GUILD_SEARCH_UPDATE_APPLICATION = "Modifier la candidature",
    GUILD_SEARCH_ALREADY_GUILDED = "Vous devez quitter votre guilde actuelle avant de pouvoir postuler dans une autre guilde.",
    GUILD_SEARCH_SELECT = "Sélectionnez une guilde pour consulter son annonce complète.",
    GUILD_SEARCH_STATUS = "État de la candidature",
    GUILD_SEARCH_STATUS_NONE = "Aucune candidature envoyée à cette guilde.",
    GUILD_SEARCH_STATUS_PENDING = "En attente de validation",
    GUILD_SEARCH_STATUS_ACCEPTED = "Acceptée — en attente de l’invitation ou de votre arrivée dans la guilde",
    GUILD_SEARCH_STATUS_DECLINED = "Refusée",
    GUILD_SEARCH_STATUS_JOINED = "Guilde rejointe",
    GUILD_SEARCH_DECLINE_REASON = "Raison : %s",
    GUILD_SEARCH_SENT = "Votre candidature a été envoyée à %s.",
    GUILD_SEARCH_UPDATED = "Votre candidature auprès de %s a été mise à jour.",
    GUILD_SEARCH_MESSAGE_REQUIRED = "Écrivez un court message de candidature avant de postuler.",
    GUILD_SEARCH_DISCOVERY_SENT = "Demande d’actualisation des guildes envoyée.",
    GUILD_SEARCH_PVE = "JcE",
    GUILD_SEARCH_PVP = "JcJ",
    GUILD_SEARCH_MIXED = "JcE & JcJ",
    GUILD_SEARCH_ALL = "Toutes",
    GUILD_SEARCH_FILTER_HELP = "Filtre la liste des guildes selon leur objectif de recrutement.",
    GUILD_SEARCH_STALE = "L’annonce de cette guilde est temporairement hors ligne. L’état de votre candidature reste conservé.",

    PENDING_TAB = "En attente",
    PENDING_TITLE = "Candidatures en attente",
    PENDING_INTRO = "Consultez les candidats, leur message et leur profil, puis acceptez-les ou refusez-les. Une candidature acceptée reste ici jusqu’à ce que le joueur rejoigne réellement la guilde.",
    PENDING_EMPTY = "Aucune candidature en attente ou acceptée pour le moment.",
    PENDING_APPLICATION = "Candidature",
    PENDING_PROFILE = "Profil du candidat",
    PENDING_LEVEL_CLASS = "Niveau %d • %s",
    PENDING_APPLIED_AT = "Candidature : %s",
    PENDING_LAST_SEEN = "Dernier contact addon : %s",
    PENDING_ONLINE_NOW = "Actuellement détecté en ligne par G.B.G",
    PENDING_OFFLINE = "Non détecté actuellement par G.B.G",
    PENDING_ACCEPT = "Accepter et inviter",
    PENDING_DECLINE = "Refuser",
    PENDING_RETRY = "Renvoyer l’invitation",
    PENDING_ACCEPTED_WAITING = "Accepté — invitation/arrivée en attente",
    PENDING_PENDING = "En attente de validation",
    PENDING_JOINED = "Le joueur a rejoint la guilde.",
    PENDING_DECLINED = "Candidature refusée.",
    PENDING_ACCEPTED_NOTICE = "La candidature de %s a été acceptée. Elle restera en attente jusqu’à son arrivée réelle dans la guilde.",
    PENDING_INVITE_RETRIED = "Une invitation de guilde a de nouveau été envoyée à %s.",
    PENDING_DECLINE_TITLE = "Refuser la candidature de %s",
    PENDING_DECLINE_HELP = "Indiquez la raison que le joueur pourra consulter.",
    PENDING_DECLINE_PLACEHOLDER = "Raison du refus...",
    PENDING_CONFIRM_DECLINE = "Confirmer le refus",
    PENDING_CANCEL = "Annuler",
    PENDING_REASON_DEFAULT = "La guilde a décidé de ne pas retenir cette candidature.",
    PENDING_SETTINGS = "Paramètres du recrutement",
    PENDING_MODE_MANUAL = "Validation manuelle",
    PENDING_MODE_AUTO = "Invitation automatique",
    PENDING_MODE_LABEL = "Gestion des candidatures : %s",
    PENDING_PERMISSION = "Seuls les membres possédant le droit d’inviter dans la guilde peuvent accéder à cette page.",
    PENDING_INVITE_FAILED_KEEP = "La candidature a été conservée car le joueur n’a pas encore rejoint la guilde.",

    RECRUIT_SETTINGS_TITLE = "Paramètres de recrutement de la guilde",
    RECRUIT_SETTINGS_INTRO = "Publiez votre guilde dans la recherche G.B.G et choisissez comment les candidatures sont traitées.",
    RECRUIT_SETTINGS_ENABLED = "Annonce de recrutement activée",
    RECRUIT_SETTINGS_DISABLED = "Annonce de recrutement désactivée",
    RECRUIT_SETTINGS_OBJECTIVE = "Objectif principal de la guilde",
    RECRUIT_SETTINGS_LEVELS = "Tranche de niveaux conseillée",
    RECRUIT_SETTINGS_DESCRIPTION = "Présentation et objectifs de la guilde",
    RECRUIT_SETTINGS_DESCRIPTION_PLACEHOLDER = "Décrivez votre guilde, vos horaires, votre ambiance, vos objectifs JcE/JcJ et les membres que vous recherchez...",
    RECRUIT_SETTINGS_MODE = "Gestion des candidatures",
    RECRUIT_SETTINGS_MODE_MANUAL = "Manuelle : les responsables valident chaque candidature",
    RECRUIT_SETTINGS_MODE_AUTO = "Automatique : inviter toutes les personnes qui postulent",
    RECRUIT_SETTINGS_AUTO_WARNING = "Le mode automatique accepte immédiatement chaque nouvelle candidature et retente l’invitation dès que le candidat est détecté en ligne. La candidature n’est jamais supprimée tant que le joueur n’a pas réellement rejoint la guilde ou qu’il n’a pas été refusé.",
    RECRUIT_SETTINGS_SAVE = "Enregistrer et publier",
    RECRUIT_SETTINGS_CLOSE = "Fermer",
    RECRUIT_SETTINGS_SAVED = "Les paramètres de recrutement de la guilde ont été enregistrés.",
    RECRUIT_SETTINGS_BANNER_HELP = "La bannière officielle de la guilde créée dans G.B.G est affichée dans la recherche. Publiez une bannière depuis le créateur pour la mettre à jour.",
    RECRUIT_SETTINGS_NO_BANNER = "Aucune bannière officielle publiée",
    RECRUIT_SETTINGS_DESCRIPTION_REQUIRED = "Ajoutez une présentation de la guilde avant d’activer le recrutement.",
    RECRUIT_SETTINGS_LEVEL_ERROR = "Le niveau minimum ne peut pas être supérieur au niveau maximum.",

    RECRUIT_POPUP_TITLE = "Recrutement de guilde",
    RECRUIT_APPLICATION_RECEIVED = "Nouvelle candidature de %s pour %s.",
    RECRUIT_APPLICATION_ACCEPTED = "Votre candidature auprès de %s a été acceptée. La guilde continuera de tenter de vous inviter jusqu’à votre arrivée.",
    RECRUIT_APPLICATION_DECLINED = "Votre candidature auprès de %s a été refusée. Raison : %s",
    RECRUIT_APPLICATION_JOINED = "Votre candidature auprès de %s est terminée : vous avez rejoint la guilde.",
    RECRUIT_CHANNEL_HELP = "G.B.G utilise un canal partagé masqué pour découvrir les guildes et échanger les candidatures entre utilisateurs de l’addon. Les données encodées sont retirées des fenêtres de discussion normales.",
    RECRUIT_BANNER_TOOLTIP = "Bannière officielle publiée par la guilde dans G.B.G.",
    RECRUIT_PROFILE_TOOLTIP = "Portrait de profil choisi par le candidat dans G.B.G.",
    RECRUIT_AUTO_TOOLTIP = "Accepte automatiquement toutes les nouvelles candidatures et retente l’invitation tant que le candidat est en ligne. La candidature reste conservée jusqu’à son arrivée réelle.",
    RECRUIT_MANUAL_TOOLTIP = "Les candidatures attendent qu’un membre autorisé de la guilde les accepte ou les refuse.",
    GUILD_SEARCH_REFRESH_HELP = "Demande aux utilisateurs de G.B.G connectés de renvoyer les annonces de recrutement actuelles de leur guilde.",
    GUILD_SEARCH_APPLY_HELP = "Envoie à la guilde votre pseudo, niveau, classe, portrait de profil G.B.G et message de candidature.",
    PENDING_SETTINGS_HELP = "Configure l’annonce publique de la guilde et choisit la validation manuelle ou automatique des candidatures.",
    PENDING_ACCEPT_HELP = "Accepte la candidature, tente immédiatement l’invitation et continue de réessayer jusqu’à l’arrivée réelle du joueur.",
    PENDING_DECLINE_HELP_TOOLTIP = "Refuse la candidature et permet d’écrire une raison que le candidat pourra consulter.",
    PENDING_RETRY_HELP = "Renvoie une invitation sans supprimer la candidature si le joueur est hors ligne ou ne peut pas encore être invité.",
    RECRUIT_SETTINGS_SAVE_HELP = "Enregistre l’annonce, la partage dans la guilde et la publie auprès des joueurs sans guilde utilisant G.B.G.",
}

for key, value in pairs(EN) do GMG.Locales.en[key] = value end
for key, value in pairs(FR) do GMG.Locales.fr[key] = value end

-- Expand About with the cross-guild recruitment system.
GMG.Locales.en.ABOUT_FEATURES = tostring(GMG.Locales.en.ABOUT_FEATURES or "") .. "\n- Cross-guild search for guildless players with official banners, goals, member counts and direct applications.\n- Persistent applicant queue with shared profile portraits, messages, class/level details, manual refusal reasons and automatic or manual invitations that remain pending until the player actually joins."
GMG.Locales.fr.ABOUT_FEATURES = tostring(GMG.Locales.fr.ABOUT_FEATURES or "") .. "\n- Recherche inter-guildes pour les joueurs sans guilde avec bannières officielles, objectifs, nombre de membres et candidature directe.\n- File de candidatures persistante avec portraits de profil, messages, classe/niveau, raisons de refus consultables et invitations automatiques ou manuelles conservées jusqu’à l’arrivée réelle du joueur."
GMG.Locales.en.ABOUT_SYNC = "Guild-only data remains exchanged inside the guild. Guild advertisements and applications use a hidden G.B.G recruitment channel shared by addon users on the same faction and realm. Personal notes and local preferences remain private."
GMG.Locales.fr.ABOUT_SYNC = "Les données internes restent échangées uniquement dans la guilde. Les annonces et candidatures utilisent un canal de recrutement G.B.G masqué, partagé entre les utilisateurs de l’addon de la même faction et du même royaume. Les notes personnelles et préférences locales restent privées."

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
}
local PANEL = {0.025, 0.030, 0.050, 0.98}
local PANEL_2 = {0.040, 0.047, 0.075, 0.98}
local PANEL_3 = {0.060, 0.067, 0.100, 0.98}
local BORDER = {0.18, 0.17, 0.30, 1}
local ACCENT = {0.58, 0.34, 0.94, 1}
local ACCENT_SOFT = {0.20, 0.10, 0.34, 0.96}
local TEXT = {0.88, 0.87, 0.94, 1}
local MUTED = {0.54, 0.56, 0.66, 1}
local GREEN = {0.27, 0.92, 0.48, 1}
local RED = {0.95, 0.34, 0.38, 1}
local GOLD = {0.95, 0.75, 0.30, 1}

local function SetBackdrop(frame, color, border)
    frame:SetBackdrop(BACKDROP)
    frame:SetBackdropColor(unpack(color or PANEL))
    frame:SetBackdropBorderColor(unpack(border or BORDER))
end

local function Text(parent, fontObject, value, size)
    local object = parent:CreateFontString(nil, "ARTWORK", fontObject or "GameFontNormal")
    object:SetText(value or "")
    if size and object.SetFont then
        local path, _, flags = object:GetFont()
        if path then object:SetFont(path, size, flags) end
    end
    object:SetTextColor(unpack(TEXT))
    return object
end

local function Button(parent, label, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 180)
    button:SetHeight(height or 34)
    SetBackdrop(button, PANEL_2, BORDER)
    button.label = Text(button, "GameFontNormal", label or "", 11)
    button.label:SetPoint("LEFT", 8, 0)
    button.label:SetPoint("RIGHT", -8, 0)
    button.label:SetPoint("CENTER", 0, 0)
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

local function AttachTooltip(button, titleKey, textKey)
    if not button then return end
    local oldEnter = button:GetScript("OnEnter")
    local oldLeave = button:GetScript("OnLeave")
    button:SetScript("OnEnter", function(self)
        if oldEnter then oldEnter(self) end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(GMG:L(titleKey), 1, 1, 1)
        if textKey then GameTooltip:AddLine(GMG:L(textKey), 0.75, 0.78, 0.88, true) end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        if oldLeave then oldLeave(self) end
        GameTooltip:Hide()
    end)
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

local function SetButtonEnabledVisual(button, enabled)
    if not button then return end
    button.visualEnabled = enabled and true or false
    button:SetAlpha(enabled and 1 or 0.42)
end

local function Trim(value)
    value = tostring(value or "")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

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

local function Split(value)
    local result = {}
    local start = 1
    value = tostring(value or "")
    while true do
        local found = string.find(value, "|", start, true)
        if not found then
            result[#result + 1] = string.sub(value, start)
            break
        end
        result[#result + 1] = string.sub(value, start, found - 1)
        start = found + 1
    end
    return result
end

local function Clamp(value, low, high, fallback)
    value = tonumber(value)
    if not value then value = fallback end
    return max(low, min(high, value or low))
end

local function FormatDate(stamp)
    stamp = tonumber(stamp) or 0
    if stamp <= 0 then return "—" end
    return date("%d/%m/%Y %H:%M", stamp)
end

local function CurrentPlayerFullName()
    local name, realm = UnitName and UnitName("player") or nil, nil
    if UnitName then name, realm = UnitName("player") end
    if not name then return "" end
    if realm and realm ~= "" then return name .. "-" .. realm end
    return name
end

local function ObjectiveLabel(self, objective)
    if objective == "pve" then return self:L("GUILD_SEARCH_PVE") end
    if objective == "pvp" then return self:L("GUILD_SEARCH_PVP") end
    return self:L("GUILD_SEARCH_MIXED")
end

function GMG:EnsureRecruitmentData()
    if not self.db then return nil end
    self.db.account = self.db.account or {}
    self.db.account.recruitment = self.db.account.recruitment or {}
    local data = self.db.account.recruitment
    data.knownGuilds = data.knownGuilds or {}
    data.myApplications = data.myApplications or {}
    return data
end

function GMG:GetRecruitmentGuildStore(create)
    local store = self:GetGuildStore(create and true or false)
    if not store then return nil end
    if create and type(store.recruitment) ~= "table" then store.recruitment = {} end
    local recruitment = store.recruitment
    if not recruitment then return nil end
    recruitment.enabled = recruitment.enabled and true or false
    recruitment.objective = recruitment.objective or "mixed"
    recruitment.mode = recruitment.mode == "auto" and "auto" or "manual"
    recruitment.minLevel = Clamp(recruitment.minLevel, 1, 60, 1)
    recruitment.maxLevel = Clamp(recruitment.maxLevel, 1, 60, 60)
    recruitment.description = tostring(recruitment.description or "")
    recruitment.revision = tonumber(recruitment.revision) or 1
    recruitment.updatedAt = tonumber(recruitment.updatedAt) or 0
    recruitment.applications = recruitment.applications or {}
    return recruitment
end

function GMG:CanManageGuildRecruitment()
    if not self:IsInGuild() then return false end
    if CanGuildInvite and not CanGuildInvite() then return false end
    return GuildInvite ~= nil
end

function GMG:GetRecruitmentMemberCounts()
    local total, online = 0, 0
    if GetNumGuildMembers then
        local a, b = GetNumGuildMembers()
        total = tonumber(a) or 0
        online = tonumber(b) or 0
    end
    if total <= 0 then
        for _, member in ipairs(self.rosterMembers or {}) do
            total = total + 1
            if member.online then online = online + 1 end
        end
    elseif online <= 0 then
        for _, member in ipairs(self.rosterMembers or {}) do if member.online then online = online + 1 end end
    end
    return total, online
end

function GMG:GetOwnRecruitmentAdvertisement()
    if not self:IsInGuild() then return nil end
    local recruitment = self:GetRecruitmentGuildStore(false)
    if not recruitment then return nil end
    local guildName = self:GetGuildName() or (GetGuildInfo and GetGuildInfo("player")) or ""
    if guildName == "" then return nil end
    local total, online = self:GetRecruitmentMemberCounts()
    local bannerRecord = self.GetGuildBannerRecord and self:GetGuildBannerRecord() or nil
    local bannerEncoded = ""
    if bannerRecord and bannerRecord.config and self.EncodeBannerConfig then
        bannerEncoded = self:EncodeBannerConfig(bannerRecord.config)
    end
    local guildImage = self.GetGuildImageTexture and self:GetGuildImageTexture() or self.DEFAULT_GUILD_IMAGE
    return {
        guildKey = self:GetGuildHash() or self:Hash((GetRealmName and GetRealmName() or "") .. ":" .. guildName),
        guildName = guildName,
        enabled = recruitment.enabled,
        objective = recruitment.objective,
        mode = recruitment.mode,
        minLevel = recruitment.minLevel,
        maxLevel = recruitment.maxLevel,
        description = recruitment.description,
        revision = recruitment.revision,
        updatedAt = recruitment.updatedAt,
        totalMembers = total,
        onlineMembers = online,
        bannerEncoded = bannerEncoded,
        guildImage = guildImage,
        publisher = self:GetPlayerName(),
        lastSeen = time(),
    }
end

function GMG:StoreKnownRecruitmentGuild(ad)
    if type(ad) ~= "table" or not ad.guildKey or ad.guildKey == "" then return false end
    local data = self:EnsureRecruitmentData()
    if not data then return false end
    if not ad.enabled then
        data.knownGuilds[ad.guildKey] = nil
        if self.guildSearchSelectedKey == ad.guildKey then self.guildSearchSelectedKey = nil end
        return true
    end
    local current = data.knownGuilds[ad.guildKey]
    local incomingRevision = tonumber(ad.revision) or 0
    local currentRevision = current and tonumber(current.revision) or 0
    if current and incomingRevision < currentRevision then
        current.lastSeen = time()
        return false
    end
    ad.lastSeen = time()
    ad.totalMembers = tonumber(ad.totalMembers) or 0
    ad.onlineMembers = tonumber(ad.onlineMembers) or 0
    ad.minLevel = Clamp(ad.minLevel, 1, 60, 1)
    ad.maxLevel = Clamp(ad.maxLevel, 1, 60, 60)
    ad.objective = (ad.objective == "pve" or ad.objective == "pvp") and ad.objective or "mixed"
    ad.mode = ad.mode == "auto" and "auto" or "manual"
    if ad.bannerEncoded and ad.bannerEncoded ~= "" and self.DecodeBannerConfig then
        ad.bannerConfig = self:DecodeBannerConfig(ad.bannerEncoded)
    end
    if self.NormalizeMediaTexturePath then ad.guildImage = self:NormalizeMediaTexturePath(ad.guildImage) end
    data.knownGuilds[ad.guildKey] = ad
    return true
end

function GMG:GetMyRecruitmentApplications()
    local data = self:EnsureRecruitmentData()
    return data and data.myApplications or {}
end

function GMG:GetGuildRecruitmentApplications()
    local recruitment = self:GetRecruitmentGuildStore(true)
    return recruitment and recruitment.applications or {}
end

function GMG:GetApplicationID(guildKey)
    local realm = GetRealmName and GetRealmName() or "UnknownRealm"
    return self:Hash(tostring(realm) .. ":" .. tostring(guildKey or "") .. ":" .. strlower(self:GetPlayerName() or ""))
end

function GMG:BuildApplicantProfile(message)
    local character = self:GetCharacterStore(true)
    local className, classFile = "", ""
    if UnitClass then className, classFile = UnitClass("player") end
    local avatar = character and character.avatar or self.DEFAULT_AVATAR
    if self.NormalizeMediaTexturePath then avatar = self:NormalizeMediaTexturePath(avatar) end
    return {
        name = self:GetPlayerName(),
        fullName = CurrentPlayerFullName(),
        level = Clamp(UnitLevel and UnitLevel("player") or 1, 1, 60, 1),
        className = className or "",
        classFile = classFile or "",
        avatar = avatar or self.DEFAULT_AVATAR,
        message = Trim(message),
    }
end

-- --------------------------------------------------------------------------
-- Hidden cross-guild channel transport
-- --------------------------------------------------------------------------
GMG.recruitmentChannelName = "GBGRecruit"
GMG.recruitmentWirePrefix = "GBGR1"

function GMG:HideRecruitmentChannelFromChat()
    if not ChatFrame_RemoveChannel then return end
    for index = 1, 10 do
        local frame = _G["ChatFrame" .. index]
        if frame then pcall(ChatFrame_RemoveChannel, frame, self.recruitmentChannelName) end
    end
end

function GMG:JoinRecruitmentChannel()
    if JoinPermanentChannel then pcall(JoinPermanentChannel, self.recruitmentChannelName) end
    if GetChannelName then
        local id = GetChannelName(self.recruitmentChannelName)
        if type(id) == "number" and id > 0 then self.recruitmentChannelID = id end
    end
    self:HideRecruitmentChannelFromChat()
    return self.recruitmentChannelID
end

function GMG:QueueRecruitmentRaw(text, priority)
    if not text or text == "" then return end
    self.recruitmentSendQueue = self.recruitmentSendQueue or {}
    if priority then table.insert(self.recruitmentSendQueue, 1, text) else table.insert(self.recruitmentSendQueue, text) end
end

function GMG:QueueRecruitmentPacket(payload, priority)
    payload = tostring(payload or "")
    if payload == "" then return end
    local header = self.recruitmentWirePrefix .. "|"
    if string.len(header .. payload) <= 240 then
        self:QueueRecruitmentRaw(header .. payload, priority)
        return
    end
    self.recruitmentPacketSerial = (self.recruitmentPacketSerial or 0) + 1
    local packetID = self:Hash(self:GetPlayerName() .. ":" .. tostring(time()) .. ":" .. tostring(self.recruitmentPacketSerial) .. ":" .. tostring(GetTime and GetTime() or 0))
    local chunkSize = 165
    local total = math.ceil(string.len(payload) / chunkSize)
    if total > 30 then return end
    for index = 1, total do
        local chunk = string.sub(payload, (index - 1) * chunkSize + 1, index * chunkSize)
        self:QueueRecruitmentRaw(header .. table.concat({"F", packetID, tostring(index), tostring(total), chunk}, "|"), priority and index == 1)
    end
end

function GMG:SendRecruitmentQueue()
    if not self.recruitmentSendQueue or #self.recruitmentSendQueue == 0 then return end
    local channelID = self.recruitmentChannelID or self:JoinRecruitmentChannel()
    if not channelID or channelID <= 0 or not SendChatMessage then return end
    local text = table.remove(self.recruitmentSendQueue, 1)
    pcall(SendChatMessage, text, "CHANNEL", nil, channelID)
end

function GMG:HandleRecruitmentFragment(sender, packetID, index, total, chunk)
    index = tonumber(index) or 0
    total = tonumber(total) or 0
    if packetID == "" or index < 1 or total < 1 or index > total or total > 30 then return end
    self.recruitmentFragments = self.recruitmentFragments or {}
    local key = strlower(self:NormalizeName(sender)) .. ":" .. packetID
    local record = self.recruitmentFragments[key]
    if not record then
        record = {parts = {}, count = 0, total = total, at = time(), sender = sender}
        self.recruitmentFragments[key] = record
    end
    if record.total ~= total then self.recruitmentFragments[key] = nil; return end
    if not record.parts[index] then record.parts[index] = chunk; record.count = record.count + 1 end
    if record.count >= total then
        local values = {}
        for part = 1, total do if not record.parts[part] then return else values[#values + 1] = record.parts[part] end end
        self.recruitmentFragments[key] = nil
        self:HandleRecruitmentPayload(table.concat(values), sender)
    end
end

function GMG:BuildRecruitmentAdvertisementPayload(ad)
    return table.concat({
        "AD", Escape(ad.guildKey), tostring(ad.revision or 0), ad.enabled and "1" or "0",
        Escape(ad.guildName), Escape(ad.objective), Escape(ad.mode), tostring(ad.minLevel or 1), tostring(ad.maxLevel or 60),
        tostring(ad.totalMembers or 0), tostring(ad.onlineMembers or 0), Escape(ad.description),
        Escape(ad.bannerEncoded), Escape(ad.guildImage), tostring(ad.updatedAt or 0), Escape(ad.publisher), tostring(self.version or "")
    }, "|")
end

function GMG:BroadcastRecruitmentAdvertisement(priority)
    local ad = self:GetOwnRecruitmentAdvertisement()
    if not ad then return end
    self:QueueRecruitmentPacket(self:BuildRecruitmentAdvertisementPayload(ad), priority)
end

function GMG:BuildCrossApplicationPayload(record)
    return table.concat({
        "AP", Escape(record.guildKey), Escape(record.guildName), Escape(record.id), tostring(record.profileRevision or 1),
        Escape(record.name), Escape(record.fullName), tostring(record.level or 1), Escape(record.className), Escape(record.classFile),
        Escape(record.avatar), Escape(record.message), tostring(record.appliedAt or time()), tostring(time()), tostring(self.version or "")
    }, "|")
end

function GMG:BroadcastMyApplication(record, priority)
    if not record or (record.status ~= "pending" and record.status ~= "accepted") then return end
    record.lastSentAt = time()
    self:QueueRecruitmentPacket(self:BuildCrossApplicationPayload(record), priority)
end

function GMG:BuildApplicationResponsePayload(record)
    return table.concat({
        "RS", Escape(record.guildKey), Escape(record.guildName), Escape(record.id), tostring(record.statusRevision or 1),
        Escape(record.name), Escape(record.status), Escape(record.reason), tostring(record.updatedAt or time()), Escape(record.acceptedBy)
    }, "|")
end

function GMG:BroadcastApplicationResponse(record, priority)
    if not record then return end
    self:QueueRecruitmentPacket(self:BuildApplicationResponsePayload(record), priority)
end

function GMG:RequestRecruitmentAdvertisements()
    self:QueueRecruitmentPacket(table.concat({"RQ", Escape(self:GetPlayerName()), tostring(self.version or "")}, "|"), true)
    if self.Print then self:Print(self:L("GUILD_SEARCH_DISCOVERY_SENT")) end
end

function GMG:StoreIncomingGuildApplication(incoming, sender)
    if not self:IsInGuild() or incoming.guildKey ~= (self:GetGuildHash() or "") then return false end
    local applications = self:GetGuildRecruitmentApplications()
    local record = applications[incoming.id]
    local isNew = not record
    if not record then
        record = {
            id = incoming.id, guildKey = incoming.guildKey, guildName = incoming.guildName,
            status = "pending", reason = "", statusRevision = 1, acceptedBy = "", lastInviteAt = 0,
        }
        applications[incoming.id] = record
    end
    local incomingRevision = tonumber(incoming.profileRevision) or 1
    local currentRevision = tonumber(record.profileRevision) or 0
    if incomingRevision >= currentRevision then
        local wasDeclined = record.status == "declined"
        record.profileRevision = incomingRevision
        record.name = self:NormalizeName(incoming.name)
        record.fullName = incoming.fullName
        record.level = Clamp(incoming.level, 1, 60, 1)
        record.className = incoming.className
        record.classFile = incoming.classFile
        record.avatar = self.NormalizeMediaTexturePath and self:NormalizeMediaTexturePath(incoming.avatar) or incoming.avatar
        record.message = incoming.message
        record.appliedAt = tonumber(incoming.appliedAt) or time()
        record.lastSeen = time()
        record.source = self:NormalizeName(sender)
        if wasDeclined and incomingRevision > currentRevision then
            record.status = "pending"
            record.reason = ""
            record.statusRevision = (tonumber(record.statusRevision) or 0) + 1
            record.updatedAt = time()
        end
    else
        record.lastSeen = time()
    end
    self:QueueGuildRecruitmentApplication(record, true)
    if isNew and self.ShowToast then self:ShowToast(self:L("RECRUIT_APPLICATION_RECEIVED", record.name, self:GetGuildName() or ""), "highlight") end
    local recruitment = self:GetRecruitmentGuildStore(true)
    if recruitment.mode == "auto" and record.status == "pending" and self:CanManageGuildRecruitment() then
        self:AcceptGuildApplication(record.id, true)
    elseif record.status == "accepted" and self:CanManageGuildRecruitment() then
        self:TryInviteAcceptedApplicant(record, false)
    end
    if self.RefreshPendingApplicationsPage then self:RefreshPendingApplicationsPage() end
    return true
end

function GMG:HandleRecruitmentPayload(payload, sender)
    local values = Split(payload)
    local command = values[1]
    sender = self:NormalizeName(sender)
    if sender == self:GetPlayerName() then return end

    if command == "AD" then
        local ad = {
            guildKey = Unescape(values[2]), revision = tonumber(values[3]) or 0, enabled = values[4] == "1",
            guildName = Unescape(values[5]), objective = Unescape(values[6]), mode = Unescape(values[7]),
            minLevel = values[8], maxLevel = values[9], totalMembers = values[10], onlineMembers = values[11],
            description = Unescape(values[12]), bannerEncoded = Unescape(values[13]), guildImage = Unescape(values[14]),
            updatedAt = tonumber(values[15]) or 0, publisher = Unescape(values[16]), remoteVersion = values[17],
        }
        if ad.guildName ~= "" and ad.guildKey ~= "" then self:StoreKnownRecruitmentGuild(ad) end
        if self.CheckRemoteAddonVersion then self:CheckRemoteAddonVersion(ad.remoteVersion, sender) end
        if self.RefreshGuildSearchPage then self:RefreshGuildSearchPage() end
        return
    end

    if command == "RQ" then
        if self:IsInGuild() then self:BroadcastRecruitmentAdvertisement(true) end
        if self.CheckRemoteAddonVersion then self:CheckRemoteAddonVersion(values[3], sender) end
        return
    end

    if command == "AP" then
        local incoming = {
            guildKey = Unescape(values[2]), guildName = Unescape(values[3]), id = Unescape(values[4]), profileRevision = values[5],
            name = Unescape(values[6]), fullName = Unescape(values[7]), level = values[8], className = Unescape(values[9]),
            classFile = Unescape(values[10]), avatar = Unescape(values[11]), message = Unescape(values[12]),
            appliedAt = values[13], lastSeen = values[14], remoteVersion = values[15],
        }
        if self.CheckRemoteAddonVersion then self:CheckRemoteAddonVersion(incoming.remoteVersion, sender) end
        self:StoreIncomingGuildApplication(incoming, sender)
        return
    end

    if command == "RS" then
        local guildKey = Unescape(values[2])
        local guildName = Unescape(values[3])
        local appID = Unescape(values[4])
        local revision = tonumber(values[5]) or 0
        local applicant = self:NormalizeName(Unescape(values[6]))
        local status = Unescape(values[7])
        local reason = Unescape(values[8])
        local updatedAt = tonumber(values[9]) or time()
        local acceptedBy = Unescape(values[10])
        if strlower(applicant) ~= strlower(self:GetPlayerName()) then return end
        local applications = self:GetMyRecruitmentApplications()
        local record = applications[appID]
        if not record then
            record = {id = appID, guildKey = guildKey, guildName = guildName, profileRevision = 1}
            applications[appID] = record
        end
        if revision >= (tonumber(record.statusRevision) or 0) then
            local oldStatus = record.status
            record.statusRevision = revision
            record.status = status
            record.reason = reason
            record.updatedAt = updatedAt
            record.acceptedBy = acceptedBy
            record.guildName = guildName ~= "" and guildName or record.guildName
            if oldStatus ~= status then
                if status == "accepted" then self:ShowRecruitmentNotice(self:L("RECRUIT_APPLICATION_ACCEPTED", record.guildName or guildName))
                elseif status == "declined" then self:ShowRecruitmentNotice(self:L("RECRUIT_APPLICATION_DECLINED", record.guildName or guildName, reason ~= "" and reason or self:L("PENDING_REASON_DEFAULT")))
                elseif status == "joined" then self:ShowRecruitmentNotice(self:L("RECRUIT_APPLICATION_JOINED", record.guildName or guildName)) end
            end
        end
        if self.RefreshGuildSearchPage then self:RefreshGuildSearchPage() end
        return
    end

    if command == "JN" then
        local guildKey = Unescape(values[2])
        local appID = Unescape(values[3])
        local applicant = self:NormalizeName(Unescape(values[4]))
        if self:IsInGuild() and guildKey == (self:GetGuildHash() or "") then
            local record = self:GetGuildRecruitmentApplications()[appID]
            if record and strlower(record.name or "") == strlower(applicant) then
                record.status = "joined"
                record.statusRevision = (tonumber(record.statusRevision) or 0) + 1
                record.updatedAt = time()
                self:QueueGuildRecruitmentApplication(record, true)
                self:BroadcastApplicationResponse(record, true)
            end
        end
        return
    end
end

function GMG:CHAT_MSG_CHANNEL(message, sender, ...)
    local prefix = self.recruitmentWirePrefix .. "|"
    if string.sub(tostring(message or ""), 1, string.len(prefix)) ~= prefix then return end
    local payload = string.sub(message, string.len(prefix) + 1)
    if string.sub(payload, 1, 2) == "F|" then
        local packetID, index, total, chunk = string.match(payload, "^F|([^|]+)|(%d+)|(%d+)|(.*)$")
        if packetID then self:HandleRecruitmentFragment(sender, packetID, index, total, chunk) end
    else
        self:HandleRecruitmentPayload(payload, sender)
    end
end

function GMG:ShowRecruitmentNotice(message)
    StaticPopupDialogs = StaticPopupDialogs or {}
    if not StaticPopupDialogs.GBG_RECRUIT_NOTICE then
        StaticPopupDialogs.GBG_RECRUIT_NOTICE = {
            text = "%s", button1 = OKAY or "OK", timeout = 0, whileDead = 1, hideOnEscape = 1, preferredIndex = 3,
        }
    end
    StaticPopup_Show("GBG_RECRUIT_NOTICE", tostring(message or ""))
end

-- --------------------------------------------------------------------------
-- Internal guild synchronization
-- --------------------------------------------------------------------------
function GMG:BuildGuildRecruitmentStatePayload()
    local recruitment = self:GetRecruitmentGuildStore(false)
    if not recruitment then return nil end
    return table.concat({
        "GR", self:GetGuildHash() or "", tostring(recruitment.revision or 1), recruitment.enabled and "1" or "0",
        Escape(recruitment.objective), Escape(recruitment.mode), tostring(recruitment.minLevel or 1), tostring(recruitment.maxLevel or 60),
        Escape(recruitment.description), tostring(recruitment.updatedAt or 0), Escape(recruitment.updatedBy or "")
    }, "|")
end

function GMG:QueueGuildRecruitmentState(priority, channel, target)
    local payload = self:BuildGuildRecruitmentStatePayload()
    if payload then self:QueuePacket(payload, channel or "GUILD", target, priority) end
end

function GMG:BuildGuildApplicationPayload(record)
    return table.concat({
        "GA", self:GetGuildHash() or "", Escape(record.id), tostring(record.profileRevision or 1), tostring(record.statusRevision or 1),
        Escape(record.name), Escape(record.fullName), tostring(record.level or 1), Escape(record.className), Escape(record.classFile),
        Escape(record.avatar), Escape(record.message), Escape(record.status), Escape(record.reason), tostring(record.appliedAt or 0),
        tostring(record.lastSeen or 0), tostring(record.updatedAt or 0), Escape(record.acceptedBy), tostring(record.lastInviteAt or 0)
    }, "|")
end

function GMG:QueueGuildRecruitmentApplication(record, priority, channel, target)
    if record then self:QueuePacket(self:BuildGuildApplicationPayload(record), channel or "GUILD", target, priority) end
end

function GMG:HandleGuildRecruitmentState(values, sender)
    if values[2] ~= (self:GetGuildHash() or "") then return end
    if not self:IsGuildMemberName(sender) then return end
    local recruitment = self:GetRecruitmentGuildStore(true)
    local revision = tonumber(values[3]) or 0
    if revision < (tonumber(recruitment.revision) or 0) then return end
    recruitment.revision = revision
    recruitment.enabled = values[4] == "1"
    recruitment.objective = Unescape(values[5])
    recruitment.mode = Unescape(values[6]) == "auto" and "auto" or "manual"
    recruitment.minLevel = Clamp(values[7], 1, 60, 1)
    recruitment.maxLevel = Clamp(values[8], 1, 60, 60)
    recruitment.description = Unescape(values[9])
    recruitment.updatedAt = tonumber(values[10]) or 0
    recruitment.updatedBy = Unescape(values[11])
    if self.RefreshPendingApplicationsPage then self:RefreshPendingApplicationsPage() end
end

function GMG:HandleGuildApplicationState(values, sender)
    if values[2] ~= (self:GetGuildHash() or "") then return end
    if not self:IsGuildMemberName(sender) then return end
    local applications = self:GetGuildRecruitmentApplications()
    local id = Unescape(values[3])
    if id == "" then return end
    local incomingProfileRevision = tonumber(values[4]) or 1
    local incomingStatusRevision = tonumber(values[5]) or 1
    local record = applications[id]
    if not record then record = {id = id}; applications[id] = record end
    if incomingProfileRevision >= (tonumber(record.profileRevision) or 0) then
        record.guildKey = self:GetGuildHash() or ""
        record.guildName = self:GetGuildName() or (GetGuildInfo and GetGuildInfo("player")) or ""
        record.profileRevision = incomingProfileRevision
        record.name = self:NormalizeName(Unescape(values[6]))
        record.fullName = Unescape(values[7])
        record.level = Clamp(values[8], 1, 60, 1)
        record.className = Unescape(values[9])
        record.classFile = Unescape(values[10])
        record.avatar = self.NormalizeMediaTexturePath and self:NormalizeMediaTexturePath(Unescape(values[11])) or Unescape(values[11])
        record.message = Unescape(values[12])
        record.appliedAt = tonumber(values[15]) or 0
        record.lastSeen = max(tonumber(record.lastSeen) or 0, tonumber(values[16]) or 0)
    end
    if incomingStatusRevision >= (tonumber(record.statusRevision) or 0) then
        record.statusRevision = incomingStatusRevision
        record.status = Unescape(values[13])
        record.reason = Unescape(values[14])
        record.updatedAt = tonumber(values[17]) or 0
        record.acceptedBy = Unescape(values[18])
        record.lastInviteAt = tonumber(values[19]) or 0
    end
    if self.RefreshPendingApplicationsPage then self:RefreshPendingApplicationsPage() end
end

local PreviousHandleCompletePayload = GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload, channel, sender)
    local values = Split(payload)
    if values[1] == "GR" then self:HandleGuildRecruitmentState(values, self:NormalizeName(sender)); return end
    if values[1] == "GA" then self:HandleGuildApplicationState(values, self:NormalizeName(sender)); return end
    PreviousHandleCompletePayload(self, payload, channel, sender)
end

local PreviousSyncTick = GMG.SyncTick
function GMG:SyncTick(initial)
    PreviousSyncTick(self, initial)
    if not self:IsInGuild() then return end
    local now = time()
    if initial or now - (self.lastRecruitmentGuildSync or 0) >= 20 then
        self.lastRecruitmentGuildSync = now
        self:QueueGuildRecruitmentState(false)
        local sent = 0
        for _, record in pairs(self:GetGuildRecruitmentApplications()) do
            if record.status == "pending" or record.status == "accepted" then
                self:QueueGuildRecruitmentApplication(record, false)
                sent = sent + 1
                if sent >= 12 then break end
            end
        end
    end
end

-- --------------------------------------------------------------------------
-- Application decisions and reliable invitation retry
-- --------------------------------------------------------------------------
function GMG:TryInviteAcceptedApplicant(record, force)
    if not record or record.status ~= "accepted" or not self:CanManageGuildRecruitment() then return false end
    local now = time()
    if not force and now - (tonumber(record.lastInviteAt) or 0) < 30 then return false end
    if not force and now - (tonumber(record.lastSeen) or 0) > 100 then return false end
    if not record.name or record.name == "" then return false end
    GuildInvite(record.fullName ~= "" and record.fullName or record.name)
    record.lastInviteAt = now
    record.updatedAt = now
    self:QueueGuildRecruitmentApplication(record, true)
    self:BroadcastApplicationResponse(record, true)
    return true
end

function GMG:AcceptGuildApplication(appID, automatic)
    if not self:CanManageGuildRecruitment() then return false end
    local record = self:GetGuildRecruitmentApplications()[appID]
    if not record or record.status == "joined" or record.status == "declined" then return false end
    if record.status ~= "accepted" then
        record.status = "accepted"
        record.reason = ""
        record.statusRevision = (tonumber(record.statusRevision) or 0) + 1
        record.acceptedBy = self:GetPlayerName()
        record.updatedAt = time()
    end
    self:QueueGuildRecruitmentApplication(record, true)
    self:BroadcastApplicationResponse(record, true)
    self:TryInviteAcceptedApplicant(record, true)
    if self.Print then self:Print(self:L("PENDING_ACCEPTED_NOTICE", record.name or "")) end
    if self.RefreshPendingApplicationsPage then self:RefreshPendingApplicationsPage() end
    return true
end

function GMG:DeclineGuildApplication(appID, reason)
    if not self:CanManageGuildRecruitment() then return false end
    local record = self:GetGuildRecruitmentApplications()[appID]
    if not record then return false end
    reason = Trim(reason)
    if reason == "" then reason = self:L("PENDING_REASON_DEFAULT") end
    record.status = "declined"
    record.reason = reason
    record.statusRevision = (tonumber(record.statusRevision) or 0) + 1
    record.updatedAt = time()
    record.acceptedBy = self:GetPlayerName()
    self:QueueGuildRecruitmentApplication(record, true)
    self:BroadcastApplicationResponse(record, true)
    if self.RefreshPendingApplicationsPage then self:RefreshPendingApplicationsPage() end
    return true
end

function GMG:IsApplicantNowGuildMember(record)
    if not record or not record.name then return false end
    return self:IsGuildMemberName(record.name)
end

function GMG:UpdateJoinedApplications()
    if not self:IsInGuild() then return end
    for _, record in pairs(self:GetGuildRecruitmentApplications()) do
        if (record.status == "accepted" or record.status == "pending") and self:IsApplicantNowGuildMember(record) then
            record.status = "joined"
            record.statusRevision = (tonumber(record.statusRevision) or 0) + 1
            record.updatedAt = time()
            self:QueueGuildRecruitmentApplication(record, true)
            self:BroadcastApplicationResponse(record, true)
        end
    end
end

function GMG:CheckOwnApplicationJoinedGuild()
    if not self:IsInGuild() then return end
    local currentGuild = self:GetGuildName() or (GetGuildInfo and GetGuildInfo("player")) or ""
    if currentGuild == "" then return end
    for _, record in pairs(self:GetMyRecruitmentApplications()) do
        if record.status ~= "joined" and record.guildName == currentGuild then
            record.status = "joined"
            record.statusRevision = (tonumber(record.statusRevision) or 0) + 1
            record.updatedAt = time()
            self:QueueRecruitmentPacket(table.concat({"JN", Escape(record.guildKey), Escape(record.id), Escape(self:GetPlayerName())}, "|"), true)
        end
    end
end

function GMG:SubmitGuildApplication(ad, message)
    if self:IsInGuild() then self:ShowRecruitmentNotice(self:L("GUILD_SEARCH_ALREADY_GUILDED")); return false end
    if not ad or not ad.guildKey then return false end
    message = Trim(message)
    if message == "" then self:ShowRecruitmentNotice(self:L("GUILD_SEARCH_MESSAGE_REQUIRED")); return false end
    if string.len(message) > 300 then message = string.sub(message, 1, 300) end
    local profile = self:BuildApplicantProfile(message)
    local applications = self:GetMyRecruitmentApplications()
    local id = self:GetApplicationID(ad.guildKey)
    local record = applications[id]
    local isUpdate = record ~= nil
    if not record then
        record = {id = id, guildKey = ad.guildKey, guildName = ad.guildName, profileRevision = 0, statusRevision = 0}
        applications[id] = record
    end
    record.profileRevision = (tonumber(record.profileRevision) or 0) + 1
    record.name = profile.name
    record.fullName = profile.fullName
    record.level = profile.level
    record.className = profile.className
    record.classFile = profile.classFile
    record.avatar = profile.avatar
    record.message = profile.message
    record.appliedAt = time()
    record.lastSeen = time()
    record.guildName = ad.guildName
    record.objective = ad.objective
    record.bannerEncoded = ad.bannerEncoded
    record.guildImage = ad.guildImage
    record.status = "pending"
    record.reason = ""
    record.updatedAt = time()
    self:BroadcastMyApplication(record, true)
    self:ShowRecruitmentNotice(self:L(isUpdate and "GUILD_SEARCH_UPDATED" or "GUILD_SEARCH_SENT", ad.guildName or ""))
    if self.RefreshGuildSearchPage then self:RefreshGuildSearchPage() end
    return true
end

function GMG:RecruitmentTick()
    local now = time()
    if now - (self.lastRecruitmentChannelJoin or 0) >= 15 then
        self.lastRecruitmentChannelJoin = now
        self:JoinRecruitmentChannel()
    end
    if now - (self.lastRecruitmentAdBroadcast or 0) >= 45 then
        self.lastRecruitmentAdBroadcast = now
        if self:IsInGuild() then self:BroadcastRecruitmentAdvertisement(false) end
    end
    if not self:IsInGuild() and now - (self.lastRecruitmentApplicationBroadcast or 0) >= 40 then
        self.lastRecruitmentApplicationBroadcast = now
        for _, record in pairs(self:GetMyRecruitmentApplications()) do self:BroadcastMyApplication(record, false) end
    end
    if self:IsInGuild() and self:CanManageGuildRecruitment() and now - (self.lastRecruitmentInviteRetry or 0) >= 15 then
        self.lastRecruitmentInviteRetry = now
        for _, record in pairs(self:GetGuildRecruitmentApplications()) do
            if record.status == "accepted" then self:TryInviteAcceptedApplicant(record, false) end
        end
        self:UpdateJoinedApplications()
    end
    local data = self:EnsureRecruitmentData()
    if data then
        for key, ad in pairs(data.knownGuilds) do
            if now - (tonumber(ad.lastSeen) or 0) > 180 then data.knownGuilds[key] = nil end
        end
    end
    if self.recruitmentFragments then
        for key, fragment in pairs(self.recruitmentFragments) do if now - (fragment.at or now) > 45 then self.recruitmentFragments[key] = nil end end
    end
end

-- --------------------------------------------------------------------------
-- UI: Guild search
-- --------------------------------------------------------------------------
local function CreateEditBox(parent, multiline)
    local holder = CreateFrame("Frame", nil, parent)
    SetBackdrop(holder, PANEL_2, BORDER)
    local edit = CreateFrame("EditBox", nil, holder)
    edit:SetPoint("TOPLEFT", 10, -7)
    edit:SetPoint("BOTTOMRIGHT", -10, 7)
    edit:SetAutoFocus(false)
    edit:SetFontObject("ChatFontNormal")
    edit:SetTextColor(unpack(TEXT))
    edit:SetMaxLetters(multiline and 300 or 80)
    edit:SetMultiLine(multiline and true or false)
    if multiline then
        edit:SetJustifyH("LEFT")
        edit:SetJustifyV("TOP")
    end
    holder.edit = edit
    return holder, edit
end

function GMG:GetGuildSearchEntries()
    local data = self:EnsureRecruitmentData()
    local result, seen = {}, {}
    local filter = self.guildSearchFilter or "all"
    if data then
        for key, ad in pairs(data.knownGuilds) do
            if ad.enabled and (filter == "all" or ad.objective == filter or (filter == "mixed" and ad.objective == "mixed")) then
                result[#result + 1] = ad
                seen[key] = true
            end
        end
        for _, application in pairs(data.myApplications) do
            if not seen[application.guildKey] and application.guildName and application.guildName ~= "" then
                local objective = application.objective or "mixed"
                if filter == "all" or objective == filter then
                    result[#result + 1] = {
                        guildKey = application.guildKey, guildName = application.guildName, enabled = true,
                        objective = objective, minLevel = 1, maxLevel = 60, totalMembers = 0, onlineMembers = 0,
                        description = "", stale = true, lastSeen = 0, objective = objective,
                        bannerEncoded = application.bannerEncoded, guildImage = application.guildImage,
                        bannerConfig = application.bannerEncoded and self.DecodeBannerConfig and self:DecodeBannerConfig(application.bannerEncoded) or nil,
                    }
                end
            end
        end
    end
    sort(result, function(a, b)
        if (a.onlineMembers or 0) ~= (b.onlineMembers or 0) then return (a.onlineMembers or 0) > (b.onlineMembers or 0) end
        return strlower(a.guildName or "") < strlower(b.guildName or "")
    end)
    return result
end

function GMG:GetMyApplicationForGuild(guildKey)
    for _, record in pairs(self:GetMyRecruitmentApplications()) do if record.guildKey == guildKey then return record end end
    return nil
end

function GMG:ApplyGuildBannerDisplay(visual, fallback, ad)
    if visual then
        if ad and ad.bannerConfig and self.ApplyBannerToVisual then
            self:ApplyBannerToVisual(visual, ad.bannerConfig)
            visual:Show()
            if fallback then fallback:Hide() end
        else
            visual:Hide()
            if fallback then fallback:SetTexture(ad and ad.guildImage or self.DEFAULT_GUILD_IMAGE); fallback:Show() end
        end
    elseif fallback then
        fallback:SetTexture(ad and ad.guildImage or self.DEFAULT_GUILD_IMAGE)
    end
end

function GMG:CreateGuildSearchPage()
    if not self.mainFrame or self.guildSearchPage then return end
    local page = CreateFrame("Frame", nil, self.mainFrame.content)
    page:SetAllPoints()
    page:Hide()
    self.guildSearchPage = page

    page.title = Text(page, "GameFontNormalLarge", self:L("GUILD_SEARCH_TITLE"), 21)
    page.title:SetPoint("TOPLEFT", 24, -20)
    page.intro = Text(page, "GameFontNormalSmall", self:L("GUILD_SEARCH_INTRO"), 11)
    page.intro:SetPoint("TOPLEFT", 24, -52)
    page.intro:SetPoint("TOPRIGHT", -180, -52)
    page.intro:SetHeight(36)
    page.intro:SetTextColor(unpack(MUTED))
    if page.intro.SetWordWrap then page.intro:SetWordWrap(true) end
    page.refresh = Button(page, self:L("GUILD_SEARCH_REFRESH"), 145, 30)
    page.refresh:SetPoint("TOPRIGHT", -22, -18)
    page.refresh:SetScript("OnClick", function() GMG:RequestRecruitmentAdvertisements() end)
    AttachTooltip(page.refresh, "GUILD_SEARCH_REFRESH", "GUILD_SEARCH_REFRESH_HELP")

    page.filters = {}
    local defs = {{"all", "GUILD_SEARCH_ALL"}, {"pve", "GUILD_SEARCH_PVE"}, {"pvp", "GUILD_SEARCH_PVP"}, {"mixed", "GUILD_SEARCH_MIXED"}}
    for index, def in ipairs(defs) do
        local button = Button(page, self:L(def[2]), 100, 28)
        button:SetPoint("TOPLEFT", 24 + (index - 1) * 106, -88)
        button.filter = def[1]
        button:SetScript("OnClick", function(self) GMG.guildSearchFilter = self.filter; GMG.guildSearchPage.page = 1; GMG:RefreshGuildSearchPage() end)
        page.filters[index] = button
    end

    page.left = CreateFrame("Frame", nil, page)
    page.left:SetPoint("TOPLEFT", 24, -126)
    page.left:SetPoint("BOTTOMLEFT", 24, 54)
    page.left:SetWidth(400)
    SetBackdrop(page.left, PANEL, BORDER)

    page.rows = {}
    for index = 1, 5 do
        local row = CreateFrame("Button", nil, page.left)
        row:SetHeight(92)
        row:SetPoint("TOPLEFT", 10, -10 - (index - 1) * 96)
        row:SetPoint("TOPRIGHT", -10, -10 - (index - 1) * 96)
        SetBackdrop(row, PANEL_2, BORDER)
        row.banner = self.CreateBannerVisual and self:CreateBannerVisual(row, 68) or nil
        if row.banner then row.banner:SetPoint("LEFT", 8, 0) end
        row.fallback = row:CreateTexture(nil, "ARTWORK")
        row.fallback:SetWidth(68); row.fallback:SetHeight(68); row.fallback:SetPoint("LEFT", 8, 0)
        row.name = Text(row, "GameFontNormal", "", 14)
        row.name:SetPoint("TOPLEFT", 88, -12); row.name:SetPoint("TOPRIGHT", -8, -12); row.name:SetJustifyH("LEFT")
        row.objective = Text(row, "GameFontNormalSmall", "", 10)
        row.objective:SetPoint("TOPLEFT", 88, -38); row.objective:SetTextColor(unpack(ACCENT))
        row.members = Text(row, "GameFontNormalSmall", "", 10)
        row.members:SetPoint("TOPLEFT", 88, -60); row.members:SetTextColor(unpack(MUTED))
        row:SetScript("OnClick", function(self) GMG.guildSearchSelectedKey = self.guildKey; GMG:RefreshGuildSearchPage() end)
        row:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(ACCENT)) end)
        row:SetScript("OnLeave", function(self) if GMG.guildSearchSelectedKey ~= self.guildKey then self:SetBackdropBorderColor(unpack(BORDER)) end end)
        row:Hide()
        page.rows[index] = row
    end
    page.empty = Text(page.left, "GameFontNormal", self:L("GUILD_SEARCH_EMPTY"), 12)
    page.empty:SetPoint("CENTER", 0, 0); page.empty:SetWidth(340); page.empty:SetJustifyH("CENTER"); page.empty:SetTextColor(unpack(MUTED))
    page.prev = Button(page, "<", 34, 26); page.prev:SetPoint("BOTTOMLEFT", 10, 10)
    page.next = Button(page, ">", 34, 26); page.next:SetPoint("BOTTOMRIGHT", -10, 10)
    page.pageText = Text(page.left, "GameFontNormalSmall", "1 / 1", 10); page.pageText:SetPoint("BOTTOM", 0, 18)
    page.prev:SetScript("OnClick", function() page.page = max(1, (page.page or 1) - 1); GMG:RefreshGuildSearchPage() end)
    page.next:SetScript("OnClick", function() page.page = (page.page or 1) + 1; GMG:RefreshGuildSearchPage() end)

    page.right = CreateFrame("Frame", nil, page)
    page.right:SetPoint("TOPLEFT", page.left, "TOPRIGHT", 16, 0)
    page.right:SetPoint("BOTTOMRIGHT", -24, 54)
    SetBackdrop(page.right, PANEL, BORDER)
    page.bannerTitle = Text(page.right, "GameFontNormalSmall", self:L("GUILD_SEARCH_BANNER"), 10)
    page.bannerTitle:SetPoint("TOPLEFT", 18, -16); page.bannerTitle:SetTextColor(unpack(MUTED))
    page.detailBanner = self.CreateBannerVisual and self:CreateBannerVisual(page.right, 118) or nil
    if page.detailBanner then page.detailBanner:SetPoint("TOPLEFT", 18, -38) end
    page.detailFallback = page.right:CreateTexture(nil, "ARTWORK")
    page.detailFallback:SetWidth(118); page.detailFallback:SetHeight(118); page.detailFallback:SetPoint("TOPLEFT", 18, -38)
    page.guildName = Text(page.right, "GameFontNormalLarge", self:L("GUILD_SEARCH_SELECT"), 19)
    page.guildName:SetPoint("TOPLEFT", 154, -38); page.guildName:SetPoint("TOPRIGHT", -18, -38); page.guildName:SetJustifyH("LEFT")
    page.objective = Text(page.right, "GameFontNormal", "", 12); page.objective:SetPoint("TOPLEFT", 154, -72); page.objective:SetTextColor(unpack(ACCENT))
    page.members = Text(page.right, "GameFontNormalSmall", "", 11); page.members:SetPoint("TOPLEFT", 154, -98); page.members:SetTextColor(unpack(GREEN))
    page.levels = Text(page.right, "GameFontNormalSmall", "", 11); page.levels:SetPoint("TOPLEFT", 154, -122); page.levels:SetTextColor(unpack(MUTED))
    page.descriptionTitle = Text(page.right, "GameFontNormal", self:L("GUILD_SEARCH_DESCRIPTION"), 12); page.descriptionTitle:SetPoint("TOPLEFT", 18, -174)
    page.descriptionPanel = CreateFrame("Frame", nil, page.right); page.descriptionPanel:SetPoint("TOPLEFT", 18, -196); page.descriptionPanel:SetPoint("TOPRIGHT", -18, -196); page.descriptionPanel:SetHeight(98); SetBackdrop(page.descriptionPanel, PANEL_2, BORDER)
    page.description = Text(page.descriptionPanel, "GameFontNormalSmall", "", 11); page.description:SetPoint("TOPLEFT", 10, -9); page.description:SetPoint("BOTTOMRIGHT", -10, 9); page.description:SetJustifyH("LEFT"); page.description:SetJustifyV("TOP"); page.description:SetTextColor(unpack(TEXT)); if page.description.SetWordWrap then page.description:SetWordWrap(true) end
    page.messageTitle = Text(page.right, "GameFontNormal", self:L("GUILD_SEARCH_APPLY_MESSAGE"), 12); page.messageTitle:SetPoint("TOPLEFT", 18, -310)
    page.messageHolder, page.message = CreateEditBox(page.right, true); page.messageHolder:SetPoint("TOPLEFT", 18, -332); page.messageHolder:SetPoint("TOPRIGHT", -18, -332); page.messageHolder:SetHeight(108)
    page.placeholder = Text(page.messageHolder, "GameFontNormalSmall", self:L("GUILD_SEARCH_APPLY_PLACEHOLDER"), 10); page.placeholder:SetPoint("TOPLEFT", 10, -8); page.placeholder:SetPoint("RIGHT", -10, 0); page.placeholder:SetTextColor(unpack(MUTED))
    page.message:SetScript("OnTextChanged", function(self) if Trim(self:GetText()) == "" then page.placeholder:Show() else page.placeholder:Hide() end end)
    page.statusTitle = Text(page.right, "GameFontNormal", self:L("GUILD_SEARCH_STATUS"), 12); page.statusTitle:SetPoint("TOPLEFT", 18, -456)
    page.status = Text(page.right, "GameFontNormalSmall", self:L("GUILD_SEARCH_STATUS_NONE"), 11); page.status:SetPoint("TOPLEFT", 18, -478); page.status:SetPoint("TOPRIGHT", -18, -478); page.status:SetHeight(54); page.status:SetJustifyH("LEFT"); page.status:SetJustifyV("TOP"); page.status:SetTextColor(unpack(MUTED)); if page.status.SetWordWrap then page.status:SetWordWrap(true) end
    page.apply = Button(page.right, self:L("GUILD_SEARCH_APPLY"), 220, 38); page.apply:SetPoint("BOTTOM", 0, 18)
    AttachTooltip(page.apply, "GUILD_SEARCH_APPLY", "GUILD_SEARCH_APPLY_HELP")
    page.apply:SetScript("OnClick", function()
        local entries = GMG:GetGuildSearchEntries(); local selected
        for _, ad in ipairs(entries) do if ad.guildKey == GMG.guildSearchSelectedKey then selected = ad break end end
        if selected then GMG:SubmitGuildApplication(selected, page.message:GetText()) end
    end)
    page.page = 1
end

function GMG:RefreshGuildSearchPage()
    local page = self.guildSearchPage
    if not page then return end
    local entries = self:GetGuildSearchEntries()
    if not self.guildSearchSelectedKey and entries[1] then self.guildSearchSelectedKey = entries[1].guildKey end
    local perPage = #page.rows
    local maxPage = max(1, math.ceil(#entries / perPage))
    page.page = max(1, min(maxPage, tonumber(page.page) or 1))
    local offset = (page.page - 1) * perPage
    for index, row in ipairs(page.rows) do
        local ad = entries[offset + index]
        if ad then
            row.guildKey = ad.guildKey
            row.name:SetText(ad.guildName or "")
            row.objective:SetText(ObjectiveLabel(self, ad.objective))
            row.members:SetText(self:L("GUILD_SEARCH_MEMBERS", ad.totalMembers or 0, ad.onlineMembers or 0))
            self:ApplyGuildBannerDisplay(row.banner, row.fallback, ad)
            if self.guildSearchSelectedKey == ad.guildKey then row:SetBackdropColor(unpack(ACCENT_SOFT)); row:SetBackdropBorderColor(unpack(ACCENT)) else row:SetBackdropColor(unpack(PANEL_2)); row:SetBackdropBorderColor(unpack(BORDER)) end
            row:Show()
        else row.guildKey = nil; row:Hide() end
    end
    if #entries == 0 then page.empty:Show() else page.empty:Hide() end
    page.pageText:SetText(page.page .. " / " .. maxPage)
    SetButtonEnabledVisual(page.prev, page.page > 1); SetButtonEnabledVisual(page.next, page.page < maxPage)
    for _, button in ipairs(page.filters) do SetButtonSelected(button, button.filter == (self.guildSearchFilter or "all")) end

    local selected
    for _, ad in ipairs(entries) do if ad.guildKey == self.guildSearchSelectedKey then selected = ad break end end
    if selected then
        self:ApplyGuildBannerDisplay(page.detailBanner, page.detailFallback, selected)
        page.guildName:SetText(selected.guildName or "")
        page.objective:SetText(self:L("GUILD_SEARCH_OBJECTIVE") .. " : " .. ObjectiveLabel(self, selected.objective))
        page.members:SetText(self:L("GUILD_SEARCH_MEMBERS", selected.totalMembers or 0, selected.onlineMembers or 0))
        page.levels:SetText(self:L("GUILD_SEARCH_LEVELS", selected.minLevel or 1, selected.maxLevel or 60))
        page.description:SetText(selected.stale and self:L("GUILD_SEARCH_STALE") or (selected.description ~= "" and selected.description or "—"))
        local application = self:GetMyApplicationForGuild(selected.guildKey)
        if application then
            if Trim(page.message:GetText()) == "" and application.message then page.message:SetText(application.message) end
            local key = "GUILD_SEARCH_STATUS_" .. string.upper(application.status or "pending")
            local statusText = self:L(key)
            if application.status == "declined" and application.reason and application.reason ~= "" then statusText = statusText .. "\n" .. self:L("GUILD_SEARCH_DECLINE_REASON", application.reason) end
            page.status:SetText(statusText)
            if application.status == "declined" then page.status:SetTextColor(unpack(RED)); page.apply.label:SetText(self:L("GUILD_SEARCH_REAPPLY"))
            elseif application.status == "joined" then page.status:SetTextColor(unpack(GREEN)); page.apply.label:SetText(self:L("GUILD_SEARCH_UPDATE_APPLICATION"))
            else page.status:SetTextColor(unpack(GOLD)); page.apply.label:SetText(self:L("GUILD_SEARCH_UPDATE_APPLICATION")) end
        else
            page.status:SetText(self:L("GUILD_SEARCH_STATUS_NONE")); page.status:SetTextColor(unpack(MUTED)); page.apply.label:SetText(self:L("GUILD_SEARCH_APPLY"))
        end
        SetButtonEnabledVisual(page.apply, not self:IsInGuild())
    else
        self:ApplyGuildBannerDisplay(page.detailBanner, page.detailFallback, nil)
        page.guildName:SetText(self:L("GUILD_SEARCH_SELECT")); page.objective:SetText(""); page.members:SetText(""); page.levels:SetText(""); page.description:SetText(""); page.status:SetText(self:L("GUILD_SEARCH_STATUS_NONE")); SetButtonEnabledVisual(page.apply, false)
    end
end

-- --------------------------------------------------------------------------
-- UI: Pending applications, decline reason and recruitment settings
-- --------------------------------------------------------------------------
function GMG:GetVisiblePendingApplications()
    local result = {}
    if not self:IsInGuild() then return result end
    for _, record in pairs(self:GetGuildRecruitmentApplications()) do
        if record.status == "pending" or record.status == "accepted" then result[#result + 1] = record end
    end
    sort(result, function(a, b)
        if a.status ~= b.status then return a.status == "pending" end
        return (tonumber(a.appliedAt) or 0) < (tonumber(b.appliedAt) or 0)
    end)
    return result
end

function GMG:CreatePendingApplicationsPage()
    if not self.mainFrame or self.pendingApplicationsPage then return end
    local page = CreateFrame("Frame", nil, self.mainFrame.content); page:SetAllPoints(); page:Hide(); self.pendingApplicationsPage = page
    page.title = Text(page, "GameFontNormalLarge", self:L("PENDING_TITLE"), 21); page.title:SetPoint("TOPLEFT", 24, -20)
    page.intro = Text(page, "GameFontNormalSmall", self:L("PENDING_INTRO"), 11); page.intro:SetPoint("TOPLEFT", 24, -52); page.intro:SetPoint("TOPRIGHT", -230, -52); page.intro:SetHeight(42); page.intro:SetTextColor(unpack(MUTED)); if page.intro.SetWordWrap then page.intro:SetWordWrap(true) end
    page.settings = Button(page, self:L("PENDING_SETTINGS"), 190, 30); page.settings:SetPoint("TOPRIGHT", -22, -18); page.settings:SetScript("OnClick", function() GMG:OpenRecruitmentSettings() end); AttachTooltip(page.settings, "PENDING_SETTINGS", "PENDING_SETTINGS_HELP")
    page.mode = Text(page, "GameFontNormalSmall", "", 11); page.mode:SetPoint("TOPRIGHT", -22, -58); page.mode:SetTextColor(unpack(ACCENT))

    page.left = CreateFrame("Frame", nil, page); page.left:SetPoint("TOPLEFT", 24, -112); page.left:SetPoint("BOTTOMLEFT", 24, 52); page.left:SetWidth(410); SetBackdrop(page.left, PANEL, BORDER)
    page.rows = {}
    for index = 1, 6 do
        local row = CreateFrame("Button", nil, page.left); row:SetHeight(70); row:SetPoint("TOPLEFT", 10, -10 - (index - 1) * 74); row:SetPoint("TOPRIGHT", -10, -10 - (index - 1) * 74); SetBackdrop(row, PANEL_2, BORDER)
        row.portrait = row:CreateTexture(nil, "ARTWORK"); row.portrait:SetWidth(52); row.portrait:SetHeight(52); row.portrait:SetPoint("LEFT", 8, 0)
        row.name = Text(row, "GameFontNormal", "", 13); row.name:SetPoint("TOPLEFT", 72, -10); row.name:SetPoint("TOPRIGHT", -8, -10); row.name:SetJustifyH("LEFT")
        row.info = Text(row, "GameFontNormalSmall", "", 10); row.info:SetPoint("TOPLEFT", 72, -34); row.info:SetTextColor(unpack(MUTED))
        row.state = Text(row, "GameFontNormalSmall", "", 10); row.state:SetPoint("TOPRIGHT", -8, -48); row.state:SetJustifyH("RIGHT")
        row:SetScript("OnClick", function(self) GMG.pendingSelectedID = self.applicationID; GMG:RefreshPendingApplicationsPage() end)
        row:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(ACCENT)); GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(GMG:L("RECRUIT_PROFILE_TOOLTIP"), 1,1,1); GameTooltip:Show() end)
        row:SetScript("OnLeave", function(self) if GMG.pendingSelectedID ~= self.applicationID then self:SetBackdropBorderColor(unpack(BORDER)) end; GameTooltip:Hide() end)
        row:Hide(); page.rows[index] = row
    end
    page.empty = Text(page.left, "GameFontNormal", self:L("PENDING_EMPTY"), 12); page.empty:SetPoint("CENTER", 0, 0); page.empty:SetWidth(350); page.empty:SetJustifyH("CENTER"); page.empty:SetTextColor(unpack(MUTED))
    page.prev = Button(page, "<", 34, 26); page.prev:SetPoint("BOTTOMLEFT", 10, 10); page.next = Button(page, ">", 34, 26); page.next:SetPoint("BOTTOMRIGHT", -10, 10); page.pageText = Text(page.left, "GameFontNormalSmall", "1 / 1", 10); page.pageText:SetPoint("BOTTOM", 0, 18)
    page.prev:SetScript("OnClick", function() page.page = max(1, (page.page or 1) - 1); GMG:RefreshPendingApplicationsPage() end); page.next:SetScript("OnClick", function() page.page = (page.page or 1) + 1; GMG:RefreshPendingApplicationsPage() end)

    page.right = CreateFrame("Frame", nil, page); page.right:SetPoint("TOPLEFT", page.left, "TOPRIGHT", 16, 0); page.right:SetPoint("BOTTOMRIGHT", -24, 52); SetBackdrop(page.right, PANEL, BORDER)
    page.profileTitle = Text(page.right, "GameFontNormalSmall", self:L("PENDING_PROFILE"), 10); page.profileTitle:SetPoint("TOPLEFT", 18, -16); page.profileTitle:SetTextColor(unpack(MUTED))
    page.portrait = page.right:CreateTexture(nil, "ARTWORK"); page.portrait:SetWidth(116); page.portrait:SetHeight(116); page.portrait:SetPoint("TOPLEFT", 18, -38)
    page.name = Text(page.right, "GameFontNormalLarge", "", 19); page.name:SetPoint("TOPLEFT", 152, -40); page.name:SetPoint("TOPRIGHT", -18, -40); page.name:SetJustifyH("LEFT")
    page.classLevel = Text(page.right, "GameFontNormal", "", 12); page.classLevel:SetPoint("TOPLEFT", 152, -76); page.classLevel:SetTextColor(unpack(ACCENT))
    page.online = Text(page.right, "GameFontNormalSmall", "", 10); page.online:SetPoint("TOPLEFT", 152, -104)
    page.dates = Text(page.right, "GameFontNormalSmall", "", 10); page.dates:SetPoint("TOPLEFT", 152, -130); page.dates:SetPoint("TOPRIGHT", -18, -130); page.dates:SetTextColor(unpack(MUTED))
    page.messageTitle = Text(page.right, "GameFontNormal", self:L("PENDING_APPLICATION"), 12); page.messageTitle:SetPoint("TOPLEFT", 18, -174)
    page.messagePanel = CreateFrame("Frame", nil, page.right); page.messagePanel:SetPoint("TOPLEFT", 18, -198); page.messagePanel:SetPoint("TOPRIGHT", -18, -198); page.messagePanel:SetHeight(160); SetBackdrop(page.messagePanel, PANEL_2, BORDER)
    page.message = Text(page.messagePanel, "GameFontNormalSmall", "", 11); page.message:SetPoint("TOPLEFT", 10, -10); page.message:SetPoint("BOTTOMRIGHT", -10, 10); page.message:SetJustifyH("LEFT"); page.message:SetJustifyV("TOP"); if page.message.SetWordWrap then page.message:SetWordWrap(true) end
    page.status = Text(page.right, "GameFontNormal", "", 12); page.status:SetPoint("TOPLEFT", 18, -376); page.status:SetPoint("TOPRIGHT", -18, -376); page.status:SetHeight(50); page.status:SetJustifyH("LEFT"); page.status:SetJustifyV("TOP")
    page.accept = Button(page.right, self:L("PENDING_ACCEPT"), 170, 38); page.accept:SetPoint("BOTTOMLEFT", 18, 18); page.accept:SetScript("OnClick", function() if GMG.pendingSelectedID then GMG:AcceptGuildApplication(GMG.pendingSelectedID, false) end end); AttachTooltip(page.accept, "PENDING_ACCEPT", "PENDING_ACCEPT_HELP")
    page.retry = Button(page.right, self:L("PENDING_RETRY"), 170, 38); page.retry:SetPoint("BOTTOM", 0, 18); page.retry:SetScript("OnClick", function() local record = GMG:GetGuildRecruitmentApplications()[GMG.pendingSelectedID or ""]; if record and GMG:TryInviteAcceptedApplicant(record, true) then GMG:Print(GMG:L("PENDING_INVITE_RETRIED", record.name or "")) end end); AttachTooltip(page.retry, "PENDING_RETRY", "PENDING_RETRY_HELP")
    page.decline = Button(page.right, self:L("PENDING_DECLINE"), 150, 38); page.decline:SetPoint("BOTTOMRIGHT", -18, 18); page.decline:SetScript("OnClick", function() if GMG.pendingSelectedID then GMG:OpenDeclineApplicationPopup(GMG.pendingSelectedID) end end); AttachTooltip(page.decline, "PENDING_DECLINE", "PENDING_DECLINE_HELP_TOOLTIP")
    page.page = 1
end

function GMG:RefreshPendingApplicationsPage()
    local page = self.pendingApplicationsPage
    if not page then return end
    local records = self:GetVisiblePendingApplications()
    if not self.pendingSelectedID and records[1] then self.pendingSelectedID = records[1].id end
    local selectedValid = false; for _, r in ipairs(records) do if r.id == self.pendingSelectedID then selectedValid = true break end end
    if not selectedValid then self.pendingSelectedID = records[1] and records[1].id or nil end
    local perPage = #page.rows; local maxPage = max(1, math.ceil(#records / perPage)); page.page = max(1, min(maxPage, tonumber(page.page) or 1)); local offset = (page.page - 1) * perPage
    for index, row in ipairs(page.rows) do
        local record = records[offset + index]
        if record then
            row.applicationID = record.id; row.portrait:SetTexture(record.avatar or self.DEFAULT_AVATAR); row.name:SetText(record.name or ""); row.info:SetText(self:L("PENDING_LEVEL_CLASS", record.level or 1, record.className ~= "" and record.className or "?")); row.state:SetText(self:L(record.status == "accepted" and "PENDING_ACCEPTED_WAITING" or "PENDING_PENDING")); row.state:SetTextColor(unpack(record.status == "accepted" and GOLD or ACCENT))
            if self.pendingSelectedID == record.id then row:SetBackdropColor(unpack(ACCENT_SOFT)); row:SetBackdropBorderColor(unpack(ACCENT)) else row:SetBackdropColor(unpack(PANEL_2)); row:SetBackdropBorderColor(unpack(BORDER)) end
            row:Show()
        else row.applicationID = nil; row:Hide() end
    end
    if #records == 0 then page.empty:Show() else page.empty:Hide() end
    page.pageText:SetText(page.page .. " / " .. maxPage); SetButtonEnabledVisual(page.prev, page.page > 1); SetButtonEnabledVisual(page.next, page.page < maxPage)
    local recruitment = self:GetRecruitmentGuildStore(false)
    local mode = recruitment and recruitment.mode or "manual"
    page.mode:SetText(self:L("PENDING_MODE_LABEL", self:L(mode == "auto" and "PENDING_MODE_AUTO" or "PENDING_MODE_MANUAL")))
    local selected = self.pendingSelectedID and self:GetGuildRecruitmentApplications()[self.pendingSelectedID] or nil
    if selected then
        page.portrait:SetTexture(selected.avatar or self.DEFAULT_AVATAR); page.name:SetText(selected.name or ""); page.classLevel:SetText(self:L("PENDING_LEVEL_CLASS", selected.level or 1, selected.className ~= "" and selected.className or "?")); local online = time() - (tonumber(selected.lastSeen) or 0) <= 100; page.online:SetText(self:L(online and "PENDING_ONLINE_NOW" or "PENDING_OFFLINE")); page.online:SetTextColor(unpack(online and GREEN or MUTED)); page.dates:SetText(self:L("PENDING_APPLIED_AT", FormatDate(selected.appliedAt)) .. "\n" .. self:L("PENDING_LAST_SEEN", FormatDate(selected.lastSeen))); page.message:SetText(selected.message or ""); page.status:SetText(self:L(selected.status == "accepted" and "PENDING_ACCEPTED_WAITING" or "PENDING_PENDING")); page.status:SetTextColor(unpack(selected.status == "accepted" and GOLD or ACCENT)); page.accept:Show(); page.decline:Show(); if selected.status == "accepted" then page.accept:Hide(); page.retry:Show() else page.retry:Hide() end
    else
        page.portrait:SetTexture(self.DEFAULT_AVATAR); page.name:SetText(""); page.classLevel:SetText(""); page.online:SetText(""); page.dates:SetText(""); page.message:SetText(""); page.status:SetText(self:L("PENDING_EMPTY")); page.status:SetTextColor(unpack(MUTED)); page.accept:Hide(); page.retry:Hide(); page.decline:Hide()
    end
    self:RefreshPendingTabBadge()
end

function GMG:CreateDeclineApplicationPopup()
    if self.declineApplicationPopup then return self.declineApplicationPopup end
    local frame = CreateFrame("Frame", "GBGDeclineApplicationPopup", UIParent); frame:SetFrameStrata("FULLSCREEN_DIALOG"); frame:SetWidth(520); frame:SetHeight(300); frame:SetPoint("CENTER"); frame:SetClampedToScreen(true); frame:EnableMouse(true); SetBackdrop(frame, PANEL, ACCENT); frame:Hide()
    frame.title = Text(frame, "GameFontNormalLarge", "", 18); frame.title:SetPoint("TOPLEFT", 20, -18)
    frame.help = Text(frame, "GameFontNormalSmall", self:L("PENDING_DECLINE_HELP"), 11); frame.help:SetPoint("TOPLEFT", 20, -52); frame.help:SetPoint("TOPRIGHT", -20, -52); frame.help:SetTextColor(unpack(MUTED))
    frame.holder, frame.edit = CreateEditBox(frame, true); frame.holder:SetPoint("TOPLEFT", 20, -82); frame.holder:SetPoint("TOPRIGHT", -20, -82); frame.holder:SetHeight(126)
    frame.placeholder = Text(frame.holder, "GameFontNormalSmall", self:L("PENDING_DECLINE_PLACEHOLDER"), 10); frame.placeholder:SetPoint("TOPLEFT", 10, -8); frame.placeholder:SetTextColor(unpack(MUTED)); frame.edit:SetScript("OnTextChanged", function(self) if Trim(self:GetText()) == "" then frame.placeholder:Show() else frame.placeholder:Hide() end end)
    frame.confirm = Button(frame, self:L("PENDING_CONFIRM_DECLINE"), 190, 34); frame.confirm:SetPoint("BOTTOMLEFT", 20, 18); frame.confirm:SetScript("OnClick", function() if frame.applicationID then GMG:DeclineGuildApplication(frame.applicationID, frame.edit:GetText()) end; frame:Hide() end)
    frame.cancel = Button(frame, self:L("PENDING_CANCEL"), 140, 34); frame.cancel:SetPoint("BOTTOMRIGHT", -20, 18); frame.cancel:SetScript("OnClick", function() frame:Hide() end)
    if UISpecialFrames then table.insert(UISpecialFrames, "GBGDeclineApplicationPopup") end
    self.declineApplicationPopup = frame; return frame
end

function GMG:OpenDeclineApplicationPopup(appID)
    local record = self:GetGuildRecruitmentApplications()[appID]
    if not record then return end
    local frame = self:CreateDeclineApplicationPopup(); frame.applicationID = appID; frame.title:SetText(self:L("PENDING_DECLINE_TITLE", record.name or "")); frame.help:SetText(self:L("PENDING_DECLINE_HELP")); frame.edit:SetText(""); frame.placeholder:Show(); frame:Show(); frame.edit:SetFocus()
end

function GMG:CreateRecruitmentSettingsPopup()
    if self.recruitmentSettingsPopup then return self.recruitmentSettingsPopup end
    local frame = CreateFrame("Frame", "GBGRecruitmentSettingsPopup", UIParent); frame:SetFrameStrata("FULLSCREEN_DIALOG"); frame:SetWidth(760); frame:SetHeight(650); frame:SetPoint("CENTER"); frame:SetClampedToScreen(true); frame:EnableMouse(true); SetBackdrop(frame, PANEL, ACCENT); frame:Hide()
    frame.title = Text(frame, "GameFontNormalLarge", self:L("RECRUIT_SETTINGS_TITLE"), 20); frame.title:SetPoint("TOPLEFT", 22, -18)
    frame.intro = Text(frame, "GameFontNormalSmall", self:L("RECRUIT_SETTINGS_INTRO"), 11); frame.intro:SetPoint("TOPLEFT", 22, -50); frame.intro:SetPoint("TOPRIGHT", -22, -50); frame.intro:SetTextColor(unpack(MUTED))
    frame.banner = self.CreateBannerVisual and self:CreateBannerVisual(frame, 150) or nil; if frame.banner then frame.banner:SetPoint("TOPLEFT", 24, -86) end
    frame.bannerFallback = frame:CreateTexture(nil, "ARTWORK"); frame.bannerFallback:SetWidth(150); frame.bannerFallback:SetHeight(150); frame.bannerFallback:SetPoint("TOPLEFT", 24, -86)
    frame.bannerHelp = Text(frame, "GameFontNormalSmall", self:L("RECRUIT_SETTINGS_BANNER_HELP"), 10); frame.bannerHelp:SetPoint("TOPLEFT", 24, -246); frame.bannerHelp:SetWidth(150); frame.bannerHelp:SetJustifyH("CENTER"); frame.bannerHelp:SetTextColor(unpack(MUTED)); if frame.bannerHelp.SetWordWrap then frame.bannerHelp:SetWordWrap(true) end
    frame.enabled = Button(frame, self:L("RECRUIT_SETTINGS_DISABLED"), 320, 34); frame.enabled:SetPoint("TOPLEFT", 202, -88); frame.enabled:SetScript("OnClick", function() frame.draft.enabled = not frame.draft.enabled; GMG:RefreshRecruitmentSettingsPopup() end)
    frame.objectiveTitle = Text(frame, "GameFontNormal", self:L("RECRUIT_SETTINGS_OBJECTIVE"), 12); frame.objectiveTitle:SetPoint("TOPLEFT", 202, -140)
    frame.objectiveButtons = {}
    local defs = {{"pve", "GUILD_SEARCH_PVE"}, {"pvp", "GUILD_SEARCH_PVP"}, {"mixed", "GUILD_SEARCH_MIXED"}}
    for index, def in ipairs(defs) do local button = Button(frame, self:L(def[2]), 150, 32); button:SetPoint("TOPLEFT", 202 + (index - 1) * 160, -164); button.objective = def[1]; button:SetScript("OnClick", function(self) frame.draft.objective = self.objective; GMG:RefreshRecruitmentSettingsPopup() end); frame.objectiveButtons[index] = button end
    frame.levelTitle = Text(frame, "GameFontNormal", self:L("RECRUIT_SETTINGS_LEVELS"), 12); frame.levelTitle:SetPoint("TOPLEFT", 202, -214)
    frame.minHolder, frame.minEdit = CreateEditBox(frame, false); frame.minHolder:SetPoint("TOPLEFT", 202, -238); frame.minHolder:SetWidth(120); frame.minHolder:SetHeight(34); frame.minEdit:SetNumeric(true); frame.minEdit:SetMaxLetters(2)
    frame.maxHolder, frame.maxEdit = CreateEditBox(frame, false); frame.maxHolder:SetPoint("TOPLEFT", 336, -238); frame.maxHolder:SetWidth(120); frame.maxHolder:SetHeight(34); frame.maxEdit:SetNumeric(true); frame.maxEdit:SetMaxLetters(2)
    frame.descriptionTitle = Text(frame, "GameFontNormal", self:L("RECRUIT_SETTINGS_DESCRIPTION"), 12); frame.descriptionTitle:SetPoint("TOPLEFT", 24, -326)
    frame.descriptionHolder, frame.description = CreateEditBox(frame, true); frame.descriptionHolder:SetPoint("TOPLEFT", 24, -350); frame.descriptionHolder:SetPoint("TOPRIGHT", -24, -350); frame.descriptionHolder:SetHeight(116)
    frame.placeholder = Text(frame.descriptionHolder, "GameFontNormalSmall", self:L("RECRUIT_SETTINGS_DESCRIPTION_PLACEHOLDER"), 10); frame.placeholder:SetPoint("TOPLEFT", 10, -8); frame.placeholder:SetPoint("RIGHT", -10, 0); frame.placeholder:SetTextColor(unpack(MUTED)); frame.description:SetScript("OnTextChanged", function(self) if Trim(self:GetText()) == "" then frame.placeholder:Show() else frame.placeholder:Hide() end end)
    frame.modeTitle = Text(frame, "GameFontNormal", self:L("RECRUIT_SETTINGS_MODE"), 12); frame.modeTitle:SetPoint("TOPLEFT", 24, -484)
    frame.manual = Button(frame, self:L("RECRUIT_SETTINGS_MODE_MANUAL"), 330, 34); frame.manual:SetPoint("TOPLEFT", 24, -508); frame.manual:SetScript("OnClick", function() frame.draft.mode = "manual"; GMG:RefreshRecruitmentSettingsPopup() end)
    frame.auto = Button(frame, self:L("RECRUIT_SETTINGS_MODE_AUTO"), 330, 34); frame.auto:SetPoint("TOPRIGHT", -24, -508); frame.auto:SetScript("OnClick", function() frame.draft.mode = "auto"; GMG:RefreshRecruitmentSettingsPopup() end)
    frame.warning = Text(frame, "GameFontNormalSmall", self:L("RECRUIT_SETTINGS_AUTO_WARNING"), 10); frame.warning:SetPoint("TOPLEFT", 24, -552); frame.warning:SetPoint("TOPRIGHT", -24, -552); frame.warning:SetHeight(42); frame.warning:SetTextColor(unpack(GOLD)); if frame.warning.SetWordWrap then frame.warning:SetWordWrap(true) end
    frame.save = Button(frame, self:L("RECRUIT_SETTINGS_SAVE"), 220, 36); frame.save:SetPoint("BOTTOMLEFT", 24, 18); frame.save:SetScript("OnClick", function() GMG:SaveRecruitmentSettingsFromPopup() end); AttachTooltip(frame.save, "RECRUIT_SETTINGS_SAVE", "RECRUIT_SETTINGS_SAVE_HELP")
    frame.close = Button(frame, self:L("RECRUIT_SETTINGS_CLOSE"), 150, 36); frame.close:SetPoint("BOTTOMRIGHT", -24, 18); frame.close:SetScript("OnClick", function() frame:Hide() end)
    if UISpecialFrames then table.insert(UISpecialFrames, "GBGRecruitmentSettingsPopup") end
    self.recruitmentSettingsPopup = frame; return frame
end

function GMG:OpenRecruitmentSettings()
    if not self:CanManageGuildRecruitment() then self:ShowRecruitmentNotice(self:L("PENDING_PERMISSION")); return end
    local frame = self:CreateRecruitmentSettingsPopup(); local recruitment = self:GetRecruitmentGuildStore(true); frame.draft = {enabled = recruitment.enabled, objective = recruitment.objective, mode = recruitment.mode, minLevel = recruitment.minLevel, maxLevel = recruitment.maxLevel}; frame.minEdit:SetText(tostring(frame.draft.minLevel)); frame.maxEdit:SetText(tostring(frame.draft.maxLevel)); frame.description:SetText(recruitment.description or ""); self:RefreshRecruitmentSettingsPopup(); frame:Show()
end

function GMG:RefreshRecruitmentSettingsPopup()
    local frame = self.recruitmentSettingsPopup; if not frame or not frame.draft then return end
    frame.title:SetText(self:L("RECRUIT_SETTINGS_TITLE")); frame.intro:SetText(self:L("RECRUIT_SETTINGS_INTRO")); frame.enabled.label:SetText(self:L(frame.draft.enabled and "RECRUIT_SETTINGS_ENABLED" or "RECRUIT_SETTINGS_DISABLED")); SetButtonSelected(frame.enabled, frame.draft.enabled)
    for _, button in ipairs(frame.objectiveButtons) do SetButtonSelected(button, button.objective == frame.draft.objective) end
    SetButtonSelected(frame.manual, frame.draft.mode == "manual"); SetButtonSelected(frame.auto, frame.draft.mode == "auto"); frame.warning:SetText(self:L("RECRUIT_SETTINGS_AUTO_WARNING")); if frame.draft.mode == "auto" then frame.warning:Show() else frame.warning:Hide() end
    frame.placeholder:SetText(self:L("RECRUIT_SETTINGS_DESCRIPTION_PLACEHOLDER")); if Trim(frame.description:GetText()) == "" then frame.placeholder:Show() else frame.placeholder:Hide() end
    local ad = self:GetOwnRecruitmentAdvertisement(); self:ApplyGuildBannerDisplay(frame.banner, frame.bannerFallback, ad)
end

function GMG:SaveRecruitmentSettingsFromPopup()
    local frame = self.recruitmentSettingsPopup; if not frame or not frame.draft then return end
    local minLevel = Clamp(frame.minEdit:GetText(), 1, 60, 1); local maxLevel = Clamp(frame.maxEdit:GetText(), 1, 60, 60); local description = Trim(frame.description:GetText())
    if minLevel > maxLevel then self:ShowRecruitmentNotice(self:L("RECRUIT_SETTINGS_LEVEL_ERROR")); return end
    if frame.draft.enabled and description == "" then self:ShowRecruitmentNotice(self:L("RECRUIT_SETTINGS_DESCRIPTION_REQUIRED")); return end
    local recruitment = self:GetRecruitmentGuildStore(true); recruitment.enabled = frame.draft.enabled; recruitment.objective = frame.draft.objective; recruitment.mode = frame.draft.mode; recruitment.minLevel = minLevel; recruitment.maxLevel = maxLevel; recruitment.description = string.sub(description, 1, 500); recruitment.revision = (tonumber(recruitment.revision) or 0) + 1; recruitment.updatedAt = time(); recruitment.updatedBy = self:GetPlayerName(); self:PersistSettings(); self:QueueGuildRecruitmentState(true); self:BroadcastRecruitmentAdvertisement(true); frame:Hide(); self:ShowRecruitmentNotice(self:L("RECRUIT_SETTINGS_SAVED")); self:RefreshPendingApplicationsPage()
end

-- --------------------------------------------------------------------------
-- Sidebar tabs, visibility and localization
-- --------------------------------------------------------------------------
function GMG:InstallRecruitmentTabs()
    if not self.mainFrame or not self.mainFrame.sidebar then return end
    if not self.mainFrame.tabs.guildsearch then
        local tab = Button(self.mainFrame.sidebar, self:L("GUILD_SEARCH_TAB"), 154, 38); tab.localeKey = "GUILD_SEARCH_TAB"; tab:SetScript("OnClick", function() GMG:ShowTab("guildsearch") end); self.mainFrame.tabs.guildsearch = tab
    end
    if not self.mainFrame.tabs.pendingapps then
        local tab = Button(self.mainFrame.sidebar, self:L("PENDING_TAB"), 154, 38); tab.localeKey = "PENDING_TAB"; tab:SetScript("OnClick", function() GMG:ShowTab("pendingapps") end)
        tab.badge = CreateFrame("Frame", nil, tab); tab.badge:SetWidth(28); tab.badge:SetHeight(20); tab.badge:SetPoint("RIGHT", -4, 0); SetBackdrop(tab.badge, {0.48, 0.04, 0.08, 1}, {0.85, 0.15, 0.20, 1}); tab.badge.text = Text(tab.badge, "GameFontNormalSmall", "0", 9); tab.badge.text:SetPoint("CENTER"); tab.badge:Hide(); self.mainFrame.tabs.pendingapps = tab
    end
end

function GMG:RefreshPendingTabBadge()
    local tab = self.mainFrame and self.mainFrame.tabs and self.mainFrame.tabs.pendingapps
    if not tab or not tab.badge then return end
    local count = 0; for _, record in ipairs(self:GetVisiblePendingApplications()) do if record.status == "pending" then count = count + 1 end end
    if count > 0 then tab.badge.text:SetText(tostring(count)); tab.badge:Show() else tab.badge:Hide() end
end

function GMG:RefreshRecruitmentTabVisibility()
    if not self.mainFrame or not self.mainFrame.tabs then return end
    local inGuild = self:IsInGuild(); local canManage = self:CanManageGuildRecruitment(); local tabs = self.mainFrame.tabs
    local ordered = {}
    if inGuild then
        for _, key in ipairs({"chat", "roster", "guild", "dungeon"}) do if tabs[key] then tabs[key]:Show(); ordered[#ordered + 1] = key end end
        if tabs.guildinvite then if canManage then tabs.guildinvite:Show(); ordered[#ordered + 1] = "guildinvite" else tabs.guildinvite:Hide() end end
        if tabs.pendingapps then if canManage then tabs.pendingapps:Show(); ordered[#ordered + 1] = "pendingapps" else tabs.pendingapps:Hide() end end
        if tabs.guildsearch then tabs.guildsearch:Hide() end
    else
        for _, key in ipairs({"chat", "roster", "guild", "dungeon", "guildinvite", "pendingapps"}) do if tabs[key] then tabs[key]:Hide() end end
        if tabs.guildsearch then tabs.guildsearch:Show(); ordered[#ordered + 1] = "guildsearch" end
    end
    for index, key in ipairs(ordered) do tabs[key]:ClearAllPoints(); tabs[key]:SetPoint("TOPLEFT", 18, -48 - (index - 1) * 46) end
    local current = self.db and self.db.profile and self.db.profile.lastTab
    if (not inGuild and current ~= "guildsearch") or (inGuild and (current == "guildsearch" or (current == "pendingapps" and not canManage) or (current == "guildinvite" and not canManage))) then self:ShowTab(inGuild and "roster" or "guildsearch") end
    self:RefreshPendingTabBadge()
end

local PreviousCreateUI = GMG.CreateUI
function GMG:CreateUI(...)
    local wanted = self.db and self.db.profile and self.db.profile.lastTab
    PreviousCreateUI(self, ...)
    self:CreateGuildSearchPage(); self:CreatePendingApplicationsPage(); self:InstallRecruitmentTabs(); self:RefreshRecruitmentTabVisibility()
    if wanted == "guildsearch" or wanted == "pendingapps" then self:ShowTab(wanted) end
end

local PreviousShowTab = GMG.ShowTab
function GMG:ShowTab(key, ...)
    if key == "guildsearch" and self.guildSearchPage and not self:IsInGuild() then
        if self.chatPage then self.chatPage:Hide() end; if self.rosterPage then self.rosterPage:Hide() end; if self.guildPage then self.guildPage:Hide() end; if self.settingsPage then self.settingsPage:Hide() end; if self.dungeonPage then self.dungeonPage:Hide() end; if self.guildInvitePage then self.guildInvitePage:Hide() end; if self.pendingApplicationsPage then self.pendingApplicationsPage:Hide() end
        self.guildSearchPage:Show(); self.db.profile.lastTab = "guildsearch"; self:PersistSettings(); for tabKey, tab in pairs(self.mainFrame.tabs or {}) do SetButtonSelected(tab, tabKey == "guildsearch") end; self:RefreshGuildSearchPage(); self:RequestRecruitmentAdvertisements(); return
    end
    if key == "pendingapps" and self.pendingApplicationsPage and self:CanManageGuildRecruitment() then
        if self.chatPage then self.chatPage:Hide() end; if self.rosterPage then self.rosterPage:Hide() end; if self.guildPage then self.guildPage:Hide() end; if self.settingsPage then self.settingsPage:Hide() end; if self.dungeonPage then self.dungeonPage:Hide() end; if self.guildInvitePage then self.guildInvitePage:Hide() end; if self.guildSearchPage then self.guildSearchPage:Hide() end
        self.pendingApplicationsPage:Show(); self.db.profile.lastTab = "pendingapps"; self:PersistSettings(); for tabKey, tab in pairs(self.mainFrame.tabs or {}) do SetButtonSelected(tab, tabKey == "pendingapps") end; self:RefreshPendingApplicationsPage(); return
    end
    PreviousShowTab(self, key, ...)
    if self.guildSearchPage then self.guildSearchPage:Hide() end; if self.pendingApplicationsPage then self.pendingApplicationsPage:Hide() end
end

local PreviousRefreshLocalization = GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
    PreviousRefreshLocalization(self, ...)
    local tabs = self.mainFrame and self.mainFrame.tabs
    if tabs and tabs.guildsearch then tabs.guildsearch.label:SetText(self:L("GUILD_SEARCH_TAB")) end
    if tabs and tabs.pendingapps then tabs.pendingapps.label:SetText(self:L("PENDING_TAB")) end
    local page = self.guildSearchPage
    if page then page.title:SetText(self:L("GUILD_SEARCH_TITLE")); page.intro:SetText(self:L("GUILD_SEARCH_INTRO")); page.refresh.label:SetText(self:L("GUILD_SEARCH_REFRESH")); page.empty:SetText(self:L("GUILD_SEARCH_EMPTY")); page.bannerTitle:SetText(self:L("GUILD_SEARCH_BANNER")); page.descriptionTitle:SetText(self:L("GUILD_SEARCH_DESCRIPTION")); page.messageTitle:SetText(self:L("GUILD_SEARCH_APPLY_MESSAGE")); page.placeholder:SetText(self:L("GUILD_SEARCH_APPLY_PLACEHOLDER")); page.statusTitle:SetText(self:L("GUILD_SEARCH_STATUS")); local keys = {"GUILD_SEARCH_ALL", "GUILD_SEARCH_PVE", "GUILD_SEARCH_PVP", "GUILD_SEARCH_MIXED"}; for i, b in ipairs(page.filters) do b.label:SetText(self:L(keys[i])) end; self:RefreshGuildSearchPage() end
    page = self.pendingApplicationsPage
    if page then page.title:SetText(self:L("PENDING_TITLE")); page.intro:SetText(self:L("PENDING_INTRO")); page.settings.label:SetText(self:L("PENDING_SETTINGS")); page.profileTitle:SetText(self:L("PENDING_PROFILE")); page.messageTitle:SetText(self:L("PENDING_APPLICATION")); page.accept.label:SetText(self:L("PENDING_ACCEPT")); page.retry.label:SetText(self:L("PENDING_RETRY")); page.decline.label:SetText(self:L("PENDING_DECLINE")); page.empty:SetText(self:L("PENDING_EMPTY")); self:RefreshPendingApplicationsPage() end
    if self.recruitmentSettingsPopup and self.recruitmentSettingsPopup:IsShown() then self:RefreshRecruitmentSettingsPopup() end
end

local PreviousRefreshDynamicUI = GMG.RefreshDynamicUI
function GMG:RefreshDynamicUI(...)
    PreviousRefreshDynamicUI(self, ...)
    self:RefreshRecruitmentTabVisibility()
    if self.guildSearchPage and self.guildSearchPage:IsShown() then self:RefreshGuildSearchPage() end
    if self.pendingApplicationsPage and self.pendingApplicationsPage:IsShown() then self:RefreshPendingApplicationsPage() end
end

local PreviousPlayerLogin = GMG.PLAYER_LOGIN
function GMG:PLAYER_LOGIN(...)
    PreviousPlayerLogin(self, ...)
    self:EnsureRecruitmentData()
    self:Schedule("recruitment-channel", 2, function() GMG:JoinRecruitmentChannel(); GMG:RequestRecruitmentAdvertisements() end)
end

local PreviousPlayerGuildUpdate = GMG.PLAYER_GUILD_UPDATE
function GMG:PLAYER_GUILD_UPDATE(...)
    PreviousPlayerGuildUpdate(self, ...)
    self:CheckOwnApplicationJoinedGuild()
    self:Schedule("recruitment-guild-state", 1, function() if GMG.IsInGuild and GMG:IsInGuild() then GMG:QueueGuildRecruitmentState(true); GMG:BroadcastRecruitmentAdvertisement(true) end; GMG:RefreshRecruitmentTabVisibility() end)
end

local PreviousGuildRosterUpdate = GMG.GUILD_ROSTER_UPDATE
function GMG:GUILD_ROSTER_UPDATE(...)
    PreviousGuildRosterUpdate(self, ...)
    self:UpdateJoinedApplications()
end

local PreviousOnUpdate = GMG.OnUpdate
function GMG:OnUpdate(elapsed)
    PreviousOnUpdate(self, elapsed)
    self.recruitmentSendPulse = (self.recruitmentSendPulse or 0) + elapsed
    self.recruitmentTickPulse = (self.recruitmentTickPulse or 0) + elapsed
    if self.recruitmentSendPulse >= 0.45 then self.recruitmentSendPulse = self.recruitmentSendPulse - 0.45; self:SendRecruitmentQueue() end
    if self.recruitmentTickPulse >= 5 then self.recruitmentTickPulse = self.recruitmentTickPulse - 5; self:RecruitmentTick() end
end

if GMG.eventFrame then GMG.eventFrame:RegisterEvent("CHAT_MSG_CHANNEL") end
