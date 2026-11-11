-- @ADDON@: conjured food, water and mana gem tracker.
local _, ns = ...

local WATER = { 5350, 2288, 2136, 3772, 8077, 8078, 8079 }
local FOOD = { 5349, 1113, 1114, 1487, 8075, 8076 }
ns.CONJURED_WATER, ns.CONJURED_FOOD = WATER, FOOD
local GEMS = { 5514, 5513, 8007, 8008 }
local GEM_SPELLS = { "Conjure Mana Agate", "Conjure Mana Jade", "Conjure Mana Citrine", "Conjure Mana Ruby" }

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

local function Status()
  if not ns.SpellInfo("Conjure Water") then return nil end
  local min = ns.db.waterMin or 10
  local water, food = Count(WATER), Count(FOOD)
  local parts = {}
  table.insert(parts, (water < min and "|cffff6060" or "|cff60ff60") .. ns.T("SUP_WATER", water) .. "|r")
  if ns.SpellInfo("Conjure Food") then
    table.insert(parts, (food < 5 and "|cffff6060" or "|cff60ff60") .. ns.T("SUP_FOOD", food) .. "|r")
  end
  if KnowsAny(GEM_SPELLS) then
    if Count(GEMS) > 0 then
      table.insert(parts, "|cff60ff60" .. ns.T("SUP_GEM") .. "|r")
    else
      table.insert(parts, "|cffff6060" .. ns.T("SUP_NOGEM") .. "|r")
    end
  end
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
