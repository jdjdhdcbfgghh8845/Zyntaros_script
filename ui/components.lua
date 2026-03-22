-- [[ ACC UI COMPONENTS ]]
-- Modular, interactive UI elements with premium animations

local Constants = require(script.Parent.Parent.core.constants)
local State = Constants.State
local Services = Constants.Services

local Components = {}

-- [[ SECTION HEADER ]]
function Components.createSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 35)
    section.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = section
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 200, 200)
    stroke.Thickness = 1; stroke.Transparency = 0.6
    stroke.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return section
end

-- [[ BUTTON COMPONENT ]]
function Components.createButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4); corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100); stroke.Thickness = 1; stroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        callback()
        Services.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        task.wait(0.1)
        Services.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    
    return btn
end

-- [[ OVERLAY SYSTEM ]]
function Components.createOverlay(parent, title)
    -- Remove existing overlays in this page container
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == "SettingOverlay" then child:Destroy() end
    end
    
    local overlay = Instance.new("ScrollingFrame")
    overlay.Name = "SettingOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    overlay.BackgroundTransparency = 0.1
    overlay.BorderSizePixel = 0
    overlay.CanvasSize = UDim2.new(0,0,0,0)
    overlay.AutomaticCanvasSize = Enum.AutomaticSize.Y
    overlay.ScrollBarThickness = 2
    overlay.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = overlay
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 40); padding.Parent = overlay
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.BackgroundTransparency = 1; closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18; closeBtn.Parent = overlay
    closeBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Text = title; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = overlay
    
    return overlay
end

-- [[ TOGGLE COMPONENT ]]
function Components.createToggle(parent, name, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    toggleFrame.Parent = parent
    
    local corner = Instance.new("UICorner", toggleFrame)
    local stroke = Instance.new("UIStroke", toggleFrame)
    stroke.Color = Color3.fromRGB(100, 100, 100); stroke.Thickness = 1
    
    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(1,-60,1,0); label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1; label.Text = name; label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Font = Enum.Font.Gotham; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", toggleFrame)
    btn.Size = UDim2.new(0,40,0,20); btn.Position = UDim2.new(1,-50,0.5,-10)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(220,220,220) or Color3.fromRGB(40,40,40)
    btn.Text = defaultState and "ON" or "OFF"; btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 10
    
    local btnCorner = Instance.new("UICorner", btn)
    
    local state = defaultState
    local function update(s)
        state = s
        btn.BackgroundColor3 = state and Color3.fromRGB(220,220,220) or Color3.fromRGB(40,40,40)
        btn.Text = state and "ON" or "OFF"
    end
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        update(state)
        callback(state)
    end)
    
    _G.ConfigRegistry[name] = update
    return update
end

-- [[ SLIDER COMPONENT ]]
function Components.createSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-20,0,50); frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", frame)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(100,100,100); stroke.Thickness = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-20,0,20); label.Position = UDim2.new(0,10,0,5)
    label.BackgroundTransparency = 1; label.Text = name .. ": " .. default; label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Font = Enum.Font.Gotham; label.TextSize = 11; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1,-20,0,4); track.Position = UDim2.new(0,10,1,-15)
    track.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", track)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(220,220,220)
    Instance.new("UICorner", fill)
    
    local handle = Instance.new("Frame", track)
    handle.Size = UDim2.new(0,12,0,12); handle.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255); Instance.new("UICorner", handle)
    
    local dragging = false
    local function updateSlider(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        local val = min + (max-min)*rel
        if max-min > 10 then val = math.floor(val) end
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, -6, 0.5, -6)
        label.Text = name .. ": " .. string.format("%.1f", val)
        callback(val)
    end
    
    frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    Services.UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    Services.UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(i) end end)
    
    _G.ConfigRegistry[name] = function(v)
        local rel = (v-min)/(max-min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, -6, 0.5, -6)
        label.Text = name .. ": " .. string.format("%.1f", v)
    end
end

-- [[ FEATURE TILE COMPONENT ]]
function Components.createFeatureTile(parent, name, defaultState, callback, rightClickCallback)
    local tile = Instance.new("Frame")
    tile.Size = UDim2.new(0, 140, 0, 120)
    tile.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tile.Parent = parent
    
    Instance.new("UICorner", tile).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", tile)
    stroke.Color = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1.5; stroke.Transparency = 0.8
    
    local btn = Instance.new("TextButton", tile)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    
    local title = Instance.new("TextLabel", tile)
    title.Size = UDim2.new(1, 0, 0, 30); title.Position = UDim2.new(0, 0, 0.6, 0)
    title.BackgroundTransparency = 1; title.Text = name; title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.Font = Enum.Font.GothamBold; title.TextSize = 13
    
    local status = Instance.new("TextLabel", tile)
    status.Size = UDim2.new(1, 0, 0, 20); status.Position = UDim2.new(0, 0, 0.8, 0)
    status.BackgroundTransparency = 1; status.Text = defaultState and "ENABLED" or "DISABLED"
    status.TextColor3 = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
    status.Font = Enum.Font.GothamBold; status.TextSize = 9
    
    local icon = Instance.new("TextLabel", tile)
    icon.Size = UDim2.new(1, 0, 0.5, 0); icon.Position = UDim2.new(0, 0, 0.1, 0)
    icon.BackgroundTransparency = 1; icon.Text = "⚙️"; icon.TextSize = 32; icon.Parent = tile

    local state = defaultState
    local function update(s)
        state = s
        stroke.Color = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
        status.Text = state and "ENABLED" or "DISABLED"
        status.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
        Services.TweenService:Create(tile, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(22, 22, 22)}):Play()
    end
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        update(state)
        callback(state)
    end)
    
    btn.MouseButton2Click:Connect(function()
        if rightClickCallback then rightClickCallback() end
    end)
    
    _G.ConfigRegistry[name] = update
    return update
end

return Components
