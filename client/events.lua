-- Client-side event handlers for texture reloading

local TextureReloader = require('textures')

RegisterNetEvent('404_reloadTexture:start', function()
    TextureReloader:Start()
end)

RegisterNetEvent('404_reloadTexture:stop', function()
    TextureReloader:Stop()
end)

RegisterNetEvent('404_reloadTexture:config', function(setting, value)
    local success, result = false, nil
    
    if setting == 'render' then
        success, result = TextureReloader:SetRenderDistance(value)
        if success then
            TriggerEvent('chat:addMessage', {
                args = {"Textures", "Render distance: " .. result .. "m"}
            })
        end
    elseif setting == 'batch' then
        success, result = TextureReloader:SetBatchSize(value)
        if success then
            TriggerEvent('chat:addMessage', {
                args = {"Textures", "Batch size: " .. result}
            })
        end
    elseif setting == 'concurrent' then
        success, result = TextureReloader:SetMaxConcurrent(value)
        if success then
            TriggerEvent('chat:addMessage', {
                args = {"Textures", "Max concurrent: " .. result}
            })
        end
    elseif setting == 'delay' then
        success, result = TextureReloader:SetRequestDelay(value)
        if success then
            TriggerEvent('chat:addMessage', {
                args = {"Textures", "Request delay: " .. result .. "ms"}
            })
        end
    elseif setting == 'status' then
        local config = TextureReloader:GetConfig()
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Distance: " .. config.renderDistance .. "m | Batch: " .. config.batchSize .. " | Concurrent: " .. config.maxConcurrent}
        })
    else
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Unknown setting: " .. setting}
        })
    end
    
    if not success and result == nil then
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Invalid value for " .. setting}
        })
    end
end)
