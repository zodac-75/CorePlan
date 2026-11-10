-- @ADDON@: import a talent build from a wow-forever-forge.com link.
-- A forge share link is https://wow-forever-forge.com/talents/<class>/<code>: every talent
-- point is the talent's ID in three base64url characters, in the order the points are
-- spent. That order becomes the leveling plan (first point at level 10). The imported plan
-- shows up as "Imported" next to our own plans, and acts like the plan of ours that spends
-- most in the same tree (stat weights, combat call-outs, buffs).
local _, ns = ...

local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local VALUE = {}
for i = 1, #ALPHABET do VALUE[ALPHABET:sub(i, i)] = i - 1 end

local function Decode(code)
  local out = {}
  for i = 1, #code - 2, 3 do
    local a, b, c = VALUE[code:sub(i, i)], VALUE[code:sub(i + 1, i + 1)], VALUE[code:sub(i + 2, i + 2)]
    if not (a and b and c) then break end
    out[#out + 1] = a * 4096 + b * 64 + c
  end
  return out
end

-- The class slug and code from a link, or just a code.
local function Parse(text)
  text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
  local cls, code = text:match("/talents/(%a+)/([%w%-_]+)")
  if not code then code = text:match("^([%w%-_]+)$") end
  return cls and cls:lower() or nil, code
end

-- Which tree a plan spends most in (1-3), from talent names.
local function MainTree(talents)
  local byName = {}
  for _, t in pairs(ns.TALENT_IDS or {}) do byName[t[1]] = t[3] end
  local count = {}
  for _, entry in pairs(talents) do
    local name = entry:match("^(.-)%s+%d+/%d+$")
    local tree = name and byName[name]
    if tree then count[tree] = (count[tree] or 0) + 1 end
  end
  local best, n = nil, -1
  for tree, c in pairs(count) do if c > n then best, n = tree, c end end
  return best
end

-- Our plan that spends most in the same tree as the imported one.
local function LikePlan(talents)
  local want = MainTree(talents)
  for _, key in ipairs(ns.PLAN_ORDER) do
    local p = ns.PLANS[key]
    if key ~= "import" and p and p.talents and MainTree(p.talents) == want then return key end
  end
  return ns.PLAN_ORDER[1]
end

-- Puts the stored import into the plan list (at login and after an import).
local function AddImported()
  local imp = ns.db.importPlan
  if not (imp and imp.talents and next(imp.talents)) then return false end
  ns.PLANS.import = { talents = imp.talents, like = imp.like }
  local listed = false
  for _, k in ipairs(ns.PLAN_ORDER) do if k == "import" then listed = true end end
  if not listed then table.insert(ns.PLAN_ORDER, "import") end
  return true
end

-- Imports a link (or code). Returns true when it worked; prints what happened.
function ns.ImportTalents(text)
  local cls, code = Parse(text)
  local mine = ("@CLASS@"):lower()
  if not code or #code < 3 then ns.Print(ns.T("IMP_BAD")) return false end
  if cls and cls ~= mine then ns.Print(ns.T("IMP_CLASS", cls)) return false end
  local ids = Decode(code)
  local talents, have, level, unknown = {}, {}, 10, 0
  for _, id in ipairs(ids) do
    local t = ns.TALENT_IDS and ns.TALENT_IDS[id]
    if t then
      have[t[1]] = (have[t[1]] or 0) + 1
      if level <= 60 then talents[level] = string.format("%s %d/%d", t[1], have[t[1]], t[2]) end
      level = level + 1
    else
      unknown = unknown + 1
    end
  end
  if not next(talents) then ns.Print(ns.T("IMP_BAD")) return false end
  local like = LikePlan(talents)
  ns.db.importPlan = { talents = talents, like = like, code = code }
  AddImported()
  ns.db.plan = "import"
  ns.ApplyPlan()
  ns.Print(ns.T("IMP_DONE", level - 10, ns.T("PLAN_" .. like)))
  if unknown > 0 then ns.Print(ns.T("IMP_UNKNOWN", unknown)) end
  ns.RefreshMain()
  if ns.RefreshTalentGlow then ns.RefreshTalentGlow() end
  if ns.RefreshMenu then ns.RefreshMenu() end
  return true
end

-- A box to paste the link into.
function ns.AskImport()
  if not (StaticPopup_Show and StaticPopupDialogs) then ns.Print(ns.T("CMD_import")) return end
  if not StaticPopupDialogs.@ADDONUP@_IMPORT then
    local function Box(self) return self.editBox or self.EditBox or (self.GetEditBox and self:GetEditBox()) end
    StaticPopupDialogs.@ADDONUP@_IMPORT = {
      button1 = ACCEPT or "OK",
      button2 = CANCEL or "Cancel",
      hasEditBox = true,
      editBoxWidth = 350,
      maxLetters = 0,
      OnShow = function(self)
        local eb = Box(self)
        if eb then eb:SetText(""); eb:SetFocus() end
      end,
      OnAccept = function(self)
        local eb = Box(self)
        ns.ImportTalents(eb and eb:GetText())
      end,
      EditBoxOnEnterPressed = function(self)
        ns.ImportTalents(self:GetText())
        self:GetParent():Hide()
      end,
      EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
      timeout = 0, whileDead = true, hideOnEscape = true,
    }
  end
  StaticPopupDialogs.@ADDONUP@_IMPORT.text = ns.T("IMP_ASK")
  StaticPopup_Show("@ADDONUP@_IMPORT")
end

-- Forget the imported build (back to our first plan).
function ns.ClearImport()
  ns.db.importPlan = nil
  ns.PLANS.import = nil
  for i = #ns.PLAN_ORDER, 1, -1 do if ns.PLAN_ORDER[i] == "import" then table.remove(ns.PLAN_ORDER, i) end end
  if ns.db.plan == "import" then ns.db.plan = nil end
  ns.ApplyPlan()
  ns.Print(ns.T("IMP_CLEARED"))
  ns.RefreshMain()
  if ns.RefreshMenu then ns.RefreshMenu() end
end

ns.RegisterModule(function()
  if AddImported() then ns.ApplyPlan() end
end)

-- /@SLASH@ import <link>: import; /@SLASH@ import: paste box; /@SLASH@ import clear: remove it.
ns.RegisterCommand("import", true, function(rest)
  rest = rest or ""
  if rest:match("^%s*$") then ns.AskImport()
  elseif rest:lower():match("^%s*clear") then ns.ClearImport()
  else ns.ImportTalents(rest) end
end)
