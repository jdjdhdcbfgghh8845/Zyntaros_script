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

--[[
    HITBOX SHRINKER
--]]
function Misc.applyShrink()
    local char = Registry.LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if Registry.shrinkEnabled then
        -- R15 Scaling (Standard method)
        local foundScale = false
        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale", "BodyProportionScale"}
        for _, scaleName in ipairs(scales) do
            local v = humanoid:FindFirstChild(scaleName)
            if v and v:IsA("NumberValue") then
                v.Value = Registry.shrinkScale
                foundScale = true
            end
        end
        
        -- R6 Logic / Direct Part Scaling (Fallback/Brute Force)
        -- We iterate through parts and shrink them if they aren't the Root
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function()
                    -- Force shrink ALL parts (not just Head) to the specified scale
                    part.Size = Vector3.new(Registry.shrinkScale, Registry.shrinkScale, Registry.shrinkScale)
                    
                    -- Eliminate collisions between parts to prevent flinging
                    part.CanCollide = false 
                end)
            end
        end
    else
        -- Restore R15 Scales
        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale", "BodyProportionScale"}
        for _, scaleName in ipairs(scales) do
            local v = humanoid:FindFirstChild(scaleName)
            if v and v:IsA("NumberValue") then
                v.Value = 1
            end
        end
        -- We don't easily restore R6 sizes without storing them, 
        -- but usually a character reset or turning off/on works.
    end
end

return Misc
