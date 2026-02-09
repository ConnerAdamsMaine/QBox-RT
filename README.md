# 404_reloadTexture

A FiveM texture reloading system that limits concurrent texture requests and only processes entities/players within render distance.

## Features

- **Render Distance Filtering**: Only reloads textures for entities and players within specified distance (default: 200m)
- **Batch Processing**: Loads textures in configurable batch sizes to prevent memory spikes
- **Concurrent Limiting**: Caps concurrent texture requests (default: 10) to avoid performance degradation
- **Progress Feedback**: Real-time chat feedback on reload progress
- **QBox Integration**: Uses QBox command API for seamless integration

## Commands

### `/reloadtex`
Starts texture reload for all entities and players within render distance.

```
/reloadtex
```

### `/stoptex`
Stops an ongoing texture reload operation.

```
/stoptex
```

### `/texconfig <setting> <value>` (Admin Only)
Configure texture reload behavior.

**Settings:**
- `render` - Set render distance in meters (default: 200)
- `batch` - Set batch size (default: 5)
- `concurrent` - Set max concurrent requests (default: 10)

```
/texconfig render 300
/texconfig batch 10
/texconfig concurrent 5
```

## How It Works

1. **Entity Discovery**: Scans for all objects within render distance, sorted by proximity
2. **Batch Processing**: Processes textures in configurable batch sizes
3. **Concurrent Limiting**: Never exceeds max concurrent model requests
4. **Progress Tracking**: Sends chat updates on completion percentage
5. **Cleanup**: Unloads models after reloading to free memory

## Configuration

Edit defaults in `client/textures.lua`:

```lua
local TextureReloader = {
    renderDistance = 200.0,  -- Meters
    batchSize = 5,           -- Textures per batch
    maxConcurrent = 10,      -- Max simultaneous requests
    requestDelay = 100       -- Ms between batches
}
```

## Technical Details

- **Language**: Lua 5.4
- **Framework**: QBox (QBX Core)
- **Client-side**: Event-driven texture reloading
- **Server-side**: Command registration and access control
- **Memory Safe**: Progressively reloads and unloads models to prevent memory leaks

## Installation

1. Place in your resources folder as `404_reloadTexture`
2. Ensure `qbx_core` is running
3. Add to server.cfg: `ensure 404_reloadTexture`
4. Use `/reloadtex` in-game

## Notes

- Command available to all players by default
- Admin-only configuration command: `/texconfig`
- Uses RebuildModel for efficient texture reloading
- Safe for production use with proper rate limiting
