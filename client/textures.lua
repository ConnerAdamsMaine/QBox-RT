-- Texture reloading system
-- Limits concurrent requests and processes within render distance

local Config = require('shared.config')
local ProgressBar = require('deps.lib')

local TextureReloader = {
    renderDistance = Config.GetSetting('renderDistance'),
    batchSize = Config.GetSetting('batchSize'),
    maxConcurrent = Config.GetSetting('maxConcurrent'),
    requestDelay = Config.GetSetting('requestDelay'),
    modelLoadTimeout = Config.GetSetting('modelLoadTimeout'),
    isReloading = false,
    processingCount = 0,
    progressBar = ProgressBar
}

local function GetPlayersInRenderDistance()
    if not PlayerPedId or PlayerPedId() == 0 then
        return {}
    end

    local ped = PlayerPedId()
    if not ped or ped == 0 then return {} end

    local playerCoords = GetEntityCoords(ped)
    if not playerCoords then return {} end

    local playersInRange = {}
    local activePlayers = GetActivePlayers()
    
    if not activePlayers or #activePlayers == 0 then
        return {}
    end

    for _, player in ipairs(activePlayers) do
        if player and player ~= 0 then
            local targetPed = GetPlayerPed(player)
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                if targetCoords then
                    local distance = #(playerCoords - targetCoords)
                    
                    if distance <= TextureReloader.renderDistance then
                        table.insert(playersInRange, {
                            player = player,
                            ped = targetPed,
                            distance = distance
                        })
                    end
                end
            end
        end
    end

    -- Sort by distance (closest first)
    table.sort(playersInRange, function(a, b)
        return a.distance < b.distance
    end)

    return playersInRange
end

local function GetEntitiesInRenderDistance()
    if not PlayerPedId or PlayerPedId() == 0 then
        return {}
    end

    local ped = PlayerPedId()
    if not ped or ped == 0 then return {} end

    local playerCoords = GetEntityCoords(ped)
    if not playerCoords then return {} end

    local entities = {}
    
    if not FindFirstObject then
        return {}
    end

    local handle, entity = FindFirstObject()
    if not handle or handle == -1 then
        return {}
    end

    local found = true
    local safety = 0
    local maxIterations = 10000

    if handle ~= -1 then
        repeat
            if not entity or entity == 0 then break end
            
            local entityCoords = GetEntityCoords(entity)
            if entityCoords then
                local distance = #(playerCoords - entityCoords)
                
                if distance <= TextureReloader.renderDistance then
                    local model = GetEntityModel(entity)
                    if model and model ~= 0 then
                        table.insert(entities, {
                            entity = entity,
                            distance = distance,
                            model = model
                        })
                    end
                end
            end
            
            found, entity = FindNextObject(handle)
            safety = safety + 1
        until not found or safety >= maxIterations
        
        if handle and handle ~= -1 then
            EndFindObject(handle)
        end
    end

    -- Sort by distance
    table.sort(entities, function(a, b)
        return a.distance < b.distance
    end)

    return entities
end

local function ReloadModelTextures(model)
    if not model or model == 0 then 
        return false
    end
    
    if not RequestModel or not HasModelLoaded then
        return false
    end

    local success = pcall(function()
        RequestModel(model)
    end)
    
    if not success then
        return false
    end

    local timeout = 0
    local maxTimeout = TextureReloader.modelLoadTimeout or 100
    
    while not HasModelLoaded(model) and timeout < maxTimeout do
        Wait(10)
        timeout = timeout + 1
    end

    if HasModelLoaded(model) then
        if RebuildModel then
            pcall(function()
                RebuildModel(model)
            end)
        end
        
        local features = Config.GetSetting('features')
        if features and features.autoCleanup and UnloadModel then
            pcall(function()
                UnloadModel(model)
            end)
        end
        return true
    end
    
    return false
end

local function ProcessBatch(entities, startIdx, batchSize)
    local processed = 0
    local endIdx = math.min(startIdx + batchSize - 1, #entities)

    for i = startIdx, endIdx do
        if TextureReloader.processingCount >= TextureReloader.maxConcurrent then
            break
        end

        local entityData = entities[i]
        TextureReloader.processingCount = TextureReloader.processingCount + 1
        
        ReloadModelTextures(entityData.model)
        
        TextureReloader.processingCount = TextureReloader.processingCount - 1
        processed = processed + 1
    end

    return processed
end

function TextureReloader:Start()
    if self.isReloading then
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Reload already in progress..."}
        })
        return false
    end

    local success = pcall(function()
        self.isReloading = true
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Starting texture reload within " .. self.renderDistance .. "m..."}
        })

        local entities = GetEntitiesInRenderDistance()
        local players = GetPlayersInRenderDistance()
        
        if not entities or not players then
            entities = entities or {}
            players = players or {}
        end
        
        if #entities == 0 and #players == 0 then
            TriggerEvent('chat:addMessage', {
                args = {"Textures", "No entities or players in render distance"}
            })
            self.isReloading = false
            return
        end

        local totalToProcess = #entities + #players
        local processed = 0
        local currentBatch = 1

        -- Start progress bar
        if self.progressBar and self.progressBar.Start then
            self.progressBar:Start(totalToProcess * 0.1, "Reloading textures...")
        end

        -- Process entities
        for i = 1, #entities, self.batchSize do
            if not self.isReloading then break end
            
            local batchProcessed = ProcessBatch(entities, i, self.batchSize) or 0
            processed = processed + batchProcessed
            
            -- Update progress bar and chat
            if self.progressBar and self.progressBar.SetProgress then
                self.progressBar:SetProgress(processed, totalToProcess)
            end
            TriggerEvent('chat:addMessage', {
                args = {"Textures", ("Progress: %d/%d"):format(processed, totalToProcess)}
            })

            Wait(self.requestDelay or 100)
            currentBatch = currentBatch + 1
        end

        -- Process player peds
        for i = 1, #players, self.batchSize do
            if not self.isReloading then break end
            
            local endIdx = math.min(i + self.batchSize - 1, #players)
            for j = i, endIdx do
                if self.processingCount >= self.maxConcurrent then break end
                
                local playerData = players[j]
                if playerData and playerData.ped then
                    self.processingCount = self.processingCount + 1
                    
                    local model = GetEntityModel(playerData.ped)
                    ReloadModelTextures(model)
                    
                    self.processingCount = self.processingCount - 1
                    processed = processed + 1
                end
            end

            -- Update progress bar and chat
            if self.progressBar and self.progressBar.SetProgress then
                self.progressBar:SetProgress(processed, totalToProcess)
            end
            TriggerEvent('chat:addMessage', {
                args = {"Textures", ("Progress: %d/%d"):format(processed, totalToProcess)}
            })

            Wait(self.requestDelay or 100)
        end

        self.isReloading = false
        if self.progressBar and self.progressBar.Stop then
            self.progressBar:Stop()
        end
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Reload complete! (" .. processed .. " textures reloaded)"}
        })
    end)
    
    if not success then
        self.isReloading = false
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "^1Error during reload process^0"}
        })
        return false
    end
    
    return true
end

function TextureReloader:Stop()
    if self.isReloading then
        self.isReloading = false
        self.progressBar:Stop()
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Texture reload cancelled"}
        })
    end
end

function TextureReloader:SetRenderDistance(distance)
    if not distance or type(distance) ~= 'number' then
        return false, nil
    end
    
    local success, clamped = Config.SetSetting('renderDistance', distance)
    if success then
        self.renderDistance = clamped
    end
    return success, clamped
end

function TextureReloader:SetBatchSize(size)
    if not size or type(size) ~= 'number' then
        return false, nil
    end
    
    local success, clamped = Config.SetSetting('batchSize', size)
    if success then
        self.batchSize = clamped
    end
    return success, clamped
end

function TextureReloader:SetMaxConcurrent(count)
    if not count or type(count) ~= 'number' then
        return false, nil
    end
    
    local success, clamped = Config.SetSetting('maxConcurrent', count)
    if success then
        self.maxConcurrent = clamped
    end
    return success, clamped
end

function TextureReloader:SetRequestDelay(delay)
    if not delay or type(delay) ~= 'number' then
        return false, nil
    end
    
    local success, clamped = Config.SetSetting('requestDelay', delay)
    if success then
        self.requestDelay = clamped
    end
    return success, clamped
end

function TextureReloader:GetConfig()
    return Config.GetAll()
end

return TextureReloader
