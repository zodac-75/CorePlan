-- @ADDON@: zone tips. A short note when you enter a place that matters for the plan:
-- profession trainers and recipe vendors, plus a few class tips.
local _, ns = ...

local TIPS = {
  { zone = "Shadowfang Keep", prof = "Tailoring",
    text = { "The Filigreed Silky Gown and Leggings patterns drop here.", "Mönstren för Filigreed Silky Gown och Leggings droppar här." } },
  { zone = "Deadmines", prof = "Tailoring",
    text = { "The Filigreed Silky Gown pattern drops here.", "Mönstret för Filigreed Silky Gown droppar här." } },
  { zone = "Tower of Azora", prof = "Enchanting",
    text = { "Kitta Firewind trains Expert Enchanting here (level 20).", "Kitta Firewind tränar Expert Enchanting här (level 20)." } },
  { zone = "Theramore", prof = "Tailoring",
    text = { "Timothy Worthington trains Artisan Tailoring here (level 35).", "Timothy Worthington tränar Artisan Tailoring här (level 35)." } },
  { zone = "Uldaman", prof = "Enchanting",
    text = { "Annora, the Artisan Enchanting trainer, is in here. Clear the way to her room.", "Annora, Artisan-trainern i Enchanting, finns här inne. Rensa vägen till hennes rum." } },
  { zone = "Silithus", prof = "Enchanting",
    text = { "Kania sells the Lesser Mana Oil formula here (Enchanting 250-265).", "Kania säljer formeln för Lesser Mana Oil här (Enchanting 250-265)." } },
  { zone = "Moonglade", prof = "Enchanting",
    text = { "Lorelae Wintersong sells the Runed Arcanite Rod formula here.", "Lorelae Wintersong säljer formeln för Runed Arcanite Rod här." } },
  { zone = "Mount Hyjal", prof = "Tailoring",
    text = { "Aisarra Nightmeadow sells the Malleable Essence of Nature pattern here (for Manaflare).", "Aisarra Nightmeadow säljer mönstret för Malleable Essence of Nature här (för Manaflare)." } },
  { zone = "Ironforge", prof = "Alchemy",
    text = { "Alchemy here: Vosur Brakthel (Apprentice, Tinker Town) and Tally Berryfizz (Journeyman, level 10).", "Alchemy här: Vosur Brakthel (Apprentice, Tinker Town) och Tally Berryfizz (Journeyman, level 10)." } },
  { zone = "Feathermoon", prof = "Alchemy",
    text = { "Kylanna Windwhisper trains Artisan Alchemy here (level 35), and Logannas sells the Nature Protection Potion recipe.", "Kylanna Windwhisper tränar Artisan Alchemy här (level 35), och Logannas säljer receptet på Nature Protection Potion." } },
  { zone = "Stormwind", prof = "Alchemy",
    text = { "Maria Lumere sells the Elixir of Shadow Power recipe (Alchemy 275-290).", "Maria Lumere säljer receptet på Elixir of Shadow Power (Alchemy 275-290)." } },
  { zone = "Three Corners", prof = "Alchemy",
    text = { "Nina Surefire sells Alchemy recipes for Merchant's Favor here, including Major Frenzy Potion (290-300).", "Nina Surefire säljer Alchemy-recept för Merchant's Favor här, bland annat Major Frenzy Potion (290-300)." } },
  -- Horde side (wow-professions, WoW Forever).
  { zone = "Undercity", prof = "Alchemy",
    text = { "Doctor Herbert Halsey trains Expert Alchemy here (level 20). Algernon sells the Superior Mana Potion and Elixir of Shadow Power recipes.", "Doctor Herbert Halsey tränar Expert Alchemy här (level 20). Algernon säljer recepten på Superior Mana Potion och Elixir of Shadow Power." } },
  { zone = "Undercity", prof = "Tailoring",
    text = { "Josef Gregorian trains Expert Tailoring here (level 20).", "Josef Gregorian tränar Expert Tailoring här (level 20)." } },
  { zone = "Undercity", prof = "Enchanting",
    text = { "Daniel Bartlett sells the Enchant Shield - Greater Stamina formula here (Enchanting 265, BoP).", "Daniel Bartlett säljer formeln Enchant Shield - Greater Stamina här (Enchanting 265, BoP)." } },
  { zone = "Orgrimmar", prof = "Blacksmithing",
    text = { "Saru Steelfury trains Expert Blacksmithing here (level 20). Tamar sells Green Dye.", "Saru Steelfury tränar Expert Blacksmithing här (level 20). Tamar säljer Green Dye." } },
  { zone = "Orgrimmar", prof = "Engineering",
    text = { "Roxxik trains Expert Engineering here (level 20), and Sovik sells the Thorium Widget schematic.", "Roxxik tränar Expert Engineering här (level 20), och Sovik säljer ritningen Thorium Widget." } },
  { zone = "Orgrimmar", prof = "Enchanting",
    text = { "Kithas sells the Minor Mana Oil and Lesser Wizard Oil formulas here.", "Kithas säljer formlerna Minor Mana Oil och Lesser Wizard Oil här." } },
  { zone = "Thunder Bluff", prof = "Leatherworking",
    text = { "Una trains Expert Leatherworking here (level 20).", "Una tränar Expert Leatherworking här (level 20)." } },
  { zone = "Sun Rock Retreat", prof = "Enchanting",
    text = { "Hgarth trains Expert Enchanting here (level 20).", "Hgarth tränar Expert Enchanting här (level 20)." } },
  { zone = "Tarren Mill", prof = "Tailoring",
    text = { "Daryl Stack trains Artisan Tailoring here (level 35).", "Daryl Stack tränar Artisan Tailoring här (level 35)." } },
  { zone = "Stonard", prof = "Alchemy",
    text = { "Rogvar trains Artisan Alchemy here (level 35).", "Rogvar tränar Artisan Alchemy här (level 35)." } },
  { zone = "Camp Mojache", prof = "Alchemy",
    text = { "Bronk sells the Nature Protection Potion recipe here (Alchemy 195).", "Bronk säljer receptet på Nature Protection Potion här (Alchemy 195)." } },
  { zone = "Camp Mojache", prof = "Leatherworking",
    text = { "Hahrana Ironhide trains Artisan Leatherworking here (level 35).", "Hahrana Ironhide tränar Artisan Leatherworking här (level 35)." } },
  { zone = "Crossroads", prof = "Alchemy",
    text = { "Apothecary Durelle (supply camp outside the Crossroads) sells Alchemy recipes for Merchant's Favor, including Major Frenzy Potion (290-300).", "Apothecary Durelle (förrådslägret utanför Crossroads) säljer Alchemy-recept för Merchant's Favor, bland annat Major Frenzy Potion (290-300)." } },
  { zone = "Booty Bay", prof = "Blacksmithing",
    text = { "Brikk Keencraft trains Artisan Blacksmithing here (level 35), for both factions.", "Brikk Keencraft tränar Artisan Blacksmithing här (level 35), för båda fraktionerna." } },
  { zone = "Gadgetzan", prof = "Engineering",
    text = { "Buzzek Bracketswing trains Artisan Engineering here (level 35), for both factions.", "Buzzek Bracketswing tränar Artisan Engineering här (level 35), för båda fraktionerna." } },
  { zone = "Aerie Peak", prof = "Leatherworking",
    text = { "Drakk Stonehand trains Artisan Leatherworking here (level 35).", "Drakk Stonehand tränar Artisan Leatherworking här (level 35)." } },
  { zone = "Valanaar", prof = "Alchemy",
    text = { "Apprentice Alchemy here: Iaadaria Bitterwind or Valiena Swiftgale.", "Apprentice Alchemy här: Iaadaria Bitterwind eller Valiena Swiftgale." } },
  { zone = "Darnassus", prof = "Alchemy",
    text = { "Alchemy here: Sylvanna Forestmoon (Journeyman, level 10) and Ainethil (Expert, level 20). Ulthir sells the Superior Mana Potion recipe.", "Alchemy här: Sylvanna Forestmoon (Journeyman, level 10) och Ainethil (Expert, level 20). Ulthir säljer receptet på Superior Mana Potion." } },
}

-- Class tips (ns.CLASS_TIPS in the class Data.lua) come after the profession tips.
for _, tip in ipairs(ns.CLASS_TIPS or {}) do table.insert(TIPS, tip) end

local shown = {}

local function Places()
  local list = {}
  if GetZoneText then table.insert(list, GetZoneText() or "") end
  if GetSubZoneText then table.insert(list, GetSubZoneText() or "") end
  if GetRealZoneText then table.insert(list, GetRealZoneText() or "") end
  if GetInstanceInfo then
    local ok, name = pcall(GetInstanceInfo)
    if ok and name then table.insert(list, name) end
  end
  return table.concat(list, " | ")
end

local function Check()
  if ns.db.zoneTipsOff then return end
  local here = Places()
  for i, tip in ipairs(TIPS) do
    if not shown[i] and here:find(tip.zone, 1, true) then
      local relevant = true
      if tip.prof then
        local skill = ns.GetProfSkill(tip.prof)
        relevant = ns.HasProf(tip.prof) and (skill == nil or skill < 300)
      end
      if relevant then
        shown[i] = true
        local text = ns.Tx(tip.text)
        if UIErrorsFrame and UIErrorsFrame.AddMessage then UIErrorsFrame:AddMessage(text, 0.4, 0.8, 1) end
        ns.Print("|cff66ccff" .. text .. "|r")
      end
    end
  end
end

ns.RegisterModule(function()
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("PLAYER_ENTERING_WORLD")
  ev:RegisterEvent("ZONE_CHANGED")
  ev:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  ev:RegisterEvent("ZONE_CHANGED_INDOORS")
  ev:SetScript("OnEvent", function() ns.Debounce("zonetips", 1, Check) end)
end)

ns.RegisterCommand("zonetips", true, function()
  ns.db.zoneTipsOff = not ns.db.zoneTipsOff
  ns.Print(ns.db.zoneTipsOff and ns.T("ZONE_OFF") or ns.T("ZONE_ON"))
end)
