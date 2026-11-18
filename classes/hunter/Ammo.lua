-- @ADDON@: ammo tracker. Counts the ammo that fits your ranged weapon (arrows for bows and
-- crossbows, bullets for guns) in your bags, quiver and ammo pouch, and shows it as a supplies
-- line in the plan window: what you shoot, the next best ammo you carry, and a better kind you
-- could buy at your level. Warns out of combat before you run dry, and at a vendor that sells
-- ammo it says how many stacks bring you up to the amount you want to carry (by default what
-- your quiver or ammo pouch holds).
local _, ns = ...

local ARROWS, BULLETS = 2, 3 -- projectile subclasses
local WEAPON_AMMO = { [2] = ARROWS, [18] = ARROWS, [3] = BULLETS } -- bows, crossbows, guns
local PROJECTILE = 6
local STACK = 200

-- Ammo every ammo vendor sells, by required level: { item ID, level, English name }.
local VENDOR = {
  [ARROWS] = { { 2512, 1, "Rough Arrow" }, { 2515, 10, "Sharp Arrow" }, { 3030, 25, "Razor Arrow" }, { 11285, 40, "Jagged Arrow" } },
  [BULLETS] = { { 2516, 1, "Light Shot" }, { 2519, 10, "Heavy Shot" }, { 3033, 25, "Solid Shot" }, { 11284, 40, "Accurate Slugs" } },
}

local function Info(item)
  local ok, name, _, _, _, minLevel, _, _, stack, _, icon, _, classID, subID = pcall(ns.ItemInfo, item)
  if not ok or not name then return nil end
  return { name = name, minLevel = minLevel or 1, stack = stack, icon = icon, classID = classID, subID = subID }
end

-- Arrows or bullets for your ranged weapon, or nil (wand, thrown, nothing).
function ns.AmmoType()
  local ok, link = pcall(GetInventoryItemLink, "player", 18)
  if not ok or not link then return nil end
  local i = Info(link)
  return i and i.classID == 2 and WEAPON_AMMO[i.subID] or nil
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

-- The ammo you carry that fits: a list of { id, count, minLevel, icon, name }, best first.
local function Carried(ammoType)
  local byId, list = {}, {}
  for bag = 0, 4 do
    for slot = 1, NumSlots(bag) do
      local link, count = SlotItem(bag, slot)
      local id = link and tonumber(link:match("item:(%d+)"))
      local i = id and Info(link)
      if i and i.classID == PROJECTILE and (not ammoType or i.subID == ammoType) then
        if not byId[id] then
          byId[id] = { id = id, count = 0, minLevel = i.minLevel, icon = i.icon, name = i.name }
          list[#list + 1] = byId[id]
        end
        byId[id].count = byId[id].count + (count or 1)
      end
    end
  end
  table.sort(list, function(a, b)
    if a.minLevel ~= b.minLevel then return a.minLevel > b.minLevel end
    return a.count > b.count
  end)
  return list
end

-- All ammo that fits your weapon (all ammo when you have no ammo weapon).
function ns.AmmoCount()
  local n = 0
  for _, a in ipairs(Carried(ns.AmmoType())) do n = n + a.count end
  return n
end

-- What your quiver or ammo pouch holds (its slots times a stack), or nil without one.
local function QuiverSize()
  local free = C_Container and C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots
  if not free then return nil end
  local best
  for bag = 1, 4 do
    local ok, _, family = pcall(free, bag)
    -- bag family 1 = quiver (arrows), 2 = ammo pouch (bullets)
    if ok and type(family) == "number" and (family == 1 or family == 2) then
      local size = NumSlots(bag) * STACK
      if not best or size > best then best = size end
    end
  end
  return best
end
ns.AmmoQuiverSize = QuiverSize

-- How much ammo you want to carry: your setting, else what the quiver holds, else 1000.
function ns.AmmoTarget()
  return ns.db.ammoTarget or QuiverSize() or 1000
end
ns.AMMO_TARGETS = { 0, 400, 600, 800, 1000, 1200, 1600, 2000, 2400, 3000, 4000 } -- 0 = quiver

local function Min() return ns.db.ammoMin or 200 end

-- The best vendor ammo for your level, if it beats the best you carry.
local function BetterToBuy(ammoType, carried)
  local level = UnitLevel("player") or 1
  local best
  for _, v in ipairs(VENDOR[ammoType] or {}) do
    if v[2] <= level then best = v end
  end
  local have = carried[1] and carried[1].minLevel or 0
  if best and best[2] > have then return best end
end

local function Icon(icon, n, color)
  return (icon and ("|T" .. tostring(icon) .. ":16:16|t ") or "") .. color .. n .. "|r"
end

local function Status()
  if ns.db.ammoOff then return nil end
  local ammoType = ns.AmmoType()
  if not ammoType then return nil end
  local carried = Carried(ammoType)
  local total = 0
  for _, a in ipairs(carried) do total = total + a.count end
  local color = total < Min() and "|cffff4040" or total < ns.AmmoTarget() and "|cffffd100" or "|cff60ff60"
  local parts = {}
  if carried[1] then
    parts[#parts + 1] = Icon(carried[1].icon, carried[1].count, color) .. " " .. ns.ItemName(carried[1].id, carried[1].name)
  else
    parts[#parts + 1] = color .. "0|r"
  end
  if carried[2] then
    parts[#parts + 1] = "|cffaaaaaa" .. ns.T("AMMO_NEXT") .. "|r " .. Icon(carried[2].icon, carried[2].count, "|cffffffff")
      .. " " .. ns.ItemName(carried[2].id, carried[2].name)
  end
  local better = BetterToBuy(ammoType, carried)
  if better then
    parts[#parts + 1] = "|cff60c0ff" .. ns.T("AMMO_BETTER", ns.ItemName(better[1], better[3]), better[2]) .. "|r"
  end
  return { text = "|cffffd100" .. ns.T("AMMO_LINE") .. "|r " .. table.concat(parts, " · "),
    icon = carried[1] and carried[1].icon or "Interface\\Icons\\INV_Ammo_Arrow_02",
    action = total < Min() }
end

local function Low()
  if ns.db.ammoOff or not ns.AmmoType() then return nil end
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

-- At a vendor: the best ammo they sell for you, and how many stacks reach your target.
function ns.AmmoVendorAdvice()
  if ns.db.ammoOff then return nil end
  local ammoType = ns.AmmoType()
  local n = GetMerchantNumItems and GetMerchantNumItems() or 0
  if not ammoType or n == 0 then return nil end
  local level = UnitLevel("player") or 1
  local best
  for i = 1, n do
    local link = GetMerchantItemLink and GetMerchantItemLink(i)
    local inf = link and Info(link)
    if inf and inf.classID == PROJECTILE and inf.subID == ammoType and inf.minLevel <= level
        and (not best or inf.minLevel > best.minLevel) then
      best = { id = tonumber(link:match("item:(%d+)")), name = inf.name, minLevel = inf.minLevel }
    end
  end
  if not best then return nil end
  local have = ns.AmmoCount()
  local target = ns.AmmoTarget()
  if have >= target then return ns.T("AMMO_VENDOR_FULL", ns.ItemName(best.id, best.name), have, target) end
  local stacks = math.ceil((target - have) / STACK)
  return ns.T("AMMO_VENDOR", ns.ItemName(best.id, best.name), stacks, stacks * STACK, target)
end

ns.RegisterModule(function()
  ns.AddStatusProvider(Status, "Interface\\Icons\\INV_Ammo_Arrow_02")
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("BAG_UPDATE")
  ev:RegisterEvent("UNIT_INVENTORY_CHANGED")
  ev:RegisterEvent("MERCHANT_SHOW")
  ev:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
      local msg = ns.AmmoVendorAdvice()
      if msg then ns.Print("|cff60c0ff" .. msg .. "|r") end
      return
    end
    ns.Debounce("ammo", 2, Check)
  end)
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
  ns.RefreshMain()
end)
