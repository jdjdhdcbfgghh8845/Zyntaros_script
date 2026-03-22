local UI_Pages = {}
local Registry = getgenv().MyHubState.Registry
local UI_Main = getgenv().MyHubState.UI_Main
local UI_Components = getgenv().MyHubState.UI_Components
local Combat = getgenv().MyHubState.Combat
local Visuals = getgenv().MyHubState.Visuals
local Effects = getgenv().MyHubState.Effects
local World = getgenv().MyHubState.World
local Misc = getgenv().MyHubState.Misc
local Config = getgenv().MyHubState.Config

function UI_Pages.build()
    -- Create Pages
    local AimbotPage = UI_Main.createPage("Aimbot")
    local VisualsPage = UI_Main.createPage("Visuals")
    local MiscPage = UI_Main.createPage("Misc")
    local SettingsPage = UI_Main.createPage("Settings")

    -- Create Tab Buttons
    UI_Main.createTabButton("AIMBOT", "🎯", "Aimbot")
    UI_Main.createTabButton("VISUALS", "👁️", "Visuals")
    UI_Main.createTabButton("MISC", "⚙️", "Misc")
    UI_Main.createTabButton("SETTINGS", "🛠️", "Settings")

    -- Default Tab
    UI_Main.switchTab("Aimbot")

    -- [[ AIMBOT PAGE TILES ]]
    local aimbotSettings, aimbotIcon = UI_Components.createFeatureTile(AimbotPage, "Aimbot", false, function(state)
        Registry.aimbotEnabled = state
        if state then print("[AIMBOT] 🎯 Enabled") end
    end)
    aimbotIcon.Text = "🎯"
    
    UI_Components.createSection(aimbotSettings, "Aimbot Core")
    UI_Components.createSlider(aimbotSettings, "Aimbot Smoothness", 0.05, 1.0, 0.2, function(val) Registry.aimbotSmoothness = val end)
    UI_Components.createSlider(aimbotSettings, "Aimbot FOV Size", 50, 2000, 200, function(val) Registry.aimbotFOV = val end)
    UI_Components.createToggle(aimbotSettings, "Wall Check", true, function(state) Registry.wallCheckEnabled = state end)
    UI_Components.createToggle(aimbotSettings, "Team Check", true, function(state) Registry.teamCheckEnabled = state end)
    
    UI_Components.createSection(aimbotSettings, "Advanced")
    UI_Components.createToggle(aimbotSettings, "Aimbot Prediction", false, function(state) Registry.predictionEnabled = state end)
    UI_Components.createSlider(aimbotSettings, "Prediction Strength", 0.05, 0.5, 0.15, function(val) Registry.predictionMultiplier = val end)
    UI_Components.createToggle(aimbotSettings, "Auto Shoot (Aimbot)", false, function(state) Registry.aimbotAutoShoot = state end)

    local silentAimSettings, silentIcon = UI_Components.createFeatureTile(AimbotPage, "Silent Aim", false, function(state)
        Registry.silentAimEnabled = state
        if state then print("[SILENT AIM] 🔫 360° Enabled") end
    end)
    silentIcon.Text = "🔫"
    
    UI_Components.createSection(silentAimSettings, "Silent Targeting")
    UI_Components.createSlider(silentAimSettings, "Silent Hit Chance (%)", 0, 100, 100, function(val) Registry.silentAimHitChance = val end)
    UI_Components.createToggle(silentAimSettings, "Auto Shoot", false, function(state) Registry.autoShootEnabled = state end)
    UI_Components.createSlider(silentAimSettings, "Auto Fire Rate", 0.05, 1.0, 0.1, function(val) Registry.autoShootDelay = val end)

    local triggerSettings, triggerIcon = UI_Components.createFeatureTile(AimbotPage, "Trigger Bot", false, function(state)
        Registry.triggerBotEnabled = state
        if state then print("[TRIGGER BOT] 🖱️ Enabled") end
    end)
    triggerIcon.Text = "🖱️"
    
    UI_Components.createSection(triggerSettings, "Trigger Settings")
    UI_Components.createToggle(triggerSettings, "Smart Headshot", true, function(state) Registry.triggerBotSmart = state end)
    UI_Components.createSlider(triggerSettings, "Auto-Click Delay", 0.001, 0.5, 0.001, function(val) Registry.ESP_SETTINGS.TriggerDelay = val end)

    -- [[ VISUALS PAGE TILES ]]
    local espSettings, espIcon = UI_Components.createFeatureTile(VisualsPage, "ESP", true, function(state)
         Registry.espEnabled = state
         if state then Visuals.initializeESP() else for p, _ in pairs(Registry.espObjects) do Visuals.removeESP(p) end end
    end)
    espIcon.Text = "👤"
    
    UI_Components.createSection(espSettings, "ESP Options")
    UI_Components.createToggle(espSettings, "Show Names", true, function(state) Registry.ESP_SETTINGS.NameEnabled = state end)
    UI_Components.createToggle(espSettings, "Show Health", true, function(state) Registry.ESP_SETTINGS.HealthEnabled = state end)
    UI_Components.createToggle(espSettings, "Show Distance", true, function(state) Registry.ESP_SETTINGS.DistanceEnabled = state end)
    UI_Components.createToggle(espSettings, "Box Highlight", true, function(state) Registry.ESP_SETTINGS.BoxEnabled = state end)
    UI_Components.createSlider(espSettings, "Max Draw Distance", 500, 10000, 5000, function(val) Registry.ESP_SETTINGS.MaxDistance = val end)

    local skelSettings, skelIcon = UI_Components.createFeatureTile(VisualsPage, "Skeleton ESP", false, function(state)
        Registry.ESP_SETTINGS.SkeletonEnabled = state
    end)
    skelIcon.Text = "💀"

    local effectSettings, effectIcon = UI_Components.createFeatureTile(VisualsPage, "Visual Effects", false, function(state) end)
    effectIcon.Text = "✨"
    
    UI_Components.createSection(effectSettings, "World Effects")
    UI_Components.createToggle(effectSettings, "Chams", false, function(state) _G.chamsEnabled = state end)
    UI_Components.createToggle(effectSettings, "Tracers", false, function(state) _G.tracersEnabled = state end)
    UI_Components.createToggle(effectSettings, "Crosshair", false, function(state) _G.crosshairEnabled = state end)
    UI_Components.createToggle(effectSettings, "Enemy Glow", false, function(state) _G.glowEnabled = state end)

    local worldSettings, worldIcon = UI_Components.createFeatureTile(VisualsPage, "World Themes", true, function(state)
        Registry.worldVisualsEnabled = state
    end)
    worldIcon.Text = "🌌"
    
    UI_Components.createSection(worldSettings, "Theme Control")
    UI_Components.createToggle(worldSettings, "Rainbow Mode", false, function(state) _G.WorldVisuals.toggleRainbow(state) end)
    UI_Components.createToggle(worldSettings, "Speed Blur", false, function(state) _G.WorldVisuals.toggleSpeedBlur(state) end)
    UI_Components.createToggle(worldSettings, "Pulse Effect", false, function(state) _G.WorldVisuals.togglePulse(state) end)
    UI_Components.createSection(worldSettings, "Post-Processing")
    UI_Components.createSlider(worldSettings, "Bloom Intensity", 0.1, 2.0, 0.5, function(val) _G.WorldVisuals.setBloomIntensity(val) end)
    UI_Components.createSlider(worldSettings, "Fog Distance", 100, 5000, 600, function(val) _G.WorldVisuals.setFogDistance(val) end)

    -- [[ MISC PAGE TILES ]]
    local speedSettings, speedIcon = UI_Components.createFeatureTile(MiscPage, "Speed Hack", false, function(state)
        Registry.speedHackEnabled = state
        Misc.applySpeedHack()
    end)
    speedIcon.Text = "⚡"
    UI_Components.createSlider(speedSettings, "Speed Multiplier", 1, 10, 2, function(val) Registry.speedMultiplier = val end)

    local jumpSettings, jumpIcon = UI_Components.createFeatureTile(MiscPage, "Infinite Jump", false, function(state)
        Registry.infJumpEnabled = state
    end)
    jumpIcon.Text = "🦘"

    local noclipSettings, noclipIcon = UI_Components.createFeatureTile(MiscPage, "Noclip", false, function(state)
        Registry.noclipEnabled = state
    end)
    noclipIcon.Text = "👻"

    local defenseSettings, defenseIcon = UI_Components.createFeatureTile(MiscPage, "Defense", false, function(state)
        Registry.bulletDodgeEnabled = state
    end)
    defenseIcon.Text = "🛡️"
    UI_Components.createSection(defenseSettings, "Evasion")
    UI_Components.createSlider(defenseSettings, "Dodge Distance", 5, 50, 10, function(val) Registry.dodgeDistance = val end)
    UI_Components.createSlider(defenseSettings, "Dodge Intensity", 1, 5, 2, function(val) Registry.dodgeSpeed = val end)

    local camSettings, camIcon = UI_Components.createFeatureTile(MiscPage, "Camera/FOV", false, function(state)
        Registry.customFOVEnabled = state
        getgenv().MyHubState.Main_Logic.applyCameraFOV()
    end)
    camIcon.Text = "🎥"
    UI_Components.createSlider(camSettings, "Custom Field of View", 30, 120, 70, function(val) 
        Registry.customFOV = val
        getgenv().MyHubState.Main_Logic.applyCameraFOV()
    end)

    -- [[ SETTINGS PAGE TILES ]]
    local configSettings, configIcon = UI_Components.createFeatureTile(SettingsPage, "Configuration", false, function(state) end)
    configIcon.Text = "💾"
    UI_Components.createSection(configSettings, "Profiles")
    UI_Components.createToggle(configSettings, "Auto-Save on Exit", false, function(state) end)
    
    local saveBtn = UI_Components.createToggle(configSettings, "Click to SAVE Config", false, function(s) Config.saveConfig() end)
    local loadBtn = UI_Components.createToggle(configSettings, "Click to LOAD Config", false, function(s) Config.loadConfig() end)

    local infoSettings, infoIcon = UI_Components.createFeatureTile(SettingsPage, "About Hub", false, function(state) end)
    infoIcon.Text = "ℹ️"
    UI_Components.createSection(infoSettings, "Script Info")
    UI_Components.createToggle(infoSettings, "Show FPS Counter", false, function(state) end)
    
    UI_Components.createSection(infoSettings, "Keybinds")
    UI_Components.createToggle(infoSettings, "Menu Key: [INSERT]", true, function(s) end)
    UI_Components.createToggle(infoSettings, "Aimbot Key: [Z]", true, function(s) end)
    UI_Components.createToggle(infoSettings, "Trigger Key: [H]", true, function(s) end)
end

return UI_Pages
