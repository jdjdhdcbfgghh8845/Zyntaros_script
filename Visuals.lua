local Visuals = {}
local Registry = getgenv().MyHubState.Registry
local Utils = getgenv().MyHubState.Utils

--[[
    ESP LOADERS
--]]

-- Create ESP for a player
function Visuals.createESP(player)
    if player == Registry.LocalPlayer then return end
    
    -- Skip teammates (don't create ESP for them)
    if Utils.isTeammate(player) then return end
    
    -- Check if already has ESP
    if Registry.espObjects[player] then
        Visuals.removeESP(player)
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- Skip dead players (corpses)
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Create ESP objects
    local highlight = Utils.createHighlight(character, player)
    local billboard = Utils.createESPLabel(character, player)
    
    if highlight and billboard then
        Registry.espObjects[player] = {
            highlight = highlight,
            billboard = billboard,
            player = player
        }
    end
end

-- Remove ESP from a player
function Visuals.removeESP(player)
    if Registry.espObjects[player] then
        if Registry.espObjects[player].highlight then
            Registry.espObjects[player].highlight:Destroy()
        end
        if Registry.espObjects[player].billboard then
            Registry.espObjects[player].billboard:Destroy()
        end
        Registry.espObjects[player] = nil
    end
end

-- Initialize ESP for all current players
function Visuals.initializeESP()
    for _, player in pairs(Registry.Players:GetPlayers()) do
        if player ~= Registry.LocalPlayer and player.Character then
            Visuals.createESP(player)
        end
    end
end

--[[
    SKELETON ESP - Bone to Bone Rendering
--]]
local skeletonLines = {}

local function createSkeletonLine()
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Transparency = 1
    line.Color = Registry.ESP_SETTINGS.SkeletonColor
    line.Visible = false
    return line
end

function Visuals.getSkeleton(player)
    if not skeletonLines[player] then
        skeletonLines[player] = {
            -- Head to Neck
            {"Head", "UpperTorso"},
            -- Torso
            {"UpperTorso", "LowerTorso"},
            -- Arms
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"RightLowerArm", "RightHand"},
            -- Legs
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"},
            {"RightLowerLeg", "RightFoot"}
        }
        
        local joints = {}
        for i = 1, #skeletonLines[player] do
            table.insert(joints, createSkeletonLine())
        end
        skeletonLines[player].drawings = joints
    end
    return skeletonLines[player]
end

function Visuals.updateSkeleton()
    if not Registry.ESP_SETTINGS.SkeletonEnabled then
        for player, data in pairs(skeletonLines) do
            for _, drawing in pairs(data.drawings) do
                drawing.Visible = false
            end
        end
        return
    end

    for _, player in pairs(Registry.Players:GetPlayers()) do
        if player ~= Registry.LocalPlayer and player.Character and not Utils.isTeammate(player) then
            local char = player.Character
            local data = Visuals.getSkeleton(player)
            local drawings = data.drawings
            
            local allVisible = true
            for i, bonePair in ipairs(data) do
                local part1 = char:FindFirstChild(bonePair[1])
                local part2 = char:FindFirstChild(bonePair[2])
                local drawing = drawings[i]
                
                if part1 and part2 then
                    local pos1, vis1 = Registry.Camera:WorldToViewportPoint(part1.Position)
                    local pos2, vis2 = Registry.Camera:WorldToViewportPoint(part2.Position)
                    
                    if vis1 and vis2 then
                        drawing.Visible = true
                        drawing.From = Vector2.new(pos1.X, pos1.Y)
                        drawing.To = Vector2.new(pos2.X, pos2.Y)
                        drawing.Color = Registry.ESP_SETTINGS.SkeletonColor
                    else
                        drawing.Visible = false
                    end
                else
                    drawing.Visible = false
                end
            end
        else
            if skeletonLines[player] then
                for _, drawing in pairs(skeletonLines[player].drawings) do
                    drawing.Visible = false
                end
            end
        end
    end
end

--[[
    TARGET HUD - Display info about current target near crosshair
--]]
local targetHUD = nil
local targetHUDFrame = nil
local targetHUDName = nil
local targetHUDHealthBar = nil
local targetHUDDistance = nil

function Visuals.createTargetHUD()
    if targetHUD then return end
    
    targetHUD = Instance.new("ScreenGui")
    targetHUD.Name = "TargetHUD"
    targetHUD.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    targetHUD.ResetOnSpawn = false
    targetHUD.Parent = Registry.CoreGui
    
    targetHUDFrame = Instance.new("Frame")
    targetHUDFrame.Name = "MainFrame"
    targetHUDFrame.Size = UDim2.new(0, 180, 0, 75)
    -- Position slightly below and to the right of screen center
    targetHUDFrame.Position = UDim2.new(0.5, 40, 0.5, 40)
    targetHUDFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    targetHUDFrame.BackgroundTransparency = 0.3
    targetHUDFrame.BorderSizePixel = 0
    targetHUDFrame.Visible = false
    targetHUDFrame.Parent = targetHUD
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = targetHUDFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.7
    stroke.Parent = targetHUDFrame
    
    -- Sub-container for padding
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -24, 1, -24)
    container.Position = UDim2.new(0, 12, 0, 12)
    container.BackgroundTransparency = 1
    container.Parent = targetHUDFrame
    
    -- Name Label (Clean modern font style)
    targetHUDName = Instance.new("TextLabel")
    targetHUDName.Size = UDim2.new(1, 0, 0, 20)
    targetHUDName.BackgroundTransparency = 1
    targetHUDName.Font = Enum.Font.GothamBold
    targetHUDName.Text = "TARGET"
    targetHUDName.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetHUDName.TextSize = 13
    targetHUDName.TextXAlignment = Enum.TextXAlignment.Left
    targetHUDName.Parent = container
    
    -- Health Bar Background
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, 0, 0, 6)
    healthBg.Position = UDim2.new(0, 0, 0, 24)
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = container
    
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(1, 0)
    hCorner.Parent = healthBg
    
    -- Health Bar Foreground
    targetHUDHealthBar = Instance.new("Frame")
    targetHUDHealthBar.Size = UDim2.new(1, 0, 1, 0)
    targetHUDHealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    targetHUDHealthBar.BorderSizePixel = 0
    targetHUDHealthBar.Parent = healthBg
    
    local hiCorner = Instance.new("UICorner")
    hiCorner.CornerRadius = UDim.new(1, 0)
    hiCorner.Parent = targetHUDHealthBar
    
    -- Distance Label
    targetHUDDistance = Instance.new("TextLabel")
    targetHUDDistance.Size = UDim2.new(1, 0, 0, 15)
    targetHUDDistance.Position = UDim2.new(0, 0, 0, 36)
    targetHUDDistance.BackgroundTransparency = 1
    targetHUDDistance.Font = Enum.Font.Gotham
    targetHUDDistance.Text = "Distance: --"
    targetHUDDistance.TextColor3 = Color3.fromRGB(180, 180, 180)
    targetHUDDistance.TextSize = 11
    targetHUDDistance.TextXAlignment = Enum.TextXAlignment.Left
    targetHUDDistance.Parent = container
end

function Visuals.updateTargetHUD()
    if not Registry.targetHUDEnabled then
        if targetHUDFrame then targetHUDFrame.Visible = false end
        return
    end
    
    if not targetHUD then Visuals.createTargetHUD() end
    
    local target = Registry.currentAimbotTarget
    if target and target.Character then
        local humanoid = target.Character:FindFirstChild("Humanoid")
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and root then
            targetHUDFrame.Visible = true
            targetHUDName.Text = (target.DisplayName or target.Name):upper()
            
            -- Smoothly interpolate health bar
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local currentSize = targetHUDHealthBar.Size.X.Scale
            local newSize = healthPercent
            
            -- Direct update (could be lerped if needed)
            targetHUDHealthBar.Size = UDim2.new(newSize, 0, 1, 0)
            targetHUDHealthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50):Lerp(Color3.fromRGB(0, 255, 120), healthPercent)
            
            -- Distance check
            local localChar = Registry.LocalPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local dist = math.floor((localRoot.Position - root.Position).Magnitude)
                targetHUDDistance.Text = "DISTANCE: " .. dist .. "M"
            else
                targetHUDDistance.Text = "DISTANCE: --"
            end
        else
            targetHUDFrame.Visible = false
        end
    else
        targetHUDFrame.Visible = false
    end
end

return Visuals
