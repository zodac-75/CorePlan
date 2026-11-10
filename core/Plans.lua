-- @ADDON@: talent plans (specs). The default plan is ns.talents from the class Data.lua
-- unless ns.PLAN_STEPS has it; the others come from ns.PLAN_STEPS. A plan can also have
-- its own stat weights (ns.PLAN_WEIGHTS) and texts (KEY@plan in the locale).
-- Check every plan against the live tree with tools/checktalents.lua.
local _, ns = ...

-- Builds a level -> "Talent n/max" table from steps of { name, maxRank, count }.
function ns.BuildPlan(startLevel, steps)
  local t, lvl, have = {}, startLevel, {}
  for _, s in ipairs(steps) do
    local name, max, n = s[1], s[2], s[3] or s[2]
    for _ = 1, n do
      have[name] = (have[name] or 0) + 1
      t[lvl] = string.format("%s %d/%d", name, have[name], max)
      lvl = lvl + 1
    end
  end
  return t
end

ns.PLANS = {}
for i, key in ipairs(ns.PLAN_ORDER) do
  local steps = ns.PLAN_STEPS and ns.PLAN_STEPS[key]
  ns.PLANS[key] = { talents = steps and ns.BuildPlan(10, steps) or (i == 1 and ns.talents) or {} }
end

-- The plan you picked (one of ours, or "import" for a talent link you imported).
function ns.PlanChoice()
  local k = ns.db and ns.db.plan
  if k and ns.PLANS[k] then return k end
  return ns.PLAN_ORDER[1]
end

-- The spec the addon acts on (stat weights, combat call-outs, buffs). An imported build
-- acts like the plan of ours that spends most in the same tree.
function ns.PlanKey()
  local c = ns.PlanChoice()
  local p = ns.PLANS[c]
  return (p and p.like) or c
end

-- The picked plan's name for the settings and the plan window.
function ns.PlanName()
  local c = ns.PlanChoice()
  if c == "import" then return ns.T("PLAN_import", ns.T("PLAN_" .. ns.PlanKey())) end
  return ns.T("PLAN_" .. c)
end

-- Stat weights per plan (ns.PLAN_WEIGHTS[key]); plans without their own use ns.STATS.weights.
local baseWeights = ns.STATS and ns.STATS.weights

function ns.ApplyPlan()
  local key = ns.PlanKey()
  ns.talents = ns.PLANS[ns.PlanChoice()].talents
  ns.planTag = "@" .. key
  if ns.STATS then
    ns.STATS.weights = (ns.PLAN_WEIGHTS and ns.PLAN_WEIGHTS[key]) or baseWeights
  end
end

function ns.CyclePlan()
  local cur, nextKey = ns.PlanChoice(), ns.PLAN_ORDER[1]
  for i, k in ipairs(ns.PLAN_ORDER) do
    if k == cur then nextKey = ns.PLAN_ORDER[(i % #ns.PLAN_ORDER) + 1] end
  end
  ns.db.plan = nextKey
  ns.ApplyPlan()
  ns.Print(ns.T("PLAN_SET", ns.PlanName()))
  ns.RefreshMain()
  if ns.RefreshTalentGlow then ns.RefreshTalentGlow() end
  if ns.RefreshMenu then ns.RefreshMenu() end
end

ns.RegisterModule(function() ns.ApplyPlan() end)
if #ns.PLAN_ORDER > 1 then
  ns.RegisterCommand("plan", true, function() ns.CyclePlan() end)
end
