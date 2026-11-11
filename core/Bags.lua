-- @ADDON@: bag check. Disenchant, AH or vendor for green and blue gear, plus white gear
-- that is no upgrade and grey junk.
-- Advice shows in item tooltips, and /@SLASH@ de opens a window that lists your bags.
-- With a vendor open you sell from the window; with Enchanting you disenchant from it.
-- AH prices come from Auctionator (do a full scan at the AH first).
-- Disenchant results are Classic tables and can differ in Forever.
local _, ns = ...

local function HasAuctionator()
  return Auctionator and Auctionator.API and Auctionator.API.v1
    and Auctionator.API.v1.GetAuctionPriceByItemID
end

local function Price(id)
  if not HasAuctionator() then return nil end
  local ok, p = pcall(Auctionator.API.v1.GetAuctionPriceByItemID, "@ADDON@", id)
  if ok and type(p) == "number" and p > 0 then return p end
  return nil
end

local function PriceLink(link)
  if not (HasAuctionator() and Auctionator.API.v1.GetAuctionPriceByItemLink) then return nil end
  local ok, p = pcall(Auctionator.API.v1.GetAuctionPriceByItemLink, "@ADDON@", link)
  if ok and type(p) == "number" and p > 0 then return p end
  return nil
end

local function Bracket(ilvl)
  for _, b in ipairs(ns.DE_BRACKETS) do
    if ilvl <= b.max then return b end
  end
end

-- Expected value of a disenchant. Returns value (or nil), bracket, main material.
local function DEValue(ilvl, quality, isWeapon)
  local b = Bracket(ilvl)
  if not b then return nil end
  local outcomes
  if quality >= 3 then
    outcomes = { { b.rare, 1, 1, 1.0 } }
  else
    local pd, pe = b.pd, b.pe
    if isWeapon then pd, pe = pe, pd end
    outcomes = { { b.dust[1], b.dust[2], b.dust[3], pd }, { b.ess[1], b.ess[2], b.ess[3], pe } }
    if b.shard and b.ps > 0 then table.insert(outcomes, { b.shard, 1, 1, b.ps }) end
  end
  local ev, priced = 0, 0
  for _, o in ipairs(outcomes) do
    local p = Price(o[1])
    if p then
      ev = ev + o[4] * (o[2] + o[3]) / 2 * p
      priced = priced + o[4]
    end
  end
  local mainMat = outcomes[1][1]
  if isWeapon and #outcomes > 1 and outcomes[2][4] > outcomes[1][4] then mainMat = outcomes[2][1] end
  if priced < 0.5 then return nil, b, mainMat end
  return ev, b, mainMat
end

-- Assesses an item. isBound = true if the item is already bound.
function ns.Evaluate(link, isBound)
  local ok, name, _, quality, ilvl, _, _, _, _, equipLoc, _, sellPrice, classID, _, bindType = pcall(ns.ItemInfo, link)
  if not ok or not name then return nil end
  if not (classID == 2 or classID == 4) then return nil end
  if not quality or quality < 2 or quality > 3 then return nil end
  if not equipLoc or equipLoc == "" or equipLoc == "INVTYPE_BODY" or equipLoc == "INVTYPE_TABARD" then return nil end

  local r = { vendor = sellPrice or 0 }
  r.tradeable = bindType ~= 1 and not isBound
  if r.tradeable then r.ah = PriceLink(link) end

  local de, b, mainMat = DEValue(ilvl or 1, quality, classID == 2)
  local skill = ns.GetProfSkill("Enchanting")
  r.req = b and b.req or 1
  r.canDE = skill ~= nil and skill >= r.req
  r.hasEnchanting = skill ~= nil
  r.de = de
  r.needsMat = r.canDE and mainMat and ns.EnchantNeedsMat and ns.EnchantNeedsMat(mainMat)
  r.mainMat = mainMat

  local best = { key = "vendor", value = r.vendor }
  if r.ah and r.ah * 0.95 > best.value then best = { key = "ah", value = r.ah * 0.95 } end
  if r.canDE and r.de and r.de > best.value then best = { key = "de", value = r.de } end

  -- If you need the material for Enchanting, DE wins unless the AH pays more than double.
  if r.needsMat and best.key ~= "de" then
    if not (best.key == "ah" and r.de and best.value > 2 * r.de) then
      best = { key = "de", value = r.de, reason = ns.T("DE_NEED", ns.ItemName(mainMat)) }
    end
  end
  -- No prices at all but you can disenchant: DE gives materials for the profession.
  if not r.ah and not r.de and r.canDE and best.key == "vendor" then
    best = { key = "de", value = nil, reason = ns.T("DE_NOPRICE") }
  end
  r.best = best
  return r
end

local COLORS = { de = "|cffb070ff", ah = "|cff60ff60", vendor = "|cffffd100", junk = "|cff9d9d9d" }

local function AdviceLine(r)
  local parts = {}
  if r.canDE then
    table.insert(parts, "DE " .. (r.de and ("~" .. ns.Money(r.de)) or "?"))
  elseif r.hasEnchanting then
    table.insert(parts, ns.T("DE_REQ", r.req))
  end
  if r.tradeable then
    table.insert(parts, "AH " .. (r.ah and ns.Money(r.ah) or "?"))
  else
    table.insert(parts, ns.T("DE_BOUND"))
  end
  table.insert(parts, ns.T("DE_VENDOR_PRICE", ns.Money(r.vendor)))
  return string.format("|cff@COLOR@@ADDON@:|r %s%s|r - %s", COLORS[r.best.key] or "", ns.T("DE_" .. r.best.key), table.concat(parts, " · "))
end

local function OnTooltip(tt)
  if ns.db and ns.db.tooltipOff then return end
  if not tt or not tt.GetItem or tt == _G.@ADDON@ScanTooltip then return end
  local ok, _, link = pcall(tt.GetItem, tt)
  if not ok or not link then return end
  local r = ns.Evaluate(link)
  if not r then return end
  tt:AddLine(AdviceLine(r))
  if r.best.reason then tt:AddLine("|cffaaaaaa  (" .. r.best.reason .. ")|r") end
end

---------------------------------------------------------------------------
-- Reading the bags
---------------------------------------------------------------------------
local function NumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) or 0 end
  if GetContainerNumSlots then return GetContainerNumSlots(bag) or 0 end
  return 0
end

local function SlotLink(bag, slot)
  if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(bag, slot) end
  if GetContainerItemLink then return GetContainerItemLink(bag, slot) end
end

-- Count, icon and whether it's bound, for one bag slot.
local function SlotInfo(bag, slot)
  if C_Container and C_Container.GetContainerItemInfo then
    local ok, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
    if ok and type(info) == "table" then return info.stackCount or 1, info.iconFileID, info.isBound end
  end
  if GetContainerItemInfo then
    local ok, icon, count = pcall(GetContainerItemInfo, bag, slot)
    if ok then return count or 1, icon, nil end
  end
  return 1, nil, nil
end

local function Keep()
  ns.db.bagKeep = ns.db.bagKeep or {}
  return ns.db.bagKeep
end

local GROUPS = { "junk", "vendor", "de", "ah" }

-- Profession tools are white weapons too: never offer to sell them.
local TOOLS = {
  [2901] = true, -- Mining Pick
  [7005] = true, -- Skinning Knife
  [5956] = true, -- Blacksmith Hammer
  [6219] = true, -- Arclight Spanner
  [12709] = true, -- Finkle's Skinner
  [19901] = true, -- Zulian Slicer
}

-- White (common) gear from drops: vendor it, unless it would be an upgrade for you
-- (also: fills an empty slot, or more armor / weapon damage than what you wear),
-- it's a fishing pole or a profession tool, or a shirt or tabard.
local function WhiteGear(link)
  local ok, name, _, quality, _, _, _, _, _, equipLoc, _, sell, classID, subclassID = pcall(ns.ItemInfo, link)
  if not ok or not name or quality ~= 1 or not (sell and sell > 0) then return nil end
  if classID ~= 2 and classID ~= 4 then return nil end
  if not equipLoc or equipLoc == "" or equipLoc == "INVTYPE_BODY" or equipLoc == "INVTYPE_TABARD" then return nil end
  if classID == 2 and subclassID == 20 then return nil end -- fishing pole
  local id = tonumber(link:match("item:(%d+)"))
  if id and TOOLS[id] then return nil end
  if ns.CompareToEquipped then
    local okC, delta = pcall(ns.CompareToEquipped, link)
    if okC and type(delta) == "number" and delta > 0 then return nil end
  end
  -- No stats to score: keep it when it fills an empty slot or beats what you wear.
  if ns.PlainGearBetter then
    local okB, better = pcall(ns.PlainGearBetter, link)
    if okB and better then return nil end
  end
  return sell
end

-- Everything worth a decision: green/blue gear (DE, AH or vendor), white gear that
-- isn't an upgrade (vendor) and grey junk.
function ns.BagScan()
  local list = { de = {}, ah = {}, vendor = {}, junk = {}, kept = {} }
  local totals = { de = 0, ah = 0, vendor = 0, junk = 0 }
  local keep = Keep()
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) do
      local link = SlotLink(bag, slot)
      if link then
        local count, icon, bound = SlotInfo(bag, slot)
        local e
        local r = ns.Evaluate(link, bound)
        if r then
          e = { key = r.best.key, value = r.best.value, reason = r.best.reason, r = r }
        else
          local ok, name, _, quality, _, _, _, _, _, _, tex, sell = pcall(ns.ItemInfo, link)
          if ok and name and quality == 0 and (sell or 0) > 0 then
            e = { key = "junk", value = sell * (count or 1) }
            icon = icon or tex
          elseif ok and name and quality == 1 then
            local price = WhiteGear(link)
            if price then
              e = { key = "vendor", value = price * (count or 1), reason = ns.T("BAG_WHITE") }
              icon = icon or tex
            end
          end
        end
        if e then
          e.bag, e.slot, e.link, e.icon = bag, slot, link, icon
          e.id = tonumber(link:match("item:(%d+)"))
          if not e.icon then
            local ok, _, _, _, _, _, _, _, _, _, tex = pcall(ns.ItemInfo, link)
            if ok then e.icon = tex end
          end
          if e.id and keep[e.id] then
            e.kept = true
            table.insert(list.kept, e)
          else
            table.insert(list[e.key], e)
            totals[e.key] = totals[e.key] + (e.value or 0)
          end
        end
      end
    end
  end
  return list, totals
end

---------------------------------------------------------------------------
-- The window. Rows are secure buttons, so a click can sell (with a vendor open)
-- or disenchant without tainting anything. Nothing is changed in combat.
---------------------------------------------------------------------------
local win, sellAll, hint, foot
local lines = {}
local merchantOpen, autoOpened, reopenAfterCombat = false, false, false
local WIDTH, LINE_H, MAX_LINES, SELL_BATCH = 360, 18, 40, 12

local function DisenchantName()
  return ns.SpellInfo(13262) or "Disenchant"
end

local function SellMacro(e) return "/use " .. e.bag .. " " .. e.slot end

local function DEMacro(e) return "/cast " .. DisenchantName() .. "\n" .. SellMacro(e) end

-- What a left-click, shift-left-click and alt-left-click on a row do, and the label.
-- Alt-click disenchants a sell or AH item when you can disenchant it (enchanters keep
-- the best-price advice but can still DE anything).
local function RowAction(e)
  if e.kept then return nil, nil, "|cff888888" .. ns.T("BAG_ACT_KEPT") .. "|r" end
  local shift = merchantOpen and SellMacro(e) or nil
  if e.key == "de" and e.r and e.r.canDE then
    return DEMacro(e), shift, COLORS.de .. ns.T("BAG_ACT_DE") .. "|r"
  end
  local alt = (e.r and e.r.canDE) and DEMacro(e) or nil
  local plusDE = alt and (COLORS.de .. ns.T("BAG_ACT_PLUSDE") .. "|r") or ""
  if (e.key == "vendor" or e.key == "junk") and merchantOpen then
    return SellMacro(e), nil, "|cff60ff60" .. ns.T("BAG_ACT_SELL") .. "|r" .. plusDE, alt
  end
  if e.key == "ah" then return nil, shift, COLORS.ah .. ns.T("BAG_ACT_AH") .. "|r" .. plusDE, alt end
  -- No vendor to sell to: a plain click disenchants.
  if alt then return alt, nil, COLORS.de .. ns.T("BAG_ACT_DE") .. "|r", nil end
  return nil, nil, ""
end

local function SetSecure(b, main, shift, alt)
  b:SetAttribute("type1", main and "macro" or nil)
  b:SetAttribute("macrotext1", main)
  b:SetAttribute("shift-type1", shift and "macro" or nil)
  b:SetAttribute("shift-macrotext1", shift)
  b:SetAttribute("alt-type1", alt and "macro" or nil)
  b:SetAttribute("alt-macrotext1", alt)
end

local Refresh

local function LineTooltip(self)
  local e = self.entry
  if not e then return end
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  if GameTooltip.SetBagItem then
    pcall(GameTooltip.SetBagItem, GameTooltip, e.bag, e.slot)
  else
    GameTooltip:SetHyperlink(e.link)
  end
  GameTooltip:AddLine(" ")
  local main, shift, _, alt = RowAction(e)
  if e.kept then
    GameTooltip:AddLine(ns.T("BAG_TT_UNKEEP"), 0.7, 0.7, 0.7)
  else
    if main and (e.key == "de" or (e.r and e.r.canDE and not merchantOpen and e.key ~= "ah")) then
      GameTooltip:AddLine(ns.T("BAG_TT_DE"), 0.7, 0.45, 1)
    elseif main then
      GameTooltip:AddLine(ns.T("BAG_TT_SELL"), 0.4, 1, 0.4)
    elseif e.key == "ah" then
      GameTooltip:AddLine(ns.T("BAG_TT_AH"), 0.4, 1, 0.4)
    elseif not merchantOpen then
      GameTooltip:AddLine(ns.T("BAG_TT_NOVENDOR"), 0.7, 0.7, 0.7)
    end
    if shift then GameTooltip:AddLine(ns.T("BAG_TT_SHIFT"), 1, 0.82, 0) end
    if alt then GameTooltip:AddLine(ns.T("BAG_TT_ALT"), 0.7, 0.45, 1) end
    GameTooltip:AddLine(ns.T("BAG_TT_KEEP"), 0.7, 0.7, 0.7)
  end
  GameTooltip:Show()
end

local function GetLine(i)
  if lines[i] then return lines[i] end
  local b = CreateFrame("Button", "@ADDON@BagLine" .. i, win, "SecureActionButtonTemplate")
  b:SetHeight(LINE_H)
  b:SetPoint("LEFT", win, "LEFT", 8, 0)
  b:SetPoint("RIGHT", win, "RIGHT", -8, 0)
  b:RegisterForClicks("AnyUp", "AnyDown")
  local hl = b:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(1, 1, 1, 0.08)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetSize(LINE_H - 2, LINE_H - 2)
  b.icon:SetPoint("LEFT", 0, 0)
  b.name = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  b.name:SetPoint("LEFT", b.icon, "RIGHT", 4, 0)
  b.name:SetWidth(190)
  b.name:SetJustifyH("LEFT")
  b.name:SetWordWrap(false)
  b.act = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  b.act:SetPoint("RIGHT", 0, 0)
  b.act:SetWidth(58)
  b.act:SetJustifyH("RIGHT")
  b.value = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  b.value:SetPoint("RIGHT", b.act, "LEFT", -6, 0)
  b.value:SetJustifyH("RIGHT")
  b.head = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  b.head:SetPoint("LEFT", 0, 0)
  b.head:SetJustifyH("LEFT")
  b:SetScript("OnEnter", LineTooltip)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  -- Right-click: keep the item (or stop keeping it). Addon code only, nothing secure.
  b:HookScript("OnMouseUp", function(self, mouse)
    if mouse ~= "RightButton" or not self.entry or not self.entry.id then return end
    local keep = Keep()
    keep[self.entry.id] = (not keep[self.entry.id]) or nil
    GameTooltip:Hide()
    Refresh()
  end)
  lines[i] = b
  return b
end

local function ShowHeader(b, text)
  b.entry = nil
  SetSecure(b, nil, nil)
  b:EnableMouse(false)
  b.icon:Hide(); b.name:Hide(); b.value:Hide(); b.act:Hide()
  b.head:SetText(text)
  b.head:Show()
end

local function ShowEntry(b, e)
  b.entry = e
  local main, shift, label, alt = RowAction(e)
  SetSecure(b, main, shift, alt)
  b:EnableMouse(true)
  b.head:Hide()
  b.icon:SetTexture(e.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
  b.icon:SetDesaturated(e.kept and true or false)
  b.name:SetText(e.link)
  b.name:SetAlpha(e.kept and 0.5 or 1)
  b.value:SetText(e.value and ns.Money(e.value) or "")
  b.act:SetText(label or "")
  b.icon:Show(); b.name:Show(); b.value:Show(); b.act:Show()
end

Refresh = function()
  if not win or not win:IsShown() or InCombatLockdown() then return end
  local list, totals = ns.BagScan()
  hint:SetText(merchantOpen and ns.T("BAG_HINT_VENDOR") or ns.T("BAG_HINT_NOVENDOR"))
  local y = -46
  local n = 0
  local hidden = 0
  local function Add(fn, arg)
    if n >= MAX_LINES then hidden = hidden + 1; return end
    n = n + 1
    local b = GetLine(n)
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", win, "TOPLEFT", 8, y)
    b:SetPoint("TOPRIGHT", win, "TOPRIGHT", -8, y)
    fn(b, arg)
    b:Show()
    y = y - LINE_H
  end
  local sellList = {}
  for _, k in ipairs(GROUPS) do
    local items = list[k]
    if #items > 0 then
      if n > 0 then y = y - 4 end
      Add(ShowHeader, COLORS[k] .. ns.T("DE_GROUP", ns.T("DE_" .. k), #items, ns.Money(totals[k])) .. "|r")
      table.sort(items, function(a, b) return (a.value or 0) > (b.value or 0) end)
      for _, e in ipairs(items) do
        Add(ShowEntry, e)
        if k == "junk" or k == "vendor" then table.insert(sellList, e) end
      end
    end
  end
  if #list.kept > 0 then
    if n > 0 then y = y - 4 end
    Add(ShowHeader, "|cff888888" .. ns.T("BAG_KEPT") .. "|r")
    for _, e in ipairs(list.kept) do Add(ShowEntry, e) end
  end
  if n == 0 then
    Add(ShowHeader, "|cffaaaaaa" .. ns.T("BAG_EMPTY") .. "|r")
  end
  for i = n + 1, #lines do
    SetSecure(lines[i], nil, nil)
    lines[i].entry = nil
    lines[i]:Hide()
  end
  if hidden > 0 then
    foot:SetText("|cffaaaaaa" .. ns.T("BAG_MORE", hidden) .. "|r")
  elseif not HasAuctionator() and (#list.de + #list.ah + #list.vendor) > 0 then
    foot:SetText("|cffaaaaaa" .. ns.T("DE_NO_AUC") .. "|r")
  else
    foot:SetText("")
  end
  foot:ClearAllPoints()
  foot:SetPoint("TOPLEFT", win, "TOPLEFT", 10, y - 4)
  foot:SetWidth(WIDTH - 20)
  y = y - 4 - (foot:GetText() ~= "" and (foot:GetStringHeight() + 4) or 0)

  -- Sell everything in the junk and vendor groups, 12 at a time (the vendor's buyback holds 12).
  local count = math.min(#sellList, SELL_BATCH)
  if merchantOpen and count > 0 then
    local macro = {}
    for i = 1, count do table.insert(macro, SellMacro(sellList[i])) end
    sellAll:SetAttribute("type1", "macro")
    sellAll:SetAttribute("macrotext1", table.concat(macro, "\n"))
    sellAll:SetText(ns.T("BAG_SELLALL", count))
    sellAll:ClearAllPoints()
    sellAll:SetPoint("TOP", win, "TOPLEFT", WIDTH / 2, y - 4)
    sellAll:Show()
    y = y - 30
  else
    sellAll:SetAttribute("type1", nil)
    sellAll:SetAttribute("macrotext1", nil)
    sellAll:Hide()
  end
  win:SetHeight(-y + 10)
end
ns.RefreshBags = Refresh

local function Create()
  if win then return end
  win = CreateFrame("Frame", "@ADDON@Bags", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  win:SetWidth(WIDTH)
  win:SetHeight(80)
  -- Same layer as the settings window, so opening it from there puts it on top.
  win:SetFrameStrata("DIALOG")
  win:SetToplevel(true)
  win:SetClampedToScreen(true)
  win:SetScale(ns.db.bagScale or 1)
  table.insert(ns.themedFrames, win)
  ns.ApplyTheme(win)
  local p = ns.db.bagPos
  if p then
    win:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  else
    win:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 400, -110)
  end
  win:SetMovable(true)
  win:EnableMouse(true)
  win:RegisterForDrag("LeftButton")
  win:SetScript("OnDragStart", function(self) if not ns.db.locked then self:StartMoving() end end)
  win:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.bagPos = { point, relPoint, x, y }
  end)
  win:EnableMouseWheel(true)
  win:SetScript("OnMouseWheel", function(self, delta)
    if not IsControlKeyDown() or ns.db.locked then return end
    local s = math.max(0.6, math.min(1.8, self:GetScale() + delta * 0.05))
    self:SetScale(s)
    ns.db.bagScale = s
  end)
  local title = win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 10, -10)
  title:SetText("|cff@COLOR@@ADDON@|r - " .. ns.T("BAG_TITLE"))
  win.title = title
  hint = win:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint:SetPoint("TOPLEFT", 10, -26)
  hint:SetWidth(WIDTH - 20)
  hint:SetJustifyH("LEFT")
  foot = win:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  foot:SetJustifyH("LEFT")
  local close = CreateFrame("Button", nil, win, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScale(0.7)
  close:SetScript("OnClick", function()
    if not InCombatLockdown() then win:Hide(); ns.db.bagShown = nil end
  end)
  sellAll = CreateFrame("Button", "@ADDON@BagSellAll", win, "SecureActionButtonTemplate,UIPanelButtonTemplate")
  sellAll:SetSize(WIDTH - 40, 24)
  sellAll:RegisterForClicks("AnyUp", "AnyDown")
  sellAll:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(ns.T("BAG_SELLALL_TT"), 1, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  sellAll:SetScript("OnLeave", function() GameTooltip:Hide() end)
  sellAll:Hide()
  win:SetScript("OnShow", function() Refresh() end)
  win:Hide()
end

-- auto: opened by the addon (at a vendor, after combat, after a reload), so it doesn't
-- change whether the window comes back after a /reload or a loading screen.
function ns.ToggleBags(show, auto)
  if InCombatLockdown() then
    ns.Print(ns.T("BAG_COMBAT"))
    return
  end
  Create()
  if show == nil then show = not win:IsShown() end
  autoOpened = false
  if not auto then ns.db.bagShown = show or nil end
  if show then
    win:Show()
    win:Raise()
    Refresh()
  else
    win:Hide()
  end
end

-- Anything the window would let you act on at a vendor?
local function WorthOpening()
  local list = ns.BagScan()
  return #list.junk + #list.vendor + #list.de > 0
end

local refreshQueued = false
local function QueueRefresh()
  if refreshQueued or not win or not win:IsShown() then return end
  refreshQueued = true
  local function Run() refreshQueued = false; Refresh() end
  if C_Timer and C_Timer.After then C_Timer.After(0.2, Run) else Run() end
end

ns.RegisterModule(function()
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt) pcall(OnTooltip, tt) end)
  elseif GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnTooltipSetItem", function(tt) pcall(OnTooltip, tt) end)
    if ItemRefTooltip then ItemRefTooltip:HookScript("OnTooltipSetItem", function(tt) pcall(OnTooltip, tt) end) end
  end

  local ev = CreateFrame("Frame")
  for _, e in ipairs({ "MERCHANT_SHOW", "MERCHANT_CLOSED", "BAG_UPDATE_DELAYED", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD" }) do
    pcall(ev.RegisterEvent, ev, e)
  end
  ev:SetScript("OnEvent", function(_, event)
    local ok, err = pcall(function()
      if event == "MERCHANT_SHOW" then
        merchantOpen = true
        if win and win:IsShown() then
          Refresh()
        elseif not ns.db.bagAutoOff and not InCombatLockdown() and WorthOpening() then
          ns.ToggleBags(true, true)
          autoOpened = true
        end
      elseif event == "MERCHANT_CLOSED" then
        merchantOpen = false
        if win and win:IsShown() and not InCombatLockdown() then
          if autoOpened then win:Hide() else Refresh() end
        end
        autoOpened = false
      elseif event == "PLAYER_ENTERING_WORLD" then
        -- Open before the reload or loading screen: open it again once the bags are read.
        if ns.db.bagShown and not (win and win:IsShown()) then
          local function Reopen()
            if ns.db.bagShown and not InCombatLockdown() then ns.ToggleBags(true, true) end
          end
          if C_Timer and C_Timer.After then C_Timer.After(1, Reopen) else Reopen() end
        end
      elseif event == "BAG_UPDATE_DELAYED" then
        QueueRefresh()
      elseif event == "PLAYER_REGEN_DISABLED" then
        -- Just before combat locks secure frames: clear every click action and hide.
        if win and win:IsShown() then
          for _, b in ipairs(lines) do SetSecure(b, nil, nil) end
          sellAll:SetAttribute("type1", nil)
          win:Hide()
          reopenAfterCombat = true
        end
      elseif event == "PLAYER_REGEN_ENABLED" then
        if reopenAfterCombat then
          reopenAfterCombat = false
          ns.ToggleBags(true, true)
        end
      end
    end)
    if not ok and ns.Debug then ns.Debug("bags: " .. tostring(err)) end
  end)
end)

---------------------------------------------------------------------------
-- A small button on your open bags. Our own frame (never parented to Blizzard's),
-- only anchored to the bag frame that is showing.
---------------------------------------------------------------------------
local bagBtn
-- Blizzard's bags and the bag addons we know. Anything else: a name scan for the
-- usual patterns, once, when a bag opens and none of these is showing.
local BAG_FRAMES = {
  "ContainerFrameCombinedBags", "ContainerFrame1",
  "Baganator_SingleViewBackpackViewFramedefault", "Baganator_SingleViewBackpackViewFrame",
  "Baganator_BackpackViewFrame", "BagnonInventory1", "BagnonInventoryFrame1",
  "AdiBagsContainer1", "ARKINV_Frame1", "BetterBagsBagBackpack", "ElvUI_ContainerFrame",
}
local BAG_PATTERNS = { "^Baganator.*Backpack.*Frame", "^Bagnon.*Inventory", "^BetterBags.*Backpack", "^AdiBagsContainer1$" }
local scanned = {}

local function Visible(f)
  return type(f) == "table" and f.IsVisible and f:IsVisible()
end

local function FindBagFrame()
  for _, name in ipairs(BAG_FRAMES) do
    if Visible(_G[name]) then return _G[name] end
  end
  for name in pairs(scanned) do
    if Visible(_G[name]) then return _G[name] end
  end
end

local function ScanBagAddons()
  for name, f in pairs(_G) do
    if type(name) == "string" and type(f) == "table" and not scanned[name] then
      for _, p in ipairs(BAG_PATTERNS) do
        if name:find(p) and f.IsVisible then scanned[name] = true break end
      end
    end
  end
end

local placedOn
local function PlaceBagButton()
  if not bagBtn then return end
  local f = not ns.db.bagBtnOff and FindBagFrame() or nil
  if not f then
    placedOn = nil
    bagBtn:Hide()
    return
  end
  if f ~= placedOn then
    placedOn = f
    bagBtn:ClearAllPoints()
    bagBtn:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -6, 2)
  end
  bagBtn:Show()
end
ns.PlaceBagButton = PlaceBagButton

local function MakeBagButton()
  bagBtn = CreateFrame("Button", "@ADDON@BagButton", UIParent)
  bagBtn:SetSize(26, 26)
  bagBtn:SetFrameStrata("HIGH")
  local icon = bagBtn:CreateTexture(nil, "ARTWORK")
  icon:SetAllPoints()
  icon:SetTexture("Interface\\Icons\\INV_Enchant_Disenchant")
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  local hl = bagBtn:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(1, 1, 1, 0.2)
  bagBtn:SetScript("OnClick", function() GameTooltip:Hide(); ns.ToggleBags() end)
  bagBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("|cff@COLOR@@ADDON@|r - " .. ns.T("BAG_TITLE"))
    GameTooltip:AddLine(ns.T("BAG_BTN_TT"), 1, 1, 1)
    GameTooltip:Show()
  end)
  bagBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  bagBtn:Hide()
  -- Bag addons make their frames whenever they like, so look twice a second
  -- (a handful of lookups) instead of hooking frames that may not exist yet.
  local watcher = CreateFrame("Frame")
  local acc, scanSoon = 0, false
  -- You opened your bags (key B or the bag bar) but we found no frame: look once for
  -- a bag addon we don't know by name.
  for _, fn in ipairs({ "ToggleAllBags", "OpenAllBags", "ToggleBackpack", "OpenBackpack" }) do
    if _G[fn] then hooksecurefunc(fn, function() scanSoon = true; acc = 0.3 end) end
  end
  watcher:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + (elapsed or 0)
    if acc < 0.5 then return end
    acc = 0
    local ok = pcall(PlaceBagButton)
    if ok and scanSoon then
      scanSoon = false
      if not placedOn and not ns.db.bagBtnOff then
        pcall(ScanBagAddons)
        pcall(PlaceBagButton)
      end
    end
  end)
end

ns.RegisterModule(function() pcall(MakeBagButton) end)

ns.RegisterCommand("bagbutton", true, function()
  ns.db.bagBtnOff = not ns.db.bagBtnOff
  PlaceBagButton()
end)

ns.RegisterCommand("de", true, function() ns.ToggleBags() end)

ns.RegisterCommand("bagauto", true, function()
  ns.db.bagAutoOff = not ns.db.bagAutoOff
  ns.Print(ns.db.bagAutoOff and ns.T("BAG_AUTO_OFF") or ns.T("BAG_AUTO_ON"))
end)

ns.RegisterCommand("tooltip", true, function()
  ns.db.tooltipOff = not ns.db.tooltipOff
  ns.Print(ns.db.tooltipOff and ns.T("TT_OFF") or ns.T("TT_ON"))
end)
