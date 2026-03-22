-- [[ ACC UTILITY FUNCTIONS ]]
-- Modular helper functions for target validation and visibility

local Constants = require(script.Parent.Parent.core.constants)
local State = Constants.State
local Services = Constants.Services

local Utils = {}

-- [[ TEAM CHECK ]]
function Utils.isTeammate(player)
    if not State.teamCheckEnabled then return false end
    if not player then return false end
    
    if Constants.LocalPlayer.Team and player.Team then
        return Constants.LocalPlayer.Team == player.Team
    end
    
    return false
end

-- [[ HEALTH COLOR ]]
function Utils.getHealthColor(health, maxHealth)
    local healthPercent = (health / maxHealth) * 100
    
    if healthPercent > 75 then
        return Color3.fromRGB(0, 255, 0) -- Green
    elseif healthPercent > 50 then
        return Color3.fromRGB(255, 255, 255) -- White (Monochrome style adaptation)
    elseif healthPercent > 25 then
        return Color3.fromRGB(150, 150, 150) -- Gray
    else
        return Color3.fromRGB(255, 0, 0) -- Red (Critical)
    end
end

-- [[ VISIBILITY CHECK ]]
function Utils.isTargetVisible(targetPart)
    if not State.wallCheckEnabled then return true end
    if not targetPart then return false end
    
    local character = Constants.LocalPlayer.Character
    if not character then return false end
    
    local origin = Constants.Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    
    if not raycastResult then
        return true
    end
    
    return raycastResult.Instance:IsDescendantOf(targetPart.Parent)
end

-- [[ MOUSE SIMULATION ]]
function Utils.moveMouse(targetPos)
    local screenPos, onScreen = Constants.Camera:WorldToViewportPoint(targetPos)
    if onScreen then
        local screenCenter = Vector2.new(Constants.Camera.ViewportSize.X / 2, Constants.Camera.ViewportSize.Y / 2)
        local delta = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter)
        
        -- Use mousemoverel if executor supports it
        if mousemoverel then
            local moveX = delta.X * (1 - State.aimbotSmoothness)
            local moveY = delta.Y * (1 - State.aimbotSmoothness)
            mousemoverel(moveX, moveY)
        else
            -- Fallback
            pcall(function()
                local VirtualInputManager = game:GetService("VirtualInputManager")
                if VirtualInputManager then
                    VirtualInputManager:SendMouseMoveEvent(screenPos.X, screenPos.Y, game)
                end
            end)
        end
    end
end

return Utils
