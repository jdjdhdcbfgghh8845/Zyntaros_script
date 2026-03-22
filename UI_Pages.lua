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
    local ExceptionsPage = UI_Main.createPage("Exceptions")
    local SettingsPage = UI_Main.createPage("Settings")

    -- Create Tab Buttons
    UI_Main.createTabButton("AIMBOT", "🎯", "Aimbot")
    UI_Main.createTabButton("VISUALS", "👁️", "Visuals")
    UI_Main.createTabButton("MISC", "⚙️", "Misc")
    UI_Main.createTabButton("EXCEPTIONS", "🛡️", "Exceptions")
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
    
    local rageSettings, rageIcon = UI_Components.createFeatureTile(AimbotPage, "Rage Aimbot", false, function(state)
        Registry.rageAimbotEnabled = state
        if state then print("[RAGE AIMBOT] 🌪️ Enabled") end
    end)
    rageIcon.Text = "🌪️"
    
    UI_Components.createSection(rageSettings, "Orbit Configuration")
    UI_Components.createSlider(rageSettings, "Orbit Speed", 1, 50, 10, function(val) Registry.rageOrbitSpeed = val end)
    UI_Components.createSlider(rageSettings, "Orbit Radius", 1, 20, 3, function(val) Registry.rageOrbitRadius = val end)
    UI_Components.createSlider(rageSettings, "Orbit Height", 0, 20, 5, function(val) Registry.rageOrbitHeight = val end)
    UI_Components.createSlider(rageSettings, "Max Teleport Distance", 10, 1000, 50, function(val) Registry.rageMaxDistance = val end)

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

    local shrinkSettings, shrinkIcon = UI_Components.createFeatureTile(MiscPage, "Hitbox Shrinker", false, function(state)
        Registry.shrinkEnabled = state
        Misc.applyShrink()
    end)
    shrinkIcon.Text = "📦"
    UI_Components.createSection(shrinkSettings, "Compression")
    UI_Components.createSlider(shrinkSettings, "Shrink Size", 0.1, 1.0, 0.2, function(val) Registry.shrinkScale = val end)



    local camSettings, camIcon = UI_Components.createFeatureTile(MiscPage, "Camera/FOV", false, function(state)
        Registry.customFOVEnabled = state
        getgenv().MyHubState.Main_Logic.applyCameraFOV()
    end)
    camIcon.Text = "🎥"
    UI_Components.createSlider(camSettings, "Custom Field of View", 30, 120, 70, function(val) 
        Registry.customFOV = val
        getgenv().MyHubState.Main_Logic.applyCameraFOV()
    end)

    -- [[ EXCEPTIONS PAGE TILES ]]
    local whitelistSettings, whitelistIcon = UI_Components.createFeatureTile(ExceptionsPage, "Whitelist", true, function(state) end)
    whitelistIcon.Text = "🛡️"
    
    UI_Components.createSection(whitelistSettings, "Add Player")
    local currentPlayerName = ""
    UI_Components.createTextBox(whitelistSettings, "Player Name", "Enter name...", function(text)
        currentPlayerName = text
    end)
    UI_Components.createButton(whitelistSettings, "Add to Whitelist", function()
        if currentPlayerName ~= "" then
            table.insert(Registry.whitelist, currentPlayerName)
            print("[WHITELIST] Added: " .. currentPlayerName)
            currentPlayerName = "" -- reset
        end
    end)
    
    UI_Components.createSection(whitelistSettings, "Remove Player")
    local removePlayerName = ""
    UI_Components.createTextBox(whitelistSettings, "Player Name", "Enter name...", function(text)
        removePlayerName = text
    end)
    UI_Components.createButton(whitelistSettings, "Remove", function()
        if removePlayerName ~= "" then
            for i, name in ipairs(Registry.whitelist) do
                if name:lower() == removePlayerName:lower() then
                    table.remove(Registry.whitelist, i)
                    print("[WHITELIST] Removed: " .. removePlayerName)
                    break
                end
            end
            removePlayerName = ""
        end
    end)

    -- [[ SETTINGS PAGE TILES ]]
    local configSettings, configIcon = UI_Components.createFeatureTile(SettingsPage, "Configuration", false, function(state) end)
    configIcon.Text = "💾"
    UI_Components.createSection(configSettings, "Profiles")
    UI_Components.createToggle(configSettings, "Auto-Save on Exit", true, function(state) Registry.autoSaveEnabled = state end)
    
    local saveBtn = UI_Components.createToggle(configSettings, "Click to SAVE Config", false, function(s) Config.saveConfig() end)
    local loadBtn = UI_Components.createToggle(configSettings, "Click to LOAD Config", false, function(s) Config.loadConfig() end)

    local infoSettings, infoIcon = UI_Components.createFeatureTile(SettingsPage, "About Hub", false, function(state) end)
    infoIcon.Text = "ℹ️"
    UI_Components.createSection(infoSettings, "Script Info")
    UI_Components.createToggle(infoSettings, "Show FPS Counter", false, function(state) end)
    
    UI_Components.createSection(infoSettings, "Keybinds")
    UI_Components.createToggle(infoSettings, "Menu Key: [INSERT]", true, function(s) end)
    UI_Components.createToggle(infoSettings, "Rage Bot Key: [X]", true, function(s) end)
    UI_Components.createToggle(infoSettings, "Aimbot Key: [Z]", true, function(s) end)
    UI_Components.createToggle(infoSettings, "Trigger Key: [H]", true, function(s) end)
end

return UI_Pages
