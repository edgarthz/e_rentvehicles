local ESX = exports['es_extended']:getSharedObject()
local resourceName = GetCurrentResourceName()
local spawnedPeds = {}
local rentedVehicles = {}
local isNuiOpen = false
local currentRentPoint = nil

-- ══════════════════════════════════════
--  NPC + BLIP SPAWNING
-- ══════════════════════════════════════

Citizen.CreateThread(function()
    for i, rp in ipairs(Config.RentPoints) do
        local model = GetHashKey(Config.NpcModel)
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(10) end

        local ped = CreatePed(4, model, rp.npcPos.x, rp.npcPos.y, rp.npcPos.z - 1.0, rp.npcPos.w, false, true)
        SetEntityHeading(ped, rp.npcPos.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true)
        SetPedCanRagdoll(ped, false)
        SetModelAsNoLongerNeeded(model)

        spawnedPeds[i] = ped

        if rp.blip then
            local blip = AddBlipForCoord(rp.npcPos.x, rp.npcPos.y, rp.npcPos.z)
            SetBlipSprite(blip, 255)
            SetBlipColour(blip, 3)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Locale['blip_name'])
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- ══════════════════════════════════════
--  INTERACTION LOOP
-- ══════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        for i, rp in ipairs(Config.RentPoints) do
            local dist = #(playerCoords - vector3(rp.npcPos.x, rp.npcPos.y, rp.npcPos.z))

            if dist < Config.DrawDistance then
                sleep = 0
                SetTextComponentFormat('STRING')
                AddTextComponentString(Locale['press_to_rent'])
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                if IsControlJustPressed(0, 38) and not isNuiOpen then
                    OpenRentMenu(i)
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- ══════════════════════════════════════
--  NUI OPEN / CLOSE
-- ══════════════════════════════════════

function OpenRentMenu(rentPointIndex)
    local rp = Config.RentPoints[rentPointIndex]
    currentRentPoint = rentPointIndex
    isNuiOpen = true

    local vehicleList = {}
    for _, v in ipairs(rp.vehicles) do
        vehicleList[#vehicleList + 1] = {
            model = v.model,
            label = v.label,
            price = v.price,
            image = v.image or nil
        }
    end

    -- Build locale table for NUI
    local nuiLocale = {
        title    = Locale['nui_title'],
        free     = Locale['nui_free'],
        perUnit  = Locale['nui_per_unit'],
        duration = Locale['nui_duration'],
        total    = Locale['nui_total'],
        cancel   = Locale['nui_cancel'],
        confirm  = Locale['nui_confirm'],
        minutes  = Locale['nui_minutes'],
    }

    SetNuiFocus(true, true)
    SendNUIMessage({
        action   = 'open',
        vehicles = vehicleList,
        title    = rp.label or Locale['nui_title'],
        locale   = nuiLocale
    })
end

function CloseRentMenu()
    isNuiOpen = false
    currentRentPoint = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- ══════════════════════════════════════
--  NUI CALLBACKS
-- ══════════════════════════════════════

RegisterNUICallback('close', function(_, cb)
    CloseRentMenu()
    cb('ok')
end)

RegisterNUICallback('rent', function(data, cb)
    local rpIndex = currentRentPoint
    if not rpIndex then cb({ success = false }) return end

    local rp = Config.RentPoints[rpIndex]
    local vehicleData = nil

    for _, v in ipairs(rp.vehicles) do
        if v.model == data.model then
            vehicleData = v
            break
        end
    end

    if not vehicleData then cb({ success = false }) return end

    local duration = tonumber(data.duration) or 1
    local totalPrice = vehicleData.price * duration

    ESX.TriggerServerCallback('e_rentvehicle:rent', function(success)
        if success then
            CloseRentMenu()

            local spawnPos = rp.spawnPos
            ESX.Game.SpawnVehicle(vehicleData.model, {
                x = spawnPos.x, y = spawnPos.y, z = spawnPos.z
            }, spawnPos.w, function(veh)
                SetVehicleNumberPlateText(veh, Config.PlateText)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                rentedVehicles[#rentedVehicles + 1] = { vehicle = veh, rpIndex = rpIndex }
                ESX.ShowNotification(Locale['rent_success'])
            end)
        else
            ESX.ShowNotification(Locale['no_money'])
        end
        cb({ success = success })
    end, vehicleData.model, duration, totalPrice)
end)

-- ══════════════════════════════════════
--  RENTAL TIMER HUD
-- ══════════════════════════════════════

RegisterNetEvent('e_rentvehicle:startTimer')
AddEventHandler('e_rentvehicle:startTimer', function(totalSeconds, model)
    SendNUIMessage({
        action  = 'addTimer',
        seconds = totalSeconds,
        model   = model
    })
end)

-- ══════════════════════════════════════
--  RENTAL EXPIRY
-- ══════════════════════════════════════

RegisterNetEvent('e_rentvehicle:expireRental')
AddEventHandler('e_rentvehicle:expireRental', function()
    if #rentedVehicles > 0 then
        local rv = table.remove(rentedVehicles, 1)
        if DoesEntityExist(rv.vehicle) then
            ESX.Game.DeleteVehicle(rv.vehicle)
        end
        ESX.ShowNotification(Locale['rent_expired'])
    end
    SendNUIMessage({ action = 'removeTimer' })
end)

-- ══════════════════════════════════════
--  CLEANUP ON RESOURCE STOP
-- ══════════════════════════════════════

AddEventHandler('onResourceStop', function(res)
    if resourceName ~= res then return end

    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeletePed(ped) end
    end

    for _, rv in ipairs(rentedVehicles) do
        if DoesEntityExist(rv.vehicle) then ESX.Game.DeleteVehicle(rv.vehicle) end
    end
end)