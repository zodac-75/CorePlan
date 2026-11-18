-- @ADDON@: where to level. A line in the plan window names the one or two zones that fit your
-- level best and the next one coming up (core/ZoneData.lua, from WoW Forever's quests), and a
-- click points the arrow at the zone's quest hub.
local _, ns = ...

local function Faction()
  local ok, f = pcall(UnitFactionGroup, "player")
  if not ok then return nil end
  return (f == "Alliance" and "A") or (f == "Horde" and "H") or nil
end

-- The zone's name in the client language (the game names the area ID itself).
local function ZoneName(z)
  if C_Map and C_Map.GetAreaInfo then
    local ok, n = pcall(C_Map.GetAreaInfo, z[1])
    if ok and type(n) == "string" and n ~= "" then return n end
  end
  return z[7]
end
ns.LevelZoneName = ZoneName

-- Zones for a level: up to two that fit now (range covers it, closest to its middle first)
-- and the next one starting within five levels.
function ns.LevelZones(level, faction)
  local list = ns.LEVEL_ZONES and ns.LEVEL_ZONES[faction or Faction() or ""]
  if not list or not level or level >= 60 then return {}, nil end
  local fits = {}
  for _, z in ipairs(list) do
    if z[2] <= level + 1 and z[3] >= level then fits[#fits + 1] = z end
  end
  table.sort(fits, function(a, b)
    local da, db = math.abs((a[2] + a[3]) / 2 - level - 1), math.abs((b[2] + b[3]) / 2 - level - 1)
    if da ~= db then return da < db end
    return a[1] < b[1]
  end)
  local now = { fits[1], fits[2] }
  local nextZone
  for _, z in ipairs(list) do
    if z[2] > level + 1 and z[2] <= level + 5 and z ~= now[1] and z ~= now[2] then
      if not nextZone or z[2] < nextZone[2] then nextZone = z end
    end
  end
  return now, nextZone
end

local function WayTo(z)
  if z and ns.SetWaypoint then ns.SetWaypoint(z[4], z[5], z[6], ns.T("LZ_HUB", ZoneName(z))) end
end

local function Line()
  if ns.db.levelZonesOff then return nil end
  local now, nextZone = ns.LevelZones(UnitLevel("player") or 1)
  if not now[1] and not nextZone then return nil end
  local parts = {}
  for _, z in ipairs(now) do parts[#parts + 1] = string.format("%s %d-%d", ZoneName(z), z[2], z[3]) end
  local text = "|cffffd100" .. ns.T("LZ_LINE") .. "|r " .. table.concat(parts, " · ")
  if nextZone then text = text .. " |cffaaaaaa" .. ns.T("LZ_NEXT", ZoneName(nextZone), nextZone[2]) .. "|r" end
  return { text = text, icon = "Interface\\Icons\\INV_Misc_Map_01", tip = ns.T("LZ_TIP"),
    click = function() WayTo(now[1] or nextZone) end,
    rclick = function() WayTo(now[2] or nextZone) end }
end

ns.RegisterModule(function()
  ns.AddStatusProvider(Line)
end)

ns.RegisterCommand("levelzones", true, function()
  ns.db.levelZonesOff = not ns.db.levelZonesOff
  ns.Print(ns.db.levelZonesOff and ns.T("LZ_OFF") or ns.T("LZ_ON"))
  ns.RefreshMain()
end)
