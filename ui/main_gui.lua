-- [[ ACC MAIN GUI ]]
-- Core interface structure with advanced particles and page management

local Constants = require(script.Parent.Parent.core.constants)
local Components = require(script.Parent.components)
local State = Constants.State
local Services = Constants.Services

local MainGui = {}

function MainGui.initialize()
    local Gui = Instance.new("ScreenGui", Services.CoreGui)
    Gui.Name = "ACCMultihackGUI"
    Gui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame", Gui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 5)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(220, 220, 220)
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.3
    
    -- [[ PARTICLE SYSTEMS ]]
    -- Border Particles
    local borderLayer = Instance.new("Frame", MainFrame)
    borderLayer.Size = UDim2.new(1, 60, 1, 60); borderLayer.Position = UDim2.new(0, -30, 0, -30)
    borderLayer.BackgroundTransparency = 1
    
    local borderParticles = {}
    for i = 1, 22 do
        local dot = Instance.new("Frame", borderLayer)
        local size = math.random(4, 9)
        dot.Size = UDim2.new(0, size, 0, size); dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        table.insert(borderParticles, {dot = dot, t = math.random(), speed = math.random(15, 45) / 1000, size = size, pulse = math.random() * math.pi * 2})
    end
    
    -- Ambient Particles
    local ambientGui = Instance.new("ScreenGui", Services.CoreGui)
    ambientGui.DisplayOrder = -1
    
    local ambParticles = {}
    for i = 1, 45 do
        local dot = Instance.new("Frame", ambientGui)
        local size = math.random(2, 8)
        dot.Size = UDim2.new(0, size, 0, size); dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        table.insert(ambParticles, {dot = dot, px = math.random(), py = math.random(), speedY = math.random(8, 25) / 10000, speedX = math.random(-8, 8) / 10000, maxAlpha = math.random(45, 85) / 100, pulse = math.random() * math.pi * 2, sizeBase = size})
    end
    
    Services.RunService.Heartbeat:Connect(function(dt)
        if not MainFrame.Visible then ambientGui.Enabled = false; return end
        ambientGui.Enabled = true
        
        -- Update Border Particles
        local W, H = borderLayer.AbsoluteSize.X, borderLayer.AbsoluteSize.Y
        for _, p in ipairs(borderParticles) do
            p.t = (p.t + p.speed * dt) % 1
            
            local px, py
            if p.t < 0.25 then -- Top
                px = (p.t / 0.25) * W
                py = 0
            elseif p.t < 0.5 then -- Right
                px = W
                py = ((p.t - 0.25) / 0.25) * H
            elseif p.t < 0.75 then -- Bottom
                px = W - ((p.t - 0.5) / 0.25) * W
                py = H
            else -- Left
                px = 0
                py = H - ((p.t - 0.75) / 0.25) * H
            end
            
            p.dot.Position = UDim2.new(0, px, 0, py)
            local currentSize = p.size + math.sin(tick() * 2 + p.pulse) * 2
            p.dot.Size = UDim2.new(0, currentSize, 0, currentSize)
        end
        
        -- Update Ambient Particles
        for _, p in ipairs(ambParticles) do
            p.py = (p.py - p.speedY * dt * 60) % 1.1; p.px = (p.px + p.speedX * dt * 60) % 1.1
            p.dot.Position = UDim2.new(p.px, 0, p.py, 0)
            p.dot.BackgroundTransparency = 1 - (p.maxAlpha * (math.sin(tick() * 1.3 + p.pulse) + 1) / 2)
        end
    end)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 50); TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0); TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = "ACC MULTIHACK"; TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 20; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Sidebar
    local SideBar = Instance.new("Frame", MainFrame)
    SideBar.Size = UDim2.new(0, 160, 1, -50); SideBar.Position = UDim2.new(0, 0, 0, 50)
    SideBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    
    -- Content Area
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -170, 1, -60); ContentArea.Position = UDim2.new(0, 165, 0, 55)
    ContentArea.BackgroundTransparency = 1
    
    -- [[ PAGE HANDLING ]]
    local pages = {}
    local tabButtons = {}
    local activePage = nil
    
    local function createPage(name)
        local page = Instance.new("ScrollingFrame", ContentArea)
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        
        local layout = Instance.new("UIGridLayout", page)
        layout.CellSize = UDim2.new(0, 148, 0, 130)
        layout.CellPadding = UDim2.new(0, 10, 0, 10)
        
        pages[name] = page
        return page
    end
    
    local function switchTab(name)
        if activePage then activePage.Visible = false end
        if pages[name] then
            pages[name].Visible = true
            activePage = pages[name]
        end
        
        for tabName, btn in pairs(tabButtons) do
            local isSelected = (tabName == name)
            Services.TweenService:Create(btn, TweenInfo.new(0.3), {
                BackgroundColor3 = isSelected and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(18, 18, 18),
                BackgroundTransparency = isSelected and 0 or 1
            }):Play()
        end
    end
    
    -- [[ SIDEBAR TABS ]]
    local tabContainer = Instance.new("Frame", SideBar)
    tabContainer.Size = UDim2.new(1, 0, 1, 0); tabContainer.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.Padding = UDim.new(0, 5)
    
    local function createTab(name, icon)
        local btn = Instance.new("TextButton", tabContainer)
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundTransparency = 1
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.Text = icon .. "  " .. name:upper()
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        tabButtons[name] = btn
        createPage(name)
    end
    
    createTab("Aimbot", "🎯")
    createTab("Visuals", "👁️")
    createTab("Misc", "🛠️")
    createTab("Settings", "⚙️")
    
    switchTab("Aimbot")
    
    -- [[ RIGHT CLICK OVERLAY ]]
    local overlay = Instance.new("Frame", MainFrame)
    overlay.Size = UDim2.new(1, 0, 1, 0); overlay.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    overlay.BackgroundTransparency = 0.2; overlay.Visible = false; overlay.ZIndex = 10
    
    local overlayTitle = Instance.new("TextLabel", overlay)
    overlayTitle.Size = UDim2.new(1, 0, 0, 50); overlayTitle.Text = "DETAILED SETTINGS"
    overlayTitle.TextColor3 = Color3.fromRGB(255, 255, 255); overlayTitle.Font = Enum.Font.GothamBold
    overlayTitle.TextSize = 18; overlayTitle.ZIndex = 11
    
    local closeBtn = Instance.new("TextButton", overlay)
    closeBtn.Size = UDim2.new(0, 100, 0, 30); closeBtn.Position = UDim2.new(0.5, -50, 1, -50)
    closeBtn.Text = "BACK"; closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.ZIndex = 11
    closeBtn.MouseButton1Click:Connect(function() overlay.Visible = false end)
    
    -- [[ PULSE ANIMATION ]]
    task.spawn(function()
        while task.wait(0.08) do
            local alpha = 0.1 + 0.4 * ((math.sin(tick() * 1.2) + 1) / 2)
            MainStroke.Transparency = alpha
        end
    end)
    
    -- [[ TOGGLE LOGIC ]]
    Services.UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
            if MainFrame.Visible then
                Services.TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                task.wait(0.3)
                MainFrame.Visible = false
                MainFrame.Size = UDim2.new(0, 650, 0, 500)
                MainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
            else
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                Services.TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 650, 0, 500),
                    Position = UDim2.new(0.5, -325, 0.5, -250)
                }):Play()
            end
        end
    end)
    
    return MainFrame, pages, overlay
end

return MainGui
