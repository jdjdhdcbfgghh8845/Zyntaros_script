local Utils = {}
local Registry = getgenv().MyHubState.Registry

--[[
    Check if player is on the same team (MUST BE DEFINED FIRST)
--]]
function Utils.isTeammate(player)
    if not Registry.teamCheckEnabled then return false end
    if not player then return false end
    
    -- Check if both players have teams
    if Registry.LocalPlayer.Team and player.Team then
        -- Same team = teammate
        return Registry.LocalPlayer.Team == player.Team
    end
    
    -- If no teams exist, assume not teammate
    return false
end

--[[
    Check if player is whitelisted
--]]
function Utils.isWhitelisted(player)
    if not player then return false end
    for _, name in ipairs(Registry.whitelist) do
        if player.Name:lower() == name:lower() or player.DisplayName:lower() == name:lower() then
            return true
        end
    end
    return false
end

--[[
    Get health color based on HP percentage
--]]
function Utils.getHealthColor(health, maxHealth)
    local healthPercent = (health / maxHealth) * 100
    
    if healthPercent > 75 then
        return Color3.fromRGB(0, 255, 0) -- Green
    elseif healthPercent > 50 then
        return Color3.fromRGB(255, 255, 0) -- Yellow
    elseif healthPercent > 25 then
        return Color3.fromRGB(255, 165, 0) -- Orange
    else
        return Color3.fromRGB(255, 0, 0) -- Red
    end
end

--[[
    Create highlight box around player (visible through walls)
    Only for enemies - teammates are filtered out before this
--]]
function Utils.createHighlight(character, player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = Registry.ESP_SETTINGS.BoxTransparency
    highlight.OutlineTransparency = 0
    highlight.FillColor = Registry.ESP_SETTINGS.BoxColor -- Enemy color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = character
    
    return highlight
end

--[[
    Create overhead ESP display (name, health, distance)
--]]
function Utils.createESPLabel(character, player)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then return nil end
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = Registry.CoreGui
    
    -- Create frame container
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    -- Player name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = frame
    
    -- Health label
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(1, 0, 0, 20)
    healthLabel.Position = UDim2.new(0, 0, 0, 25)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "HP: 100"
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextSize = 12
    healthLabel.Parent = frame
    
    -- Distance label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 0, 50)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 11
    distanceLabel.Parent = frame
    
    return billboard
end

--[[
    Update ESP information (health, distance, colors)
--]]
function Utils.updateESP(player, espData)
    if not espData then return end
    
    -- Remove ESP if player became teammate
    if Utils.isTeammate(player) then
        getgenv().MyHubState.Visuals.removeESP(player)
        return
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then return end
    
    -- Remove ESP if player died
    local health = humanoid.Health
    if health <= 0 then
        getgenv().MyHubState.Visuals.removeESP(player)
        return
    end
    
    -- OPTIMIZED: Cache frequently accessed objects
    local billboard = espData.billboard
    if billboard then
        local frame = billboard:FindFirstChild("Frame")
        if frame then
            local healthLabel = frame:FindFirstChild("HealthLabel")
            local distanceLabel = frame:FindFirstChild("DistanceLabel")
            
            if healthLabel then
                local maxHealth = humanoid.MaxHealth
                local healthInt = Registry.mathFloor(health)
                local maxHealthInt = Registry.mathFloor(maxHealth)
                healthLabel.Text = healthInt .. "/" .. maxHealthInt -- Faster than string.format
                healthLabel.TextColor3 = Utils.getHealthColor(healthInt, maxHealthInt)
            end
            
            -- Update distance (OPTIMIZED)
            if distanceLabel then
                local localChar = Registry.LocalPlayer.Character
                if localChar then
                    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        local distance = (localRoot.Position - humanoidRootPart.Position).Magnitude
                        distanceLabel.Text = Registry.mathFloor(distance) .. "m" -- Faster concatenation
                        
                        -- Hide if too far (optimized)
                        local isVisible = distance <= Registry.ESP_SETTINGS.MaxDistance
                        billboard.Enabled = isVisible
                        if espData.highlight then
                            espData.highlight.Enabled = isVisible
                        end
                    end
                end
            end
        end
    end
    
    -- Update highlight color based on health (OPTIMIZED)
    if espData.highlight then
        local healthPercent = (health / humanoid.MaxHealth) * 100
        espData.highlight.FillColor = Utils.getHealthColor(humanoid.Health, humanoid.MaxHealth)
    end
end

-- Check if target is visible (not behind walls)
function Utils.isTargetVisible(targetPart)
    if not Registry.wallCheckEnabled then return true end
    if not targetPart then return false end
    
    local character = Registry.LocalPlayer.Character
    if not character then return false end
    
    local origin = Registry.Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    
    -- Create raycast params
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    -- Perform raycast
    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    
    -- If ray hits nothing, target is visible
    -- If ray hits something, check if it's the target
    if not raycastResult then
        return true
    end
    
    -- Check if hit part belongs to target
    return raycastResult.Instance:IsDescendantOf(targetPart.Parent)
end

return Utils
