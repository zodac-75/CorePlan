-- @ADDON@: disenchant, AH eller vendor? Visas i tooltips och via /@SLASH@ de.
-- AH-priser kommer från Auctionator (gör en full scan i AH först).
-- Disenchant-utfallen är Classic-tabeller och kan avvika i Forever.
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

-- Förväntat värde av en disenchant. Returnerar värde (eller nil), bracket, huvudmaterial.
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

-- Bedömer ett föremål. isBound = true om föremålet redan är bundet.
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

  -- Behöver du materialet till Enchanting går DE före, om inte AH ger mer än dubbelt.
  if r.needsMat and best.key ~= "de" then
    if not (best.key == "ah" and r.de and best.value > 2 * r.de) then
      best = { key = "de", value = r.de, reason = ns.T("DE_NEED", ns.ItemName(mainMat)) }
    end
  end
  -- Inga priser alls men du kan disenchanta: DE ger mats till yrket.
  if not r.ah and not r.de and r.canDE and best.key == "vendor" then
    best = { key = "de", value = nil, reason = ns.T("DE_NOPRICE") }
  end
  r.best = best
  return r
end

local COLORS = { de = "|cffb070ff", ah = "|cff60ff60", vendor = "|cffffd100" }

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
  local line = string.format("|cff@COLOR@@ADDON@:|r %s%s|r - %s", COLORS[r.best.key] or "", ns.T("DE_" .. r.best.key), table.concat(parts, " · "))
  return line
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
-- Väskskanning
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

local function SlotBound(bag, slot)
  if C_Container and C_Container.GetContainerItemInfo then
    local ok, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
    if ok and type(info) == "table" then return info.isBound end
  end
  return nil
end

local function ScanBags()
  local groups = { de = {}, ah = {}, vendor = {} }
  local totals = { de = 0, ah = 0, vendor = 0 }
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) do
      local link = SlotLink(bag, slot)
      if link then
        local r = ns.Evaluate(link, SlotBound(bag, slot))
        if r then
          local k = r.best.key
          table.insert(groups[k], link .. " " .. (r.best.value and ns.Money(r.best.value) or "") .. (r.best.reason and (" - " .. r.best.reason) or ""))
          totals[k] = totals[k] + (r.best.value or 0)
        end
      end
    end
  end
  local any = false
  for _, k in ipairs({ "de", "ah", "vendor" }) do
    if #groups[k] > 0 then
      any = true
      ns.Print(COLORS[k] .. ns.T("DE_GROUP", ns.T("DE_" .. k), #groups[k], ns.Money(totals[k])) .. "|r")
      for _, l in ipairs(groups[k]) do ns.Print("  " .. l) end
    end
  end
  if not any then
    ns.Print(ns.T("DE_NONE"))
  else
    ns.Print("|cffaaaaaa" .. ns.T("DE_WARN") .. "|r")
  end
  if not HasAuctionator() then
    ns.Print("|cffff9900" .. ns.T("DE_NO_AUC") .. "|r")
  end
end

ns.RegisterModule(function()
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt) pcall(OnTooltip, tt) end)
  elseif GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnTooltipSetItem", function(tt) pcall(OnTooltip, tt) end)
    if ItemRefTooltip then ItemRefTooltip:HookScript("OnTooltipSetItem", function(tt) pcall(OnTooltip, tt) end) end
  end
end)

ns.RegisterCommand("de", true, ScanBags)

ns.RegisterCommand("tooltip", true, function()
  ns.db.tooltipOff = not ns.db.tooltipOff
  ns.Print(ns.db.tooltipOff and ns.T("TT_OFF") or ns.T("TT_ON"))
end)
