local E = unpack(ElvUI)
if not E then return end

local addon = CreateFrame("Frame", "ElvUITrackingButtonAddon")
local button
local trackingHidden = false

-------------------------------------------------------
-- Defaults in ElvUI profile
-------------------------------------------------------
local defaults = {
    enabled = true,
    size = 22,
    point = "TOPLEFT",
    relativePoint = "TOPLEFT",
    x = 4,
    y = -4,
    locked = false
}

-------------------------------------------------------
-- Profile DB
-------------------------------------------------------
local function DB()
    E.db.trackingbutton = E.db.trackingbutton or {}

    for k, v in pairs(defaults) do
        if E.db.trackingbutton[k] == nil then
            E.db.trackingbutton[k] = v
        end
    end

    return E.db.trackingbutton
end

-------------------------------------------------------
-- Helpers
-------------------------------------------------------
local function HideDefaultTracking()
    if trackingHidden then return end

    if MiniMapTracking then
        MiniMapTracking:Hide()
        MiniMapTracking.Show = function() end
        trackingHidden = true
    end
end

local function SavePosition()
    local db = DB()
    local p, _, rp, x, y = button:GetPoint()

    db.point = p
    db.relativePoint = rp
    db.x = math.floor(x + 0.5)
    db.y = math.floor(y + 0.5)
end

local function ApplyPosition()
    local db = DB()

    button:ClearAllPoints()
    button:SetPoint(db.point, Minimap, db.relativePoint, db.x, db.y)
end

local function UpdateIcon()
    if not button then return end

    local tex

    for i = 1, GetNumTrackingTypes() do
        local _, icon, active = GetTrackingInfo(i)
        if active then
            tex = icon
            break
        end
    end

    button.icon:SetTexture(tex or "Interface\\Minimap\\Tracking\\None")
end

-------------------------------------------------------
-- Refresh
-------------------------------------------------------
local function RefreshButton()
    if not button then return end

    local db = DB()

    if db.enabled then
        button:Show()
    else
        button:Hide()
        return
    end

    button:SetSize(db.size, db.size)
    ApplyPosition()
    UpdateIcon()
end

-------------------------------------------------------
-- Create
-------------------------------------------------------
local function CreateButton()
    button = CreateFrame("Button", "ElvUITrackingButton", Minimap)
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetFrameStrata("MEDIUM")

    if button.SetTemplate then
        button:SetTemplate("Default")
    end

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexCoord(.08, .92, .08, .92)
    button.icon:SetPoint("TOPLEFT", 2, -2)
    button.icon:SetPoint("BOTTOMRIGHT", -2, 2)

    button:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" then
            local db = DB()
            db.x = defaults.x
            db.y = defaults.y
            db.point = defaults.point
            db.relativePoint = defaults.relativePoint
            ApplyPosition()
            return
        end

        if MiniMapTrackingDropDown then
            ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, -8, 0)
        end
    end)

    button:SetScript("OnDragStart", function(self)
        local db = DB()
        if db.locked then return end
        self:StartMoving()
    end)

    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Tracking")
        GameTooltip:AddLine("Left Click: Open menu", 1, 1, 1)
        GameTooltip:AddLine("Right Click: Reset position", 1, 1, 1)
        GameTooltip:AddLine("Drag: Move", 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    RefreshButton()
end

-------------------------------------------------------
-- Config in /ec
-------------------------------------------------------
local function InjectOptions()
    -- E.Options may not be ready yet on some setups; retry via callback if needed
    if not E.Options then
        if E.RegisterCallback then
            E:RegisterCallback("Options_Loaded", InjectOptions)
        end
        return
    end

    E.Options.args.trackingbutton = {
        order = 100,
        type = "group",
        name = "Tracking Button",
        args = {
            header = {
                order = 1,
                type = "header",
                name = "Tracking Button",
            },

            enabled = {
                order = 2,
                type = "toggle",
                name = "Enable",
                get = function() return DB().enabled end,
                set = function(_, v)
                    DB().enabled = v
                    if v then
                        HideDefaultTracking()
                    end
                    RefreshButton()
                end,
            },

            locked = {
                order = 3,
                type = "toggle",
                name = "Lock Position",
                get = function() return DB().locked end,
                set = function(_, v)
                    DB().locked = v
                end,
            },

            size = {
                order = 4,
                type = "range",
                name = "Size",
                min = 16,
                max = 40,
                step = 1,
                get = function() return DB().size end,
                set = function(_, v)
                    DB().size = v
                    RefreshButton()
                end,
            },

            reset = {
                order = 5,
                type = "execute",
                name = "Reset Position",
                func = function()
                    local db = DB()
                    db.point = defaults.point
                    db.relativePoint = defaults.relativePoint
                    db.x = defaults.x
                    db.y = defaults.y
                    RefreshButton()
                end,
            },
        },
    }
end

-------------------------------------------------------
-- Events
-------------------------------------------------------
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("MINIMAP_UPDATE_TRACKING")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")

addon:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")

        DB()

        local db = DB()
        if db.enabled then
            HideDefaultTracking()
        end

        CreateButton()
        InjectOptions()
        return
    end

    -- MINIMAP_UPDATE_TRACKING and PLAYER_ENTERING_WORLD
    local db = DB()
    if db.enabled then
        HideDefaultTracking()
    end
    UpdateIcon()
end)
