-- @ADDON@: party marks.
-- Pick who gets each of the five usual party marks (Star, Circle, Diamond, Triangle, Moon)
-- in the settings window. When you're in a party and someone is missing their mark, the buff
-- row shows a mark icon: one click puts all the missing marks on (out of combat).
local _, ns = ...

ns.PARTY_MARKS = { 1, 2, 3, 4, 5 }
local ME = "@me" -- "you", whichever character you're playing (profiles are shared)

local function Name(unit)
  local ok, n = pcall(UnitName, unit)
  if not ok or not n or (issecretvalue and issecretvalue(n)) then return nil end
  return n
end

local function Marks()
  ns.db.marks = ns.db.marks or {}
  return ns.db.marks
end

-- Who you can pick: nobody, you, or a party slot (party member 2-5 in the party frames).
-- Slots stay put when people come and go, so the marks follow the slot, not the name.
local SLOTS = { false, ME, "party1", "party2", "party3", "party4" }
local function Choices(idx)
  local list = {}
  for i, v in ipairs(SLOTS) do list[i] = v end
  local cur = Marks()[idx]
  local known = false
  for _, v in ipairs(list) do if v == cur then known = true end end
  if cur and not known then list[#list + 1] = cur end -- a name picked with an older version
  return list
end

local function UnitFor(who)
  if who == ME then return "player" end
  if type(who) == "string" and who:match("^party%d$") then
    return UnitExists(who) and who or nil
  end
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

-- Marks only a click may set (SetRaidTarget is protected), so this builds a macro for the
-- buff row's mark icon: "/tm [@party1] 2" sets a mark on that player without changing your
-- target. Only marks that are missing go in, since setting a mark a player has takes it off.
-- Returns { name, icon, macro, who } or nil.
function ns.PartyMarkMacro()
  if ns.db.marksOff then return nil end
  if not (IsInGroup and IsInGroup()) or (IsInRaid and IsInRaid()) then return nil end
  if InCombatLockdown and InCombatLockdown() then return nil end
  local lines, first, who = {}, nil, {}
  for _, idx in ipairs(ns.PARTY_MARKS) do
    local name = Marks()[idx]
    local unit = name and UnitFor(name)
    -- A mark only sticks on someone near you: players out of range (the party frames'
    -- ~40 yards) wait until they're close. The buff row checks again every second.
    if unit and unit ~= "player" then
      local readable = function(v) return not (issecretvalue and issecretvalue(v)) end
      local ok, vis = pcall(UnitIsVisible, unit)
      if ok and readable(vis) and not vis then unit = nil end
      if unit and UnitInRange then
        local ok2, inRange, checked = pcall(UnitInRange, unit)
        if ok2 and readable(inRange) and readable(checked) and checked and not inRange then unit = nil end
      end
    end
    if unit then
      local cur, known = CurrentMark(unit)
      if known and cur ~= idx then
        lines[#lines + 1] = "/tm [@" .. unit .. "] " .. idx
        first = first or idx
        who[#who + 1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. idx .. ":0|t "
          .. (unit == "player" and ns.T("MK_ME") or (Name(unit) or name))
      end
    end
  end
  if #lines == 0 then return nil end
  return { name = ns.T("CAT_MARKS"), icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. first,
    macro = table.concat(lines, "\n"), who = table.concat(who, ", ") }
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
  marks[idx] = new or nil
  if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
end

-- Settings window rows: "<icon> Star   < Jennie >".
ns.MARK_SELECTORS = {}
for _, idx in ipairs(ns.PARTY_MARKS) do
  table.insert(ns.MARK_SELECTORS, { key = "MK_" .. idx,
    value = function()
      local who = Marks()[idx]
      if not who then return ns.T("CFG_OFF") end
      if who == ME then return ns.T("MK_ME") end
      local slot = type(who) == "string" and who:match("^party(%d)$")
      if slot then return ns.T("MK_SLOT", tonumber(slot) + 1) end
      return who
    end,
    step = function(dir) Step(idx, dir) end })
end

-- A group change or a new mark shows (or hides) the icon right away.
ns.RegisterModule(function()
  local ev = CreateFrame("Frame")
  for _, e in ipairs({ "GROUP_ROSTER_UPDATE", "RAID_TARGET_UPDATE", "PLAYER_REGEN_ENABLED" }) do
    pcall(ev.RegisterEvent, ev, e)
  end
  ev:SetScript("OnEvent", function(_, event)
    if event == "GROUP_ROSTER_UPDATE" and ns.RefreshMenu then ns.RefreshMenu() end
    if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
  end)
end)

ns.RegisterCommand("marks", true, function()
  ns.db.marksOff = not ns.db.marksOff
  ns.Print(ns.db.marksOff and ns.T("MARKS_OFF") or ns.T("MARKS_ON"))
  if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
end)
