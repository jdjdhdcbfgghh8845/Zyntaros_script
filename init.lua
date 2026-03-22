-- [[ ACC MULTIHACK - PREMIUM EDITION v2.4.0-PRO ]]
-- Main entry point with Integrated Auto-Downloader for GitHub Injection

local BASE_URL = "https://raw.githubusercontent.com/jdjdhdcbfgghh8845/Zyntaros_script/refs/heads/main/"
local FOLDER_NAME = "ACC"

-- [[ AUTO-DOWNLOADER / INSTALLER ]]
local function install()
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
    if not isfolder(FOLDER_NAME .. "/core") then makefolder(FOLDER_NAME .. "/core") end
    if not isfolder(FOLDER_NAME .. "/utils") then makefolder(FOLDER_NAME .. "/utils") end
    if not isfolder(FOLDER_NAME .. "/modules") then makefolder(FOLDER_NAME .. "/modules") end
    if not isfolder(FOLDER_NAME .. "/ui") then makefolder(FOLDER_NAME .. "/ui") end
    if not isfolder(FOLDER_NAME .. "/ui/pages") then makefolder(FOLDER_NAME .. "/ui/pages") end
    if not isfolder(FOLDER_NAME .. "/config") then makefolder(FOLDER_NAME .. "/config") end

    local files = {
        "core/constants.lua",
        "utils/utils.lua",
        "modules/esp.lua",
        "modules/aimbot.lua",
        "modules/silent_aim.lua",
        "modules/movement.lua",
        "modules/defense.lua",
        "modules/visuals.lua",
        "ui/components.lua",
        "ui/main_gui.lua",
        "ui/pages/aimbot.lua",
        "ui/pages/visuals.lua",
        "ui/pages/misc.lua",
        "ui/pages/settings.lua",
        "config/config.lua"
    }

    print("[ACC] 📥 Checking for updates...")
    for _, file in pairs(files) do
        local localPath = FOLDER_NAME .. "/" .. file
        -- For simplicity, we always update to the latest GitHub version on loadstring injection
        local success, content = pcall(function() return game:HttpGet(BASE_URL .. file) end)
        if success and content and not content:find("404") then
            writefile(localPath, content)
        else
            warn("[ACC] ❌ Failed to download: " .. file)
        end
    end
    print("[ACC] ✅ All modules synced!")
end

-- Detect if we are running from a local file or cloud
-- If 'script' is a ModuleScript (Local), we use require
-- If 'script' is nil or not in ACC folder (Cloud), we use loadfile from workspace
local isLocal = (typeof(script) == "Instance" and script:IsDescendantOf(game:GetService("CoreGui")))

if not isLocal then
    install()
end

-- [[ MODULE LOADER ]]
local function safeRequire(path)
    if isLocal then
        -- Standard Roblox require
        local segments = path:split(".")
        local current = script
        for _, s in ipairs(segments) do current = current[s] end
        return require(current)
    else
        -- Executor loadfile
        local localPath = FOLDER_NAME .. "/" .. path:gsub("%.", "/") .. ".lua"
        if isfile(localPath) then
            return loadstring(readfile(localPath))()
        else
            error("[ACC] ❌ Module not found locally: " .. localPath)
        end
    end
end

local Constants = safeRequire("core.constants")
local Utils = safeRequire("utils.utils")
local ESP = safeRequire("modules.esp")
local Aimbot = safeRequire("modules.aimbot")
local SilentAim = safeRequire("modules.silent_aim")
local Movement = safeRequire("modules.movement")
local Defense = safeRequire("modules.defense")
local Visuals = safeRequire("modules.visuals")
local MainGui = safeRequire("ui.main_gui")
local Config    = safeRequire("config.config")

local Services = Constants.Services
local State = Constants.State

-- [[ BOOTSTRAP ]]
local function bootstrap()
    -- Initialize Modules
    ESP.initialize()
    Aimbot.initialize()
    SilentAim.initialize()
    Movement.initialize()
    Defense.initialize()
    Visuals.initialize()
    
    -- Initialize GUI
    local mainFrame, pages, overlay = MainGui.initialize()
    
    -- Load Pages
    -- Note: UI pages in modular version are just functions that render content
    safeRequire("ui.pages.aimbot").render(pages["Aimbot"])
    safeRequire("ui.pages.visuals").render(pages["Visuals"])
    safeRequire("ui.pages.misc").render(pages["Misc"])
    safeRequire("ui.pages.settings").render(pages["Settings"])

    -- Auto-load config if exists
    task.spawn(function()
        task.wait(0.5)
        Config.loadConfig()
    end)
    
    -- Welcome notification
    task.spawn(function()
        task.wait(1)
        local notification = Instance.new("ScreenGui", Services.CoreGui)
        notification.Name = "WelcomeNotif"
        
        local notifFrame = Instance.new("Frame", notification)
        notifFrame.Size = UDim2.new(0, 350, 0, 80); notifFrame.Position = UDim2.new(0.5, -175, 0, -100)
        notifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", notifFrame)
        local stroke = Instance.new("UIStroke", notifFrame)
        stroke.Color = Color3.fromRGB(220, 220, 220); stroke.Thickness = 1.5; stroke.Transparency = 0.3
        
        local notifText = Instance.new("TextLabel", notifFrame)
        notifText.Size = UDim2.new(1, -20, 1, -20); notifText.Position = UDim2.new(0, 10, 0, 10)
        notifText.BackgroundTransparency = 1; notifText.Text = "MULTIHACK LOADED\nPress INSERT to open menu"
        notifText.Font = Enum.Font.GothamBold; notifText.TextSize = 16; notifText.TextColor3 = Color3.fromRGB(240, 240, 240)
        
        Services.TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -175, 0, 20)}):Play()
        task.wait(4)
        Services.TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -175, 0, -100)}):Play()
        task.wait(0.5); notification:Destroy()
    end)

    -- Final Print Statements
    print("\n")
    print("╔══════════════════════════════════════════════╗")
    print("║  ⚡ ULTIMATE MULTIHACK v2.3 OPTIMIZED ⚡     ║")
    print("╠══════════════════════════════════════════════╣")
    print("║  ✨ Features Loaded:                         ║")
    print("║  📦 ESP | 🎯 TRIGGER | 🔫 AIMBOT | ⚡ SILENT   ║")
    print("║  🚀 DODGE | 🏃 SPEED | 💾 CONFIG | 🎨 UI      ║")
    print("╠══════════════════════════════════════════════╣")
    print("║  ⌨️  Controls:                               ║")
    print("║  INSERT / RSHIFT - Toggle GUI Menu          ║")
    print("║  H - Quick Trigger | Z - Quick Aimbot       ║")
    print("╚══════════════════════════════════════════════╝")
    print("\n✅ All systems operational!")
end

bootstrap()
