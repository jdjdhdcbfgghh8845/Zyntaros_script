-- [[ ACC ESP MODULE ]]
-- Highly optimized ESP system with highlights and billboard displays

local Constants = require(script.Parent.Parent.core.constants)
local Utils = require(script.Parent.Parent.utils.utils)
local State = Constants.State
local Services = Constants.Services
local ESP_SETTINGS = Constants.ESP_SETTINGS

local ESP = {}

-- [[ HIGHLIGHT BOX ]]
function ESP.createHighlight(character, player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = ESP_SETTINGS.BoxTransparency
    highlight.OutlineTransparency = 0
    highlight.FillColor = ESP_SETTINGS.BoxColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = character
    
    return highlight
end

-- [[ OVERHEAD LABEL ]]
function ESP.createESPLabel(character, player)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = Services.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = frame
    
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

-- [[ UPDATE ESP STATS ]]
function ESP.updateESP(player, espData)
    if not espData then return end
    
    if Utils.isTeammate(player) then
        ESP.removeESP(player)
        return
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then return end
    
    local health = humanoid.Health
    if health <= 0 then
        ESP.removeESP(player)
        return
    end
    
    local billboard = espData.billboard
    if billboard then
        local frame = billboard:FindFirstChild("Frame")
        if frame then
            local healthLabel = frame:FindFirstChild("HealthLabel")
            local distanceLabel = frame:FindFirstChild("DistanceLabel")
            
            if healthLabel then
                local maxHealth = humanoid.MaxHealth
                healthLabel.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
                healthLabel.TextColor3 = Utils.getHealthColor(health, maxHealth)
            end
            
            if distanceLabel then
                local localChar = Constants.LocalPlayer.Character
                if localChar then
                    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        local distance = (localRoot.Position - humanoidRootPart.Position).Magnitude
                        distanceLabel.Text = math.floor(distance) .. "m"
                        
                        local isVisible = distance <= ESP_SETTINGS.MaxDistance
                        billboard.Enabled = isVisible
                        if espData.highlight then
                            espData.highlight.Enabled = isVisible
                        end
                    end
                end
            end
        end
    end
    
    if espData.highlight then
        espData.highlight.FillColor = Utils.getHealthColor(humanoid.Health, humanoid.MaxHealth)
    end
end

-- [[ CREATE PLAYER ESP ]]
function ESP.createESP(player)
    if player == Constants.LocalPlayer then return end
    if Utils.isTeammate(player) then return end
    
    if State.espObjects[player] then
        ESP.removeESP(player)
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local highlight = ESP.createHighlight(character, player)
    local billboard = ESP.createESPLabel(character, player)
    
    if highlight and billboard then
        State.espObjects[player] = {
            highlight = highlight,
            billboard = billboard,
            player = player
        }
    end
end

-- [[ REMOVE PLAYER ESP ]]
function ESP.removeESP(player)
    if State.espObjects[player] then
        if State.espObjects[player].highlight then
            State.espObjects[player].highlight:Destroy()
        end
        if State.espObjects[player].billboard then
            State.espObjects[player].billboard:Destroy()
        end
        State.espObjects[player] = nil
    end
end

-- [[ INITIALIZE ]]
function ESP.initialize()
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Constants.LocalPlayer and player.Character then
            ESP.createESP(player)
        end
    end
    
    Services.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            character:WaitForChild("HumanoidRootPart", 10)
            task.wait(0.5)
            if State.espEnabled then
                ESP.createESP(player)
            end
        end)
    end)
    
    Services.Players.PlayerRemoving:Connect(function(player)
        ESP.removeESP(player)
    end)
    
    Services.RunService.Heartbeat:Connect(function()
        if not State.espEnabled then return end
        
        local currentTime = tick()
        if currentTime - State.lastESPUpdate < State.espUpdateInterval then return end
        State.lastESPUpdate = currentTime
        
        for player, espData in pairs(State.espObjects) do
            if player and player.Character then
                ESP.updateESP(player, espData)
            else
                ESP.removeESP(player)
            end
        end
    end)
end

return ESP
