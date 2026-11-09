-- @ADDON@: combat helper. Calls out 5 combo points (time for a finisher) and Riposte
-- (Combat) when it lights up, and reminds you of Slice and Dice and of Rupture
-- (Assassination) on your target.
local _, ns = ...

local function ComboPoints()
  if GetComboPoints then
    local ok, n = pcall(GetComboPoints, "player", "target")
    if ok and ns.Readable(n) then return n end
  end
  if UnitPower then
    local ok, n = pcall(UnitPower, "player", 4)
    if ok and ns.Readable(n) then return n end
  end
end

local function Update()
  local hasTarget = ns.HasHostileTarget()
  local inCombat = UnitAffectingCombat("player")
  local plan = ns.PlanKey()
  local main, sub, state

  if inCombat and hasTarget then
    local cp = ComboPoints()
    if plan == "combat" and ns.SpellUsable("Riposte") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "RIPOSTE!", ns.T("SH_RIPOSTE"), "Riposte")
    elseif cp and cp >= 5 then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "5 COMBO POINTS!", ns.T("SH_FINISH"), { "Eviscerate", "Slice and Dice" })
    end
  end

  -- Reminders, most important first, each on its own line (at most three).
  local list = {}
  local function add(color, text, spell) if #list < 3 then table.insert(list, ns.Alert(color, text, spell)) end end
  if inCombat and hasTarget then
    if ns.SpellInfo("Slice and Dice") and ns.AuraMissing("player", "HELPFUL", "Slice and Dice") then
      add("|cffff9900", ns.T("SH_SND"), "Slice and Dice")
    end
    if plan == "assa" and ns.SpellInfo("Rupture") and ns.AuraMissing("target", "HARMFUL|PLAYER", "Rupture") then
      add("|cffff6060", ns.T("SH_RUPTURE"), "Rupture")
    end
  end

  -- Icons only: side by side in one row; otherwise one line each.
  if #list > 0 then sub = table.concat(list, ns.db.alertStyle == "icons" and "  " or "\n") end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
