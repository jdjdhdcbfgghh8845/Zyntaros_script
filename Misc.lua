local Misc = {}
local Registry = getgenv().MyHubState.Registry

--[[
    BULLET DODGE SYSTEM
    Automatically dodges incoming bullets and projectiles
--]]

local activeBullets = {}
local lastDodgeTime = 0
local dodgeCooldown = 0.5 -- Seconds between dodges

-- Detect bullets in workspace
function Misc.detectBullets()
    activeBullets = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("BasePart") then
            -- Common bullet identifiers
            if obj.Name:lower():find("bullet") or 
               obj.Name:lower():find("projectile") or
               obj.Name:lower():find("shot") or
               (obj.Velocity and obj.Velocity.Magnitude > 50) then
                table.insert(activeBullets, obj)
            end
        end
    end
end

-- Calculate dodge direction
function Misc.calculateDodgeDirection(bulletPosition, bulletVelocity)
    if not Registry.LocalPlayer.Character or not Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local rootPart = Registry.LocalPlayer.Character.HumanoidRootPart
    local playerPos = rootPart.Position
    
    -- Calculate if bullet is heading towards player
    local toBullet = (bulletPosition - playerPos)
    local bulletDir = bulletVelocity.Unit
    
    -- Get perpendicular dodge direction
    local dodgeDir = Vector3.new(-bulletDir.Z, 0, bulletDir.X).Unit
    
    -- Random left/right
    if math.random() > 0.5 then
        dodgeDir = -dodgeDir
    end
    
    return dodgeDir
end

-- Execute dodge movement
function Misc.performDodge()
    if not Registry.bulletDodgeEnabled then return end
    if tick() - lastDodgeTime < dodgeCooldown then return end
    
    if not Registry.LocalPlayer.Character or not Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = Registry.LocalPlayer.Character.HumanoidRootPart
    local humanoid = Registry.LocalPlayer.Character:FindFirstChild("Humanoid")
    
    if not humanoid then return end
    
    Misc.detectBullets()
    
    for _, bullet in pairs(activeBullets) do
        if bullet and bullet.Parent then
            local bulletPos = bullet.Position
            local bulletVel = bullet.AssemblyLinearVelocity or bullet.Velocity or Vector3.new(0, 0, 0)
            
            local distance = (bulletPos - rootPart.Position).Magnitude
            
            -- Check if bullet is close and moving towards player
            if distance < Registry.dodgeDistance then
                local toBullet = (bulletPos - rootPart.Position).Unit
                local bulletDir = bulletVel.Unit
                
                -- Dot product to check if bullet is coming at us
                local dotProduct = toBullet:Dot(bulletDir)
                
                if dotProduct < -0.5 then -- Bullet heading towards us
                    local dodgeDir = Misc.calculateDodgeDirection(bulletPos, bulletVel)
                    
                    if dodgeDir then
                        -- Apply dodge velocity
                        pcall(function()
                            rootPart.AssemblyLinearVelocity = dodgeDir * (humanoid.WalkSpeed * Registry.dodgeSpeed)
                        end)
                        
                        lastDodgeTime = tick()
                        print("[BULLET DODGE] 🚀 Dodged bullet!")
                        break
                    end
                end
            end
        end
    end
end

--[[
    SPEED HACK FUNCTIONALITY
    Increases player movement speed
--]]

-- Apply speed hack
function Misc.applySpeedHack()
    if not Registry.LocalPlayer.Character then return end
    
    local humanoid = Registry.LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if Registry.speedHackEnabled then
        -- Store original speed on first enable
        if humanoid.WalkSpeed == 16 or humanoid.WalkSpeed == Registry.originalWalkSpeed then
            Registry.originalWalkSpeed = humanoid.WalkSpeed
        end
        
        -- Apply speed multiplier
        humanoid.WalkSpeed = Registry.originalWalkSpeed * Registry.speedMultiplier
    else
        -- Restore original speed
        humanoid.WalkSpeed = Registry.originalWalkSpeed
    end
end

--[[
    NOCLIP & INFINITE JUMP
--]]
function Misc.applyNoclip()
    if Registry.noclipEnabled and Registry.LocalPlayer.Character then
        for _, v in pairs(Registry.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end

function Misc.applyInfiniteJump()
    if Registry.infJumpEnabled then
        local humanoid = Registry.LocalPlayer.Character and Registry.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end

return Misc
