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

        
        -- Visuals
        espEnabled = Registry.espEnabled,
        skeletonEnabled = Registry.ESP_SETTINGS.SkeletonEnabled,
        chamsEnabled = _G.chamsEnabled,
        tracersEnabled = _G.tracersEnabled,
        crosshairEnabled = _G.crosshairEnabled,
        glowEnabled = _G.glowEnabled,
        
        -- Misc
        speedMultiplier = Registry.speedMultiplier,

        noclipEnabled = Registry.noclipEnabled,
        infJumpEnabled = Registry.infJumpEnabled,
        
        -- Settings
        rainbowEnabled = Registry.rainbowEnabled
    }
    
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

        
        if config.espEnabled ~= nil then Registry.espEnabled = config.espEnabled end
        if config.skeletonEnabled ~= nil then Registry.ESP_SETTINGS.SkeletonEnabled = config.skeletonEnabled end
        if config.chamsEnabled ~= nil then _G.chamsEnabled = config.chamsEnabled end
        if config.tracersEnabled ~= nil then _G.tracersEnabled = config.tracersEnabled end
        if config.crosshairEnabled ~= nil then _G.crosshairEnabled = config.crosshairEnabled end
        if config.glowEnabled ~= nil then _G.glowEnabled = config.glowEnabled end
        
        if config.speedMultiplier ~= nil then Registry.speedMultiplier = config.speedMultiplier end

        if config.noclipEnabled ~= nil then Registry.noclipEnabled = config.noclipEnabled end
        if config.infJumpEnabled ~= nil then Registry.infJumpEnabled = config.infJumpEnabled end
        if config.rainbowEnabled ~= nil then Registry.rainbowEnabled = config.rainbowEnabled end
        
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
            crosshairEnabled = "Crosshair",
            glowEnabled = "Enemy Glow",
            
            speedMultiplier = "Speed Multiplier",

            noclipEnabled = "Noclip",
            infJumpEnabled = "Infinite Jump",
            rainbowEnabled = "Rainbow Mode"
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
