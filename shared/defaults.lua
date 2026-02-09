-- User-editable configuration defaults for 404_reloadTexture
-- Modify these values to customize resource behavior
-- All values are validated and clamped within safe limits

return {
    -- Render distance in meters - scan radius for entities
    -- Min: 50m | Max: 1000m | Default: 200m
    renderDistance = 200.0,
    
    -- Batch size - number of textures to load per cycle
    -- Min: 1 | Max: 20 | Default: 5
    batchSize = 5,
    
    -- Maximum concurrent texture requests
    -- Min: 1 | Max: 50 | Default: 10
    -- Higher = more performance impact but faster reload
    maxConcurrent = 10,
    
    -- Delay in milliseconds between batch cycles
    -- Min: 10ms | Max: 5000ms | Default: 100ms
    -- Helps prevent server/client lag spikes
    requestDelay = 100,
    
    -- Model loading timeout in 10ms intervals (max 100 = 1 second)
    -- Min: 10 | Max: 1000 | Default: 100
    modelLoadTimeout = 100,
    
    -- Feature flags
    features = {
        -- Automatically unload models after reloading to free memory
        autoCleanup = true,
        
        -- Send progress updates to chat
        progressUpdates = true,
        
        -- Sort entities by distance (closest first)
        sortByDistance = true
    }
}
