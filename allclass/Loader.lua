-- AllClassPlan: one install for every class. This small addon is always loaded; it loads the
-- part for your character's class (AllClassPlan_Mage, AllClassPlan_Paladin, ...), which are
-- the class addons built under the AllClassPlan name and marked load-on-demand.
--
-- If the stand-alone addon for your class (MagePlan, ...) is installed and turned on, that one
-- runs and AllClassPlan stays out of the way on this character, so nothing shows up twice.
-- The stand-alone addons are OptionalDeps in the .toc, so they are loaded before this check.
--
-- The language and layout profiles (AllClassPlanGlobal) are saved here, so they are shared by
-- all your characters; each class part saves its own per-character settings (AllClassPlanDB).
local ADDON = ...

-- class token -> { part suffix, stand-alone addon, class color } (filled by tools/buildall.py)
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

local function Start()
  AllClassPlanGlobal = AllClassPlanGlobal or {}
  local swedish = AllClassPlanGlobal.lang == "svSE"
  local _, class = UnitClass("player")
  local info = class and CLASSES[class]
  if not info then
    message = swedish and "din klass finns inte med än." or "your class isn't supported yet."
    return
  end
  if isLoaded and isLoaded(info.standalone) then
    message = string.format(swedish and "%s är installerat, så %s kör det här och AllClassPlan håller sig undan."
      or "%s is installed, so it runs on this character and AllClassPlan stays out of the way.",
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
    -- Without a class part loaded, /acp still answers.
    if state ~= "loaded" then
      SLASH_ALLCLASSPLANLOADER1 = "/acp"
      SlashCmdList.ALLCLASSPLANLOADER = function() Say(message or "") end
    end
  end
end)

AllClassPlanLoader = { Start = Start, State = function() return state end }
