-- @ADDON@: checks that your action bars have the highest rank and that new spells
-- are on a button. Forever no longer puts new spells on your bars by itself.
local _, ns = ...

local CHECK = ns.RANK_CHECK -- from the class Data.lua

local outdated, missing = {}, {}
local debugScan = false

local function Num(v)
  if type(v) ~= "number" or (issecretvalue and issecretvalue(v)) then return nil end
  return v
end

local function Call(fn, ...)
  if not fn then return nil end
  local ok, v = pcall(fn, ...)
  if ok then return v end
  return nil
end

-- "Rank 3" from the game, or nil when it hides it (Forever often returns "").
local function RankNumber(id)
  for _, fn in ipairs({ C_Spell and C_Spell.GetSpellSubtext, GetSpellSubtext }) do
    local s = Call(fn, id)
    if type(s) == "string" and not (issecretvalue and issecretvalue(s)) then
      local n = tonumber(s:match("(%d+)"))
      if n then return n end
    end
  end
  return nil
end

-- The level a rank is learned at: higher rank, higher level.
local function LevelOf(id)
  return Num(Call(C_Spell and C_Spell.GetSpellLevelLearned, id)) or Num(Call(GetSpellLevelLearned, id))
end

-- Mana/rage cost of a rank: higher rank usually costs more.
local function CostOf(id)
  local costs = Call(C_Spell and C_Spell.GetSpellPowerCost, id) or Call(GetSpellPowerCost, id)
  if type(costs) == "table" and costs[1] then return Num(costs[1].cost) end
  return nil
end

-- Is the button's spell an older rank than the one you know? Uses the rank text when
-- the game gives it, else the level it's learned at, else the cost.
-- Returns old (bool), button rank, best rank, how ("rank", "level", "cost").
local function OlderRank(id, bestId)
  if id == bestId then return false end
  local r, best = RankNumber(id), RankNumber(bestId)
  if r and best then return r < best, r, best, "rank" end
  local l, bl = LevelOf(id), LevelOf(bestId)
  if l and bl and l > 0 and bl > 0 and l ~= bl then return l < bl, r, best, "level" end
  local c, bc = CostOf(id), CostOf(bestId)
  if c and bc and c ~= bc then return c < bc, r, best, "cost" end
  return false, r, best, nil
end

-- Spells a macro casts: { {name = "Frostbolt", rank = 1 or nil}, ... }.
-- Reads /cast, /use, /castsequence, /castrandom and #showtooltip lines; drops
-- [conditions], "reset=" and "!". A spell without "(Rank N)" casts your highest rank.
local MACRO_CMDS = { cast = true, use = true, castsequence = true, castrandom = true, showtooltip = true }

local function MacroSpells(body)
  local out = {}
  if type(body) ~= "string" then return out end
  for line in body:gmatch("[^\r\n]+") do
    local cmd, args = line:match("^%s*[/#](%a+)%s*(.*)$")
    if cmd and MACRO_CMDS[cmd:lower()] then
      args = args:gsub("%b[]", ""):gsub("reset=%S+", "")
      for part in args:gmatch("[^;,]+") do
        part = part:gsub("^%s*!?", ""):gsub("%s+$", "")
        if part ~= "" then
          local rank = tonumber(part:match("%(%s*[Rr]ank%s*(%d+)%s*%)"))
          local name = part:gsub("%s*%(.-%)%s*$", "")
          table.insert(out, { name = name:lower(), rank = rank })
        end
      end
    end
  end
  return out
end

local function MacroBody(index)
  if GetMacroInfo then
    local ok, _, _, body = pcall(GetMacroInfo, index)
    if ok and type(body) == "string" then return body end
  end
  return nil
end

local function MacroName(index, slot)
  if GetMacroInfo then
    local ok, name = pcall(GetMacroInfo, index)
    if ok and type(name) == "string" then return name end
  end
  if GetActionText then
    local ok, t = pcall(GetActionText, slot)
    if ok and type(t) == "string" then return t end
  end
  return "?"
end

local function SpellsOnBars()
  local onBar = {}
  if not GetActionInfo then return onBar end
  local wanted = {} -- lower-case name -> spell name, for the spells we check
  for _, spell in ipairs(CHECK) do
    local name = ns.SpellInfo(spell)
    if name then wanted[name:lower()] = name end
  end
  local function Add(name, entry)
    onBar[name] = onBar[name] or {}
    table.insert(onBar[name], entry)
  end
  -- 1-360: the normal bars, the extra pages bar addons use, and the controller's sets.
  for slot = 1, 360 do
    local ok, kind, id = pcall(GetActionInfo, slot)
    if ok and kind == "spell" and id then
      local name = ns.SpellInfo(id)
      if name then Add(name, { slot = slot, id = id }) end
    elseif ok and kind == "macro" and id then
      -- Macros count as having the spell on a button. Only a macro that names an
      -- old rank, "Frostbolt(Rank 1)", is reported as outdated.
      local found = false
      for _, m in ipairs(MacroSpells(MacroBody(id))) do
        local name = wanted[m.name]
        if name then
          found = true
          Add(name, { slot = slot, macroRank = m.rank, macro = MacroName(id, slot) })
        end
      end
      if not found and GetMacroSpell then
        -- No readable text: ask the game which spell the macro shows.
        local okS, spellId = pcall(GetMacroSpell, id)
        local name = okS and spellId and ns.SpellInfo(spellId)
        if name then Add(name, { slot = slot, macro = MacroName(id, slot) }) end
      end
    end
  end
  -- Still not found: ask the game whether the spell is on any button at all. This also
  -- finds WoW Forever's controller layouts, wherever their slots are.
  local AB = C_ActionBar
  for _, name in pairs(wanted) do
    if not onBar[name] and AB then
      local _, id = ns.SpellInfo(name)
      if id then
        local ok, slots = pcall(AB.FindSpellActionButtons, id)
        if ok and type(slots) == "table" and slots[1] then
          for _, slot in ipairs(slots) do
            if type(slot) == "number" and not (issecretvalue and issecretvalue(slot)) then
              Add(name, { slot = slot, id = id })
            end
          end
        end
        if not onBar[name] and AB.IsOnBarOrSpecialBar then
          local ok2, on = pcall(AB.IsOnBarOrSpecialBar, id)
          if ok2 and on == true then Add(name, { slot = 0, bound = "bar" }) end
        end
      end
    end
  end
  -- Spells bound straight to a key or a controller button ("SPELL Frostbolt") count too.
  if GetBindingKey then
    for _, name in pairs(wanted) do
      if not onBar[name] then
        local ok, key = pcall(GetBindingKey, "SPELL " .. name)
        if ok and key then Add(name, { slot = 0, bound = key }) end
      end
    end
  end
  return onBar
end

local lastPrinted = ""

local function Scan(force)
  if InCombatLockdown and InCombatLockdown() then
    ns.rankScanPending = true
    return
  end
  ns.rankScanPending = false
  ns.db.missingSeen = ns.db.missingSeen or {}
  if force then ns.db.missingSeen = {} end

  local onBar = SpellsOnBars()
  local newOutdated, newMissing = {}, {}
  if debugScan then
    -- Where each checked spell was found (or not), to see how a controller layout shows up.
    for _, spell in ipairs(CHECK) do
      local name = ns.SpellInfo(spell)
      if name then
        local where = {}
        for _, s in ipairs(onBar[name] or {}) do
          where[#where + 1] = s.bound and ("bound " .. tostring(s.bound)) or s.macro and ("macro " .. s.macro .. " @" .. s.slot) or ("slot " .. s.slot)
        end
        ns.Print("  " .. name .. ": " .. (#where > 0 and table.concat(where, ", ") or "NOT FOUND"))
      end
    end
  end

  for _, spell in ipairs(CHECK) do
    local name, bestId = ns.SpellInfo(spell)
    if name and bestId then
      local slots = onBar[name]
      if not slots then
        if not ns.db.missingSeen[name] then
          table.insert(newMissing, name)
          ns.db.missingSeen[name] = true
        end
      else
        local bestRank = RankNumber(bestId)
        for _, s in ipairs(slots) do
          if s.bound then
            -- Bound to a key: nothing to check, the game casts the best rank.
          elseif s.macro then
            -- A macro is only outdated when it names a lower rank.
            if s.macroRank and bestRank and s.macroRank < bestRank then
              table.insert(newOutdated, ns.T("RANKS_OLD_MACRO", name, s.macroRank, s.macro, bestRank))
            end
          else
            local old, r, best = OlderRank(s.id, bestId)
            if old then
              if r and best then
                table.insert(newOutdated, ns.T("RANKS_OLD_LINE", name, r, s.slot, best))
              else
                table.insert(newOutdated, ns.T("RANKS_OLD_NORANK", name, s.slot))
              end
            end
            if debugScan then
              ns.Print(string.format("  %s: button %d id %s, best id %s, rank %s/%s, level %s/%s, cost %s/%s -> %s",
                name, s.slot, tostring(s.id), tostring(bestId), tostring(RankNumber(s.id)), tostring(RankNumber(bestId)),
                tostring(LevelOf(s.id)), tostring(LevelOf(bestId)), tostring(CostOf(s.id)), tostring(CostOf(bestId)),
                old and "OLD" or "ok"))
            end
          end
        end
      end
    end
  end

  outdated = newOutdated
  for _, n in ipairs(newMissing) do table.insert(missing, n) end

  -- Automatic checks are quiet when turned off, and never repeat the same list.
  local key = table.concat(newOutdated, "|")
  local quiet = not force and (ns.db.rankChatOff or key == lastPrinted)
  lastPrinted = key
  if quiet then
    newOutdated = {}
    if ns.db.rankChatOff then newMissing = {} end
  end
  if #newOutdated > 0 then
    ns.Print("|cffff9900" .. ns.T("RANKS_OLD_HDR") .. "|r")
    for _, l in ipairs(newOutdated) do ns.Print("  " .. l) end
    ns.Print("  " .. ns.T("RANKS_DRAG"))
  end
  if #newMissing > 0 then
    ns.Print("|cffff9900" .. ns.T("RANKS_MISSING") .. "|r " .. table.concat(newMissing, ", "))
  end
  if force and #newOutdated == 0 and #newMissing == 0 then
    ns.Print(ns.T("RANKS_OK"))
  end
  ns.RefreshMain()
end

ns.RegisterModule(function()
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("SPELLS_CHANGED")
  ev:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
  ev:RegisterEvent("UPDATE_MACROS")
  ev:RegisterEvent("PLAYER_REGEN_ENABLED")
  ev:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" and not ns.rankScanPending then return end
    ns.Debounce("ranks", 2, function() Scan(false) end)
  end)
  C_Timer.After(6, function() pcall(Scan, false) end)

  ns.AddStatusProvider(function()
    if #outdated > 0 then
      return { action = true, icon = "Interface\\Icons\\INV_Misc_Note_01",
        text = "|cffff9900" .. ns.T("RANKS_STATUS", #outdated) .. "|r",
        click = function() missing = {}; Scan(true) end, tip = ns.T("PW_CLICK_RANKS") }
    end
  end)
end)

ns.RegisterCommand("rankchat", true, function()
  ns.db.rankChatOff = not ns.db.rankChatOff
  ns.Print(ns.db.rankChatOff and ns.T("RANKCHAT_OFF") or ns.T("RANKCHAT_ON"))
end)

ns.RegisterCommand("ranks", true, function(arg)
  missing = {}
  -- "/@SLASH@ ranks debug" prints what the check sees for every button.
  debugScan = arg == "debug"
  Scan(true)
  debugScan = false
end)
