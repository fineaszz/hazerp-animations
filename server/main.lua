ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("haze-animations:server:requestSynced")
AddEventHandler("haze-animations:server:requestSynced", function(targetId, data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if targetPlayer then
        TriggerClientEvent('haze-animations:client:syncRequest', targetId, src, data)
    else
        TriggerClientEvent('esx:showNotification', src, 'Gracz nie jest dostępny')
    end
end)

RegisterNetEvent("haze-animations:server:syncResponse")
AddEventHandler("haze-animations:server:syncResponse", function(sourceId, accepted, data)
    local src = source
    if accepted then
        TriggerClientEvent('haze-animations:client:playSyncedSource', sourceId, data.keyword, src)
        TriggerClientEvent('haze-animations:client:playSynced', src, data.keyword, sourceId)
    else
        TriggerClientEvent('esx:showNotification', sourceId, 'Gracz odrzucił twoją prośbę')
    end
end)

RegisterNetEvent("haze-animations:server:syncPtfx")
AddEventHandler("haze-animations:server:syncPtfx", function(PtfxAsset, PtfxName, offset, rot, PtfxBone, PtfxScale, PtfxColor)
    local src = source
    local playerState = Player(src).state
    playerState:set('ptfxAsset', PtfxAsset, true)
    playerState:set('ptfxName', PtfxName, true)
    playerState:set('ptfxOffset', offset, true)
    playerState:set('ptfxRot', rot, true)
    playerState:set('ptfxBone', PtfxBone, true)
    playerState:set('ptfxScale', PtfxScale, true)
    playerState:set('ptfxColor', PtfxColor, true)
end)

RegisterNetEvent("haze-animations:server:syncPtfxProp")
AddEventHandler("haze-animations:server:syncPtfxProp", function(propNet)
    local src = source
    local playerState = Player(src).state
    playerState:set('ptfxPropNet', propNet, true)
end)

RegisterNetEvent("haze-animations:server:stopSynced")
AddEventHandler("haze-animations:server:stopSynced", function(targetId)
    local src = source
    TriggerClientEvent('haze-animations:client:stopSynced', targetId, src)
end)
