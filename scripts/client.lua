CreateThread(function()
    for k, v in ipairs(Config.CityHallNPC) do
        local ModelHashKey = GetHashKey(v.model)
        RequestModel(ModelHashKey)
        while not HasModelLoaded(ModelHashKey) do
            Wait(1)
        end

        local npc = CreatePed(2, v.model, v.location.x, v.location.y, (v.location.z - 1), v.heading,  false, true)
            
        SetPedFleeAttributes(npc, 0, false)
        SetPedDropsWeaponsWhenDead(npc, false)
        SetPedDiesWhenInjured(npc, false)
        SetEntityInvincible(npc , true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_CLIPBOARD', 0, true)

        exports.ox_target:addBoxZone({
            coords = vec3(v.location.x, v.location.y, v.location.z),
            size = vec3(1, 1, 1),
            rotation = 45,
            options = {
                {
                    serverEvent = 'nw-license:server:menuElements',
                    distance = v.targetDistance,
                    icon = 'fa fa-city',
                    label = Config.Locales['open_city_hall'],
                },
            }
        })
    end
end)

RegisterNetEvent('nw-license:client:OpenContextMenu', function(data)
    local registeredContext = {
        title = Config.Locales['license_center'],
        id = 'nw-license:licenses',
        options = data.elements
    }

    lib.registerContext(registeredContext)
    lib.showContext(registeredContext.id)
end)
