-- @ADDON@: party marks.
-- Pick who gets each of the five usual party marks (Star, Circle, Diamond, Triangle, Moon)
-- in the settings window. In a party a small mark button shows (its own movable button, no
-- alerts): one click puts the marks on. Marks only a click may set, so it's a macro button.
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

local function Icon(idx) return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. idx end

-- The picked marks whose player is in your party now: { { idx, unit, label }, ... }.
local function Picked()
  local out = {}
  if ns.db.marksOff then return out end
  if not (IsInGroup and IsInGroup()) or (IsInRaid and IsInRaid()) then return out end
  for _, idx in ipairs(ns.PARTY_MARKS) do
    local name = Marks()[idx]
    local unit = name and UnitFor(name)
    if unit then
      out[#out + 1] = { idx = idx, unit = unit,
        label = "|T" .. Icon(idx) .. ":0|t " .. (unit == "player" and ns.T("MK_ME") or (Name(unit) or name)) }
    end
  end
  return out
end

-- The macro for the mark button: "/tm [@party1] 2" sets a mark on that player without
-- changing your target. Out of combat only the missing marks go in. For combat (when the
-- addon can't see or change anything) every mark is cleared and set again, so one click
-- always brings them all back, whatever the tank's marking took away.
function ns.PartyMarkMacro(forCombat)
  local lines = {}
  for _, m in ipairs(Picked()) do
    if forCombat then
      lines[#lines + 1] = "/tm [@" .. m.unit .. "] 0"
      lines[#lines + 1] = "/tm [@" .. m.unit .. "] " .. m.idx
    else
      local cur, known = CurrentMark(m.unit)
      if not known then
        lines[#lines + 1] = "/tm [@" .. m.unit .. "] 0"
        lines[#lines + 1] = "/tm [@" .. m.unit .. "] " .. m.idx
      elseif cur ~= m.idx then
        lines[#lines + 1] = "/tm [@" .. m.unit .. "] " .. m.idx
      end
    end
  end
  return table.concat(lines, "\n")
end

-- The button: shown in a party when you've picked marks. Shift-drag moves it, Ctrl + wheel
-- resizes it. Everything about it is set out of combat (secure button).
local btn
local function UpdateButton(forCombat)
  if not btn then return end
  if InCombatLockdown and InCombatLockdown() then return end
  local picked = Picked()
  if #picked == 0 then btn:Hide() return end
  btn.icon:SetTexture(Icon(picked[1].idx))
  btn.picked = picked
  btn:SetAttribute("type1", "macro")
  btn:SetAttribute("macrotext1", ns.PartyMarkMacro(forCombat))
  btn:Show()
end
ns.UpdateMarkButton = UpdateButton

local function CreateButton()
  btn = CreateFrame("Button", "@ADDON@MarkButton", UIParent, "SecureActionButtonTemplate")
  btn:SetSize(30, 30)
  local p = ns.db.markPos
  if p then btn:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else btn:SetPoint("CENTER", UIParent, "CENTER", 260, -150) end
  btn:SetScale(ns.db.markScale or 1)
  btn:SetFrameStrata("MEDIUM")
  btn:RegisterForClicks("AnyUp", "AnyDown")
  btn.icon = btn:CreateTexture(nil, "ARTWORK")
  btn.icon:SetAllPoints()
  btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  btn:SetMovable(true)
  btn:RegisterForDrag("LeftButton")
  btn:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() and not (InCombatLockdown and InCombatLockdown()) then self:StartMoving() end
  end)
  btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.markPos = { point, relPoint, x, y }
  end)
  btn:EnableMouseWheel(true)
  btn:SetScript("OnMouseWheel", function(self, delta)
    if not IsControlKeyDown() or (InCombatLockdown and InCombatLockdown()) then return end
    local s = math.max(0.6, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.markScale = s
  end)
  btn:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(ns.T("CAT_MARKS"))
    local who = {}
    for _, m in ipairs(self.picked or {}) do who[#who + 1] = m.label end
    GameTooltip:AddLine(ns.T("MK_CLICK", table.concat(who, ", ")), 0.6, 0.8, 1, true)
    GameTooltip:AddLine(ns.T("MK_MOVE"), 0.6, 0.6, 0.6, true)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  btn:Hide()
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
  UpdateButton()
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

ns.RegisterModule(function()
  CreateButton()
  local ev = CreateFrame("Frame")
  for _, e in ipairs({ "GROUP_ROSTER_UPDATE", "RAID_TARGET_UPDATE", "PLAYER_REGEN_ENABLED",
    "PLAYER_REGEN_DISABLED", "PLAYER_ENTERING_WORLD" }) do
    pcall(ev.RegisterEvent, ev, e)
  end
  ev:SetScript("OnEvent", function(_, event)
    if event == "GROUP_ROSTER_UPDATE" and ns.RefreshMenu then ns.RefreshMenu() end
    -- Going into combat: load the "bring them all back" macro while we still can.
    UpdateButton(event == "PLAYER_REGEN_DISABLED")
  end)
  UpdateButton()
end)

ns.RegisterCommand("marks", true, function()
  ns.db.marksOff = not ns.db.marksOff
  ns.Print(ns.db.marksOff and ns.T("MARKS_OFF") or ns.T("MARKS_ON"))
  UpdateButton()
end)
