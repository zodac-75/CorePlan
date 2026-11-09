-- Profession data shared by the Plan addons.
-- Leveling routes 1-300 for the crafting professions, what the gathering professions can
-- gather at each skill, and the secondary skills, for WoW Forever (both factions).
-- Routes, trainers and recipe vendors follow wow-professions.com's WoW Forever guides; the
-- parts they wrote during the beta (mostly 225-300) are marked untested = true.
-- mats = { {itemID, amount per craft, name}, ... }; batch = true: make the whole batch.
-- Texts can be { A = ..., H = ... } for Alliance and Horde (see ns.Tx).
local _, ns = ...

-- Primary professions, in the order the settings window cycles through them.
ns.PROFS = { "Alchemy", "Blacksmithing", "Enchanting", "Engineering", "Herbalism",
  "Leatherworking", "Mining", "Skinning", "Tailoring" }
ns.GATHERING = { Herbalism = true, Mining = true, Skinning = true }

-- Rank cap -> character level needed for the next rank.
ns.RANK_LEVEL = { [75] = 10, [150] = 20, [225] = 35 }

-- Where to train each rank, per faction. [50] = Journeyman, [125] = Expert, [200] = Artisan.
-- From wow-professions.com's WoW Forever guides.
ns.PROF_TRAINERS = {
  Alchemy = { [50] = { A = "Lilyssia Nightbreeze (Stormwind) / Tally Berryfizz (Ironforge) / Sylvanna Forestmoon (Darnassus)", H = "Yelmak (Orgrimmar) / Doctor Marsh (Undercity) / Bena Winterhoof (Thunder Bluff)" }, [125] = { A = "Ainethil (Darnassus)", H = "Doctor Herbert Halsey (Undercity)" }, [200] = { A = "Kylanna Windwhisper (Feathermoon, Feralas)", H = "Rogvar (Stonard, Swamp of Sorrows)" } },
  Blacksmithing = { [50] = { A = "Therum Deepforge (Stormwind) / Rotgath Stonebeard (Ironforge)", H = "Snarl (Orgrimmar) / James Van Brunt (Undercity) / Karn Stonehoof (Thunder Bluff)" }, [125] = { A = "Bengus Deepforge (Ironforge)", H = "Saru Steelfury (Orgrimmar)" }, [200] = "Brikk Keencraft (Booty Bay)" },
  Enchanting = { [50] = { A = "Lucan Cordell (Stormwind) / Gimble Thistlefuzz (Ironforge) / Taladan (Darnassus)", H = "Godan (Orgrimmar) / Lavinia Crowe (Undercity) / Teg Dawnstrider (Thunder Bluff)" }, [125] = { A = "Kitta Firewind (Tower of Azora, Elwynn)", H = "Hgarth (Sun Rock Retreat, Stonetalon)" }, [200] = "Annora (Uldaman, bring a group)" },
  Engineering = { [50] = { A = "Lilliam Sparkspindle (Stormwind) / Trixie Quikswitch (Ironforge)", H = "Nogg (Orgrimmar) / Franklin Lloyd (Undercity)" }, [125] = { A = "Springspindle Fizzlegear (Ironforge)", H = "Roxxik (Orgrimmar)" }, [200] = "Buzzek Bracketswing (Gadgetzan)" },
  Leatherworking = { [50] = { A = "Simon Tanner (Stormwind) / Fimble Finespindle (Ironforge) / Faldron (Darnassus)", H = "Karolek (Orgrimmar) / Arthur Moore (Undercity) / Tarn (Thunder Bluff)" }, [125] = { A = "Telonis (Darnassus)", H = "Una (Thunder Bluff)" }, [200] = { A = "Drakk Stonehand (Aerie Peak, Hinterlands)", H = "Hahrana Ironhide (Camp Mojache, Feralas)" } },
  Tailoring = { [50] = { A = "Sellandus (Stormwind) / Jormund Stonebrow (Ironforge) / Me'lynn (Darnassus)", H = "Magar (Orgrimmar) / Rhiannon Davis (Undercity) / Tepa (Thunder Bluff)" }, [125] = { A = "Georgio Bolero (Stormwind)", H = "Josef Gregorian (Undercity)" }, [200] = { A = "Timothy Worthington (Theramore)", H = "Daryl Stack (Tarren Mill)" } },
  Herbalism = { [50] = { A = "Tannysa (Stormwind) / Reyna Stonebranch (Ironforge) / Firodren Mooncaller (Darnassus)", H = "Jandi (Orgrimmar) / Martha Alliestar (Undercity) / Komin Winterhoof (Thunder Bluff)" }, [125] = { A = "Tannysa (Stormwind) / Reyna Stonebranch (Ironforge) / Firodren Mooncaller (Darnassus)", H = "Jandi (Orgrimmar) / Martha Alliestar (Undercity) / Komin Winterhoof (Thunder Bluff)" }, [200] = { A = "Tannysa (Stormwind) / Reyna Stonebranch (Ironforge) / Firodren Mooncaller (Darnassus)", H = "Jandi (Orgrimmar) / Martha Alliestar (Undercity) / Komin Winterhoof (Thunder Bluff)" } },
  Mining = { [50] = { A = "Gelman Stonehand (Stormwind) / Geofram Bouldertoe (Ironforge)", H = "Makaru (Orgrimmar) / Brom Killian (Undercity) / Brek Stonehoof (Thunder Bluff)" }, [125] = { A = "Gelman Stonehand (Stormwind) / Geofram Bouldertoe (Ironforge)", H = "Makaru (Orgrimmar) / Brom Killian (Undercity) / Brek Stonehoof (Thunder Bluff)" }, [200] = { A = "Gelman Stonehand (Stormwind) / Geofram Bouldertoe (Ironforge)", H = "Makaru (Orgrimmar) / Brom Killian (Undercity) / Brek Stonehoof (Thunder Bluff)" } },
  Skinning = { [50] = { A = "Maris Granger (Stormwind) / Balthus Stoneflayer (Ironforge) / Eladriel (Darnassus)", H = "Thuwd (Orgrimmar) / Killian Hagey (Undercity) / Mooranta (Thunder Bluff)" }, [125] = { A = "Maris Granger (Stormwind) / Balthus Stoneflayer (Ironforge) / Eladriel (Darnassus)", H = "Thuwd (Orgrimmar) / Killian Hagey (Undercity) / Mooranta (Thunder Bluff)" }, [200] = { A = "Maris Granger (Stormwind) / Balthus Stoneflayer (Ironforge) / Eladriel (Darnassus)", H = "Thuwd (Orgrimmar) / Killian Hagey (Undercity) / Mooranta (Thunder Bluff)" } },
}

ns.ROUTES = {}

-- Bolts -> råtyg (för att räkna ut hur mycket cloth som saknas).
ns.BOLTS = {
  [2996]  = { raw = 2589,  ratio = 2, name = "Linen Cloth" },
  [2997]  = { raw = 2592,  ratio = 3, name = "Wool Cloth" },
  [4305]  = { raw = 4306,  ratio = 4, name = "Silk Cloth" },
  [4339]  = { raw = 4338,  ratio = 5, name = "Mageweave Cloth" },
  [14048] = { raw = 14047, ratio = 4, name = "Runecloth" },
}

-- Cloth som visas i sammanfattningen.
ns.CLOTH = {
  { 2589,  "Linen" }, { 2592, "Wool" }, { 4306, "Silk" },
  { 4338,  "Mageweave" }, { 14047, "Runecloth" },
}

ns.ROUTES.Tailoring = {
  { from = 1, to = 30, crafts = 30, craft = "Bolt of Linen Cloth", mats = { {2589, 2, "Linen Cloth"} },
    note = { "Save the bolts for Linen Belt", "Spara bolts till Linen Belt" } },
  { from = 30, to = 55, crafts = 28, craft = "Linen Belt", mats = { {2996, 1, "Bolt of Linen Cloth"}, {2320, 1, "Coarse Thread"} } },
  { from = 55, to = 80, crafts = 45, craft = "Bolt of Woolen Cloth", mats = { {2592, 3, "Wool Cloth"} },
    note = { "You need 153 woolen bolts up to 140, so make more later", "Du behöver 153 woolen bolts fram till 140, så gör fler senare" } },
  { from = 80, to = 95, crafts = 22, craft = "Woolen Cape", mats = { {2997, 1, "Bolt of Woolen Cloth"}, {2321, 1, "Fine Thread"} } },
  { from = 95, to = 100, crafts = 5, craft = "Double-stitched Woolen Shoulders", mats = { {2997, 3, "Bolt of Woolen Cloth"}, {2321, 2, "Fine Thread"} } },
  { from = 100, to = 120, crafts = 54, craft = "Bolt of Silk Cloth", mats = { {4306, 4, "Silk Cloth"} },
    note = { "You need 184 silk bolts up to 190", "Du behöver 184 silk bolts fram till 190" } },
  { from = 120, to = 140, crafts = 29, craft = "Gloves of Meditation", mats = { {2997, 4, "Bolt of Woolen Cloth"}, {2321, 3, "Fine Thread"}, {3383, 1, "Elixir of Wisdom"} } },
  { from = 140, to = 150, crafts = 23, craft = "Bolt of Mageweave", mats = { {4338, 5, "Mageweave Cloth"} },
    note = { "You need 180 mageweave bolts up to 225", "Du behöver 180 mageweave bolts fram till 225" } },
  { from = 150, to = 170, crafts = 20, craft = "Crimson Silk Vest", mats = { {4305, 4, "Bolt of Silk Cloth"}, {2604, 2, "Red Dye"}, {2321, 2, "Fine Thread"} } },
  { from = 170, to = 190, crafts = 26, craft = "Crimson Silk Pantaloons", mats = { {4305, 4, "Bolt of Silk Cloth"}, {2604, 2, "Red Dye"}, {4291, 2, "Silken Thread"} } },
  { from = 190, to = 215, crafts = 38, craft = "Black Mageweave Gloves", mats = { {4339, 2, "Bolt of Mageweave"}, {8343, 2, "Heavy Silken Thread"} } },
  { from = 215, to = 225, crafts = 26, craft = "Mageweave Bag", mats = { {4339, 4, "Bolt of Mageweave"}, {4291, 2, "Silken Thread"} } },
  { from = 225, to = 240, crafts = 24, craft = "Runecloth Belt", mats = { {14048, 3, "Bolt of Runecloth"}, {14341, 1, "Rune Thread"} }, untested = true,
    note = { "From the Artisan trainer. Bolts no longer give points here, so make all 244 at once", "Från Artisan-tränaren. Bolts ger inga poäng här längre, så gör alla 244 på en gång" } },
  { from = 240, to = 265, crafts = 43, craft = "Runecloth Gloves", mats = { {14048, 4, "Bolt of Runecloth"}, {8170, 4, "Rugged Leather"}, {14341, 1, "Rune Thread"} }, untested = true,
    note = { "Pattern: Qia, Everlook (Winterspring)", "Mönster: Qia, Everlook (Winterspring)" } },
  { from = 265, to = 270, crafts = 6, craft = "Earthenweave Leggings", mats = { {14048, 6, "Bolt of Runecloth"}, {7076, 2, "Essence of Earth"}, {14341, 1, "Rune Thread"} }, untested = true,
    note = { "The Forever guide stops at 265: from here it's the older route", "Forever-guiden slutar vid 265: härifrån är det den äldre vägen" } },
  { from = 270, to = 285, crafts = 21, craft = "Earthenweave Cuffs", mats = { {14048, 5, "Bolt of Runecloth"}, {7076, 1, "Essence of Earth"}, {14341, 1, "Rune Thread"} }, untested = true },
  { from = 285, to = 296, crafts = 24, craft = "Earthenweave Crown", mats = { {14048, 6, "Bolt of Runecloth"}, {7076, 3, "Essence of Earth"}, {14341, 1, "Rune Thread"} }, untested = true },
  { from = 296, to = 300, crafts = 6, craft = "Mooncloth Boots", mats = { {14048, 6, "Bolt of Runecloth"}, {14342, 4, "Mooncloth"}, {7971, 2, "Black Pearl"}, {14341, 1, "Rune Thread"} }, untested = true },
}

ns.ROUTES.Enchanting = {
  { from = 1, to = 2, crafts = 1, craft = "Runed Copper Rod", mats = { {6217, 1, "Copper Rod"}, {247786, 1, "Mote of Magic"} },
    note = { "Both from the Enchanting Supply vendor. Disenchant is in the Professions window, not the spellbook", "Båda hos Enchanting Supply. Disenchant finns i Professions-fönstret, inte i spellbooken" } },
  { from = 2, to = 20, crafts = 18, craft = "Enchant Bracer - Inferior Stamina", mats = { {247786, 1, "Mote of Magic"} } },
  { from = 20, to = 70, crafts = 50, craft = "Enchant Chest - Inferior Stamina", mats = { {10940, 1, "Strange Dust"} },
    note = { "Or Enchant Bracer - Minor Deflect (Lesser Magic Essence)", "Eller Enchant Bracer - Minor Deflect (Lesser Magic Essence)" } },
  { from = 70, to = 100, crafts = 30, craft = "Enchant Bracer - Minor Stamina", mats = { {10940, 2, "Strange Dust"} },
    note = { "Lots of essences instead? Enchant Chest - Minor Absorption to 109", "Mest essences? Enchant Chest - Minor Absorption till 109" } },
  { from = 100, to = 109, crafts = 9, craft = "Enchant Cloak - Minor Protection", mats = { {10940, 2, "Strange Dust"} } },
  { from = 109, to = 110, crafts = 1, craft = "Runed Silver Rod", mats = { {6338, 1, "Silver Rod"}, {10940, 3, "Strange Dust"}, {10938, 4, "Lesser Magic Essence"}, {1210, 1, "Shadowgem"} } },
  { from = 110, to = 130, crafts = 32, craft = "Enchant Cloak - Minor Protection", mats = { {10940, 2, "Strange Dust"} },
    note = { A = { "Buy the Minor Mana Oil and Lesser Wizard Oil formulas now: Tilli Thistlefuzz (Ironforge), Jessara Cordell (Stormwind) or Vaean (Darnassus)", "Köp formlerna Minor Mana Oil och Lesser Wizard Oil nu: Tilli Thistlefuzz (Ironforge), Jessara Cordell (Stormwind) eller Vaean (Darnassus)" }, H = { "Buy the Minor Mana Oil and Lesser Wizard Oil formulas now: Kithas (Orgrimmar), Nata Dawnstrider (Thunder Bluff) or Thaddeus Webb (Undercity)", "Köp formlerna Minor Mana Oil och Lesser Wizard Oil nu: Kithas (Orgrimmar), Nata Dawnstrider (Thunder Bluff) eller Thaddeus Webb (Undercity)" } } },
  { from = 130, to = 150, crafts = 20, craft = "Enchant Boots - Minor Stamina", mats = { {10940, 4, "Strange Dust"} },
    note = { "Or Enchant 2H Weapon - Lesser Intellect (Lesser Magic Essence)", "Eller Enchant 2H Weapon - Lesser Intellect (Lesser Magic Essence)" } },
  { from = 150, to = 151, crafts = 1, craft = "Runed Golden Rod", mats = { {11128, 1, "Golden Rod"}, {5500, 1, "Iridescent Pearl"}, {11082, 1, "Greater Astral Essence"}, {11083, 1, "Soul Dust"} } },
  { from = 151, to = 165, crafts = 16, craft = "Minor Mana Oil", mats = { {11083, 1, "Soul Dust"}, {17034, 2, "Maple Seed"}, {3372, 1, "Leaded Vial"} },
    note = { "Maple Seed: Reagent vendor. Leaded Vial: Alchemy Supply", "Maple Seed: Reagent-försäljare. Leaded Vial: Alchemy Supply" } },
  { from = 165, to = 200, crafts = 47, craft = "Enchant Boots - Lesser Agility", mats = { {11083, 1, "Soul Dust"} },
    note = { "Vision Dust cheaper? Stop at 185 and make Enchant Bracer - Strength to 200", "Billigare Vision Dust? Sluta vid 185 och gör Enchant Bracer - Strength till 200" } },
  { from = 200, to = 201, crafts = 1, craft = "Runed Truesilver Rod", mats = { {11144, 1, "Truesilver Rod"}, {7971, 1, "Black Pearl"}, {11135, 1, "Greater Mystic Essence"}, {11137, 1, "Vision Dust"} },
    note = { "Annora (Uldaman) shows up when her room is cleared: bring a group, learn all her recipes and enough Vision Dust for 250", "Annora (Uldaman) dyker upp när rummet är rensat: ta med en grupp, lär dig alla hennes recept och Vision Dust till 250" } },
  { from = 201, to = 220, crafts = 25, craft = "Lesser Wizard Oil", mats = { {11137, 1, "Vision Dust"}, {17035, 2, "Stranglethorn Seed"}, {3372, 1, "Leaded Vial"} } },
  { from = 220, to = 225, crafts = 5, craft = "Enchant Cloak - Greater Defense", mats = { {11137, 1, "Vision Dust"} } },
  { from = 225, to = 230, crafts = 5, craft = "Enchant Gloves - Agility", mats = { {11137, 1, "Vision Dust"} }, untested = true },
  { from = 230, to = 235, crafts = 5, craft = "Enchant Boots - Stamina", mats = { {11137, 2, "Vision Dust"} }, untested = true },
  { from = 235, to = 250, crafts = 20, craft = "Enchant Chest - Superior Stamina", mats = { {11137, 3, "Vision Dust"} }, untested = true },
  { from = 250, to = 265, crafts = 20, craft = "Lesser Mana Oil", mats = { {11176, 1, "Dream Dust"}, {8831, 1, "Purple Lotus"}, {8925, 1, "Crystal Vial"} }, untested = true,
    note = { "Formula: Kania, Silithus (upstairs in the inn). No Purple Lotus? Enchant Bracer - Greater Strength", "Formel: Kania, Silithus (övervåningen på värdshuset). Ingen Purple Lotus? Enchant Bracer - Greater Strength" } },
  { from = 265, to = 294, crafts = 32, craft = "Enchant Shield - Greater Stamina", mats = { {11176, 6, "Dream Dust"} }, untested = true,
    note = { A = { "Formula (BoP): Mythrin'dir, Darnassus", "Formel (BoP): Mythrin'dir, Darnassus" }, H = { "Formula (BoP): Daniel Bartlett, Undercity", "Formel (BoP): Daniel Bartlett, Undercity" } } },
  { from = 294, to = 295, crafts = 1, craft = "Runed Arcanite Rod", mats = { {16206, 1, "Arcanite Rod"}, {13926, 1, "Golden Pearl"}, {16204, 10, "Illusion Dust"}, {16203, 4, "Greater Eternal Essence"}, {14343, 4, "Small Brilliant Shard"}, {14344, 2, "Large Brilliant Shard"} }, untested = true,
    note = { "Formula: Lorelae Wintersong, Moonglade (buy Cloak - Superior Defense there too)", "Formel: Lorelae Wintersong, Moonglade (köp Cloak - Superior Defense där också)" } },
  { from = 295, to = 300, crafts = 5, craft = "Enchant Cloak - Superior Defense", mats = { {16204, 8, "Illusion Dust"} }, untested = true },
}

ns.ROUTES.Alchemy = {
  { from = 1, to = 10, crafts = 9, craft = "Minor Arcane Elixir", mats = { {2447, 1, "Peacebloom"}, {3371, 1, "Empty Vial"} },
    note = { "Or Elixir of Minor Force (Silverleaf). Apprentice has no level requirement in Forever", "Eller Elixir of Minor Force (Silverleaf). Apprentice har inget level-krav i Forever" } },
  { from = 10, to = 55, crafts = 45, craft = "Elixir of Minor Defense", mats = { {765, 1, "Silverleaf"}, {2447, 1, "Peacebloom"}, {3371, 1, "Empty Vial"} } },
  { from = 55, to = 65, crafts = 10, craft = "Minor Mana Potion", mats = { {785, 1, "Mageroyal"}, {2447, 1, "Peacebloom"}, {3371, 1, "Empty Vial"} } },
  { from = 65, to = 90, crafts = 27, craft = "Elixir of Minor Fortitude", mats = { {2449, 2, "Earthroot"}, {2447, 1, "Peacebloom"}, {3371, 1, "Empty Vial"} } },
  { from = 90, to = 120, crafts = 30, craft = "Elixir of Wisdom", mats = { {785, 1, "Mageroyal"}, {2450, 2, "Briarthorn"}, {3371, 1, "Empty Vial"} } },
  { from = 120, to = 130, crafts = 10, craft = "Lesser Mana Potion", mats = { {785, 1, "Mageroyal"}, {3820, 1, "Stranglekelp"}, {3371, 1, "Empty Vial"} } },
  { from = 130, to = 150, crafts = 20, craft = "Fire Oil", mats = { {6359, 2, "Firefin Snapper"}, {3371, 1, "Empty Vial"} },
    note = { "Each craft gives 2 Fire Oil: keep 30 for Elixir of Fire Power. Or 20 Lesser Mana Potion", "Varje craft ger 2 Fire Oil: spara 30 till Elixir of Fire Power. Eller 20 Lesser Mana Potion" } },
  { from = 150, to = 165, crafts = 15, craft = "Elixir of Fire Power", mats = { {6371, 2, "Fire Oil"}, {3356, 1, "Kingsblood"}, {3372, 1, "Leaded Vial"} },
    note = { "Or 22 Lesser Mana Potion", "Eller 22 Lesser Mana Potion" } },
  { from = 165, to = 195, crafts = 36, craft = "Mana Potion", mats = { {3820, 1, "Stranglekelp"}, {3356, 1, "Kingsblood"}, {3372, 1, "Leaded Vial"} } },
  { from = 195, to = 225, crafts = 36, craft = "Nature Protection Potion", mats = { {3357, 1, "Liferoot"}, {3820, 1, "Stranglekelp"}, {3372, 1, "Leaded Vial"} },
    note = { A = { "Recipe (BoP): Logannas (Feralas), Glyx Brewright (Stranglethorn) or Alchemist Pestlezugg (Tanaris)", "Recept (BoP): Logannas (Feralas), Glyx Brewright (Stranglethorn) eller Alchemist Pestlezugg (Tanaris)" }, H = { "Recipe (BoP): Bronk (Feralas), Glyx Brewright (Stranglethorn) or Alchemist Pestlezugg (Tanaris)", "Recept (BoP): Bronk (Feralas), Glyx Brewright (Stranglethorn) eller Alchemist Pestlezugg (Tanaris)" } } },
  { from = 225, to = 230, crafts = 12, craft = "Nature Protection Potion", mats = { {3357, 1, "Liferoot"}, {3820, 1, "Stranglekelp"}, {3372, 1, "Leaded Vial"} }, untested = true },
  { from = 230, to = 240, crafts = 20, craft = "Greater Mana Potion", mats = { {3358, 1, "Khadgar's Whisker"}, {3821, 1, "Goldthorn"}, {3372, 1, "Leaded Vial"} }, untested = true },
  { from = 240, to = 265, crafts = 35, craft = "Draught of Detect Undead", mats = { {8836, 1, "Arthas' Tears"}, {8925, 1, "Crystal Vial"} }, untested = true },
  { from = 265, to = 290, crafts = 30, craft = "Superior Mana Potion", mats = { {8838, 2, "Sungrass"}, {8839, 2, "Blindweed"}, {8925, 1, "Crystal Vial"} }, untested = true,
    note = { A = { "Recipe (BoP): Ulthir, Darnassus. Or Elixir of Greater Defense / Elixir of Shadow Power (Maria Lumere, Stormwind)", "Recept (BoP): Ulthir, Darnassus. Eller Elixir of Greater Defense / Elixir of Shadow Power (Maria Lumere, Stormwind)" }, H = { "Recipe (BoP): Algernon, Undercity. Or Elixir of Greater Defense / Elixir of Shadow Power (also Algernon)", "Recept (BoP): Algernon, Undercity. Eller Elixir of Greater Defense / Elixir of Shadow Power (också Algernon)" } } },
  { from = 290, to = 300, crafts = 17, craft = "Major Frenzy Potion", mats = { {13466, 3, "Plaguebloom"}, {8839, 2, "Blindweed"}, {18256, 1, "Imbued Vial"} }, untested = true,
    note = { A = { "Recipe for Merchant's Favor: Nina Surefire, Three Corners (Redridge). The guide hasn't settled the last 10 points", "Recept för Merchant's Favor: Nina Surefire, Three Corners (Redridge). Guiden har inte bestämt de sista 10 poängen" }, H = { "Recipe for Merchant's Favor: Apothecary Durelle, camp outside the Crossroads (Durotar Supply). The guide hasn't settled the last 10 points", "Recept för Merchant's Favor: Apothecary Durelle, lägret utanför Crossroads (Durotar Supply). Guiden har inte bestämt de sista 10 poängen" } } },
}

ns.ROUTES.Blacksmithing = {
  { from = 1, to = 25, crafts = 30, craft = "Rough Sharpening Stone", mats = { {2835, 1, "Rough Stone"} },
    note = { "Buy a Blacksmith Hammer from the Blacksmithing Supply vendor by the trainer (needed from 67)", "Köp en Blacksmith Hammer hos Blacksmithing Supply bredvid tränaren (behövs från 67)" } },
  { from = 25, to = 50, crafts = 30, craft = "Rough Grinding Stone", mats = { {2835, 2, "Rough Stone"} },
    note = { "Keep 26 for Runed Copper Gauntlets", "Spara 26 till Runed Copper Gauntlets" } },
  { from = 50, to = 67, crafts = 36, craft = "Coarse Grinding Stone", mats = { {2836, 2, "Coarse Stone"} },
    note = { "Keep the stones for Patterned Bronze Bracers", "Spara stenarna till Patterned Bronze Bracers" } },
  { from = 67, to = 75, crafts = 8, craft = "Runed Copper Gauntlets", mats = { {2840, 8, "Copper Bar"}, {3470, 2, "Rough Grinding Stone"} } },
  { from = 75, to = 95, crafts = 23, craft = "Runed Copper Belt", mats = { {2840, 10, "Copper Bar"} },
    note = { "Or Silver Rod (Silver Bar + 2 Rough Grinding Stone) for 75-80", "Eller Silver Rod (Silver Bar + 2 Rough Grinding Stone) för 75-80" } },
  { from = 95, to = 100, crafts = 5, craft = "Patterned Bronze Bracers", mats = { {2841, 5, "Bronze Bar"}, {3478, 2, "Coarse Grinding Stone"} } },
  { from = 100, to = 112, crafts = 20, craft = "Heavy Grinding Stone", mats = { {2838, 3, "Heavy Stone"} },
    note = { "Keep all 20 for Golden Scale Bracers at 180", "Spara alla 20 till Golden Scale Bracers vid 180" } },
  { from = 112, to = 125, crafts = 13, craft = "Patterned Bronze Bracers", mats = { {2841, 5, "Bronze Bar"}, {3478, 2, "Coarse Grinding Stone"} } },
  { from = 125, to = 140, crafts = 24, craft = "Bronze Shortsword", mats = { {2841, 5, "Bronze Bar"}, {2880, 4, "Weak Flux"}, {2319, 2, "Medium Leather"} },
    note = { "Or Patterned Bronze Bracers", "Eller Patterned Bronze Bracers" } },
  { from = 140, to = 170, crafts = 39, craft = "Bronze Warhammer", mats = { {2841, 8, "Bronze Bar"}, {3466, 1, "Strong Flux"}, {2319, 1, "Medium Leather"} } },
  { from = 170, to = 175, crafts = 9, craft = "Green Iron Bracers", mats = { {3575, 6, "Iron Bar"}, {2605, 1, "Green Dye"} },
    note = { A = { "Green Dye: Bombus Finespindle, Ironforge", "Green Dye: Bombus Finespindle, Ironforge" }, H = { "Green Dye: Tamar, Orgrimmar", "Green Dye: Tamar, Orgrimmar" } } },
  { from = 175, to = 180, crafts = 8, craft = "Solid Grinding Stone", mats = { {7912, 4, "Solid Stone"} },
    note = { "Keep 7 for Steel Plate Helm at 210", "Spara 7 till Steel Plate Helm vid 210" } },
  { from = 180, to = 195, crafts = 20, craft = "Golden Scale Bracers", mats = { {3859, 5, "Steel Bar"}, {3486, 2, "Heavy Grinding Stone"} },
    note = { "Make 20 more Heavy Grinding Stones (60 Heavy Stone). Steel Bar: smelt it yourself at Mining 165", "Gör 20 Heavy Grinding Stone till (60 Heavy Stone). Steel Bar: smält själv vid Mining 165" } },
  { from = 195, to = 210, crafts = 21, craft = "Heavy Mithril Gauntlet", mats = { {3860, 6, "Mithril Bar"}, {4338, 4, "Mageweave Cloth"} } },
  { from = 210, to = 215, crafts = 7, craft = "Steel Plate Helm", mats = { {3859, 14, "Steel Bar"}, {7966, 1, "Solid Grinding Stone"} } },
  { from = 215, to = 225, crafts = 10, craft = "Heavy Mithril Breastplate", mats = { {3860, 16, "Mithril Bar"} },
    note = { "Or Mithril Spurs if you have the plans (world drop)", "Eller Mithril Spurs om du har ritningen (world drop)" } },
  { from = 225, to = 230, crafts = 5, craft = "Dense Sharpening Stone", mats = { {12365, 1, "Dense Stone"} }, untested = true },
  { from = 230, to = 240, crafts = 16, craft = "Heavy Mithril Boots", mats = { {3860, 14, "Mithril Bar"}, {4304, 4, "Thick Leather"} }, untested = true },
  { from = 240, to = 245, crafts = 5, craft = "Imperial Plate Belt", mats = { {12359, 22, "Thorium Bar"}, {8170, 6, "Rugged Leather"}, {7909, 1, "Aquamarine"} }, untested = true,
    note = { "Plans from quests by Derotain Mudsipper, Tanaris (lowered to 240 in Forever)", "Ritningar från quests hos Derotain Mudsipper, Tanaris (sänkt till 240 i Forever)" } },
  { from = 245, to = 270, crafts = 27, craft = "Imperial Plate Bracers", mats = { {12359, 20, "Thorium Bar"}, {7910, 1, "Star Ruby"} }, untested = true },
  { from = 270, to = 290, crafts = 20, craft = "Imperial Plate Boots", mats = { {12359, 34, "Thorium Bar"}, {7910, 1, "Star Ruby"}, {7909, 1, "Aquamarine"} }, untested = true },
  { from = 290, to = 300, crafts = 10, craft = "Imperial Plate Leggings", mats = { {12359, 44, "Thorium Bar"}, {7910, 2, "Star Ruby"} }, untested = true },
}

ns.ROUTES.Leatherworking = {
  { from = 1, to = 30, crafts = 33, craft = "Light Leather", mats = { {2934, 3, "Ruined Leather Scraps"} },
    note = { "Bought Light Leather instead? Make Light Armor Kits to 30", "Köpte du Light Leather? Gör Light Armor Kit till 30" } },
  { from = 30, to = 45, crafts = 24, craft = "Light Armor Kit", mats = { {2318, 1, "Light Leather"} } },
  { from = 45, to = 75, crafts = 31, craft = "Embossed Leather Gloves", mats = { {2318, 3, "Light Leather"}, {2320, 2, "Coarse Thread"} } },
  { from = 75, to = 80, crafts = 8, craft = "Medium Leather", mats = { {2318, 4, "Light Leather"} } },
  { from = 80, to = 90, crafts = 10, craft = "Cured Medium Hide", mats = { {4232, 1, "Medium Hide"}, {4289, 1, "Salt"} },
    note = { "Keep the hides for Dark Leather Belt", "Spara hudarna till Dark Leather Belt" } },
  { from = 90, to = 100, crafts = 19, craft = "Fine Leather Belt", mats = { {2318, 6, "Light Leather"}, {2320, 2, "Coarse Thread"} },
    note = { "Keep 10 belts for Dark Leather Belt", "Spara 10 bälten till Dark Leather Belt" } },
  { from = 100, to = 115, crafts = 16, craft = "Dark Leather Cloak", mats = { {2319, 8, "Medium Leather"}, {2321, 1, "Fine Thread"}, {4340, 1, "Gray Dye"} } },
  { from = 115, to = 125, crafts = 10, craft = "Dark Leather Belt", mats = { {4246, 1, "Fine Leather Belt"}, {4233, 1, "Cured Medium Hide"}, {2321, 2, "Fine Thread"}, {4340, 1, "Gray Dye"} } },
  { from = 125, to = 130, crafts = 7, craft = "Heavy Leather", mats = { {2319, 5, "Medium Leather"} } },
  { from = 130, to = 155, crafts = 30, craft = "Hillman's Leather Gloves", mats = { {2319, 14, "Medium Leather"}, {2321, 4, "Fine Thread"} },
    note = { "Cheap Heavy Hide? Cure 20 hides (3 Salt each) and use the Cured Heavy Hide route instead", "Billig Heavy Hide? Bered 20 hudar (3 Salt var) och kör Cured Heavy Hide-vägen istället" } },
  { from = 155, to = 170, crafts = 17, craft = "Barbaric Leggings", mats = { {4234, 10, "Heavy Leather"}, {2321, 2, "Fine Thread"}, {1206, 1, "Moss Agate"} },
    note = { A = { "Pattern: Hammon Karwn (Arathi) or Lardan (Ashenvale)", "Mönster: Hammon Karwn (Arathi) eller Lardan (Ashenvale)" }, H = { "Pattern: Jandia (Thousand Needles) or Keena (Arathi)", "Mönster: Jandia (Thousand Needles) eller Keena (Arathi)" } } },
  { from = 170, to = 175, crafts = 5, craft = "Barbaric Harness", mats = { {4234, 14, "Heavy Leather"}, {2321, 2, "Fine Thread"}, {7071, 1, "Iron Buckle"} } },
  { from = 175, to = 195, crafts = 26, craft = "Guardian Gloves", mats = { {4234, 4, "Heavy Leather"}, {4236, 1, "Cured Heavy Hide"}, {4291, 1, "Silken Thread"} },
    note = { "Cured Heavy Hide: Heavy Hide + 3 Salt", "Cured Heavy Hide: Heavy Hide + 3 Salt" } },
  { from = 195, to = 210, crafts = 21, craft = "Nightscape Headband", mats = { {4304, 5, "Thick Leather"}, {4291, 2, "Silken Thread"} } },
  { from = 210, to = 225, crafts = 15, craft = "Nightscape Pants", mats = { {4304, 14, "Thick Leather"}, {4291, 4, "Silken Thread"} },
    note = { "Only the Artisan trainer teaches it (not Thunder Bluff or Darnassus)", "Bara Artisan-tränaren lär ut den (inte Thunder Bluff eller Darnassus)" } },
  { from = 225, to = 235, crafts = 12, craft = "Nightscape Boots", mats = { {4304, 16, "Thick Leather"}, {8343, 2, "Heavy Silken Thread"} }, untested = true },
  { from = 235, to = 265, crafts = 36, craft = "Wicked Leather Gauntlets", mats = { {8170, 8, "Rugged Leather"}, {2325, 1, "Black Dye"}, {14341, 1, "Rune Thread"} }, untested = true,
    note = { A = { "Pattern: Leonard Porter, Western Plaguelands", "Mönster: Leonard Porter, Western Plaguelands" }, H = { "Pattern: Werg Thickblade, Tirisfal Glades", "Mönster: Werg Thickblade, Tirisfal Glades" } } },
  { from = 265, to = 300, crafts = 53, craft = "Runic Leather Headband", mats = { {8170, 14, "Rugged Leather"}, {14047, 10, "Runecloth"}, {14341, 1, "Rune Thread"} }, untested = true,
    note = { "Pattern: Jase Farlane, Light's Hope Chapel", "Mönster: Jase Farlane, Light's Hope Chapel" } },
}

ns.ROUTES.Engineering = {
  { from = 1, to = 30, crafts = 60, craft = "Rough Blasting Powder", mats = { {2835, 1, "Rough Stone"} },
    note = { "Buy a Blacksmith Hammer first", "Köp en Blacksmith Hammer först" } },
  { from = 30, to = 50, crafts = 30, craft = "Handful of Copper Bolts", mats = { {2840, 1, "Copper Bar"} } },
  { from = 50, to = 51, crafts = 1, craft = "Arclight Spanner", mats = { {2840, 6, "Copper Bar"} } },
  { from = 51, to = 75, crafts = 30, craft = "Rough Copper Bomb", mats = { {2840, 1, "Copper Bar"}, {4359, 1, "Handful of Copper Bolts"}, {4357, 2, "Rough Blasting Powder"}, {2589, 1, "Linen Cloth"} },
    note = { "Learn Journeyman first: the bombs can carry you past 75", "Lär dig Journeyman först: bomberna kan ta dig förbi 75" } },
  { from = 75, to = 90, crafts = 60, craft = "Coarse Blasting Powder", mats = { {2836, 1, "Coarse Stone"} } },
  { from = 90, to = 100, crafts = 20, craft = "Coarse Dynamite", mats = { {4364, 3, "Coarse Blasting Powder"}, {2589, 1, "Linen Cloth"} } },
  { from = 100, to = 105, crafts = 5, craft = "Silver Contact", mats = { {2842, 1, "Silver Bar"} },
    note = { "Or Flying Tiger Goggles", "Eller Flying Tiger Goggles" } },
  { from = 105, to = 125, crafts = 25, craft = "Bronze Tube", mats = { {2841, 2, "Bronze Bar"}, {2880, 1, "Weak Flux"} } },
  { from = 125, to = 135, crafts = 10, craft = "Standard Scope", mats = { {4371, 1, "Bronze Tube"}, {1206, 1, "Moss Agate"} },
    note = { "No Moss Agate? Make Heavy Blasting Powder instead", "Ingen Moss Agate? Gör Heavy Blasting Powder istället" } },
  { from = 135, to = 150, crafts = 30, craft = "Heavy Blasting Powder", mats = { {2838, 1, "Heavy Stone"} },
    note = { "Also make 15 Whirring Bronze Gizmo: both go into Explosive Sheep", "Gör också 15 Whirring Bronze Gizmo: båda går till Explosive Sheep" } },
  { from = 150, to = 160, crafts = 15, craft = "Bronze Framework", mats = { {2841, 2, "Bronze Bar"}, {2319, 1, "Medium Leather"}, {2592, 1, "Wool Cloth"} } },
  { from = 160, to = 175, crafts = 15, craft = "Explosive Sheep", mats = { {4377, 2, "Heavy Blasting Powder"}, {4375, 1, "Whirring Bronze Gizmo"}, {4382, 1, "Bronze Framework"}, {2592, 2, "Wool Cloth"} } },
  { from = 175, to = 194, crafts = 60, craft = "Solid Blasting Powder", mats = { {7912, 2, "Solid Stone"} },
    note = { "Keep the powder for later steps", "Spara pudret till senare steg" } },
  { from = 194, to = 195, crafts = 1, craft = "Gyromatic Micro-Adjustor", mats = { {3859, 4, "Steel Bar"} } },
  { from = 195, to = 200, crafts = 6, craft = "Mithril Tube", mats = { {3860, 3, "Mithril Bar"} } },
  { from = 200, to = 215, crafts = 20, craft = "Unstable Trigger", mats = { {3860, 1, "Mithril Bar"}, {4338, 1, "Mageweave Cloth"}, {10505, 1, "Solid Blasting Powder"} },
    note = { "Gnomish or Goblin specialization opens at 200 (level 30)", "Gnomish eller Goblin-specialisering öppnar vid 200 (level 30)" } },
  { from = 215, to = 238, crafts = 40, craft = "Mithril Casing", mats = { {3860, 3, "Mithril Bar"} }, untested = true },
  { from = 238, to = 250, crafts = 20, craft = "Hi-Explosive Bomb", mats = { {10561, 2, "Mithril Casing"}, {10560, 1, "Unstable Trigger"}, {10505, 2, "Solid Blasting Powder"} }, untested = true },
  { from = 250, to = 260, crafts = 30, craft = "Dense Blasting Powder", mats = { {12365, 2, "Dense Stone"} }, untested = true },
  { from = 260, to = 285, crafts = 35, craft = "Thorium Widget", mats = { {12359, 3, "Thorium Bar"}, {14047, 1, "Runecloth"} }, untested = true,
    note = { A = { "Schematic: Gearcutter Cogspinner, Ironforge", "Ritning: Gearcutter Cogspinner, Ironforge" }, H = { "Schematic: Sovik, Orgrimmar", "Ritning: Sovik, Orgrimmar" } } },
  { from = 285, to = 300, crafts = 20, craft = "Thorium Tube", mats = { {12359, 6, "Thorium Bar"} }, untested = true,
    note = { "Schematic (BoP): Xizzer Fizzbolt, Everlook", "Ritning (BoP): Xizzer Fizzbolt, Everlook" } },
}

-- Disenchant-utfall per item level (Classic-tabeller; Forever kan avvika).
-- dust/ess = {itemID, min, max}; pd/pe/ps = chans för dust/essence/shard (armor).
-- Vapen byter chans mellan dust och essence. rare = shard från blå föremål.
ns.DE_BRACKETS = {
  { max = 15,  req = 1,   dust = {10940, 1, 2}, ess = {10938, 1, 2}, pd = 0.80, pe = 0.20, ps = 0,    rare = 10978 },
  { max = 20,  req = 1,   dust = {10940, 2, 3}, ess = {10939, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 10978, rare = 10978 },
  { max = 25,  req = 25,  dust = {10940, 4, 6}, ess = {10998, 1, 2}, pd = 0.75, pe = 0.15, ps = 0.10, shard = 10978, rare = 10978 },
  { max = 30,  req = 50,  dust = {11083, 1, 2}, ess = {11082, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 11084, rare = 11084 },
  { max = 35,  req = 75,  dust = {11083, 2, 5}, ess = {11134, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 11138, rare = 11138 },
  { max = 40,  req = 100, dust = {11137, 1, 2}, ess = {11135, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 11139, rare = 11139 },
  { max = 45,  req = 125, dust = {11137, 2, 5}, ess = {11174, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 11177, rare = 11177 },
  { max = 50,  req = 150, dust = {11176, 1, 2}, ess = {11175, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 11178, rare = 11178 },
  { max = 55,  req = 175, dust = {11176, 2, 5}, ess = {16202, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 14343, rare = 14343 },
  { max = 60,  req = 200, dust = {16204, 1, 2}, ess = {16203, 1, 2}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 14344, rare = 14344 },
  { max = 999, req = 225, dust = {16204, 2, 5}, ess = {16203, 2, 3}, pd = 0.75, pe = 0.20, ps = 0.05, shard = 14344, rare = 14344 },
}

-- Herbs: {itemID, name, Herbalism skill needed}. Classic values; Forever may differ a little.
ns.HERBS = {
  { 2447, "Peacebloom", 1 }, { 765, "Silverleaf", 1 }, { 2449, "Earthroot", 15 },
  { 785, "Mageroyal", 50 }, { 2450, "Briarthorn", 70 }, { 3820, "Stranglekelp", 85 },
  { 2453, "Bruiseweed", 100 }, { 3355, "Wild Steelbloom", 115 }, { 3356, "Kingsblood", 125 },
  { 3357, "Liferoot", 150 }, { 3818, "Fadeleaf", 160 }, { 3821, "Goldthorn", 170 },
  { 3358, "Khadgar's Whisker", 185 }, { 3819, "Wintersbite", 195 }, { 4625, "Firebloom", 205 },
  { 8831, "Purple Lotus", 210 }, { 8836, "Arthas' Tears", 220 }, { 8838, "Sungrass", 230 },
  { 8839, "Blindweed", 235 }, { 8845, "Ghost Mushroom", 245 }, { 8846, "Gromsblood", 250 },
  { 13464, "Golden Sansam", 260 }, { 13463, "Dreamfoil", 270 }, { 13465, "Mountain Silversage", 280 },
  { 13466, "Plaguebloom", 285 }, { 13467, "Icecap", 290 },
}

-- Where to pick herbs: up to this Herbalism skill (wow-professions, WoW Forever).
ns.HERB_ZONES = {
  { to = 70, zones = { A = "Elwynn Forest, Dun Morogh, Teldrassil, Zephras Isle", H = "Durotar, Mulgore, Tirisfal Glades, Zephras Isle" } },
  { to = 115, zones = { A = "Loch Modan, Darkshore", H = "Silverpine Forest" } },
  { to = 170, zones = "Hillsbrad Foothills, Stonetalon Mountains" },
  { to = 205, zones = "Stranglethorn Vale, Arathi Highlands" },
  { to = 230, zones = "Tanaris, Searing Gorge (no trainer there: learn Artisan first)" },
  { to = 270, zones = "The Hinterlands (Ghost Mushroom in caves from 245)" },
  { to = 300, zones = "Felwood" },
}

-- Ores: {itemID, name, Mining skill needed}. Classic values; Forever may differ a little.
ns.ORES = {
  { 2770, "Copper Ore", 1 }, { 2771, "Tin Ore", 65 }, { 2775, "Silver Ore", 75 },
  { 2772, "Iron Ore", 125 }, { 2776, "Gold Ore", 155 }, { 3858, "Mithril Ore", 175 },
  { 7911, "Truesilver Ore", 230 }, { 10620, "Thorium Ore", 245 },
}

-- Where to mine: up to this Mining skill (wow-professions, WoW Forever).
ns.MINING_ZONES = {
  { to = 65, zones = { A = "Elwynn Forest, Dun Morogh, Teldrassil, Zephras Isle", H = "Durotar, Mulgore, Tirisfal Glades, Zephras Isle" } },
  { to = 125, zones = { A = "Wetlands, Westfall, Ashenvale", H = "Silverpine Forest (cave), Hillsbrad Foothills, The Barrens, Stonetalon Mountains" } },
  { to = 175, zones = "Thousand Needles (around level 30), Arathi Highlands, Desolace" },
  { to = 245, zones = "The Hinterlands, Tanaris" },
  { to = 275, zones = "Un'Goro Crater, Blasted Lands, Felwood" },
  { to = 300, zones = "Un'Goro Crater, Eastern Plaguelands, Winterspring, Burning Steppes" },
}

-- Leather: {itemID, name, Skinning skill where it starts to drop}.
ns.LEATHER = {
  { 2934, "Ruined Leather Scraps", 1 }, { 2318, "Light Leather", 1 }, { 2319, "Medium Leather", 100 },
  { 4234, "Heavy Leather", 150 }, { 4304, "Thick Leather", 200 }, { 8170, "Rugged Leather", 250 },
}

-- Highest beast level you can skin with this skill (the Classic rule).
function ns.SkinLevel(skill)
  if skill < 100 then return math.floor(skill / 10) + 10 end
  return math.floor(skill / 5)
end

-- Where to skin: up to this Skinning skill (wow-professions, WoW Forever).
ns.SKIN_ZONES = {
  { to = 75, zones = "any starting zone" },
  { to = 125, zones = { A = "Loch Modan (boars, bears, crocolisks)", H = "The Barrens (raptors west of Northwatch Hold)" } },
  { to = 150, zones = { A = "Wetlands (raptors at Whelgar's Excavation Site)", H = "The Barrens (raptors west of Northwatch Hold)" } },
  { to = 225, zones = "Hillsbrad Foothills (yetis in Foothill Caverns) or Duskwood (Nightbane worgen at Roland's Doom)" },
  { to = 280, zones = "Feralas (yetis in Feral Scar Vale)" },
  { to = 300, zones = "Un'Goro Crater (diemetradons and pterrordax)" },
}

---------------------------------------------------------------------------
-- Secondary skills: Cooking, First Aid and Fishing. They don't use a profession slot,
-- so they show in the crafting assistant when you've learned them.
-- Routes follow wow-professions.com's WoW Forever guides; their 225-300 parts were written
-- during the beta and are marked untested.
---------------------------------------------------------------------------
ns.SECONDARY = { "Cooking", "First Aid", "Fishing" }

-- What you need for the next rank, by your current max skill (75 / 150 / 225).
ns.RANK_NOTES = {
  Cooking = {
    [75]  = { "Journeyman: any Cooking trainer (learn it before 75)", "Journeyman: vilken Cooking-tränare som helst (lär dig före 75)" },
    [150] = { A = { "Expert Cookbook: Shandrina, Mystral Lake (Ashenvale), needs 125", "Expert Cookbook: Shandrina, Mystral Lake (Ashenvale), kräver 125" },
              H = { "Expert Cookbook: Wulan, Shadowprey Village (Desolace), needs 125", "Expert Cookbook: Wulan, Shadowprey Village (Desolace), kräver 125" } },
    [225] = { A = { "Artisan: \"I Know A Guy...\" from Daryl Riknussun (Ironforge), lvl 35. Bring 12 Giant Egg, 10 Zesty Clam Meat, 20 Alterac Swiss to Dirge Quikcleave (Gadgetzan)", "Artisan: \"I Know A Guy...\" från Daryl Riknussun (Ironforge), lvl 35. Ta med 12 Giant Egg, 10 Zesty Clam Meat, 20 Alterac Swiss till Dirge Quikcleave (Gadgetzan)" },
              H = { "Artisan: \"To Gadgetzan You Go!\" from Zamja (Orgrimmar), lvl 35. Bring 12 Giant Egg, 10 Zesty Clam Meat, 20 Alterac Swiss to Dirge Quikcleave (Gadgetzan)", "Artisan: \"To Gadgetzan You Go!\" från Zamja (Orgrimmar), lvl 35. Ta med 12 Giant Egg, 10 Zesty Clam Meat, 20 Alterac Swiss till Dirge Quikcleave (Gadgetzan)" } },
  },
  ["First Aid"] = {
    [75]  = { "Journeyman: your First Aid trainer (needs 50)", "Journeyman: din First Aid-tränare (kräver 50)" },
    [150] = { A = { "Expert First Aid - Under Wraps: Deneb Walker, Arathi Highlands (needs 125). Buy both bandage manuals too", "Expert First Aid - Under Wraps: Deneb Walker, Arathi Highlands (kräver 125). Köp båda bandage-manualerna också" },
              H = { "Expert First Aid - Under Wraps: Balai Lok'Wein, Dustwallow Marsh (needs 125). Buy both bandage manuals too", "Expert First Aid - Under Wraps: Balai Lok'Wein, Dustwallow Marsh (kräver 125). Köp båda bandage-manualerna också" } },
    [225] = { A = { "Artisan: Triage quest, Doctor Gustaf VanHowzen, Theramore (lvl 35)", "Artisan: questen Triage, Doctor Gustaf VanHowzen, Theramore (lvl 35)" },
              H = { "Artisan: Triage quest, Doctor Gregory Victor, Hammerfall (Arathi), lvl 35", "Artisan: questen Triage, Doctor Gregory Victor, Hammerfall (Arathi), lvl 35" } },
  },
  Fishing = {
    [75]  = { "Journeyman: any Fishing trainer (lvl 10, needs 50)", "Journeyman: vilken Fishing-tränare som helst (lvl 10, kräver 50)" },
    [150] = { "Expert Fishing - The Bass and You: Old Man Heming, Booty Bay (lvl 20, needs 125)", "Expert Fishing - The Bass and You: Old Man Heming, Booty Bay (lvl 20, kräver 125)" },
    [225] = { "Artisan: Nat Pagle, Angler Extreme quest, Dustwallow Marsh (lvl 35)", "Artisan: questen Nat Pagle, Angler Extreme, Dustwallow Marsh (lvl 35)" },
  },
}

ns.ROUTES.Cooking = {
  { from = 1, to = 50, crafts = 55, craft = "Charred Wolf Meat", mats = { {2672, 1, "Stringy Wolf Meat"} },
    note = { A = { "Trainer recipe. Or Roasted Boar Meat / Herb Baked Egg (trainer), Brilliant Smallfish (Tharynn Bouden, Goldshire) or Kaldorei Spider Kabob (quest from Zarrin, Teldrassil)", "Tränar-recept. Eller Roasted Boar Meat / Herb Baked Egg (tränaren), Brilliant Smallfish (Tharynn Bouden, Goldshire) eller Kaldorei Spider Kabob (quest hos Zarrin, Teldrassil)" }, H = { "Trainer recipe. Or Roasted Boar Meat / Herb Baked Egg (trainer), Scorpid Surprise (Grimtak, Durotar), Crispy Bat Wing (Abigail Shiel, Brill) or Brilliant Smallfish (Harn Longcast, Mulgore)", "Tränar-recept. Eller Roasted Boar Meat / Herb Baked Egg (tränaren), Scorpid Surprise (Grimtak, Durotar), Crispy Bat Wing (Abigail Shiel, Brill) eller Brilliant Smallfish (Harn Longcast, Mulgore)" } } },
  { from = 50, to = 100, crafts = 55, craft = "Boiled Clams", mats = { {5503, 1, "Clam Meat"}, {159, 1, "Refreshing Spring Water"} },
    note = { A = { "Trainer recipe. Or Coyote Steak (trainer), Longjaw Mud Snapper (Tharynn Bouden / Tansy Puddlefizz, Ironforge)", "Tränar-recept. Eller Coyote Steak (tränaren), Longjaw Mud Snapper (Tharynn Bouden / Tansy Puddlefizz, Ironforge)" }, H = { "Trainer recipe. Or Coyote Steak (trainer), Rainbow Fin Albacore (Shankys, Orgrimmar), Strider Stew (Tari'qa, Barrens)", "Tränar-recept. Eller Coyote Steak (tränaren), Rainbow Fin Albacore (Shankys, Orgrimmar), Strider Stew (Tari'qa, Barrens)" } } },
  { from = 100, to = 130, crafts = 40, craft = "Crab Cake", mats = { {2674, 1, "Crawler Meat"}, {2678, 1, "Mild Spices"} },
    note = { A = { "Trainer recipe. Or Dry Pork Ribs (trainer), Bristle Whisker Catfish (Catherine Leland, Stormwind: buy 55 fish for 100-150)", "Tränar-recept. Eller Dry Pork Ribs (tränaren), Bristle Whisker Catfish (Catherine Leland, Stormwind: köp 55 fiskar till 100-150)" }, H = { "Trainer recipe. Or Dry Pork Ribs (trainer), Bristle Whisker Catfish (Ronald Burch, Undercity / Naal Mistrunner, Thunder Bluff: buy 55 fish for 100-150)", "Tränar-recept. Eller Dry Pork Ribs (tränaren), Bristle Whisker Catfish (Ronald Burch, Undercity / Naal Mistrunner, Thunder Bluff: köp 55 fiskar till 100-150)" } } },
  { from = 130, to = 150, crafts = 25, craft = "Goblin Deviled Clams", mats = { {5504, 1, "Tangy Clam Meat"}, {2692, 1, "Hot Spices"} },
    note = { A = { "Trainer recipe. Or Curiously Tasty Omelet (Kendor Kabonka, Stormwind)", "Tränar-recept. Eller Curiously Tasty Omelet (Kendor Kabonka, Stormwind)" }, H = { "Trainer recipe. Or Curiously Tasty Omelet (Keena, Arathi) / Hot Lion Chops (Zargh, Barrens)", "Tränar-recept. Eller Curiously Tasty Omelet (Keena, Arathi) / Hot Lion Chops (Zargh, Barrens)" } } },
  { from = 150, to = 175, crafts = 28, craft = "Curiously Tasty Omelet", mats = { {3685, 1, "Raptor Egg"}, {2692, 1, "Hot Spices"} },
    note = { A = { "Recipe: Kendor Kabonka, Stormwind. Turns yellow at 170, make a few extra", "Recept: Kendor Kabonka, Stormwind. Gult vid 170, gör några extra" }, H = { "Recipe: Keena, Arathi Highlands. Or Hot Lion Chops (Zargh, Barrens)", "Recept: Keena, Arathi Highlands. Eller Hot Lion Chops (Zargh, Barrens)" } } },
  { from = 175, to = 225, crafts = 55, craft = "Mithril Headed Trout", mats = { {8365, 1, "Raw Mithril Head Trout"} },
    note = { A = { "Recipe: Tansy Puddlefizz (Ironforge) / Stuart Fleming (Menethil Harbor). Or Roast Raptor (Hammon Karwn, Arathi)", "Recept: Tansy Puddlefizz (Ironforge) / Stuart Fleming (Menethil Harbor). Eller Roast Raptor (Hammon Karwn, Arathi)" }, H = { "Recipe: Shankys (Orgrimmar) / Lizbeth Cromwell (Undercity) / Wulan (Desolace). Or Roast Raptor (Keena, Arathi)", "Recept: Shankys (Orgrimmar) / Lizbeth Cromwell (Undercity) / Wulan (Desolace). Eller Roast Raptor (Keena, Arathi)" } } },
  { from = 225, to = 275, crafts = 65, craft = "Spotted Yellowtail", mats = { {4603, 1, "Raw Spotted Yellowtail"} }, untested = true,
    note = { "Recipe: Gikkix, Steamwheedle Port (Tanaris): buy all his recipes. Or Filet of Redgill, Monster Omelet, Tender Wolf Steak", "Recept: Gikkix, Steamwheedle Port (Tanaris): köp alla hans recept. Eller Filet of Redgill, Monster Omelet, Tender Wolf Steak" } },
  { from = 275, to = 300, crafts = 35, craft = "Nightfin Soup", mats = { {13759, 1, "Raw Nightfin Snapper"}, {159, 1, "Refreshing Spring Water"} }, untested = true,
    note = { "Recipe: Gikkix, Tanaris. Or Poached Sunscale Salmon (also Gikkix)", "Recept: Gikkix, Tanaris. Eller Poached Sunscale Salmon (också Gikkix)" } },
}

ns.ROUTES["First Aid"] = {
  { from = 1, to = 40, crafts = 50, craft = "Linen Bandage", mats = { {2589, 1, "Linen Cloth"} },
    note = { "Trainer recipe", "Tränar-recept" } },
  { from = 40, to = 75, crafts = 40, craft = "Heavy Linen Bandage", mats = { {2589, 2, "Linen Cloth"} },
    note = { "Or Minor Healing Potion 1-75 (Peacebloom, Mild Spices, Empty Vial): healing potions are First Aid in Forever", "Eller Minor Healing Potion 1-75 (Peacebloom, Mild Spices, Empty Vial): healing potions hör till First Aid i Forever" } },
  { from = 75, to = 80, crafts = 12, craft = "Heavy Linen Bandage", mats = { {2589, 2, "Linen Cloth"} } },
  { from = 80, to = 115, crafts = 50, craft = "Wool Bandage", mats = { {2592, 1, "Wool Cloth"} },
    note = { "Trainer recipe", "Tränar-recept" } },
  { from = 115, to = 150, crafts = 50, craft = "Heavy Wool Bandage", mats = { {2592, 2, "Wool Cloth"} },
    note = { "Trainer recipe. Learn Silk Bandage too before you leave", "Tränar-recept. Lär dig Silk Bandage också innan du går" } },
  { from = 150, to = 180, crafts = 42, craft = "Silk Bandage", mats = { {4306, 1, "Silk Cloth"} } },
  { from = 180, to = 210, crafts = 46, craft = "Heavy Silk Bandage", mats = { {4306, 2, "Silk Cloth"} },
    note = { A = { "Manual: Deneb Walker, Arathi Highlands", "Manual: Deneb Walker, Arathi Highlands" }, H = { "Manual: Balai Lok'Wein, Dustwallow Marsh", "Manual: Balai Lok'Wein, Dustwallow Marsh" } } },
  { from = 210, to = 225, crafts = 19, craft = "Mageweave Bandage", mats = { {4338, 1, "Mageweave Cloth"} },
    note = { A = { "Manual: Deneb Walker, Arathi Highlands", "Manual: Deneb Walker, Arathi Highlands" }, H = { "Manual: Balai Lok'Wein, Dustwallow Marsh", "Manual: Balai Lok'Wein, Dustwallow Marsh" } } },
  { from = 225, to = 240, crafts = 29, craft = "Mageweave Bandage", mats = { {4338, 1, "Mageweave Cloth"} }, untested = true },
  { from = 240, to = 260, crafts = 30, craft = "Heavy Mageweave Bandage", mats = { {4338, 2, "Mageweave Cloth"} }, untested = true,
    note = { A = { "Doctor Gustaf VanHowzen (Theramore) teaches it at 240", "Doctor Gustaf VanHowzen (Theramore) lär ut den vid 240" }, H = { "Doctor Gregory Victor (Hammerfall, Arathi) teaches it at 240", "Doctor Gregory Victor (Hammerfall, Arathi) lär ut den vid 240" } } },
  { from = 260, to = 275, crafts = 20, craft = "Runecloth Bandage", mats = { {14047, 1, "Runecloth"} }, untested = true,
    note = { "The doctor teaches it at 260", "Doktorn lär ut den vid 260" } },
  { from = 275, to = 300, crafts = 30, craft = "Major Healing Potion", mats = { {13464, 1, "Golden Sansam"}, {3713, 3, "Soothing Spices"}, {8925, 1, "Crystal Vial"} }, untested = true,
    note = { "Manual: Major Healing Potion drops from high-level mobs. Without it: Runecloth Bandage to 290, then Heavy Runecloth Bandage", "Manual: Major Healing Potion droppar från höglevel-mobs. Utan den: Runecloth Bandage till 290, sen Heavy Runecloth Bandage" } },
}

-- Where to fish: up to this Fishing skill (wow-professions, WoW Forever).
ns.FISH_ZONES = {
  { to = 75, zones = { A = "any starting zone: Elwynn Forest, Dun Morogh, Teldrassil, Zephras Isle", H = "any starting zone: Durotar, Mulgore, Tirisfal Glades, Zephras Isle" } },
  { to = 150, zones = { A = "Stormwind, Ironforge, Darnassus, Darkshore, Loch Modan, Westfall", H = "Orgrimmar, Undercity, Thunder Bluff, The Barrens, Silverpine Forest" } },
  { to = 225, zones = "Dustwallow Marsh (best), Arathi Highlands, Stranglethorn Vale, Desolace, Swamp of Sorrows, Thousand Needles" },
  { to = 300, zones = "Feralas, Tanaris, The Hinterlands, Un'Goro Crater, Felwood, Western Plaguelands" },
}

-- Fishing gear by skill: up to this skill, what to use and where to buy it.
ns.FISH_GEAR = {
  { to = 50,  text = { A = { "Fishing Pole + Shiny Bauble: Tharynn Bouden (Goldshire), Catherine Leland (Stormwind), Tansy Puddlefizz (Ironforge)", "Fishing Pole + Shiny Bauble: Tharynn Bouden (Goldshire), Catherine Leland (Stormwind), Tansy Puddlefizz (Ironforge)" },
                       H = { "Fishing Pole + Shiny Bauble: Shankys (Orgrimmar), Lizbeth Cromwell (Undercity), Sewa Mistrunner (Thunder Bluff), Zansoa (Durotar)", "Fishing Pole + Shiny Bauble: Shankys (Orgrimmar), Lizbeth Cromwell (Undercity), Sewa Mistrunner (Thunder Bluff), Zansoa (Durotar)" } } },
  { to = 150, text = { "Nightcrawlers if fish get away (fishing supply vendors)", "Nightcrawlers om fiskarna smiter (fiskeförsäljare)" } },
  { to = 300, text = { "Bright Baubles: Old Man Heming, Booty Bay", "Bright Baubles: Old Man Heming, Booty Bay" } },
}
