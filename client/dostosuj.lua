anims = {
    playerPed = nil,
    playerPedCoords = nil,
    utils = {
        menuOn = false,
        speed = 0.01, -- szybkosc WASD + strzalki gora/dol
        headingSpeed = 0.5, -- szybkosc strzalki lewo/prawo
        maxDistance = 5.0, -- maksymalny dystans (zeby gracz nie mogl za daleko uciec)
        pressed = IsControlPressed,
        notifyon = false
    },
    initVars = function() anims.playerPed = PlayerPedId() end,
    showHelpNotification = function(value)
        Main.NUI.SendNUIMessage('helpnotify', {status = value})
    end,
    updateNotifyState = function(state)
        anims.utils.notifyon = not anims.utils.notifyon
    end,
    --[[callback = function(message)
         po ucieknieciu
        ESX.ShowNotification(message)
    end,]]
    processStarted = function(ped, startcrds)
        while true do
            if (anims.utils.menuOn) then
                local dist = #(GetEntityCoords(ped) - startcrds)
                if (dist > anims.utils.maxDistance) then
                    print(json.encode(startcrds))
                    SetEntityCoordsNoOffset(ped, startcrds, true, true, true)
                end
            else
                break
                Wait(1000)
            end
            Wait(500)
        end
    end,
    keepFlying = function(ped, crds)
        FreezeEntityPosition(ped, true)
        TriggerServerEvent('haze-anims:syncPlayer', crds, GetEntityHeading(ped))
    end
}

AddEventHandler('playerSpawned', function()
    SetTimeout(1000, function() anims.initVars() end)
end)

RegisterCommand('dostosuj', function()
    if Main.Data.PlayingAnim == false then return end
    Main.Data.DostosujOpen = not Main.Data.DostosujOpen
    anims.playerPed = PlayerPedId()
    if Main.Data.DostosujOpen then
        local coords = GetEntityCoords(anims.playerPed)
        local heading = GetEntityHeading(anims.playerPed)
        Main.Data.ClonedPlayer = ClonePed(anims.playerPed, false, false, true)
        if coords.x == 0 and coords.y == 0 and coords.z == 0 then
            return
        end

        SetEntityCoords(Main.Data.ClonedPlayer, coords.x, coords.y, coords.z - 1)
        SetEntityHeading(Main.Data.ClonedPlayer, heading)
        SetEntityAlpha(anims.playerPed, 200, false)

        FreezeEntityPosition(Main.Data.ClonedPlayer, true)

        Main.PlayAnimation(Main.Data.CurrentAnim, Main.Data.ClonedPlayer)
        anims.playerPedCoords = coords
    else
        DeleteEntity(Main.Data.ClonedPlayer)
        Main.Data.ClonedPlayer = nil
        SetEntityAlpha(anims.playerPed, 255, false)
    end

    FreezeEntityPosition(anims.playerPed, not anims.utils.menuOn)
    SetEntityDynamic(anims.playerPed, anims.utils.menuOn)
    SetEntityCollision(anims.playerPed, anims.utils.menuOn, anims.utils.menuOn)
    SetEntityCompletelyDisableCollision(anims.playerPed, anims.utils.menuOn,
                                        anims.utils.menuOn)
    if (anims.utils.menuOn) then
        anims.showHelpNotification(false)
        anims.keepFlying(anims.playerPed, GetEntityCoords(anims.playerPed))
    else
        anims.showHelpNotification(true)
    end
    anims.utils.menuOn = not anims.utils.menuOn
    anims.processStarted(anims.playerPed, GetEntityCoords(anims.playerPed))
    local x, y, z = table.unpack(GetEntityCoords(anims.playerPed))
    if (anims.utils.notifyon == true) then
        anims.updateNotifyState(not anims.utils.notifyon)
    end
end)

RegisterCommand('closedostosuj', function()
    if Main.Data.DostosujOpen == false then return end

    Main.Data.DostosujOpen = false

    DeleteEntity(Main.Data.ClonedPlayer)
    Main.Data.ClonedPlayer = nil
    SetEntityAlpha(anims.playerPed, 255, false)

    FreezeEntityPosition(anims.playerPed, not anims.utils.menuOn)

    SetEntityDynamic(anims.playerPed, anims.utils.menuOn)
    SetEntityCollision(anims.playerPed, anims.utils.menuOn, anims.utils.menuOn)
    SetEntityCompletelyDisableCollision(anims.playerPed, anims.utils.menuOn,
                                        anims.utils.menuOn)

    anims.showHelpNotification(false)

    anims.utils.menuOn = false

    anims.processStarted(anims.playerPed, GetEntityCoords(anims.playerPed))

    SetEntityCoordsNoOffset(anims.playerPed, anims.playerPedCoords.x, anims.playerPedCoords.y, anims.playerPedCoords.z, true, true, true)
end)

RegisterCommand('canceldostosuj', function()
    if Main.Data.DostosujOpen == true then return end
    FreezeEntityPosition(anims.playerPed, false)
end)
RegisterKeyMapping('canceldostosuj', 'Anuluje freeze z /dostosuj', 'keyboard',
                   'x')


CreateThread(function()
    while true do
        if (anims.utils.menuOn) then
            local playercoords, newplayercoords = GetEntityCoords(
                                                      anims.playerPed), nil
            local heading, newheading = GetEntityHeading(anims.playerPed), nil
            if anims.utils.pressed(0, 31) then
                newplayercoords = GetOffsetFromEntityInWorldCoords(
                                      anims.playerPed, 0.0, -anims.utils.speed,
                                      0.0)
            elseif anims.utils.pressed(0, 32) then
                newplayercoords = GetOffsetFromEntityInWorldCoords(
                                      anims.playerPed, 0.0, anims.utils.speed,
                                      0.0)
            elseif anims.utils.pressed(0, 34) then
                newplayercoords = GetOffsetFromEntityInWorldCoords(
                                      anims.playerPed, -anims.utils.speed, 0.0,
                                      0.0)
            elseif anims.utils.pressed(0, 35) then
                newplayercoords = GetOffsetFromEntityInWorldCoords(
                                      anims.playerPed, anims.utils.speed, 0.0,
                                      0.0)
            elseif anims.utils.pressed(0, 174) then
                if (newheading == nil) then
                    newheading = GetEntityHeading(anims.playerPed)
                end
                newheading = newheading + anims.utils.headingSpeed
                if (newheading > 360) then
                    newheading = newheading - 360
                end
            elseif anims.utils.pressed(0, 175) then
                if (newheading == nil) then
                    newheading = GetEntityHeading(anims.playerPed)
                end
                newheading = newheading - anims.utils.headingSpeed
                if (newheading < 0) then
                    newheading = newheading + 360
                end
            elseif anims.utils.pressed(0, 172) then
                newplayercoords = GetOffsetFromEntityInWorldCoords(
                                      anims.playerPed, 0.0, 0.0,
                                      anims.utils.speed)
            elseif anims.utils.pressed(0, 173) then
                newplayercoords = GetOffsetFromEntityInWorldCoords(
                                      anims.playerPed, 0.0, 0.0,
                                      -anims.utils.speed)
            elseif anims.utils.pressed(0, 191) then
                ExecuteCommand('dostosuj')
                Wait(500)
            end

            if (newplayercoords) then
                if (newplayercoords.z == 0) then
                    newplayercoords = anims.playerPedCoords
                end
                SetEntityCoordsNoOffset(anims.playerPed, newplayercoords.x, newplayercoords.y, newplayercoords.z, true, true, true)
            end
            if (newheading) then
                SetEntityHeading(anims.playerPed, newheading)
            end

            if (newplayercoords) then
                local foundground, ground =
                    GetGroundZFor_3dCoord(newplayercoords.x, newplayercoords.y,
                                          newplayercoords.z, 0.0)
                if (foundground) then
                    if (ground - newplayercoords.z) > 5.0 or (ground - newplayercoords.z) < -5.0 then
                        print(2, newplayercoords.x, newplayercoords.y, ground + 1.0)
                        SetEntityCoordsNoOffset(anims.playerPed, newplayercoords.x, newplayercoords.y, ground + 1.0, true, true, true)
                    end
                end
            end

            DisableControlAction(0, 200, true)
            DisableControlAction(0, 202, true)
        else
            Wait(1000)
        end
        -- wait moze byc troche za duzy, ale 20 powinno byc G (zalezy od preferencji)
        Wait(1)
    end
end)

RegisterNetEvent('haze-anims:syncPlayerClient', function(ped, crds, heading)
    local networkedPlayer = NetToPed(ped)
    SetEntityCoordsNoOffset(networkedPlayer, crds.x, crds.y, crds.z, true, true,
                            true)
    SetEntityHeading(networkedPlayer, heading)
end)
