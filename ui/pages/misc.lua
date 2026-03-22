-- [[ ACC MISC PAGE ]]
local Components = require(script.Parent.Parent.components)
local Constants = require(script.Parent.Parent.Parent.core.constants)
local State = Constants.State

local MiscPage = {}

function MiscPage.render(container)
    local section = Components.createSection(container, "Movement Features")
    
    -- Speed Hack
    Components.createFeatureTile(container, "Speed Hack", State.speedHackEnabled, function(val)
        State.speedHackEnabled = val
    end, function()
        local overlay = Components.createOverlay(container, "Speed Settings")
        Components.createSlider(overlay, "Speed Multiplier", 1, 10, State.speedMultiplier, function(v) State.speedMultiplier = v end)
    end)
    
    -- Noclip
    Components.createFeatureTile(container, "Noclip", State.noclipEnabled, function(val)
        State.noclipEnabled = val
    end)
    
    -- Infinite Jump
    Components.createFeatureTile(container, "Infinite Jump", State.infJumpEnabled, function(val)
        State.infJumpEnabled = val
    end)
    
    local defenseSection = Components.createSection(container, "Defense Features")
    
    -- Bullet Dodge (Defense in syncMap)
    Components.createFeatureTile(container, "Defense", State.bulletDodgeEnabled, function(val)
        State.bulletDodgeEnabled = val
    end, function()
        local overlay = Components.createOverlay(container, "Defense Settings")
        Components.createSlider(overlay, "Dodge Distance", 5, 50, State.dodgeDistance, function(v) State.dodgeDistance = v end)
        Components.createSlider(overlay, "Dodge Speed", 1, 5, State.dodgeSpeed, function(v) State.dodgeSpeed = v end)
    end)
end

return MiscPage
