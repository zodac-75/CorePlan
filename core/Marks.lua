-- @ADDON@: party marks.
-- Pick who gets each of the five usual party marks (Star, Circle, Diamond, Triangle, Moon)
-- in the settings window. While you're in a party the addon puts them on those players:
-- when the group changes, when you zone and when you pick someone. Out of combat only,
-- and never in reaction to someone else's marks, so it doesn't fight a leader or another addon.
local _, ns = ...

ns.PARTY_MARKS = { 1, 2, 3, 4, 5 }
local ME = "@me" -- "you", whichever character you're playing (profiles are shared)
local pending = false

local function Name(unit)
  local ok, n = pcall(UnitName, unit)
  if not ok or not n or (issecretvalue and issecretvalue(n)) then return nil end
  return n
end

local function Marks()
  ns.db.marks = ns.db.marks or {}
  return ns.db.marks
end

-- Who you can pick: nobody, you, your party, and whoever is already picked.
local function Choices(idx)
  local list, seen = { false, ME }, {}
  for i = 1, 4 do
    local u = "party" .. i
    local n = UnitExists(u) and Name(u)
    if n and not seen[n] then seen[n] = true; list[#list + 1] = n end
  end
  local cur = Marks()[idx]
  if cur and cur ~= ME and not seen[cur] then list[#list + 1] = cur end
  return list
end

local function UnitFor(who)
  if who == ME then return "player" end
  for i = 1, 4 do
    local u = "party" .. i
    if UnitExists(u) and Name(u) == who then return u end
  end
end

local function CurrentMark(unit)
  if not GetRaidTargetIndex then return nil, false end
  local ok, cur = pcall(GetRaidTargetIndex, unit)
  if not ok or (issecretvalue and issecretvalue(cur)) then return nil, false end
  return cur, true
end

-- Put the picked marks on. Only in a party (raid marks belong to the raid leader).
local function Apply()
  if not (IsInGroup and IsInGroup()) or (IsInRaid and IsInRaid()) or not SetRaidTarget then return end
  if InCombatLockdown and InCombatLockdown() then pending = true return end
  pending = false
  for _, idx in ipairs(ns.PARTY_MARKS) do
    local who = Marks()[idx]
    local unit = who and UnitFor(who)
    if unit then
      local cur, known = CurrentMark(unit)
      -- Setting the mark a unit already has would take it off again.
      if known and cur ~= idx then pcall(SetRaidTarget, unit, idx) end
    end
  end
end
ns.ApplyPartyMarks = Apply

-- Take a mark off whoever we gave it to (when you pick someone else or nobody).
local function Clear(idx, who)
  if not who or not (IsInGroup and IsInGroup()) or (IsInRaid and IsInRaid()) or not SetRaidTarget then return end
  if InCombatLockdown and InCombatLockdown() then return end
  local unit = UnitFor(who)
  if unit and CurrentMark(unit) == idx then pcall(SetRaidTarget, unit, 0) end
end

local function Step(idx, dir)
  local list, marks = Choices(idx), Marks()
  local at = 1
  for i, v in ipairs(list) do if v == (marks[idx] or false) then at = i end end
  -- One mark per player: skip whoever already has another mark.
  local function taken(v)
    if not v then return false end
    for _, other in ipairs(ns.PARTY_MARKS) do
      if other ~= idx and marks[other] == v then return true end
    end
    return false
  end
  local new
  for n = 1, #list do
    new = list[(at - 1 + dir * n) % #list + 1]
    if not taken(new) then break end
  end
  Clear(idx, marks[idx])
  marks[idx] = new or nil
  Apply()
end

-- Settings window rows: "<icon> Star   < Jennie >".
ns.MARK_SELECTORS = {}
for _, idx in ipairs(ns.PARTY_MARKS) do
  table.insert(ns.MARK_SELECTORS, { key = "MK_" .. idx,
    value = function()
      local who = Marks()[idx]
      if not who then return ns.T("CFG_OFF") end
      if who == ME then return ns.T("MK_ME") end
      return who
    end,
    step = function(dir) Step(idx, dir) end })
end

ns.RegisterModule(function()
  local ev = CreateFrame("Frame")
  for _, e in ipairs({ "GROUP_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED" }) do
    pcall(ev.RegisterEvent, ev, e)
  end
  ev:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" and not pending then return end
    if event == "GROUP_ROSTER_UPDATE" and ns.RefreshMenu then ns.RefreshMenu() end
    -- Give the new member's frame a moment to exist.
    C_Timer.After(1, function() pcall(Apply) end)
  end)
end)

ns.RegisterCommand("marks", false, function() Apply() end)
