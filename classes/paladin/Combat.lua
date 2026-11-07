-- @ADDON@: combat helper. Calls out Hammer of Wrath on low targets and Exorcism on undead
-- and demons, and reminds you of a missing Righteous Fury (Protection), aura, seal,
-- blessing or Holy Shield (Protection).
local _, ns = ...

-- True when no paladin aura is on for sure (aura buffs all end in " Aura").
local function NoAura()
  local found, unsure = ns.ForEachAura("player", "HELPFUL", function(n)
    return n:sub(-5) == " Aura"
  end)
  return not found and not unsure
end

local function TargetIsUndeadOrDemon()
  if not UnitCreatureType then return false end
  local ok, t = pcall(UnitCreatureType, "target")
  if not ok or (issecretvalue and issecretvalue(t)) then return false end
  return t == "Undead" or t == "Demon"
end

local function Update()
  local hasTarget = ns.HasHostileTarget()
  local inCombat = UnitAffectingCombat("player")
  local plan = ns.PlanKey()
  local main, sub, state

  if hasTarget then
    local hp = ns.TargetHealthPct()
    -- The game only lights it up below 20%; health can be hidden in combat.
    if (hp == nil or hp < 20) and ns.SpellUsable("Hammer of Wrath") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "HAMMER OF WRATH!", ns.T("SH_GO"), "Hammer of Wrath")
    elseif TargetIsUndeadOrDemon() and ns.SpellUsable("Exorcism") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "EXORCISM!", ns.T("SH_EXORCISM"), "Exorcism")
    end
  end

  -- Reminders, most important first, each on its own line (at most three).
  local list = {}
  local function add(color, text, spell) if #list < 3 then table.insert(list, ns.Alert(color, text, spell)) end end
  local busy = (IsMounted and IsMounted()) or (UnitOnTaxi and UnitOnTaxi("player"))
    or (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player"))

  if (inCombat or hasTarget) and plan == "prot" and ns.SpellInfo("Righteous Fury")
    and ns.AuraMissing("player", "HELPFUL", "Righteous Fury") then
    add("|cffffd100", ns.T("SH_FURY"), "Righteous Fury")
  end
  -- Auras stay on until you change them, so this one shows any time, not only in fights.
  if not busy then
    local want = ns.WantedAura()
    if want and ns.SpellInfo(want) then
      if ns.AuraMissing("player", "HELPFUL", want) then add("|cffffd100", ns.T("SH_AURA_PICK", want), want) end
    elseif ns.SpellInfo("Devotion Aura") and NoAura() then
      local best = (plan == "ret" and ns.SpellInfo("Retribution Aura")) and "Retribution Aura" or "Devotion Aura"
      add("|cffffd100", ns.T("SH_AURA", best), best)
    end
  end
  if hasTarget and plan ~= "holy" and ns.AuraMissingLike("player", "HELPFUL", "Seal of ") then
    add("|cffffd100", ns.T("SH_SEAL"), { "Seal of Righteousness", "Seal of Command", "Seal of the Crusader" })
  end
  if (inCombat or hasTarget) and ns.SpellInfo("Blessing of Might")
    and ns.AuraMissingLike("player", "HELPFUL", "Blessing of ", "Greater Blessing of ") then
    add("|cffffd100", ns.T("SH_BLESSING"), plan == "holy" and { "Blessing of Wisdom", "Blessing of Might" } or { "Blessing of Might", "Blessing of Wisdom" })
  end
  if inCombat and hasTarget and plan == "prot" and ns.SpellUsable("Holy Shield")
    and ns.AuraMissing("player", "HELPFUL", "Holy Shield") then
    add("|cffff9966", ns.T("SH_HOLYSHIELD"), "Holy Shield")
  end
  -- Icons only: side by side in one row; otherwise one line each.
  if #list > 0 then sub = table.concat(list, ns.db.alertStyle == "icons" and "  " or "\n") end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
