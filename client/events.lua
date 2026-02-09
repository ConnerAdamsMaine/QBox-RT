-- Client-side event handlers for texture reloading

local TextureReloader = require('textures')

RegisterNetEvent('404_reloadTexture:start', function()
    TextureReloader:Start()
end)

RegisterNetEvent('404_reloadTexture:stop', function()
    TextureReloader:Stop()
end)

RegisterNetEvent('404_reloadTexture:config', function(setting, value)
    if setting == 'render' then
        TextureReloader:SetRenderDistance(value)
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Render distance set to " .. value .. "m"}
        })
    elseif setting == 'batch' then
        TextureReloader:SetBatchSize(value)
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Batch size set to " .. value}
        })
    elseif setting == 'concurrent' then
        TextureReloader:SetMaxConcurrent(value)
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Max concurrent set to " .. value}
        })
    end
end)
