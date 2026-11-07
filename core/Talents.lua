-- @ADDON@: shows the next talent in the plan and marks it in the talent window.
local _, ns = ...

local TREES = ns.TALENT_TREES
local glow, hint

-- All talents: name -> {tab, index, tier, rank, max, icon}
local function TalentMap()
  local map = {}
  if not (GetNumTalentTabs and GetNumTalents and GetTalentInfo) then return map end
  local okT, tabs = pcall(GetNumTalentTabs)
  if not okT or not tabs then return map end
  for tab = 1, tabs do
    local okN, n = pcall(GetNumTalents, tab)
    if okN and n then
      for i = 1, n do
        local ok, name, icon, tier, _, rank, maxRank = pcall(GetTalentInfo, tab, i)
        if ok and name then
          map[name] = { tab = tab, index = i, tier = tier, rank = rank or 0, max = maxRank, icon = icon }
        end
      end
    end
  end
  return map
end

-- Returns name, talent info, wanted rank; "done" when the plan is complete.
function ns.NextTalent()
  local map = TalentMap()
  if not next(map) then return nil end
  for lvl = 10, 60 do
    local entry = ns.talents[lvl]
    if entry then
      local name, want = entry:match("^(.-)%s+(%d+)/%d+$")
      want = tonumber(want)
      local t = name and map[name]
      if t and want and t.rank < want then
        return name, t, want
      end
    end
  end
  return "done"
end

local function Unspent()
  if UnitCharacterPoints then
    local ok, p = pcall(UnitCharacterPoints, "player")
    if ok and type(p) == "number" then return p end
  end
  return nil
end

local function NextText()
  local name, t, want = ns.NextTalent()
  if not name then return nil end
  if name == "done" then
    local extra = ns.PlanDoneExtra and ns.PlanDoneExtra()
    return "|cffffd100" .. ns.T("PLAN_DONE") .. "|r" .. (extra and (" " .. extra) or "")
  end
  local tree = TREES[t.tab] or ns.T("TREE_N", t.tab)
  return "|cffffd100" .. ns.T("NEXT_TALENT") .. "|r " .. ns.T("NEXT_FMT", name, want, t.max or want, tree, t.tier or 0)
end

-- The talent window. WoW Forever has its own window with all three trees side by side,
-- so besides Blizzard's PlayerTalentFrame we look for any shown top-level frame with
-- "Talent" in its name, and find the talent's button by its icon.
local roots = {}

local function FindRoots()
  local found = {}
  if PlayerTalentFrame then found[PlayerTalentFrame] = true end
  if EnumerateFrames then
    local f = EnumerateFrames()
    while f do
      local ok, name = pcall(f.GetName, f)
      if ok and type(name) == "string" and name:find("Talent") and not name:find("^@ADDON@") then
        local okP, parent = pcall(f.GetParent, f)
        local okW, w = pcall(f.GetWidth, f)
        -- Only windows: skips micro buttons, alerts and other small frames.
        if okP and (parent == UIParent or parent == nil) and okW and type(w) == "number" and w >= 300
          and not name:find("Button") then
          found[f] = true
        end
      end
      f = EnumerateFrames(f)
    end
  end
  return found
end

local function ShownRoot()
  for f in pairs(roots) do
    local ok, shown = pcall(f.IsShown, f)
    if ok and shown then return f end
  end
end

local function SameIcon(a, b)
  if a == nil or b == nil then return false end
  if a == b then return true end
  return tostring(a):lower():gsub("\\", "/") == tostring(b):lower():gsub("\\", "/")
end

local function ButtonHasIcon(btn, icon)
  if btn.icon and btn.icon.GetTexture and SameIcon(btn.icon:GetTexture(), icon) then return true end
  local regions = { btn:GetRegions() }
  for _, r in ipairs(regions) do
    if r.GetTexture and r:IsObjectType("Texture") then
      local ok, tex = pcall(r.GetTexture, r)
      if ok and SameIcon(tex, icon) then return true end
      if r.GetTextureFileID then
        local okF, id = pcall(r.GetTextureFileID, r)
        if okF and SameIcon(id, icon) then return true end
      end
    end
  end
  return false
end

-- Walks the window looking for the shown button that shows the talent's icon.
local function FindButton(root, t)
  local old = (root == PlayerTalentFrame) and _G["PlayerTalentFrameTalent" .. t.index]
  if old and old:IsShown() then return old end
  if not t.icon then return nil end
  local function walk(f, depth)
    if depth > 10 then return nil end
    for _, c in ipairs({ f:GetChildren() }) do
      local okS, shown = pcall(c.IsShown, c)
      if okS and shown then
        -- One odd frame must not stop the search.
        local okI, isIt = pcall(ButtonHasIcon, c, t.icon)
        if okI and isIt then return c end
        local hit = walk(c, depth + 1)
        if hit then return hit end
      end
    end
  end
  local ok, btn = pcall(walk, root, 0)
  return ok and btn or nil
end

local function UpdateGlow()
  if not glow then return end
  glow:Hide()
  if hint then hint:Hide() end
  local root = ShownRoot()
  if not root then return end

  local line = NextText()
  if hint and line then
    hint:SetParent(root)
    hint:ClearAllPoints()
    hint:SetPoint("BOTTOM", root, "TOP", 0, 4)
    hint:SetText("@ADDON@: " .. line:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
    hint:Show()
  end

  local name, t = ns.NextTalent()
  if not t or name == "done" then return end
  if root == PlayerTalentFrame then
    local sel
    if PanelTemplates_GetSelectedTab then
      local ok, s = pcall(PanelTemplates_GetSelectedTab, PlayerTalentFrame)
      if ok then sel = s end
    end
    sel = sel or PlayerTalentFrame.selectedTab
    if sel and sel ~= t.tab then return end
  end

  local btn = FindButton(root, t)
  if not btn then return end
  glow:SetParent(btn)
  glow:ClearAllPoints()
  glow:SetPoint("CENTER", btn, "CENTER", 0, 0)
  glow:SetSize(btn:GetWidth() * 1.9, btn:GetHeight() * 1.9)
  glow:SetFrameStrata("DIALOG")
  glow:SetFrameLevel(btn:GetFrameLevel() + 5)
  glow:Show()
end

local function HookRoot(f)
  if roots[f] then return end
  roots[f] = true
  pcall(f.HookScript, f, "OnShow", function() C_Timer.After(0.1, function() pcall(UpdateGlow) end) end)
  pcall(f.HookScript, f, "OnHide", function() if glow then glow:Hide() end if hint then hint:Hide() end end)
end

local function ScanRoots()
  for f in pairs(FindRoots()) do HookRoot(f) end
end

local function SetupTalentUI()
  if glow then return end
  glow = CreateFrame("Frame", nil, UIParent)
  local tex = glow:CreateTexture(nil, "OVERLAY")
  tex:SetAllPoints()
  tex:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
  tex:SetBlendMode("ADD")
  tex:SetVertexColor(0.3, 0.8, 1)
  local ag = glow:CreateAnimationGroup()
  local a = ag:CreateAnimation("Alpha")
  a:SetFromAlpha(1)
  a:SetToAlpha(0.3)
  a:SetDuration(0.6)
  ag:SetLooping("BOUNCE")
  ag:Play()
  glow:Hide()

  hint = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  hint:Hide()

  if PlayerTalentFrame_Update then hooksecurefunc("PlayerTalentFrame_Update", function() pcall(UpdateGlow) end) end
  if PanelTemplates_SetTab then
    hooksecurefunc("PanelTemplates_SetTab", function(f)
      if roots[f] then C_Timer.After(0.05, function() pcall(UpdateGlow) end) end
    end)
  end
  pcall(ScanRoots)
end

-- /@SLASH@ talentui: what the addon found, for when the glow doesn't show.
local function DebugTalentUI()
  pcall(ScanRoots)
  local names = {}
  for f in pairs(roots) do
    local ok, n = pcall(f.GetName, f)
    local okS, shown = pcall(f.IsShown, f)
    table.insert(names, tostring(ok and n or "?") .. (okS and shown and " (open)" or ""))
  end
  ns.Print("talent windows: " .. (#names > 0 and table.concat(names, ", ") or "none"))
  local name, t = ns.NextTalent()
  ns.Print("next talent: " .. tostring(name) .. (t and (" tab " .. t.tab .. " #" .. t.index .. " icon " .. tostring(t.icon)) or ""))
  local root = ShownRoot()
  if root and t then
    local btn = FindButton(root, t)
    ns.Print("button: " .. (btn and tostring(btn:GetName() or "found (no name)") or "not found"))
  else
    ns.Print("open the talent window and run this again.")
  end
end
ns.RegisterCommand("talentui", false, DebugTalentUI)

function ns.RefreshTalentGlow() pcall(UpdateGlow) end

local function OnPointsChanged()
  ns.RefreshMain()
  pcall(UpdateGlow)
end

ns.RegisterModule(function()
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("ADDON_LOADED")
  ev:RegisterEvent("CHARACTER_POINTS_CHANGED")
  ev:RegisterEvent("PLAYER_LEVEL_UP")
  ev:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
      if type(arg1) == "string" and arg1:find("Talent") then
        pcall(SetupTalentUI)
        C_Timer.After(0.5, function() pcall(ScanRoots) end)
      end
    else
      ns.Debounce("talents", 0.3, OnPointsChanged)
    end
  end)
  pcall(SetupTalentUI)
  -- Windows made after login (Forever's talent window can be one) are found a bit later,
  -- and again whenever the talent key may have created a new window.
  C_Timer.After(3, function() pcall(ScanRoots) end)
  if ToggleTalentFrame then
    hooksecurefunc("ToggleTalentFrame", function()
      C_Timer.After(0.1, function() pcall(ScanRoots); pcall(UpdateGlow) end)
    end)
  end

  ns.AddStatusProvider(function()
    local line = NextText()
    if not line then return nil end
    local u = Unspent()
    if u and u > 0 then
      line = line .. " |cff60ff60" .. ns.T("POINTS_TO_SPEND", u) .. "|r"
    end
    return line
  end)

  C_Timer.After(5, function()
    local u = Unspent()
    local line = NextText()
    if u and u > 0 and line then
      ns.Print(ns.T("LOGIN_POINTS", u, line))
    end
  end)
end)
