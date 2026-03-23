local Effects = {}
local Registry = getgenv().MyHubState.Registry
local Utils = getgenv().MyHubState.Utils

--[[
    CHAMS - Colored Enemy Models
    Враги светятся цветными моделями через стены
--]]

local chamsObjects = {}
_G.chamsColor = Color3.fromRGB(255, 0, 100) -- Enemy color
_G.teammateChamsColor = Color3.fromRGB(0, 255, 100) -- Teammate color

function Effects.createChams(player)
    if player == Registry.LocalPlayer then return end
    if not player.Character then return end
    
    -- Remove old chams
    if chamsObjects[player] then
        chamsObjects[player]:Destroy()
    end
    
    -- Выбор цвета в зависимости от команды (используем GLOBAL переменные)
    local isTeam = Utils.isTeammate(player)
    local fillColor = isTeam and _G.teammateChamsColor or _G.chamsColor
    
    -- Create Highlight (works through walls!)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ChamsHighlight"
    highlight.Adornee = player.Character
    highlight.FillColor = fillColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно через стены!
    highlight.Parent = player.Character
    
    chamsObjects[player] = highlight
end

function Effects.removeChams(player)
    if chamsObjects[player] then
        chamsObjects[player]:Destroy()
        chamsObjects[player] = nil
    end
end

function Effects.updateChams()
    if not _G.chamsEnabled then
        for player, _ in pairs(chamsObjects) do
            Effects.removeChams(player)
        end
        return
    end
    
    for _, player in pairs(Registry.Players:GetPlayers()) do
        if player ~= Registry.LocalPlayer and player.Character then
            if not chamsObjects[player] then
                Effects.createChams(player)
            else
                -- Обновить цвет если игрок уже подсвечен (используем GLOBAL переменные)
                local isTeam = Utils.isTeammate(player)
                local newColor = isTeam and _G.teammateChamsColor or _G.chamsColor
                if chamsObjects[player].FillColor ~= newColor then
                    chamsObjects[player].FillColor = newColor
                end
            end
        end
    end
end

--[[
    TRACERS - Lines to Enemies
    Линии от центра экрана к врагам
--]]

local tracersDrawing = Instance.new("ScreenGui")
tracersDrawing.Name = "TracersGUI"
tracersDrawing.ResetOnSpawn = false
tracersDrawing.Parent = Registry.CoreGui
table.insert(Registry.AllGuis, tracersDrawing)

local tracerLines = {}
local tracersColor = Color3.fromRGB(0, 255, 255)

function Effects.createTracer(player)
    if player == Registry.LocalPlayer then return end
    if not player.Character then return nil end
    if Utils.isTeammate(player) then return nil end
    
    local line = Drawing.new("Line") or Instance.new("Frame") -- Fallback if Drawing not available
    
    if line.ClassName == "Frame" then
        -- Fallback method using Frame
        line.Size = UDim2.new(0, 2, 0, 0)
        line.BackgroundColor3 = tracersColor
        line.BorderSizePixel = 0
        line.Parent = tracersDrawing
    else
        -- Drawing method (better performance)
        line.Visible = true
        line.Color = tracersColor
        line.Thickness = 2
        line.Transparency = 0.7
    end
    
    return line
end

function Effects.updateTracers()
    if not _G.tracersEnabled then
        for _, line in pairs(tracerLines) do
            if line then
                if typeof(line) == "Instance" then
                    line:Destroy()
                else
                    line.Visible = false
                end
            end
        end
        tracerLines = {}
        return
    end
    
    local screenCenter = Vector2.new(Registry.Camera.ViewportSize.X / 2, Registry.Camera.ViewportSize.Y)
    
    for _, player in pairs(Registry.Players:GetPlayers()) do
        if player ~= Registry.LocalPlayer and player.Character and not Utils.isTeammate(player) then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local screenPos, onScreen = Registry.Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen and screenPos.Z > 0 then
                    if not tracerLines[player] then
                        tracerLines[player] = Effects.createTracer(player)
                    end
                    
                    local line = tracerLines[player]
                    if line then
                        if typeof(line) == "Instance" then
                            -- Frame method
                            local linePos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (linePos - screenCenter).Magnitude
                            local angle = math.atan2(linePos.Y - screenCenter.Y, linePos.X - screenCenter.X)
                            
                            line.Size = UDim2.new(0, distance, 0, 2)
                            line.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
                            line.Rotation = math.deg(angle)
                        else
                            -- Drawing method
                            line.From = screenCenter
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                            line.Visible = true
                        end
                    end
                else
                    if tracerLines[player] then
                        if typeof(tracerLines[player]) == "Instance" then
                            tracerLines[player]:Destroy()
                        else
                            tracerLines[player].Visible = false
                        end
                        tracerLines[player] = nil
                    end
                end
            end
        end
    end
end

--[[
    CUSTOM CROSSHAIR
    Кастомный прицел с индикацией врагов
--]]

local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "CrosshairGUI"
crosshairGui.ResetOnSpawn = false
crosshairGui.Parent = Registry.CoreGui
table.insert(Registry.AllGuis, crosshairGui)

local crosshairFrame = Instance.new("Frame")
crosshairFrame.Size = UDim2.new(0, 20, 0, 20)
crosshairFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Parent = crosshairGui

local crosshairColor = Color3.fromRGB(0, 255, 0)

-- Horizontal line
local hLine = Instance.new("Frame")
hLine.Size = UDim2.new(0, 14, 0, 2)
hLine.Position = UDim2.new(0.5, -7, 0.5, -1)
hLine.BackgroundColor3 = crosshairColor
hLine.BorderSizePixel = 0
hLine.Parent = crosshairFrame

-- Vertical line
local vLine = Instance.new("Frame")
vLine.Size = UDim2.new(0, 2, 0, 14)
vLine.Position = UDim2.new(0.5, -1, 0.5, -7)
vLine.BackgroundColor3 = crosshairColor
vLine.BorderSizePixel = 0
vLine.Parent = crosshairFrame

-- Center dot
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 3, 0, 3)
dot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
dot.BackgroundColor3 = crosshairColor
dot.BorderSizePixel = 0
dot.Parent = crosshairFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

function Effects.updateCrosshair()
    crosshairFrame.Visible = _G.crosshairEnabled
    
    if not _G.crosshairEnabled then return end
    
    -- Check if aiming at enemy
    local target = Registry.mouse.Target
    if target then
        for _, player in pairs(Registry.Players:GetPlayers()) do
            if player ~= Registry.LocalPlayer and player.Character and not Utils.isTeammate(player) then
                if target:IsDescendantOf(player.Character) then
                    -- Enemy detected - change to RED
                    hLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    vLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    return
                end
            end
        end
    end
    
    -- No enemy - default color
    hLine.BackgroundColor3 = crosshairColor
    vLine.BackgroundColor3 = crosshairColor
    dot.BackgroundColor3 = crosshairColor
end

--[[
    GLOW EFFECT
    Enemies glow with outline
--]]

function Effects.applyGlow(player)
    if not player.Character then return end
    
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            local glow = Instance.new("SurfaceLight")
            glow.Name = "GlowEffect"
            glow.Brightness = 2
            glow.Color = Color3.fromRGB(255, 0, 100)
            glow.Range = 16
            glow.Parent = part
        end
    end
end

function Effects.removeGlow(player)
    if not player.Character then return end
    
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("SurfaceLight") and part.Name == "GlowEffect" then
            part:Destroy()
        end
    end
end

--[[
    BULLET TRACERS
    Рисует линию от игрока до цели при выстреле
--]]

function Effects.createBulletTracer(from, to)
    if not Registry.bulletTracersEnabled then return end
    
    local distance = (from - to).Magnitude
    if distance > 1000 then return end -- Skip extreme distances
    
    local p = Instance.new("Part")
    p.Name = "BulletTracer"
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Size = Vector3.new(0.05, 0.05, distance)
    p.CFrame = CFrame.new(from:Lerp(to, 0.5), to)
    p.Color = Registry.bulletTracerColor or Color3.fromRGB(255, 0, 0)
    p.Material = Enum.Material.Neon
    p.Transparency = 0.4
    p.Parent = workspace:FindFirstChildOfClass("Camera") or workspace
    
    -- Animate fading and removal
    task.spawn(function()
        local duration = Registry.bulletTracerDuration or 0.5
        local start = tick()
        while tick() - start < duration do
            local elapsed = tick() - start
            local percent = elapsed / duration
            p.Transparency = 0.4 + (0.6 * percent)
            -- Optionally shrink the tracer
            -- p.Size = Vector3.new(0.05 * (1 - percent), 0.05 * (1 - percent), distance)
            task.wait()
        end
        p:Destroy()
    end)
end

return Effects
