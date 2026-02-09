-- Texture reload command registration (QBox)

-- Verify QBox core is loaded
if not lib or not lib.addCommand then
    print("^1[404_reloadTexture] ERROR: QBox framework not detected!^0")
    return
end

local function ValidateSource(source)
    if not source or source == 0 then
        return false
    end
    return true
end

local function ReloadTexCommand(source, args)
    if not ValidateSource(source) then
        print("^1[404_reloadTexture] Invalid source: " .. tostring(source) .. "^0")
        return
    end
    
    local success = pcall(function()
        TriggerClientEvent('404_reloadTexture:start', source)
    end)
    
    if not success then
        print("^1[404_reloadTexture] Failed to trigger start event for player " .. source .. "^0")
    end
end

lib.addCommand('reloadtex', {
    help = 'Reload textures within render distance',
    restricted = nil
}, ReloadTexCommand)

lib.addCommand('rt', {
    help = 'Reload textures within render distance (alias)',
    restricted = nil
}, ReloadTexCommand)

lib.addCommand('stoptex', {
    help = 'Stop ongoing texture reload',
    restricted = nil
}, function(source, args)
    if not ValidateSource(source) then
        print("^1[404_reloadTexture] Invalid source: " .. tostring(source) .. "^0")
        return
    end
    
    local success = pcall(function()
        TriggerClientEvent('404_reloadTexture:stop', source)
    end)
    
    if not success then
        print("^1[404_reloadTexture] Failed to trigger stop event for player " .. source .. "^0")
    end
end)

lib.addCommand('texconfig', {
    help = 'Configure texture reload settings',
    params = {
        { name = 'setting', help = 'render | batch | concurrent | delay | status', type = 'string', optional = false },
        { name = 'value', help = 'numeric value (optional for status)', type = 'number', optional = true }
    },
    restricted = 'group.admin'
}, function(source, args)
    if not ValidateSource(source) then
        print("^1[404_reloadTexture] Invalid source: " .. tostring(source) .. "^0")
        return
    end
    
    if not args or not args.setting then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Textures", "Invalid command usage"}
        })
        return
    end
    
    local setting = tostring(args.setting):lower()
    
    if setting == 'status' then
        local success = pcall(function()
            TriggerClientEvent('404_reloadTexture:config', source, 'status')
        end)
        if not success then
            print("^1[404_reloadTexture] Failed to trigger config event for player " .. source .. "^0")
        end
    else
        if not args.value then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"Textures", "Value required for " .. setting}
            })
            return
        end
        
        if type(args.value) ~= 'number' then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"Textures", "Value must be a number"}
            })
            return
        end
        
        local success = pcall(function()
            TriggerClientEvent('404_reloadTexture:config', source, setting, args.value)
        end)
        
        if not success then
            print("^1[404_reloadTexture] Failed to trigger config event for player " .. source .. "^0")
        end
    end
end)
