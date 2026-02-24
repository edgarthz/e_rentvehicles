local ESX = exports['es_extended']:getSharedObject()
local activeRentals = {}

-- ══════════════════════════════════════
--  RENT VEHICLE CALLBACK
-- ══════════════════════════════════════

ESX.RegisterServerCallback('e_rentvehicle:rent', function(source, cb, model, duration, totalPrice)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end

    if not activeRentals[source] then activeRentals[source] = {} end

    if #activeRentals[source] >= Config.MaxRentals then
        xPlayer.showNotification(Locale['max_rentals'])
        cb(false)
        return
    end

    -- Free rental
    if totalPrice <= 0 then
        startRentalTimer(source, model, duration)
        cb(true)
        return
    end

    -- Paid rental
    if xPlayer.getMoney() >= totalPrice then
        xPlayer.removeMoney(totalPrice)
        startRentalTimer(source, model, duration)
        cb(true)
    else
        cb(false)
    end
end)

-- ══════════════════════════════════════
--  TIMER SYSTEM
-- ══════════════════════════════════════

function startRentalTimer(source, model, duration)
    local minutes = duration * 10
    if minutes <= 0 then minutes = 60 end

    local totalSeconds = minutes * 60

    if not activeRentals[source] then activeRentals[source] = {} end

    activeRentals[source][#activeRentals[source] + 1] = {
        model     = model,
        startTime = os.time(),
        endTime   = os.time() + totalSeconds
    }

    TriggerClientEvent('e_rentvehicle:startTimer', source, totalSeconds, model)
end

-- Check timers every 60 seconds
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        local now = os.time()

        for src, rentals in pairs(activeRentals) do
            for i = #rentals, 1, -1 do
                if now >= rentals[i].endTime then
                    table.remove(rentals, i)
                    TriggerClientEvent('e_rentvehicle:expireRental', src)
                end
            end

            if #rentals == 0 then
                activeRentals[src] = nil
            end
        end
    end
end)

-- ══════════════════════════════════════
--  CLEANUP ON PLAYER DROP
-- ══════════════════════════════════════

AddEventHandler('playerDropped', function()
    activeRentals[source] = nil
end)
