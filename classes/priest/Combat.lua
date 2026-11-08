-- @ADDON@: combat helper. Calls out Mind Blast (Shadow) and Penance (Discipline) when
-- they're ready, and reminds you of a missing Shadow Word: Pain or Vampiric Embrace on
-- your target and a missing Inner Fire.
local _, ns = ...

local function Update()
  local hasTarget = ns.HasHostileTarget()
  local inCombat = UnitAffectingCombat("player")
  local plan = ns.PlanKey()
  local main, sub, state

  if inCombat and hasTarget then
    if plan == "shadow" and ns.SpellUsable("Mind Blast") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "MIND BLAST!", ns.T("SH_MINDBLAST"), "Mind Blast")
    elseif plan == "disc" and ns.SpellUsable("Penance") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "PENANCE!", ns.T("SH_PENANCE"), "Penance")
    end
  end

  -- Reminders, most important first, each on its own line (at most three).
  local list = {}
  local function add(color, text, spell) if #list < 3 then table.insert(list, ns.Alert(color, text, spell)) end end

  if inCombat and hasTarget then
    if ns.SpellInfo("Shadow Word: Pain") and ns.AuraMissing("target", "HARMFUL|PLAYER", "Shadow Word: Pain") then
      add("|cffb48cff", ns.T("SH_SWP"), "Shadow Word: Pain")
    end
    if plan == "shadow" and ns.SpellInfo("Vampiric Embrace")
      and ns.AuraMissing("target", "HARMFUL|PLAYER", "Vampiric Embrace") then
      add("|cffb48cff", ns.T("SH_VE"), "Vampiric Embrace")
    end
  end
  if (inCombat or hasTarget) and ns.SpellInfo("Inner Fire") and ns.AuraMissing("player", "HELPFUL", "Inner Fire") then
    add("|cffffd100", ns.T("SH_INNERFIRE"), "Inner Fire")
  end

  -- Icons only: side by side in one row; otherwise one line each.
  if #list > 0 then sub = table.concat(list, ns.db.alertStyle == "icons" and "  " or "\n") end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
