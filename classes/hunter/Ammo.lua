-- @ADDON@: ammo alert. Counts the arrows or bullets in your bags (quivers and ammo pouches
-- too) and warns you out of combat, in the big alert, before you run dry. Only when your
-- ranged weapon is a bow, gun or crossbow.
local _, ns = ...

local AMMO_WEAPONS = { [2] = true, [3] = true, [18] = true } -- bows, guns, crossbows
local PROJECTILE = 6

local function NeedsAmmo()
  local ok, link = pcall(GetInventoryItemLink, "player", 18)
  if not ok or not link then return false end
  local okI, name, _, _, _, _, _, _, _, _, _, _, classID, subID = pcall(ns.ItemInfo, link)
  return okI and name and classID == 2 and AMMO_WEAPONS[subID] or false
end

local function NumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) or 0 end
  return GetContainerNumSlots and GetContainerNumSlots(bag) or 0
end

local function SlotItem(bag, slot)
  if C_Container and C_Container.GetContainerItemInfo then
    local ok, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
    if ok and type(info) == "table" then return info.hyperlink, info.stackCount or 1 end
    return nil
  end
  if GetContainerItemLink then
    local count = 1
    if GetContainerItemInfo then
      local ok, _, c = pcall(GetContainerItemInfo, bag, slot)
      if ok and c then count = c end
    end
    return GetContainerItemLink(bag, slot), count
  end
end

function ns.AmmoCount()
  local n = 0
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) do
      local link, count = SlotItem(bag, slot)
      if link then
        local ok, name, _, _, _, _, _, _, _, _, _, _, classID = pcall(ns.ItemInfo, link)
        if ok and name and classID == PROJECTILE then n = n + (count or 1) end
      end
    end
  end
  return n
end

local function Min() return ns.db.ammoMin or 200 end

local function Low()
  if ns.db.ammoOff or not NeedsAmmo() then return nil end
  local n = ns.AmmoCount()
  if n < Min() then return n end
end

-- A line in the out-of-combat alert (with Drink!), not just in chat.
if ns.AddRestAlert then
  ns.AddRestAlert(function()
    local n = Low()
    if n then return ns.T("AMMO_LOW", n), "Interface\\Icons\\INV_Ammo_Arrow_02" end
  end)
end

local warned = false
local function Check()
  local n = Low()
  if n and not warned then
    warned = true
    ns.Print("|cffff9900" .. ns.T("AMMO_LOW", n) .. "|r")
  elseif not n then
    warned = false
  end
  ns.RefreshMain()
  if ns.RefreshRestAlert then ns.RefreshRestAlert() end
end

ns.RegisterModule(function()
  ns.AddStatusProvider(function()
    local n = Low()
    if n then return "|cffff9900" .. ns.T("AMMO_STATUS", n) .. "|r" end
  end, "Interface\\Icons\\INV_Ammo_Arrow_02")
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("BAG_UPDATE")
  ev:RegisterEvent("UNIT_INVENTORY_CHANGED")
  ev:SetScript("OnEvent", function() ns.Debounce("ammo", 2, Check) end)
  C_Timer.After(5, function() pcall(Check) end)
end)

-- /@SLASH@ ammo: on/off. /@SLASH@ ammo 300: warn below 300.
ns.RegisterCommand("ammo", true, function(arg)
  local n = tonumber(arg)
  if n then
    ns.db.ammoMin = math.max(0, math.floor(n))
    ns.Print(ns.T("AMMO_MIN", ns.db.ammoMin))
    return
  end
  ns.db.ammoOff = not ns.db.ammoOff
  ns.Print(ns.db.ammoOff and ns.T("AMMO_OFF") or ns.T("AMMO_ON", Min()))
end)
