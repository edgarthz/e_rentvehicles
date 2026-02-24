# e_vehiclesrent

A vehicle rental system for **FiveM** servers running **ESX Legacy**. Players can rent vehicles from NPC points across the map through a clean, modern NUI interface.

![FiveM](https://img.shields.io/badge/FiveM-ESX%20Legacy-blue)
![Lua](https://img.shields.io/badge/Lua-5.4-purple)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **NPC Rental Points** — Configurable NPC locations across the map with automatic ped spawning and blips
- **Modern NUI** — Minimalist blue glassmorphism UI with smooth animations
- **Timed Rentals** — Duration slider (10 min increments, up to 2 hours), vehicles auto-delete on expiry
- **Timer HUD** — On-screen countdown for each active rental with warning state when < 2 min remaining
- **Free & Paid** — Support for free vehicles (e.g. bicycles) and priced rentals deducted from player cash
- **Multi-language** — Built-in locale system (`es` / `en`) — switch with a single config line
- **Vehicle Images** — Optional thumbnail images per vehicle in the NUI card list
- **Max Rentals** — Configurable limit on simultaneous rentals per player
- **Auto Cleanup** — Vehicles and NPCs are cleaned up on resource stop; rentals cleared on player disconnect

## Preview

| NUI Panel | Timer HUD |
|---|---|
| Vehicle selection with duration & price config | Live countdown per active rental |
| ![NUI Panel](e_rentvehicles/screenshots/nui_panel.png) | ![Timer HUD](e_rentvehicles/screenshots/timer_hud.png) |

## Dependencies

- [es_extended](https://github.com/esx-framework/esx_core) (ESX Legacy)
- [oxmysql](https://github.com/overextended/oxmysql) (not directly used, but required by ESX)

## Installation

1. **Download** or clone this repository into your server's `resources/` folder
2. **Rename** the folder to `e_vehiclesrent` (must match the resource name)
3. Add to your `server.cfg`:
   ```
   ensure e_vehiclesrent
   ```
4. Configure `config.lua` to your liking (see [Configuration](#configuration))
5. Restart your server

## Configuration

All settings are in `config.lua`:

```lua
Config.Locale      = 'es'               -- 'es' (Spanish) or 'en' (English)
Config.PlateText   = 'RENT'             -- License plate text
Config.MaxRentals  = 2                  -- Max simultaneous rentals per player
Config.DrawDistance = 1.5               -- Interaction prompt distance
Config.NpcModel    = 's_m_y_valet_01'   -- NPC ped model
```

### Adding Rental Points

```lua
Config.RentPoints = {
    {
        label    = 'Airport Rental',
        npcPos   = vector4(x, y, z, heading),
        spawnPos = vector4(x, y, z, heading),
        blip     = true,
        vehicles = {
            { model = 'faggio',  label = 'Faggio',  price = 3 },
            { model = 'bmx',     label = 'Bicycle', price = 0, image = 'bmx.png' },
        }
    },
}
```

### Vehicle Images (Optional)

1. Place `.png` images in `html/img/`
2. Reference them in config:
   ```lua
   { model = 'faggio', label = 'Faggio', price = 3, image = 'faggio.png' }
   ```

### Adding a Language

1. Create a new file in `locales/` (e.g. `locales/fr.lua`)
2. Copy the contents of `locales/en.lua` and translate the values
3. Set `Config.Locale = 'fr'` in `config.lua`

## File Structure

```
e_vehiclesrent/
├── config.lua              # All configurable settings
├── fxmanifest.lua          # Resource manifest
├── client/
│   └── main.lua            # NPC spawning, interaction, NUI control
├── server/
│   └── main.lua            # Payment, timer system, cleanup
├── locales/
│   ├── en.lua              # English
│   └── es.lua              # Spanish
└── html/
    ├── ui.html             # NUI markup
    ├── css/
    │   └── app.css         # Blue glassmorphism theme
    ├── js/
    │   └── app.js          # NUI logic, timers, locale
    └── img/                # Vehicle thumbnail images
```

## License

MIT — free to use, modify, and distribute.
