local World = {}
local Registry = getgenv().MyHubState.Registry

local Lighting = game:GetService("Lighting")

-- Setting variables (From Global Scope)
-- worldVisualsEnabled = true

-- Backup original lighting
local originalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart
}

--[[
    THEMES - Готовые темы для быстрого применения
--]]

World.themes = {
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
    
    ["Matrix"] = {
        name = "💚 Matrix",
        ambient = Color3.fromRGB(0, 50, 0),
        outdoorAmbient = Color3.fromRGB(0, 80, 0),
        brightness = 1.1,
        colorShiftTop = Color3.fromRGB(0, 255, 0),
        colorShiftBottom = Color3.fromRGB(0, 180, 0),
        fogColor = Color3.fromRGB(0, 60, 0),
        fogEnd = 500,
        bloomIntensity = 0.6,
        bloomSize = 30
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
    
    ["Ice"] = {
        name = "❄️ Ice World",
        ambient = Color3.fromRGB(50, 80, 150),
        outdoorAmbient = Color3.fromRGB(80, 100, 150),
        brightness = 1.2,
        colorShiftTop = Color3.fromRGB(200, 220, 255),
        colorShiftBottom = Color3.fromRGB(100, 200, 255),
        fogColor = Color3.fromRGB(100, 130, 180),
        fogEnd = 800,
        bloomIntensity = 0.3,
        bloomSize = 20
    },
    
    ["Rainbow"] = {
        name = "🌈 Rainbow",
        -- Динамический режим (будет меняться)
        dynamic = true
    }
}

--[[
    POST-PROCESSING EFFECTS
    Bloom, Color Correction, Sun Rays
--]]

-- Bloom Effect (свечение)
local bloom = Instance.new("BloomEffect")
bloom.Name = "CustomBloom"
bloom.Intensity = 0.5
bloom.Size = 25
bloom.Threshold = 2.5
bloom.Enabled = true
bloom.Parent = Lighting

-- Color Correction (коррекция цветов)
local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "CustomColorCorrection"
colorCorrection.Brightness = 0
colorCorrection.Contrast = 0.15
colorCorrection.Saturation = 0.25
colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
colorCorrection.Enabled = true
colorCorrection.Parent = Lighting

-- Sun Rays (солнечные лучи)
local sunRays = Instance.new("SunRaysEffect")
sunRays.Name = "CustomSunRays"
sunRays.Intensity = 0.15
sunRays.Spread = 0.5
sunRays.Enabled = true
sunRays.Parent = Lighting

-- Blur Effect (размытие при движении)
local blur = Instance.new("BlurEffect")
blur.Name = "CustomBlur"
blur.Size = 0
blur.Enabled = false
blur.Parent = Lighting

--[[
    PARTICLE EFFECTS
    Создаем красивые частицы в мире
--]]

local particleContainer = Instance.new("Folder")
particleContainer.Name = "WorldParticles"
particleContainer.Parent = workspace

-- Floating particles (летающие частицы)
function World.createWorldParticles()
    for i = 1, 5 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.5, 0.5, 0.5)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.Name = "ParticleEmitter" .. i
        part.Parent = particleContainer
        
        -- Random position around player
        if Registry.LocalPlayer.Character and Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos = Registry.LocalPlayer.Character.HumanoidRootPart.Position
            part.Position = rootPos + Vector3.new(
                math.random(-50, 50),
                math.random(0, 30),
                math.random(-50, 50)
            )
        end
        
        -- Particle Emitter
        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emitter.Rate = 20
        emitter.Lifetime = NumberRange.new(3, 5)
        emitter.Speed = NumberRange.new(2, 4)
        emitter.SpreadAngle = Vector2.new(360, 360)
        emitter.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 100))
        }
        emitter.Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        }
        emitter.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 1)
        }
        emitter.LightEmission = 1
        emitter.Enabled = true
        emitter.Parent = part
    end
end

--[[
    SKY EFFECTS
    Красивое небо с градиентами
--]]

local sky = Instance.new("Sky")
sky.Name = "CustomSky"
sky.SkyboxBk = "rbxasset://sky/moon.jpg"
sky.SkyboxDn = "rbxasset://sky/moon.jpg"
sky.SkyboxFt = "rbxasset://sky/moon.jpg"
sky.SkyboxLf = "rbxasset://sky/moon.jpg"
sky.SkyboxRt = "rbxasset://sky/moon.jpg"
sky.SkyboxUp = "rbxasset://sky/moon.jpg"
sky.StarCount = 3000
sky.SunAngularSize = 15
sky.MoonAngularSize = 12
sky.Parent = Lighting

--[[
    APPLY THEME FUNCTION
    Применить тему к миру
--]]

function World.applyTheme(themeName)
    local theme = World.themes[themeName]
    if not theme then return end
    
    Registry.currentTheme = themeName
    
    if theme.dynamic then
        -- Rainbow mode будет обрабатываться отдельно
        return
    end
    
    -- Apply lighting
    Lighting.Ambient = theme.ambient
    Lighting.OutdoorAmbient = theme.outdoorAmbient
    Lighting.Brightness = theme.brightness
    Lighting.ColorShift_Top = theme.colorShiftTop
    Lighting.ColorShift_Bottom = theme.colorShiftBottom
    Lighting.FogColor = theme.fogColor
    Lighting.FogEnd = theme.fogEnd
    Lighting.FogStart = 0
    
    -- Apply post-processing
    bloom.Intensity = theme.bloomIntensity
    bloom.Size = theme.bloomSize
    
    print("[WORLD VISUALS] 🎨 Theme applied: " .. theme.name)
end

--[[
    RESTORE ORIGINAL
    Вернуть оригинальное освещение
--]]

function World.restoreOriginal()
    Lighting.Ambient = originalLighting.Ambient
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ColorShift_Top = originalLighting.ColorShift_Top
    Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
    Lighting.FogColor = originalLighting.FogColor
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    
    bloom.Intensity = 0.4
    bloom.Size = 24
    
    print("[WORLD VISUALS] ♻️ Original lighting restored")
end

--[[
    RAINBOW MODE
    Динамически меняющиеся цвета
--]]

local rainbowSpeed = 1

function World.updateRainbow()
    if not Registry.rainbowEnabled then return end
    
    local t = tick()
    local hue = (t * rainbowSpeed) % 5 / 5
    local color = Color3.fromHSV(hue, 1, 1)
    
    Lighting.Ambient = color
    Lighting.OutdoorAmbient = Color3.fromHSV((hue + 0.1) % 1, 1, 1)
    Lighting.ColorShift_Top = Color3.fromHSV((hue + 0.2) % 1, 1, 1)
    Lighting.ColorShift_Bottom = Color3.fromHSV((hue + 0.3) % 1, 0.8, 1)
    Lighting.FogColor = Color3.fromHSV((hue + 0.15) % 1, 0.6, 1)
    
    -- Rainbow Distortion Effect
    blur.Enabled = true
    blur.Size = 3 + math.sin(t * 3) * 3
    colorCorrection.Saturation = 0.4 + math.sin(t * 2) * 0.3
    colorCorrection.Contrast = 0.2 + math.sin(t * 1.5) * 0.15
end

--[[
    SPEED BLUR
    Размытие при быстром движении
--]]

World.speedBlurEnabled = false
local lastPosition = nil

function World.updateSpeedBlur()
    if not World.speedBlurEnabled then
        if not Registry.rainbowEnabled then
            blur.Size = 0
        end
        return
    end
    
    if not Registry.LocalPlayer.Character then return end
    local rootPart = Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local currentPos = rootPart.Position
    
    if lastPosition then
        local speed = (currentPos - lastPosition).Magnitude
        blur.Size = math.clamp(speed * 2, 0, 24)
    end
    
    lastPosition = currentPos
end

--[[
    DYNAMIC LIGHTING
    Пульсирующее освещение
--]]

World.pulseEnabled = false
World.pulseSpeed = 2
World.pulseIntensity = 0.5

function World.updatePulse()
    if not World.pulseEnabled then return end
    
    local pulse = math.sin(tick() * World.pulseSpeed) * World.pulseIntensity
    bloom.Intensity = 1 + pulse
    Lighting.Brightness = 2 + pulse
end

--[[
    INITIALIZATION
    Запуск эффектов
--]]

function World.initializeWorldVisuals()
    -- Apply default theme
    World.applyTheme("Cyberpunk")
    
    -- Create particles
    World.createWorldParticles()
    
    -- Update particles position periodically
    task.spawn(function()
        while task.wait(2) do
            if Registry.LocalPlayer.Character and Registry.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, part in pairs(particleContainer:GetChildren()) do
                    local rootPos = Registry.LocalPlayer.Character.HumanoidRootPart.Position
                    part.Position = rootPos + Vector3.new(
                        math.random(-50, 50),
                        math.random(0, 30),
                        math.random(-50, 50)
                    )
                end
            end
        end
    end)
    
    print("✅ WORLD VISUALS INITIALIZED!")
    print("🎨 Available themes:")
    for name, theme in pairs(World.themes) do
        print("   - " .. (theme.name or name))
    end
end

-- Export functions for Global Scope
_G.WorldVisuals = {
    applyTheme = World.applyTheme,
    restore = World.restoreOriginal,
    toggleRainbow = function(state)
        Registry.rainbowEnabled = state
        if state then
            Registry.currentTheme = "Rainbow"
            blur.Enabled = true
        else
            Registry.rainbowEnabled = false
            blur.Size = 0
            blur.Enabled = World.speedBlurEnabled
            colorCorrection.Saturation = 0.25
            colorCorrection.Contrast = 0.15
            World.restoreOriginal()
        end
    end,
    toggleSpeedBlur = function(state)
        World.speedBlurEnabled = state
    end,
    togglePulse = function(state)
        World.pulseEnabled = state
    end,
    setBloomIntensity = function(value)
        bloom.Intensity = value
    end,
    setBloomSize = function(value)
        bloom.Size = value
    end,
    setFogDistance = function(value)
        Lighting.FogEnd = value
    end,
    themes = World.themes
}

return World
