-- @ADDON@: moving to AllClassPlan (all nine Plan addons in one install).
--
-- Stand-alone (@ADDON@): when AllClassPlan and its part for this class are turned on for this
-- character, @ADDON@ steps aside (no window, no commands, no modules) and sets
-- @ADDON@Retired, so AllClassPlan knows this version is safe to run next to. Its saved
-- settings still load, so AllClassPlan can copy them.
--
-- Inside AllClassPlan (ns.ALLCLASS = "MagePlan", set by tools/buildall.py): the first time a
-- character logs in, the stand-alone addon's settings are copied (ns.ImportSettings).
local ADDON, ns = ...

-- The AllClassPlan page. ACP_LIVE = true once it is on CurseForge: then the stand-alone
-- addons show the moving notice once per character.
ns.ACP_URL = "https://www.curseforge.com/wow/addons/allclassplan"
ns.ACP_LIVE = true

local function Copy(v)
  if type(v) ~= "table" then return v end
  local t = {}
  for k, x in pairs(v) do t[k] = Copy(x) end
  return t
end
ns.DeepCopy = Copy

-- Is this addon turned on for the character logging in? (installed and ticked in the list)
function ns.AddonOn(name)
  local who = UnitName and UnitName("player")
  if C_AddOns and C_AddOns.GetAddOnEnableState then
    local ok, s = pcall(C_AddOns.GetAddOnEnableState, name, who)
    if ok and type(s) == "number" then return s > 0 end
  end
  if GetAddOnEnableState then
    local ok, s = pcall(GetAddOnEnableState, who, name)
    if ok and type(s) == "number" then return s > 0 end
  end
  return false
end

if not ns.ALLCLASS then
  local part = "AllClassPlan_" .. ADDON:gsub("Plan$", "")
  ns.retired = ns.AddonOn("AllClassPlan") and ns.AddonOn(part) or nil
  if ns.retired then _G[ADDON .. "Retired"] = true end
end

-- AllClassPlan: copy the stand-alone addon's settings.
--   db: this character's AllClassPlanDB (nil the first time), global: AllClassPlanGlobal.
-- The character's settings are copied only when there are none yet. The account-wide ones
-- (language, layout profiles) are merged in once per stand-alone addon, without overwriting
-- anything already there. Returns the db and true when the character's settings came along.
function ns.ImportSettings(from, db, global)
  local imported
  local old = rawget(_G, from .. "DB")
  if db == nil and type(old) == "table" and next(old) ~= nil then
    db = Copy(old)
    imported = true
  end
  local oldG = rawget(_G, from .. "Global")
  global.importedFrom = global.importedFrom or {}
  if type(oldG) == "table" and not global.importedFrom[from] then
    for k, v in pairs(oldG) do
      if global[k] == nil then
        global[k] = Copy(v)
      elseif type(global[k]) == "table" and type(v) == "table" then
        for kk, vv in pairs(v) do
          if global[k][kk] == nil then global[k][kk] = Copy(vv) end
        end
      end
    end
    global.importedFrom[from] = true
  end
  return db, imported
end

-- The moving notice (stand-alone only): thanks, why, and the link to copy.
function ns.ShowAllClassNotice()
  local text = ns.T("ACP_NOTICE")
  if not (StaticPopup_Show and StaticPopupDialogs) then
    ns.Print(text:gsub("\n+", " ") .. " " .. ns.ACP_URL)
    return
  end
  local key = "@ADDONUP@_ALLCLASS"
  if not StaticPopupDialogs[key] then
    local function Box(self) return self.editBox or self.EditBox or (self.GetEditBox and self:GetEditBox()) end
    StaticPopupDialogs[key] = {
      button1 = OKAY or "OK",
      hasEditBox = true,
      editBoxWidth = 320,
      showAlert = 1, -- makes room on the left for the AllClassPlan logo
      OnShow = function(self)
        -- The AllClassPlan logo where the alert icon normally sits.
        local icon = self.AlertIcon or self.Icon or (self.GetName and self:GetName() and _G[self:GetName() .. "AlertIcon"])
        if icon and icon.SetTexture then
          icon:SetTexture(ns.MEDIA .. "ACP")
          icon:SetTexCoord(0, 1, 0, 1)
          if icon.Show then icon:Show() end
        end
        local eb = Box(self)
        if eb then eb:SetText(ns.ACP_URL); eb:HighlightText(); eb:SetFocus() end
      end,
      EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
      EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
      EditBoxOnTextChanged = function(self)
        if self:GetText() ~= ns.ACP_URL then self:SetText(ns.ACP_URL); self:HighlightText() end
      end,
      timeout = 0, whileDead = true, hideOnEscape = true,
    }
  end
  StaticPopupDialogs[key].text = text
  StaticPopup_Show(key)
end

-- Once per character, a few seconds after login, when AllClassPlan is out.
function ns.MaybeAllClassNotice()
  if ns.ALLCLASS or ns.retired or not ns.ACP_LIVE or not ns.db or ns.db.acpNoticeSeen then return end
  C_Timer.After(6, function()
    if InCombatLockdown and InCombatLockdown() then return end -- next login
    ns.db.acpNoticeSeen = true
    ns.ShowAllClassNotice()
  end)
end
