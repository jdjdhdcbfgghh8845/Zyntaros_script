-- [[ ACC CONFIGURATION SYSTEM ]]
-- Full registry synchronization and JSON persistence with 100% parity

local Constants = require(script.Parent.Parent.core.constants)
local State = Constants.State
local Services = Constants.Services
local ESP_SETTINGS = Constants.ESP_SETTINGS

local Config = {}
local fileName = "ACC_MultihackConfig.json"

-- Registry Sync Helper
local function syncRegistry(key, value)
    if _G.ConfigRegistry[key] then
        pcall(_G.ConfigRegistry[key], value)
    end
end

function Config.saveConfig()
    local success, err = pcall(function()
        local settingsToSave = {
            Aimbot = {
                Enabled = State.aimbotEnabled,
                Smoothness = State.aimbotSmoothness,
                FOV = State.aimbotFOV,
                WallCheck = State.wallCheckEnabled,
                TeamCheck = State.teamCheckEnabled,
                Prediction = State.predictionEnabled,
                PredictionStrength = State.predictionMultiplier,
                AutoShoot = State.aimbotAutoShoot
            },
            Trigger = {
                Enabled = State.triggerBotEnabled,
                Smart = State.triggerBotSmart
            },
            Silent = {
                Enabled = State.silentAimEnabled,
                HitChance = State.silentAimHitChance,
                AutoShoot = State.autoShootEnabled
            },
            Visuals = {
                ESP = State.espEnabled,
                Skeleton = ESP_SETTINGS.SkeletonEnabled,
                MaxDist = ESP_SETTINGS.MaxDistance,
                Chams = State.chamsEnabled,
                Tracers = State.tracersEnabled,
                Glow = State.glowEnabled,
                Theme = State.currentTheme,
                Rainbow = State.rainbowEnabled
            },
            Movement = {
                SpeedEnabled = State.speedHackEnabled,
                SpeedMult = State.speedMultiplier,
                Noclip = State.noclipEnabled,
                InfJump = State.infJumpEnabled
            },
            Defense = {
                Enabled = State.bulletDodgeEnabled,
                Dist = State.dodgeDistance,
                Speed = State.dodgeSpeed
            }
        }
        
        local json = Services.HttpService:JSONEncode(settingsToSave)
        writefile(fileName, json)
    end)
    if not success then warn("[CONFIG] Save Error: " .. tostring(err)) end
end

function Config.loadConfig()
    if not isfile(fileName) then return end
    
    local success, err = pcall(function()
        local json = readfile(fileName)
        local data = Services.HttpService:JSONDecode(json)
        
        -- Aimbot
        if data.Aimbot then
            State.aimbotEnabled = data.Aimbot.Enabled; syncRegistry("Aimbot", State.aimbotEnabled)
            State.aimbotSmoothness = data.Aimbot.Smoothness; syncRegistry("Aimbot Smoothness", State.aimbotSmoothness)
            State.aimbotFOV = data.Aimbot.FOV; syncRegistry("Aimbot FOV Size", State.aimbotFOV)
            State.wallCheckEnabled = data.Aimbot.WallCheck; syncRegistry("Wall Check", State.wallCheckEnabled)
            State.teamCheckEnabled = data.Aimbot.TeamCheck; syncRegistry("Team Check", State.teamCheckEnabled)
            State.predictionEnabled = data.Aimbot.Prediction; syncRegistry("Aimbot Prediction", State.predictionEnabled)
            State.predictionMultiplier = data.Aimbot.PredictionStrength; syncRegistry("Prediction Strength", State.predictionMultiplier)
            State.aimbotAutoShoot = data.Aimbot.AutoShoot; syncRegistry("Auto Shoot (Aimbot)", State.aimbotAutoShoot)
        end
        
        -- Trigger
        if data.Trigger then
            State.triggerBotEnabled = data.Trigger.Enabled; syncRegistry("Trigger Bot", State.triggerBotEnabled)
            State.triggerBotSmart = data.Trigger.Smart; syncRegistry("Smart Mode (Head)", State.triggerBotSmart)
        end
        
        -- Silent
        if data.Silent then
            State.silentAimEnabled = data.Silent.Enabled; syncRegistry("Silent Aim", State.silentAimEnabled)
            State.silentAimHitChance = data.Silent.HitChance; syncRegistry("Silent Hit Chance (%)", State.silentAimHitChance)
            State.autoShootEnabled = data.Silent.AutoShoot; syncRegistry("Silent Auto Shoot", State.autoShootEnabled)
        end
        
        -- Visuals
        if data.Visuals then
            State.espEnabled = data.Visuals.ESP; syncRegistry("ESP", State.espEnabled)
            ESP_SETTINGS.SkeletonEnabled = data.Visuals.Skeleton; syncRegistry("Skeleton ESP", ESP_SETTINGS.SkeletonEnabled)
            ESP_SETTINGS.MaxDistance = data.Visuals.MaxDist; syncRegistry("Max Distance", ESP_SETTINGS.MaxDistance)
            State.chamsEnabled = data.Visuals.Chams; syncRegistry("Chams", State.chamsEnabled)
            State.tracersEnabled = data.Visuals.Tracers; syncRegistry("Tracers", State.tracersEnabled)
            State.glowEnabled = data.Visuals.Glow; syncRegistry("Enemy Glow", State.glowEnabled)
            State.currentTheme = data.Visuals.Theme
            State.rainbowEnabled = data.Visuals.Rainbow; syncRegistry("Rainbow Mode", State.rainbowEnabled)
        end
        
        -- Movement
        if data.Movement then
            State.speedHackEnabled = data.Movement.SpeedEnabled; syncRegistry("Speed Hack", State.speedHackEnabled)
            State.speedMultiplier = data.Movement.SpeedMult; syncRegistry("Speed Multiplier", State.speedMultiplier)
            State.noclipEnabled = data.Movement.Noclip; syncRegistry("Noclip", State.noclipEnabled)
            State.infJumpEnabled = data.Movement.InfJump; syncRegistry("Infinite Jump", State.infJumpEnabled)
        end
        
        -- Defense
        if data.Defense then
            State.bulletDodgeEnabled = data.Defense.Enabled; syncRegistry("Defense", State.bulletDodgeEnabled)
            State.dodgeDistance = data.Defense.Dist; syncRegistry("Dodge Distance", State.dodgeDistance)
            State.dodgeSpeed = data.Defense.Speed; syncRegistry("Dodge Speed", State.dodgeSpeed)
        end
    end)
    if not success then warn("[CONFIG] Load Error: " .. tostring(err)) end
end

return Config
