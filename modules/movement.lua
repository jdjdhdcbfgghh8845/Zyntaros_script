-- [[ ACC MOVEMENT MODULE ]]
-- Speed, Noclip, and Infinite Jump systems

local Constants = require(script.Parent.Parent.core.constants)
local State = Constants.State
local Services = Constants.Services

local Movement = {}

-- [[ SPEED HACK ]]
function Movement.applySpeedHack()
    if not Constants.LocalPlayer.Character then return end
    local humanoid = Constants.LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if State.speedHackEnabled then
        if humanoid.WalkSpeed == 16 or humanoid.WalkSpeed == State.originalWalkSpeed then
            State.originalWalkSpeed = humanoid.WalkSpeed
        end
        humanoid.WalkSpeed = State.originalWalkSpeed * State.speedMultiplier
    else
        humanoid.WalkSpeed = State.originalWalkSpeed
    end
end

-- [[ INITIALIZE ]]
function Movement.initialize()
    -- Character respawn handling
    Constants.LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid then
            State.originalWalkSpeed = humanoid.WalkSpeed
            if State.speedHackEnabled then Movement.applySpeedHack() end
        end
    end)
    
    -- Continuous speed update
    task.spawn(function()
        while task.wait(0.15) do
            if State.speedHackEnabled then Movement.applySpeedHack() end
        end
    end)
    
    -- Noclip (Stepped for collision override)
    Services.RunService.Stepped:Connect(function()
        if State.noclipEnabled and Constants.LocalPlayer.Character then
            for _, v in pairs(Constants.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
    
    -- Infinite Jump
    Services.UserInputService.JumpRequest:Connect(function()
        if State.infJumpEnabled and Constants.LocalPlayer.Character then
            local humanoid = Constants.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState("Jumping") end
        end
    end)
end

return Movement
