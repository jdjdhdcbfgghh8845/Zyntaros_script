-- [[ ACC SILENT AIM MODULE ]]
-- Advanced silent aim using metatable hooks

local Constants = require(script.Parent.Parent.core.constants)
local Utils = require(script.Parent.Parent.utils.utils)
local State = Constants.State
local Services = Constants.Services

local SilentAim = {}

function SilentAim.getSilentAimTarget()
    if not State.silentAimEnabled then return nil end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Constants.LocalPlayer and player.Character and not Utils.isTeammate(player) then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local targetPart = character:FindFirstChild(State.aimbotTargetPart)
                
                if targetPart then
                    if State.wallCheckEnabled and not Utils.isTargetVisible(targetPart) then
                        continue
                    end
                    
                    if Constants.LocalPlayer.Character and Constants.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (Constants.LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                        
                        -- Hit chance calculation
                        local hitRoll = math.random(1, 100)
                        if hitRoll <= (State.silentAimHitChance * 100) then
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

-- [[ AUTO SHOOT ]]
function SilentAim.autoShoot()
    if not State.autoShootEnabled then return end
    if tick() - State.lastAimbotShot < State.autoShootDelay then return end
    
    local target = SilentAim.getSilentAimTarget()
    if target then
        local shootSuccess = pcall(function()
            mouse1click()
        end)
        
        if not shootSuccess then
            pcall(function()
                mouse1press()
                task.wait(0.05)
                mouse1release()
            end)
        end
        
        State.lastAimbotShot = tick()
        print("[AUTO SHOOT] 🔫 Fired at " .. target.Name) -- Exact parity print
    end
end

-- [[ INITIALIZE ]]
function SilentAim.initialize()
    if not hookmetamethod then return end
    
    -- __namecall Hook (FireServer redirection)
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if not checkcaller() and State.silentAimEnabled and method == "FireServer" then
            if self.Name:find("Shoot") or self.Name:find("Fire") or self.Name:find("Remote") then
                local target = SilentAim.getSilentAimTarget()
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild(State.aimbotTargetPart)
                    if targetPart then
                        args[1] = targetPart.Position
                        print("[SILENT AIM] 🎯 Redirected shot to " .. target.Name) -- Exact parity print
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    
    -- __index Hook (Camera/FOV Bypass)
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, index)
        if not checkcaller() and self:IsA("Camera") then
            if index == "FieldOfView" and State.customFOVEnabled then
                return State.customFOV
            elseif index == "CFrame" and State.aimbotEnabled then
                -- Return fake or pass through as in lines 540-547
            end
        end
        return oldIndex(self, index)
    end)
    
    Services.RunService.Heartbeat:Connect(function()
        if State.silentAimEnabled or State.autoShootEnabled then
            SilentAim.autoShoot()
        end
    end)
end

return SilentAim
