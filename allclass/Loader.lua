-- AllClassPlan: one install for every class. This small addon is always loaded; it loads the
-- part for your character's class (AllClassPlan_Mage, AllClassPlan_Paladin, ...), which are
-- the class addons built under the AllClassPlan name and marked load-on-demand.
--
-- The stand-alone addons (MagePlan, ...) are OptionalDeps in the .toc, so they load first:
--  * a version that knows about AllClassPlan steps aside on its own (sets MagePlanRetired),
--    and its saved settings are loaded, so the part copies them the first time;
--  * an older version runs as before, and AllClassPlan stays out of the way on this
--    character (and says to update or remove it), so nothing shows up twice.
--
-- Every class's command works on every character: /mp, /pal, ... all go to the loaded part,
-- same as /acp.
--
-- The language and layout profiles (AllClassPlanGlobal) are saved here, so they are shared by
-- all your characters; each class part saves its own per-character settings (AllClassPlanDB).
local ADDON = ...

-- class token -> { part suffix, stand-alone addon, class color, slash } (tools/buildall.py)
local CLASSES = {
--@CLASSES@
}

local isLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
local loadAddOn = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn

local message -- shown at login, when the chat window is ready

local function Say(text)
  local chat = DEFAULT_CHAT_FRAME
  if chat then chat:AddMessage("|cffffd100" .. ADDON .. ":|r " .. text) end
end

-- A stand-alone addon that still runs as itself (an older version without the step-aside).
local function Running(standalone)
  return isLoaded and isLoaded(standalone) and not rawget(_G, standalone .. "Retired")
end

local function Start()
  AllClassPlanGlobal = AllClassPlanGlobal or {}
  local swedish = AllClassPlanGlobal.lang == "svSE"
  local _, class = UnitClass("player")
  local info = class and CLASSES[class]
  if not info then
    message = swedish and "din klass finns inte med än." or "your class isn't supported yet."
    return
  end
  if Running(info.standalone) then
    message = string.format(swedish
      and "en äldre %s är installerad och körs här, så AllClassPlan håller sig undan. Uppdatera %s (eller ta bort den) så tar AllClassPlan över med dina inställningar."
      or "an older %s is installed and runs on this character, so AllClassPlan stays out of the way. Update %s (or remove it) and AllClassPlan takes over with your settings.",
      "|cff" .. info.color .. info.standalone .. "|r", info.standalone)
    return "standalone"
  end
  local part = ADDON .. "_" .. info.suffix
  local ok, reason = loadAddOn(part)
  if not ok then
    message = string.format(swedish and "kunde inte ladda %s (%s). Kolla att den är påslagen i addon-listan."
      or "couldn't load %s (%s). Check that it is turned on in the addon list.", part, tostring(reason))
    return "failed"
  end
  return "loaded"
end

-- /mp, /pal, ... on any character go to the loaded part (unless that class's own stand-alone
-- addon still runs and owns its command).
local function ForwardSlashes(own)
  for token, info in pairs(CLASSES) do
    if token ~= own and info.slash and not Running(info.standalone) then
      local key = "ALLCLASSPLAN_" .. token
      _G["SLASH_" .. key .. "1"] = "/" .. info.slash
      SlashCmdList[key] = function(msg)
        local main = SlashCmdList.ALLCLASSPLAN
        if main then main(msg) end
      end
    end
  end
end

local state
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, name)
  if event == "ADDON_LOADED" and name == ADDON then
    self:UnregisterEvent("ADDON_LOADED")
    -- Load the class part now, before PLAYER_LOGIN, so it starts up like a normal addon.
    state = Start()
  elseif event == "PLAYER_LOGIN" then
    if message then Say(message) end
    if state == "loaded" then
      local _, class = UnitClass("player")
      ForwardSlashes(class)
    else
      -- Without a class part loaded, /acp still answers.
      SLASH_ALLCLASSPLANLOADER1 = "/acp"
      SlashCmdList.ALLCLASSPLANLOADER = function() Say(message or "") end
    end
  end
end)

AllClassPlanLoader = { Start = Start, State = function() return state end }
