-- [[ ACC UNIVERSAL GITHUB LOADER v3.0 - FINAL ]]
-- The definitive way to run the modular Zyntaros Script from GitHub

local BASE_URL = "https://raw.githubusercontent.com/jdjdhdcbfgghh8845/Zyntaros_script/main/"
local CACHE = {}

-- [[ CLOUD REQUIRE SYSTEM ]]
local function cloudRequire(modulePath)
    -- Normalize the path
    local fileName = ""
    if type(modulePath) == "string" then
        fileName = modulePath:gsub("%.", "/") .. ".lua"
    elseif type(modulePath) == "table" and modulePath.__path then
        fileName = modulePath.__path .. ".lua"
    else
        error("[ACC LOADER] Invalid require call. Use require(\"path.to.module\") or require(script.Module)")
    end
    
    if CACHE[fileName] then return CACHE[fileName] end
    
    local fullUrl = BASE_URL .. fileName
    local success, source = pcall(function() return game:HttpGet(fullUrl) end)
    
    if not success or not source or source:find("404") then
        error("[ACC LOADER] Failed to fetch: " .. fileName)
    end
    
    local func, err = loadstring(source)
    if not func then error("[ACC LOADER] Syntax Error in " .. fileName .. ": " .. err) end
    
    -- [[ VIRTUAL SCRIPT ENVIRONMENT ]]
    -- We inject a 'script' object into each loaded module's environment
    local function createVirtualScript(path)
        local vs = { __path = path, Name = path:match("([^/]+)$") }
        setmetatable(vs, {
            __index = function(t, k)
                if k == "Parent" then
                    local parentPath = path:match("(.+)/[^/]+$") or ""
                    return createVirtualScript(parentPath)
                end
                -- script.NameOfModule
                return createVirtualScript(path .. (path == "" and "" or "/") .. k)
            end
        })
        return vs
    end
    
    local modEnv = getfenv(func)
    modEnv.script = createVirtualScript(fileName:gsub("%.lua$", ""))
    modEnv.require = cloudRequire
    setfenv(func, modEnv)
    
    -- Execute and cache
    local result = func()
    CACHE[fileName] = result
    return result
end

-- [[ BOOTSTRAP ]]
print("[ACC] 🚀 Initializing Modular Injection from GitHub...")
getgenv().require = cloudRequire

local success, err = pcall(function()
    cloudRequire("init")
end)

if not success then
    warn("[ACC LOADER] CRITICAL ERROR: " .. tostring(err))
end
