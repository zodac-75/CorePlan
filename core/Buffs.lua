-- @ADDON@: buff watcher. A movable row of icons for your own buffs (ns.BUFF_WATCH in
-- the class Data.lua) that shows up when a buff is missing or about to run out.
-- Click an icon to cast the buff. Turn on "Move" (/@SLASH@ move, same switch as the combat
-- helper) to see every watched buff, drag the row by any icon and resize it with Ctrl + wheel.
--
-- An entry: { spells = { "Arcane Intellect" } or function(plan) -> list,
--             buffs = { names that count }, match = function(name) -> bool,
--             imbue = true (weapon buff), only = function() -> bool, warn = seconds }
-- The icon casts the first spell in the list you know.
--
-- Party buffs (ns.PARTY_BUFFS, same fields plus mana = true for mana users only, or
-- spells = function(unit) -> list): one icon per party member who is missing it, with
-- their name on it; a click casts it on them.
local _, ns = ...

local SIZE, GAP, WARN = 36, 6, 60
local holder, buttons = nil, {}
local acc, pendingLayout = 0, false
local warned = {} -- spells already announced as running out (sound + message once)

-- Out of combat you get an earlier "rebuff now" heads-up (minutes; 0 = off).
ns.REBUFF_TIMES = { 0, 1, 2, 3, 5, 10 }
local function RebuffSec() return (ns.db.rebuffMin or 3) * 60 end

local function Spells(e)
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
  local out, unsure, durs = {}, false, {}
  local now = GetTime()
  for i = 1, 40 do
    local name, expires, dur
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
      local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, "HELPFUL")
      if not ok then unsure = true break end
      if not a then break end
      name, expires, dur = a.name, a.expirationTime, a.duration
    elseif UnitAura then
      local ok, n, _, _, d, _, exp = pcall(UnitAura, unit, i, "HELPFUL")
      if not ok then unsure = true break end
      if not n then break end
      name, expires, dur = n, exp, d
    else
      unsure = true
      break
    end
    if issecretvalue and (issecretvalue(name) or issecretvalue(expires)) then
      unsure = true
    elseif type(name) == "string" then
      local left = (type(expires) == "number" and expires > 0) and (expires - now) or 0
      out[name] = math.max(out[name] or 0, left)
      if ns.Readable(dur) and dur > 0 then durs[name] = dur end
    end
  end
  return out, unsure, durs
end

-- Seconds left on the weapon buff, 0 for none, nil when unknown.
local function ImbueLeft()
  if not GetWeaponEnchantInfo then return nil end
  local ok, has, ms = pcall(GetWeaponEnchantInfo)
  if not ok then return nil end
  if not has then return 0 end
  return (ms or 0) / 1000
end

-- What each entry needs now: { spell, left } where left = 0 means missing.
local function Needed()
  local buffs, unsure, durs = PlayerBuffs()
  local out = {}
  local combat = InCombatLockdown and InCombatLockdown()
  for idx, e in ipairs(ns.BUFF_WATCH or {}) do
    local spell = Spells(e)
    if spell and not Hidden(EntryKey(e, idx, false)) and (not e.only or e.only()) then
      local left, dur
      if e.imbue then
        local l = ImbueLeft()
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
        if best then left = best elseif not unsure then left = 0 end
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
      if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
        local theirs, unsureP = PlayerBuffs(unit)
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
            local warn = combat and (e.warn or WARN) or math.max(e.warn or WARN, math.min(RebuffSec(), 600))
            if left and (left == 0 or left < warn) then
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
local function InRange(unit)
  if not unit or not UnitInRange then return true end
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
    GameTooltip:AddLine(self.whoName and ns.T("BW_CLICK_ON", self.whoName) or ns.T("BW_CLICK"), 0.6, 0.8, 1)
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
        b:SetAlpha(still and (InRange(still.unit) and 1 or 0.4) or 0.25)
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
    b:SetAttribute("spell1", n.spell)
    b:SetAttribute("unit", n.unit or "player")
    b.who:SetText(n.who and n.who:sub(1, 7) or "")
    -- No casting while you're moving it.
    b:SetAttribute("type1", (not unlocked) and "spell" or nil)
    b.icon:SetTexture(ns.SpellIcon(n.spell))
    -- Red frame: missing. Yellow frame: running out.
    if n.left == 0 then b.border:SetColorTexture(1, 0.25, 0.25, 0.9)
    elseif n.left < 0 then b.border:SetColorTexture(0.5, 0.5, 0.5, 0.6)
    else b.border:SetColorTexture(1, 0.8, 0.25, 0.9) end
    b.time:SetText(n.left > 0 and Short(n.left) or "")
    b:ClearAllPoints()
    b:SetPoint("LEFT", holder, "LEFT", (i - 1) * (SIZE + GAP), 0)
    b:SetAlpha((n.left < 0 or not InRange(n.unit)) and 0.45 or 1)
    b:Show()
  end
  for i = #list + 1, #buttons do buttons[i]:Hide() end

  -- A heads-up the first time a buff starts running out (or goes missing) out of combat:
  -- a line above the row, the icon pulses, and the alert sound if sounds are on.
  local msg, now = nil, {}
  for i, n in ipairs(list) do
    if n.left >= 0 then
      now[n.key] = true
      if not warned[n.key] then
        warned[n.key] = true
        if (ns.db.alertSound or "off") ~= "off" and ns.PlayAlertSound then ns.PlayAlertSound() end
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
  for s in pairs(warned) do if not now[s] then warned[s] = nil end end
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
  ev:SetScript("OnEvent", function(_, event, unit)
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

ns.RegisterCommand("partybuffs", false, function()
  ns.db.partyBuffsOff = not ns.db.partyBuffsOff
  ns.Print(ns.db.partyBuffsOff and ns.T("PB_OFF") or ns.T("PB_ON"))
  pcall(Update)
end)
