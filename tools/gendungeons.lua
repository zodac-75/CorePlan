-- Builds a class's DungeonData.lua from QuestieDB's merged WoW Forever data.
--   QDB=path/to/QuestieDB texlua tools/gendungeons.lua <mage|shaman|druid> classes/<class>/DungeonData.lua
dofile("tools/qload.lua")
local C = (os.getenv("QDB") or "QDB") .. "/src/corrections/Forever/combined/"
local Q = dofile(C .. "foreverQuestDB.lua")
local N = dofile(C .. "foreverNpcDB.lua")
local I = dofile(C .. "foreverItemDB.lua")
local O = dofile(C .. "foreverObjectDB.lua")
local Z = (os.getenv("QDB") or "QDB") .. "/support/Forever/Zones/areaIdToUiMapId.lua"
local toUi = QLoad(Z, "ZoneDB.private.areaIdToUiMapId")
for k, v in pairs(QLoad(Z, "ZoneDB.private.areaIdToUiMapIdOverride")) do toUi[k] = v end

-- Dungeon list from Questie's Forever dungeons.lua (name, alt area IDs, entrances).
local src = io.open((os.getenv("QDB") or "QDB") .. "/support/Forever/Zones/dungeons.lua"):read("a")
local DUN = {}
for id, name, alt, ent in src:gmatch("%[(%d+)%] = {\"([^\"]+)\",([^,]-%b{}),%d+,(%b{})") do
  DUN[tonumber(id)] = { name = name, alt = alt, ent = ent }
end
for id, name, ent in src:gmatch("%[(%d+)%] = {\"([^\"]+)\",nil,%d+,(%b{})") do
  DUN[tonumber(id)] = { name = name, ent = ent }
end

-- Leveling dungeons, in level order, with the usual level ranges.
-- {areaID, low, high, instanceID, faction}: faction "A"/"H" hides it from the other side
-- (it sits in the other faction's capital).
local LIST = {
  {2437, 13, 18, 389, "H"}, {16919, 13, 18, 3065, "A"}, {16611, 15, 20, 2999},
  {718, 15, 24, 43}, {1581, 17, 26, 36}, {209, 20, 30, 33}, {719, 24, 32, 48}, {717, 24, 32, 34, "A"},
  {16732, 26, 31, 2998}, {16544, 28, 33, 2959},
  {721, 29, 38, 90}, {491, 29, 38, 47}, {796, 30, 45, 189}, {722, 37, 46, 129}, {1337, 41, 51, 70},
  {1176, 44, 54, 209}, {2100, 46, 55, 349}, {1477, 50, 60, 109}, {1584, 52, 60, 230}, {1583, 55, 60, 229},
  {2557, 56, 60, 429}, {2057, 58, 60, 289}, {2017, 58, 60, 329},
}
-- New WoW Forever dungeons that QuestieDB has no data for yet: name, levels and the zone they're in.
-- {name, low, high, uiMapID, where (English, Swedish)}
local NEWER = {
  {"The Drowned City", 35, 40, 1434, "Underwater off the coast west of Grom'gol", "Under vattnet utanför kusten väster om Grom'gol"},
  {"Krol'dok Stronghold", 40, 45, 2548, "Riverglades", "Riverglades"},
  {"Alcaz Prison", 48, 53, 1445, "Alcaz Island", "Alcaz Island"},
  {"Blackmaw Hold", 55, 60, 1447, "Azshara", "Azshara"},
  {"Shaper's Terrace", 58, 60, 1449, "The hills in northern Un'Goro Crater", "Kullarna i norra Un'Goro Crater"},
}

local ALLY, SKY = 4294967373, 4294967296
local HORDE, SKYH = 8589934770, 8589934592
-- Per class: class mask bit and the item classes worth listing as loot
-- (2 = weapon subclasses, 4 = armor subclasses).
local CLASSES = {
  mage = { mask = 128, gear = { [2] = { [7] = true, [10] = true, [15] = true, [19] = true }, [4] = { [0] = true, [1] = true } } },
  shaman = { mask = 64, gear = { [2] = { [0] = true, [1] = true, [4] = true, [5] = true, [10] = true, [13] = true, [15] = true }, [4] = { [0] = true, [2] = true, [3] = true, [6] = true } } },
  warrior = { mask = 1, gear = { [2] = { [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true, [10] = true, [13] = true, [15] = true, [16] = true, [18] = true }, [4] = { [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [6] = true } } },
  paladin = { mask = 2, gear = { [2] = { [0] = true, [1] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true }, [4] = { [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [6] = true } } },
  priest = { mask = 16, gear = { [2] = { [4] = true, [10] = true, [15] = true, [19] = true }, [4] = { [0] = true, [1] = true } } },
  warlock = { mask = 256, gear = { [2] = { [7] = true, [10] = true, [15] = true, [19] = true }, [4] = { [0] = true, [1] = true } } },
  rogue = { mask = 8, gear = { [2] = { [2] = true, [3] = true, [4] = true, [7] = true, [13] = true, [15] = true, [16] = true, [18] = true }, [4] = { [0] = true, [1] = true, [2] = true } } },
  hunter = { mask = 4, gear = { [2] = { [0] = true, [1] = true, [2] = true, [3] = true, [6] = true, [7] = true, [8] = true, [10] = true, [13] = true, [15] = true, [16] = true, [18] = true }, [4] = { [0] = true, [1] = true, [2] = true, [3] = true } } },
  druid = { mask = 1024, gear = { [2] = { [4] = true, [5] = true, [6] = true, [10] = true, [13] = true, [15] = true }, [4] = { [0] = true, [2] = true } } },
}
local CLASS = assert(CLASSES[arg[1]], "usage: gendungeons.lua <mage|shaman|druid|warrior|paladin|warlock|priest|hunter|rogue> <out>")
local SHAMAN = CLASS.mask
local RACECODE = { [1] = "H", [4] = "D", [8] = "N", [64] = "G", [SKY] = "S",
  [2] = "O", [16] = "U", [32] = "T", [128] = "R", [SKYH] = "K" }

-- Quests for either faction; ForMe() in the addon filters by your race.
local function allianceOK(q)
  local c = q[7]
  if c and c ~= 0 and (c & SHAMAN) == 0 then return false end
  if q[18] or q[31] or q[35] then return false end -- profession quests
  return true
end
local function raceCodes(q)
  local r = q[6]
  if not r or r == 0 or ((r & ALLY) == ALLY and (r & HORDE) == HORDE) then return nil end
  local s = ""
  for bit, code in pairs(RACECODE) do if (r & bit) ~= 0 then s = s .. code end end
  return s
end

local function inDungeon(zone, ids) return ids[zone] end

-- Picks a spawn point outside the dungeon: {uiMap, x, y} or "inside".
local function spot(spawns, ids)
  if not spawns then return nil end
  local inside = false
  local zones = {}
  for zone in pairs(spawns) do zones[#zones + 1] = zone end
  table.sort(zones)
  for _, zone in ipairs(zones) do
    if inDungeon(zone, ids) then inside = true
    else
      local ui = toUi[zone]
      local p = spawns[zone][1]
      if ui and ui ~= 0 and p and p[1] and p[1] > 0 then return { ui, p[1], p[2] } end
    end
  end
  return inside and "inside" or nil
end

local function giver(q, ids, fac)
  local sb = q[2]
  if not sb then return nil end
  for _, npc in ipairs(sb[1] or {}) do
    local n = N[npc]
    if n and (not n[13] or n[13]:find(fac)) then
      local s = spot(n[7], ids)
      if s then return { name = n[1], at = s } end
    end
  end
  for _, obj in ipairs(sb[2] or {}) do
    local o = O[obj]
    if o then
      local s = spot(o[4], ids)
      if s then return { name = o[1], at = s } end
    end
  end
  -- Starts from an item: who (or what) drops it, and where, so the arrow can point there.
  for _, item in ipairs(sb[3] or {}) do
    local it = I[item]
    if it then
      for _, npc in ipairs(it[2] or {}) do
        local n = N[npc]
        local s = n and spot(n[7], ids)
        if type(s) == "table" then return { name = it[1], item = item, from = n[1], at = s } end
      end
      for _, obj in ipairs(it[3] or {}) do
        local o = O[obj]
        local s = o and spot(o[4], ids)
        if type(s) == "table" then return { name = it[1], item = item, from = o[1], at = s } end
      end
      return { name = it[1], item = item }
    end
  end
  return nil
end

local out, quests = {}, {}
local function addQuest(id, ids, depth)
  if quests[id] or depth > 12 then return end
  local q = Q[id]
  if not q or not allianceOK(q) then return end
  local r = q[6] or 0
  local forA = r == 0 or (r & ALLY) ~= 0
  local forH = r == 0 or (r & HORDE) ~= 0
  local gA = forA and giver(q, ids, "A") or nil
  local gH = forH and giver(q, ids, "H") or nil
  local function same(a, b)
    if not a or not b then return a == b end
    return a.name == b.name and a.item == b.item and (a.at == b.at or (type(a.at) == "table" and type(b.at) == "table"
      and a.at[1] == b.at[1] and a.at[2] == b.at[2] and a.at[3] == b.at[3]))
  end
  local e = { name = q[1], req = q[4] or 1, lvl = q[5] or q[4] or 1, races = raceCodes(q), g = gA or gH }
  if gA and gH and not same(gA, gH) then e.gh = gH end
  quests[id] = e
  local function filt(list)
    if not list then return nil end
    local r = {}
    for _, p in ipairs(list) do
      if Q[p] and allianceOK(Q[p]) then r[#r + 1] = p; addQuest(p, ids, depth + 1) end
    end
    return #r > 0 and r or nil
  end
  e.any = filt(q[13])
  e.all = filt(q[12])
  e.excl = filt(q[16])
end

local MAGE_GEAR = CLASS.gear

local dungeons = {}
for _, d in ipairs(LIST) do
  local id, lo, hi = d[1], d[2], d[3]
  local D = DUN[id]
  local ids = { [id] = true }
  if D.alt then for a in D.alt:gmatch("%d+") do ids[tonumber(a)] = true end end
  if id == 2557 then for a = 10022, 10027 do ids[a] = true end end -- Dire Maul wings
  local qlist = {}
  for qid, q in pairs(Q) do
    if q[17] and ids[q[17]] and allianceOK(q) and not ((q[24] or 0) & 1 == 1) then
      addQuest(qid, ids, 0)
      if quests[qid] then qlist[#qlist + 1] = qid end
    end
  end
  table.sort(qlist, function(a, b)
    local A, B = quests[a], quests[b]
    if A.lvl ~= B.lvl then return A.lvl < B.lvl end
    return a < b
  end)
  -- Entrances: {areaId, x, y}
  local ent = {}
  for a, x, y in D.ent:gmatch("{(%d+),%s*([%d.]+),%s*([%d.]+)}") do
    local ui = toUi[tonumber(a)]
    if ui and ui ~= 0 then ent[#ent + 1] = { ui, tonumber(x), tonumber(y) } end
  end
  -- Boss loot usable by mages: dropped only by NPCs that live in this dungeon, by at most 2 of them.
  local loot = {}
  for iid, it in pairs(I) do
    local drops = it[2]
    local cls, sub = it[12], it[13]
    if drops and #drops <= 2 and cls and MAGE_GEAR[cls] and MAGE_GEAR[cls][sub] and (it[9] or 0) >= lo - 5 then
      local ok, boss = true, nil
      for _, npc in ipairs(drops) do
        local n = N[npc]
        if not n or not n[7] then ok = false break end
        local only = true
        local count = 0
        for zone, pts in pairs(n[7]) do
          if not ids[zone] then only = false end
          count = count + #pts
        end
        if not only or count > 2 then ok = false break end
        boss = boss or n[1]
      end
      if ok and boss then loot[#loot + 1] = { iid, boss, it[10] or 0 } end
    end
  end
  table.sort(loot, function(a, b) if a[3] ~= b[3] then return a[3] < b[3] end return a[1] < b[1] end)
  dungeons[#dungeons + 1] = { inst = d[4], id = id, name = D.name:gsub("^The Hall", "Hall"), lo = lo, hi = hi, fac = d[5], ent = ent, quests = qlist, loot = loot }
  io.stderr:write(string.format("%-28s quests %2d  loot %2d  entrances %d\n", D.name, #qlist, #loot, #ent))
end

-- Write Lua
local function s(v) return string.format("%q", v) end
local function f(v) return (string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", "")) end
local L = {}
L[#L + 1] = "-- @ADDON@: dungeon quests and loot for WoW Forever (Alliance and Horde)."
L[#L + 1] = "-- Generated from QuestieDB's Forever data (https://github.com/Questie/QuestieDB, GPL-3.0). Do not edit by hand."
L[#L + 1] = "local _, ns = ..."
L[#L + 1] = ""
L[#L + 1] = "-- q = quest IDs; ent = entrances {uiMapID, x, y}; loot = {itemID, boss, required level};"
L[#L + 1] = "-- fac = only shown to that faction; zone/where = no entrance data yet, the zone and a hint instead"
L[#L + 1] = "ns.DUNGEONS = {"
for _, d in ipairs(dungeons) do
  local e = {}
  for _, p in ipairs(d.ent) do e[#e + 1] = string.format("{%d,%s,%s}", p[1], f(p[2]), f(p[3])) end
  local lt = {}
  for _, l in ipairs(d.loot) do lt[#lt + 1] = string.format("{%d,%s,%d}", l[1], s(l[2]), l[3]) end
  L[#L + 1] = string.format("  { id = %d, inst = %d, name = %s, lo = %d, hi = %d,%s\n    ent = {%s},\n    q = {%s},\n    loot = {%s} },",
    d.id, d.inst, s(d.name), d.lo, d.hi, d.fac and (" fac = " .. s(d.fac) .. ",") or "", table.concat(e, ","), table.concat(d.quests, ","), table.concat(lt, ","))
end
for _, n in ipairs(NEWER) do
  L[#L + 1] = string.format("  { id = 0, inst = 0, name = %s, lo = %d, hi = %d, zone = %d, where = { %s, %s },\n    ent = {}, q = {}, loot = {} },",
    s(n[1]), n[2], n[3], n[4], s(n[5]), s(n[6]))
end
L[#L + 1] = "}"
L[#L + 1] = ""
L[#L + 1] = "-- n = name, req = required level, lvl = quest level, any/all = pre-quests, excl = exclusive with,"
L[#L + 1] = "-- races = allowed races when restricted (Alliance H D N G S, Horde O U T R K),"
L[#L + 1] = "-- g = giver {name, map, x, y} / {name, inside} / {name, item} / {item name, map, x, y, item, from = who drops it};"
L[#L + 1] = "-- gh = the Horde giver when it differs"
L[#L + 1] = "ns.DQUESTS = {"
local ids = {}
for id in pairs(quests) do ids[#ids + 1] = id end
table.sort(ids)
for _, id in ipairs(ids) do
  local e = quests[id]
  local parts = { "n=" .. s(e.name), "req=" .. e.req, "lvl=" .. e.lvl }
  if e.any then parts[#parts + 1] = "any={" .. table.concat(e.any, ",") .. "}" end
  if e.all then parts[#parts + 1] = "all={" .. table.concat(e.all, ",") .. "}" end
  if e.excl then parts[#parts + 1] = "excl={" .. table.concat(e.excl, ",") .. "}" end
  if e.races then parts[#parts + 1] = "races=" .. s(e.races) end
  for _, k in ipairs({ "g", "gh" }) do
    local g = e[k]
    if g then
      if g.item and type(g.at) == "table" then
        parts[#parts + 1] = string.format("%s={%s,%d,%s,%s,item=%d,from=%s}", k, s(g.name), g.at[1], f(g.at[2]), f(g.at[3]), g.item, s(g.from))
      elseif g.item then parts[#parts + 1] = string.format("%s={%s,item=%d}", k, s(g.name), g.item)
      elseif g.at == "inside" then parts[#parts + 1] = string.format("%s={%s,inside=true}", k, s(g.name))
      else parts[#parts + 1] = string.format("%s={%s,%d,%s,%s}", k, s(g.name), g.at[1], f(g.at[2]), f(g.at[3])) end
    end
  end
  L[#L + 1] = string.format("  [%d] = {%s},", id, table.concat(parts, ","))
end
L[#L + 1] = "}"
local fh = io.open(arg[2], "w"); fh:write(table.concat(L, "\n") .. "\n"); fh:close()
io.stderr:write("quests total " .. #ids .. "\n")
