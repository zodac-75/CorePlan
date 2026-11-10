-- @ADDON@: the movable combat helper text used by the class combat modules.
-- A class module calls ns.MakeCombatHelper(update), where update() returns
--   main  - the big line (or nil),
--   sub   - the small reminder line (or nil),
--   state - "go" makes the text flash once when it appears.
-- It adds /@SLASH@ combat (on/off) and /@SLASH@ move. The frame and settings keep the
-- "shatter" names from MagePlan so profiles work across all the Plan addons.
local _, ns = ...

function ns.Readable(v)
  return type(v) == "number" and not (issecretvalue and issecretvalue(v))
end

function ns.PlayerHas(buff)
  return ns.AuraByName("player", "HELPFUL", buff) == true
end

function ns.MyDebuffOnTarget(debuff)
  return ns.AuraByName("target", "HARMFUL|PLAYER", debuff) == true
end

function ns.HasHostileTarget()
  return UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")
end

-- Target health in percent, or nil when the game hides it.
function ns.TargetHealthPct()
  if UnitHealthPercent then
    local ok, p = pcall(UnitHealthPercent, "target")
    if ok and ns.Readable(p) then return p <= 1 and p * 100 or p end
  end
  local ok, cur, max = pcall(function() return UnitHealth("target"), UnitHealthMax("target") end)
  if ok and ns.Readable(cur) and ns.Readable(max) and max > 0 then return cur / max * 100 end
  return nil
end

-- When you last cast each spell (your own casts), for cooldowns the game hides in combat.
local lastCast = {}
local castWatch = CreateFrame("Frame")
pcall(castWatch.RegisterUnitEvent, castWatch, "UNIT_SPELLCAST_SUCCEEDED", "player")
castWatch:SetScript("OnEvent", function(_, _, _, _, spellID)
  pcall(function()
    local name = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID))
      or (GetSpellInfo and GetSpellInfo(spellID))
    if type(name) == "string" and not (issecretvalue and issecretvalue(name)) then lastCast[name] = GetTime() end
  end)
end)
ns.lastCast = lastCast

-- The spell's cooldown in seconds without talents (for when the live one is hidden).
local function BaseCooldown(spell)
  local ok, ms = pcall(GetSpellBaseCooldown, spell)
  if ok and ns.Readable(ms) and ms > 0 then return ms / 1000 end
  return 8
end

-- True when the spell is known and usable right now (enough rage/mana, proc active, off
-- cooldown). When the game hides the cooldown (combat), the spell counts as on cooldown
-- for its base cooldown after you cast it, so a call-out doesn't stay up while it's ticking.
function ns.SpellUsable(spell)
  if not ns.SpellInfo(spell) then return false end
  local ok, usable, noPower
  if C_Spell and C_Spell.IsSpellUsable then
    ok, usable, noPower = pcall(C_Spell.IsSpellUsable, spell)
  elseif IsUsableSpell then
    ok, usable, noPower = pcall(IsUsableSpell, spell)
  end
  if not ok or (issecretvalue and (issecretvalue(usable) or issecretvalue(noPower))) then return false end
  if not usable or noPower then return false end
  local s, d = ns.SpellCooldown(spell)
  if ns.Readable(s) and ns.Readable(d) then return ns.CooldownLeft(spell) <= 0 end
  local t = lastCast[spell]
  return not t or GetTime() - t >= BaseCooldown(spell)
end

---------------------------------------------------------------------------
-- Size and sound, shared by every class's combat helper (all use @ADDON@ShatterFrame).
---------------------------------------------------------------------------
ns.HELPER_SIZES = { 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5 }

function ns.SetHelperScale(s)
  ns.db.shatterScale = s
  local f = _G["@ADDON@ShatterFrame"]
  if f then f:SetScale(s) end
end

-- Sound when a call-out lights up ("procs") and, if you want, when a reminder appears.
ns.ALERT_MODES = { "off", "procs", "all" }
ns.ALERT_SOUNDS = {
  { key = "RAID_WARNING", id = 8959 },
  { key = "READY_CHECK", id = 8960 },
  { key = "TELL_MESSAGE", id = 3081 },
  { key = "MAP_PING", id = 3175 },
  { key = "ALARM_CLOCK_WARNING_3", id = 12889 },
}

function ns.PlayAlertSound()
  local want = ns.db.alertSoundKit or "RAID_WARNING"
  local id
  for _, s in ipairs(ns.ALERT_SOUNDS) do
    if s.key == want then id = (SOUNDKIT and SOUNDKIT[s.key]) or s.id end
  end
  if id and PlaySound then pcall(PlaySound, id, "Master") end
end

-- How alerts look: the spell's icon and the text, icons only, or text only.
ns.ALERT_STYLES = { "both", "icons", "text" }

local function IconTag(spell, size)
  local tex = spell and ns.SpellIcon and ns.SpellIcon(spell)
  if not tex then return nil end
  return "|T" .. tex .. ":" .. size .. ":" .. size .. ":0:0:64:64:5:59:5:59|t"
end

-- A reminder line: "|T icon|t Text", the icon alone or the text alone (ns.db.alertStyle).
-- spell may be a list; the first one you know gives the icon.
function ns.Alert(color, text, spell)
  local style = ns.db.alertStyle or "both"
  if type(spell) == "table" then
    local pick
    for _, s in ipairs(spell) do if ns.SpellIcon(s) then pick = s; break end end
    spell = pick
  end
  local tag = style ~= "text" and IconTag(spell, style == "icons" and 30 or 18)
  if style == "icons" and tag then return tag end
  return (tag and (tag .. " ") or "") .. color .. text .. "|r"
end

-- A call-out line: big word, then a short explanation; icons only shows a big icon.
function ns.AlertMain(color, shout, rest, spell)
  local style = ns.db.alertStyle or "both"
  if type(spell) == "table" then
    local pick
    for _, s in ipairs(spell) do if ns.SpellIcon(s) then pick = s; break end end
    spell = pick
  end
  local tag = style ~= "text" and IconTag(spell, style == "icons" and 40 or 26)
  if style == "icons" and tag then return tag end
  return (tag and (tag .. " ") or "") .. color .. shout .. "|r" .. (rest and rest ~= "" and (" " .. rest) or "")
end

local lastAlertState, lastAlertSub, lastSoundAt = nil, nil, 0

-- Called by each combat helper on every update with what it shows.
function ns.HelperAlert(main, sub, state)
  local mode = ns.db.alertSound or "off"
  local play = false
  if mode ~= "off" and state == "go" and lastAlertState ~= "go" then play = true end
  if mode == "all" and sub and sub ~= lastAlertSub then play = true end
  lastAlertState, lastAlertSub = state, sub
  if play and GetTime() - lastSoundAt > 1.5 then
    lastSoundAt = GetTime()
    ns.PlayAlertSound()
  end
end

function ns.MakeCombatHelper(update)
  local f, big, small, flash
  local acc, lastState = 0, nil

  local function Update()
    if ns.db.shatterOff then f:Hide(); return end
    local main, sub, state = update()
    ns.HelperAlert(main, sub, state)
    local unlocked = ns.db.shatterUnlocked
    if not main and not sub and not unlocked then
      f:Hide()
      lastState = nil
      return
    end
    big:SetText(main or (unlocked and ("|cff888888" .. ns.T("SH_DRAG") .. "|r")) or "")
    small:SetText(sub or "")
    f:Show()
    if state == "go" and lastState ~= "go" then flash:Play() end
    lastState = state
  end

  local function Create()
    f = CreateFrame("Frame", "@ADDON@ShatterFrame", UIParent)
    f:SetSize(360, 56)
    local p = ns.db.shatterPos
    if p then
      f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
      f:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
    end
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
      self:StopMovingOrSizing()
      local point, _, relPoint, x, y = self:GetPoint()
      ns.db.shatterPos = { point, relPoint, x, y }
    end)
    f:EnableMouse(ns.db.shatterUnlocked and true or false)
    f:SetScale(ns.db.shatterScale or 1)
    f:EnableMouseWheel(ns.db.shatterUnlocked and true or false)
    f:SetScript("OnMouseWheel", function(self, delta)
      if not ns.db.shatterUnlocked then return end
      local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
      self:SetScale(s)
      ns.db.shatterScale = s
    end)

    big = f:CreateFontString(nil, "OVERLAY")
    big:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
    big:SetPoint("TOP", f, "TOP", 0, 0)
    small = f:CreateFontString(nil, "OVERLAY")
    small:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
    small:SetPoint("TOP", big, "BOTTOM", 0, -4)

    flash = f:CreateAnimationGroup()
    local a = flash:CreateAnimation("Alpha")
    a:SetFromAlpha(0.2)
    a:SetToAlpha(1)
    a:SetDuration(0.25)
    f:Hide()

    -- Updates 10 times a second from its own frame, so it keeps running while hidden.
    local ticker = CreateFrame("Frame")
    ticker:SetScript("OnUpdate", function(_, elapsed)
      acc = acc + elapsed
      if acc < 0.1 then return end
      acc = 0
      local ok, err = pcall(Update)
      if not ok and not ns.shatterErrorShown then
        ns.shatterErrorShown = true
        ns.Print(ns.T("SH_ERR", tostring(err)))
      end
    end)
  end

  ns.RegisterModule(Create)

  ns.RegisterCommand("combat", true, function()
    ns.db.shatterOff = not ns.db.shatterOff
    ns.Print(ns.db.shatterOff and ns.T("SH_OFF") or ns.T("SH_ON"))
  end)

  ns.RegisterCommand("move", true, function()
    ns.db.shatterUnlocked = not ns.db.shatterUnlocked
    if f then
      f:EnableMouse(ns.db.shatterUnlocked and true or false)
      f:EnableMouseWheel(ns.db.shatterUnlocked and true or false)
    end
    if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
    ns.Print(ns.db.shatterUnlocked and ns.T("SH_UNLOCKED") or ns.T("SH_LOCKED"))
  end)
end
