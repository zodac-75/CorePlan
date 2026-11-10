-- @ADDON@: draws a window as rows instead of one block of text. Used by the plan window
-- and the crafting assistant.
--
--   local render = ns.RowRenderer(frame)
--   render({ entries })
--
-- Entries:
--   { head = "text", click = fn }                 a heading (clickable when click is set)
--   { gap = 4 }                                   extra space
--   { text = "...", icon = tex, indent = 10,      a row; all fields but text are optional
--     spells = { "Name", ... },                   known spells become icons with tooltips
--     items = { { id = 2589, have = 3, need = 10 } or { id = 2589, count = 7 } },
--     bar = { value = 120, max = 150 },           a progress bar under the text
--     click = fn, tip = "..." }                    click and hover help
local _, ns = ...

local ROW_ICON, SMALL_ICON = 16, 18

function ns.SpellIcon(name)
  local tex
  if C_Spell and C_Spell.GetSpellTexture then
    local ok, t = pcall(C_Spell.GetSpellTexture, name)
    if ok then tex = t end
  end
  if not tex and GetSpellTexture then
    local ok, t = pcall(GetSpellTexture, name)
    if ok then tex = t end
  end
  if issecretvalue and issecretvalue(tex) then return nil end
  return tex
end

function ns.ItemIcon(id)
  local tex
  if C_Item and C_Item.GetItemIconByID then
    local ok, t = pcall(C_Item.GetItemIconByID, id)
    if ok then tex = t end
  end
  if not tex and GetItemIcon then
    local ok, t = pcall(GetItemIcon, id)
    if ok then tex = t end
  end
  return tex
end

local function ShowTip(owner, fill)
  if not GameTooltip then return end
  GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
  pcall(fill, GameTooltip)
  GameTooltip:Show()
end

local function HideTip() if GameTooltip then GameTooltip:Hide() end end

function ns.RowRenderer(frame)
  local rowPool, iconPool, headPool = {}, {}, {}

  local function GetRow(i)
    local r = rowPool[i]
    if r then return r end
    r = CreateFrame("Button", nil, frame)
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r.hl = r:CreateTexture(nil, "HIGHLIGHT")
    r.hl:SetAllPoints()
    r.hl:SetColorTexture(1, 1, 1, 0.08)
    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetSize(ROW_ICON, ROW_ICON)
    r.icon:SetPoint("TOPLEFT", 0, -1)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.text = r:CreateFontString(nil, "OVERLAY")
    r.text:SetPoint("TOPLEFT", ROW_ICON + 6, -2)
    r.text:SetJustifyH("LEFT")
    r.text:SetJustifyV("TOP")
    -- Progress bar: a dark track with a colored fill.
    r.barBg = r:CreateTexture(nil, "BACKGROUND")
    r.barBg:SetColorTexture(0, 0, 0, 0.45)
    r.bar = r:CreateTexture(nil, "ARTWORK")
    r:SetScript("OnClick", function(self, button)
      local item = self.item
      if not item then return end
      if button == "RightButton" then
        if item.rclick then item.rclick() end -- right-click only does something when a row asks for it
      elseif item.click then
        item.click()
      end
    end)
    r:SetScript("OnEnter", function(self)
      local tip, list = self.item and self.item.tip, self.fullList
      if tip or list then
        ShowTip(self, function(tt)
          tt:SetText(list or tip, 1, 1, 1, 1, true)
          if list and tip then tt:AddLine(tip, 0.6, 0.8, 1, true) end
        end)
      end
    end)
    r:SetScript("OnLeave", HideTip)
    rowPool[i] = r
    return r
  end

  local function GetIcon(i)
    local b = iconPool[i]
    if b then return b end
    b = CreateFrame("Button", nil, frame)
    b:SetSize(SMALL_ICON, SMALL_ICON)
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetAllPoints()
    b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    b.count:SetPoint("BOTTOMRIGHT", 2, -1)
    b:SetScript("OnEnter", function(self)
      ShowTip(self, function(tt)
        if self.itemId and tt.SetItemByID then
          tt:SetItemByID(self.itemId)
        elseif self.spell then
          local _, id = ns.SpellInfo(self.spell)
          if id and tt.SetSpellByID then tt:SetSpellByID(id) else tt:SetText(self.spell) end
        end
        if self.extra then tt:AddLine(self.extra, 1, 1, 1) end
      end)
    end)
    b:SetScript("OnLeave", HideTip)
    b:SetScript("OnClick", function(self) if self.click then self.click() end end)
    iconPool[i] = b
    return b
  end

  local function GetHead(i)
    local h = headPool[i]
    if h then return h end
    h = CreateFrame("Button", nil, frame)
    h.text = h:CreateFontString(nil, "OVERLAY")
    h.text:SetPoint("LEFT", 0, 0)
    h.text:SetJustifyH("LEFT")
    h:SetScript("OnClick", function(self) if self.click then self.click() end end)
    headPool[i] = h
    return h
  end

  return function(entries)
    local fontObj = _G[ns.CurrentFont().font] or GameFontHighlightSmall
    local width = frame:GetWidth() - 20
    local y = -8
    local nRow, nIcon, nHead = 0, 0, 0

    local function Head(e)
      nHead = nHead + 1
      local h = GetHead(nHead)
      h.text:SetFontObject(fontObj)
      h.text:SetText(e.head)
      h.click = e.click
      h:EnableMouse(e.click ~= nil)
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + (e.indent or 0), y)
      h:SetSize(width - (e.indent or 0), h.text:GetStringHeight() + 2)
      h:Show()
      y = y - h.text:GetStringHeight() - 4
    end

    local function Icon(r, k, x, iconsY, tex)
      nIcon = nIcon + 1
      local b = GetIcon(nIcon)
      b.tex:SetTexture(tex)
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", r, "TOPLEFT", x + (k - 1) * (SMALL_ICON + 3), -iconsY)
      b:SetFrameLevel(r:GetFrameLevel() + 2)
      b.itemId, b.spell, b.extra, b.click = nil, nil, nil, r.item.click
      b.count:SetText("")
      b:Show()
      return b
    end

    local function Row(item)
      nRow = nRow + 1
      local r = GetRow(nRow)
      r.item = item
      local indent = item.indent or 0
      local left = item.icon and (ROW_ICON + 6) or 0
      r.icon:SetTexture(item.icon)
      r.icon:SetShown(item.icon ~= nil)
      r.text:ClearAllPoints()
      r.text:SetPoint("TOPLEFT", left, -2)
      r.text:SetFontObject(fontObj)
      r.text:SetWidth(width - indent - left)

      -- Known spells become icons; the rest stay in the text, at most five of them.
      local withIcon, noIcon = {}, {}
      for _, s in ipairs(item.spells or {}) do
        local name = s:gsub(" %d+$", "")
        local tex = ns.SpellIcon(name)
        if tex then table.insert(withIcon, { name = name, tex = tex }) else table.insert(noIcon, s) end
      end
      local text = item.text or ""
      r.fullList = nil
      if item.spells then
        local shown = noIcon
        if #noIcon > 5 then
          shown = { unpack(noIcon, 1, 5) }
          table.insert(shown, ns.T("PW_MORE", #noIcon - 5))
          r.fullList = table.concat(noIcon, "\n")
        end
        if #withIcon > 0 or #noIcon > 5 then
          text = (text:match("^(|c%x+.-|r)") or "") .. (#shown > 0 and (" " .. table.concat(shown, ", ")) or "")
        end
      end
      r.text:SetText(text)
      r.text:SetShown(text ~= "")

      local h = (text ~= "") and math.max(ROW_ICON + 2, r.text:GetStringHeight() + 4) or (item.icon and ROW_ICON + 2 or 0)
      r:ClearAllPoints()
      r:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + indent, y)

      if item.bar and item.bar.max and item.bar.max > 0 then
        local w = width - indent - left
        local pct = math.max(0, math.min(1, item.bar.value / item.bar.max))
        r.barBg:ClearAllPoints()
        r.barBg:SetPoint("TOPLEFT", left, -h)
        r.barBg:SetSize(w, 5)
        r.bar:ClearAllPoints()
        r.bar:SetPoint("TOPLEFT", left, -h)
        r.bar:SetSize(math.max(1, w * pct), 5)
        local c = item.bar.color or { 0.35, 0.75, 1 }
        r.bar:SetColorTexture(c[1], c[2], c[3], 0.9)
        r.barBg:Show(); r.bar:Show()
        h = h + 8
      else
        r.barBg:Hide(); r.bar:Hide()
      end

      local stripY = h
      local k = 0
      for _, s in ipairs(withIcon) do
        k = k + 1
        local b = Icon(r, k, left, stripY, s.tex)
        b.spell = s.name
      end
      for _, it in ipairs(item.items or {}) do
        local tex = ns.ItemIcon(it.id)
        if tex then
          k = k + 1
          local b = Icon(r, k, left, stripY, tex)
          b.itemId = it.id
          if it.need then
            local done = (it.have or 0) >= it.need
            b.count:SetText((done and "|cff60ff60" or "|cffff6060") .. (it.have or 0) .. "/" .. it.need .. "|r")
          elseif it.count then
            b.count:SetText(tostring(it.count))
          end
          b.extra = it.extra
        end
      end
      if k > 0 then
        -- Item icons with counts need a bit more room per icon.
        local per = (item.items and #item.items > 0) and 40 or (SMALL_ICON + 3)
        if per > SMALL_ICON + 3 then
          for i = nIcon - k + 1, nIcon do
            local b = iconPool[i]
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", r, "TOPLEFT", left + (i - (nIcon - k) - 1) * per, -stripY)
          end
        end
        h = h + SMALL_ICON + 6
      end

      r:SetSize(width - indent, math.max(h, 1))
      r:EnableMouse(item.click ~= nil or item.tip ~= nil)
      r.hl:SetShown(item.click ~= nil)
      r:Show()
      y = y - h - 2
    end

    for _, e in ipairs(entries) do
      if e.head then Head(e)
      elseif e.gap then y = y - e.gap
      else Row(e) end
    end

    for i = nRow + 1, #rowPool do rowPool[i]:Hide() end
    for i = nIcon + 1, #iconPool do iconPool[i]:Hide() end
    for i = nHead + 1, #headPool do headPool[i]:Hide() end
    frame.rendering = true
    frame:SetHeight(-y + 8)
    frame.rendering = false
  end
end

-- Makes a window from ns.MakeWindow draw rows: SetContent and resizing redraw it.
function ns.UseRows(frame, refresh)
  frame.text:Hide()
  frame.render = ns.RowRenderer(frame)
  function frame:SetContent() refresh() end
  frame:SetScript("OnSizeChanged", function(self)
    if self.rendering then return end
    ns.Debounce(tostring(self) .. "size", 0.05, refresh)
  end)
end
