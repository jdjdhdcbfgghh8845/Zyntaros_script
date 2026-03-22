-- [[ ACC AIMBOT PAGE ]]
local Components = require(script.Parent.Parent.components)
local Constants = require(script.Parent.Parent.Parent.core.constants)
local State = Constants.State

local AimbotPage = {}

function AimbotPage.render(container)
    local section = Components.createSection(container, "Master Controls")
    
    -- Aimbot Tile
    Components.createFeatureTile(container, "Aimbot", State.aimbotEnabled, function(val)
        State.aimbotEnabled = val
    end, function()
        -- Right click overlay (Smoothness, FOV, Prediction)
        local overlay = Components.createOverlay(container, "Aimbot Settings")
        Components.createSlider(overlay, "Aimbot Smoothness", 0.05, 1.0, State.aimbotSmoothness, function(v) State.aimbotSmoothness = v end)
        Components.createSlider(overlay, "Aimbot FOV Size", 10, 2000, State.aimbotFOV, function(v) State.aimbotFOV = v end)
        Components.createToggle(overlay, "Wall Check", State.wallCheckEnabled, function(v) State.wallCheckEnabled = v end)
        Components.createToggle(overlay, "Team Check", State.teamCheckEnabled, function(v) State.teamCheckEnabled = v end)
        Components.createToggle(overlay, "Aimbot Prediction", State.predictionEnabled, function(v) State.predictionEnabled = v end)
        Components.createSlider(overlay, "Prediction Strength", 0, 1, State.predictionMultiplier, function(v) State.predictionMultiplier = v end)
        Components.createToggle(overlay, "Auto Shoot (Aimbot)", State.aimbotAutoShoot, function(v) State.aimbotAutoShoot = v end)
    end)
    
    -- Trigger Bot Tile
    Components.createFeatureTile(container, "Trigger Bot", State.triggerBotEnabled, function(val)
        State.triggerBotEnabled = val
    end, function()
        local overlay = Components.createOverlay(container, "Trigger Bot Settings")
        Components.createToggle(overlay, "Smart Mode (Head)", State.triggerBotSmart, function(v) State.triggerBotSmart = v end)
    end)
    
    -- Silent Aim Tile
    Components.createFeatureTile(container, "Silent Aim", State.silentAimEnabled, function(val)
        State.silentAimEnabled = val
    end, function()
        local overlay = Components.createOverlay(container, "Silent Aim Settings")
        Components.createSlider(overlay, "Silent Hit Chance (%)", 0, 100, State.silentAimHitChance, function(v) State.silentAimHitChance = v end)
        Components.createToggle(overlay, "Silent Auto Shoot", State.autoShootEnabled, function(v) State.autoShootEnabled = v end)
    end)
end

return AimbotPage
