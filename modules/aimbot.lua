-- [[ ACC AIMBOT MODULE ]]
-- Advanced aimbot with prediction, sticky aim, and optimization

local Constants = require(script.Parent.Parent.core.constants)
local Utils = require(script.Parent.Parent.utils.utils)
local State = Constants.State
local Services = Constants.Services

local Aimbot = {}

local previousTargetPositions = {}
local fovCircle = nil

-- [[ FOV CIRCLE ]]
function Aimbot.createFOVCircle()
    local success, result = pcall(function()
        local circle = Drawing.new("Circle")
        circle.Thickness = 2
        circle.NumSides = 50
        circle.Radius = State.aimbotFOV
        circle.Color = Color3.fromRGB(255, 255, 255)
        circle.Transparency = 0.7
        circle.Visible = false
        circle.Filled = false
        return circle
    end)
    
    if success then
        fovCircle = result
        return result
    end
    return nil
end

function Aimbot.updateFOVCircle()
    if fovCircle then
        fovCircle.Position = Vector2.new(Constants.Camera.ViewportSize.X / 2, Constants.Camera.ViewportSize.Y / 2)
        fovCircle.Radius = State.aimbotFOV
        fovCircle.Visible = State.aimbotEnabled
    end
end

-- [[ TARGET SELECTION ]]
function Aimbot.getClosestPlayerInFOV()
    -- Sticky aim: keep locked on current target if still valid
    if State.currentAimbotTarget and (tick() - State.targetLockTime) < State.stickyAimDuration then
        local player = State.currentAimbotTarget
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and not Utils.isTeammate(player) then
                local targetPart = player.Character:FindFirstChild(State.aimbotTargetPart)
                if targetPart and Utils.isTargetVisible(targetPart) then
                    local screenPos, onScreen = Constants.Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(Constants.Camera.ViewportSize.X / 2, Constants.Camera.ViewportSize.Y / 2)
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance < State.aimbotFOV * 1.5 then
                            return State.currentAimbotTarget
                        end
                    end
                end
            end
        end
        State.currentAimbotTarget = nil
    end
    
    local closestPlayer = nil
    local bestScore = math.huge
    local screenCenter = Vector2.new(Constants.Camera.ViewportSize.X / 2, Constants.Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Constants.LocalPlayer and player.Character and not Utils.isTeammate(player) then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local targetPart = character:FindFirstChild(State.aimbotTargetPart)
                
                if targetPart and Utils.isTargetVisible(targetPart) then
                    local screenPos, onScreen = Constants.Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        
                        if screenDistance < State.aimbotFOV then
                            local rootPart = Constants.LocalPlayer.Character and Constants.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local worldDistance = rootPart and (rootPart.Position - targetPart.Position).Magnitude or 999
                            
                            local healthFactor = (100 - humanoid.Health) / 100
                            local score = screenDistance * 0.6 + (worldDistance * 0.3) - (healthFactor * 50)
                            
                            if score < bestScore then
                                closestPlayer = player
                                bestScore = score
                            end
                        end
                    end
                end
            end
        end
    end
    
    if closestPlayer then
        State.currentAimbotTarget = closestPlayer
        State.targetLockTime = tick()
    end
    
    return closestPlayer
end

-- [[ AIM EXECUTION ]]
function Aimbot.aimAtTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetPart = targetPlayer.Character:FindFirstChild(State.aimbotTargetPart)
    if not targetPart then return end
    
    local targetPosition = targetPart.Position
    local cameraPosition = Constants.Camera.CFrame.Position
    
    -- Prediction
    if State.predictionEnabled then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local velocity = targetRoot.AssemblyLinearVelocity or targetRoot.Velocity or Vector3.new(0,0,0)
            
            if previousTargetPositions[targetPlayer] then
                local prevPos = previousTargetPositions[targetPlayer].position
                local prevTime = previousTargetPositions[targetPlayer].time
                local deltaTime = tick() - prevTime
                
                if deltaTime > 0 and deltaTime < 0.5 then
                    local calculatedVelocity = (targetPosition - prevPos) / deltaTime
                    velocity = (velocity + calculatedVelocity) / 2
                end
            end
            
            previousTargetPositions[targetPlayer] = {position = targetPosition, time = tick()}
            
            local distance = (targetPosition - cameraPosition).Magnitude
            local travelTime = distance / 1000
            local prediction = velocity * travelTime * State.predictionMultiplier * 10
            targetPosition = targetPosition + prediction
        end
    end
    
    -- Stealth Mode (Mouse Move)
    if State.aimbotMode == "Mouse" then
        Utils.moveMouse(targetPosition)
        return
    end

    -- Classic Mode (Camera LERP)
    local targetCFrame = CFrame.new(cameraPosition, targetPosition)
    local screenPos = Constants.Camera:WorldToViewportPoint(targetPosition)
    local screenCenter = Vector2.new(Constants.Camera.ViewportSize.X / 2, Constants.Camera.ViewportSize.Y / 2)
    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
    
    local dynamicSmoothness = math.clamp(State.aimbotSmoothness * (1 + screenDistance / 500), State.aimbotSmoothness, 1.0)
    
    pcall(function()
        Constants.Camera.CFrame = Constants.Camera.CFrame:Lerp(targetCFrame, dynamicSmoothness)
    end)
end

-- [[ TRIGGER BOT ]]
local function triggerBot()
    if not State.triggerBotEnabled then return end
    local mouse = Constants.LocalPlayer:GetMouse()
    local target = mouse.Target
    if target and target.Parent then
        local player = Services.Players:GetPlayerFromCharacter(target.Parent)
        if player and player ~= Constants.LocalPlayer and not Utils.isTeammate(player) then
            local humanoid = target.Parent:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if State.triggerBotSmart then
                    if target.Name == "Head" then
                        mouse1click()
                    end
                else
                    mouse1click()
                end
            end
        end
    end
end

-- [[ INITIALIZE ]]
function Aimbot.initialize()
    Aimbot.createFOVCircle()
    
    Services.RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        
        -- FOV Circle Update
        Aimbot.updateFOVCircle()
        
        -- Trigger Bot (Always active if enabled)
        triggerBot()
        
        -- Aimbot Logic
        if State.aimbotEnabled and currentTime - State.lastAimbotUpdate >= State.aimbotUpdateInterval then
            State.lastAimbotUpdate = currentTime
            
            local target = Aimbot.getClosestPlayerInFOV()
            if target then
                Aimbot.aimAtTarget(target)
                
                -- Auto Shoot Logic (Part of Aimbot in original)
                if State.aimbotAutoShoot and target.Character then
                    if currentTime - State.lastAimbotShot >= State.aimbotShootDelay then
                        local targetPart = target.Character:FindFirstChild(State.aimbotTargetPart)
                        if targetPart and Utils.isTargetVisible(targetPart) then
                            pcall(mouse1press)
                            task.wait(0.01)
                            pcall(mouse1release)
                            State.lastAimbotShot = currentTime
                            print("[AUTO SHOOT] 🔫 Fired at " .. target.Name)
                        end
                    end
                end
            end
        end
    end)
end

return Aimbot
