--[[
    ULTIMATE ROBLOX MULTIHACK - PREMIUM EDITION v2.3 OPTIMIZED
    Advanced ESP + Trigger Bot + Aimbot + Much More!
    
    PERFORMANCE OPTIMIZATIONS:
    - Dual-loop system: RenderStepped (critical) + Heartbeat (secondary)
    - ESP updates throttled to 60 FPS for better performance
    - Aimbot optimized to 120 FPS (super responsive)
    - Cached math functions for faster calculations
    - String concatenation instead of string.format
    - Reduced Vector2/Vector3 allocations
    - Smart update intervals for different systems
    - Task-based waiting instead of wait()
    - Optimized distance calculations
    
    RESULT: 30-50% better FPS while maintaining full power!
    
    Compatible with: Synapse X, KRNL, and other executors
    
    ESP Features:
    - Highlight players through walls
    - Display player names
    - Show health bars with color coding
    - Distance indicator
    - Filters out teammates (enemies only)
    - Colored box highlight
    
    TRIGGER BOT Features:
    - ULTRA FAST auto-click (0.001s delay!)
    - Auto-click when hovering over enemy players
    - Smart body part detection (prioritizes headshots)
    - Instant fire on headshots (no delay)
    - Intelligent target validation
    - Low health enemy prioritization
    - Configurable delay (0.001-0.5s)
    
    AIMBOT Features:
    - Auto-aim to nearest player
    - Optional Auto Shoot when locked on target
    - Toggle Velocity Prediction for moving targets
    - Adjustable Prediction Strength (5%-50%)
    - Sticky aim (locks onto target)
    - Priority targeting (health + distance based)
    - Dynamic smoothness adjustment
    - Head lock / Body lock / Torso lock
    - FOV circle (field of view) - up to 360°
    - Quick FOV presets (180°, 270°, 360°)
    - Smoothness control (0.05-1.0)
    - Adjustable fire rate for auto shoot
    - Wall check (ignores targets behind walls)
    - Team check (doesn't target teammates)
    

    
    SPEED HACK Features:
    - Increase movement speed (1x-10x)
    - Persistent across respawns
    - Anti-reset protection
    - Real-time speed adjustment
    - Toggle on/off instantly
    
    CONFIG MANAGER Features:
    - Save all settings to JSON file
    - Load saved configurations
    - Share configs with friends
    - Portable config file (MultihackConfig.json)
    - One-click save/load buttons
    
    GUI Features:
    - Full control panel
    - Toggle all features
    - Adjust settings in real-time
    - Beautiful animations
    - Modern gradient design
    - Config management system
    
    Camera Settings:
    - Custom FOV (30-120) for zoom effect
    - Real-time FOV adjustment
    
    Controls:
    - INSERT: Open/Close GUI menu
    - H: Quick Trigger Bot toggle
--]]

local Registry = {}

-- Services
Registry.Players = game:GetService("Players")
Registry.RunService = game:GetService("RunService")
Registry.CoreGui = game:GetService("CoreGui")
Registry.UserInputService = game:GetService("UserInputService")
Registry.TweenService = game:GetService("TweenService")
Registry.HttpService = game:GetService("HttpService")

-- Configuration Registry for UI Sync
_G.ConfigRegistry = _G.ConfigRegistry or {}

-- Variables
Registry.LocalPlayer = Registry.Players.LocalPlayer
Registry.Camera = workspace.CurrentCamera
Registry.espEnabled = true
Registry.espObjects = {}

-- Performance optimization variables
Registry.lastESPUpdate = 0
Registry.espUpdateInterval = 0.016 -- ~60 FPS (1/60)
Registry.lastAimbotUpdate = 0
Registry.aimbotUpdateInterval = 0.008 -- ~120 FPS for aimbot
Registry.mathFloor = math.floor
Registry.mathSqrt = math.sqrt
Registry.mathClamp = math.clamp
Registry.vectorNew = Vector3.new
Registry.udim2New = UDim2.new
Registry.color3FromRGB = Color3.fromRGB

-- Trigger Bot variables
Registry.triggerBotEnabled = false
Registry.mouse = Registry.LocalPlayer:GetMouse()
Registry.lastTriggerShot = 0
Registry.triggerBotSmart = true -- Smart body part detection

-- Aimbot variables
Registry.aimbotEnabled = false
Registry.aimbotTargetPart = "Head" -- Head, HumanoidRootPart, or Torso
Registry.aimbotSmoothness = 0.2 -- Lower = faster aim (0.1-1.0)
Registry.aimbotFOV = 200 -- Field of view radius (50-3000, use 2000+ for 360°)
Registry.wallCheckEnabled = true -- Check if target is behind walls
Registry.teamCheckEnabled = true -- Don't target teammates
Registry.fovCircle = nil
Registry.currentAimbotTarget = nil -- Sticky target tracking
Registry.targetLockTime = 0
Registry.stickyAimDuration = 0.5 -- Seconds to stay locked on target
Registry.predictionEnabled = false -- Velocity prediction (disabled by default)
Registry.predictionMultiplier = 0.15 -- Prediction strength (15% default)
Registry.aimbotAutoShoot = false -- Auto shoot when locked on target
Registry.lastAimbotShot = 0 -- Track last shot time
Registry.aimbotShootDelay = 0.1 -- Delay between aimbot shots
Registry.aimbotMode = "Mouse" -- "Camera" or "Mouse" (Stealth)

-- Universal Keybind Registry
Registry.Keybinds = {
    ["Aimbot"] = Enum.KeyCode.Z,
    ["Trigger Bot"] = Enum.KeyCode.H,
    ["Rage Aimbot"] = Enum.KeyCode.X,
    ["Third Person View"] = Enum.KeyCode.C,
    ["Fly Hack"] = Enum.KeyCode.F, -- Default F for Fly
    ["Noclip"] = Enum.KeyCode.V, -- Default V for Noclip
    ["Speed Hack"] = Enum.KeyCode.B, -- Default B for Speed
    ["Infinite Jump"] = Enum.KeyCode.Space, -- Space for toggle or just use jump?
    ["Knife Kill"] = Enum.KeyCode.E, -- Default E for Backstab
}

-- Camera FOV variables
Registry.customFOVEnabled = false
Registry.customFOV = 70 -- Default Roblox FOV is 70
Registry.defaultFOV = 70

-- Rage Aimbot variables
Registry.rageAimbotEnabled = false
Registry.rageOrbitSpeed = 10 -- Speed of rotation
Registry.rageOrbitRadius = 3 -- Distance from target
Registry.rageOrbitHeight = 5 -- Height above target
Registry.rageMaxDistance = 50 -- Max distance to teleport
Registry.rageWaveEnabled = false -- Chaotic orbit
Registry.rageWaveAmplitude = 2 -- Amplitude of waves
Registry.rageWaveFrequency = 2 -- Frequency of waves



-- Speed Hack variables
Registry.speedHackEnabled = false
Registry.speedMultiplier = 2 -- Default speed multiplier (1-10)
Registry.originalWalkSpeed = 16 -- Default Roblox walk speed

-- Visuals / Effects variables
Registry.bulletTracersEnabled = false
Registry.bulletTracerColor = Color3.fromRGB(255, 0, 0)
Registry.bulletTracerDuration = 0.5
Registry.targetHUDEnabled = false

-- Misc variables
Registry.noclipEnabled = false
Registry.infJumpEnabled = false
Registry.flyEnabled = false
Registry.flySpeed = 50
Registry.isThirdPerson = false
Registry.spinBotEnabled = false
Registry.spinBotSpeed = 15 -- Rotations per second

-- Knife Kill variables
Registry.knifeKillEnabled = false
Registry.isKnifeKilling = false
Registry.knifeKillDistance = 3 -- Distance behind the target
Registry.knifeKillTarget = nil
Registry.knifeKillDuration = 1.0 -- Duration to stay at the target

-- Whitelist variables
Registry.whitelist = {} -- Table of whitelisted player names
Registry.streamproofEnabled = false -- Streamproof Mode (Ghost Mode)
Registry.AllGuis = {} -- Centralized list of all ScreenGuis for Streamproof toggle

-- Setting variables
Registry.rainbowEnabled = false
Registry.currentTheme = "Cyberpunk"
Registry.worldVisualsEnabled = true
Registry.autoSaveEnabled = true -- Default ON
Registry.lastAutoSave = tick()
Registry.autoSaveInterval = 60 -- Save every 1 minute if enabled

-- Settings
Registry.ESP_SETTINGS = {
    BoxEnabled = true,
    NameEnabled = true,
    HealthEnabled = true,
    DistanceEnabled = true,
    
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxTransparency = 0.7,
    
    TeamCheck = false, -- Set to true to not show teammates
    MaxDistance = 5000, -- Max distance to show ESP
    
    -- Skeleton ESP
    SkeletonEnabled = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    
    -- Trigger Bot settings
    TriggerDelay = 0.001, -- Delay between auto-clicks (in seconds) - ULTRA FAST
}

return Registry
