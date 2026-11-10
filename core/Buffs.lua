-- @ADDON@: buff watcher. A movable row of icons for your own buffs (ns.BUFF_WATCH in
-- the class Data.lua) that shows up when a buff is missing or about to run out.
-- Click an icon to cast the buff. Turn on "Move" (/@SLASH@ move, same switch as the combat
-- helper) to see every watched buff, drag the row by any icon and resize it with Ctrl + wheel.
--
-- An entry: { spells = { "Arcane Intellect" } or function(plan) -> list,
--             buffs = { names that count }, match = function(name) -> bool,
--             imbue = true (weapon buff, or "off" for the off-hand), only = function() -> bool,
--             warn = seconds, use = function() -> { name, macro, icon } or nil }
-- The icon casts the first spell in the list you know. With use (poisons and other items),
-- the icon runs that macro instead, and the entry only shows while use() returns something.
--
-- A higher rank of the same buff from someone else counts as "up" until it runs out:
-- your weaker cast can't replace it.
--
-- Party buffs (ns.PARTY_BUFFS, same fields plus mana = true for mana users only, or
-- spells = function(unit) -> list): one icon per party member who is missing it, with
-- their name on it; a click casts it on them.
local _, ns = ...

local SIZE, GAP, WARN = 36, 6, 60
local holder, buttons = nil, {}
local acc, pendingLayout = 0, false
local warned = {} -- spells already announced as running out (sound + message once)
local gone = {}   -- when an announced one left the row (a party member out of range for a moment)
local FORGET = 60 -- seconds away before it counts as new again

-- Out of combat you get an earlier "rebuff now" heads-up (minutes; 0 = off).
ns.REBUFF_TIMES = { 0, 1, 2, 3, 5, 10 }
local function RebuffSec() return (ns.db.rebuffMin or 3) * 60 end

local function Use(e)
  if not e.use then return nil end
  local ok, u = pcall(e.use)
  if ok and type(u) == "table" and u.name then return u end
end

local function Spells(e)
  if e.use then
    local u = Use(e)
    return u and u.name or nil
  end
  local list = type(e.spells) == "function" and e.spells(ns.PlanKey()) or e.spells or {}
  for _, s in ipairs(list) do
    if ns.SpellInfo(s) then return s end
  end
  return nil
end

-- Each entry can be turned off on its own in the settings (ns.db.buffHide[key]).
local function EntryKey(e, i, party)
  local first = type(e.spells) == "table" and e.spells[1] or e.id or ("entry" .. i)
  return (party and "party:" or "") .. first
end

local function EntryLabel(e, party)
  local name
  if type(e.spells) == "function" then
    local ok, list = pcall(e.spells, ns.PlanKey(), true)
    if ok and type(list) == "table" then
      for _, s in ipairs(list) do if ns.SpellInfo(s) then name = s break end end
      name = name or list[1]
    end
  else
    for _, s in ipairs(e.spells or {}) do if ns.SpellInfo(s) then name = s break end end
    name = name or (e.spells and e.spells[1])
  end
  name = e.label and ns.Tx(e.label) or name or "?"
  return party and ns.T("BW_PARTY_LABEL", name) or name
end

local function Hidden(key) return ns.db.buffHide and ns.db.buffHide[key] end

-- Tick boxes for the settings window: one per watched buff, then the party ones.
function ns.BuffWatchToggles()
  local out = {}
  local function add(e, i, party)
    local key = EntryKey(e, i, party)
    table.insert(out, {
      text = function() return EntryLabel(e, party) end,
      on = function() return not Hidden(key) end,
      toggle = function()
        ns.db.buffHide = ns.db.buffHide or {}
        ns.db.buffHide[key] = not ns.db.buffHide[key] or nil
        if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
      end,
    })
  end
  for i, e in ipairs(ns.BUFF_WATCH or {}) do add(e, i, false) end
  for i, e in ipairs(ns.PARTY_BUFFS or {}) do add(e, i, true) end
  return out
end

-- Your buffs: name -> seconds left (0 = no end), name -> full duration;
-- unsure when the game hides names.
local function PlayerBuffs(unit)
  unit = unit or "player"
  local out, unsure, durs, ids = {}, false, {}, {}
  local now = GetTime()
  for i = 1, 40 do
    local name, expires, dur, id
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
      local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, "HELPFUL")
      if not ok then unsure = true break end
      if not a then break end
      name, expires, dur, id = a.name, a.expirationTime, a.duration, a.spellId
    elseif UnitAura then
      local ok, n, _, _, d, _, exp, _, _, _, sid = pcall(UnitAura, unit, i, "HELPFUL")
      if not ok then unsure = true break end
      if not n then break end
      name, expires, dur, id = n, exp, d, sid
    else
      unsure = true
      break
    end
    if issecretvalue and (issecretvalue(name) or issecretvalue(expires)) then
      unsure = true
    elseif type(name) ~= "string" then
      unsure = true -- an aura without a readable name (restricted): can't tell what it is
    else
      local left = (type(expires) == "number" and expires > 0) and (expires - now) or 0
      out[name] = math.max(out[name] or 0, left)
      if ns.Readable(dur) and dur > 0 then durs[name] = dur end
      if ns.Readable(id) and type(id) == "number" then ids[name] = id end
    end
  end
  return out, unsure, durs, ids
end

-- A higher rank of your buff, cast by someone else (a higher-level druid's Mark of the
-- Wild): yours can't replace it ("a more powerful spell is already active"), so there is
-- nothing to cast until it has run out. Unknown ranks count as "not stronger".
local function StrongerThanMine(auraId, spell)
  if not (auraId and spell and ns.OlderRank) then return false end
  local _, myId = ns.SpellInfo(spell)
  if not myId or myId == auraId then return false end
  local ok, older = pcall(ns.OlderRank, myId, auraId)
  return ok and older == true
end

-- Is one of the buffs that count a stronger one from someone else?
local function Outranked(names, ids, spell)
  for _, n in ipairs(names or {}) do
    if n == spell and StrongerThanMine(ids[n], spell) then return true end
  end
  return false
end

-- When the aura list is hidden (secret values), ask for the buff by name instead.
-- Seconds left (1e9 = no end or unknown), 0 = missing for sure, nil = can't tell.
local function LookupByName(unit, names)
  if not (names and C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName) then return nil end
  for _, n in ipairs(names) do
    local ok, a = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, n, "HELPFUL")
    if not ok then return nil end
    if a then
      local exp = a.expirationTime
      if ns.Readable(exp) and exp > 0 then return math.max(0.1, exp - GetTime()) end
      return 1e9
    end
  end
  return 0
end

-- Seconds left on the weapon buff, 0 for none, nil when unknown.
local function ImbueLeft(offHand)
  if not GetWeaponEnchantInfo then return nil end
  local ok, has, ms, _, _, hasOff, msOff = pcall(GetWeaponEnchantInfo)
  if not ok then return nil end
  if offHand then has, ms = hasOff, msOff end
  if not has then return 0 end
  return (ms or 0) / 1000
end

-- During a boss fight the game hides other players' buffs (and sometimes yours): the list
-- comes back empty or secret and a lookup by name finds nothing, which looked like
-- "everyone is missing Arcane Intellect" at the pull. Then "not found" means "can't tell".
local bossFight = false -- ENCOUNTER_START .. ENCOUNTER_END, for clients without IsEncounterInProgress
local function InEncounter()
  if bossFight then return true end
  if not IsEncounterInProgress then return false end
  local ok, v = pcall(IsEncounterInProgress)
  return ok and v == true
end

-- What each entry needs now: { spell, left } where left = 0 means missing.
local InRange -- below: can your buff reach them?

local function Needed()
  local buffs, unsure, durs, ids = PlayerBuffs()
  local out = {}
  local combat = InCombatLockdown and InCombatLockdown()
  local boss = InEncounter()
  if boss and next(buffs) == nil then unsure = true end
  for idx, e in ipairs(ns.BUFF_WATCH or {}) do
    local spell = Spells(e)
    if spell and not Hidden(EntryKey(e, idx, false)) and (not e.only or e.only()) then
      local left, dur
      if e.imbue then
        local l = ImbueLeft(e.imbue == "off")
        left = l and (l == 0 and 0 or l) or nil
      else
        local best
        for name, l in pairs(buffs) do
          local hit = (e.match and e.match(name, "player")) or false
          if not hit and e.buffs then
            for _, b in ipairs(e.buffs) do if b == name then hit = true break end end
          end
          if hit then
            best = math.max(best or 0, l == 0 and 1e9 or l)
            dur = durs[name] or dur
          end
        end
        if best then left = best elseif not unsure then left = 0
        elseif not e.match then left = LookupByName("player", e.buffs) end
        if left == 0 and unsure and boss then left = nil end
        if best and Outranked(e.buffs, ids, spell) then left = nil end
      end
      local warn = e.warn or WARN
      -- Out of combat: warn earlier, but at most a third of the buff's length, so a
      -- 2-minute shout doesn't nag right after you cast it. Weapon buffs keep their own.
      if not combat and not e.imbue and RebuffSec() > warn then
        local r = RebuffSec()
        if dur then r = math.min(r, dur / 3) end
        if r > warn then warn = r end
      end
      if left and (left == 0 or left < warn) then
        table.insert(out, { entry = e, spell = spell, left = left, key = spell })
      end
    end
  end
  -- Your party: whoever is missing your group buff.
  if not ns.db.partyBuffsOff and ns.PARTY_BUFFS and IsInGroup and IsInGroup() then
    for i = 1, 4 do
      local unit = "party" .. i
      -- Only party members you can see (same zone, nearby): no icons for someone far away.
      local okV, visible = pcall(UnitIsVisible, unit)
      if okV and issecretvalue and issecretvalue(visible) then visible = true end
      if not okV then visible = true end
      if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) and visible then
        local theirs, unsureP, _, theirIds = PlayerBuffs(unit)
        if boss and next(theirs) == nil then unsureP = true end
        local isMana
        local okP, pt = pcall(UnitPowerType, unit)
        if okP and not (issecretvalue and issecretvalue(pt)) then isMana = (pt == 0) end
        for idx, e in ipairs(ns.PARTY_BUFFS) do
          local list = type(e.spells) == "function" and e.spells(unit, isMana) or e.spells or {}
          local spell
          for _, s in ipairs(list) do if ns.SpellInfo(s) then spell = s break end end
          if spell and not Hidden(EntryKey(e, idx, true)) and not (e.mana and isMana == false) then
            local best
            for name, l in pairs(theirs) do
              local hit = (e.match and e.match(name, unit)) or false
              if not hit and e.buffs then
                for _, b in ipairs(e.buffs) do if b == name then hit = true break end end
              end
              if hit then best = math.max(best or 0, l == 0 and 1e9 or l) end
            end
            local left = best or (not unsureP and 0 or nil)
            if left == nil and not e.match then left = LookupByName(unit, e.buffs) end
            -- Their list is hidden: a name lookup that finds nothing isn't proof it's gone.
            if left == 0 and unsureP then left = nil end
            if best and Outranked(e.buffs, theirIds, spell) then left = nil end
            local warn = combat and (e.warn or WARN) or math.max(e.warn or WARN, math.min(RebuffSec(), 600))
            -- Out of buff range: no icon until they come closer (checked every second).
            if left and (left == 0 or left < warn) and InRange(unit, spell) then
              local okN, who = pcall(UnitName, unit)
              if not okN or (issecretvalue and issecretvalue(who)) then who = nil end
              table.insert(out, { entry = e, spell = spell, left = left, unit = unit, who = who,
                key = spell .. "@" .. unit })
            end
          end
        end
      end
    end
  end
  return out
end

-- Can you reach them with a buff? (unknown counts as yes)
-- Can your buff reach them? The spell's own range first (buffs reach 30 yards; the
-- party range check is about 40), then the party range check. nil = can't tell.
local function SpellRange(spell, unit)
  local f = (C_Spell and C_Spell.IsSpellInRange) or IsSpellInRange
  if not (f and spell) then return nil end
  local ok, r = pcall(f, spell, unit)
  if not ok or r == nil or (issecretvalue and issecretvalue(r)) then return nil end
  return r == true or r == 1
end

function InRange(unit, spell)
  if not unit then return true end
  local r = SpellRange(spell, unit)
  if r ~= nil then return r end
  if not UnitInRange then return true end
  local ok, inRange, checked = pcall(UnitInRange, unit)
  if not ok or (issecretvalue and (issecretvalue(inRange) or issecretvalue(checked))) then return true end
  if checked == false then return true end
  return inRange and true or false
end

local function Short(sec)
  if sec >= 600 then return math.floor(sec / 60 + 0.5) .. "m" end
  if sec >= 60 then return string.format("%d:%02d", math.floor(sec / 60), math.floor(sec % 60)) end
  return math.floor(sec) .. "s"
end

local function MakeButton(i)
  -- A secure button so a click casts the buff; it can't be shown or moved in combat.
  local b = CreateFrame("Button", "@ADDON@Buff" .. i, holder, "SecureActionButtonTemplate")
  b:SetSize(SIZE, SIZE)
  b:RegisterForClicks("AnyUp", "AnyDown")
  -- Left-click casts; right-click is ours (e.g. pick a blessing for that player).
  b:SetAttribute("type1", "spell")
  b:SetAttribute("unit", "player")
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetAllPoints()
  b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  b.border = b:CreateTexture(nil, "OVERLAY")
  b.border:SetPoint("TOPLEFT", -2, 2)
  b.border:SetPoint("BOTTOMRIGHT", 2, -2)
  b.border:SetColorTexture(1, 0.25, 0.25, 0.9)
  b.border:SetDrawLayer("BACKGROUND")
  b.pulse = b:CreateAnimationGroup()
  b.pulse:SetLooping("BOUNCE")
  local a = b.pulse:CreateAnimation("Alpha")
  a:SetFromAlpha(1)
  a:SetToAlpha(0.45)
  a:SetDuration(0.6)
  b.time = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
  b.time:SetPoint("BOTTOM", b, "BOTTOM", 0, -12)
  -- Party buffs: who it's for, on top of the icon.
  b.who = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmallOutline")
  b.who:SetPoint("TOP", b, "TOP", 0, 10)
  b:SetScript("OnEnter", function(self)
    if not GameTooltip or not self.spell then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    local _, id = ns.SpellInfo(self.spell)
    if id and GameTooltip.SetSpellByID then GameTooltip:SetSpellByID(id) else GameTooltip:SetText(self.spell) end
    if ns.db.shatterUnlocked then
      GameTooltip:AddLine(ns.T("BW_MOVE_ON"), 1, 0.4, 0.4)
    elseif self.outOfRange then
      GameTooltip:AddLine(ns.T("BW_OUT_OF_RANGE", self.whoName or ""), 1, 0.4, 0.4)
    else
      GameTooltip:AddLine(self.whoName and ns.T("BW_CLICK_ON", self.whoName) or ns.T("BW_CLICK"), 0.6, 0.8, 1)
    end
    if self.entry and self.entry.choice then
      local ok, c = pcall(self.entry.choice, self.unit or "player")
      GameTooltip:AddLine(ns.T("BW_RIGHT_PICK", ok and c or "?"), 0.6, 0.8, 1)
    end
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  b:HookScript("OnMouseUp", function(self, mouse)
    if mouse ~= "RightButton" or not (self.entry and self.entry.cycle) then return end
    if InCombatLockdown and InCombatLockdown() then ns.Print(ns.T("BW_NOT_IN_COMBAT")) return end
    pcall(self.entry.cycle, self.unit or "player")
    ns.RefreshBuffWatch()
    if GameTooltip and GameTooltip:IsOwned(self) then self:GetScript("OnEnter")(self) end
  end)
  -- While unlocked, dragging an icon moves the whole row.
  b:RegisterForDrag("LeftButton")
  b:SetScript("OnDragStart", function()
    if ns.db.shatterUnlocked and not (InCombatLockdown and InCombatLockdown()) then holder:StartMoving() end
  end)
  b:SetScript("OnDragStop", function() holder:GetScript("OnDragStop")(holder) end)
  b:EnableMouseWheel(true)
  b:SetScript("OnMouseWheel", function(_, delta) holder:GetScript("OnMouseWheel")(holder, delta) end)
  b:Hide()
  buttons[i] = b
  return b
end

local function Update()
  if not holder then return end
  local combat = InCombatLockdown and InCombatLockdown()
  local list = (ns.db.buffsOff or (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player"))) and {} or Needed()
  -- Moved together with the combat helper ("Move" switch), not with the window lock.
  local unlocked = ns.db.shatterUnlocked and not ns.db.buffsOff

  if combat then
    -- Can't add or remove buttons now: just update what's shown, and redo the row later.
    pendingLayout = true
    holder.msg:Hide() -- the call-outs own the screen in combat
    for _, b in ipairs(buttons) do
      if b:IsShown() then
        local still
        for _, n in ipairs(list) do if n.key == b.key then still = n end end
        -- A party icon whose player went out of range is hidden (alpha only: secure button in combat).
        b:SetAlpha(still and (InRange(still.unit, still.spell) and 1 or 0.4) or (b.unit and 0 or 0.25))
        b.time:SetText(still and still.left > 0 and Short(still.left) or "")
      end
    end
    return
  end
  pendingLayout = false

  -- Unlocked: show every watched buff (faded when it's up) so there is something to drag.
  if unlocked then
    local have = {}
    for _, n in ipairs(list) do have[n.spell] = true end
    for idx, e in ipairs(ns.BUFF_WATCH or {}) do
      local spell = Spells(e)
      if spell and not have[spell] and not Hidden(EntryKey(e, idx, false)) then
        have[spell] = true
        table.insert(list, { entry = e, spell = spell, left = -1, key = spell })
      end
    end
  end

  for i, n in ipairs(list) do
    local b = buttons[i] or MakeButton(i)
    b.spell, b.key, b.whoName, b.entry, b.unit = n.spell, n.key, n.who, n.entry, n.unit
    local reach = InRange(n.unit, n.spell)
    b.outOfRange = not reach
    local use = not n.unit and n.entry and Use(n.entry)
    if use then
      -- An item (a poison): the macro uses it and puts it on the weapon.
      b:SetAttribute("spell1", nil)
      b:SetAttribute("macrotext1", use.macro)
    elseif n.unit then
      -- Party: a /cast that names its target, so the game can never put it on you instead
      -- (auto self-cast); out of range, the click does nothing at all.
      b:SetAttribute("spell1", nil)
      b:SetAttribute("macrotext1", "/cast [@" .. n.unit .. ",help,nodead] " .. n.spell)
    else
      b:SetAttribute("macrotext1", nil)
      b:SetAttribute("spell1", n.spell)
    end
    b:SetAttribute("unit", n.unit or "player")
    b.who:SetText(n.who and n.who:sub(1, 7) or "")
    -- No casting while you're moving it.
    local castType = (n.unit or use) and "macro" or "spell"
    b:SetAttribute("type1", (not unlocked and reach) and castType or nil)
    b.icon:SetTexture(use and use.icon or ns.SpellIcon(n.spell))
    -- Red frame: missing. Yellow frame: running out.
    if n.left == 0 then b.border:SetColorTexture(1, 0.25, 0.25, 0.9)
    elseif n.left < 0 then b.border:SetColorTexture(0.5, 0.5, 0.5, 0.6)
    else b.border:SetColorTexture(1, 0.8, 0.25, 0.9) end
    b.time:SetText(n.left > 0 and Short(n.left) or "")
    b:ClearAllPoints()
    b:SetPoint("LEFT", holder, "LEFT", (i - 1) * (SIZE + GAP), 0)
    b:SetAlpha((n.left < 0 or not reach) and 0.45 or 1)
    b:Show()
  end
  for i = #list + 1, #buttons do buttons[i]:Hide() end

  -- A heads-up the first time a buff starts running out (or goes missing) out of combat:
  -- a line above the row, the icon pulses, and the alert sound if sounds are on.
  local msg, now = nil, {}
  local fighting = InCombatLockdown and InCombatLockdown()
  for i, n in ipairs(list) do
    if n.left >= 0 then
      now[n.key] = true
      if not warned[n.key] then
        warned[n.key] = true
        -- No sound for party buffs in combat: players moving in and out of range would
        -- set it off again and again.
        if (ns.db.alertSound or "off") ~= "off" and ns.PlayAlertSound and not (fighting and n.who) then
          ns.PlayAlertSound()
        end
      end
      local b = buttons[i]
      if b.pulse and not b.pulse:IsPlaying() then b.pulse:Play() end
      if not msg then
        if n.who then
          msg = n.left == 0 and ns.T("BW_MISSING_ON", n.spell, n.who) or ns.T("BW_REBUFF_ON", n.spell, n.who, Short(n.left))
        else
          msg = n.left == 0 and ns.T("BW_MISSING", n.spell) or ns.T("BW_REBUFF", n.spell, Short(n.left))
        end
      end
    elseif buttons[i].pulse then
      buttons[i].pulse:Stop()
    end
  end
  -- Forget a warning only when it has been gone a while, so a party member stepping out
  -- of range and back doesn't warn again.
  local t = GetTime and GetTime() or 0
  for s in pairs(warned) do
    if now[s] then gone[s] = nil
    else
      gone[s] = gone[s] or t
      if t - gone[s] > FORGET then warned[s], gone[s] = nil, nil end
    end
  end
  for i = #list + 1, #buttons do if buttons[i].pulse then buttons[i].pulse:Stop() end end
  holder.msg:SetText(msg and ("|cffffd100" .. msg .. "|r") or "")
  holder.msg:SetShown(msg ~= nil and not unlocked)
  holder:SetWidth(math.max(SIZE, #list * (SIZE + GAP) - GAP))
  holder.label:SetShown(unlocked)
  holder.bg:SetShown(unlocked)
end

ns.RegisterModule(function()
  if not ns.BUFF_WATCH or #ns.BUFF_WATCH == 0 then return end
  holder = CreateFrame("Frame", "@ADDON@BuffWatch", UIParent)
  holder:SetSize(SIZE, SIZE)
  holder:SetClampedToScreen(true)
  local p = ns.db.buffPos
  if p then holder:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else holder:SetPoint("CENTER", UIParent, "CENTER", 0, -220) end
  holder:SetScale(ns.db.buffScale or 1)
  holder:SetMovable(true)
  holder:EnableMouse(true)
  holder:RegisterForDrag("LeftButton")
  holder:SetScript("OnDragStart", function(self)
    if ns.db.shatterUnlocked and not (InCombatLockdown and InCombatLockdown()) then self:StartMoving() end
  end)
  holder:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.buffPos = { point, relPoint, x, y }
  end)
  holder:EnableMouseWheel(true)
  holder:SetScript("OnMouseWheel", function(self, delta)
    if not IsControlKeyDown() or not ns.db.shatterUnlocked or (InCombatLockdown and InCombatLockdown()) then return end
    local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.buffScale = s
  end)
  -- While "Move" is on: a faint box and a label so you can find and drag it.
  holder.bg = holder:CreateTexture(nil, "BACKGROUND")
  holder.bg:SetPoint("TOPLEFT", -4, 4)
  holder.bg:SetPoint("BOTTOMRIGHT", 4, -4)
  holder.bg:SetColorTexture(0, 0, 0, 0.35)
  holder.label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  holder.label:SetPoint("BOTTOM", holder, "TOP", 0, 6)
  holder.label:SetText(ns.T("BW_DRAG"))
  holder.msg = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  holder.msg:SetPoint("BOTTOM", holder, "TOP", 0, 8)

  local ev = CreateFrame("Frame")
  ev:RegisterEvent("UNIT_AURA")
  ev:RegisterEvent("PLAYER_REGEN_ENABLED")
  ev:RegisterEvent("UNIT_INVENTORY_CHANGED")
  pcall(ev.RegisterEvent, ev, "GROUP_ROSTER_UPDATE")
  pcall(ev.RegisterEvent, ev, "ENCOUNTER_START")
  pcall(ev.RegisterEvent, ev, "ENCOUNTER_END")
  pcall(ev.RegisterEvent, ev, "PLAYER_ENTERING_WORLD")
  ev:SetScript("OnEvent", function(_, event, unit)
    if event == "ENCOUNTER_START" then bossFight = true
    elseif event == "ENCOUNTER_END" or event == "PLAYER_ENTERING_WORLD" then bossFight = false end
    if event == "UNIT_AURA" and unit ~= "player" and not (type(unit) == "string" and unit:find("^party")) then return end
    ns.Debounce("buffs", 0.2, function() pcall(Update) end)
  end)
  -- Timers count down every second.
  ev:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 1 then return end
    acc = 0
    pcall(Update)
  end)
  C_Timer.After(2, function() pcall(Update) end)
end)

ns.RegisterCommand("buffs", true, function()
  ns.db.buffsOff = not ns.db.buffsOff
  ns.Print(ns.db.buffsOff and ns.T("BW_OFF") or ns.T("BW_ON"))
  pcall(Update)
end)

function ns.RefreshBuffWatch() pcall(Update) end

-- /@SLASH@ buffdebug: why an icon does or doesn't show.
ns.RegisterCommand("buffdebug", false, function()
  local buffs, unsure, _, ids = PlayerBuffs()
  ns.Print(string.format("buffs %s, move %s, combat %s, aura list %s", ns.db.buffsOff and "OFF" or "on",
    ns.db.shatterUnlocked and "ON" or "off", (InCombatLockdown and InCombatLockdown()) and "yes" or "no",
    unsure and "HIDDEN (secret)" or "readable"))
  for idx, e in ipairs(ns.BUFF_WATCH or {}) do
    local spell = Spells(e)
    local found
    for _, b in ipairs(e.buffs or {}) do if buffs[b] then found = b end end
    local byName = LookupByName("player", e.buffs)
    ns.Print(string.format("  %s: known %s, ticked %s, for this spec %s, on you %s, by name %s%s",
      EntryLabel(e, false), spell and "yes" or "NO", Hidden(EntryKey(e, idx, false)) and "NO" or "yes",
      (not e.only or e.only()) and "yes" or "no", found and "yes" or "no",
      byName == nil and "?" or (byName > 0 and "yes" or "no"),
      (found and Outranked(e.buffs, ids, spell)) and ", higher rank from someone else (not watched until it ends)" or ""))
  end
  -- Party: what the game lets us see of each member's buffs.
  ns.Print(string.format("  boss fight %s, party buffs %s", InEncounter() and "YES" or "no",
    ns.db.partyBuffsOff and "OFF" or "on"))
  if IsInGroup and IsInGroup() then
    for i = 1, 4 do
      local unit = "party" .. i
      if UnitExists(unit) then
        local theirs, unsureP, _, theirIds = PlayerBuffs(unit)
        local n, names = 0, {}
        for name in pairs(theirs) do n = n + 1; if n <= 4 then table.insert(names, name) end end
        local okN, who = pcall(UnitName, unit)
        if not okN or (issecretvalue and issecretvalue(who)) then who = unit end
        local parts = {}
        for _, e in ipairs(ns.PARTY_BUFFS or {}) do
          local list = type(e.spells) == "function" and e.spells(unit) or e.spells or {}
          local spell
          for _, s in ipairs(list) do if ns.SpellInfo(s) then spell = s break end end
          if spell then
            local has
            for _, b in ipairs(e.buffs or {}) do if theirs[b] then has = b end end
            local byName = LookupByName(unit, e.buffs)
            table.insert(parts, string.format("%s %s/by name %s%s", spell, has and "yes" or "no",
              byName == nil and "?" or (byName > 0 and "yes" or "no"),
              (has and Outranked(e.buffs, theirIds, spell)) and "/higher rank" or ""))
          end
        end
        ns.Print(string.format("  %s: %d buffs%s (%s) %s", tostring(who), n, unsureP and ", HIDDEN" or "",
          table.concat(names, ", "), table.concat(parts, "; ")))
      end
    end
  end
  local n = 0
  for _, b in ipairs(buttons) do if b:IsShown() then n = n + 1 end end
  ns.Print("  icons shown: " .. n)
end)

ns.RegisterCommand("partybuffs", false, function()
  ns.db.partyBuffsOff = not ns.db.partyBuffsOff
  ns.Print(ns.db.partyBuffsOff and ns.T("PB_OFF") or ns.T("PB_ON"))
  pcall(Update)
end)
