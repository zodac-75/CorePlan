-- @ADDON@: quest reward picker. When a quest lets you choose, it marks the biggest
-- upgrade with a green "+" and the reward that sells for the most with a gold "$",
-- on Blizzard's quest window and in the item tooltip (for quest dialog addons).
local _, ns = ...

local marks = {}

local function RewardButton(i)
  if QuestInfoRewardsFrame and QuestInfoRewardsFrame.RewardButtons and QuestInfoRewardsFrame.RewardButtons[i] then
    return QuestInfoRewardsFrame.RewardButtons[i]
  end
  return _G["QuestInfoRewardsFrameQuestInfoItem" .. i] or _G["QuestInfoItem" .. i] or _G["QuestRewardItem" .. i]
end

local function ClearMarks()
  for _, m in ipairs(marks) do m:Hide() end
  marks = {}
end

-- Badges on a reward button: a green "+" for the best upgrade, a gold "$" for the
-- reward that sells for the most. One item can get both.
local function Badge(btn, key, symbol, color, text, corner)
  btn.@ADDON@Badges = btn.@ADDON@Badges or {}
  local m = btn.@ADDON@Badges[key]
  if not m then
    m = CreateFrame("Frame", nil, btn)
    m:SetAllPoints(btn)
    m.glow = m:CreateTexture(nil, "OVERLAY")
    m.glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    m.glow:SetBlendMode("ADD")
    m.glow:SetAllPoints(m)
    m.symbol = m:CreateFontString(nil, "OVERLAY")
    m.symbol:SetFont(STANDARD_TEXT_FONT, 22, "THICKOUTLINE")
    m.label = m:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.@ADDON@Badges[key] = m
  end
  m.glow:SetVertexColor(color[1], color[2], color[3])
  m.glow:SetShown(key == "up")
  m.symbol:SetText(symbol)
  m.symbol:SetTextColor(color[1], color[2], color[3])
  m.symbol:ClearAllPoints()
  m.label:ClearAllPoints()
  if corner == "left" then
    m.symbol:SetPoint("TOPLEFT", m, "TOPLEFT", -6, 8)
    m.label:SetPoint("BOTTOMRIGHT", m, "BOTTOMRIGHT", -4, 3)
  else
    m.symbol:SetPoint("TOPRIGHT", m, "TOPRIGHT", 4, 8)
    m.label:SetPoint("TOPRIGHT", m, "TOPRIGHT", -18, -4)
  end
  m.label:SetText(text or "")
  m:SetFrameLevel(btn:GetFrameLevel() + 3)
  m:Show()
  table.insert(marks, m)
end

local GREEN, GOLD = { 0.3, 1, 0.3 }, { 1, 0.82, 0.1 }
local best = {} -- what the tooltips say: best.up / best.cash = choice index

local function Evaluate(isRetry)
  ClearMarks()
  best = {}
  if ns.db.questOff or not GetNumQuestChoices or not GetQuestItemLink then return end
  local n = GetNumQuestChoices() or 0
  if n < 2 then return end

  local bestUp, bestUpI, bestVal, bestValI, missing = 0.5, nil, 0, nil, false
  for i = 1, n do
    local link = GetQuestItemLink("choice", i)
    if link then
      local diff, needLevel = ns.CompareToEquipped(link)
      -- Skip rewards you can't wear yet (e.g. plate before you learn it).
      if diff and diff > bestUp and (needLevel or 0) <= (UnitLevel("player") or 1) then
        bestUp, bestUpI = diff, i
      end
      local ok, name, _, _, _, _, _, _, _, _, _, sell = pcall(ns.ItemInfo, link)
      if not (ok and name) then missing = true end
      local count = GetQuestItemInfo and select(3, GetQuestItemInfo("choice", i)) or 1
      local value = (sell or 0) * (tonumber(count) or 1)
      if value > bestVal then bestVal, bestValI = value, i end
    else
      missing = true
    end
  end
  -- Item data may not be loaded on first view; try once more shortly after.
  if missing and not isRetry then
    C_Timer.After(0.5, function() pcall(Evaluate, true) end)
    return
  end

  if bestUpI then
    best.up, best.upText = bestUpI, ns.T("QR_UPGRADE_SHORT", math.floor(bestUp + 0.5))
    best.upID = tonumber((GetQuestItemLink("choice", bestUpI) or ""):match("item:(%d+)"))
    local btn = RewardButton(bestUpI)
    if btn then pcall(Badge, btn, "up", "+", GREEN, best.upText, "left") end
    ns.Print(ns.T("QR_UPGRADE", GetQuestItemLink("choice", bestUpI) or "?", math.floor(bestUp + 0.5)))
  end
  if bestValI then
    best.cash, best.cashText = bestValI, ns.Money(bestVal)
    best.cashID = tonumber((GetQuestItemLink("choice", bestValI) or ""):match("item:(%d+)"))
    local btn = RewardButton(bestValI)
    if btn then pcall(Badge, btn, "cash", "$", GOLD, nil, "right") end
    ns.Print((bestUpI and ns.T("QR_CASH", GetQuestItemLink("choice", bestValI) or "?", best.cashText))
      or ns.T("QR_VENDOR", GetQuestItemLink("choice", bestValI) or "?", best.cashText))
  end
end

-- Quest dialog addons (DialogueUI, Immersion, ...) draw their own reward buttons, but
-- they show the normal item tooltip: there we add the same "+" and "$" lines.
local function OnQuestTooltip(tt, kind, index)
  if ns.db.questOff or kind ~= "choice" or not index then return end
  local added = false
  if best.up == index then
    tt:AddLine("|cff4dff4d+ " .. ns.T("QR_TIP_UP", best.upText) .. "|r")
    added = true
  end
  if best.cash == index then
    tt:AddLine("|cffffd11a$ " .. ns.T("QR_TIP_CASH", best.cashText) .. "|r")
    added = true
  end
  if added then tt:Show() end
end

-- DialogueUI has its own tooltip; it lets other addons add lines through its API.
local duiHooked = false
local function HookDialogueUI()
  if duiHooked or not (DialogueUIAPI and DialogueUIAPI.AddItemTooltipProcessorExternal) then return end
  duiHooked = true
  DialogueUIAPI.AddItemTooltipProcessorExternal(function(tooltip, itemID)
    if ns.db.questOff or not itemID then return false end
    local added = false
    if best.upID and itemID == best.upID then
      tooltip:AddLine("+ " .. ns.T("QR_TIP_UP", best.upText), 0.3, 1, 0.3)
      added = true
    end
    if best.cashID and itemID == best.cashID then
      tooltip:AddLine("$ " .. ns.T("QR_TIP_CASH", best.cashText), 1, 0.82, 0.1)
      added = true
    end
    return added
  end)
end

ns.RegisterModule(function()
  pcall(HookDialogueUI)
  local addonEv = CreateFrame("Frame")
  addonEv:RegisterEvent("ADDON_LOADED")
  addonEv:SetScript("OnEvent", function(_, _, name)
    if name == "DialogueUI" then pcall(HookDialogueUI) end
  end)
  if GameTooltip and GameTooltip.SetQuestItem then
    hooksecurefunc(GameTooltip, "SetQuestItem", function(tt, kind, index) pcall(OnQuestTooltip, tt, kind, index) end)
  end
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("QUEST_COMPLETE")
  ev:RegisterEvent("QUEST_DETAIL")
  ev:RegisterEvent("QUEST_FINISHED")
  ev:SetScript("OnEvent", function(_, event)
    if event == "QUEST_FINISHED" then
      ClearMarks()
      best = {}
    else
      C_Timer.After(0.1, function()
        local ok, err = pcall(Evaluate, false)
        if not ok then ns.Print(ns.T("ERROR_IN", "QuestReward", tostring(err))) end
      end)
    end
  end)
end)

ns.RegisterCommand("quest", true, function()
  ns.db.questOff = not ns.db.questOff
  ns.Print(ns.db.questOff and ns.T("QR_OFF") or ns.T("QR_ON"))
end)
