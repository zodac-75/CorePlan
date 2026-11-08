-- @ADDON@: combat helper. Calls out Shadow Trance (Nightfall: instant Shadow Bolt),
-- Decimation (fast Soul Fire), Shadowburn on low targets and Conflagrate (Destruction),
-- and reminds you of missing DoTs, Life Tap when mana is low and health high, a missing
-- demon and running out of Soul Shards.
local _, ns = ...

local SOUL_SHARD = 6265

local function HealthPct()
  local ok, cur, max = pcall(function() return UnitHealth("player"), UnitHealthMax("player") end)
  if ok and ns.Readable(cur) and ns.Readable(max) and max > 0 then return cur / max * 100 end
  return nil
end

local function Sacrificed()
  local found = ns.ForEachAura("player", "HELPFUL", function(n)
    for _, b in ipairs(ns.SACRIFICE_BUFFS or {}) do if n == b then return true end end
  end)
  return found
end

local function HasPet()
  return UnitExists("pet") and not UnitIsDead("pet")
end

local SUMMONS = { "Summon Felhunter", "Summon Voidwalker", "Summon Succubus", "Summon Incubus", "Summon Imp" }

-- Soul Shards in your bags, or nil when the game doesn't give a count. Only nags once
-- you've had a shard, in case shards aren't bag items on this server.
local function Shards()
  local n = ns.ItemCount(SOUL_SHARD)
  if type(n) ~= "number" then return nil end
  if n > 0 then ns.db.hadShard = true end
  return n
end

local function Update()
  local hasTarget = ns.HasHostileTarget()
  local inCombat = UnitAffectingCombat("player")
  local plan = ns.PlanKey()
  local main, sub, state

  if hasTarget then
    local hp = ns.TargetHealthPct()
    if ns.PlayerHas("Shadow Trance") and ns.SpellInfo("Shadow Bolt") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "SHADOW TRANCE!", ns.T("SH_TRANCE"), "Shadow Bolt")
    elseif hp and hp < 20 and ns.SpellUsable("Shadowburn") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "SHADOWBURN!", ns.T("SH_SHADOWBURN"), "Shadowburn")
    elseif ns.PlayerHas("Decimation") and ns.SpellUsable("Soul Fire") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "SOUL FIRE!", ns.T("SH_DECIMATION"), "Soul Fire")
    elseif plan == "destruction" and ns.SpellUsable("Conflagrate")
      and ns.MyDebuffOnTarget("Immolate") then
      state, main = "go", ns.AlertMain("|cff@COLOR@", "CONFLAGRATE!", ns.T("SH_CONFLAG"), "Conflagrate")
    end
  end

  -- Reminders, most important first, each on its own line (at most three).
  local list = {}
  local function add(color, text, spell) if #list < 3 then table.insert(list, ns.Alert(color, text, spell)) end end
  local busy = (IsMounted and IsMounted()) or (UnitOnTaxi and UnitOnTaxi("player"))
    or (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player"))

  if inCombat and hasTarget then
    if plan == "destruction" and ns.SpellInfo("Immolate")
      and ns.AuraMissing("target", "HARMFUL|PLAYER", "Immolate") then
      add("|cffff9966", ns.T("SH_IMMOLATE"), "Immolate")
    end
    if ns.SpellInfo("Corruption") and ns.AuraMissing("target", "HARMFUL|PLAYER", "Corruption") then
      add("|cffb48cff", ns.T("SH_CORRUPTION"), "Corruption")
    end
    if plan ~= "destruction" and ns.SpellInfo("Bane of Agony")
      and ns.AuraMissingLike("target", "HARMFUL|PLAYER", "Bane of ") then
      add("|cffb48cff", ns.T("SH_BANE"), "Bane of Agony")
    end
    if plan == "affliction" and ns.SpellInfo("Siphon Life")
      and ns.AuraMissing("target", "HARMFUL|PLAYER", "Siphon Life") then
      add("|cffb48cff", ns.T("SH_SIPHON"), "Siphon Life")
    end
  end

  -- Life Tap: low on mana but plenty of health.
  if not busy and ns.SpellInfo("Life Tap") then
    local mana, hp = ns.ManaPct(), HealthPct()
    if mana and hp and mana < 25 and hp > 70 then add("|cff66ccff", ns.T("SH_LIFETAP"), "Life Tap") end
  end

  if not inCombat and not busy then
    if not HasPet() and not Sacrificed() then
      for _, s in ipairs(SUMMONS) do
        if ns.SpellInfo(s) then add("|cffffd100", ns.T("SH_PET"), SUMMONS) break end
      end
    end
    local n = Shards()
    if n == 0 and ns.db.hadShard and ns.SpellInfo("Drain Soul") then
      add("|cffffd100", ns.T("SH_SHARDS"), "Drain Soul")
    end
  end

  -- Icons only: side by side in one row; otherwise one line each.
  if #list > 0 then sub = table.concat(list, ns.db.alertStyle == "icons" and "  " or "\n") end
  return main, sub, state
end

ns.MakeCombatHelper(Update)
