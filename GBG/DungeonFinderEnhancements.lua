-- G.B.G (Glayna Better Guild)
-- v1.7.5: Guild Finder portraits, role-aware creation, descriptions and level filtering.
-- WoW 3.3.5a / Ascension Interface 30300.

local GMG = GlaynaBetterGuild
local floor, max, min = math.floor, math.max, math.min
local sort, tonumber, tostring = table.sort, tonumber, tostring
local strlower, time = string.lower, time

local BD = {bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", tile=false, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}}
local BG={0.025,0.031,0.052,0.995}; local PANEL={0.045,0.052,0.082,0.99}; local PANEL2={0.075,0.082,0.125,0.98}
local BORDER={0.24,0.22,0.38,1}; local ACCENT={0.60,0.42,1,1}; local ACCENTSOFT={0.30,0.19,0.52,0.95}
local TEXT={0.88,0.90,0.96,1}; local MUTED={0.48,0.52,0.64,1}; local GREEN={0.25,0.90,0.55,1}; local RED={0.95,0.34,0.42,1}

local EN={
 DF_DESCRIPTION="Description", DF_DESCRIPTION_TOOLTIP="Activity description", DF_YOUR_ACTIVITY_ROLE="Your role in this activity",
 DF_CREATOR_LEVEL_INVALID="You cannot create this activity because your level (%d) is outside the required range %d-%d.",
 DF_CREATOR_ROLE_REQUIRED="Choose your own role for this activity.", DF_CREATOR_ROLE_DISABLED="Your role must be enabled in the available-role list.",
 DF_CREATOR_ROLE_IMPOSSIBLE="The selected composition has no available place for your role.",
 DF_HIDE_INELIGIBLE="Hide activities whose level requirement I do not meet",
 DF_HIDE_INELIGIBLE_HELP="Activities remain synchronized but are hidden when your character level is outside their required range.",
 DF_LEVEL_SHORT="Lvl. %d-%d", DF_OWNER_SHORT="Leader: %s", DF_NO_DESCRIPTION="No description provided.",
}
local FR={
 DF_DESCRIPTION="Description", DF_DESCRIPTION_TOOLTIP="Description de l’activité", DF_YOUR_ACTIVITY_ROLE="Votre rôle dans cette activité",
 DF_CREATOR_LEVEL_INVALID="Vous ne pouvez pas créer cette activité : votre niveau (%d) n’est pas compris dans la tranche requise %d-%d.",
 DF_CREATOR_ROLE_REQUIRED="Choisissez votre propre rôle pour cette activité.", DF_CREATOR_ROLE_DISABLED="Votre rôle doit être activé dans la liste des rôles disponibles.",
 DF_CREATOR_ROLE_IMPOSSIBLE="La composition sélectionnée ne prévoit aucune place pour votre rôle.",
 DF_HIDE_INELIGIBLE="Masquer les activités dont je n’ai pas le niveau requis",
 DF_HIDE_INELIGIBLE_HELP="Les activités restent synchronisées mais sont masquées si votre niveau n’est pas compris dans leur tranche requise.",
 DF_LEVEL_SHORT="Niv. %d-%d", DF_OWNER_SHORT="Responsable : %s", DF_NO_DESCRIPTION="Aucune description renseignée.",
}
GMG.Locales=GMG.Locales or {en={},fr={}}; GMG.Locales.en=GMG.Locales.en or {}; GMG.Locales.fr=GMG.Locales.fr or {}
for k,v in pairs(EN) do GMG.Locales.en[k]=v end; for k,v in pairs(FR) do GMG.Locales.fr[k]=v end

local TYPE_KEYS={
 XP_DUNGEON="DF_TYPE_XP_DUNGEON", NORMAL_DUNGEON="DF_TYPE_NORMAL_DUNGEON", HEROIC_DUNGEON="DF_TYPE_HEROIC_DUNGEON",
 MYTHIC_DUNGEON="DF_TYPE_MYTHIC_DUNGEON", MYTHIC_PLUS="DF_TYPE_MYTHIC_PLUS", RAID="DF_TYPE_RAID", WORLD_BOSS="DF_TYPE_WORLD_BOSS", OTHER_PVE="DF_TYPE_OTHER_PVE",
 XP_BATTLEGROUND="DF_TYPE_XP_BATTLEGROUND", MAX_BATTLEGROUND="DF_TYPE_MAX_BATTLEGROUND", ARENA="DF_TYPE_ARENA", WORLD_PVP="DF_TYPE_WORLD_PVP", WARGAME="DF_TYPE_WARGAME", OTHER_PVP="DF_TYPE_OTHER_PVP",
}

local function Backdrop(f,b,c) f:SetBackdrop(BD); f:SetBackdropColor(unpack(b or PANEL)); f:SetBackdropBorderColor(unpack(c or BORDER)) end
local function Text(p,font,text,size)
 local fs=p:CreateFontString(nil,"OVERLAY",font or "GameFontNormal"); if size then local f,_,fl=fs:GetFont(); if f then fs:SetFont(f,size,fl) end end
 fs:SetText(text or ""); fs:SetTextColor(unpack(TEXT)); return fs
end
local function Bounded(fs,text,width)
 if not fs then return end; text=tostring(text or ""); if width then fs:SetWidth(width) end; if fs.SetWordWrap then fs:SetWordWrap(false) end; fs:SetText(text)
 if not width or not fs.GetStringWidth or fs:GetStringWidth()<=width or string.find(text,"|",1,true) then return end
 local s=text; while string.len(s)>1 do s=string.sub(s,1,string.len(s)-1); fs:SetText(s.."..."); if fs:GetStringWidth()<=width then return end end
end
local function Button(p,text,w,h)
 local b=CreateFrame("Button",nil,p); b:SetWidth(w or 120); b:SetHeight(h or 30); Backdrop(b,PANEL2,BORDER)
 b.label=Text(b,"GameFontNormal",text or "",11); b.label:SetPoint("LEFT",6,0); b.label:SetPoint("RIGHT",-6,0); b.label:SetJustifyH("CENTER")
 b:SetScript("OnEnter",function(s) if not s.disabled then s:SetBackdropColor(unpack(ACCENTSOFT)); s:SetBackdropBorderColor(unpack(ACCENT)) end end)
 b:SetScript("OnLeave",function(s) if s.selected then s:SetBackdropColor(unpack(ACCENTSOFT)); s:SetBackdropBorderColor(unpack(ACCENT)) else s:SetBackdropColor(unpack(PANEL2)); s:SetBackdropBorderColor(unpack(BORDER)) end end)
 b:SetScript("OnDisable",function(s) s.disabled=true; s:SetAlpha(.42) end); b:SetScript("OnEnable",function(s) s.disabled=false; s:SetAlpha(1) end); return b
end
local function Select(b,value)
 if not b then return end; b.selected=value and true or false
 if b.selected then b:SetBackdropColor(unpack(ACCENTSOFT)); b:SetBackdropBorderColor(unpack(ACCENT)); if b.label then b.label:SetTextColor(1,1,1,1) end
 else b:SetBackdropColor(unpack(PANEL2)); b:SetBackdropBorderColor(unpack(BORDER)); if b.label then b.label:SetTextColor(unpack(TEXT)) end end
end
local function Check(p,label,w)
 local b=CreateFrame("Button",nil,p); b:SetWidth(w or 350); b:SetHeight(24); b.box=CreateFrame("Frame",nil,b); b.box:SetWidth(18); b.box:SetHeight(18); b.box:SetPoint("LEFT",0,0); Backdrop(b.box,PANEL,BORDER)
 b.fill=b.box:CreateTexture(nil,"ARTWORK"); b.fill:SetTexture("Interface\\Buttons\\WHITE8X8"); b.fill:SetPoint("TOPLEFT",4,-4); b.fill:SetPoint("BOTTOMRIGHT",-4,4); b.fill:SetVertexColor(unpack(ACCENT)); b.fill:Hide()
 b.label=Text(b,"GameFontNormal",label or "",11); b.label:SetPoint("LEFT",b.box,"RIGHT",8,0); b.label:SetPoint("RIGHT",0,0); b.label:SetJustifyH("LEFT")
 function b:SetChecked(v) self.checked=v and true or false; if self.checked then self.fill:Show(); self.box:SetBackdropColor(unpack(ACCENTSOFT)); self.box:SetBackdropBorderColor(unpack(ACCENT)) else self.fill:Hide(); self.box:SetBackdropColor(unpack(PANEL)); self.box:SetBackdropBorderColor(unpack(BORDER)) end end
 function b:GetChecked() return self.checked end; b:SetChecked(false); return b
end
local function Escape(v) v=tostring(v or ""); v=string.gsub(v,"%%","%%25"); v=string.gsub(v,"|","%%7C"); v=string.gsub(v,"\n","%%0A"); v=string.gsub(v,"\r","%%0D"); return v end
local function Unescape(v) v=tostring(v or ""); v=string.gsub(v,"%%0D","\r"); v=string.gsub(v,"%%0A","\n"); v=string.gsub(v,"%%7C","|"); v=string.gsub(v,"%%25","%%"); return v end
local function Split(v) local r={}; local s=1; while true do local p=string.find(v,"|",s,true); if not p then r[#r+1]=string.sub(v,s); break end; r[#r+1]=string.sub(v,s,p-1); s=p+1 end; return r end
local function Role(v) v=strlower(tostring(v or "")); if v=="tank" then return "tank" elseif v=="heal" or v=="healer" then return "heal" elseif v=="dps" or v=="damage" or v=="damager" then return "dps" elseif v=="support" then return "support" end end
local function HasRole(roles,wanted) wanted=Role(wanted); for v in string.gmatch(tostring(roles or ""),"[^,]+") do if Role(v)==wanted then return true end end; return false end
local function RoleLabel(self,role) local k={tank="DF_ROLE_TANK",heal="DF_ROLE_HEAL",dps="DF_ROLE_DPS",support="DF_ROLE_SUPPORT"}; return self:L(k[Role(role)] or "DF_MEMBER_ROLE_UNKNOWN") end
local function TypeLabel(self,a) return self:L(TYPE_KEYS[a and a.activityType] or (a and a.category=="PVP" and "DF_TYPE_OTHER_PVP" or "DF_TYPE_OTHER_PVE")) end
local function Description(v) v=tostring(v or ""); v=string.gsub(v,"\r",""); v=string.gsub(v,"^%s+",""); v=string.gsub(v,"%s+$",""); if string.len(v)>300 then v=string.sub(v,1,300) end; return v end
local function PlayerLevel() local l=UnitLevel and tonumber(UnitLevel("player")) or 1; return max(1,min(60,l or 1)) end
local function Eligible(a) local l=PlayerLevel(); return a and l>=(tonumber(a.minLevel) or 1) and l<=(tonumber(a.maxLevel) or 60) end
local function DefaultRole() local r=UnitGroupRolesAssigned and Role(UnitGroupRolesAssigned("player")); return r or "dps" end

function GMG:NormalizeDungeonActivityV175(a)
 if not a then return a end; a.description=Description(a.description); a.ownerRole=Role(a.ownerRole); a.members=a.members or {}
 local owner=self:NormalizeName(a.owner or ""); if a.ownerRole and owner~="" then
  local old; for n in pairs(a.members) do if strlower(self:NormalizeName(n))==strlower(owner) then old=n; break end end
  if old and old~=owner then a.members[old]=nil end; a.members[owner]=a.ownerRole
 end; return a
end

local Store0=GMG.StoreDungeonActivity
function GMG:StoreDungeonActivity(a,announce)
 if a and self:NormalizeName(a.owner or "")==self:GetPlayerName() then if self.v175Description~=nil then a.description=self.v175Description end; if self.v175OwnerRole~=nil then a.ownerRole=self.v175OwnerRole end end
 self:NormalizeDungeonActivityV175(a); return Store0(self,a,announce)
end
local Payload0=GMG.BuildDungeonActivityPayload
function GMG:BuildDungeonActivityPayload(a) self:NormalizeDungeonActivityV175(a); return Payload0(self,a).."|"..Escape(a.description or "").."|"..Escape(a.ownerRole or "") end
local Handle0=GMG.HandleCompletePayload
function GMG:HandleCompletePayload(payload,channel,sender)
 Handle0(self,payload,channel,sender); local v=Split(payload or ""); if v[1]~="DA" or v[2]~=self:GetGuildHash() then return end
 local a=self:GetDungeonActivity(Unescape(v[3] or "")); if not a then return end; a.description=Description(Unescape(v[22] or "")); a.ownerRole=Role(Unescape(v[23] or "")); self:NormalizeDungeonActivityV175(a)
 self.dungeonDirty=true; if self.PersistSettings then self:PersistSettings() end; if self.dungeonPage and self.dungeonPage:IsShown() then self:RefreshDungeonFinder(true) end
end

local function Validate(self,category,minLevel,maxLevel,slots,roles,ownerRole)
 minLevel=max(1,min(60,tonumber(minLevel) or 1)); maxLevel=max(1,min(60,tonumber(maxLevel) or 60)); slots=max(1,min(40,tonumber(slots) or 5)); local l=PlayerLevel(); ownerRole=Role(ownerRole)
 if l<minLevel or l>maxLevel then self:Print(self:L("DF_CREATOR_LEVEL_INVALID",l,minLevel,maxLevel)); return false end
 if not ownerRole then self:Print(self:L("DF_CREATOR_ROLE_REQUIRED")); return false end
 if not HasRole(roles,ownerRole) then self:Print(self:L("DF_CREATOR_ROLE_DISABLED")); return false end
 if self.GetDungeonRoleCaps then local c=self:GetDungeonRoleCaps({category=category,slots=slots,roles=roles}); local cap=(ownerRole=="dps" or ownerRole=="support") and c.flex or c[ownerRole]; if not cap or cap<=0 then self:Print(self:L("DF_CREATOR_ROLE_IMPOSSIBLE")); return false end end
 return true
end
local Create0=GMG.CreateDungeonActivity
function GMG:CreateDungeonActivity(title,category,minLevel,maxLevel,slots,roles,approval,autoInvite,activityType,description,ownerRole)
 ownerRole=Role(ownerRole) or DefaultRole(); if not Validate(self,category,minLevel,maxLevel,slots,roles,ownerRole) then return false end
 self.v175Description=Description(description); self.v175OwnerRole=ownerRole; local ok=Create0(self,title,category,minLevel,maxLevel,slots,roles,approval,true,activityType); self.v175Description=nil; self.v175OwnerRole=nil; return ok
end
local Update0=GMG.UpdateDungeonActivity
function GMG:UpdateDungeonActivity(a,title,category,minLevel,maxLevel,slots,roles,approval,autoInvite,activityType,description,ownerRole)
 ownerRole=Role(ownerRole) or (a and a.ownerRole) or DefaultRole(); if not Validate(self,category,minLevel,maxLevel,slots,roles,ownerRole) then return false end
 self.v175Description=Description(description); self.v175OwnerRole=ownerRole; local ok=Update0(self,a,title,category,minLevel,maxLevel,slots,roles,approval,true,activityType); self.v175Description=nil; self.v175OwnerRole=nil; return ok
end
local Activities0=GMG.GetDungeonActivities
function GMG:GetDungeonActivities()
 local all=Activities0(self); local out={}; local hide=self.db and self.db.profile and self.db.profile.hideIneligibleDungeonGroups
 for _,a in ipairs(all) do self:NormalizeDungeonActivityV175(a); if not hide or Eligible(a) then out[#out+1]=a end end; return out
end

local function MultiEdit(parent,w,h)
 local holder=CreateFrame("Frame",nil,parent); holder:SetWidth(w); holder:SetHeight(h); Backdrop(holder,PANEL,BORDER)
 local edit=CreateFrame("EditBox",nil,holder); edit:SetPoint("TOPLEFT",9,-7); edit:SetPoint("BOTTOMRIGHT",-9,7); edit:SetAutoFocus(false); edit:SetFontObject("ChatFontNormal"); edit:SetTextColor(unpack(TEXT)); edit:SetMultiLine(true); edit:SetMaxLetters(300)
 holder.editBox=edit; return holder,edit
end

function GMG:RefreshDungeonCreatorRoleButtons()
 local f=self.dungeonCreatePopup; if not f or not f.creatorRoleButtons then return end
 local enabled={}; local first
 for _,c in ipairs(f.roleChecks or {}) do enabled[c.role]=c:GetChecked(); if c:GetChecked() and not first then first=c.role end end
 if not f.creatorRole or not enabled[f.creatorRole] then f.creatorRole=first end
 for _,b in ipairs(f.creatorRoleButtons) do if enabled[b.role] then b:Enable() else b:Disable() end; Select(b,enabled[b.role] and f.creatorRole==b.role) end
end

function GMG:EnhanceDungeonCreatePopupV175()
 local f=self.dungeonCreatePopup; if not f or f.v175Enhanced then return end; f.v175Enhanced=true; f:SetWidth(580); f:SetHeight(760)
 f.descriptionLabel=Text(f,"GameFontNormal",self:L("DF_DESCRIPTION"),12); f.descriptionLabel:SetPoint("TOPLEFT",24,-126)
 f.descriptionHolder,f.description=MultiEdit(f,532,66); f.descriptionHolder:SetPoint("TOPLEFT",24,-148)
 f.creatorRoleLabel=Text(f,"GameFontNormal",self:L("DF_YOUR_ACTIVITY_ROLE"),12); f.creatorRoleLabel:SetPoint("TOPLEFT",24,-522)
 f.creatorRoleButtons={}; local roles={"tank","heal","dps","support"}
 for i,r in ipairs(roles) do
  local b=Button(f,RoleLabel(self,r),126,36); b:SetPoint("TOPLEFT",24+(i-1)*132,-546); b.role=r
  b.icon=b:CreateTexture(nil,"ARTWORK"); b.icon:SetTexture(self:GetDungeonRoleIcon(r)); b.icon:SetWidth(22); b.icon:SetHeight(22); b.icon:SetPoint("LEFT",8,0)
  b.label:ClearAllPoints(); b.label:SetPoint("LEFT",b.icon,"RIGHT",6,0); b.label:SetPoint("RIGHT",-5,0); b.label:SetJustifyH("LEFT")
  b:SetScript("OnClick",function(s) if not s.disabled then f.creatorRole=s.role; GMG:RefreshDungeonCreatorRoleButtons() end end); f.creatorRoleButtons[i]=b
 end
 for _,c in ipairs(f.roleChecks or {}) do
  c:SetWidth(126)
  c.roleIcon=c:CreateTexture(nil,"ARTWORK"); c.roleIcon:SetTexture(self:GetDungeonRoleIcon(c.role)); c.roleIcon:SetWidth(20); c.roleIcon:SetHeight(20); c.roleIcon:SetPoint("LEFT",c.box,"RIGHT",5,0)
  c.label:ClearAllPoints(); c.label:SetPoint("LEFT",c.roleIcon,"RIGHT",5,0); c.label:SetPoint("RIGHT",0,0); c.label:SetJustifyH("LEFT")
  c:SetScript("OnClick",function(s) s:SetChecked(not s:GetChecked()); GMG:RefreshDungeonCreatorRoleButtons() end)
 end

 -- Clean vertical layout. Nothing shares the same area.
 f.title:ClearAllPoints(); f.title:SetPoint("TOPLEFT",24,-20)
 f.nameLabel:ClearAllPoints(); f.nameLabel:SetPoint("TOPLEFT",24,-58); f.nameHolder:ClearAllPoints(); f.nameHolder:SetWidth(532); f.nameHolder:SetPoint("TOPLEFT",24,-82)
 f.typeLabel:ClearAllPoints(); f.typeLabel:SetPoint("TOPLEFT",24,-230); f.pve:ClearAllPoints(); f.pve:SetWidth(150); f.pve:SetPoint("TOPLEFT",24,-254); f.pvp:ClearAllPoints(); f.pvp:SetWidth(150); f.pvp:SetPoint("LEFT",f.pve,"RIGHT",12,0)
 if f.activityTypeLabel then f.activityTypeLabel:ClearAllPoints(); f.activityTypeLabel:SetPoint("TOPLEFT",24,-302) end
 if f.activityTypeButton then f.activityTypeButton:ClearAllPoints(); f.activityTypeButton:SetWidth(280); f.activityTypeButton:SetPoint("TOPLEFT",24,-326) end
 f.levelLabel:ClearAllPoints(); f.levelLabel:SetPoint("TOPLEFT",24,-376)
 f.minLabel:ClearAllPoints(); f.minLabel:SetPoint("TOPLEFT",24,-401); f.minHolder:ClearAllPoints(); f.minHolder:SetPoint("TOPLEFT",24,-420)
 f.maxLabel:ClearAllPoints(); f.maxLabel:SetPoint("TOPLEFT",154,-401); f.maxHolder:ClearAllPoints(); f.maxHolder:SetPoint("TOPLEFT",154,-420)
 f.slotsLabel:ClearAllPoints(); f.slotsLabel:SetPoint("TOPLEFT",284,-401); f.slotsHolder:ClearAllPoints(); f.slotsHolder:SetPoint("TOPLEFT",284,-420)
 f.rolesLabel:ClearAllPoints(); f.rolesLabel:SetPoint("TOPLEFT",24,-468); for i,c in ipairs(f.roleChecks or {}) do c:ClearAllPoints(); c:SetPoint("TOPLEFT",24+(i-1)*132,-492) end
 f.approvalLabel:ClearAllPoints(); f.approvalLabel:SetPoint("TOPLEFT",24,-598); f.approvalAuto:ClearAllPoints(); f.approvalAuto:SetWidth(258); f.approvalAuto:SetPoint("TOPLEFT",24,-622); f.approvalManual:ClearAllPoints(); f.approvalManual:SetWidth(258); f.approvalManual:SetPoint("TOPRIGHT",-24,-622)
 if f.autoInvite then f.autoInvite:Hide() end; f.create:ClearAllPoints(); f.create:SetPoint("BOTTOMLEFT",24,22); f.cancel:ClearAllPoints(); f.cancel:SetPoint("BOTTOMRIGHT",-24,22)

 local function chooseCategory(cat)
  f.category=cat=="PVP" and "PVP" or "PVE"; Select(f.pve,f.category=="PVE"); Select(f.pvp,f.category=="PVP"); local l=PlayerLevel(); local preset
  if f.category=="PVP" then preset=l>=10 and "XP_BATTLEGROUND" or "WORLD_PVP" else preset=l>=15 and "XP_DUNGEON" or "OTHER_PVE" end
  if GMG.ApplyDungeonActivityTypePreset then GMG:ApplyDungeonActivityTypePreset(f,preset,true) end
 end
 f.pve:SetScript("OnClick",function() chooseCategory("PVE") end); f.pvp:SetScript("OnClick",function() chooseCategory("PVP") end)
 f.create:SetScript("OnClick",function()
  local selected={}; for _,c in ipairs(f.roleChecks or {}) do if c:GetChecked() then selected[#selected+1]=c.role end end
  local lo=max(1,min(60,tonumber(f.minLevel:GetText()) or 1)); local hi=max(1,min(60,tonumber(f.maxLevel:GetText()) or 60)); if hi<lo then hi=lo end; f.minLevel:SetText(tostring(lo)); f.maxLevel:SetText(tostring(hi))
  local ok
  if f.editActivityID then ok=GMG:UpdateDungeonActivity(GMG:GetDungeonActivity(f.editActivityID),f.name:GetText(),f.category,lo,hi,f.slots:GetText(),table.concat(selected,","),f.approvalMode,true,f.activityType,f.description:GetText(),f.creatorRole)
  else ok=GMG:CreateDungeonActivity(f.name:GetText(),f.category,lo,hi,f.slots:GetText(),table.concat(selected,","),f.approvalMode,true,f.activityType,f.description:GetText(),f.creatorRole) end
  if ok then f:Hide(); GMG:ShowTab("dungeon"); GMG:RefreshDungeonFinder(true) end
 end)
end

local CreatePopup0=GMG.CreateDungeonCreatePopup
function GMG:CreateDungeonCreatePopup() CreatePopup0(self); self:EnhanceDungeonCreatePopupV175() end
local OpenCreate0=GMG.OpenDungeonCreatePopup
function GMG:OpenDungeonCreatePopup()
 OpenCreate0(self); local f=self.dungeonCreatePopup; if not f then return end; self:EnhanceDungeonCreatePopupV175(); f.description:SetText(""); f.creatorRole=DefaultRole()
 if f.category=="PVE" and PlayerLevel()<15 and self.ApplyDungeonActivityTypePreset then self:ApplyDungeonActivityTypePreset(f,"OTHER_PVE",true) end; self:RefreshDungeonCreatorRoleButtons()
end
local OpenEdit0=GMG.OpenDungeonEditPopup
function GMG:OpenDungeonEditPopup(a)
 OpenEdit0(self,a); local f=self.dungeonCreatePopup; if not f or not a then return end; self:EnhanceDungeonCreatePopupV175(); self:NormalizeDungeonActivityV175(a)
 f.description:SetText(a.description or ""); f.creatorRole=a.ownerRole or (a.members and a.members[self:GetPlayerName()]) or DefaultRole(); self:RefreshDungeonCreatorRoleButtons()
end

function GMG:InstallDungeonFinderEnhancementVisuals()
 local p=self.dungeonPage; if not p or p.v175Visuals then return end; p.v175Visuals=true
 for _,row in ipairs(p.rows or {}) do
  row.ownerAvatar=row:CreateTexture(nil,"ARTWORK"); row.ownerAvatar:SetWidth(40); row.ownerAvatar:SetHeight(40); row.ownerAvatar:SetPoint("LEFT",7,0)
  row.ownerRole=row:CreateTexture(nil,"OVERLAY"); row.ownerRole:SetWidth(17); row.ownerRole:SetHeight(17); row.ownerRole:SetPoint("BOTTOMRIGHT",row.ownerAvatar,"BOTTOMRIGHT",2,-2)
  row.name:ClearAllPoints(); row.name:SetPoint("TOPLEFT",54,-7); row.name:SetPoint("RIGHT",-8,0); row.name:SetJustifyH("LEFT")
  row.type:ClearAllPoints(); row.type:SetWidth(48); row.type:SetPoint("BOTTOMLEFT",54,8); row.type:SetJustifyH("LEFT")
  row.meta:ClearAllPoints(); row.meta:SetPoint("BOTTOMLEFT",102,8); row.meta:SetPoint("RIGHT",-136,0); row.meta:SetJustifyH("LEFT")
  if row.roleBadges then local o={tank=1,heal=2,dps=3}; for role,b in pairs(row.roleBadges) do b:ClearAllPoints(); b:SetPoint("BOTTOMRIGHT",-6-(3-(o[role] or 3))*43,5) end end
  row:SetScript("OnEnter",function(s)
   local a=s.activityID and GMG:GetDungeonActivity(s.activityID); if not a then return end; GameTooltip:SetOwner(s,"ANCHOR_RIGHT"); GameTooltip:AddLine(a.title or "",1,1,1)
   GameTooltip:AddLine(TypeLabel(GMG,a).."  •  "..GMG:L("DF_REQUIRED_LEVEL",a.minLevel or 1,a.maxLevel or 60),.72,.74,.84); GameTooltip:AddLine(GMG:L("DF_OWNER_SHORT",a.owner or ""),.72,.74,.84)
   GameTooltip:AddLine(" "); GameTooltip:AddLine(GMG:L("DF_DESCRIPTION_TOOLTIP"),.75,.55,1); GameTooltip:AddLine(a.description~="" and a.description or GMG:L("DF_NO_DESCRIPTION"),.9,.92,.98,true)
   if not Eligible(a) then GameTooltip:AddLine(" "); GameTooltip:AddLine(GMG:L("DF_LEVEL_TOO_LOW",a.minLevel or 1,a.maxLevel or 60,PlayerLevel()),1,.25,.3,true) end; GameTooltip:Show()
  end); row:SetScript("OnLeave",function() GameTooltip:Hide() end)
 end
 p.detail:EnableMouse(true); p.detailOwnerAvatar=p.detail:CreateTexture(nil,"ARTWORK"); p.detailOwnerAvatar:SetWidth(40); p.detailOwnerAvatar:SetHeight(40); p.detailOwnerAvatar:SetPoint("TOPLEFT",16,-14)
 p.detailOwnerRole=p.detail:CreateTexture(nil,"OVERLAY"); p.detailOwnerRole:SetWidth(18); p.detailOwnerRole:SetHeight(18); p.detailOwnerRole:SetPoint("BOTTOMRIGHT",p.detailOwnerAvatar,"BOTTOMRIGHT",2,-2)
 p.detailTitle:ClearAllPoints(); p.detailTitle:SetPoint("TOPLEFT",66,-18); p.detailTitle:SetPoint("TOPRIGHT",-18,-18)
end

function GMG:ApplyDungeonFinderFinalLayout()
 local p=self.dungeonPage; if not p then return end
 p.detailInfo:ClearAllPoints(); p.detailInfo:SetPoint("TOPLEFT",18,-62); p.detailInfo:SetPoint("TOPRIGHT",-18,-62); p.detailInfo:SetHeight(68)
 if p.capacity then p.capacity:ClearAllPoints(); p.capacity:SetPoint("TOPLEFT",18,-136); p.capacity:SetPoint("TOPRIGHT",-18,-136) end
 p.roleTitle:ClearAllPoints(); p.roleTitle:SetPoint("TOPLEFT",18,-160)
 for i,b in ipairs(p.roleButtons or {}) do local c=(i-1)%2; local r=floor((i-1)/2); b:ClearAllPoints(); b:SetWidth(126); b:SetPoint("TOPLEFT",18+c*138,-182-r*36) end
 p.membersTitle:ClearAllPoints(); p.membersTitle:SetPoint("TOPLEFT",18,-260)
 for i,r in ipairs(p.memberRows or {}) do r:ClearAllPoints(); r:SetPoint("TOPLEFT",18,-284-(i-1)*38); r:SetPoint("TOPRIGHT",-18,-284-(i-1)*38) end
 p.levelWarning:ClearAllPoints(); p.levelWarning:SetPoint("BOTTOMLEFT",18,58); p.levelWarning:SetPoint("BOTTOMRIGHT",-18,58)
end

function GMG:RefreshDungeonFinderEnhancementVisuals()
 local p=self.dungeonPage; if not p then return end; self:InstallDungeonFinderEnhancementVisuals(); self:ApplyDungeonFinderFinalLayout(); local list=self:GetDungeonActivities()
 for i,row in ipairs(p.rows or {}) do local a=list[i]
  if a and row:IsShown() then
   local m=self.GetRosterMemberByName and self:GetRosterMemberByName(a.owner); row.ownerAvatar:SetTexture(self:GetAvatarFor(a.owner,m and m.class,m and m.classFile,true))
   if a.ownerRole then row.ownerRole:SetTexture(self:GetDungeonRoleIcon(a.ownerRole)); row.ownerRole:Show() else row.ownerRole:Hide() end
   Bounded(row.name,TypeLabel(self,a).." — "..(a.title or ""),315); local occ=self:GetDungeonActivityOccupancy(a); row.meta:SetText(self:L("DF_LEVEL_SHORT",a.minLevel or 1,a.maxLevel or 60).."  •  "..occ.."/"..(a.slots or 1)); row:SetAlpha(Eligible(a) and 1 or .72)
  elseif row.ownerAvatar then row.ownerAvatar:SetTexture(nil); row.ownerRole:Hide(); row:SetAlpha(1) end
 end
 local a=self:GetDungeonActivity(self.dungeonSelectedID)
 if a then local m=self.GetRosterMemberByName and self:GetRosterMemberByName(a.owner); p.detailOwnerAvatar:SetTexture(self:GetAvatarFor(a.owner,m and m.class,m and m.classFile,true)); if a.ownerRole then p.detailOwnerRole:SetTexture(self:GetDungeonRoleIcon(a.ownerRole)); p.detailOwnerRole:Show() else p.detailOwnerRole:Hide() end
  p.detail:SetScript("OnEnter",function() if a.description=="" then return end; GameTooltip:SetOwner(p.detail,"ANCHOR_RIGHT"); GameTooltip:AddLine(self:L("DF_DESCRIPTION_TOOLTIP"),1,1,1); GameTooltip:AddLine(a.description,.9,.92,.98,true); GameTooltip:Show() end); p.detail:SetScript("OnLeave",function() GameTooltip:Hide() end)
 else p.detailOwnerAvatar:SetTexture(nil); p.detailOwnerRole:Hide(); p.detail:SetScript("OnEnter",nil); p.detail:SetScript("OnLeave",nil) end
end

local CreatePage0=GMG.CreateDungeonFinderPage
function GMG:CreateDungeonFinderPage() CreatePage0(self); self:InstallDungeonFinderEnhancementVisuals(); self:ApplyDungeonFinderFinalLayout() end
local RefreshFinder0=GMG.RefreshDungeonFinder
function GMG:RefreshDungeonFinder(force) RefreshFinder0(self,force); self:RefreshDungeonFinderEnhancementVisuals() end

function GMG:InstallHideIneligibleDungeonSetting()
 local p=self.settingsPage; if not p or p.hideIneligibleDungeonGroups then return end; p.hideIneligibleDungeonGroups=Check(p.left,self:L("DF_HIDE_INELIGIBLE"),360); p.hideIneligibleDungeonGroups:SetChecked(self.db.profile.hideIneligibleDungeonGroups and true or false)
 p.hideIneligibleDungeonGroups:SetScript("OnClick",function(b) b:SetChecked(not b:GetChecked()); GMG.db.profile.hideIneligibleDungeonGroups=b:GetChecked(); GMG.dungeonSelectedID=nil; GMG.dungeonDirty=true; GMG:PersistSettings(); GMG:RefreshDungeonFinder(true); GMG:RefreshDungeonActivityBadges() end)
 p.hideIneligibleDungeonGroups:SetScript("OnEnter",function(b) GameTooltip:SetOwner(b,"ANCHOR_RIGHT"); GameTooltip:AddLine(GMG:L("DF_HIDE_INELIGIBLE"),1,1,1); GameTooltip:AddLine(GMG:L("DF_HIDE_INELIGIBLE_HELP"),.72,.74,.84,true); GameTooltip:Show() end); p.hideIneligibleDungeonGroups:SetScript("OnLeave",function() GameTooltip:Hide() end)
end

local CreateUI0=GMG.CreateUI
function GMG:CreateUI(...)
 CreateUI0(self,...); self:InstallHideIneligibleDungeonSetting(); self:ApplyProfessionalSettingsLayout(); if self.mainFrame then self.mainFrame:SetMinResize(1080,780); if self.mainFrame:GetHeight()<780 then self.mainFrame:SetHeight(800) end end
end
local Settings0=GMG.RefreshSettings
function GMG:RefreshSettings(...)
 Settings0(self,...); self:InstallHideIneligibleDungeonSetting(); if self.settingsPage and self.settingsPage.hideIneligibleDungeonGroups then self.settingsPage.hideIneligibleDungeonGroups:SetChecked(self.db.profile.hideIneligibleDungeonGroups and true or false) end
end
local Layout0=GMG.ApplyProfessionalSettingsLayout
function GMG:ApplyProfessionalSettingsLayout(...)
 if Layout0 then Layout0(self,...) end; local p=self.settingsPage; if not p or not p.hideIneligibleDungeonGroups then return end
 p.hideIneligibleDungeonGroups:ClearAllPoints(); p.hideIneligibleDungeonGroups:SetPoint("TOPLEFT",18,-329)
 if p.displayTitle then p.displayTitle:ClearAllPoints(); p.displayTitle:SetPoint("TOPLEFT",18,-375) end; if p.showOffline then p.showOffline:ClearAllPoints(); p.showOffline:SetPoint("TOPLEFT",18,-405) end; if p.showLauncher then p.showLauncher:ClearAllPoints(); p.showLauncher:SetPoint("TOPLEFT",18,-438) end
 if p.keyTitle then p.keyTitle:ClearAllPoints(); p.keyTitle:SetPoint("TOPLEFT",18,-486) end; if p.currentKey then p.currentKey:ClearAllPoints(); p.currentKey:SetPoint("TOPLEFT",18,-514) end
 if p.changeKey then p.changeKey:ClearAllPoints(); p.changeKey:SetPoint("TOPLEFT",18,-548); p.changeKey:SetWidth(156) end; if p.clearKey then p.clearKey:ClearAllPoints(); p.clearKey:SetPoint("LEFT",p.changeKey,"RIGHT",12,0); p.clearKey:SetWidth(156) end
end
local Locale0=GMG.RefreshLocalization
function GMG:RefreshLocalization(...)
 Locale0(self,...); local f=self.dungeonCreatePopup; if f and f.v175Enhanced then f.descriptionLabel:SetText(self:L("DF_DESCRIPTION")); f.creatorRoleLabel:SetText(self:L("DF_YOUR_ACTIVITY_ROLE")); for _,b in ipairs(f.creatorRoleButtons or {}) do Bounded(b.label,RoleLabel(self,b.role),86) end; for _,c in ipairs(f.roleChecks or {}) do Bounded(c.label,RoleLabel(self,c.role),80) end end
 if self.settingsPage and self.settingsPage.hideIneligibleDungeonGroups then Bounded(self.settingsPage.hideIneligibleDungeonGroups.label,self:L("DF_HIDE_INELIGIBLE"),330) end; self:RefreshDungeonFinder(true)
end
