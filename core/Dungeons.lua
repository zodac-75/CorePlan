-- @ADDON@: dungeon guide.
-- A list of dungeons; pick one to see its quests (in your log, completed, available or
-- what's missing), the way to each quest giver or the entrance, and the loot for your class there.
local _, ns = ...

local win, scroll, content
local TK = "dungeon" -- its own text size (ns.TextScale)
local listButtons = {}
local rows, rowPool = {}, {}
local selected
local inLog = {}

-- Sizes at 100% text size. ns.TS scales them with the text size; the window itself can be
-- resized by its corner (the detail pane takes the extra room) and scaled with Ctrl + wheel.
local BASE_LIST_W, DETAIL_W, BASE_ROW_H, WIN_H = 200, 400, 32, 470
local function LIST_W() return ns.TS(BASE_LIST_W, TK) end
local function ROW_H() return ns.TS(BASE_ROW_H, TK) end
local function DetailW() return (scroll and scroll:GetWidth() and scroll:GetWidth() > 50) and scroll:GetWidth() or DETAIL_W end

---------------------------------------------------------------------------
-- Quest state
---------------------------------------------------------------------------
local function IsCompleted(id)
  if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
    return C_QuestLog.IsQuestFlaggedCompleted(id) and true or false
  end
  return IsQuestFlaggedCompleted and IsQuestFlaggedCompleted(id) and true or false
end

local function ScanLog()
  wipe(inLog)
  if C_QuestLog and C_QuestLog.GetInfo and C_QuestLog.GetNumQuestLogEntries then
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
      local info = C_QuestLog.GetInfo(i)
      if info and not info.isHeader and info.questID then inLog[info.questID] = true end
    end
  elseif GetNumQuestLogEntries and GetQuestLogTitle then
    for i = 1, GetNumQuestLogEntries() do
      local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i)
      if not isHeader and questID then inLog[questID] = true end
    end
  end
end

-- Race codes used in DQUESTS.races. Forever's new races (Skyborne on each side) get S or K.
local RACE_CODE = { [1] = "H", [3] = "D", [4] = "N", [7] = "G", [2] = "O", [5] = "U", [6] = "T", [8] = "R" }
local function PlayerRaceCode()
  local _, _, raceID = UnitRace("player")
  return RACE_CODE[raceID] or (ns.IsHorde() and "K" or "S")
end

-- The quest giver for your faction.
local function Giver(q)
  if not q then return nil end
  return (ns.IsHorde() and q.gh) or q.g
end

-- Dungeons in the other faction's capital are left out.
local function Visible(d)
  return not d.fac or d.fac == (ns.IsHorde() and "H" or "A")
end

-- New dungeons without entrance data: ask the game's dungeon journal for the entrance on the zone map.
local function Simple(name) return (name or ""):lower():gsub("^the ", ""):gsub("[^%a]", "") end
local function FindEntrance(d)
  if #d.ent > 0 or not d.zone or d.ejTried then return end
  d.ejTried = true
  if not (C_EncounterJournal and C_EncounterJournal.GetDungeonEntrancesForMap) then return end
  local ok, list = pcall(C_EncounterJournal.GetDungeonEntrancesForMap, d.zone)
  if not ok or type(list) ~= "table" then return end
  local want = Simple(d.name)
  for _, e in ipairs(list) do
    local n = Simple(e.name)
    if n ~= "" and (n == want or n:find(want, 1, true) or want:find(n, 1, true)) and e.position then
      local x, y = e.position.x, e.position.y
      if x and y then d.ent[1] = { d.zone, x * 100, y * 100 } return end
    end
  end
end

local function QuestName(id)
  local q = ns.DQUESTS[id]
  local t = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(id)
  return (t and t ~= "") and t or (q and q.n) or ("#" .. id)
end

local function ForMe(id)
  local q = ns.DQUESTS[id]
  if not q then return false end
  if q.races and not q.races:find(PlayerRaceCode(), 1, true) then return false end
  if q.excl then
    for _, x in ipairs(q.excl) do
      if IsCompleted(x) or inLog[x] then return false end
    end
  end
  return true
end

-- The next thing to do on the way to a quest: returns kind, questID, and the quest that needs
-- it (its giver is usually who you hand the step in to).
-- kind: "done", "inlog", "pickup" (quest to grab, maybe level-locked).
local function NextStep(id, depth, parent)
  depth = depth or 0
  if IsCompleted(id) then return "done", id, parent end
  if inLog[id] then return "inlog", id, parent end
  local q = ns.DQUESTS[id]
  if q and depth < 15 then
    if q.all then
      for _, p in ipairs(q.all) do
        if ForMe(p) and not IsCompleted(p) then return NextStep(p, depth + 1, id) end
      end
    end
    if q.any then
      local anyDone, first = false, nil
      for _, p in ipairs(q.any) do
        if IsCompleted(p) then anyDone = true break end
        if ForMe(p) then
          if inLog[p] then return "inlog", p, id end
          first = first or p
        end
      end
      if not anyDone and first then return NextStep(first, depth + 1, id) end
    end
  end
  return "pickup", id, parent
end

-- Status for a quest row: status, short label, detail line (or nil), quest to show the way to.
local function Status(id)
  local q = ns.DQUESTS[id]
  local kind, step, parent = NextStep(id)
  local level = UnitLevel("player") or 1
  if kind == "done" and step == id then return "done", ns.T("DG_S_DONE") end
  if kind == "inlog" and step == id then return "inlog", ns.T("DG_S_INLOG") end
  if step ~= id then
    if kind == "inlog" then
      -- Point at the giver of the quest that comes after it: that's normally who you hand it in to.
      return "pre", ns.T("DG_S_PRE"), ns.T("DG_PRE_INLOG", QuestName(step)), parent
    end
    local sq = ns.DQUESTS[step]
    local extra = (sq and level < sq.req) and (" " .. ns.T("DG_AT_LEVEL", sq.req)) or ""
    return "pre", ns.T("DG_S_PRE"), ns.T("DG_PRE", QuestName(step)) .. extra, step
  end
  if level < q.req then return "level", ns.T("DG_S_LEVEL", q.req), nil, id end
  return "avail", ns.T("DG_S_AVAIL"), nil, id
end

local function GiverText(id)
  local g = Giver(ns.DQUESTS[id])
  if not g then return ns.T("DG_UNKNOWN") end
  if g.inside then return ns.T("DG_INSIDE", g[1]) end
  if g.item and g.from and g[2] then
    return ns.T("DG_ITEM_FROM", ns.ItemName(g.item, g[1]), g.from, ns.MapName(g[2]))
  end
  if g.item then return ns.T("DG_ITEM", ns.ItemName(g.item, g[1])) end
  return g[1] .. ", " .. ns.MapName(g[2])
end

-- Right-click on a row: open the world map on that zone. The player clicks, so this is their own
-- action, but opening Blizzard's map from addon code can still taint it, so never in combat.
local function OpenMap(map)
  if not map then return end
  if InCombatLockdown() then
    ns.Print(ns.T("DG_MAP_COMBAT"))
    return
  end
  if OpenWorldMap then
    pcall(OpenWorldMap, map)
  elseif ToggleWorldMap and not (WorldMapFrame and WorldMapFrame:IsShown()) then
    pcall(ToggleWorldMap)
  end
  if WorldMapFrame and WorldMapFrame:IsShown() and WorldMapFrame.SetMapID
    and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID() ~= map then
    pcall(WorldMapFrame.SetMapID, WorldMapFrame, map)
  end
end

local function WayTo(id, button)
  local g = Giver(ns.DQUESTS[id])
  if g and g.item and g.from and g[2] then
    -- Item quest: point at the mob (or chest) that drops the item.
    ns.SetWaypoint(g[2], g[3], g[4], g.from .. " – " .. ns.ItemName(g.item, g[1]))
    if button == "RightButton" then OpenMap(g[2]) end
  elseif g and g[2] then
    ns.SetWaypoint(g[2], g[3], g[4], g[1] .. " – " .. QuestName(id))
    if button == "RightButton" then OpenMap(g[2]) end
  elseif g and g.inside then
    ns.Print(ns.T("DG_INSIDE", g[1]))
  elseif g and g.item then
    ns.Print(ns.T("DG_ITEM", ns.ItemName(g.item, g[1])))
  else
    ns.Print(ns.T("DG_NOWAY"))
  end
end

-- How many of a dungeon's quests you can grab or already have.
local function Doable(d)
  local n = 0
  local level = UnitLevel("player") or 1
  local seen = {}
  for _, id in ipairs(d.q) do
    local q = ns.DQUESTS[id]
    if ForMe(id) and not seen[q.n] then
      local st = Status(id)
      if st == "inlog" or (st == "avail" and level >= q.req) then
        n = n + 1
        seen[q.n] = true
      end
    end
  end
  return n
end

---------------------------------------------------------------------------
-- Detail rows (pooled)
---------------------------------------------------------------------------
local ICONS = {
  done = "Interface\\RaidFrame\\ReadyCheck-Ready",
  inlog = "Interface\\RaidFrame\\ReadyCheck-Ready",
  avail = "Interface\\GossipFrame\\AvailableQuestIcon",
  level = "Interface\\GossipFrame\\AvailableQuestIcon",
  pre = "Interface\\GossipFrame\\AvailableQuestIcon",
  door = "Interface\\Minimap\\Tracking\\None",
}

local function GetRow()
  local r = table.remove(rowPool)
  if not r then
    r = CreateFrame("Button", nil, content)
    r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetPoint("TOPLEFT", 4, -3)
    r.right = ns.FontString(r, "small", nil, TK)
    r.right:SetPoint("TOPRIGHT", -8, -4)
    r.text = ns.FontString(r, "small", nil, TK)
    r.text:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
    r.text:SetJustifyH("LEFT")
    r.text:SetWordWrap(false)
    r.sub = ns.FontString(r, "dim", nil, TK)
    r.sub:SetPoint("TOPLEFT", r.text, "BOTTOMLEFT", 0, -2)
    r.sub:SetPoint("RIGHT", -8, 0)
    r.sub:SetJustifyH("LEFT")
    r.sub:SetWordWrap(false)
  end
  r:SetParent(content)
  r:SetWidth(DetailW() - 24)
  r.icon:SetSize(ns.TS(16, TK), ns.TS(16, TK))
  r.text:ClearAllPoints()
  r.text:SetPoint("TOPLEFT", ns.TS(16, TK) + 8, -4)
  r.text:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
  r.icon:SetTexture(nil)
  r.icon:SetDesaturated(false)
  r.icon:SetVertexColor(1, 1, 1)
  r.icon:SetTexCoord(0, 1, 0, 1)
  r.text:SetFontObject(ns.Font("small", TK))
  r.text:SetText("")
  r.sub:SetText("")
  r.right:SetText("")
  r:SetScript("OnClick", nil)
  r:SetScript("OnEnter", nil)
  r:SetScript("OnLeave", nil)
  r:EnableMouse(true)
  r:Show()
  table.insert(rows, r)
  return r
end

local function ReleaseRows()
  for _, r in ipairs(rows) do
    r:Hide()
    table.insert(rowPool, r)
  end
  wipe(rows)
end

local function Header(y, text)
  local r = GetRow()
  r:SetHeight(ns.TS(22, TK))
  r:SetPoint("TOPLEFT", 4, y)
  r:EnableMouse(false)
  r.text:SetText("|cff@COLOR@" .. text .. "|r")
  r.text:SetFontObject(ns.Font("head", TK))
  return y - ns.TS(24, TK)
end

local function SmallText(y, text)
  local r = GetRow()
  r:SetHeight(ns.TS(18, TK))
  r:SetPoint("TOPLEFT", 4, y)
  r:EnableMouse(false)
  r.text:SetText("|cff999999" .. text .. "|r")
  return y - ns.TS(18, TK)
end

---------------------------------------------------------------------------
-- Detail pane
---------------------------------------------------------------------------
local function ShowDetail()
  ReleaseRows()
  local d = selected
  if not d then return end
  local level = UnitLevel("player") or 1
  local y = -4

  -- Title
  local t = GetRow()
  t:SetHeight(ns.TS(26, TK))
  t:SetPoint("TOPLEFT", 4, y)
  t:EnableMouse(false)
  t.text:SetFontObject(ns.Font("large", TK))
  t.text:SetText(d.name)
  t.right:SetText(ns.T("DG_LEVELS", d.lo, d.hi))
  y = y - ns.TS(28, TK)

  -- Entrances (the newest dungeons: from the game's dungeon journal, or the zone and a hint)
  FindEntrance(d)
  if #d.ent == 0 and d.zone then
    local r = GetRow()
    r:SetHeight(ROW_H())
    r:SetPoint("TOPLEFT", 4, y)
    r.text:SetFontObject(ns.Font("small", TK))
    r.icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.text:SetText(ns.T("DG_ENTRANCE"))
    r.sub:SetText(ns.MapName(d.zone) .. (d.where and (" – " .. ns.Tx(d.where)) or ""))
    y = y - ROW_H()
  end
  for i, e in ipairs(d.ent) do
    local r = GetRow()
    r:SetHeight(ROW_H())
    r:SetPoint("TOPLEFT", 4, y)
    r.text:SetFontObject(ns.Font("small", TK))
    r.icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.text:SetText(ns.T("DG_ENTRANCE") .. (#d.ent > 1 and (" " .. i) or ""))
    r.sub:SetText(ns.MapName(e[1]) .. string.format(" (%.0f, %.0f) – ", e[2], e[3]) .. ns.T("DG_CLICK"))
    r:SetScript("OnClick", function(_, button)
      ns.SetWaypoint(e[1], e[2], e[3], d.name)
      if button == "RightButton" then OpenMap(e[1]) end
    end)
    y = y - ROW_H()
  end

  -- Quests, one row per quest name (Questie lists some quests once per variant).
  y = Header(y - 4, ns.T("DG_QUESTS"))
  local shown, seen = 0, {}
  local order = { inlog = 1, avail = 2, level = 3, pre = 4, done = 5 }
  local list = {}
  for _, id in ipairs(d.q) do
    if ForMe(id) then
      local st, label, detail, way = Status(id)
      local q = ns.DQUESTS[id]
      local key = q.n .. "|" .. ((Giver(q) and Giver(q)[1]) or "")
      local prev = seen[key]
      if not prev or order[st] < order[prev.st] then
        local entry = { id = id, st = st, label = label, detail = detail, way = way }
        if prev then
          for i, e in ipairs(list) do if e == prev then list[i] = entry end end
        else
          list[#list + 1] = entry
        end
        seen[key] = entry
      end
    end
  end
  for _, e in ipairs(list) do
    local id, st = e.id, e.st
    local q = ns.DQUESTS[id]
    local r = GetRow()
    r:SetHeight(ROW_H())
    r:SetPoint("TOPLEFT", 4, y)
    r.text:SetFontObject(ns.Font("small", TK))
    r.icon:SetTexture(ICONS[st])
    local color = "|cffffffff"
    if st == "done" then
      r.icon:SetDesaturated(true)
      color = "|cff808080"
    elseif st == "inlog" then
      color = "|cff33ff33"
    elseif st == "avail" then
      color = "|cffffd100"
    else
      r.icon:SetDesaturated(true)
      r.icon:SetVertexColor(1, 0.4, 0.4)
      color = "|cffff8080"
    end
    r.text:SetText(color .. "[" .. q.lvl .. "] " .. QuestName(id) .. "|r")
    r.right:SetText(color .. e.label .. "|r")
    if st == "pre" then
      r.sub:SetText("|cffff8080" .. e.detail .. "|r" .. (e.way and (" – " .. GiverText(e.way)) or ""))
    else
      r.sub:SetText(GiverText(id))
    end
    r:SetScript("OnClick", function(_, button)
      WayTo(e.way or id, button)
    end)
    r:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine(QuestName(id))
      GameTooltip:AddLine(ns.T("DG_TT_LEVEL", q.lvl, q.req), 1, 1, 1)
      GameTooltip:AddLine(GiverText(id), 0.8, 0.8, 0.8)
      GameTooltip:AddLine(ns.T("DG_TT_CLICK"), 0.41, 0.8, 0.94)
      if q.any or q.all then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(ns.T("DG_TT_PRE"), 0.41, 0.8, 0.94)
        for _, p in ipairs(q.all or q.any) do
          if ForMe(p) then
            local mark = IsCompleted(p) and "|TInterface\\RaidFrame\\ReadyCheck-Ready:14|t "
              or (inLog[p] and "|TInterface\\RaidFrame\\ReadyCheck-Waiting:14|t " or "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14|t ")
            GameTooltip:AddLine(mark .. QuestName(p), 1, 1, 1)
          end
        end
      end
      if st ~= "done" then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(ns.T("DG_CLICK"), 0.6, 0.6, 0.6)
      end
      GameTooltip:Show()
    end)
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
    y = y - ROW_H()
    shown = shown + 1
  end
  if shown == 0 then y = SmallText(y, ns.T(d.id == 0 and "DG_NEW" or "DG_NOQUESTS")) end

  -- Loot for your class
  y = Header(y - 6, ns.T("DG_LOOT"))
  local lootShown, waiting = 0, false
  for _, l in ipairs(d.loot) do
    local id, boss, req = l[1], l[2], l[3]
    local name, link, quality, _, _, _, _, _, _, icon, _, classID, subclassID = ns.ItemInfo(id)
    if not name then
      waiting = true
      if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, id) end
    elseif (quality or 0) >= 2 and ns.ItemScore(link) > 0 and ns.CompareToEquipped(link) ~= nil then
      local r = GetRow()
      r:SetHeight(ROW_H())
      r:SetPoint("TOPLEFT", 4, y)
      r.text:SetFontObject(ns.Font("small", TK))
      r.icon:SetTexture(icon)
      r.text:SetText(link)
      r.sub:SetText(ns.T("DG_DROPS", boss) .. (req > 0 and (" – " .. ns.T("DG_REQ", req)) or ""))
      local diff = ns.CompareToEquipped(link)
      if diff and diff > 0 then
        r.right:SetText("|cff33ff33" .. ns.T("DG_UPGRADE", math.floor(diff + 0.5)) .. "|r")
      elseif req > level then
        r.right:SetText("|cff999999" .. ns.T("DG_REQ", req) .. "|r")
      end
      r:SetScript("OnClick", function()
        if IsShiftKeyDown() and ChatEdit_InsertLink then ChatEdit_InsertLink(link) end
      end)
      r:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. id)
        GameTooltip:Show()
      end)
      r:SetScript("OnLeave", function() GameTooltip:Hide() end)
      y = y - ROW_H()
      lootShown = lootShown + 1
    end
  end
  if waiting then
    y = SmallText(y, ns.T("DG_LOADING"))
  elseif lootShown == 0 then
    y = SmallText(y, ns.T(d.id == 0 and "DG_NEW_LOOT" or "DG_NOLOOT"))
  end

  content:SetWidth(DetailW())
  content:SetHeight(-y + 8)
end

---------------------------------------------------------------------------
-- Dungeon list
---------------------------------------------------------------------------
local function RefreshList()
  local level = UnitLevel("player") or 1
  for _, b in ipairs(listButtons) do
    local d = b.dungeon
    local color
    if level > d.hi then color = "|cff808080"
    elseif level >= d.lo - 2 then color = "|cff33ff33"
    elseif level >= d.lo - 6 then color = "|cffffd100"
    else color = "|cffff8080" end
    b.text:SetText(color .. d.name .. "|r")
    b.lvl:SetText(color .. d.lo .. "–" .. d.hi .. "|r")
    local n = Doable(d)
    b.count:SetText(n > 0 and ("|cffffd100" .. n .. "!|r") or "")
    b.sel:SetShown(d == selected)
  end
end

local function Refresh()
  if not win or not win:IsShown() then return end
  ScanLog()
  RefreshList()
  ShowDetail()
  win.title:SetText(ns.T("DG_TITLE"))
  win.clear:SetText(ns.T("DG_CLEAR"))
end
ns.RefreshDungeons = function() ns.Debounce("dungeons", 0.3, Refresh) end

local function Select(d)
  selected = d
  if scroll then scroll:SetVerticalScroll(0) end
  Refresh()
end

-- The dungeon you're in, or the first one that fits your level.
local function DefaultDungeon()
  local _, instType, _, _, _, _, _, instID = GetInstanceInfo()
  if instType == "party" or instType == "raid" then
    for _, d in ipairs(ns.DUNGEONS) do if d.inst == instID then return d end end
  end
  local level = UnitLevel("player") or 1
  for _, d in ipairs(ns.DUNGEONS) do
    if Visible(d) and level >= d.lo - 2 and level <= d.hi then return d end
  end
  for _, d in ipairs(ns.DUNGEONS) do if Visible(d) then return d end end
end

local function CreateWindow()
  win = CreateFrame("Frame", "@ADDON@Dungeons", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  win:SetSize(ns.db.dungeonW or (LIST_W() + DETAIL_W + 24), ns.db.dungeonH or WIN_H)
  win:SetFrameStrata("HIGH")
  win:SetToplevel(true)
  win:SetClampedToScreen(true)
  win:EnableMouse(true)
  win:SetMovable(true)
  win:RegisterForDrag("LeftButton")
  win:SetScript("OnDragStart", win.StartMoving)
  win:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local a, _, b, x, y = self:GetPoint()
    ns.db.dungeonPos = { a, b, x, y }
  end)
  local p = ns.db.dungeonPos
  if p then win:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else win:SetPoint("CENTER", 0, 40) end
  -- Ctrl + mouse wheel resizes the window (anywhere on it, also over the lists).
  win:SetScale(ns.db.dungeonScale or 1)
  local function Resize(delta)
    local s = math.max(0.6, math.min(1.8, win:GetScale() + delta * 0.05))
    win:SetScale(s)
    ns.db.dungeonScale = s
  end
  win:EnableMouseWheel(true)
  win:SetScript("OnMouseWheel", function(_, delta)
    if IsControlKeyDown() and not ns.db.locked then Resize(delta) end
  end)
  -- The scroll areas take the wheel first: Ctrl resizes, a plain wheel still scrolls.
  local function CtrlResize(sf)
    local scrollIt = sf:GetScript("OnMouseWheel")
    sf:SetScript("OnMouseWheel", function(self, delta)
      if IsControlKeyDown() then
        if not ns.db.locked then Resize(delta) end
      elseif scrollIt then
        scrollIt(self, delta)
      end
    end)
  end
  win.CtrlResize = CtrlResize
  table.insert(ns.themedFrames, win)
  ns.ApplyTheme(win)
  -- Not in UISpecialFrames: Esc is for closing quest dialogs, so it must not close the guide too.

  local logo = win:CreateTexture(nil, "ARTWORK")
  logo:SetTexture(ns.MEDIA .. "Icon")
  logo:SetSize(26, 26)
  logo:SetPoint("TOPLEFT", 10, -8)
  win.title = ns.FontString(win, "large", nil, TK)
  win.title:SetPoint("LEFT", logo, "RIGHT", 6, 0)
  win.title:SetTextColor(0.41, 0.8, 0.94)

  local close = CreateFrame("Button", nil, win, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -2, -2)

  -- Left: dungeons for your faction, in a scrollable list
  local listScroll = CreateFrame("ScrollFrame", "@ADDON@DungeonList", win, "UIPanelScrollFrameTemplate")
  listScroll:SetPoint("TOPLEFT", 10, -42)
  listScroll:SetPoint("BOTTOMLEFT", 10, 40)
  local list = CreateFrame("Frame", nil, listScroll)
  listScroll:SetScrollChild(list)
  local i = 0
  for _, d in ipairs(ns.DUNGEONS) do if Visible(d) then
    i = i + 1
    local b = CreateFrame("Button", nil, list)
    b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    b.sel = b:CreateTexture(nil, "BACKGROUND")
    b.sel:SetAllPoints()
    b.sel:SetColorTexture(0.41, 0.8, 0.94, 0.2)
    b.text = ns.FontString(b, "small", nil, TK)
    b.text:SetPoint("LEFT", 4, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(false)
    b.count = ns.FontString(b, "small", nil, TK)
    b.count:SetPoint("LEFT", b.text, "RIGHT", 2, 0)
    b.lvl = ns.FontString(b, "small", nil, TK)
    b.lvl:SetPoint("RIGHT", -4, 0)
    b.dungeon = d
    b:SetScript("OnClick", function() Select(d) end)
    listButtons[i] = b
  end end

  local divider = win:CreateTexture(nil, "ARTWORK")
  divider:SetColorTexture(0.41, 0.8, 0.94, 0.3)
  divider:SetWidth(1)

  win.clear = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
  win.clear:SetPoint("BOTTOMLEFT", 10, 10)
  win.clear:SetScript("OnClick", function() ns.ClearWaypoint() end)

  -- Right: details, scrollable
  scroll = CreateFrame("ScrollFrame", "@ADDON@DungeonScroll", win, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("BOTTOMRIGHT", -30, 22)
  content = CreateFrame("Frame", nil, scroll)
  content:SetSize(DETAIL_W, 400)
  scroll:SetScrollChild(content)
  CtrlResize(scroll)
  CtrlResize(listScroll)

  -- Everything that depends on the text size: list width and rows, divider, buttons.
  local function Layout()
    local lw, bh = LIST_W(), ns.TS(20, TK)
    listScroll:SetWidth(lw - 30)
    for k, b in ipairs(listButtons) do
      b:SetSize(lw - 30, bh)
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", 0, -(k - 1) * (bh + 1))
      b.text:SetWidth(lw - 30 - ns.TS(70, TK))
    end
    list:SetSize(lw - 30, #listButtons * (bh + 1))
    divider:ClearAllPoints()
    divider:SetPoint("TOPLEFT", lw + 6, -40)
    divider:SetPoint("BOTTOMLEFT", lw + 6, 12)
    win.clear:SetSize(lw - 8, ns.TS(22, TK))
    listScroll:SetPoint("BOTTOMLEFT", 10, ns.TS(22, TK) + 18)
    scroll:SetPoint("TOPLEFT", lw + 10, -40)
    local minW = lw + 300
    if win.SetResizeBounds then win:SetResizeBounds(minW, 300, 1600, 1200)
    elseif win.SetMinResize then win:SetMinResize(minW, 300); win:SetMaxResize(1600, 1200) end
    if win:GetWidth() < minW then win:SetWidth(minW) end
  end
  win.Layout = Layout
  Layout()

  -- Drag the corner for width and height; the detail pane takes the room.
  win:SetResizable(true)
  local grip = CreateFrame("Button", nil, win)
  grip:SetSize(14, 14)
  grip:SetPoint("BOTTOMRIGHT", -3, 3)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  grip:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then ns.ShowTextSizeMenu(self, TK) return end
    if not ns.db.locked then win:StartSizing("BOTTOMRIGHT") end
  end)
  ns.GripTooltip(grip)
  grip:SetScript("OnMouseUp", function(_, button)
    if button == "RightButton" then return end
    win:StopMovingOrSizing()
    ns.db.dungeonW, ns.db.dungeonH = win:GetWidth(), win:GetHeight()
    local a, _, b, x, y = win:GetPoint()
    ns.db.dungeonPos = { a, b, x, y }
    if win:IsShown() then ns.RefreshDungeons() end
  end)
  win.grip = grip
  win:SetScript("OnSizeChanged", function()
    ns.Debounce("dungeonsize", 0.05, function() if win:IsShown() then ns.RefreshDungeons() end end)
  end)

  ns.OnTextScale(function()
    Layout()
    if win:IsShown() then ns.RefreshDungeons() end
  end)
  ns.OnResetWindows(function()
    ns.db.dungeonPos, ns.db.dungeonW, ns.db.dungeonH, ns.db.dungeonScale = nil, nil, nil, nil
    win:SetScale(1)
    win:SetSize(LIST_W() + DETAIL_W + 24, WIN_H)
    win:ClearAllPoints()
    win:SetPoint("CENTER", 0, 40)
    Layout()
    if win:IsShown() then ns.RefreshDungeons() end
  end)

  win:SetScript("OnShow", Refresh)
  win:Hide()

  local ev = CreateFrame("Frame")
  for _, e in ipairs({ "QUEST_LOG_UPDATE", "QUEST_TURNED_IN", "QUEST_ACCEPTED", "PLAYER_LEVEL_UP",
    "GET_ITEM_INFO_RECEIVED", "PLAYER_EQUIPMENT_CHANGED" }) do
    pcall(ev.RegisterEvent, ev, e)
  end
  ev:SetScript("OnEvent", function()
    if win:IsShown() then ns.RefreshDungeons() end
  end)
end

function ns.ToggleDungeons(name)
  if not win then return end
  if name and name ~= "" then
    name = name:lower()
    for _, d in ipairs(ns.DUNGEONS) do
      if Visible(d) and d.name:lower():find(name, 1, true) then
        win:Show()
        Select(d)
        return
      end
    end
  end
  if win:IsShown() then win:Hide() return end
  selected = selected or DefaultDungeon()
  win:Show()
end

---------------------------------------------------------------------------
-- When you zone into a dungeon, say how many of its quests you have.
---------------------------------------------------------------------------
local lastInst
local function OnZone()
  local _, instType, _, _, _, _, _, instID = GetInstanceInfo()
  if instType ~= "party" or instID == lastInst then
    if instType ~= "party" then lastInst = nil end
    return
  end
  lastInst = instID
  for _, d in ipairs(ns.DUNGEONS) do
    if d.inst == instID then
      if ns.db.dungeonAutoOpen and win then
        win:Show()
        Select(d)
      end
      ScanLog()
      local have, missing, seen = 0, 0, {}
      for _, id in ipairs(d.q) do
        local q = ns.DQUESTS[id]
        if ForMe(id) and not seen[q.n] then
          seen[q.n] = true
          local st = Status(id)
          if st == "inlog" then have = have + 1
          elseif st == "avail" then missing = missing + 1 end
        end
      end
      if have + missing > 0 then ns.Print(ns.T("DG_ENTER", d.name, have, missing)) end
      return
    end
  end
end

ns.RegisterModule(function()
  CreateWindow()
  -- Stays open through loading screens (/reload, login, zoning into a dungeon): the state is
  -- saved just before a loading screen (the game may hide windows during it) and the window
  -- comes back after it, on the same dungeon.
  local function Restore()
    if not ns.db.dungeonOpen or win:IsShown() then return end
    local want
    for _, d in ipairs(ns.DUNGEONS) do
      if Visible(d) and d.name == ns.db.dungeonSel then want = d end
    end
    selected = want or selected or DefaultDungeon()
    win:Show()
    if selected then pcall(Select, selected) end
  end
  Restore()
  local save = CreateFrame("Frame")
  save:RegisterEvent("PLAYER_LEAVING_WORLD")
  save:RegisterEvent("PLAYER_ENTERING_WORLD")
  save:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LEAVING_WORLD" then
      ns.db.dungeonOpen = win:IsShown() or nil
      ns.db.dungeonSel = selected and selected.name or nil
    else
      Restore()
      C_Timer.After(1, Restore)
    end
  end)
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("PLAYER_ENTERING_WORLD")
  ev:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  ev:SetScript("OnEvent", function() C_Timer.After(2, OnZone) end)
end)

ns.RegisterCommand("dungeons", true, function(rest) ns.ToggleDungeons(rest) end)
ns.RegisterCommand("dungeonauto", true, function()
  ns.db.dungeonAutoOpen = not ns.db.dungeonAutoOpen
  ns.Print(ns.db.dungeonAutoOpen and ns.T("DG_AUTO_ON") or ns.T("DG_AUTO_OFF"))
end)
