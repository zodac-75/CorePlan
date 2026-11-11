-- @ADDON@: import a talent build from a wow-forever-forge.com or Wowhead link.
-- A forge share link is https://wow-forever-forge.com/talents/<class>/<code>: every talent
-- point is the talent's ID in three base64url characters, in the order the points are
-- spent. That order becomes the leveling plan (first point at level 10).
-- A Wowhead link is https://www.wowhead.com/forever/talent-calc/<class>/<ranks>...: the
-- ranks are one digit per talent, tree by tree ("-" between trees), talents row by row and
-- left to right. It has no order we can read, so the plan fills the tree with the most
-- points first, row by row, then the next tree.
-- A talentsforever.com link is https://talentsforever.com/<class>/<level>/<ranks>?...: the
-- ranks are the same as Wowhead's (one digit per talent, "-" between the three trees, a
-- fourth part after them is not talents), so it is read the same way.
-- An Icy Veins link is https://www.icy-veins.com/wow-forever/<class>-talent-calculator#tc-<code>~<build>:
-- every talent point is one character (talent number 1, 2, 3 ... over the three trees, in
-- the characters 1-9, a-z, A-Z), in the order the points were spent, so like a forge link
-- it gives the leveling order. The talents are numbered tree by tree, row by row and left
-- to right, except where the class has ns.ICY_FRONT = { [tree] = { names } } (talents the
-- site numbers first in their tree). A link that doesn't fit the class (an unknown
-- character, too many points in a talent, a talent used before its row is open) is
-- refused instead of read wrongly.
-- The imported plan shows up as "Imported" next to our own plans, and acts like the plan
-- of ours that spends most in the same tree (stat weights, combat call-outs, buffs).
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

-- The class slug and code from a link, or just a code. kind is "forge" or "wowhead".
local function Parse(text)
  text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
  local icls, icode = text:match("icy%-veins%.com/wow%-forever/(%a+)%-talent%-calculator#tc%-([%w]+)")
  if icode then return icls:lower(), icode, "icy" end
  local tcls, tlevel, tranks = text:match("talentsforever%.com/(%a+)/(%d+)/([%d%-]+)")
  if not tranks then tcls, tranks = text:match("talentsforever%.com/(%a+)/([%d%-]+)") end
  if tranks then return tcls:lower(), tranks, "wowhead" end
  local cls, ranks = text:match("talent%-calc/(%a+)/([^/%s]+)")
  if ranks then
    ranks = ranks:gsub("_.*$", ""):gsub("^%a+", "") -- drop "_t0..." and the letters in front
    return cls:lower(), ranks, "wowhead"
  end
  local code
  cls, code = text:match("/talents/(%a+)/([%w%-_]+)")
  if not code then code = text:match("^([%w%-_]+)$") end
  return cls and cls:lower() or nil, code, "forge"
end

-- Wowhead ranks ("05002322302-25500001-...") to a list of talent IDs, one per point:
-- the tree with the most points first, then row by row, left to right.
local function FromWowhead(ranks)
  local trees = {}
  for part in (ranks .. "-"):gmatch("([^%-]*)%-") do trees[#trees + 1] = part end
  local byTree = { {}, {}, {} }
  for id, t in pairs(ns.TALENT_IDS or {}) do
    if byTree[t[3]] then table.insert(byTree[t[3]], id) end
  end
  local picks, total = {}, {}
  for ti = 1, 3 do
    local list = byTree[ti]
    table.sort(list, function(a, b)
      local x, y = ns.TALENT_IDS[a], ns.TALENT_IDS[b]
      if x[4] ~= y[4] then return x[4] < y[4] end
      return x[5] < y[5]
    end)
    picks[ti], total[ti] = {}, 0
    local digits = trees[ti] or ""
    for i = 1, #digits do
      local n = tonumber(digits:sub(i, i)) or 0
      local id = list[i]
      if id and n > 0 then
        for _ = 1, math.min(n, ns.TALENT_IDS[id][2]) do table.insert(picks[ti], id) end
        total[ti] = total[ti] + n
      end
    end
  end
  local order = { 1, 2, 3 }
  table.sort(order, function(a, b)
    if total[a] ~= total[b] then return total[a] > total[b] end
    return a < b
  end)
  local ids = {}
  for _, ti in ipairs(order) do
    for _, id in ipairs(picks[ti]) do ids[#ids + 1] = id end
  end
  return ids
end

-- Icy Veins characters to talent IDs, one per point, or nil when the link doesn't fit.
local ICY_CHARS = "123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local function FromIcy(code)
  local list = {}
  for ti = 1, 3 do
    local tree = {}
    for id, t in pairs(ns.TALENT_IDS or {}) do
      if t[3] == ti then table.insert(tree, id) end
    end
    table.sort(tree, function(a, b)
      local x, y = ns.TALENT_IDS[a], ns.TALENT_IDS[b]
      if x[4] ~= y[4] then return x[4] < y[4] end
      return x[5] < y[5]
    end)
    local front = ns.ICY_FRONT and ns.ICY_FRONT[ti]
    if front then
      local moved, rest = {}, {}
      for _, name in ipairs(front) do
        for _, id in ipairs(tree) do if ns.TALENT_IDS[id][1] == name then table.insert(moved, id) end end
      end
      local isMoved = {}
      for _, id in ipairs(moved) do isMoved[id] = true end
      for _, id in ipairs(tree) do if not isMoved[id] then table.insert(rest, id) end end
      tree = moved
      for _, id in ipairs(rest) do table.insert(tree, id) end
    end
    for _, id in ipairs(tree) do list[#list + 1] = id end
  end
  local ids, have, spent = {}, {}, {}
  for i = 1, #code do
    local at = ICY_CHARS:find(code:sub(i, i), 1, true)
    local id = at and list[at]
    local t = id and ns.TALENT_IDS[id]
    if not t then return nil end
    have[id] = (have[id] or 0) + 1
    if have[id] > t[2] then return nil end
    if (spent[t[3]] or 0) < 5 * t[4] then return nil end -- the row isn't open yet
    spent[t[3]] = (spent[t[3]] or 0) + 1
    ids[#ids + 1] = id
  end
  return ids
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
  local cls, code, kind = Parse(text)
  local mine = ("@CLASS@"):lower()
  if not code or #code < 3 then ns.Print(ns.T("IMP_BAD")) return false end
  if cls and cls ~= mine then ns.Print(ns.T("IMP_CLASS", cls)) return false end
  local ids
  if kind == "icy" then
    ids = FromIcy(code)
    if not ids then ns.Print(ns.T("IMP_ICY")) return false end
  else
    ids = kind == "wowhead" and FromWowhead(code) or Decode(code)
  end
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
