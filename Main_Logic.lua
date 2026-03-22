local Main_Logic = {}
local Registry = getgenv().MyHubState.Registry
local Utils = getgenv().MyHubState.Utils
local Combat = getgenv().MyHubState.Combat
local Visuals = getgenv().MyHubState.Visuals
local Effects = getgenv().MyHubState.Effects
local World = getgenv().MyHubState.World
local Config = getgenv().MyHubState.Config

-- Helper to safely get modules (in case of dynamic loading issues)
local function getModule(name)
    return getgenv().MyHubState[name]
end

--[[
    CAMERA METATABLE HOOK (ANTI-CHEAT BYPASS)
    Hides camera manipulation from the game engine
--]]
function Main_Logic.installBypasses()
    if hookmetamethod and checkcaller then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and self == Registry.Camera and key == "CFrame" and Registry.aimbotEnabled then
                -- If the game tries to read Camera.CFrame, we can potentially return a "fake" one
            end
            return oldIndex(self, key)
        end)
        print("[BYPASS] ✅ Camera metatable hook installed")
    end


end

--[[
    CAMERA FOV FUNCTIONS
    Change camera field of view for zoom effect
--]]
local fovConnection = nil

function Main_Logic.applyCameraFOV()
    if Registry.customFOVEnabled then
        -- Force set FOV multiple times
        pcall(function()
            Registry.Camera.FieldOfView = Registry.customFOV
        end)
        
        -- Create persistent connection if not exists
        if not fovConnection then
            fovConnection = Registry.RunService.RenderStepped:Connect(function()
                if Registry.customFOVEnabled then
                    pcall(function()
                        if Registry.Camera.FieldOfView ~= Registry.customFOV then
                            Registry.Camera.FieldOfView = Registry.customFOV
                        end
                    end)
                end
            end)
        end
    else
        -- Restore default FOV
        pcall(function()
            Registry.Camera.FieldOfView = Registry.defaultFOV
        end)
        
        -- Disconnect aggressive updates
        if fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
    end
end

--[[
    EVENT CONNECTIONS
--]]
function Main_Logic.onCharacterAdded(player, character)
    if player == Registry.LocalPlayer then 
        -- Monitor for character respawn to reapply speed
        wait(0.5)
        local humanoid = character:WaitForChild("Humanoid")
        Registry.originalWalkSpeed = humanoid.WalkSpeed
        if Registry.speedHackEnabled then
            Misc.applySpeedHack()
        end
        return 
    end
    
    character:WaitForChild("HumanoidRootPart", 10)
    wait(0.5) -- Wait for character to fully load
    
    if Registry.espEnabled then
        Visuals.createESP(player)
    end
    
    if _G.chamsEnabled then
        Effects.createChams(player)
    end
    
    if _G.glowEnabled then
        Effects.applyGlow(player)
    end
end

function Main_Logic.connectEvents()
    Registry.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            Main_Logic.onCharacterAdded(player, character)
        end)
        
        -- If character already exists
        if player.Character then
            Main_Logic.onCharacterAdded(player, player.Character)
        end
    end)
    
    Registry.Players.PlayerRemoving:Connect(function(player)
        Visuals.removeESP(player)
        Effects.removeChams(player)
        Effects.removeGlow(player)
    end)
    
    Registry.LocalPlayer.CharacterAdded:Connect(function(char)
        Main_Logic.onCharacterAdded(Registry.LocalPlayer, char)
        wait(1)
        if Registry.espEnabled then
            Visuals.initializeESP()
        end
    end)
    
    Registry.UserInputService.JumpRequest:Connect(function()
        local Misc = getModule("Misc")
        if Misc then
            Misc.applyInfiniteJump()
        end
    end)
    
    -- Auto-Load Config on start
    task.spawn(function()
        wait(1)
        Config.loadConfig()
    end)

    -- Universal Keybind Listener
    Registry.UserInputService.InputBegan:Connect(function(input, processed)
        -- Only ignore if typing in a text box
        if Registry.UserInputService:GetFocusedTextBox() then return end
        
        for featureName, bindKey in pairs(Registry.Keybinds) do
            if input.KeyCode == bindKey and bindKey ~= Enum.KeyCode.Unknown then
                if featureName == "Aimbot" then
                    Registry.aimbotEnabled = not Registry.aimbotEnabled
                    local update = _G.ConfigRegistry["Aimbot"]
                    if update then update(Registry.aimbotEnabled) end
                    print("[AIMBOT] Toggled: " .. tostring(Registry.aimbotEnabled))
                
                elseif featureName == "Trigger Bot" then
                    Registry.triggerBotEnabled = not Registry.triggerBotEnabled
                    local update = _G.ConfigRegistry["Trigger Bot"]
                    if update then update(Registry.triggerBotEnabled) end
                    print("[TRIGGER] Toggled: " .. tostring(Registry.triggerBotEnabled))
                
                elseif featureName == "Rage Aimbot" then
                    Registry.rageAimbotEnabled = not Registry.rageAimbotEnabled
                    local update = _G.ConfigRegistry["Rage Aimbot"]
                    if update then update(Registry.rageAimbotEnabled) end
                    print("[RAGE] Toggled: " .. tostring(Registry.rageAimbotEnabled))
                
                elseif featureName == "Third Person View" then
                    local Misc = getgenv().MyHubState.Misc
                    if Misc then Misc.toggleThirdPerson() end
                
                elseif featureName == "Fly Hack" then
                    Registry.flyEnabled = not Registry.flyEnabled
                    local update = _G.ConfigRegistry["Fly Hack"]
                    if update then update(Registry.flyEnabled) end
                    print("[FLY] Toggled: " .. tostring(Registry.flyEnabled))
                
                elseif featureName == "Noclip" then
                    Registry.noclipEnabled = not Registry.noclipEnabled
                    local update = _G.ConfigRegistry["Noclip"]
                    if update then update(Registry.noclipEnabled) end
                    print("[NOCLIP] Toggled: " .. tostring(Registry.noclipEnabled))
                
                elseif featureName == "Speed Hack" then
                    Registry.speedHackEnabled = not Registry.speedHackEnabled
                    local update = _G.ConfigRegistry["Speed Hack"]
                    if update then update(Registry.speedHackEnabled) end
                    print("[SPEED] Toggled: " .. tostring(Registry.speedHackEnabled))
                
                elseif featureName == "Infinite Jump" then
                    Registry.infJumpEnabled = not Registry.infJumpEnabled
                    local update = _G.ConfigRegistry["Infinite Jump"]
                    if update then update(Registry.infJumpEnabled) end
                    print("[INF JUMP] Toggled: " .. tostring(Registry.infJumpEnabled))
                end
                
                -- Auto-Save on keybind toggle
                if Registry.autoSaveEnabled then
                    getgenv().MyHubState.Config.saveConfig()
                end
            end
        end
    end)
end

--[[
    MAIN LOOPS
--]]
function Main_Logic.startLoops()
    -- OPTIMIZED: Main render loop - high-priority systems only
    Registry.RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        
        -- Trigger Bot (ULTRA FAST - always runs)
        if Registry.triggerBotEnabled then
            Combat.autoClick()
        end
        
        -- Aimbot (OPTIMIZED - throttled to ~120 FPS)
        if Registry.aimbotEnabled and currentTime - Registry.lastAimbotUpdate >= Registry.aimbotUpdateInterval then
            Registry.lastAimbotUpdate = currentTime
            
            local target = Combat.getClosestPlayerInFOV()
            if target then
                Combat.aimAtTarget(target)
                
                -- Auto shoot when locked on target
                if Registry.aimbotAutoShoot and target.Character then
                    if currentTime - Registry.lastAimbotShot >= Registry.aimbotShootDelay then
                        -- Check if target is visible
                        local targetPart = target.Character:FindFirstChild(Registry.aimbotTargetPart)
                        if targetPart and Utils.isTargetVisible(targetPart) then
                            -- Fire weapon (OPTIMIZED)
                            local success = pcall(mouse1press)
                            if success then
                                task.wait(0.01)
                                pcall(mouse1release)
                                Registry.lastAimbotShot = currentTime
                            else
                                -- Fallback
                                pcall(mouse1click)
                                Registry.lastAimbotShot = currentTime
                            end
                        end
                    end
                end
            end
        end
        
        -- Rage Aimbot (ORBIT)
        if Registry.rageAimbotEnabled then
            Combat.performRageBot()
        end
        
        -- Update FOV circle (always visible)
        if getgenv().MyHubState.fovCircle then
            getgenv().MyHubState.fovCircle.Position = Vector2.new(Registry.Camera.ViewportSize.X / 2, Registry.Camera.ViewportSize.Y / 2)
            getgenv().MyHubState.fovCircle.Radius = Registry.aimbotFOV
            getgenv().MyHubState.fovCircle.Visible = Registry.aimbotEnabled
        end
    end)

    -- OPTIMIZED: Secondary loop for less critical systems (Heartbeat ~30 FPS)
    local lastSecondaryUpdate = 0
    local secondaryUpdateInterval = 0.033 -- ~30 FPS
    Registry.RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastSecondaryUpdate < secondaryUpdateInterval then return end
        lastSecondaryUpdate = currentTime
        
        -- ESP Update
        if Registry.espEnabled and currentTime - Registry.lastESPUpdate >= Registry.espUpdateInterval then
            Registry.lastESPUpdate = currentTime
            for player, espData in pairs(Registry.espObjects) do
                if player and player.Character then
                    Utils.updateESP(player, espData)
                else
                    Visuals.removeESP(player)
                end
            end
        end

        -- Effects Updates
        Effects.updateChams()
        Effects.updateTracers()
        Effects.updateCrosshair()
        Visuals.updateSkeleton()


        
        -- World Visuals
        if Registry.worldVisualsEnabled then
            if Registry.currentTheme == "Rainbow" and Registry.rainbowEnabled then
                World.updateRainbow()
            end
            World.updateSpeedBlur()
            World.updatePulse()
        end

        -- Target HUD Update
        Visuals.updateTargetHUD()

        -- Continuous Speed Hack check
        local Misc = getModule("Misc")
        if Misc then
            if Registry.speedHackEnabled then
                Misc.applySpeedHack()
            end

            -- Fly Hack Update
            Misc.updateFly()
        end

        -- Periodic Auto-Save
        if Registry.autoSaveEnabled and currentTime - Registry.lastAutoSave >= Registry.autoSaveInterval then
            Registry.lastAutoSave = currentTime
            Config.saveConfig()
        end

        -- Noclip
        Misc.applyNoclip()
    end)
end

return Main_Logic
