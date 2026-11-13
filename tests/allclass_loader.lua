-- Tests the AllClassPlan loader (allclass/Loader.lua): which class part it loads, and that it
-- steps aside when the stand-alone class addon is installed.
--   texlua tests/allclass_loader.lua <out>/AllClassPlan
local DIR = arg[1]
local errors = {}
local function check(cond, msg) if not cond then table.insert(errors, msg) end end

local function run(class, installed, loadResult, lang, retired)
  local frames, said, loaded = {}, {}, {}
  for _, n in ipairs({ "MagePlan", "PaladinPlan" }) do _G[n .. "Retired"] = retired and retired[n] or nil end
  _G.AllClassPlanGlobal = lang and { lang = lang } or nil
  _G.AllClassPlanLoader = nil
  _G.SlashCmdList = {}
  _G.SLASH_ALLCLASSPLANLOADER1 = nil
  _G.DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) said[#said + 1] = m end }
  _G.UnitClass = function() return class and class:sub(1, 1) .. class:sub(2):lower(), class end
  _G.C_AddOns = {
    IsAddOnLoaded = function(n) return installed[n] == true end,
    LoadAddOn = function(n) loaded[#loaded + 1] = n; if loadResult then return false, loadResult end return true end,
  }
  _G.CreateFrame = function()
    local f = { events = {} }
    function f:RegisterEvent(e) self.events[e] = true end
    function f:UnregisterEvent(e) self.events[e] = nil end
    function f:SetScript(_, fn) self.onEvent = fn end
    frames[#frames + 1] = f
    return f
  end
  local chunk = assert(loadfile(DIR .. "/Loader.lua"))
  chunk("AllClassPlan", {})
  local function fire(e, ...)
    for _, f in ipairs(frames) do if f.events[e] and f.onEvent then f.onEvent(f, e, ...) end end
  end
  fire("ADDON_LOADED", "Auctionator")
  fire("ADDON_LOADED", "AllClassPlan")
  fire("ADDON_LOADED", "AllClassPlan") -- only once
  fire("PLAYER_LOGIN")
  return loaded, said
end

print("--- AllClassPlan-laddaren ---")
do
  local loaded, said = run("MAGE", {})
  check(#loaded == 1 and loaded[1] == "AllClassPlan_Mage", "mage: laddade " .. table.concat(loaded, ","))
  check(#said == 0, "mage: sa något fast allt gick bra: " .. table.concat(said, " | "))
  check(type(AllClassPlanGlobal) == "table", "AllClassPlanGlobal skapades inte")
  check(SlashCmdList.ALLCLASSPLANLOADER == nil, "laddarens /acp registrerades fast delen laddades")
end
do
  local loaded = run("PALADIN", {})
  check(loaded[1] == "AllClassPlan_Paladin", "paladin: laddade " .. tostring(loaded[1]))
end
do
  local loaded, said = run("MAGE", { MagePlan = true })
  check(#loaded == 0, "MagePlan installerat men delen laddades ändå")
  check(said[1] and said[1]:find("MagePlan", 1, true), "inget besked om MagePlan: " .. tostring(said[1]))
  check(SlashCmdList.ALLCLASSPLANLOADER ~= nil and SLASH_ALLCLASSPLANLOADER1 == "/acp", "/acp svarar inte när delen inte laddades")
  print("  " .. tostring(said[1]))
end
do
  -- A stand-alone version that steps aside on its own: AllClassPlan takes over.
  local loaded, said = run("MAGE", { MagePlan = true }, nil, nil, { MagePlan = true })
  check(loaded[1] == "AllClassPlan_Mage", "MagePlan som kliver åt sidan: delen laddades inte")
  check(#said == 0, "MagePlan som kliver åt sidan: sa något: " .. table.concat(said, " | "))
end
do
  -- Every class's command goes to the loaded part; an older stand-alone keeps its own.
  local got
  run("MAGE", { PaladinPlan = true })
  SlashCmdList.ALLCLASSPLAN = function(msg) got = msg end
  local pal, rp, mp
  for k, fn in pairs(SlashCmdList) do
    local s1 = _G["SLASH_" .. k .. "1"]
    if s1 == "/pal" then pal = fn elseif s1 == "/rp" then rp = fn elseif s1 == "/mp" then mp = fn end
  end
  check(pal == nil, "/pal togs över fast PaladinPlan (äldre) körs")
  check(mp == nil, "/mp registrerades av laddaren (delen äger den)")
  check(rp ~= nil, "/rp går inte till AllClassPlan")
  if rp then rp("egg dance") end
  check(got == "egg dance", "/rp egg dance kom inte fram: " .. tostring(got))
end
do
  -- Another class's stand-alone addon doesn't stop it.
  local loaded = run("ROGUE", { MagePlan = true })
  check(loaded[1] == "AllClassPlan_Rogue", "rogue med MagePlan installerat: laddade " .. tostring(loaded[1]))
end
do
  local loaded, said = run("WARLOCK", {}, "DISABLED", "svSE")
  check(loaded[1] == "AllClassPlan_Warlock", "warlock: försökte inte ladda")
  check(said[1] and said[1]:find("DISABLED", 1, true) and said[1]:find("kunde inte", 1, true), "inget svenskt felbesked: " .. tostring(said[1]))
  print("  " .. tostring(said[1]))
end
do
  local loaded, said = run("DEATHKNIGHT", {})
  check(#loaded == 0, "okänd klass laddade något")
  check(said[1] ~= nil, "okänd klass: inget besked")
end

print("--- FEL (" .. #errors .. ") ---")
for _, e in ipairs(errors) do print(e) end
