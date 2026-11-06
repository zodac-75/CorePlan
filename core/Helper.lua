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
  return ns.ForEachAura("player", "HELPFUL", function(n) return n == buff end)
end

function ns.MyDebuffOnTarget(debuff)
  return ns.ForEachAura("target", "HARMFUL|PLAYER", function(n) return n == debuff end)
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

-- True when the spell is known and usable right now (enough rage/mana, proc active).
function ns.SpellUsable(spell)
  if not ns.SpellInfo(spell) then return false end
  local ok, usable, noPower
  if C_Spell and C_Spell.IsSpellUsable then
    ok, usable, noPower = pcall(C_Spell.IsSpellUsable, spell)
  elseif IsUsableSpell then
    ok, usable, noPower = pcall(IsUsableSpell, spell)
  end
  if not ok or (issecretvalue and (issecretvalue(usable) or issecretvalue(noPower))) then return false end
  return usable and not noPower and ns.CooldownLeft(spell) <= 0
end

function ns.MakeCombatHelper(update)
  local f, big, small, flash
  local acc, lastState = 0, nil

  local function Update()
    if ns.db.shatterOff then f:Hide(); return end
    local main, sub, state = update()
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
    ns.Print(ns.db.shatterUnlocked and ns.T("SH_UNLOCKED") or ns.T("SH_LOCKED"))
  end)
end
