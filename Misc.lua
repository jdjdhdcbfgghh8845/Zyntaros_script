local Misc = {}
local Registry = getgenv().MyHubState.Registry


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
    FLY HACK
--]]
local flyVelocity = nil
local flyGyro = nil

function Misc.updateFly()
    if not Registry.LocalPlayer.Character then return end
    local root = Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if Registry.flyEnabled then
        -- Create physics objects if they don't exist
        if not flyVelocity or flyVelocity.Parent ~= root then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10^6
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyVelocity.Parent = root
            
            flyGyro = Instance.new("BodyGyro")
            flyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10^6
            flyGyro.D = 100
            flyGyro.P = 10000
            flyGyro.CFrame = root.CFrame
            flyGyro.Parent = root
        end
        
        -- Calculate movement direction based on Camera and Input
        local moveDir = Vector3.new(0, 0, 0)
        local camCF = Registry.Camera.CFrame
        
        if Registry.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if Registry.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if Registry.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if Registry.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if Registry.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if Registry.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        flyVelocity.Velocity = moveDir * Registry.flySpeed
        flyGyro.CFrame = camCF
        
        -- Animation fix (stop falling animation)
        local humanoid = Registry.LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        end
    else
        -- Clean up physics objects
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
    end
end

--[[
    THIRD PERSON VIEW
--]]
function Misc.updateThirdPerson()
    pcall(function()
        if Registry.isThirdPerson then
            Registry.LocalPlayer.CameraMaxZoomDistance = 50
            Registry.LocalPlayer.CameraMinZoomDistance = 10
            -- Force zoom out slightly if current distance is too small
        else
            Registry.LocalPlayer.CameraMaxZoomDistance = 0.5
            Registry.LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end)
end

function Misc.toggleThirdPerson()
    Registry.isThirdPerson = not Registry.isThirdPerson
    Misc.updateThirdPerson()
    print("[CAMERA] 🎥 Third Person: " .. (Registry.isThirdPerson and "ON" or "OFF"))
    
    -- Sync UI
    local updateFunc = _G.ConfigRegistry["Third Person View"]
    if updateFunc then updateFunc(Registry.isThirdPerson) end
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
