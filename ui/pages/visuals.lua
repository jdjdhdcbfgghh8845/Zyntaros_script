-- [[ ACC VISUALS PAGE ]]
local Components = require(script.Parent.Parent.components)
local Constants = require(script.Parent.Parent.Parent.core.constants)
local State = Constants.State

local VisualsPage = {}

function VisualsPage.render(container)
    local section = Components.createSection(container, "ESP Settings")
    
    -- ESP Main
    Components.createFeatureTile(container, "ESP", State.espEnabled, function(val)
        State.espEnabled = val
    end, function()
        local overlay = Components.createOverlay(container, "ESP Details")
        Components.createToggle(overlay, "Skeleton ESP", Constants.ESP_SETTINGS.SkeletonEnabled, function(v) Constants.ESP_SETTINGS.SkeletonEnabled = v end)
        Components.createSlider(overlay, "Max Distance", 100, 10000, Constants.ESP_SETTINGS.MaxDistance, function(v) Constants.ESP_SETTINGS.MaxDistance = v end)
        Components.createToggle(overlay, "Chams", State.chamsEnabled, function(v) State.chamsEnabled = v end)
        Components.createToggle(overlay, "Tracers", State.tracersEnabled, function(v) State.tracersEnabled = v end)
        Components.createToggle(overlay, "Enemy Glow", State.glowEnabled, function(v) State.glowEnabled = v end)
    end)
    
    -- World Themes
    Components.createFeatureTile(container, "World Themes", State.worldVisualsEnabled, function(val)
        State.worldVisualsEnabled = val
    end, function()
        local overlay = Components.createOverlay(container, "Theme Selection")
        for _, themeName in pairs({"Cyberpunk", "Ocean", "Forest", "Hell", "Space", "Candy", "Neon", "Default"}) do
            -- Button for theme selection
            Components.createButton(overlay, themeName, function()
                State.currentTheme = themeName
                -- Force theme update logic if needed
            end)
        end
        Components.createToggle(overlay, "Rainbow Mode", State.rainbowEnabled, function(v) State.rainbowEnabled = v end)
    end)
end

return VisualsPage
