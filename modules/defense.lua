-- [[ ACC DEFENSE MODULE ]]
-- Exact Bullet Dodge logic from old/lua.lua

local Constants = require(script.Parent.Parent.core.constants)
local State = Constants.State
local Services = Constants.Services
local Utils = require(script.Parent.Parent.utils.utils)

local Defense = {}

local activeBullets = {}
local lastDodgeTime = 0
local dodgeCooldown = 0.5

-- 100% Original Logic from old/lua.lua:967
local function detectBullets()
    activeBullets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("BasePart") then
            if obj.Name:lower():find("bullet") or 
               obj.Name:lower():find("projectile") or
               obj.Name:lower():find("shot") or
               (obj.Velocity and obj.Velocity.Magnitude > 50) then
                table.insert(activeBullets, obj)
            end
        end
    end
end

-- 100% Original Logic from old/lua.lua:984
local function calculateDodgeDirection(bulletPosition, bulletVelocity)
    local character = Constants.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local rootPart = character.HumanoidRootPart
    local bulletDir = bulletVelocity.Unit
    local dodgeDir = Vector3.new(-bulletDir.Z, 0, bulletDir.X).Unit
    
    if math.random() > 0.5 then
        dodgeDir = -dodgeDir
    end
    
    return dodgeDir
end

-- 100% Original Logic from old/lua.lua:1008
function Defense.performDodge()
    if not State.bulletDodgeEnabled then return end
    if tick() - lastDodgeTime < dodgeCooldown then return end
    
    local character = Constants.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    detectBullets()
    
    for _, bullet in pairs(activeBullets) do
        if bullet and bullet.Parent then
            local bulletPos = bullet.Position
            local bulletVel = bullet.AssemblyLinearVelocity or bullet.Velocity or Vector3.new(0, 0, 0)
            local distance = (bulletPos - rootPart.Position).Magnitude
            
            if distance < State.dodgeDistance then
                local toBullet = (bulletPos - rootPart.Position).Unit
                local bulletDir = bulletVel.Unit
                local dotProduct = toBullet:Dot(bulletDir)
                
                if dotProduct < -0.5 then -- Bullet heading towards us
                    local dodgeDir = calculateDodgeDirection(bulletPos, bulletVel)
                    if dodgeDir then
                        pcall(function()
                            rootPart.AssemblyLinearVelocity = dodgeDir * (humanoid.WalkSpeed * State.dodgeSpeed)
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

function Defense.initialize()
    Services.RunService.Heartbeat:Connect(function()
        Defense.performDodge()
    end)
end

return Defense
