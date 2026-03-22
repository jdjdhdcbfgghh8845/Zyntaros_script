-- [[ ACC SETTINGS PAGE ]]
-- Config management and Information

local Constants = require(script.Parent.Parent.Parent.core.constants)
local Components = require(script.Parent.Parent.components)

local SettingsPage = {}

function SettingsPage.setup(page)
    -- [[ CONFIG TILE ]]
    Components.createFeatureTile(page, "Configuration", true, function() end)
    Components.createToggle(page, "SAVE CONFIG", false, function()
        -- Trigger saveConfig (will be connected in init.lua)
        _G.saveConfig()
    end)
    Components.createToggle(page, "LOAD CONFIG", false, function()
        -- Trigger loadConfig (will be connected in init.lua)
        _G.loadConfig()
    end)
    
    -- [[ INFO TILE ]]
    Components.createFeatureTile(page, "Information", true, function() end)
    
    local function createInfo(text)
        local label = Instance.new("TextLabel", page)
        label.Size = UDim2.new(1, -20, 0, 20)
        label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(150, 150, 150)
        label.Font = Enum.Font.Gotham; label.TextSize = 11; label.Text = text
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    createInfo("Build: v2.4.0-PRO")
    createInfo("User: " .. Constants.LocalPlayer.Name)
    createInfo("Status: Active")
    createInfo("Exploit: " .. (identifyexecutor and identifyexecutor() or "Unknown"))
end

return SettingsPage
