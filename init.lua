-- [[ ACC MULTIHACK - PREMIUM EDITION v2.4.0-PRO ]]
-- Main entry point connecting all modular parts with 100% absolute parity

local Constants = require(script.core.constants)
local Utils = require(script.utils.utils)
local ESP = require(script.modules.esp)
local Aimbot = require(script.modules.aimbot)
local SilentAim = require(script.modules.silent_aim)
local Movement = require(script.modules.movement)
local Defense = require(script.modules.defense)
local Visuals = require(script.modules.visuals)
local MainGui = require(script.ui.main_gui)
local Config    = require(script.config.config)

local Services = Constants.Services
local State = Constants.State

-- [[ BOOTSTRAP ]]
local function bootstrap()
    -- Initialize Modules
    ESP.initialize()
    Aimbot.initialize()
    SilentAim.initialize()
    Movement.initialize()
    Defense.initialize()
    Visuals.initialize()
    
    -- Initialize GUI
    local mainFrame, pages, overlay = MainGui.initialize()
    
    -- Load Pages
    require(script.ui.pages.aimbot).render(pages["Aimbot"])
    require(script.ui.pages.visuals).render(pages["Visuals"])
    require(script.ui.pages.misc).render(pages["Misc"])
    require(script.ui.pages.settings).render(pages["Settings"])

    -- Auto-load config if exists (Exact parity from old/lua.lua:3132)
    task.spawn(function()
        task.wait(0.5)
        Config.loadConfig()
    end)
    
    -- Welcome notification (Exact parity from old/lua.lua:3147)
    task.spawn(function()
        task.wait(1)
        local notification = Instance.new("ScreenGui", Services.CoreGui)
        notification.Name = "WelcomeNotif"
        
        local notifFrame = Instance.new("Frame", notification)
        notifFrame.Size = UDim2.new(0, 350, 0, 80); notifFrame.Position = UDim2.new(0.5, -175, 0, -100)
        notifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", notifFrame)
        local stroke = Instance.new("UIStroke", notifFrame)
        stroke.Color = Color3.fromRGB(220, 220, 220); stroke.Thickness = 1.5; stroke.Transparency = 0.3
        
        local notifText = Instance.new("TextLabel", notifFrame)
        notifText.Size = UDim2.new(1, -20, 1, -20); notifText.Position = UDim2.new(0, 10, 0, 10)
        notifText.BackgroundTransparency = 1; notifText.Text = "MULTIHACK LOADED\nPress INSERT to open menu"
        notifText.Font = Enum.Font.GothamBold; notifText.TextSize = 16; notifText.TextColor3 = Color3.fromRGB(240, 240, 240)
        
        Services.TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -175, 0, 20)}):Play()
        task.wait(4)
        Services.TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -175, 0, -100)}):Play()
        task.wait(0.5); notification:Destroy()
    end)

    -- Final Print Statements (Exact parity from old/lua.lua:3097-3129)
    print("\n")
    print("╔══════════════════════════════════════════════╗")
    print("║  ⚡ ULTIMATE MULTIHACK v2.3 OPTIMIZED ⚡     ║")
    print("╠══════════════════════════════════════════════╣")
    print("║                                              ║")
    print("║  ✨ Features Loaded:                         ║")
    print("║  📦 ESP - 60 FPS Optimized                  ║")
    print("║  🎯 TRIGGER BOT - ULTRA FAST (0.001s)       ║")
    print("║  🔫 AIMBOT - 120 FPS Smooth Aim             ║")
    print("║  ⚡ SILENT AIM + AUTO SHOOT - 360°          ║")
    print("║  🚀 BULLET DODGE - Matrix Mode              ║")
    print("║  🏃 SPEED HACK - Up to 10x Speed!           ║")
    print("║  💾 CONFIG MANAGER - Save & Share!          ║")
    print("║  📷 CAMERA FOV - Custom Zoom (30-120)       ║")
    print("║  🎨 BEAUTIFUL GUI - Animated Interface      ║")
    print("║                                              ║")
    print("║  ⚡ PERFORMANCE BOOST: +30-50% FPS!         ║")
    print("║                                              ║")
    print("║  ⌨️  Controls:                               ║")
    print("║  INSERT / RSHIFT - Toggle GUI Menu          ║")
    print("║  H - Quick Trigger Toggle                   ║")
    print("║                                              ║")
    print("║  🛡️  Team Check - Won't target teammates    ║")
    print("║  💎 Premium Edition with TweenService       ║")
    print("║  🌟 Made for Synapse X / KRNL              ║")
    print("║                                              ║")
    print("║  💾 Config File: MultihackConfig.json       ║")
    print("╚══════════════════════════════════════════════╝")
    print("\n✅ All systems operational! Press INSERT or RSHIFT to begin.")
    print("💡 TIP: Use Save/Load Config to share settings!")
    print("⚡ OPTIMIZED: Dual-loop system for maximum performance!\n")
end

bootstrap()
