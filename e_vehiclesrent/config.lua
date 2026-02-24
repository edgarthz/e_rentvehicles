Config = {}

-- ══════════════════════════════════════
--  GENERAL SETTINGS
-- ══════════════════════════════════════

Config.Locale      = 'es'               -- 'es' or 'en'
Config.PlateText   = 'RENT'             -- License plate text for rented vehicles
Config.MaxRentals  = 2                  -- Max simultaneous rentals per player
Config.DrawDistance = 1.5               -- Distance to show interaction prompt
Config.NpcModel    = 's_m_y_valet_01'   -- NPC ped model

-- ══════════════════════════════════════
--  RENT POINTS
-- ══════════════════════════════════════
--  Each point has:
--    label     = Display name (shown on blip & NUI header)
--    npcPos    = NPC position (vector4)
--    spawnPos  = Vehicle spawn position (vector4)
--    blip      = Show blip on map (true/false)
--    vehicles  = List of rentable vehicles
--      model   = GTA vehicle model name
--      label   = Display name
--      price   = Price per 10 minutes (0 = free)
--      image   = (optional) Image filename in html/img/ folder

Config.RentPoints = {
    {
        label    = 'Ayuntamiento LS',
        npcPos   = vector4(-517.7, -251.1, 35.70, 210.0),
        spawnPos = vector4(-536.7, -271.54, 35.17, 180.0),
        blip     = true,
        vehicles = {
            { model = 'bmx',     label = 'Bicicleta',      price = 0, image = 'bmx.png' },
            { model = 'faggio',  label = 'Faggio',         price = 3, image = 'faggio.png' },
            { model = 'faggio2', label = 'Faggio Sport',   price = 5, image = 'faggio.png' },
        }
    },
    {
        label    = 'Paleto Bay',
        npcPos   = vector4(-245.61, 6198.62, 31.49, 134.0),
        spawnPos = vector4(-238.48, 6196.10, 30.48, 134.24),
        blip     = true,
        vehicles = {
            { model = 'faggio', label = 'Faggio',     price = 1 },
            { model = 'bmx',    label = 'Bicicleta',  price = 0 },
        }
    },
    {
        label    = 'Del Perro Pier',
        npcPos   = vector4(-1565.28, -917.09, 13.02, 90.0),
        spawnPos = vector4(-1559.3, -924.67, 12.68, 90.0),
        blip     = true,
        vehicles = {
            { model = 'faggio', label = 'Faggio', price = 1 },
        }
    },
    {
        label    = 'Sandy Shores',
        npcPos   = vector4(1933.285, 3263.22, 45.73, 220.0),
        spawnPos = vector4(1940.21, 3269.51, 45.70, 220.0),
        blip     = true,
        vehicles = {
            { model = 'faggio', label = 'Faggio', price = 1 },
            { model = 'bf400',  label = 'BF400',  price = 5 },
        }
    },
    {
        label    = 'Cayo Perico',
        npcPos   = vector4(4517.430, -4493.10, 4.18, 220.0),
        spawnPos = vector4(4526.948, -4529.0, 4.14, 220.0),
        blip     = true,
        vehicles = {
            { model = 'mesa3',    label = 'Mesa',     price = 1 },
            { model = 'bf400',    label = 'BF400',    price = 1 },
            { model = 'maverick', label = 'Maverick', price = 10 },
        }
    },
    {
        label    = 'Aeropuerto LSIA',
        npcPos   = vector4(-1010.71, -2696.58, 13.00, 80.0),
        spawnPos = vector4(-1020.50, -2690.93, 13.00, 223.85),
        blip     = true,
        vehicles = {
            { model = 'faggio', label = 'Faggio', price = 0 },
        }
    },
}