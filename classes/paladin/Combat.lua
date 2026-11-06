-- @ADDON@: combat helper. Calls out Hammer of Wrath on low targets and Exorcism on undead
-- and demons, and reminds you of a missing Righteous Fury (Protection), seal, blessing
-- or Holy Shield (Protection).
local _, ns = ...

local function HasBuffLike(prefix)
  return ns.ForEachAura("player", "HELPFUL", function(n) return type(n) == "string" and n:find(prefix, 1, true) == 1 end)
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
    if hp and hp < 20 and ns.SpellUsable("Hammer of Wrath") then
      state, main = "go", "|cff@COLOR@HAMMER OF WRATH!|r " .. ns.T("SH_GO")
    elseif TargetIsUndeadOrDemon() and ns.SpellUsable("Exorcism") then
      state, main = "go", "|cff@COLOR@EXORCISM!|r " .. ns.T("SH_EXORCISM")
    end
  end

  -- Reminders, most important first.
  if (inCombat or hasTarget) and plan == "prot" and ns.SpellInfo("Righteous Fury") and not ns.PlayerHas("Righteous Fury") then
    sub = "|cffffd100" .. ns.T("SH_FURY") .. "|r"
  elseif hasTarget and plan ~= "holy" and not HasBuffLike("Seal of ") then
    sub = "|cffffd100" .. ns.T("SH_SEAL") .. "|r"
  elseif (inCombat or hasTarget) and ns.SpellInfo("Blessing of Might") and not HasBuffLike("Blessing of ")
    and not HasBuffLike("Greater Blessing of ") then
    sub = "|cffffd100" .. ns.T("SH_BLESSING") .. "|r"
  elseif inCombat and hasTarget and plan == "prot" and ns.SpellUsable("Holy Shield") and not ns.PlayerHas("Holy Shield") then
    sub = "|cffff9966" .. ns.T("SH_HOLYSHIELD") .. "|r"
  end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
