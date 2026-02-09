-- Texture reloading system
-- Limits concurrent requests and processes within render distance

local TextureReloader = {
    renderDistance = 200.0,
    batchSize = 5,
    maxConcurrent = 10,
    requestDelay = 100, -- ms between batch requests
    isReloading = false,
    processingCount = 0
}

local function GetPlayersInRenderDistance()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local playersInRange = {}

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= 0 then
            local targetCoords = GetEntityCoords(targetPed)
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

    -- Sort by distance (closest first)
    table.sort(playersInRange, function(a, b)
        return a.distance < b.distance
    end)

    return playersInRange
end

local function GetEntitiesInRenderDistance()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local entities = {}
    local handle, entity = FindFirstObject()
    local found = true

    if handle ~= -1 then
        repeat
            local entityCoords = GetEntityCoords(entity)
            local distance = #(playerCoords - entityCoords)
            
            if distance <= TextureReloader.renderDistance then
                table.insert(entities, {
                    entity = entity,
                    distance = distance,
                    model = GetEntityModel(entity)
                })
            end
            
            found, entity = FindNextObject(handle)
        until not found
        
        EndFindObject(handle)
    end

    -- Sort by distance
    table.sort(entities, function(a, b)
        return a.distance < b.distance
    end)

    return entities
end

local function ReloadModelTextures(model)
    if model == 0 then return end
    
    RequestModel(model)
    local timeout = 0
    
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if HasModelLoaded(model) then
        RebuildModel(model)
        UnloadModel(model)
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
        return
    end

    self.isReloading = true
    TriggerEvent('chat:addMessage', {
        args = {"Textures", "Starting texture reload within " .. self.renderDistance .. "m..."}
    })

    local entities = GetEntitiesInRenderDistance()
    local players = GetPlayersInRenderDistance()
    
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

    -- Process entities
    for i = 1, #entities, self.batchSize do
        if not self.isReloading then break end
        
        local batchProcessed = ProcessBatch(entities, i, self.batchSize)
        processed = processed + batchProcessed
        
        TriggerEvent('chat:addMessage', {
            args = {"Textures", ("Progress: %d/%d"):format(processed, totalToProcess)}
        })

        Wait(self.requestDelay)
        currentBatch = currentBatch + 1
    end

    -- Process player peds
    for i = 1, #players, self.batchSize do
        if not self.isReloading then break end
        
        local endIdx = math.min(i + self.batchSize - 1, #players)
        for j = i, endIdx do
            if self.processingCount >= self.maxConcurrent then break end
            
            local playerData = players[j]
            self.processingCount = self.processingCount + 1
            
            ReloadModelTextures(GetEntityModel(playerData.ped))
            
            self.processingCount = self.processingCount - 1
            processed = processed + 1
        end

        TriggerEvent('chat:addMessage', {
            args = {"Textures", ("Progress: %d/%d"):format(processed, totalToProcess)}
        })

        Wait(self.requestDelay)
    end

    self.isReloading = false
    TriggerEvent('chat:addMessage', {
        args = {"Textures", "Reload complete! (" .. processed .. " textures reloaded)"}
    })
end

function TextureReloader:Stop()
    if self.isReloading then
        self.isReloading = false
        TriggerEvent('chat:addMessage', {
            args = {"Textures", "Texture reload cancelled"}
        })
    end
end

function TextureReloader:SetRenderDistance(distance)
    self.renderDistance = distance
end

function TextureReloader:SetBatchSize(size)
    self.batchSize = math.max(1, size)
end

function TextureReloader:SetMaxConcurrent(count)
    self.maxConcurrent = math.max(1, count)
end

return TextureReloader
