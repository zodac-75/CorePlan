-- @ADDON@: spell ranks taught by the class trainer, from the WoW Forever client data
-- (build 1.60.1.70790). name = { {level, rank}, ... }
local _, ns = ...

ns.RANK_TABLE = {
  ["Blessing of Might"] = { {4,1}, {12,2}, {22,3}, {32,4}, {42,5}, {52,6}, {60,7} },
  ["Blessing of Protection"] = { {10,1}, {24,2}, {38,3} },
  ["Blessing of Sacrifice"] = { {46,1}, {54,2} },
  ["Blessing of Wisdom"] = { {14,1}, {24,2}, {34,3}, {44,4}, {54,5}, {60,6} },
  ["Consecration"] = { {20,1}, {30,2}, {40,3}, {50,4}, {60,5} },
  ["Devotion Aura"] = { {10,2}, {20,3}, {30,4}, {40,5}, {50,6}, {60,7} },
  ["Divine Protection"] = { {6,1}, {18,2} },
  ["Divine Shield"] = { {34,1}, {50,2} },
  ["Exorcism"] = { {20,1}, {28,2}, {36,3}, {44,4}, {52,5}, {60,6} },
  ["Fire Resistance Aura"] = { {36,1}, {48,2}, {60,3} },
  ["Flash of Light"] = { {20,1}, {26,2}, {34,3}, {42,4}, {50,5}, {58,6} },
  ["Frost Resistance Aura"] = { {32,1}, {44,2}, {56,3} },
  ["Greater Blessing of Might"] = { {52,1}, {60,2} },
  ["Greater Blessing of Wisdom"] = { {54,1}, {60,2} },
  ["Hammer of Justice"] = { {8,1}, {24,2}, {40,3}, {54,4} },
  ["Hammer of Wrath"] = { {44,1}, {52,2}, {60,3} },
  ["Holy Light"] = { {6,2}, {14,3}, {22,4}, {38,6}, {46,7}, {54,8}, {60,9} },
  ["Holy Strike"] = { {6,1}, {12,2}, {20,3}, {28,4}, {36,5}, {44,6}, {52,7}, {60,8} },
  ["Holy Wrath"] = { {50,1}, {60,2} },
  ["Lay on Hands"] = { {10,1}, {30,2}, {50,3} },
  ["Light's Vigil"] = { {40,1}, {50,2}, {60,3} },
  ["Retribution Aura"] = { {16,1}, {26,2}, {36,3}, {46,4}, {56,5} },
  ["Seal of Fury"] = { {10,1}, {18,2}, {26,3}, {34,4}, {42,5}, {50,6}, {58,7} },
  ["Seal of Light"] = { {30,1}, {40,2}, {50,3}, {60,4} },
  ["Seal of Righteousness"] = { {10,2}, {18,3}, {26,4}, {34,5}, {42,6}, {50,7}, {58,8} },
  ["Seal of Wisdom"] = { {38,1}, {48,2}, {58,3} },
  ["Seal of the Crusader"] = { {6,1}, {12,2}, {22,3}, {32,4}, {42,5}, {52,6} },
  ["Shadow Resistance Aura"] = { {28,1}, {40,2}, {52,3} },
}
