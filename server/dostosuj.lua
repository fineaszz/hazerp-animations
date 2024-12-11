ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('haze-anims:syncPlayer')
AddEventHandler('haze-anims:syncPlayer', function(crds, heading)
    local src = source
    TriggerClientEvent('haze-anims:syncPlayerClient', -1, src, crds, heading)
end)
