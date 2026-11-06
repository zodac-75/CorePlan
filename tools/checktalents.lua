-- Checks every talent plan of a class against the live talent tree:
--   texlua tools/checktalents.lua <class>
-- Each point must be in a talent that exists, below its max rank, with enough points
-- spent in its tree for its row, and after its prerequisite; levels 10-60 get one point each.
local cls = assert(arg[1], "usage: checktalents.lua <class>")
local root = arg[0]:gsub("tools/checktalents%.lua$", "")
if root == arg[0] then root = "./" end
local trees = dofile(root .. "tools/trees/" .. cls .. ".lua")

local ns = {}
local chunk = assert(loadfile(root .. "classes/" .. cls .. "/Data.lua"))
chunk("x", ns)

-- Same as core/Plans.lua.
local function BuildPlan(startLevel, steps)
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

local errors = 0
local function check(key, plan)
  local spent, rank, perTree = 0, {}, {}
  for lvl = 10, 60 do
    local e = plan[lvl]
    local function bad(msg)
      errors = errors + 1
      print(string.format("%s %s level %d: %s", cls, key, lvl, msg))
    end
    if not e then bad("no talent point") else
      local name, r, max = e:match("^(.-) (%d+)/(%d+)$")
      local t = name and trees[name]
      if not t then bad("unknown talent " .. tostring(e)) else
        r, max = tonumber(r), tonumber(max)
        if max ~= t.max then bad(name .. " has " .. t.max .. " ranks, plan says " .. max) end
        if r ~= (rank[name] or 0) + 1 then bad(name .. " rank " .. r .. " out of order") end
        if r > t.max then bad(name .. " over max rank") end
        if (perTree[t.tree] or 0) < t.req then
          bad(string.format("%s needs %d points in %s, has %d", name, t.req, t.tree, perTree[t.tree] or 0))
        end
        if t.prereq and (rank[t.prereq[1]] or 0) < t.prereq[2] then
          bad(name .. " needs " .. t.prereq[1] .. " " .. t.prereq[2])
        end
        rank[name] = r
        perTree[t.tree] = (perTree[t.tree] or 0) + 1
        spent = spent + 1
      end
    end
  end
  local parts = {}
  for _, tree in ipairs(ns.TALENT_TREES or {}) do table.insert(parts, tostring(perTree[tree] or 0)) end
  print(string.format("%s %-12s %d points  %s", cls, key, spent, table.concat(parts, "/")))
end

for i, key in ipairs(ns.PLAN_ORDER) do
  local steps = ns.PLAN_STEPS and ns.PLAN_STEPS[key]
  check(key, steps and BuildPlan(10, steps) or (i == 1 and ns.talents) or {})
end
if errors > 0 then print(errors .. " errors"); os.exit(1) end
