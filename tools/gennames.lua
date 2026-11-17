-- Writes core/NameData.lua: NPC, object and quest names in the client languages that QuestieDB
-- translates, for the names the dungeon guide shows. The game can't name an NPC you don't see,
-- so the guide looks them up here (ns.NpcName / ns.QuestName in Dungeons.lua).
--   QDB=path/to/QuestieDB texlua tools/gennames.lua
dofile("tools/qload.lua")
local QDB = os.getenv("QDB") or "QDB"
local C = QDB .. "/src/corrections/Forever/combined/"
local N = dofile(C .. "foreverNpcDB.lua")
local O = dofile(C .. "foreverObjectDB.lua")
local I = dofile(C .. "foreverItemDB.lua")
local LOCALES = { "deDE", "frFR", "esES", "esMX", "ptBR", "ruRU" }

-- Names and quest IDs the dungeon data uses (every class).
local names, quests = {}, {}
for _, class in ipairs({ "mage", "shaman", "druid", "warrior", "paladin", "warlock", "priest", "hunter", "rogue" }) do
  local s = io.open("classes/" .. class .. "/DungeonData.lua"):read("a")
  for id in s:gmatch("\n  %[(%d+)%] = {n=") do quests[tonumber(id)] = true end
  for n in s:gmatch('g={"([^"]+)"') do names[n] = true end
  for n in s:gmatch('from="([^"]+)"') do names[n] = true end
  for loot in s:gmatch("loot = (%b{})") do
    for n in loot:gmatch('{%d+,"([^"]+)",%d+}') do names[n] = true end
  end
end

-- Names inside the data texts (zone tips, profession routes, trainers, gear notes): NPCs, items
-- and places, so the sentences can show the client's names. Several words always count; a single
-- word only when it can't be an ordinary word: a trainer's name, an item the profession data
-- lists by ID, or a place that isn't a plain word ("City", "Camp").
--   arg[1] = AreaTable.csv (wago.tools) for the place names; without it places are left out.
local textNames = {} -- English name -> "npc" | "item" | "area"
local textItems, textAreas = {}, {}
do
  local files = { "core/ZoneTips.lua", "core/ProfData.lua", "core/TrainerData.lua", "core/ClassTrainerData.lua" }
  for _, class in ipairs({ "mage", "shaman", "druid", "warrior", "paladin", "warlock", "priest", "hunter", "rogue" }) do
    files[#files + 1] = "classes/" .. class .. "/Data.lua"
  end
  local strs, trainers, listedItems = {}, {}, {}
  for _, f in ipairs(files) do
    local src = io.open(f):read("a")
    for t in src:gmatch('"([^"\n]+)"') do strs[#strs + 1] = t end
    if f:find("TrainerData") then
      for n in src:gmatch('%[?"([^"]+)"%]? = {') do trainers[n] = true end
      for n in src:gmatch('{ "%u+", "([^"]+)"') do trainers[n] = true end
    end
    if f:find("ProfData") then
      for id in src:gmatch("{ ?(%d+), [^{}]-\"") do listedItems[tonumber(id)] = true end
    end
  end
  local all = table.concat(strs, "\n")
  local function inText(n) return all:find("%f[%w]" .. n:gsub("%p", "%%%0") .. "%f[%W]") end
  local WORDS = { Blacksmith = true, Camp = true, City = true }
  local PROFS = { Alchemy = true, Blacksmithing = true, Enchanting = true, Engineering = true, Herbalism = true,
    Leatherworking = true, Mining = true, Skinning = true, Tailoring = true, Cooking = true, Fishing = true,
    ["First Aid"] = true }
  -- Places first (they win over an NPC or item with the same name), then items, then NPCs.
  local csv = arg[1] and io.open(arg[1])
  if csv then
    for line in csv:read("a"):gmatch("[^\n]+") do
      local id, n = line:match('^(%d+),[^,]*,"?([^",]+)')
      id = tonumber(id)
      if id and n and #n >= 4 and n:find("^%u") and not WORDS[n] and not n:find("UNUSED") and not n:find("^Unused")
          and not textNames[n] and inText(n) then
        textNames[n] = "area"; textAreas[n] = id
      elseif id and textAreas[n] and id < textAreas[n] then
        textAreas[n] = id
      end
    end
    csv:close()
  end
  -- Spells and professions the addon knows by ID (core/SpellIds.lua): the client names them.
  for n in io.open("core/SpellIds.lua"):read("a"):gmatch('%["([^"]+)"%] = %d+') do
    -- one word only for the professions: "Charge" or "Blind" may just be English in a sentence
    if #n >= 4 and (n:find(" ") or PROFS[n]) and not textNames[n] and inText(n) then textNames[n] = "spell" end
  end
  for id, v in pairs(I) do
    local n = type(v) == "table" and v[1]
    if n and #n >= 4 and n:find("^%u") and (n:find(" ") or listedItems[id]) and (not textNames[n] or textNames[n] == "item") and inText(n) then
      textNames[n] = "item"
      if not textItems[n] or id < textItems[n] then textItems[n] = id end
    end
  end
  for _, v in pairs(N) do
    local n = type(v) == "table" and v[1]
    if n and #n >= 4 and n:find("^%u") and (n:find(" ") or trainers[n]) and not textNames[n] and inText(n) then
      textNames[n] = "npc"; names[n] = true
    end
  end
end

-- English name -> NPC / object IDs.
local npcIds, objIds = {}, {}
for id, v in pairs(N) do
  local n = type(v) == "table" and v[1]
  if n and names[n] then npcIds[n] = npcIds[n] or {}; table.insert(npcIds[n], id) end
end
for id, v in pairs(O) do
  local n = type(v) == "table" and v[1]
  if n and names[n] then objIds[n] = objIds[n] or {}; table.insert(objIds[n], id) end
end
for _, t in pairs(npcIds) do table.sort(t) end
for _, t in pairs(objIds) do table.sort(t) end

-- Questie's l10n files: `l10n.xLookup["deDE"] = loadstring([[return {...}]])`.
local function lookup(kind, loc)
  local f = io.open(QDB .. "/l10n/Forever/" .. kind .. "/" .. loc .. ".lua")
  if not f then return {} end
  local s = f:read("a"); f:close()
  local body = s:match("loadstring%(%[%[(.-)%]%]%)")
  return body and assert(load(body))() or {}
end

local function q(s) return string.format("%q", s) end
local out = {
  "-- @ADDON@: NPC, object and quest names in other client languages, for the dungeon guide.",
  "-- From QuestieDB's WoW Forever translations (https://github.com/Questie/QuestieDB, GPL-3.0).",
  "-- Generated by tools/gennames.lua. Do not edit by hand.",
  "local _, ns = ...", "", "ns.NAMES = {",
}
local total = 0
for _, loc in ipairs(LOCALES) do
  local npc, obj, qst = lookup("lookupNpcs", loc), lookup("lookupObjects", loc), lookup("lookupQuests", loc)
  local itm = lookup("lookupItems", loc)
  local ii = {}
  local inames = {}
  for n in pairs(textItems) do inames[#inames + 1] = n end
  table.sort(inames)
  for _, n in ipairs(inames) do
    local e = itm[textItems[n]]
    local t = type(e) == "table" and e[1] or (type(e) == "string" and e) or nil
    if t and t ~= n then ii[#ii + 1] = "      [" .. q(n) .. "] = " .. q(t) .. "," end
  end
  local nn, qq = {}, {}
  local sorted = {}
  for n in pairs(names) do sorted[#sorted + 1] = n end
  table.sort(sorted)
  for _, n in ipairs(sorted) do
    local t
    for _, id in ipairs(npcIds[n] or {}) do
      local e = npc[id]; t = t or (type(e) == "table" and e[1] or (type(e) == "string" and e) or nil)
    end
    for _, id in ipairs(objIds[n] or {}) do
      local e = obj[id]; t = t or (type(e) == "table" and e[1] or (type(e) == "string" and e) or nil)
    end
    if t and t ~= n then nn[#nn + 1] = "      [" .. q(n) .. "] = " .. q(t) .. "," end
  end
  local ids = {}
  for id in pairs(quests) do ids[#ids + 1] = id end
  table.sort(ids)
  for _, id in ipairs(ids) do
    local e = qst[id]
    local t = type(e) == "table" and e[1] or (type(e) == "string" and e) or nil
    if t then qq[#qq + 1] = "      [" .. id .. "] = " .. q(t) .. "," end
  end
  out[#out + 1] = "  " .. loc .. " = {"
  out[#out + 1] = "    npc = {"; for _, l in ipairs(nn) do out[#out + 1] = l end; out[#out + 1] = "    },"
  out[#out + 1] = "    quest = {"; for _, l in ipairs(qq) do out[#out + 1] = l end; out[#out + 1] = "    },"
  out[#out + 1] = "    item = {"; for _, l in ipairs(ii) do out[#out + 1] = l end; out[#out + 1] = "    },"
  out[#out + 1] = "  },"
  total = total + #nn + #qq
  print(loc, #nn .. " names", #qq .. " quests")
end
out[#out + 1] = "}"
out[#out + 1] = ""
out[#out + 1] = "-- Names inside the data texts: English name -> { kind, ID }. Items and places get their"
out[#out + 1] = "-- client name from the game by ID (GetItemInfo, C_Map.GetAreaInfo); NPCs from ns.NAMES."
out[#out + 1] = "ns.TEXT_NAMES = {"
do
  local all = {}
  for n in pairs(textNames) do all[#all + 1] = n end
  table.sort(all)
  for _, n in ipairs(all) do
    local k = textNames[n]
    out[#out + 1] = "  [" .. q(n) .. "] = { \"" .. k .. "\"" .. (k == "item" and (", " .. textItems[n]) or k == "area" and (", " .. textAreas[n]) or "") .. " },"
  end
end
out[#out + 1] = "}"
local f = io.open("core/NameData.lua", "w"); f:write(table.concat(out, "\n") .. "\n"); f:close()
local count = 0; for _ in pairs(names) do count = count + 1 end
local found = 0; for n in pairs(names) do if npcIds[n] or objIds[n] then found = found + 1 end end
local nq = 0; for _ in pairs(quests) do nq = nq + 1 end
print(string.format("%d names (%d found in QuestieDB), %d quests, %d translations", count, found, nq, total))
