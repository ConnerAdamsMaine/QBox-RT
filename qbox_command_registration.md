# QBox Command Registration Guide

This document explains how to register commands in **QBox (QBX Core)** for FiveM.

---

## Server-Side Command Registration

```lua
-- server/commands.lua
lib.addCommand('mycommand', {
    help = 'Description for /mycommand',
    params = {
        { name = 'arg1', help = 'First argument', type = 'string', optional = false },
        { name = 'arg2', help = 'Second argument', type = 'number', optional = true }
    },
    restricted = nil  -- nil = everyone can use it
}, function(source, args)
    local arg1 = args.arg1
    local arg2 = args.arg2

    print(('[QBox] /mycommand ran by %d with %s and %s'):format(source, tostring(arg1), tostring(arg2)))
end)
```

### Key Points
- `lib.addCommand(name, infoTable, callback)` is the QBox command API.
- `help` is the description shown in chat suggestion.
- `params` defines typed arguments.
- `restricted` controls permission: `nil` = anyone, or use permission groups like `'group.admin'`.

## Example of Parameters

```lua
params = {
    { name = 'targetId', help = 'Player server ID', type = 'number', optional = false },
    { name = 'message', help = 'Text message to send', type = 'string', optional = true }
}
```

## Restricting Commands to Admins

```lua
lib.addCommand('admincmd', {
    help = 'Admin only command',
    restricted = 'group.admin'
}, function(source, args)
    print('Admin ran the command:', source)
end)
```

## Triggering Client Logic

For commands affecting client-side logic, trigger a client event:

```lua
lib.addCommand('togglehud', {
    help = 'Toggle HUD on/off'
}, function(source)
    TriggerClientEvent('myresource:toggleHud', source)
end)
```

Client-side handler:

```lua
RegisterNetEvent('myresource:toggleHud', function()
    -- Client UI logic here
end)
```

---

**Notes:**
- QBox uses `lib.addCommand`, not `QBCore.Commands.Add`.
- All commands are generally registered server-side, even if the logic triggers client events.

