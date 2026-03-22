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

return Visuals
