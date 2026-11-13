-- Tests core/AllClass.lua: when a stand-alone addon steps aside for AllClassPlan, and how
-- AllClassPlan copies its settings.
--   texlua tests/allclass_core.lua <out>/MagePlan/AllClass.lua <out>/AllClassPlan_Mage/AllClass.lua
local STANDALONE, PART = arg[1], arg[2]
local errors = {}
local function check(cond, msg) if not cond then table.insert(errors, msg) end end

UnitName = function() return "Me" end
local enabled = {}
C_AddOns = { GetAddOnEnableState = function(name) return enabled[name] and 2 or 0 end }

local function load(file, addon, ns)
  local chunk = assert(loadfile(file))
  chunk(addon, ns)
  return ns
end

print("--- AllClass: kliva åt sidan ---")
do
  enabled = {}
  local ns = load(STANDALONE, "MagePlan", {})
  check(not ns.retired and MagePlanRetired == nil, "utan AllClassPlan klev MagePlan åt sidan")
  enabled = { AllClassPlan = true }
  ns = load(STANDALONE, "MagePlan", {})
  check(not ns.retired, "AllClassPlan utan magedelen: MagePlan klev åt sidan")
  enabled = { AllClassPlan = true, AllClassPlan_Mage = true }
  ns = load(STANDALONE, "MagePlan", {})
  check(ns.retired and MagePlanRetired == true, "AllClassPlan + magedelen: MagePlan klev inte åt sidan")
  MagePlanRetired = nil
  ns = load(PART, "AllClassPlan_Mage", { ALLCLASS = "MagePlan" })
  check(not ns.retired and AllClassPlan_MageRetired == nil, "AllClassPlan-delen klev åt sidan för sig själv")
end

print("--- AllClass: inställningarna följer med ---")
do
  local ns = load(PART, "AllClassPlan_Mage", { ALLCLASS = "MagePlan" })
  MagePlanDB = { textScale = 130, pos = { x = 5 }, plan = "frost" }
  MagePlanGlobal = { lang = "svSE", profiles = { Big = { textScale = 150 } } }
  local global = { profiles = { Mine = {} } }
  local db, imported = ns.ImportSettings("MagePlan", nil, global)
  check(imported and db.textScale == 130 and db.pos.x == 5 and db.plan == "frost", "per karaktär kopierades inte")
  check(db ~= MagePlanDB and db.pos ~= MagePlanDB.pos, "inte en kopia (samma tabell)")
  check(global.lang == "svSE" and global.profiles.Big and global.profiles.Mine, "kontots inställningar slogs inte ihop")
  -- Later logins: nothing is overwritten.
  db.textScale = 110
  MagePlanGlobal.lang = "enUS"
  local db2, again = ns.ImportSettings("MagePlan", db, global)
  check(db2 == db and db2.textScale == 110 and not again, "befintliga inställningar skrevs över")
  check(global.lang == "svSE", "kontots språk skrevs över")
  -- Another class's settings merge in without taking over.
  PaladinPlanGlobal = { lang = "enUS", profiles = { Big = { textScale = 90 }, Pal = {} } }
  ns.ImportSettings("PaladinPlan", nil, global)
  check(global.lang == "svSE" and global.profiles.Big.textScale == 150 and global.profiles.Pal, "andra klassens profiler slogs fel ihop")
  -- No stand-alone settings: a fresh start.
  MagePlanDB, MagePlanGlobal = nil, nil
  local db3, imp3 = ns.ImportSettings("MagePlan", nil, {})
  check(db3 == nil and not imp3, "importerade fast inget fanns")
end

print("--- FEL (" .. #errors .. ") ---")
for _, e in ipairs(errors) do print(e) end
