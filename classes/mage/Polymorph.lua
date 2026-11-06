-- @ADDON@: polymorph alerts. Warns 5 seconds before your sheep ends,
-- and tells you when it breaks early.
local _, ns = ...

local RANK_DURATION = { 20, 30, 40, 50 } -- seconds per Polymorph rank (PvE)
local active = {}
local playerGUID

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

local function OnCombatLog()
  local _, sub, _, srcGUID, _, _, _, dstGUID, dstName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
  if srcGUID ~= playerGUID or type(spellName) ~= "string" or not spellName:find("^Polymorph") then return end

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
  if not CombatLogGetCurrentEventInfo then return end -- combat log not available to addons
  playerGUID = UnitGUID and UnitGUID("player")
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  ev:SetScript("OnEvent", function()
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
