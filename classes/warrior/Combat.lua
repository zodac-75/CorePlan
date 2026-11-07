-- @ADDON@: combat helper. Calls out Overpower (Arms/Fury) or Revenge (Protection) when
-- they light up, Execute on low targets and Victory Rush after a kill, and reminds you
-- of a missing Battle Shout, Rend (Arms) or Demoralizing Shout (Protection).
local _, ns = ...

local function Update()
  local hasTarget = ns.HasHostileTarget()
  local inCombat = UnitAffectingCombat("player")
  local plan = ns.PlanKey()
  local main, sub, state

  if hasTarget then
    local hp = ns.TargetHealthPct()
    -- The game only lights it up below 20%; health can be hidden in combat.
    if (hp == nil or hp < 20) and ns.SpellUsable("Execute") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "EXECUTE!", ns.T("SH_EXECUTE"), "Execute")
    elseif plan == "prot" and ns.SpellUsable("Revenge") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "REVENGE!", ns.T("SH_REVENGE"), "Revenge")
    elseif plan ~= "prot" and ns.SpellUsable("Overpower") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "OVERPOWER!", ns.T("SH_GO"), "Overpower")
    elseif ns.SpellUsable("Victory Rush") then
      main = ns.Alert("|cffffcc88", ns.T("SH_VICTORY"), "Victory Rush")
    end
  end

  -- Reminders, most important first.
  if (inCombat or hasTarget) and ns.SpellInfo("Battle Shout") and ns.AuraMissing("player", "HELPFUL", "Battle Shout") then
    sub = ns.Alert("|cffffd100", ns.T("SH_SHOUT"), "Battle Shout")
  elseif inCombat and hasTarget and plan == "arms" and ns.SpellInfo("Rend") and ns.AuraMissing("target", "HARMFUL|PLAYER", "Rend") then
    sub = ns.Alert("|cffff9966", ns.T("SH_REND"), "Rend")
  elseif inCombat and hasTarget and plan == "prot" and ns.SpellInfo("Demoralizing Shout")
    and ns.AuraMissing("target", "HARMFUL", "Demoralizing Shout", "Demoralizing Roar") then
    sub = ns.Alert("|cffff9966", ns.T("SH_DEMO"), "Demoralizing Shout")
  end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
