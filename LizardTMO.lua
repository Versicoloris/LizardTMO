-- =========================
-- LizardTMO - Core
-- =========================

LizardTMO = {}
LizardTMO.frame = CreateFrame("Frame", "LizardTMOFrame", UIParent)

-- =========================
-- SavedVariables init
-- =========================

LizardTMO.frame:RegisterEvent("ADDON_LOADED")
LizardTMO.frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "LizardTMO" then

        if not LizardTMO_Saved then
            LizardTMO_Saved = { outfits = {} }
        end

        if not LizardTMO_MinimapPos then
            LizardTMO_MinimapPos = 0
        end

        LizardTMO:CreateUI()

        -- Apply saved minimap position AFTER variables load
        if LizardTMO.UpdateMinimapPosition then
            LizardTMO.UpdateMinimapPosition()
        end
    end
end)

-- =========================
-- Apply Code
-- =========================

function LizardTMO:ApplyCode(code)
    local importBtn = _G["TransmogFrame-SM-Btn2"]
    local editBox = _G["TransmogFrameImportFrameEdit"]
    local okBtn = _G["TransmogFrameImportFrame-Ok"]

    if not importBtn or not editBox or not okBtn then
        print("LizardTMO: Transmog UI not found")
        return
    end

    importBtn:Click()
    editBox:SetText(code)
    okBtn:Click()
end

-- =========================
-- UI Creation
-- =========================

function LizardTMO:CreateUI()
    local f = self.frame

    f:SetSize(340, 420)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(200)

    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:Hide()

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("LizardTMO")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    -- Name Input
    local nameBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    nameBox:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -40)
    nameBox:SetSize(140, 20)
    nameBox:SetAutoFocus(false)
    nameBox:SetText("Name")

    -- Code Input (your custom styled one)
    local codeFrame = CreateFrame("Frame", nil, f)
    codeFrame:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", -2, -10)
    codeFrame:SetSize(nameBox:GetWidth() + 2, nameBox:GetHeight())

    codeFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    codeFrame:SetBackdropColor(0, 0, 0, 1)

    local codeBox = CreateFrame("EditBox", nil, codeFrame)
    codeBox:SetPoint("LEFT", 6, 0)
    codeBox:SetPoint("RIGHT", -4, 0)
    codeBox:SetHeight(nameBox:GetHeight())
    codeBox:SetFontObject(nameBox:GetFontObject())
    codeBox:SetAutoFocus(false)

    codeBox:SetText("Paste code here")
    codeBox.isPlaceholder = true

    codeBox:SetScript("OnEditFocusGained", function(self)
        if self.isPlaceholder then
            self:SetText("")
            self.isPlaceholder = false
        end
    end)

    codeBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText("Paste code here")
            self.isPlaceholder = true
        end
    end)

    codeBox:SetScript("OnTextChanged", function(self)
        if not self.isPlaceholder then
            self:SetCursorPosition(strlen(self:GetText()))
        end
    end)

    -- Add Button
    local addBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    addBtn:SetSize(80, 22)
    addBtn:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", 0, -35)
    addBtn:SetText("Add")

    addBtn:SetScript("OnClick", function()
        local name = nameBox:GetText()
        local code = codeBox.isPlaceholder and "" or codeBox:GetText()

        if code ~= "" then
            table.insert(LizardTMO_Saved.outfits, {
                name = name ~= "" and name or ("Outfit #" .. (#LizardTMO_Saved.outfits + 1)),
                code = code
            })
            LizardTMO:RefreshList()

            codeBox:SetText("Paste code here")
            codeBox.isPlaceholder = true
        end
    end)

    -- Scroll Frame
    local scrollFrame = CreateFrame("ScrollFrame", "LizardTMOScroll", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(300, 240)
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -140)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(280, 240)
    scrollFrame:SetScrollChild(content)

    f.content = content

    self:RefreshList()
end

-- =========================
-- Refresh List
-- =========================

function LizardTMO:RefreshList()
    local parent = self.frame.content

    local children = { parent:GetChildren() }
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end

    local y = -10

    for i, outfit in ipairs(LizardTMO_Saved.outfits) do

        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(280, 24)
        row:SetPoint("TOPLEFT", 0, y)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", 5, 0)
        label:SetText(outfit.name)

        local applyBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        applyBtn:SetSize(50, 20)
        applyBtn:SetPoint("RIGHT", -5, 0)
        applyBtn:SetText("Apply")
        applyBtn:SetScript("OnClick", function()
            LizardTMO:ApplyCode(outfit.code)
        end)

        local copyBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        copyBtn:SetSize(50, 20)
        copyBtn:SetPoint("RIGHT", applyBtn, "LEFT", -5, 0)
        copyBtn:SetText("Copy")

        copyBtn:SetScript("OnClick", function()
            if not LizardTMO.CopyFrame then
                local cf = CreateFrame("Frame", "LizardTMO_CopyFrame", UIParent)
                cf:SetSize(400, 120)
                cf:SetPoint("CENTER")
                cf:SetFrameStrata("FULLSCREEN_DIALOG")

                cf:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true, tileSize = 16, edgeSize = 16,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })

                local eb = CreateFrame("EditBox", nil, cf, "InputBoxTemplate")
                eb:SetSize(340, 20)
                eb:SetPoint("TOP", 0, -40)
                eb:SetAutoFocus(true)

                cf.editBox = eb

                local close = CreateFrame("Button", nil, cf, "UIPanelButtonTemplate")
                close:SetSize(80, 22)
                close:SetPoint("BOTTOM", 0, 10)
                close:SetText("Close")
                close:SetScript("OnClick", function() cf:Hide() end)

                LizardTMO.CopyFrame = cf
            end

            local cf = LizardTMO.CopyFrame
            cf:Show()
            cf.editBox:SetText(outfit.code)
            cf.editBox:HighlightText()
        end)

        local delBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        delBtn:SetSize(20, 20)
        delBtn:SetPoint("RIGHT", copyBtn, "LEFT", -5, 0)
        delBtn:SetText("X")
        delBtn:SetScript("OnClick", function()
            table.remove(LizardTMO_Saved.outfits, i)
            LizardTMO:RefreshList()
        end)

        y = y - 28
    end
end

-- =========================
-- Slash Command
-- =========================

SLASH_LIZARDTMO1 = "/tmo"
SlashCmdList["LIZARDTMO"] = function()
    if LizardTMO.frame:IsShown() then
        LizardTMO.frame:Hide()
    else
        LizardTMO.frame:Show()
    end
end

-- =========================
-- Minimap Button
-- =========================

local minimapButton = CreateFrame("Button", "LizardTMO_MinimapButton", Minimap)

minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)
minimapButton:RegisterForDrag("LeftButton")

local bg = minimapButton:CreateTexture(nil, "BACKGROUND")
bg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
bg:SetSize(54, 54)
bg:SetPoint("TOPLEFT")

local icon = minimapButton:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\Icons\\INV_Shirt_06")
icon:SetSize(20, 20)
icon:SetPoint("CENTER", 0, 0)

local border = minimapButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(54, 54)
border:SetPoint("TOPLEFT")

function LizardTMO.UpdateMinimapPosition()
    local angle = math.rad(LizardTMO_MinimapPos or 0)
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Drag
minimapButton:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = UIParent:GetScale()

        px = px / scale
        py = py / scale

        local angle = math.deg(math.atan2(py - my, px - mx))
        LizardTMO_MinimapPos = angle

        LizardTMO.UpdateMinimapPosition()
    end)
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

-- Click
minimapButton:SetScript("OnClick", function(self)
    if LizardTMO.frame:IsShown() then
        LizardTMO.frame:Hide()
    else
        LizardTMO.frame:Show()
    end
end)

-- Tooltip
minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("LizardTMO")
    GameTooltip:AddLine("Left Click: Toggle window", 1,1,1)
    GameTooltip:AddLine("Drag: Move button", 1,1,1)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
