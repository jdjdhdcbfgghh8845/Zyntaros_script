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
        if Registry.autoSaveEnabled then Config.saveConfig() end
        if state then print("[AIMBOT] 🎯 Enabled") end
    end)
    aimbotIcon.Text = "🎯"
    
    UI_Components.createSection(aimbotSettings, "Aimbot Core")
    UI_Components.createKeybind(aimbotSettings, "Aimbot", Registry.Keybinds["Aimbot"], function(key) Registry.Keybinds["Aimbot"] = key if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(aimbotSettings, "Aimbot Smoothness", 0.05, 1.0, 0.2, function(val) Registry.aimbotSmoothness = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(aimbotSettings, "Aimbot FOV Size", 50, 2000, 200, function(val) Registry.aimbotFOV = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(aimbotSettings, "Wall Check", true, function(state) Registry.wallCheckEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(aimbotSettings, "Team Check", true, function(state) Registry.teamCheckEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    
    UI_Components.createSection(aimbotSettings, "Advanced")
    UI_Components.createToggle(aimbotSettings, "Aimbot Prediction", false, function(state) Registry.predictionEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(aimbotSettings, "Prediction Strength", 0.05, 0.5, 0.15, function(val) Registry.predictionMultiplier = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(aimbotSettings, "Auto Shoot (Aimbot)", false, function(state) Registry.aimbotAutoShoot = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    
    local rageSettings, rageIcon = UI_Components.createFeatureTile(AimbotPage, "Rage Aimbot", false, function(state)
        Registry.rageAimbotEnabled = state
        if Registry.autoSaveEnabled then Config.saveConfig() end
        if state then print("[RAGE AIMBOT] 🌪️ Enabled") end
    end)
    rageIcon.Text = "🌪️"
    
    UI_Components.createSection(rageSettings, "Orbit Configuration")
    UI_Components.createKeybind(rageSettings, "Rage Aimbot", Registry.Keybinds["Rage Aimbot"], function(key) Registry.Keybinds["Rage Aimbot"] = key if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(rageSettings, "Orbit Speed", 1, 50, 10, function(val) Registry.rageOrbitSpeed = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(rageSettings, "Orbit Radius", 1, 20, 3, function(val) Registry.rageOrbitRadius = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(rageSettings, "Orbit Height", 0, 20, 5, function(val) Registry.rageOrbitHeight = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(rageSettings, "Max Teleport Distance", 10, 1000, 50, function(val) Registry.rageMaxDistance = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    
    UI_Components.createSection(rageSettings, "Wave (Chaotic) Orbit")
    UI_Components.createToggle(rageSettings, "Enabled Wave Orbit", false, function(state) Registry.rageWaveEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(rageSettings, "Wave Amplitude", 1, 10, 2, function(val) Registry.rageWaveAmplitude = val if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(rageSettings, "Wave Frequency", 1, 10, 2, function(val) Registry.rageWaveFrequency = val if Registry.autoSaveEnabled then Config.saveConfig() end end)

    local triggerSettings, triggerIcon = UI_Components.createFeatureTile(AimbotPage, "Trigger Bot", false, function(state)
        Registry.triggerBotEnabled = state
        if Registry.autoSaveEnabled then Config.saveConfig() end
        if state then print("[TRIGGER BOT] 🖱️ Enabled") end
    end)
    triggerIcon.Text = "🖱️"
    
    UI_Components.createSection(triggerSettings, "Trigger Settings")
    UI_Components.createKeybind(triggerSettings, "Trigger Bot", Registry.Keybinds["Trigger Bot"], function(key) Registry.Keybinds["Trigger Bot"] = key if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(triggerSettings, "Smart Headshot", true, function(state) Registry.triggerBotSmart = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(triggerSettings, "Auto-Click Delay", 0.001, 0.5, 0.001, function(val) Registry.ESP_SETTINGS.TriggerDelay = val if Registry.autoSaveEnabled then Config.saveConfig() end end)

    -- [[ VISUALS PAGE TILES ]]
    local espSettings, espIcon = UI_Components.createFeatureTile(VisualsPage, "ESP", true, function(state)
         Registry.espEnabled = state
         if state then Visuals.initializeESP() else for p, _ in pairs(Registry.espObjects) do Visuals.removeESP(p) end end
    end)
    espIcon.Text = "👤"
    
    UI_Components.createSection(espSettings, "ESP Options")
    UI_Components.createToggle(espSettings, "Show Names", true, function(state) Registry.ESP_SETTINGS.NameEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(espSettings, "Show Health", true, function(state) Registry.ESP_SETTINGS.HealthEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(espSettings, "Show Distance", true, function(state) Registry.ESP_SETTINGS.DistanceEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(espSettings, "Box Highlight", true, function(state) Registry.ESP_SETTINGS.BoxEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(espSettings, "Max Draw Distance", 500, 10000, 5000, function(val) Registry.ESP_SETTINGS.MaxDistance = val if Registry.autoSaveEnabled then Config.saveConfig() end end)

    local skelSettings, skelIcon = UI_Components.createFeatureTile(VisualsPage, "Skeleton ESP", false, function(state)
        Registry.ESP_SETTINGS.SkeletonEnabled = state
    end)
    skelIcon.Text = "💀"

    local effectSettings, effectIcon = UI_Components.createFeatureTile(VisualsPage, "Visual Effects", false, function(state) end)
    effectIcon.Text = "✨"
    
    UI_Components.createSection(effectSettings, "World Effects")
    UI_Components.createToggle(effectSettings, "Chams", false, function(state) _G.chamsEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(effectSettings, "Tracers", false, function(state) _G.tracersEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(effectSettings, "Enemy Glow", false, function(state) _G.glowEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(effectSettings, "Bullet Tracers", false, function(state) Registry.bulletTracersEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(effectSettings, "Target HUD", false, function(state) Registry.targetHUDEnabled = state if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(effectSettings, "Tracer Duration", 0.1, 2.0, 0.5, function(val) Registry.bulletTracerDuration = val if Registry.autoSaveEnabled then Config.saveConfig() end end)

    local worldSettings, worldIcon = UI_Components.createFeatureTile(VisualsPage, "World Themes", true, function(state)
        Registry.worldVisualsEnabled = state
    end)
    worldIcon.Text = "🌌"
    
    UI_Components.createSection(worldSettings, "Theme Control")
    UI_Components.createToggle(worldSettings, "Rainbow Mode", false, function(state) _G.WorldVisuals.toggleRainbow(state) if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(worldSettings, "Speed Blur", false, function(state) _G.WorldVisuals.toggleSpeedBlur(state) if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createToggle(worldSettings, "Pulse Effect", false, function(state) _G.WorldVisuals.togglePulse(state) if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSection(worldSettings, "Post-Processing")
    UI_Components.createSlider(worldSettings, "Bloom Intensity", 0.1, 2.0, 0.5, function(val) _G.WorldVisuals.setBloomIntensity(val) if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(worldSettings, "Fog Distance", 100, 5000, 600, function(val) _G.WorldVisuals.setFogDistance(val) if Registry.autoSaveEnabled then Config.saveConfig() end end)

    -- [[ MISC PAGE TILES ]]
    local speedSettings, speedIcon = UI_Components.createFeatureTile(MiscPage, "Speed Hack", false, function(state)
        Registry.speedHackEnabled = state
        if Registry.autoSaveEnabled then Config.saveConfig() end
        Misc.applySpeedHack()
    end)
    speedIcon.Text = "⚡"
    UI_Components.createKeybind(speedSettings, "Speed Hack", Registry.Keybinds["Speed Hack"], function(key) Registry.Keybinds["Speed Hack"] = key if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(speedSettings, "Speed Multiplier", 1, 10, 2, function(val) Registry.speedMultiplier = val if Registry.autoSaveEnabled then Config.saveConfig() end end)

    local jumpSettings, jumpIcon = UI_Components.createFeatureTile(MiscPage, "Infinite Jump", false, function(state)
        Registry.infJumpEnabled = state
        if Registry.autoSaveEnabled then Config.saveConfig() end
    end)
    jumpIcon.Text = "🦘"

    local noclipSettings, noclipIcon = UI_Components.createFeatureTile(MiscPage, "Noclip", false, function(state)
        Registry.noclipEnabled = state
        if Registry.autoSaveEnabled then Config.saveConfig() end
    end)
    noclipIcon.Text = "👻"
    UI_Components.createKeybind(noclipSettings, "Noclip", Registry.Keybinds["Noclip"], function(key) Registry.Keybinds["Noclip"] = key if Registry.autoSaveEnabled then Config.saveConfig() end end)

    local flySettings, flyIcon = UI_Components.createFeatureTile(MiscPage, "Fly Hack", false, function(state)
        Registry.flyEnabled = state
        if Registry.autoSaveEnabled then Config.saveConfig() end
        Misc.updateFly()
    end)
    flyIcon.Text = "🕊️"
    UI_Components.createKeybind(flySettings, "Fly Hack", Registry.Keybinds["Fly Hack"], function(key) Registry.Keybinds["Fly Hack"] = key if Registry.autoSaveEnabled then Config.saveConfig() end end)
    UI_Components.createSlider(flySettings, "Fly Speed", 10, 200, 50, function(val) Registry.flySpeed = val if Registry.autoSaveEnabled then Config.saveConfig() end end)

    local tpSettings, tpIcon = UI_Components.createFeatureTile(MiscPage, "Third Person View", false, function(state)
         Registry.isThirdPerson = state
         if Registry.autoSaveEnabled then Config.saveConfig() end
         Misc.applyThirdPerson()
    end)
    tpIcon.Text = "🧍"
    UI_Components.createKeybind(tpSettings, "Third Person View", Registry.Keybinds["Third Person View"], function(key) Registry.Keybinds["Third Person View"] = key if Registry.autoSaveEnabled then Config.saveConfig() end end)

    local spinSettings, spinIcon = UI_Components.createFeatureTile(MiscPage, "Spin Bot", false, function(state)
        Registry.spinBotEnabled = state
        if Registry.autoSaveEnabled then Config.saveConfig() end
    end)
    spinIcon.Text = "🌀"
    UI_Components.createSlider(spinSettings, "Spin Speed", 1, 100, 15, function(val) Registry.spinBotSpeed = val if Registry.autoSaveEnabled then Config.saveConfig() end end)


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
    
    UI_Components.createSection(infoSettings, "Keybinds Info")
    UI_Components.createToggle(infoSettings, "Standard Toggle: [CLICK TILE]", true, function(s) end)
    UI_Components.createToggle(infoSettings, "Quick Menu: [INSERT]", true, function(s) end)
    UI_Components.createButton(infoSettings, "Forced Save Config Now", function() Config.saveConfig() end)
end

return UI_Pages
