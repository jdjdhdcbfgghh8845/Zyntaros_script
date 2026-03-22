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
    if not Registry.LocalPlayer.Character then return end
    local humanoid = Registry.LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local scales = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale", "BodyProportionScale"}
    
    if Registry.shrinkEnabled then
        for _, scaleName in ipairs(scales) do
            local scaleValue = humanoid:FindFirstChild(scaleName)
            if scaleValue and scaleValue:IsA("NumberValue") then
                scaleValue.Value = Registry.shrinkScale
            end
        end
    else
        -- Restore to default
        for _, scaleName in ipairs(scales) do
            local scaleValue = humanoid:FindFirstChild(scaleName)
            if scaleValue and scaleValue:IsA("NumberValue") then
                scaleValue.Value = 1
            end
        end
    end
end

return Misc
