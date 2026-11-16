-- Run from the repo root: texlua tests/upgradelines.lua
-- Feeds known tooltip wordings through every class's ns.STATS.patterns and checks which stat they
-- land on (nil = ignored on purpose). A new wording that scores 0 shows up as a false "downgrade".
local expect = {
  -- line, then per class: key (or false = must be ignored)
  { "Equip: Increases damage and healing done by magical spells and effects by up to 12.",
    mage="sp", shaman="sp", druid="sp", paladin="sp", warlock="sp", priest="sp" },
  { "Equip: Increases healing done by spells and effects by up to 20.", shaman="heal", druid="heal", paladin="heal", priest="heal", mage=false, warlock=false },
  { "Equip: Increases damage done by Frost spells and effects by up to 9.", mage="frost", shaman="school" },
  { "Equip: Increases damage done by Nature spells and effects by up to 9.", shaman="school", druid="school", mage=false },
  { "Equip: Increases damage done by Shadow spells and effects by up to 9.", priest="shadow", warlock="shadow", mage=false },
  { "Equip: Increases ranged attack power by 14.", shaman="rap", druid="rap", warrior="rap", paladin="rap", hunter="rap", rogue="rap" },
  { "Equip: Increases attack power by 20.", shaman="ap", druid="ap", warrior="ap", paladin="ap", hunter="ap", rogue="ap", mage=false, priest=false },
  { "Equip: Restores 4 mana per 5 sec.", mage="mp5", shaman="mp5", druid="mp5", paladin="mp5", warlock="mp5", priest="mp5", hunter="mp5" },
  { "+4 Mana per 5 sec", mage="mp5", priest="mp5" },
  { "+5 Nature Spell Damage", shaman="school", druid="school" },
  { "Equip: Increases the attack power of your pet by 20.", mage=false, hunter=false, warlock=false },
}
local classes = { "mage", "shaman", "druid", "warrior", "paladin", "warlock", "priest", "hunter", "rogue" }
local bad = 0
for _, c in ipairs(classes) do
  local f = assert(io.open("classes/" .. c .. "/Data.lua")):read("a")
  local pats = assert(load("return " .. f:match("ns%.STATS%.patterns = (%b{})")))()
  for _, e in ipairs(expect) do
    if e[c] ~= nil then
      local got = false
      for _, p in ipairs(pats) do if e[1]:match(p[1]) then got = p[2]; break end end
      if got ~= e[c] then bad = bad + 1; print("FEL", c, tostring(got), "väntade", tostring(e[c]), e[1]) end
    end
  end
end
print("--- FEL (" .. bad .. ") ---")
os.exit(bad == 0 and 0 or 1)
