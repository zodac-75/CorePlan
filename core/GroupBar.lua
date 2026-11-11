-- @ADDON@: the group bar. A small bar that shows while you are in a party, with one button
-- per group tool of your class (ns.GROUP_TRADES in the class Data.lua). A tool hands out
-- an item: a click opens a trade with the next party member in range who hasn't had one
-- yet and puts it in the trade window. When a party member opens a trade with you, it goes
-- in by itself. You always press Trade yourself.
--
-- ns.GROUP_TRADES = { {
--   key = "GB_WATER",               -- button text and tooltip (key, key .. "_TIP")
--   icon = "Interface\\Icons\\...",
--   spell = "Conjure Water",        -- only shown once you know it
--   items = function(unit) return { id, ... } end,  -- what this player gets, best first
--   oncePer = 300,                  -- seconds before the same player is offered another
-- } }
local _, ns = ...

local TRADE_RANGE = 2   -- CheckInteractDistance index for trading (about 11 yards)

local bar
local buttons = {}
local given = {}        -- tool key -> player name -> GetTime() of the last hand-out
local pending           -- { tool, name, time }: our click asked for this trade
local lastFill          -- { tool, name }: what we put in the open trade window
local tradeOpen = false
local nextIndex = 0

local function Now() return GetTime and GetTime() or 0 end
local function InCombat() return InCombatLockdown and InCombatLockdown() end

local function Tools()
  local list = {}
  for _, t in ipairs(ns.GROUP_TRADES or {}) do
    if not t.spell or ns.SpellInfo(t.spell) then list[#list + 1] = t end
  end
  return list
end

local function NameOf(unit)
  local ok, name = pcall(UnitName, unit)
  if ok and type(name) == "string" and not (issecretvalue and issecretvalue(name)) then return name end
end

---------------------------------------------------------------------------
-- Bags
---------------------------------------------------------------------------
local function NumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) or 0 end
  if GetContainerNumSlots then return GetContainerNumSlots(bag) or 0 end
  return 0
end

local function SlotItem(bag, slot)
  if C_Container and C_Container.GetContainerItemInfo then
    local ok, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
    if ok and type(info) == "table" then return info.itemID, info.stackCount or 1, info.isLocked end
    return nil
  end
  if GetContainerItemInfo then
    local ok, _, count, locked, _, _, _, link, _, _, id = pcall(GetContainerItemInfo, bag, slot)
    if ok then
      id = id or (type(link) == "string" and tonumber(link:match("item:(%d+)")))
      return id, count or 1, locked
    end
  end
end

-- Required level of an item: from the game, else from ns.ITEM_MIN_LEVEL (class Data.lua).
local function MinLevel(id)
  local f = (C_Item and C_Item.GetItemInfo) or GetItemInfo
  if f then
    local ok, _, _, _, _, minLevel = pcall(f, id)
    if ok and type(minLevel) == "number" and ns.Readable(minLevel) then return minLevel end
  end
  return ns.ITEM_MIN_LEVEL and ns.ITEM_MIN_LEVEL[id] or 0
end

local function LevelOf(unit)
  local ok, lvl = pcall(UnitLevel, unit)
  if ok and type(lvl) == "number" and ns.Readable(lvl) and lvl > 0 then return lvl end
end

-- The bag slot with the best item from the list (first in the list wins) that this player's
-- level can use, fullest stack first.
local function FindStack(ids, unit)
  local rank = {}
  local lvl = unit and LevelOf(unit)
  for i, id in ipairs(ids or {}) do
    if not lvl or MinLevel(id) <= lvl then rank[id] = i end
  end
  local best
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) do
      local id, count, locked = SlotItem(bag, slot)
      local r = id and rank[id]
      if r and not locked and (not best or r < best.r or (r == best.r and count > best.count)) then
        best = { bag = bag, slot = slot, id = id, count = count, r = r }
      end
    end
  end
  return best
end

local function ItemName(id)
  if C_Item and C_Item.GetItemNameByID then
    local ok, n = pcall(C_Item.GetItemNameByID, id)
    if ok and n then return n end
  end
  if GetItemInfo then
    local ok, n = pcall(GetItemInfo, id)
    if ok and n then return n end
  end
  return "item " .. tostring(id)
end

---------------------------------------------------------------------------
-- Who gets what
---------------------------------------------------------------------------
local function Members()
  local list = {}
  local n = (GetNumSubgroupMembers and GetNumSubgroupMembers()) or 4
  for i = 1, math.min(n, 4) do list[#list + 1] = "party" .. i end
  return list
end

local function InTradeRange(unit)
  if not CheckInteractDistance then return true end
  local ok, near = pcall(CheckInteractDistance, unit, TRADE_RANGE)
  return ok and near and true or false
end

local function Usable(unit)
  return UnitExists(unit) and UnitIsPlayer(unit) and (not UnitIsConnected or UnitIsConnected(unit))
    and not (UnitIsDeadOrGhost and UnitIsDeadOrGhost(unit))
end

local function Recent(tool, name)
  local t = given[tool.key] and given[tool.key][name]
  return t and (Now() - t) < (tool.oncePer or 300)
end

local function MarkGiven(tool, name, when)
  given[tool.key] = given[tool.key] or {}
  given[tool.key][name] = when
end

---------------------------------------------------------------------------
-- Filling the trade window
---------------------------------------------------------------------------
local function FreeTradeSlot()
  if not GetTradePlayerItemInfo then return 1 end
  for i = 1, 6 do
    local ok, name = pcall(GetTradePlayerItemInfo, i)
    if ok and not name then return i end
  end
end

local function Pickup(bag, slot)
  if C_Container and C_Container.PickupContainerItem then return C_Container.PickupContainerItem(bag, slot) end
  if PickupContainerItem then return PickupContainerItem(bag, slot) end
end

local function Fill(tool, unit, name)
  if CursorHasItem and CursorHasItem() then return end
  local stack = FindStack(tool.items(unit), unit)
  if not stack then
    ns.Print(ns.T("GB_OUT", ns.T(tool.key)))
    return
  end
  local at = FreeTradeSlot()
  if not at or not ClickTradeButton then return end
  local ok = pcall(Pickup, stack.bag, stack.slot)
  if not ok then return end
  pcall(ClickTradeButton, at)
  if CursorHasItem and CursorHasItem() and ClearCursor then ClearCursor() end
  MarkGiven(tool, name, Now())
  lastFill = { tool = tool, name = name, done = false }
  ns.Print(ns.T("GB_PUT", stack.count, ItemName(stack.id), name))
end

-- The tool for a trade with this player: the one we clicked, or else the first tool they
-- haven't had lately (a party member who opens a trade with you).
local function ToolFor(name)
  if pending and pending.name == name and Now() - pending.time < 20 then return pending.tool end
  if ns.db.groupBarOff then return nil end
  for _, t in ipairs(Tools()) do
    if not Recent(t, name) then return t end
  end
end

local function OnTradeShow()
  tradeOpen = true
  local name = NameOf("npc")
  if not name then return end
  local inParty = false
  for _, unit in ipairs(Members()) do
    if UnitExists(unit) and NameOf(unit) == name then inParty = true end
  end
  local tool = inParty and ToolFor(name)
  pending = nil
  if tool then Fill(tool, "npc", name) end
end

local function OnTradeClosed()
  tradeOpen = false
  local f = lastFill
  if f and not f.done and C_Timer then
    -- No "trade complete" message within a second: the trade was cancelled, so they can
    -- have it next time.
    C_Timer.After(1, function()
      if not f.done then MarkGiven(f.tool, f.name, nil) end
      if lastFill == f then lastFill = nil end
    end)
  end
end

---------------------------------------------------------------------------
-- The click: open a trade with the next party member who needs it
---------------------------------------------------------------------------
function ns.GroupTrade(tool)
  tool = tool or Tools()[1]
  if not tool then ns.Print(ns.T("GB_NONE_CLASS")) return end
  if InCombat() then ns.Print(ns.T("GB_COMBAT")) return end
  if not (IsInGroup and IsInGroup()) then ns.Print(ns.T("GB_SOLO")) return end
  if tradeOpen then
    local name = NameOf("npc")
    if name then Fill(tool, "npc", name) end
    return
  end
  local units = Members()
  -- A party member you have targeted gets it, even if they already had one.
  if UnitExists("target") then
    local tname = NameOf("target")
    for _, unit in ipairs(units) do
      if tname and Usable(unit) and NameOf(unit) == tname then
        if not InTradeRange("target") then ns.Print(ns.T("GB_FAR", tname)) return end
        if not FindStack(tool.items(unit), unit) then ns.Print(ns.T("GB_OUT", ns.T(tool.key))) return end
        pending = { tool = tool, name = tname, time = Now() }
        local ok = InitiateTrade and pcall(InitiateTrade, "target")
        if not ok then ns.Print(ns.T("GB_MANUAL", tname)) end
        return
      end
    end
  end
  local inRange, all = 0, #units
  for step = 1, all do
    local i = (nextIndex + step - 1) % all + 1
    local unit = units[i]
    local name = Usable(unit) and NameOf(unit)
    if name and InTradeRange(unit) then
      inRange = inRange + 1
      if not Recent(tool, name) then
        if not FindStack(tool.items(unit), unit) then
          ns.Print(ns.T("GB_OUT", ns.T(tool.key)))
          return
        end
        nextIndex = i
        pending = { tool = tool, name = name, time = Now() }
        local ok = InitiateTrade and pcall(InitiateTrade, unit)
        if not ok then ns.Print(ns.T("GB_MANUAL", name)) end
        return
      end
    end
  end
  if inRange > 0 then
    -- Everyone nearby has had one: the next click starts a new round.
    given[tool.key] = {}
    ns.Print(ns.T("GB_ROUND"))
  else
    ns.Print(ns.T("GB_RANGE"))
  end
end

---------------------------------------------------------------------------
-- The bar
---------------------------------------------------------------------------
local SIZE = 32

local function Build()
  bar = CreateFrame("Frame", "@ADDON@GroupBar", UIParent)
  bar:SetSize(SIZE, SIZE)
  local p = ns.db.groupBarPos
  if p then bar:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else bar:SetPoint("CENTER", UIParent, "CENTER", 300, -110) end
  bar:SetScale(ns.db.groupBarScale or 1)
  bar:SetFrameStrata("MEDIUM")
  bar:SetMovable(true)
  bar:SetClampedToScreen(true)
  bar:Hide()
end

local function MakeButton(i, tool)
  local b = CreateFrame("Button", nil, bar)
  b:SetSize(SIZE, SIZE)
  b:SetPoint("LEFT", bar, "LEFT", (i - 1) * (SIZE + 4), 0)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetAllPoints()
  b.icon:SetTexture(tool.icon)
  b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  b:RegisterForClicks("LeftButtonUp")
  b:RegisterForDrag("LeftButton")
  b:SetScript("OnClick", function() ns.GroupTrade(tool) end)
  b:SetScript("OnDragStart", function() if IsShiftKeyDown() and not InCombat() then bar:StartMoving() end end)
  b:SetScript("OnDragStop", function()
    bar:StopMovingOrSizing()
    local point, _, relPoint, x, y = bar:GetPoint()
    ns.db.groupBarPos = { point, relPoint, x, y }
  end)
  b:EnableMouseWheel(true)
  b:SetScript("OnMouseWheel", function(_, delta)
    if not IsControlKeyDown() then return end
    local s = math.max(0.6, math.min(2.5, bar:GetScale() + delta * 0.1))
    bar:SetScale(s)
    ns.db.groupBarScale = s
  end)
  b:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(ns.T(tool.key))
    GameTooltip:AddLine(ns.T(tool.key .. "_TIP"), 0.6, 0.8, 1, true)
    GameTooltip:AddLine(ns.T("GB_MOVE"), 0.6, 0.6, 0.6, true)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  return b
end

local function Update()
  if not bar then return end
  local tools = Tools()
  for i, tool in ipairs(tools) do
    buttons[i] = buttons[i] or MakeButton(i, tool)
    buttons[i]:Show()
  end
  for i = #tools + 1, #buttons do buttons[i]:Hide() end
  bar:SetWidth(math.max(1, #tools) * (SIZE + 4) - 4)
  local show = #tools > 0 and not ns.db.groupBarOff and IsInGroup and IsInGroup() and not InCombat()
  if show then bar:Show() else bar:Hide() end
end
ns.UpdateGroupBar = Update

ns.RegisterModule(function()
  if not ns.GROUP_TRADES then return end
  Build()
  local ev = CreateFrame("Frame")
  for _, e in ipairs({ "GROUP_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED", "SPELLS_CHANGED", "TRADE_SHOW", "TRADE_CLOSED", "UI_INFO_MESSAGE" }) do
    ev:RegisterEvent(e)
  end
  ev:SetScript("OnEvent", function(_, event, a1, a2)
    if event == "TRADE_SHOW" then
      if C_Timer then C_Timer.After(0.2, OnTradeShow) else OnTradeShow() end
    elseif event == "TRADE_CLOSED" then
      OnTradeClosed()
    elseif event == "UI_INFO_MESSAGE" then
      local msg = a2 or a1
      if lastFill and ERR_TRADE_COMPLETE and msg == ERR_TRADE_COMPLETE then lastFill.done = true end
    else
      Update()
    end
  end)
  Update()
end)

-- "/@SLASH@ trade": the first tool's next hand-out (for a key binding or a macro).
ns.RegisterCommand("trade", true, function() ns.GroupTrade() end)
ns.RegisterCommand("groupbar", true, function()
  ns.db.groupBarOff = not ns.db.groupBarOff
  ns.Print(ns.T(ns.db.groupBarOff and "GB_OFF" or "GB_ON"))
  Update()
end)
