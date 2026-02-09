-- Texture reload command registration (QBox)

lib.addCommand('reloadtex', {
    help = 'Reload textures within render distance (limit: 10 concurrent)',
    restricted = nil
}, function(source, args)
    TriggerClientEvent('404_reloadTexture:start', source)
    TriggerEvent('chat:addMessage', {
        args = {"Server", ("Player %d initiated texture reload"):format(source)}
    })
end)

lib.addCommand('stoptex', {
    help = 'Stop ongoing texture reload',
    restricted = nil
}, function(source, args)
    TriggerClientEvent('404_reloadTexture:stop', source)
end)

lib.addCommand('texconfig', {
    help = 'Configure texture reload settings',
    params = {
        { name = 'setting', help = 'render | batch | concurrent', type = 'string', optional = false },
        { name = 'value', help = 'numeric value', type = 'number', optional = false }
    },
    restricted = 'group.admin'
}, function(source, args)
    TriggerClientEvent('404_reloadTexture:config', source, args.setting, args.value)
end)
