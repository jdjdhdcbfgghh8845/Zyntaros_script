local UI_Main = {}
local Registry = getgenv().MyHubState.Registry

-- [[ BEAUTIFUL MODERN GUI MENU ]]
-- Full control panel with animations and gradients

UI_Main.MainGui = Instance.new("ScreenGui")
UI_Main.MainGui.Name = "MultihackGUI"
UI_Main.MainGui.ResetOnSpawn = false
UI_Main.MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI_Main.MainGui.Parent = Registry.CoreGui

-- Main Frame with shadow (LARGER FOR TABS)
UI_Main.MainFrame = Instance.new("Frame")
UI_Main.MainFrame.Name = "MainFrame"
UI_Main.MainFrame.Size = UDim2.new(0, 650, 0, 500)
UI_Main.MainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
UI_Main.MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
UI_Main.MainFrame.BorderSizePixel = 0
UI_Main.MainFrame.Visible = false
UI_Main.MainFrame.ClipsDescendants = true
UI_Main.MainFrame.Parent = UI_Main.MainGui

-- State Tracking
UI_Main.pages = {}
UI_Main.currentTab = nil

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 5)
MainCorner.Parent = UI_Main.MainFrame

-- White stroke effect
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(220, 220, 220)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = UI_Main.MainFrame

-- Subtle dark gradient overlay
local GradientOverlay = Instance.new("Frame")
GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
GradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GradientOverlay.BackgroundTransparency = 0.97
GradientOverlay.BorderSizePixel = 0
GradientOverlay.Parent = UI_Main.MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
}
Gradient.Rotation = 135
Gradient.Parent = GradientOverlay

local GradientCorner = Instance.new("UICorner")
GradientCorner.CornerRadius = UDim.new(0, 5)
GradientCorner.Parent = GradientOverlay

--[[
    PARTICLE SYSTEM
    Animated glowing white orbs floating around the panel border
]]
local particleGui = Instance.new("Frame")
particleGui.Name = "ParticleLayer"
particleGui.Size = UDim2.new(1, 60, 1, 60)
particleGui.Position = UDim2.new(0, -30, 0, -30)
particleGui.BackgroundTransparency = 1
particleGui.ClipsDescendants = false
particleGui.ZIndex = 0
particleGui.Parent = UI_Main.MainFrame

local PARTICLE_COUNT = 22
local particleData = {}

local function createParticle()
    local dot = Instance.new("Frame")
    local size = math.random(4, 9)
    dot.Size = UDim2.new(0, size, 0, size)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BackgroundTransparency = math.random(20, 60) / 100
    dot.BorderSizePixel = 0
    dot.ZIndex = 0
    dot.ClipsDescendants = false
    dot.Parent = particleGui
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot
    -- random starting position on border path (0..1 = perimeter fraction)
    local t = math.random() 
    local speed = math.random(15, 45) / 1000 -- fraction of border per tick
    local pulseOffset = math.random() * math.pi * 2
    table.insert(particleData, {dot = dot, t = t, speed = speed, size = size, pulse = pulseOffset})
end

for i = 1, PARTICLE_COUNT do createParticle() end

-- Perimeter path: fraction 0..1 maps around the rounded rect border
local function perimeterPos(frac, W, H)
    local perimeter = 2 * (W + H)
    local dist = frac * perimeter
    if dist < W then
        return dist, 0
    elseif dist < W + H then
        return W, dist - W
    elseif dist < 2*W + H then
        return W - (dist - W - H), H
    else
        return 0, H - (dist - 2*W - H)
    end
end

Registry.RunService.Heartbeat:Connect(function(dt)
    if not UI_Main.MainFrame.Visible then return end
    local W = particleGui.AbsoluteSize.X
    local H = particleGui.AbsoluteSize.Y
    if W == 0 then return end
    local t0 = tick()
    for _, p in ipairs(particleData) do
        p.t = (p.t + p.speed * dt) % 1
        local px, py = perimeterPos(p.t, W, H)
        p.dot.Position = UDim2.new(0, px - p.size/2, 0, py - p.size/2)
        -- Pulsing alpha
        local alpha = 0.2 + 0.6 * ((math.sin(t0 * 2 + p.pulse) + 1) / 2)
        p.dot.BackgroundTransparency = alpha
    end
end)

--[[
    AMBIENT SCREEN PARTICLES
    Floating white glowing orbs drift across the full screen while menu is open
]]
local ambientGui = Instance.new("ScreenGui")
ambientGui.Name = "AmbientParticles"
ambientGui.ResetOnSpawn = false
ambientGui.DisplayOrder = -1  -- behind GUI but above game
ambientGui.Parent = Registry.CoreGui

local AMB_COUNT = 45
local ambParticles = {}

local function spawnAmbientParticle(randomPos)
    local size = math.random(2, 8)
    local dot = Instance.new("Frame")
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Size = UDim2.new(0, size, 0, size)
    -- Start at random position or bottom spawn
    local startX = math.random(0, 1000) / 1000
    local startY = randomPos and (math.random(0, 1000) / 1000) or 1.05
    dot.Position = UDim2.new(startX, 0, startY, 0)
    dot.BackgroundTransparency = 1  -- start hidden, loop will reveal
    dot.ZIndex = 1
    dot.Parent = ambientGui

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    -- randomised per-particle properties
    local speedY   = math.random(8,  25) / 10000   -- fraction/tick upward
    local speedX   = (math.random(-8, 8)) / 10000  -- slight horizontal drift
    local maxAlpha = math.random(45, 85) / 100     -- max opacity (subtle)
    local pulseOff = math.random() * math.pi * 2
    local sizeBase = size
    local px = startX
    local py = startY

    table.insert(ambParticles, {
        dot      = dot,
        px       = px,
        py       = py,
        speedY   = speedY,
        speedX   = speedX,
        maxAlpha = maxAlpha,
        pulse    = pulseOff,
        sizeBase = sizeBase,
    })
end

-- Spawn all particles at random positions on the screen
for i = 1, AMB_COUNT do
    spawnAmbientParticle(true)
end

-- Heartbeat: move and pulse ambient particles
Registry.RunService.Heartbeat:Connect(function(dt)
    if not UI_Main.MainFrame.Visible then
        -- Hide all when menu is closed
        ambientGui.Enabled = false
        return
    end
    ambientGui.Enabled = true

    local t0 = tick()
    for _, p in ipairs(ambParticles) do
        -- Move
        p.py = p.py - p.speedY * dt * 60
        p.px = p.px + p.speedX * dt * 60

        -- Wrap around edges
        if p.py < -0.05 then
            p.py = 1.05
            p.px = math.random(0, 1000) / 1000
        end
        if p.px < -0.02 then p.px = 1.02 end
        if p.px >  1.02 then p.px = -0.02 end

        p.dot.Position = UDim2.new(p.px, 0, p.py, 0)

        -- Pulse opacity (slow breathing)
        local wave = (math.sin(t0 * 1.3 + p.pulse) + 1) / 2
        local transparency = 1 - (p.maxAlpha * wave)
        p.dot.BackgroundTransparency = transparency

        -- Subtle size breathing (±1 px)
        local sizeWave = p.sizeBase + math.floor(((math.sin(t0 * 0.9 + p.pulse) + 1) / 2) * 2)
        p.dot.Size = UDim2.new(0, sizeWave, 0, sizeWave)
    end
end)

-- Title Bar (black monochrome)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = UI_Main.MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 5)
TitleCorner.Parent = TitleBar

-- Title Label with glow
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ULTIMATE MULTIHACK"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Color3.fromRGB(255, 255, 255)
TitleStroke.Thickness = 1
TitleStroke.Transparency = 0.7
TitleStroke.Parent = TitleLabel

-- Version label
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 100, 0, 15)
VersionLabel.Position = UDim2.new(0, 15, 1, -20)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v2.3 OPTIMIZED"
VersionLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
VersionLabel.Font = Enum.Font.GothamBold
VersionLabel.TextSize = 10
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.Parent = TitleBar

-- Sidebar for Tabs (dark)
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 160, 1, -50)
SideBar.Position = UDim2.new(0, 0, 0, 50)
SideBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
SideBar.BorderSizePixel = 0
SideBar.Parent = UI_Main.MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 5)
SideCorner.Parent = SideBar

-- Hide bottom right corner of sidebar to blend with MainFrame
local SideHide = Instance.new("Frame")
SideHide.Size = UDim2.new(0, 20, 0, 20)
SideHide.Position = UDim2.new(1, -20, 1, -20)
SideHide.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
SideHide.BorderSizePixel = 0
SideHide.Parent = SideBar

-- Content Area for Pages
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -170, 1, -60)
ContentArea.Position = UDim2.new(0, 165, 0, 55)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = UI_Main.MainFrame

-- [[ SETTINGS OVERLAY SYSTEM ]]
UI_Main.SettingsOverlay = Instance.new("Frame")
UI_Main.SettingsOverlay.Name = "SettingsOverlay"
UI_Main.SettingsOverlay.Size = UDim2.new(1, -10, 1, -10)
UI_Main.SettingsOverlay.Position = UDim2.new(0, 5, 0, 5)
UI_Main.SettingsOverlay.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
UI_Main.SettingsOverlay.BackgroundTransparency = 0.05
UI_Main.SettingsOverlay.BorderSizePixel = 0
UI_Main.SettingsOverlay.Visible = false
UI_Main.SettingsOverlay.ZIndex = 50
UI_Main.SettingsOverlay.Parent = ContentArea

local OverlayCorner = Instance.new("UICorner")
OverlayCorner.CornerRadius = UDim.new(0, 6)
OverlayCorner.Parent = UI_Main.SettingsOverlay

local OverlayStroke = Instance.new("UIStroke")
OverlayStroke.Color = Color3.fromRGB(255, 255, 255)
OverlayStroke.Thickness = 1.5
OverlayStroke.Transparency = 0.5
OverlayStroke.Parent = UI_Main.SettingsOverlay

UI_Main.OverlayTitle = Instance.new("TextLabel")
UI_Main.OverlayTitle.Size = UDim2.new(1, -80, 0, 40)
UI_Main.OverlayTitle.Position = UDim2.new(0, 15, 0, 10)
UI_Main.OverlayTitle.BackgroundTransparency = 1
UI_Main.OverlayTitle.ZIndex = 51
UI_Main.OverlayTitle.Text = "FEATURE SETTINGS"
UI_Main.OverlayTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
UI_Main.OverlayTitle.Font = Enum.Font.GothamBold
UI_Main.OverlayTitle.TextSize = 18
UI_Main.OverlayTitle.TextXAlignment = Enum.TextXAlignment.Left
UI_Main.OverlayTitle.Parent = UI_Main.SettingsOverlay

local BackButton = Instance.new("TextButton")
BackButton.Size = UDim2.new(0, 70, 0, 30)
BackButton.Position = UDim2.new(1, -85, 0, 15)
BackButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BackButton.ZIndex = 51
BackButton.Text = "< BACK"
BackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BackButton.Font = Enum.Font.GothamBold
BackButton.TextSize = 12
BackButton.AutoButtonColor = false
BackButton.Parent = UI_Main.SettingsOverlay

local BackCorner = Instance.new("UICorner")
BackCorner.CornerRadius = UDim.new(0, 4)
BackCorner.Parent = BackButton

BackButton.MouseButton1Click:Connect(function()
    UI_Main.SettingsOverlay.Visible = false
    -- Show the current page again
    if UI_Main.currentTab and UI_Main.pages[UI_Main.currentTab] then
        UI_Main.pages[UI_Main.currentTab].Visible = true
    end
    for _, child in pairs(UI_Main.SettingsOverlay:GetChildren()) do
        if child:IsA("ScrollingFrame") then child.Visible = false end
    end
end)

function UI_Main.createSettingsContainer(name)
    local container = Instance.new("ScrollingFrame")
    container.Name = name .. "Settings"
    container.Size = UDim2.new(1, -20, 1, -60)
    container.Position = UDim2.new(0, 10, 0, 55)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 2
    container.ZIndex = 51
    container.Visible = false
    container.Parent = UI_Main.SettingsOverlay
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    return container
end

function UI_Main.openSettings(name, container)
    UI_Main.OverlayTitle.Text = name:upper() .. " SETTINGS"
    
    -- Hide the current page to avoid overlap
    if UI_Main.currentTab and UI_Main.pages[UI_Main.currentTab] then
        UI_Main.pages[UI_Main.currentTab].Visible = false
    end
    
    UI_Main.SettingsOverlay.Visible = true
    container.Visible = true
    for _, child in pairs(UI_Main.SettingsOverlay:GetChildren()) do
        if child:IsA("ScrollingFrame") and child ~= container then child.Visible = false end
    end
end

-- Page Creation Helper
function UI_Main.createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = ContentArea
    
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 148, 0, 130)
    layout.CellPadding = UDim2.new(0, 10, 0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    UI_Main.pages[name] = page
    return page
end

-- Tab Buttons logic
function UI_Main.switchTab(name)
    if UI_Main.currentTab == name then return end
    
    UI_Main.SettingsOverlay.Visible = false
    for tabName, page in pairs(UI_Main.pages) do
        page.Visible = (tabName == name)
    end
    
    UI_Main.currentTab = name
end

UI_Main.tabY = 10
function UI_Main.createTabButton(name, icon, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, UI_Main.tabY)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = SideBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(220, 220, 220)
    btnStroke.Thickness = 0
    btnStroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        UI_Main.switchTab(pageName)
        
        -- Reset all buttons
        for _, child in pairs(SideBar:GetChildren()) do
            if child:IsA("TextButton") then
                Registry.TweenService:Create(child, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(28, 28, 28), TextColor3 = Color3.fromRGB(160, 160, 160)}):Play()
                if child:FindFirstChild("UIStroke") then child.UIStroke.Thickness = 0 end
            end
        end
        
        -- Highlight current (white accent)
        Registry.TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        btnStroke.Thickness = 1.5
    end)
    
    UI_Main.tabY = UI_Main.tabY + 50
    return btn
end

-- Close Button (monochrome)
UI_Main.CloseButton = Instance.new("TextButton")
UI_Main.CloseButton.Size = UDim2.new(0, 35, 0, 35)
UI_Main.CloseButton.Position = UDim2.new(1, -45, 0, 7.5)
UI_Main.CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
UI_Main.CloseButton.Text = "✕"
UI_Main.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UI_Main.CloseButton.Font = Enum.Font.GothamBold
UI_Main.CloseButton.TextSize = 18
UI_Main.CloseButton.AutoButtonColor = false
UI_Main.CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = UI_Main.CloseButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(255, 255, 255)
CloseStroke.Thickness = 1.5
CloseStroke.Transparency = 0.6
CloseStroke.Parent = UI_Main.CloseButton

-- Close button hover effect (white flash)
UI_Main.CloseButton.MouseEnter:Connect(function()
    Registry.TweenService:Create(UI_Main.CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
    Registry.TweenService:Create(UI_Main.CloseButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 38, 0, 38)}):Play()
end)
UI_Main.CloseButton.MouseLeave:Connect(function()
    Registry.TweenService:Create(UI_Main.CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    Registry.TweenService:Create(UI_Main.CloseButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 35, 0, 35)}):Play()
end)

-- Draggable GUI logic
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    UI_Main.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = UI_Main.MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

Registry.UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Subtle title shimmer animation (monochrome)
spawn(function()
    while wait(0.08) do
        -- Gently pulse the MainStroke transparency for glow effect
        local alpha = 0.1 + 0.4 * ((math.sin(tick() * 1.2) + 1) / 2)
        MainStroke.Transparency = alpha
    end
end)

-- Close button functionality with animation
UI_Main.CloseButton.MouseButton1Click:Connect(function()
    Registry.TweenService:Create(UI_Main.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    wait(0.3)
    UI_Main.MainFrame.Visible = false
    UI_Main.MainFrame.Size = UDim2.new(0, 650, 0, 500)
    UI_Main.MainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
end)

return UI_Main
