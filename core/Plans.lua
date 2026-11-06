-- @ADDON@: talent plans. The default plan is ns.talents from the class Data.lua; extra
-- plans come from ns.PLAN_STEPS. Every plan must be checked against the live tree:
-- a talent is only taken once its row has enough points spent in that tree.
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

function ns.PlanKey()
  local k = ns.db and ns.db.plan
  if k and ns.PLANS[k] then return k end
  return ns.PLAN_ORDER[1]
end

function ns.ApplyPlan()
  ns.talents = ns.PLANS[ns.PlanKey()].talents
end

function ns.CyclePlan()
  local cur, nextKey = ns.PlanKey(), ns.PLAN_ORDER[1]
  for i, k in ipairs(ns.PLAN_ORDER) do
    if k == cur then nextKey = ns.PLAN_ORDER[(i % #ns.PLAN_ORDER) + 1] end
  end
  ns.db.plan = nextKey
  ns.ApplyPlan()
  ns.Print(ns.T("PLAN_SET", ns.T("PLAN_" .. nextKey)))
  ns.RefreshMain()
  if ns.RefreshTalentGlow then ns.RefreshTalentGlow() end
  if ns.RefreshMenu then ns.RefreshMenu() end
end

ns.RegisterModule(function() ns.ApplyPlan() end)
if #ns.PLAN_ORDER > 1 then
  ns.RegisterCommand("plan", true, function() ns.CyclePlan() end)
end
