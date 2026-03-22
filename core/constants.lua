-- [[ ACC CORE CONSTANTS ]]
-- Centralized settings, services, and shared state

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    Lighting = game:GetService("Lighting")
}

local LocalPlayer = Services.Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- [[ GLOBAL STATE ]]
local State = {
    -- Aimbot
    aimbotEnabled = false,
    aimbotSmoothness = 0.25,
    aimbotFOV = 400,
    aimbotTargetPart = "Head",
    wallCheckEnabled = true,
    teamCheckEnabled = true,
    predictionEnabled = false,
    predictionMultiplier = 1.0,
    aimbotAutoShoot = false,
    
    -- Silent Aim
    silentAimEnabled = false,
    silentAimHitChance = 100,
    autoShootEnabled = false,
    
    -- Trigger Bot
    triggerBotEnabled = false,
    triggerBotSmart = true,
    
    -- ESP / Visuals
    espEnabled = false,
    chamsEnabled = false,
    tracersEnabled = false,
    crosshairEnabled = false,
    glowEnabled = false,
    worldVisualsEnabled = true,
    rainbowEnabled = false,
    currentTheme = "Cyberpunk",
    
    -- Movement
    speedHackEnabled = false,
    speedMultiplier = 2,
    noclipEnabled = false,
    infJumpEnabled = false,
    
    -- Defense
    bulletDodgeEnabled = false,
    dodgeDistance = 20,
    dodgeSpeed = 2,
    
    -- Camera
    customFOV = 90,
    customFOVEnabled = false
}

-- [[ SHARED REGISTRY ]]
_G.ConfigRegistry = {}

-- [[ ESP SETTINGS ]]
local ESP_SETTINGS = {
    SkeletonEnabled = false,
    MaxDistance = 5000,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(0, 255, 0),
    DistanceColor = Color3.fromRGB(200, 200, 200),
    TriggerDelay = 0.01
}

-- [[ WORLD THEMES ]]
local THEMES = {
    ["Cyberpunk"] = {
        name = "🌃 Cyberpunk",
        ambient = Color3.fromRGB(50, 20, 80),
        outdoorAmbient = Color3.fromRGB(20, 50, 100),
        brightness = 1.25,
        colorShiftTop = Color3.fromRGB(255, 0, 255),
        colorShiftBottom = Color3.fromRGB(0, 255, 255),
        fogColor = Color3.fromRGB(50, 0, 80),
        fogEnd = 600,
        bloomIntensity = 0.5,
        bloomSize = 30
    },
    ["Neon"] = {
        name = "💜 Neon Dreams",
        ambient = Color3.fromRGB(80, 0, 150),
        outdoorAmbient = Color3.fromRGB(150, 0, 80),
        brightness = 1.3,
        colorShiftTop = Color3.fromRGB(255, 100, 255),
        colorShiftBottom = Color3.fromRGB(100, 255, 255),
        fogColor = Color3.fromRGB(100, 0, 100),
        fogEnd = 400,
        bloomIntensity = 0.6,
        bloomSize = 40
    },
    ["Sunset"] = {
        name = "🌅 Sunset Vibes",
        ambient = Color3.fromRGB(150, 80, 30),
        outdoorAmbient = Color3.fromRGB(150, 50, 50),
        brightness = 1.2,
        colorShiftTop = Color3.fromRGB(255, 200, 100),
        colorShiftBottom = Color3.fromRGB(255, 100, 150),
        fogColor = Color3.fromRGB(150, 80, 50),
        fogEnd = 1000,
        bloomIntensity = 0.4,
        bloomSize = 25
    },
    ["Hell"] = {
        name = "🔥 Hell Fire",
        ambient = Color3.fromRGB(80, 0, 0),
        outdoorAmbient = Color3.fromRGB(100, 30, 0),
        brightness = 1.2,
        colorShiftTop = Color3.fromRGB(255, 80, 0),
        colorShiftBottom = Color3.fromRGB(255, 0, 0),
        fogColor = Color3.fromRGB(80, 0, 0),
        fogEnd = 300,
        bloomIntensity = 0.8,
        bloomSize = 45
    },
    ["Rainbow"] = {
        name = "🌈 Rainbow",
        dynamic = true
    }
}

return {
    Services = Services,
    LocalPlayer = LocalPlayer,
    mouse = mouse,
    State = State,
    ESP_SETTINGS = ESP_SETTINGS,
    THEMES = THEMES
}
