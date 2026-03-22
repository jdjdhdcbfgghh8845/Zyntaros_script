local Combat = {}
local Registry = getgenv().MyHubState.Registry
local Utils = getgenv().MyHubState.Utils

--[[
    AIMBOT FUNCTIONALITY
    Auto-aim to nearest player within FOV
--]]

-- Get closest player to crosshair within FOV with advanced targeting
function Combat.getClosestPlayerInFOV()
    -- Sticky aim: keep locked on current target if still valid
    if Registry.currentAimbotTarget and (tick() - Registry.targetLockTime) < Registry.stickyAimDuration then
        local player = Registry.currentAimbotTarget
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and not Utils.isTeammate(player) then
                local targetPart = player.Character:FindFirstChild(Registry.aimbotTargetPart)
                if targetPart and Utils.isTargetVisible(targetPart) then
                    local screenPos, onScreen = Registry.Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(Registry.Camera.ViewportSize.X / 2, Registry.Camera.ViewportSize.Y / 2)
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance < Registry.aimbotFOV * 1.5 then -- Allow 50% more FOV for sticky targets
                            return Registry.currentAimbotTarget
                        end
                    end
                end
            end
        end
        -- Target lost, reset
        Registry.currentAimbotTarget = nil
    end
    
    local closestPlayer = nil
    local bestScore = math.huge
    local screenCenter = Vector2.new(Registry.Camera.ViewportSize.X / 2, Registry.Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Registry.Players:GetPlayers()) do
        if player ~= Registry.LocalPlayer and player.Character then
            -- Skip teammates
            if not Utils.isTeammate(player) then
                local character = player.Character
                local humanoid = character:FindFirstChild("Humanoid")
                
                -- Skip dead players (corpses)
                if humanoid and humanoid.Health > 0 then
                    local targetPart = character:FindFirstChild(Registry.aimbotTargetPart)
                    
                    if targetPart then
                        -- Check if target is visible (wall check)
                        if Utils.isTargetVisible(targetPart) then
                            local screenPos, onScreen = Registry.Camera:WorldToViewportPoint(targetPart.Position)
                            
                            if onScreen then
                                local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                
                                if screenDistance < Registry.aimbotFOV then
                                    -- Calculate 3D distance
                                    local rootPart = Registry.LocalPlayer.Character and Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    local worldDistance = rootPart and (rootPart.Position - targetPart.Position).Magnitude or 999
                                    
                                    -- Priority scoring system:
                                    -- - Closer to crosshair = better
                                    -- - Lower health = higher priority
                                    -- - Closer distance = higher priority
                                    local healthFactor = (100 - humanoid.Health) / 100 -- 0 to 1, higher for low HP
                                    local distanceFactor = math.min(worldDistance / 100, 1) -- Normalize distance
                                    
                                    -- Weighted score (lower is better)
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
        end
    end
    
    -- Update sticky target
    if closestPlayer then
        Registry.currentAimbotTarget = closestPlayer
        Registry.targetLockTime = tick()
    end
    
    return closestPlayer
end

-- Aim at target with velocity prediction
local aimbotErrorShown = false
local previousTargetPositions = {} -- Store previous positions for velocity calculation

-- Mouse simulation utility (Bypasses camera resets)
function Combat.moveMouse(targetPos)
    local screenPos, onScreen = Registry.Camera:WorldToViewportPoint(targetPos)
    if onScreen then
        local screenCenter = Vector2.new(Registry.Camera.ViewportSize.X / 2, Registry.Camera.ViewportSize.Y / 2)
        local delta = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter)
        
        -- Use mousemoverel if executor supports it
        if mousemoverel then
            -- Scale delta by smoothness for natural feel
            local moveX = delta.X * (1 - Registry.aimbotSmoothness)
            local moveY = delta.Y * (1 - Registry.aimbotSmoothness)
            mousemoverel(moveX, moveY)
        else
            -- Fallback to InputService if mousemoverel is missing
            -- This is less effective for bypassing resets but better than nothing
            pcall(function()
                local InputService = game:GetService("VirtualInputManager")
                if InputService then
                    InputService:SendMouseMoveEvent(screenPos.X, screenPos.Y, game)
                end
            end)
        end
    end
end

function Combat.aimAtTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetPart = targetPlayer.Character:FindFirstChild(Registry.aimbotTargetPart)
    if not targetPart then return end
    
    local targetPosition = targetPart.Position
    local cameraPosition = Registry.Camera.CFrame.Position
    
    -- Advanced velocity prediction
    if Registry.predictionEnabled then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            -- Calculate velocity based on current velocity or position history
            local velocity = Vector3.new(0, 0, 0)
            
            -- Method 1: Use AssemblyLinearVelocity if available
            if targetRoot.AssemblyLinearVelocity then
                velocity = targetRoot.AssemblyLinearVelocity
            elseif targetRoot.Velocity then
                velocity = targetRoot.Velocity
            end
            
            -- Method 2: Calculate from position history (more accurate)
            if previousTargetPositions[targetPlayer] then
                local prevPos = previousTargetPositions[targetPlayer].position
                local prevTime = previousTargetPositions[targetPlayer].time
                local deltaTime = tick() - prevTime
                
                if deltaTime > 0 and deltaTime < 0.5 then -- Valid time window
                    local calculatedVelocity = (targetPosition - prevPos) / deltaTime
                    -- Blend both velocities for best accuracy
                    velocity = (velocity + calculatedVelocity) / 2
                end
            end
            
            -- Store current position for next frame
            previousTargetPositions[targetPlayer] = {
                position = targetPosition,
                time = tick()
            }
            
            -- Calculate distance to target
            local distance = (targetPosition - cameraPosition).Magnitude
            
            -- Predict future position based on velocity and distance
            local travelTime = distance / 1000 
            local prediction = velocity * travelTime * Registry.predictionMultiplier * 10
            
            -- Apply prediction
            targetPosition = targetPosition + prediction
        end
    end
    
    -- STEALTH MODE: Mouse Simulation
    if Registry.aimbotMode == "Mouse" then
        Combat.moveMouse(targetPosition)
        return
    end

    -- CLASSIC MODE: Camera LERP
    local targetCFrame = CFrame.new(cameraPosition, targetPosition)
    
    -- Dynamic smoothness based on distance to target
    local viewportSize = Registry.Camera.ViewportSize
    local screenCenterX = viewportSize.X * 0.5
    local screenCenterY = viewportSize.Y * 0.5
    local screenPos = Registry.Camera:WorldToViewportPoint(targetPosition)
    
    local dx = screenPos.X - screenCenterX
    local dy = screenPos.Y - screenCenterY
    local screenDistance = Registry.mathSqrt(dx * dx + dy * dy)
    
    local dynamicSmoothness = Registry.mathClamp(Registry.aimbotSmoothness * (1 + screenDistance / 500), Registry.aimbotSmoothness, 1.0)
    
    local success, err = pcall(function()
        Registry.Camera.CFrame = Registry.Camera.CFrame:Lerp(targetCFrame, dynamicSmoothness)
    end)
    
    if not success and not aimbotErrorShown then
        warn("[AIMBOT] Camera manipulation failed - switching to Mouse mode automatically")
        Registry.aimbotMode = "Mouse"
        aimbotErrorShown = true
    end
end

--[[
    360° SILENT AIM
    Shoots at enemies in any direction without turning camera
--]]

function Combat.getSilentAimTarget()
    if not Registry.silentAimEnabled then return nil end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Registry.Players:GetPlayers()) do
        if player ~= Registry.LocalPlayer and player.Character and not Utils.isTeammate(player) then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            
            -- Skip dead players (corpses)
            if humanoid and humanoid.Health > 0 then
                local targetPart = character:FindFirstChild(Registry.aimbotTargetPart)
                
                if targetPart then
                    -- Wall check
                    if Registry.wallCheckEnabled then
                        if not Utils.isTargetVisible(targetPart) then
                            continue
                        end
                    end
                    
                    -- Calculate distance
                    if Registry.LocalPlayer.Character and Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (Registry.LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                        
                        -- Hit chance calculation
                        local hitRoll = math.random(1, 100)
                        if hitRoll <= Registry.silentAimHitChance then
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

--[[
    AUTO SHOOT SYSTEM
    Automatically shoots when target is found
--]]

local lastShootTime = 0

function Combat.autoShoot()
    if not Registry.autoShootEnabled then return end
    if tick() - lastShootTime < Registry.autoShootDelay then return end
    
    local target = Combat.getSilentAimTarget()
    if target then
        -- Simulate mouse click to shoot
        local shootSuccess = pcall(function()
            mouse1click()
        end)
        
        if not shootSuccess then
            -- Fallback method
            pcall(function()
                mouse1press()
                wait(0.05)
                mouse1release()
            end)
        end
        
        lastShootTime = tick()
        print("[AUTO SHOOT] 🔫 Fired at " .. target.Name)
    end
end

--[[
    TRIGGER BOT FUNCTIONALITY
    Auto-clicks when hovering over a player with H enabled
--]]

-- Check if mouse is hovering over a player (not teammate) with smart detection
function Combat.isHoveringPlayer()
    local target = Registry.mouse.Target
    if not target then return false end
    
    local bestTarget = nil
    local bestPriority = 0
    
    -- Check if target belongs to a player's character
    for _, player in pairs(Registry.Players:GetPlayers()) do
        if player ~= Registry.LocalPlayer and player.Character then
            -- Skip teammates
            if not Utils.isTeammate(player) then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                
                -- Skip dead players (corpses)
                if humanoid and humanoid.Health > 0 then
                    if target:IsDescendantOf(player.Character) then
                        -- Smart body part detection
                        local priority = 1 -- Default priority
                        
                        if Registry.triggerBotSmart then
                            local targetName = target.Name:lower()
                            
                            -- Prioritize critical body parts
                            if targetName == "head" then
                                priority = 10 -- Highest priority
                            elseif targetName == "upperTorso" or targetName == "torso" then
                                priority = 5 -- Medium-high priority
                            elseif targetName == "lowerTorso" then
                                priority = 4
                            elseif targetName:find("arm") then
                                priority = 2 -- Lower priority
                            elseif targetName:find("leg") then
                                priority = 1 -- Lowest priority
                            else
                                priority = 3 -- Unknown parts
                            end
                            
                            -- Factor in health - lower health = higher priority
                            local healthFactor = (100 - humanoid.Health) / 100
                            priority = priority + healthFactor * 2
                        end
                        
                        if priority > bestPriority then
                            bestTarget = player
                            bestPriority = priority
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget ~= nil, bestTarget, bestPriority
end

-- Auto click function with ULTRA FAST firing
function Combat.autoClick()
    if not Registry.triggerBotEnabled then return end
    
    local isHovering, targetPlayer, priority = Combat.isHoveringPlayer()
    
    if isHovering then
        -- Additional validation: check if still visible
        if targetPlayer and targetPlayer.Character then
            local targetPart = Registry.mouse.Target
            if targetPart and Utils.isTargetVisible(targetPart) then
                -- Ultra-fast firing with minimal delay
                local currentTime = tick()
                local minDelay = Registry.ESP_SETTINGS.TriggerDelay
                
                -- Only check delay for non-critical shots
                if priority >= 8 or (currentTime - Registry.lastTriggerShot >= minDelay) then
                    -- Simulate left mouse button click - INSTANT
                    local success = pcall(function()
                        mouse1press()
                        mouse1release()
                    end)
                    
                    if success then
                        Registry.lastTriggerShot = currentTime
                        -- Optional: Debug output for high-priority targets
                        if priority >= 10 then
                            print("[TRIGGER BOT] 🎯 Headshot on " .. targetPlayer.Name)
                        end
                    else
                        -- Fallback method - also instant
                        pcall(function()
                            mouse1click()
                            Registry.lastTriggerShot = currentTime
                        end)
                    end
                end
            end
        end
    end
end

return Combat
