-- @ADDON@: checks that your action bars have the highest rank and that new spells
-- are on a button. Forever no longer puts new spells on your bars by itself.
local _, ns = ...

local CHECK = ns.RANK_CHECK -- from the class Data.lua

local outdated, missing = {}, {}

local function RankNumber(id)
  if not GetSpellSubtext then return nil end
  local ok, s = pcall(GetSpellSubtext, id)
  if ok and type(s) == "string" then return tonumber(s:match("(%d+)")) end
  return nil
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
  for slot = 1, 120 do
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
  return onBar
end

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
          if s.macro then
            -- A macro is only outdated when it names a lower rank.
            if s.macroRank and bestRank and s.macroRank < bestRank then
              table.insert(newOutdated, ns.T("RANKS_OLD_MACRO", name, s.macroRank, s.macro, bestRank))
            end
          else
            local r = RankNumber(s.id)
            -- Only warn when both ranks can be read and the button has a lower one.
            if s.id ~= bestId and r and bestRank and r < bestRank then
              table.insert(newOutdated, ns.T("RANKS_OLD_LINE", name, r, s.slot, bestRank))
            end
          end
        end
      end
    end
  end

  outdated = newOutdated
  for _, n in ipairs(newMissing) do table.insert(missing, n) end

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

ns.RegisterCommand("ranks", true, function()
  missing = {}
  Scan(true)
end)
