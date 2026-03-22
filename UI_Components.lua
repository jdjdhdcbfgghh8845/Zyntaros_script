local UI_Components = {}
local Registry = getgenv().MyHubState.Registry

-- Helper function to create section headers (monochrome)
function UI_Components.createSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 35)
    section.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = section
    
    -- Subtle white gradient
    local sectionGradient = Instance.new("UIGradient")
    sectionGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 55, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18))
    }
    sectionGradient.Rotation = 90
    sectionGradient.Parent = section
    
    -- White thin stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 200, 200)
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return section
end

-- Helper function to create beautiful toggle buttons (monochrome)
function UI_Components.createToggle(parent, name, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 4)
    frameCorner.Parent = toggleFrame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = defaultState and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(55, 55, 55)
    frameStroke.Thickness = 1.5
    frameStroke.Transparency = 0.4
    frameStroke.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 1, 0)
    toggle.BackgroundTransparency = 1
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle switch indicator (white = ON, dark = OFF)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 50, 0, 22)
    indicator.Position = UDim2.new(1, -60, 0.5, -11)
    indicator.BackgroundColor3 = defaultState and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(40, 40, 40)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleFrame
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 4)
    indicatorCorner.Parent = indicator
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = defaultState and "ON" or "OFF"
    statusText.TextColor3 = defaultState and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(130, 130, 130)
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 11
    statusText.Parent = indicator
    
    local state = defaultState
    
    local function updateToggle(newState)
        state = newState
        local targetBg   = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(40, 40, 40)
        local targetText = state and Color3.fromRGB(20, 20, 20)    or Color3.fromRGB(130, 130, 130)
        local targetStroke = state and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(55, 55, 55)
        
        Registry.TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
        Registry.TweenService:Create(frameStroke, TweenInfo.new(0.3), {Color = targetStroke}):Play()
        statusText.Text = state and "ON" or "OFF"
        statusText.TextColor3 = targetText
    end
    
    -- Click animation and toggle
    toggle.MouseButton1Click:Connect(function()
        state = not state
        updateToggle(state)
        callback(state)
        
        -- Bounce effect
        Registry.TweenService:Create(toggleFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -5, 0, 42)}):Play()
        task.wait(0.1)
        Registry.TweenService:Create(toggleFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 40)}):Play()
    end)
    
    -- Hover effect
    toggle.MouseEnter:Connect(function()
        Registry.TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
    end)
    toggle.MouseLeave:Connect(function()
        Registry.TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
    end)
    
    -- Register for config sync
    _G.ConfigRegistry[name] = updateToggle
    
    return updateToggle
end

-- Helper function to create beautiful sliders (monochrome)
function UI_Components.createSlider(parent, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 60)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 4)
    frameCorner.Parent = sliderFrame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(180, 180, 180)
    frameStroke.Thickness = 1
    frameStroke.Transparency = 0.6
    frameStroke.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 15, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.35, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.65, 0, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.2f", default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    -- Slider track (dark)
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -30, 0, 8)
    sliderTrack.Position = UDim2.new(0, 15, 1, -20)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    -- Slider fill (white → light gray gradient)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    fill.BorderSizePixel = 0
    fill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
    }
    fillGradient.Parent = fill
    
    -- Slider button (handle) - white dot
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = sliderTrack
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    local handleStroke = Instance.new("UIStroke")
    handleStroke.Color = Color3.fromRGB(180, 180, 180)
    handleStroke.Thickness = 1.5
    handleStroke.Parent = handle
    
    -- Interaction
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 1, 0)
    slider.BackgroundTransparency = 1
    slider.Text = ""
    slider.Parent = sliderTrack
    
    local dragging = false
    
    local function updateSlider(input)
        local relativePos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relativePos
        
        -- Animate slider movement
        Registry.TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(relativePos, 0, 1, 0)}):Play()
        Registry.TweenService:Create(handle, TweenInfo.new(0.1), {Position = UDim2.new(relativePos, -9, 0.5, -9)}):Play()
        
        valueLabel.Text = string.format("%.2f", value)
        callback(value)
    end
    
    slider.MouseButton1Down:Connect(function()
        dragging = true
        Registry.TweenService:Create(handle, TweenInfo.new(0.1), {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(handle.Position.X.Scale, -11, 0.5, -11)}):Play()
    end)
    
    Registry.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Registry.TweenService:Create(handle, TweenInfo.new(0.1), {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(handle.Position.X.Scale, -9, 0.5, -9)}):Play()
        end
    end)
    
    Registry.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    -- Click on track to jump
    slider.MouseButton1Click:Connect(function()
        local mousePos = Registry.UserInputService:GetMouseLocation()
        updateSlider({Position = Vector2.new(mousePos.X, mousePos.Y)})
    end)
    
    -- Register for config sync
    _G.ConfigRegistry[name] = function(val)
        val = math.clamp(val, min, max)
        local relativePos = (val - min) / (max - min)
        Registry.TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.new(relativePos, 0, 1, 0)}):Play()
        Registry.TweenService:Create(handle, TweenInfo.new(0.2), {Position = UDim2.new(relativePos, -9, 0.5, -9)}):Play()
        valueLabel.Text = string.format("%.2f", val)
    end
    
    return sliderFrame
end

-- [[ FEATURE TILE COMPONENT ]]
function UI_Components.createFeatureTile(parent, name, defaultState, callback)
    local tile = Instance.new("Frame")
    tile.Size = UDim2.new(0, 140, 0, 120)
    tile.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tile.BorderSizePixel = 0
    tile.Parent = parent
    
    local tileCorner = Instance.new("UICorner")
    tileCorner.CornerRadius = UDim.new(0, 8)
    tileCorner.Parent = tile
    
    local tileStroke = Instance.new("UIStroke")
    tileStroke.Color = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
    tileStroke.Thickness = 1.5
    tileStroke.Transparency = 0.5
    tileStroke.Parent = tile
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = tile
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Position = UDim2.new(0, 0, 0.6, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = tile
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0.8, 0)
    status.BackgroundTransparency = 1
    status.Text = defaultState and "ENABLED" or "DISABLED"
    status.TextColor3 = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 9
    status.Parent = tile
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 0.5, 0)
    iconLabel.Position = UDim2.new(0, 0, 0.1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "⚙️"
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 32
    iconLabel.Parent = tile

    local state = defaultState
    local settingsContainer = getgenv().MyHubState.UI_Main.createSettingsContainer(name)
    
    local function updateTile(newState)
        state = newState
        tileStroke.Color = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
        status.Text = state and "ENABLED" or "DISABLED"
        status.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
        Registry.TweenService:Create(tile, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(22, 22, 22)}):Play()
    end
    
    button.MouseButton1Click:Connect(function()
        state = not state
        updateTile(state)
        callback(state)
        
        Registry.TweenService:Create(tile, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 135, 0, 115)}):Play()
        task.wait(0.1)
        Registry.TweenService:Create(tile, TweenInfo.new(0.1), {Size = UDim2.new(0, 140, 0, 120)}):Play()
    end)
    
    button.MouseButton2Click:Connect(function()
        getgenv().MyHubState.UI_Main.openSettings(name, settingsContainer)
    end)
    
    button.MouseEnter:Connect(function()
        Registry.TweenService:Create(tile, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        Registry.TweenService:Create(tile, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(22, 22, 22)}):Play()
    end)
    
    _G.ConfigRegistry[name] = updateTile
    return settingsContainer, iconLabel
end

return UI_Components
