-- [[ ACC VISUALS MODULE ]]
-- Exact World Visuals implementation from old/lua.lua

local Constants = require(script.Parent.Parent.core.constants)
local Utils = require(script.Parent.Parent.utils.utils)
local State = Constants.State
local Services = Constants.Services

local Visuals = {}

local activeVisuals = {
    bloom = nil,
    colorCorrection = nil,
    sunRays = nil,
    blur = nil,
    sky = nil
}

local particleContainer = nil
local lastPosition = nil
local lastSecondaryUpdate = 0
local secondaryUpdateInterval = 0.033

-- [[ INITIALIZE LIGHTING ]]
local function setupLighting()
    local Lighting = Services.Lighting
    
    activeVisuals.bloom = Lighting:FindFirstChild("CustomBloom") or Instance.new("BloomEffect", Lighting)
    activeVisuals.bloom.Name = "CustomBloom"
    activeVisuals.bloom.Intensity = 0.5; activeVisuals.bloom.Size = 25; activeVisuals.bloom.Threshold = 2.5
    
    activeVisuals.colorCorrection = Lighting:FindFirstChild("CustomColorCorrection") or Instance.new("ColorCorrectionEffect", Lighting)
    activeVisuals.colorCorrection.Name = "CustomColorCorrection"
    activeVisuals.colorCorrection.Contrast = 0.15; activeVisuals.colorCorrection.Saturation = 0.25
    
    activeVisuals.sunRays = Lighting:FindFirstChild("CustomSunRays") or Instance.new("SunRaysEffect", Lighting)
    activeVisuals.sunRays.Name = "CustomSunRays"
    activeVisuals.sunRays.Intensity = 0.15; activeVisuals.sunRays.Spread = 0.5
    
    activeVisuals.blur = Lighting:FindFirstChild("CustomBlur") or Instance.new("BlurEffect", Lighting)
    activeVisuals.blur.Name = "CustomBlur"; activeVisuals.blur.Size = 0; activeVisuals.blur.Enabled = false
    
    activeVisuals.sky = Lighting:FindFirstChild("CustomSky") or Instance.new("Sky", Lighting)
    activeVisuals.sky.Name = "CustomSky"; activeVisuals.sky.StarCount = 3000
end

-- [[ RAINBOW MODE ]]
local function updateRainbow()
    if not State.rainbowEnabled then return end
    local t = tick()
    local hue = (t * 1) % 5 / 5
    local color = Color3.fromHSV(hue, 1, 1)
    
    Services.Lighting.Ambient = color
    Services.Lighting.OutdoorAmbient = Color3.fromHSV((hue + 0.1) % 1, 1, 1)
    Services.Lighting.ColorShift_Top = Color3.fromHSV((hue + 0.2) % 1, 1, 1)
    Services.Lighting.ColorShift_Bottom = Color3.fromHSV((hue + 0.3) % 1, 0.8, 1)
    Services.Lighting.FogColor = Color3.fromHSV((hue + 0.15) % 1, 0.6, 1)
    
    activeVisuals.blur.Enabled = true
    activeVisuals.blur.Size = 3 + math.sin(t * 3) * 3
    activeVisuals.colorCorrection.Saturation = 0.4 + math.sin(t * 2) * 0.3
    activeVisuals.colorCorrection.Contrast = 0.2 + math.sin(t * 1.5) * 0.15
end

-- [[ PARTICLES ]]
local function createParticles()
    particleContainer = workspace:FindFirstChild("WorldParticles") or Instance.new("Folder", workspace)
    particleContainer.Name = "WorldParticles"
    
    for i = 1, 5 do
        local part = Instance.new("Part", particleContainer)
        part.Size = Vector3.new(0.5, 0.5, 0.5); part.Transparency = 1
        part.Anchored = true; part.CanCollide = false
        
        local emitter = Instance.new("ParticleEmitter", part)
        emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emitter.Rate = 20; emitter.Lifetime = NumberRange.new(3, 5)
        emitter.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 100))
        }
        emitter.Size = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(0.5,0.5), NumberSequenceKeypoint.new(1,0)}
        emitter.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.5), NumberSequenceKeypoint.new(1,1)}
        emitter.LightEmission = 1
    end
end

-- [[ APPLY THEME ]]
function Visuals.applyTheme(name)
    local theme = Constants.THEMES[name]
    if not theme then return end
    
    State.currentTheme = name
    if theme.dynamic then return end
    
    Services.Lighting.Ambient = theme.ambient
    Services.Lighting.OutdoorAmbient = theme.outdoorAmbient
    Services.Lighting.Brightness = theme.brightness
    Services.Lighting.ColorShift_Top = theme.colorShiftTop
    Services.Lighting.ColorShift_Bottom = theme.colorShiftBottom
    Services.Lighting.FogColor = theme.fogColor
    Services.Lighting.FogEnd = theme.fogEnd
    
    if activeVisuals.bloom then
        activeVisuals.bloom.Intensity = theme.bloomIntensity
        activeVisuals.bloom.Size = theme.bloomSize
    end
    print("[WORLD VISUALS] 🎨 Theme applied: " .. name)
end

-- [[ INITIALIZE ]]
function Visuals.initialize()
    setupLighting()
    createParticles()
    Visuals.applyTheme("Cyberpunk")
    
    Services.RunService.Heartbeat:Connect(function()
        if not State.worldVisualsEnabled then return end
        
        if State.currentTheme == "Rainbow" and State.rainbowEnabled then
            updateRainbow()
        end
        
        -- Particles Reposition
        local currentTime = tick()
        if currentTime - lastSecondaryUpdate >= 2 then
            lastSecondaryUpdate = currentTime
            local char = Constants.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local rootPos = char.HumanoidRootPart.Position
                for _, part in pairs(particleContainer:GetChildren()) do
                    part.Position = rootPos + Vector3.new(math.random(-50,50), math.random(0,30), math.random(-50,50))
                end
            end
        end
    end)
end

return Visuals
