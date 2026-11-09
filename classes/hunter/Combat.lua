-- @ADDON@: combat helper. Calls out Mongoose Bite and Counterattack (Survival) when they
-- light up, and reminds you of your pet (missing, dead or low), Hunter's Mark and
-- Serpent Sting on your target.
local _, ns = ...

local function Pct(unit)
  if UnitHealthPercent then
    local ok, p = pcall(UnitHealthPercent, unit)
    if ok and ns.Readable(p) then return p <= 1 and p * 100 or p end
  end
  local ok, cur, max = pcall(function() return UnitHealth(unit), UnitHealthMax(unit) end)
  if ok and ns.Readable(cur) and ns.Readable(max) and max > 0 then return cur / max * 100 end
end

local function Update()
  local hasTarget = ns.HasHostileTarget()
  local inCombat = UnitAffectingCombat("player")
  local plan = ns.PlanKey()
  local main, sub, state

  if inCombat and hasTarget and plan == "sv" then
    if ns.SpellUsable("Counterattack") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "COUNTERATTACK!", ns.T("SH_COUNTER"), "Counterattack")
    elseif ns.SpellUsable("Mongoose Bite") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "MONGOOSE BITE!", ns.T("SH_MONGOOSE"), "Mongoose Bite")
    end
  end

  -- Reminders, most important first, each on its own line (at most three).
  local list = {}
  local function add(color, text, spell) if #list < 3 then table.insert(list, ns.Alert(color, text, spell)) end end

  -- Your pet: Beast Mastery and Marksmanship fight with one (Survival may too).
  if ns.SpellInfo("Revive Pet") and (inCombat or hasTarget) then
    if UnitExists("pet") and UnitIsDead("pet") then
      add("|cffff6060", ns.T("SH_PET_DEAD"), "Revive Pet")
    elseif not UnitExists("pet") and plan ~= "sv" then
      add("|cffff6060", ns.T("SH_PET_MISSING"), "Call Pet")
    elseif UnitExists("pet") and ns.SpellInfo("Mend Pet") then
      local p = Pct("pet")
      if p and p < 40 and ns.AuraMissing("pet", "HELPFUL", "Mend Pet") then
        add("|cff60ff60", ns.T("SH_MENDPET"), "Mend Pet")
      end
    end
  end
  if inCombat and hasTarget then
    if ns.SpellInfo("Hunter's Mark") and ns.AuraMissing("target", "HARMFUL", "Hunter's Mark") then
      add("|cffff9900", ns.T("SH_MARK"), "Hunter's Mark")
    end
    if plan ~= "sv" and ns.SpellInfo("Serpent Sting") and ns.AuraMissing("target", "HARMFUL|PLAYER", "Serpent Sting") then
      add("|cff60ff60", ns.T("SH_STING"), "Serpent Sting")
    end
  end

  -- Icons only: side by side in one row; otherwise one line each.
  if #list > 0 then sub = table.concat(list, ns.db.alertStyle == "icons" and "  " or "\n") end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
