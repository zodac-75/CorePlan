-- @ADDON@: polymorph alerts. Warns 5 seconds before your sheep ends,
-- and tells you when it breaks early.
-- Two sources: the combat log (older clients), and your own cast (UNIT_SPELLCAST_SUCCEEDED)
-- for clients where addons no longer get combat log events (they come back empty or secret).
local _, ns = ...

local RANK_DURATION = { 20, 30, 40, 50 } -- seconds per Polymorph rank (PvE)
local active = {}
local playerGUID
local lastLog = -1000 -- when the combat log last told us about one of your sheep
local stats = { log = 0, casts = 0, last = "-" }

local function Alert(msg, r, g, b)
  if UIErrorsFrame and UIErrorsFrame.AddMessage then
    UIErrorsFrame:AddMessage(msg, r or 1, g or 0.8, b or 0.2)
  end
  ns.Print(msg)
  PlaySound(SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959)
end

local function RankOf(spellId)
  if spellId and spellId ~= 0 and GetSpellSubtext then
    local ok, s = pcall(GetSpellSubtext, spellId)
    if ok and type(s) == "string" then return tonumber(s:match("(%d+)")) end
  end
  return nil
end

-- Classic combat logs often report spell ID 0, so fall back to your highest known rank.
local function Duration(spellId)
  local r = RankOf(spellId)
  if not r then
    local _, best = ns.SpellInfo("Polymorph")
    r = RankOf(best)
  end
  return RANK_DURATION[r or 1] or 20
end

local function Readable(v)
  return not (issecretvalue and issecretvalue(v))
end

-- ---- Fallback: your own cast ---------------------------------------------------------
local TOKENS = { "target", "focus", "mouseover" }
local castSeq = 0

local function SpellNameOf(id)
  if C_Spell and C_Spell.GetSpellName then
    local ok, n = pcall(C_Spell.GetSpellName, id)
    if ok and type(n) == "string" and Readable(n) then return n end
  end
  if C_Spell and C_Spell.GetSpellInfo then
    local ok, i = pcall(C_Spell.GetSpellInfo, id)
    if ok and type(i) == "table" and type(i.name) == "string" and Readable(i.name) then return i.name end
  end
  if GetSpellInfo then
    local ok, n = pcall(GetSpellInfo, id)
    if ok and type(n) == "table" then n = n.name end
    if ok and type(n) == "string" and Readable(n) then return n end
  end
  return nil
end

-- The sheep on one of these units: aura table (up), false (not there), nil (can't tell).
local function AuraOn(unit, name)
  if not (C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName and UnitExists and UnitExists(unit)) then return nil end
  local ok, a = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, name, "HARMFUL")
  if not ok then return nil end
  if a == nil then return false end
  if type(a) ~= "table" or not Readable(a) then return nil end
  return a
end

local function FindAura(name)
  local unsure = false
  for _, u in ipairs(TOKENS) do
    local a = AuraOn(u, name)
    if a then return u, a end
    if a == nil then unsure = true end
  end
  return nil, nil, unsure
end

local function Finish(entry)
  if active.cast ~= entry then return end
  active.cast = nil
  if ns.db.polyOff then return end
  if GetTime() < entry.ends - 1 then
    Alert(ns.T("POLY_BROKE", entry.name or "?"), 1, 0.3, 0.3)
  else
    Alert(ns.T("POLY_ENDED", entry.name or "?"), 1, 0.8, 0.2)
  end
end

local function Watch(entry)
  -- Every half second: is the sheep still on them? (only when we can read the aura)
  C_Timer.After(0.5, function()
    if active.cast ~= entry then return end
    local a = AuraOn(entry.unit, entry.spell)
    if a == false and GetTime() - entry.start > 2 then Finish(entry) return end
    if GetTime() < entry.ends + 3 then Watch(entry) else active.cast = nil end
  end)
end

local function OnCast(unit, _, spellId)
  if unit ~= "player" or type(spellId) ~= "number" or not Readable(spellId) then return end
  local name = SpellNameOf(spellId)
  if not (name and name:find("^Polymorph")) then return end
  stats.casts = stats.casts + 1
  stats.last = name
  castSeq = castSeq + 1
  local seq = castSeq
  local t = GetTime()
  -- Resisted or immune? Look at the targets a moment later.
  C_Timer.After(0.8, function()
    if seq ~= castSeq or GetTime() - lastLog < 5 then return end -- a newer cast, or the combat log handled it
    local tok, _, unsure = FindAura(name)
    if not tok and not unsure then return end -- readable and not there: it didn't land
    local dur = Duration(spellId)
    local who
    if tok then
      local ok, n = pcall(UnitName, tok)
      if ok and type(n) == "string" and Readable(n) then who = n end
    end
    local entry = { ends = t + dur, start = t, name = who, unit = tok, spell = name }
    active.cast = entry
    if dur > 6 then
      C_Timer.After(math.max(0, t + dur - 5 - GetTime()), function()
        if active.cast == entry and not ns.db.polyOff then Alert(ns.T("POLY_SOON", 5), 1, 0.8, 0.2) end
      end)
    end
    if tok then Watch(entry) end
  end)
end

local function OnCombatLog()
  local _, sub, _, srcGUID, _, _, _, dstGUID, dstName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
  if srcGUID ~= playerGUID or type(spellName) ~= "string" or not spellName:find("^Polymorph") then return end

  lastLog = GetTime()
  stats.log = stats.log + 1
  active.cast = nil
  if sub == "SPELL_AURA_APPLIED" or sub == "SPELL_AURA_REFRESH" then
    local dur = Duration(spellId)
    local entry = { ends = GetTime() + dur, name = dstName }
    active[dstGUID] = entry
    if dur > 6 then
      C_Timer.After(dur - 5, function()
        if active[dstGUID] == entry and not ns.db.polyOff then
          Alert(ns.T("POLY_SOON", 5), 1, 0.8, 0.2)
        end
      end)
    end
  elseif sub == "SPELL_AURA_REMOVED" or sub == "SPELL_AURA_BROKEN" or sub == "SPELL_AURA_BROKEN_SPELL" then
    local entry = active[dstGUID]
    active[dstGUID] = nil
    if entry and not ns.db.polyOff then
      if GetTime() < entry.ends - 1 then
        Alert(ns.T("POLY_BROKE", entry.name or "?"), 1, 0.3, 0.3)
      else
        Alert(ns.T("POLY_ENDED", entry.name or "?"), 1, 0.8, 0.2)
      end
    end
  end
end

ns.RegisterModule(function()
  playerGUID = UnitGUID and UnitGUID("player")
  local ev = CreateFrame("Frame")
  if CombatLogGetCurrentEventInfo then pcall(ev.RegisterEvent, ev, "COMBAT_LOG_EVENT_UNFILTERED") end
  pcall(ev.RegisterEvent, ev, "UNIT_SPELLCAST_SUCCEEDED")
  ev:SetScript("OnEvent", function(_, event, a1, a2, a3)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then pcall(OnCast, a1, a2, a3) return end
    if not CombatLogGetCurrentEventInfo then return end
    local ok, err = pcall(OnCombatLog)
    if not ok and not ns.polyErrorShown then
      ns.polyErrorShown = true
      ns.Print(ns.T("ERROR_IN", "Polymorph", tostring(err)))
    end
  end)
end)

ns.RegisterCommand("poly", true, function()
  ns.db.polyOff = not ns.db.polyOff
  ns.Print(ns.db.polyOff and ns.T("POLY_OFF") or ns.T("POLY_ON"))
end)

-- /@SLASH@ polydebug: is the alert getting anything to work with?
ns.RegisterCommand("polydebug", false, function()
  ns.Print(string.format("polymorph alerts %s; combat log %s (%d sheep events), your casts seen %d (last: %s), active %s",
    ns.db.polyOff and "OFF" or "on", CombatLogGetCurrentEventInfo and "available" or "not available",
    stats.log, stats.casts, stats.last, active.cast and "yes" or "no"))
end)
