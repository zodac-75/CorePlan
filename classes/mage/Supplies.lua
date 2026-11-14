-- @ADDON@: conjured food, water and mana gem tracker.
local _, ns = ...

local WATER = { 5350, 2288, 2136, 3772, 8077, 8078, 8079 }
local FOOD = { 5349, 1113, 1114, 1487, 8075, 8076 }
ns.CONJURED_WATER, ns.CONJURED_FOOD = WATER, FOOD
local GEMS = { 5514, 5513, 8007, 8008 }
local GEM_SPELLS = { "Conjure Mana Agate", "Conjure Mana Jade", "Conjure Mana Citrine", "Conjure Mana Ruby" }
-- Reagents for teleports (Rune of Teleportation) and portals (Rune of Portals).
local TELE_RUNE, PORTAL_RUNE = { 17031 }, { 17032 }
local CITIES = { "Stormwind", "Ironforge", "Darnassus", "Orgrimmar", "Undercity", "Thunder Bluff" }
local TELE_SPELLS, PORTAL_SPELLS = {}, {}
for _, c in ipairs(CITIES) do
  TELE_SPELLS[#TELE_SPELLS + 1] = "Teleport: " .. c
  PORTAL_SPELLS[#PORTAL_SPELLS + 1] = "Portal: " .. c
end

local lastWater

local function Count(ids)
  local n = 0
  for _, id in ipairs(ids) do
    local f = (C_Item and C_Item.GetItemCount) or GetItemCount
    if f then
      local ok, c = pcall(f, id) -- bags only
      if ok and c then n = n + c end
    end
  end
  return n
end

local function KnowsAny(spells)
  for _, s in ipairs(spells) do
    if ns.SpellInfo(s) then return true end
  end
  return false
end

-- An item's icon (texture or file ID), or nil.
local function ItemIcon(id)
  local icon
  pcall(function()
    icon = (C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(id)) or (GetItemIcon and GetItemIcon(id))
  end)
  return icon
end

-- The icon of the best (highest rank) one of these you carry, else the fallback.
local function CarriedIcon(ids, fallback)
  local f = (C_Item and C_Item.GetItemCount) or GetItemCount
  for i = #ids, 1, -1 do
    local ok, c = pcall(f, ids[i])
    if ok and type(c) == "number" and c > 0 then return ItemIcon(ids[i]) or fallback end
  end
  return fallback
end

-- "|T icon|t 12" in red, yellow or green.
local function IconCount(icon, n, color)
  return "|T" .. tostring(icon) .. ":20:20|t " .. color .. n .. "|r"
end

local function Status()
  if not ns.SpellInfo("Conjure Water") then return nil end
  local min = ns.db.waterMin or 10
  local water, food = Count(WATER), Count(FOOD)
  local parts = {}
  table.insert(parts, IconCount(CarriedIcon(WATER, ns.SpellIcon("Conjure Water") or "Interface\\Icons\\INV_Drink_07"),
    water, water < min and "|cffff6060" or "|cff60ff60"))
  if ns.SpellInfo("Conjure Food") then
    table.insert(parts, IconCount(CarriedIcon(FOOD, ns.SpellIcon("Conjure Food") or "Interface\\Icons\\INV_Misc_Food_10"),
      food, food < 5 and "|cffff6060" or "|cff60ff60"))
  end
  if KnowsAny(GEM_SPELLS) then
    if Count(GEMS) > 0 then
      table.insert(parts, "|cff60ff60" .. ns.T("SUP_GEM") .. "|r")
    else
      table.insert(parts, "|cffff6060" .. ns.T("SUP_NOGEM") .. "|r")
    end
  end
  -- Runes: the rune's icon and how many you carry (red when none, yellow at the last two).
  local function Rune(ids, fallback)
    local n = Count(ids)
    table.insert(parts, IconCount(ItemIcon(ids[1]) or fallback, n, n == 0 and "|cffff6060" or n < 3 and "|cffffd100" or "|cff60ff60"))
  end
  if KnowsAny(TELE_SPELLS) then Rune(TELE_RUNE, "Interface\\Icons\\INV_Misc_Rune_06") end
  if KnowsAny(PORTAL_SPELLS) then Rune(PORTAL_RUNE, "Interface\\Icons\\INV_Misc_Rune_08") end
  return "|cffffffff" .. ns.T("SUP_LINE") .. "|r " .. table.concat(parts, ", ")
end

local function CheckLow()
  if not ns.SpellInfo("Conjure Water") then return end
  local min = ns.db.waterMin or 10
  local water = Count(WATER)
  lastWater = water
  ns.RefreshMain()
  if ns.RefreshRestAlert then ns.RefreshRestAlert() end
end

-- Low on water: a line in the out-of-combat alert (with Drink!), not just in chat.
if ns.AddRestAlert then
  ns.AddRestAlert(function()
    if not ns.SpellInfo("Conjure Water") then return nil end
    local water = Count(WATER)
    if water < (ns.db.waterMin or 10) then
      return ns.T("SUP_LOW", water), ns.SpellIcon("Conjure Water") or "Interface\\Icons\\INV_Drink_18"
    end
  end)
end

ns.RegisterModule(function()
  ns.AddStatusProvider(Status, "Interface\\Icons\\INV_Drink_07")
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("BAG_UPDATE")
  ev:SetScript("OnEvent", function() ns.Debounce("supplies", 1, CheckLow) end)
  C_Timer.After(3, function() pcall(CheckLow) end)
end)

ns.RegisterCommand("water", true, function(rest)
  local n = tonumber((rest or ""):match("(%d+)"))
  if n then
    ns.db.waterMin = n
    ns.Print(ns.T("SUP_SET", n))
    ns.RefreshMain()
  end
end)
