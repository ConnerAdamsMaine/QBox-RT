-- Texture reloader configuration

local Config = {
    -- Render distance settings
    renderDistance = {
        default = 200.0,
        min = 50.0,
        max = 1000.0,
        description = "Distance in meters to scan for entities"
    },
    
    -- Batch processing settings
    batchSize = {
        default = 5,
        min = 1,
        max = 20,
        description = "Number of textures to load per batch"
    },
    
    -- Concurrent request limiting
    maxConcurrent = {
        default = 10,
        min = 1,
        max = 50,
        description = "Maximum concurrent texture requests"
    },
    
    -- Timing settings
    requestDelay = {
        default = 100,
        min = 10,
        max = 5000,
        description = "Milliseconds between batch requests"
    },
    
    modelLoadTimeout = {
        default = 100,
        min = 10,
        max = 1000,
        description = "Timeout in 10ms intervals for model loading"
    },
    
    -- Feature flags
    features = {
        progressUpdates = true,
        autoCleanup = true,
        sortByDistance = true
    }
}

-- Validate and clamp settings within min/max
local function ValidateSetting(key, value)
    if not Config[key] then
        return nil, "Setting '" .. key .. "' does not exist"
    end
    
    local setting = Config[key]
    if type(setting) ~= "table" or not setting.min or not setting.max then
        return nil, "Setting '" .. key .. "' is not configurable"
    end
    
    local clamped = math.max(setting.min, math.min(setting.max, value))
    return clamped, nil
end

-- Get current setting value
local function GetSetting(key)
    if not Config[key] then return nil end
    
    if type(Config[key]) == "table" and Config[key].default then
        return Config[key].default
    end
    
    return Config[key]
end

-- Set setting with validation
local function SetSetting(key, value)
    local clamped, err = ValidateSetting(key, value)
    if err then return false, err end
    
    Config[key].default = clamped
    return true, clamped
end

-- Get all settings as flat table
local function GetAll()
    local result = {}
    for key, setting in pairs(Config) do
        if type(setting) == "table" and setting.default then
            result[key] = setting.default
        elseif type(setting) == "table" and setting.features then
            result[key] = setting
        end
    end
    return result
end

-- Reset to defaults
local function ResetToDefaults()
    for key, setting in pairs(Config) do
        if type(setting) == "table" and setting.default then
            setting.default = setting.__original or setting.default
        end
    end
end

return {
    Config = Config,
    GetSetting = GetSetting,
    SetSetting = SetSetting,
    ValidateSetting = ValidateSetting,
    GetAll = GetAll,
    ResetToDefaults = ResetToDefaults
}
