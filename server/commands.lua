-- Texture reload command registration (QBox)

lib.addCommand('reloadtex', {
    help = 'Reload textures within render distance',
    restricted = nil
}, function(source, args)
    TriggerClientEvent('404_reloadTexture:start', source)
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
        { name = 'setting', help = 'render | batch | concurrent | delay | status', type = 'string', optional = false },
        { name = 'value', help = 'numeric value (optional for status)', type = 'number', optional = true }
    },
    restricted = 'group.admin'
}, function(source, args)
    if args.setting == 'status' then
        TriggerClientEvent('404_reloadTexture:config', source, 'status')
    else
        if not args.value then
            TriggerEvent('chat:addMessage', {
                args = {"Textures", "Value required for " .. args.setting}
            })
            return
        end
        TriggerClientEvent('404_reloadTexture:config', source, args.setting, args.value)
    end
end)
