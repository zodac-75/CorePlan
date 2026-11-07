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
      state, main = "go", "|cff@COLOR@HAMMER OF WRATH!|r " .. ns.T("SH_GO")
    elseif TargetIsUndeadOrDemon() and ns.SpellUsable("Exorcism") then
      state, main = "go", "|cff@COLOR@EXORCISM!|r " .. ns.T("SH_EXORCISM")
    end
  end

  -- Reminders, most important first.
  if (inCombat or hasTarget) and plan == "prot" and ns.SpellInfo("Righteous Fury") and ns.AuraMissing("player", "HELPFUL", "Righteous Fury") then
    sub = "|cffffd100" .. ns.T("SH_FURY") .. "|r"
  elseif (inCombat or hasTarget) and ns.WantedAura() and ns.SpellInfo(ns.WantedAura())
    and ns.AuraMissing("player", "HELPFUL", ns.WantedAura()) then
    -- The aura you picked in the settings isn't on (another one may be).
    sub = "|cffffd100" .. ns.T("SH_AURA_PICK", ns.WantedAura()) .. "|r"
  elseif (inCombat or hasTarget) and not ns.WantedAura() and ns.SpellInfo("Devotion Aura") and NoAura() then
    local best = (plan == "ret" and ns.SpellInfo("Retribution Aura")) and "Retribution Aura" or "Devotion Aura"
    sub = "|cffffd100" .. ns.T("SH_AURA", best) .. "|r"
  elseif hasTarget and plan ~= "holy" and ns.AuraMissingLike("player", "HELPFUL", "Seal of ") then
    sub = "|cffffd100" .. ns.T("SH_SEAL") .. "|r"
  elseif (inCombat or hasTarget) and ns.SpellInfo("Blessing of Might")
    and ns.AuraMissingLike("player", "HELPFUL", "Blessing of ", "Greater Blessing of ") then
    sub = "|cffffd100" .. ns.T("SH_BLESSING") .. "|r"
  elseif inCombat and hasTarget and plan == "prot" and ns.SpellUsable("Holy Shield") and ns.AuraMissing("player", "HELPFUL", "Holy Shield") then
    sub = "|cffff9966" .. ns.T("SH_HOLYSHIELD") .. "|r"
  end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
