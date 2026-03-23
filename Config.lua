local Config = {}
local Registry = getgenv().MyHubState.Registry

-- [[ CONFIGURATION MANAGEMENT ]]
function Config.saveConfig()
    local config = {
        -- Aimbot
        aimbotEnabled = Registry.aimbotEnabled,
        triggerBotEnabled = Registry.triggerBotEnabled,
        aimbotSmoothness = Registry.aimbotSmoothness,
        aimbotFOV = Registry.aimbotFOV,
        aimbotMode = Registry.aimbotMode,
        wallCheckEnabled = Registry.wallCheckEnabled,
        teamCheckEnabled = Registry.teamCheckEnabled,
        predictionEnabled = Registry.predictionEnabled,
        predictionMultiplier = Registry.predictionMultiplier,
        aimbotAutoShoot = Registry.aimbotAutoShoot,
        rageAimbotEnabled = Registry.rageAimbotEnabled,
        rageOrbitSpeed = Registry.rageOrbitSpeed,
        rageOrbitRadius = Registry.rageOrbitRadius,
        rageOrbitHeight = Registry.rageOrbitHeight,
        rageMaxDistance = Registry.rageMaxDistance,
        rageWaveEnabled = Registry.rageWaveEnabled,
        rageWaveAmplitude = Registry.rageWaveAmplitude,
        rageWaveFrequency = Registry.rageWaveFrequency,

        
        -- Visuals
        espEnabled = Registry.espEnabled,
        skeletonEnabled = Registry.ESP_SETTINGS.SkeletonEnabled,
        chamsEnabled = _G.chamsEnabled,
        tracersEnabled = _G.tracersEnabled,
        crosshairEnabled = _G.crosshairEnabled,
        glowEnabled = _G.glowEnabled,
        bulletTracersEnabled = Registry.bulletTracersEnabled,
        bulletTracerColor = {Registry.bulletTracerColor.R, Registry.bulletTracerColor.G, Registry.bulletTracerColor.B},
        bulletTracerDuration = Registry.bulletTracerDuration,
        targetHUDEnabled = Registry.targetHUDEnabled,
        
        -- Misc
        speedMultiplier = Registry.speedMultiplier,
        flyEnabled = Registry.flyEnabled,
        flySpeed = Registry.flySpeed,
        isThirdPerson = Registry.isThirdPerson,

        noclipEnabled = Registry.noclipEnabled,
        infJumpEnabled = Registry.infJumpEnabled,
        spinBotEnabled = Registry.spinBotEnabled,
        spinBotSpeed = Registry.spinBotSpeed,
        
        -- Settings
        rainbowEnabled = Registry.rainbowEnabled,
        autoSaveEnabled = Registry.autoSaveEnabled,
        streamproofEnabled = Registry.streamproofEnabled,
        
        -- Keybinds (Stored as strings)
        keybinds = {}
    }
    
    for name, key in pairs(Registry.Keybinds) do
        config.keybinds[name] = key.Name
    end
    
    local success, err = pcall(function()
        writefile("MultihackConfig.json", Registry.HttpService:JSONEncode(config))
    end)
    
    if success then
        -- print("[CONFIG] 💾 Configuration saved successfully")
    else
        warn("[CONFIG] ❌ Failed to save: " .. tostring(err))
    end
end

function Config.loadConfig()
    local success, content = pcall(function()
        return readfile("MultihackConfig.json")
    end)
    
    if success then
        local config = Registry.HttpService:JSONDecode(content)
        
        -- Update variables
        if config.aimbotEnabled ~= nil then Registry.aimbotEnabled = config.aimbotEnabled end
        if config.triggerBotEnabled ~= nil then Registry.triggerBotEnabled = config.triggerBotEnabled end
        if config.aimbotSmoothness ~= nil then Registry.aimbotSmoothness = config.aimbotSmoothness end
        if config.aimbotFOV ~= nil then Registry.aimbotFOV = config.aimbotFOV end
        if config.aimbotMode ~= nil then Registry.aimbotMode = config.aimbotMode end
        if config.wallCheckEnabled ~= nil then Registry.wallCheckEnabled = config.wallCheckEnabled end
        if config.teamCheckEnabled ~= nil then Registry.teamCheckEnabled = config.teamCheckEnabled end
        if config.predictionEnabled ~= nil then Registry.predictionEnabled = config.predictionEnabled end
        if config.predictionMultiplier ~= nil then Registry.predictionMultiplier = config.predictionMultiplier end
        if config.aimbotAutoShoot ~= nil then Registry.aimbotAutoShoot = config.aimbotAutoShoot end
        if config.rageAimbotEnabled ~= nil then Registry.rageAimbotEnabled = config.rageAimbotEnabled end
        if config.rageOrbitSpeed ~= nil then Registry.rageOrbitSpeed = config.rageOrbitSpeed end
        if config.rageOrbitRadius ~= nil then Registry.rageOrbitRadius = config.rageOrbitRadius end
        if config.rageOrbitHeight ~= nil then Registry.rageOrbitHeight = config.rageOrbitHeight end
        if config.rageMaxDistance ~= nil then Registry.rageMaxDistance = config.rageMaxDistance end
        if config.rageWaveEnabled ~= nil then Registry.rageWaveEnabled = config.rageWaveEnabled end
        if config.rageWaveAmplitude ~= nil then Registry.rageWaveAmplitude = config.rageWaveAmplitude end
        if config.rageWaveFrequency ~= nil then Registry.rageWaveFrequency = config.rageWaveFrequency end

        
        if config.espEnabled ~= nil then Registry.espEnabled = config.espEnabled end
        if config.skeletonEnabled ~= nil then Registry.ESP_SETTINGS.SkeletonEnabled = config.skeletonEnabled end
        if config.chamsEnabled ~= nil then _G.chamsEnabled = config.chamsEnabled end
        if config.tracersEnabled ~= nil then _G.tracersEnabled = config.tracersEnabled end
        if config.crosshairEnabled ~= nil then _G.crosshairEnabled = config.crosshairEnabled end
        if config.glowEnabled ~= nil then _G.glowEnabled = config.glowEnabled end
        if config.bulletTracersEnabled ~= nil then Registry.bulletTracersEnabled = config.bulletTracersEnabled end
        if config.bulletTracerDuration ~= nil then Registry.bulletTracerDuration = config.bulletTracerDuration end
        if config.bulletTracerColor ~= nil then 
            Registry.bulletTracerColor = Color3.new(config.bulletTracerColor[1], config.bulletTracerColor[2], config.bulletTracerColor[3]) 
        end
        if config.targetHUDEnabled ~= nil then Registry.targetHUDEnabled = config.targetHUDEnabled end
        
        if config.speedMultiplier ~= nil then Registry.speedMultiplier = config.speedMultiplier end
        if config.flyEnabled ~= nil then Registry.flyEnabled = config.flyEnabled end
        if config.flySpeed ~= nil then Registry.flySpeed = config.flySpeed end
        if config.isThirdPerson ~= nil then Registry.isThirdPerson = config.isThirdPerson end

        if config.noclipEnabled ~= nil then Registry.noclipEnabled = config.noclipEnabled end
        if config.infJumpEnabled ~= nil then Registry.infJumpEnabled = config.infJumpEnabled end
        if config.spinBotEnabled ~= nil then Registry.spinBotEnabled = config.spinBotEnabled end
        if config.spinBotSpeed ~= nil then Registry.spinBotSpeed = config.spinBotSpeed end
        if config.rainbowEnabled ~= nil then Registry.rainbowEnabled = config.rainbowEnabled end
        if config.autoSaveEnabled ~= nil then Registry.autoSaveEnabled = config.autoSaveEnabled end
        if config.streamproofEnabled ~= nil then 
            Registry.streamproofEnabled = config.streamproofEnabled 
            -- Apply immediately after loading
            task.spawn(function()
                wait(0.5)
                getgenv().MyHubState.UI_Main.updateStreamproof()
            end)
        end
        
        -- Load Keybinds
        if config.keybinds then
            for name, keyName in pairs(config.keybinds) do
                pcall(function()
                    local key = Enum.KeyCode[keyName]
                    Registry.Keybinds[name] = key
                    -- Sync UI button
                    local updateKey = _G.ConfigRegistry[name .. " Bind"]
                    if updateKey then updateKey(key) end
                end)
            end
        end
        
        -- Mapping variables to UI names for sync
        local syncMap = {
            aimbotEnabled = "Aimbot",
            triggerBotEnabled = "Trigger Bot",
            aimbotSmoothness = "Aimbot Smoothness",
            aimbotFOV = "Aimbot FOV Size",
            wallCheckEnabled = "Wall Check",
            teamCheckEnabled = "Team Check",
            predictionEnabled = "Aimbot Prediction",
            predictionMultiplier = "Prediction Strength",
            aimbotAutoShoot = "Auto Shoot (Aimbot)",
            rageAimbotEnabled = "Rage Aimbot",
            rageOrbitSpeed = "Orbit Speed",
            rageOrbitRadius = "Orbit Radius",
            rageOrbitHeight = "Orbit Height",
            rageMaxDistance = "Max Teleport Distance",

            
            espEnabled = "ESP",
            skeletonEnabled = "Skeleton ESP",
            chamsEnabled = "Chams",
            tracersEnabled = "Tracers",
            crosshairEnabled = "Custom Crosshair",
            glowEnabled = "Enemy Glow",
            bulletTracersEnabled = "Bullet Tracers",
            bulletTracerDuration = "Tracer Duration",
            targetHUDEnabled = "Target HUD (Crosshair)",
            
            speedMultiplier = "Speed Multiplier",
            flyEnabled = "Fly Hack",
            flySpeed = "Fly Speed",
            isThirdPerson = "Third Person View",

            noclipEnabled = "Noclip",
            infJumpEnabled = "Infinite Jump",
            spinBotEnabled = "Spin Bot",
            spinBotSpeed = "Spin Speed",
            rageWaveEnabled = "Enabled Wave Orbit",
            streamproofEnabled = "Streamproof Mode"
        }
        
        -- Sync GUI Elements
        for varName, uiName in pairs(syncMap) do
            local val = config[varName]
            if val ~= nil then
                local updateFunc = _G.ConfigRegistry[uiName]
                if updateFunc then
                    if uiName == "Silent Hit Chance (%)" then val = val * 100 end
                    pcall(function() updateFunc(val) end)
                end
            end
        end
        
        print("[CONFIG] ✅ Configuration loaded and synchronized!")
    end
end

return Config
