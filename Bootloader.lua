-- [[ MULTIHACK BOOTLOADER ]]
-- Modular system with HTTP loading capability

local HUB_VERSION = "2.3.1-Modular"
local BASE_URL = "https://raw.githubusercontent.com/jdjdhdcbfgghh8845/Zyntaros_script/refs/heads/main/" -- GitHub hosting URL

-- Global State Container
getgenv().MyHubState = getgenv().MyHubState or {}

local function loadModule(name)
    print("[BOOT] Loading module: " .. name)
    
    -- Local development loading (use this if testing locally)
    local success, result = pcall(function()
        return loadfile("c:\\Users\\JDH\\Desktop\\original\\justdoit\\ACC\\" .. name .. ".lua")()
    end)
    
    -- HTTP Fallback loading (for actual use)
    if not success then
        local httpSuccess, httpResult = pcall(function()
            local url = BASE_URL .. name .. ".lua"
            return loadstring(game:HttpGet(url))()
        end)
        
        if httpSuccess then
            getgenv().MyHubState[name] = httpResult
            return httpResult
        else
            warn("[BOOT] CRITICAL ERROR: Failed to load module " .. name .. ": " .. tostring(httpResult))
            return nil
        end
    end
    
    getgenv().MyHubState[name] = result
    return result
end

-- 1. Load Core Modules (Order matters)
local Registry = loadModule("Registry")
local Utils = loadModule("Utils")
local Config = loadModule("Config")

-- 2. Load Feature Modules
local Combat = loadModule("Combat")
local Visuals = loadModule("Visuals")
local Effects = loadModule("Effects")
local World = loadModule("World")
local Misc = loadModule("Misc")

-- 3. Load UI Modules
local UI_Main = loadModule("UI_Main")
local UI_Components = loadModule("UI_Components")
local UI_Pages = loadModule("UI_Pages")

-- 4. Load Logic Module
local Main_Logic = loadModule("Main_Logic")

-- [[ INITIALIZATION ]]

-- Initialize Draw FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 460
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.Color = Color3.fromRGB(220, 220, 220)
fovCircle.Visible = false
getgenv().MyHubState.fovCircle = fovCircle

-- Build UI
UI_Pages.build()

-- Connect Events and Loops
Main_Logic.installBypasses()
Main_Logic.connectEvents()
Main_Logic.startLoops()
World.initializeWorldVisuals()

-- Initial ESP Scan
if Registry.espEnabled then
    Visuals.initializeESP()
end

-- GUI Toggle Command
Registry.UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
            UI_Main.MainFrame.Visible = not UI_Main.MainFrame.Visible
            if UI_Main.MainFrame.Visible then
                -- Opening animation
                UI_Main.MainFrame.Size = UDim2.new(0, 0, 0, 0)
                UI_Main.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                Registry.TweenService:Create(UI_Main.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 650, 0, 500),
                    Position = UDim2.new(0.5, -325, 0.5, -250)
                }):Play()
            end
        elseif input.KeyCode == Enum.KeyCode.H then
            -- Quick Trigger Bot toggle
            Registry.triggerBotEnabled = not Registry.triggerBotEnabled
            local updateFunc = _G.ConfigRegistry["Trigger Bot"]
            if updateFunc then updateFunc(Registry.triggerBotEnabled) end
            print("[TRIGGER BOT] Toggle via H -> " .. (Registry.triggerBotEnabled and "ON" or "OFF"))
        elseif input.KeyCode == Enum.KeyCode.Z then
            -- Quick Aimbot toggle
            Registry.aimbotEnabled = not Registry.aimbotEnabled
            local updateFunc = _G.ConfigRegistry["Aimbot"]
            if updateFunc then updateFunc(Registry.aimbotEnabled) end
            print("[AIMBOT] Toggle via Z -> " .. (Registry.aimbotEnabled and "ON" or "OFF"))
        end
    end
end)

print([[
========================================
   ULTIMATE MULTIHACK LOADED!
   Version: ]] .. HUB_VERSION .. [[
   
   [INSERT] - Toggle Menu
   [H] - Quick Trigger
   [Z] - Quick Aimbot
========================================
]])

-- Tips for User
task.spawn(function()
    wait(2)
    print("💡 TIP: Right-click on feature tiles to access detailed settings!")
end)

return "SUCCESS"
