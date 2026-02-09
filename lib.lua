-- Main API export for 404_reloadTexture

local TextureReloader = require('client.textures')
local Config = require('shared.config')

return {
    -- Reloader functions
    Start = function() TextureReloader:Start() end,
    Stop = function() TextureReloader:Stop() end,
    
    -- Configuration functions
    SetRenderDistance = function(distance) return TextureReloader:SetRenderDistance(distance) end,
    SetBatchSize = function(size) return TextureReloader:SetBatchSize(size) end,
    SetMaxConcurrent = function(count) return TextureReloader:SetMaxConcurrent(count) end,
    SetRequestDelay = function(delay) return TextureReloader:SetRequestDelay(delay) end,
    
    -- Config getters
    GetConfig = function() return TextureReloader:GetConfig() end,
    GetSetting = function(key) return Config.GetSetting(key) end,
    
    -- Direct access
    TextureReloader = TextureReloader,
    Config = Config
}
