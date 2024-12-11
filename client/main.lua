Main = {
    Data = {
        CurrentAnim = nil,
        DostosujOpen = false,
        AnimMenuOpen = false,
        ClonedPlayer = nil,
        PlayingAnim = false,
        CanCancelAnim = true,
    },
    ConfigShared = {},
    NUI = {},
    Entities = {},
    AnimationPositioning = nil,
    AnimationPositioningPed = nil,
    SyncedPlayer = nil,
    AnimationPositioningCoords = nil,
    Entities = {},
}
local loop = {
    status = nil,
    current = nil,
    finish = nil,
    delay = 0,
    dettach = false,
    last = 0
}

local prop2, prop3 = nil, {}

local ragdoll = false

Main.NUI.SendNUIMessage = function(action, data)
    SendNUIMessage({action = action, data = data})
end

CreateThread(function()
    for i=1, #Config.Animations do
        local conf = Config.Animations[i] 
        if conf.name == 'shared' or conf.name == 'porn' then
            for j=1, #conf.items do
                local item = conf.items[j]
                if item.type == 'shared' then
                    Main.ConfigShared[#Main.ConfigShared + 1] = item
                end
            end
        end
    end
end)

Main.OpenMenu = function()

    Main.NUI.SendNUIMessage('openui', {table = Config.Animations})

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)

    Main.Data.AnimMenuOpen = true

    CreateThread(function()
        while Main.Data.AnimMenuOpen do
            DisableControlAction(0, 24, true) -- disable attack
            DisableControlAction(0, 25, true) -- disable aim
            DisableControlAction(0, 47, true) -- disable weapon
            DisableControlAction(0, 58, true) -- disable weapon
            DisableControlAction(0, 63, true) -- veh turn left
            DisableControlAction(0, 64, true) -- veh turn right
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 142, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
            DisableControlAction(0, 289, true) -- disable inventory
            DisableControlAction(0, 166, true) -- F5 menu
            DisableControlAction(0, 157, true) -- 1
            DisableControlAction(0, 158, true) -- 2
            DisableControlAction(0, 160, true) -- 3
            DisableControlAction(0, 164, true) -- 4
            DisableControlAction(0, 165, true) -- 5
            DisableControlAction(0, 45, true) -- reload

            DisableControlAction(0, 199, true) -- esc
            DisableControlAction(0, 200, true) -- esc            
            
            DisableControlAction(0, 0, true) -- camera mode
            DisableControlAction(0, 1, true) -- camera mode
            DisableControlAction(0, 2, true) -- camera mode
            Wait(1)
        end
    end)
end

Main.CloseUi = function(data)
    if data == nil then Main.NUI.SendNUIMessage('closeui', {}) end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    Wait(500)
    Main.Data.AnimMenuOpen = false
end

Main.NuiCallback = function(data) 
    Main.PlayAnimation(data.animData)
end

Main.CloseAnimation = function()
    if Main.Data.DostosujOpen then
        Wait(100)
        ExecuteCommand('closedostosuj')
    end
    if Main.Data.AnimMenuOpen then Main.CloseUi() end
end

Main.FocusCallback = function(data)
    if data then
        SetNuiFocusKeepInput(false)
    else
        SetNuiFocusKeepInput(true)
    end
end




Main.PlayAnimation = function(data, playerPed)
    if data.type ~= 'shared-synced' then
        if not playerPed then
            Main.ClearTasks()
        end
    end

    if not playerPed then
        playerPed = PlayerPedId()
    end

    if data.type == "walk" then
        Main.SetMovementClipset(data.animdict)
        return
    end

    if data.type == "expression" then
        Main.SetFacialAnim(data.animdict)
        return
    end

    Main.Data.PlayingAnim = true
    Main.Data.CanCancelAnim = true
    Main.Data.CurrentAnim = data

    if data.type == "shared" then
        Main.SyncedAnimation(data)
        return
    end

    local AnimationMode = 0
    local AnimationDuration = -1
    local AnimationOptions = data.options

    if IsPedInAnyVehicle(PlayerPedId(), true) then
        AnimationMode = 51
    elseif AnimationOptions then
        if AnimationOptions.moving then
            AnimationMode = 51
        elseif AnimationOptions.loop then
            AnimationMode = 1
        elseif AnimationOptions.stuck then
            AnimationMode = 50
        end
    end

    if AnimationOptions and AnimationOptions.duration then
        AnimationDuration = AnimationOptions.duration
    end

    
    local StartAnim = function()
        Main.TaskPlayAnimation(data, AnimationMode, AnimationDuration, AnimationOptions and AnimationOptions.props, playerPed)

        Wait(250)

        local PtfxNoProp = false
        if AnimationOptions and AnimationOptions.ptfx then
            local PtfxAsset = AnimationOptions.ptfx.asset
            local PtfxName = AnimationOptions.ptfx.name
            if AnimationOptions.ptfx.noProp then
                PtfxNoProp = AnimationOptions.ptfx.noProp
            else
                PtfxNoProp = false
            end
            local Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, PtfxScale = table.unpack(AnimationOptions.ptfx.placement)
            local PtfxBone = AnimationOptions.ptfx.bone
            local PtfxColor = AnimationOptions.ptfx.color
            local PtfxInfo = AnimationOptions.ptfx.info
            local PtfxWait = AnimationOptions.ptfx.wait
            local PtfxCanHold = AnimationOptions.ptfx.canHold
            TriggerServerEvent("haze-animations:server:syncPtfx", PtfxAsset, PtfxName, vector3(Ptfx1, Ptfx2, Ptfx3), vector3(Ptfx4, Ptfx5, Ptfx6), PtfxBone, PtfxScale, PtfxColor)

            CreateThread(function()
                if PtfxCanHold then
                    while IsEntityPlayingAnim(playerPed, data.dict, data.name, 3) do
                        if IsControlPressed(0, 47) then
                            Main.StartPtfx()
                            Wait(PtfxWait)
                            while IsControlPressed(0, 47) and IsEntityPlayingAnim(playerPed, data.dict, data.name, 3) do
                                Wait(5)
                            end
                            Main.StopPtfx()
                        end
                        Wait(0)
                    end
                else
                    Wait(PtfxWait)
                    Main.StartPtfx()
                    Main.StopPtfx()
                end
            end)
        end

        if AnimationOptions and AnimationOptions.ptfx and not PtfxNoProp then
            TriggerServerEvent("haze-animations:server:syncPtfxProp", ObjToNet(Main.Entities[1]))
        end

        CreateThread(function()
            while IsEntityPlayingAnim(playerPed, data.dict, data.name, 3) do
                Wait(100)
            end
            FreezeEntityPosition(playerPed, false)
            SetEntityCollision(playerPed, true, true)
            SetEntityCompletelyDisableCollision(playerPed, true, true)
        end)
    end

    if data.positioning then
        Main.PosAnimation(data, AnimationMode, AnimationDuration, AnimationOptions and AnimationOptions.props, function(bool)
            if bool then
                FreezeEntityPosition(playerPed, true)
                StartAnim()
            end
        end, playerPed)
    else
        StartAnim()
    end
end

Main.SetMovementClipset = function(name)
    RequestAnimSet(name)
    while not HasAnimSetLoaded(name) do
        Citizen.Wait(1)
    end
    SetPedMovementClipset(PlayerPedId(), name, 0.2)
    RemoveAnimSet(name)
    SetResourceKvp("haze-animations:movementClipset", name)
end

Main.SetFacialAnim = function(name)
    SetFacialIdleAnimOverride(PlayerPedId(), name, 0)
    SetResourceKvp("haze-animations:facialAnim", name)
end

Main.SyncedAnimation = function(data)
    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestPlayerDistance > 3.0 then
        ESX.ShowNotification('Nie ma zadnego gracza blisko ciebie!')
    else
        local targetId = GetPlayerServerId(closestPlayer)
        local elements = {
            {
                unselectable = true,
                icon = "fas fa-info-circle",
                title = "Zaproś do animacji",
            },
            {
                icon = "fas fa-check",
                title = "Chcesz zaprosić do animacji",
                description = Player(targetId).state.ESXPlayerName .. ' (' .. targetId .. ' #' .. Player(targetId).state.ESXPlayerUID .. ')',
                value = true,
            },
            {
                icon = "fas fa-check",
                title = "Anuluj",
            },
        }
          
        ESX.OpenContext("right" , elements, function(menu, element) 
            if element.value == true then
                TriggerServerEvent("haze-animations:server:requestSynced", targetId, data)
                ESX.ShowNotification('Wysłałeś prośbe', 'success')
            end
          
            ESX.CloseContext()
        end)
    end
end

Main.TaskPlayAnimation = function(data, AnimationMode, AnimationDuration, props, playerPed)
    local ped = playerPed or PlayerPedId()

    RequestAnimDict(data.dict)
    while not HasAnimDictLoaded(data.dict) do
        Wait(0)
    end

    TaskPlayAnim(ped, data.dict, data.name, 5.0, 5.0, AnimationDuration, AnimationMode, 0, false, false, false)
    RemoveAnimDict(data.dict)

    if props then
        local x, y, z = table.unpack(GetEntityCoords(ped))
        for i = 1, #(props) do
            local obj = props[i]
            local name = obj.name
            local bone = obj.bone
            local off1, off2, off3, rot1, rot2, rot3 = table.unpack(obj.placement)
            if IsModelValid(name) then
                while not HasModelLoaded(joaat(name)) do
                    RequestModel(joaat(name))
                    Wait(10)
                end

                if clone then
                    local prop = CreateObject(joaat(name), x, y, z + 0.2, false, true, true)
                    SetEntityAlpha(prop, 200, false)
                    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
                    Main.Entities[#Main.Entities + 1] = prop
                    SetModelAsNoLongerNeeded(prop)
                else
                    local prop = CreateObject(joaat(name), x, y, z + 0.2, true, true, true)
                    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
                    Main.Entities[#Main.Entities + 1] = prop
                    SetModelAsNoLongerNeeded(prop)
                end
            end
        end
    end
end

Main.PosAnimation = function(data, AnimationMode, AnimationDuration, props, cb, playerPed)
    local playerPed = playerPed or PlayerPedId()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)

        Main.AnimationPositioning = true
        Main.AnimationPositioningPed = CreatePed(2, GetEntityModel(playerPed), coords.x, coords.y, coords.z - 1.0, heading, false)

        TriggerEvent("skinchanger:loadSkin", skin, function()
            FreezeEntityPosition(Main.AnimationPositioningPed, true)
            SetEntityCollision(Main.AnimationPositioningPed, false, false)
            SetEntityCompletelyDisableCollision(Main.AnimationPositioningPed, false, false)
            SetEntityAlpha(Main.AnimationPositioningPed, 200, false)

            Main.TaskPlayAnimation(data, AnimationMode, AnimationDuration, props, Main.AnimationPositioningPed, playerPed)

            while Main.AnimationPositioning do
                DisableControlAction(0, 14, true)
                DisableControlAction(0, 15, true)
                DisableControlAction(0, 18, true)
                DisableControlAction(0, 30,  true)
                DisableControlAction(0, 31,  true)
                DisableControlAction(0, 32, true)
                DisableControlAction(0, 33, true)
                DisableControlAction(0, 34, true)
                DisableControlAction(0, 35, true)
                DisableControlAction(0, 38, true)
                DisableControlAction(0, 44, true)

                local xoff = 0.0
                local yoff = 0.0
                local zoff = 0.0
                local heading = GetEntityHeading(Main.AnimationPositioningPed)

                if IsDisabledControlJustReleased(0, 15) then
                    heading = heading + 5
                end
                if IsDisabledControlJustReleased(0, 14) then
                    heading = heading - 1
                end

                if IsDisabledControlPressed(0, 34) then
                    xoff = -0.01;
                end
                if IsDisabledControlPressed(0, 35) then
                    xoff = 0.01;
                end

                if IsDisabledControlPressed(0, 32) then
                    yoff = 0.01;
                end
                if IsDisabledControlPressed(0, 33) then
                    yoff = -0.01;
                end

                if IsDisabledControlPressed(0, 38) then
                    zoff = 0.01;
                end
                if IsDisabledControlPressed(0, 44) then
                    zoff = -0.01;
                end

                if IsDisabledControlJustPressed(0, 18) then
                    if HasEntityClearLosToEntity(Main.AnimationPositioningPed, playerPed, 2) then
                        Main.AnimationPositioningCoords = {
                            x = coords.x,
                            y = coords.y,
                            z = coords.z - 1.0,
                            h = heading
                        }
                        
                        SetEntityCoordsNoOffset(playerPed, GetEntityCoords(Main.AnimationPositioningPed), false, true, true)
                        SetEntityHeading(playerPed, GetEntityHeading(Main.AnimationPositioningPed))
                        
                        for i = 1, #(Main.Entities) do
                            DeleteEntity(Main.Entities[i])
                        end
                        Main.Entities = {}
                        DeleteEntity(Main.AnimationPositioningPed)            
                        break
                    else
                        ESX.ShowNotification("Nie możesz ustawić animacji w tym miejscu!", 'warn')
                    end
                end

                local newPos = GetOffsetFromEntityInWorldCoords(Main.AnimationPositioningPed, xoff, yoff, zoff)
                if #(vec3(coords.x, coords.y, coords.z) - vec3(newPos.x, newPos.y, newPos.z)) < 3 then
                    SetEntityCoordsNoOffset(Main.AnimationPositioningPed, newPos.x, newPos.y, newPos.z, false, true, true)
                end
                SetEntityHeading(Main.AnimationPositioningPed, heading)

                Wait(0)
            end

            cb(Main.AnimationPositioning)
            Main.AnimationPositioning = false
        end, Main.AnimationPositioningPed)
    end)
end


RegisterNetEvent("haze-animations:client:playSyncedSource", function(emote, player)
    Main.ClearTasks()
    Wait(300)
    
    local plyServerId = GetPlayerFromServerId(player)
    local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())
    
    local SyncOffsetFront = 1.0
    local SyncOffsetSide = 0.0
    local SyncOffsetHeight = 0.0
    local SyncOffsetHeading = 180.1

    for i = 1, #(Main.ConfigShared) do
        local item = Main.ConfigShared[i]
        if item.keyword == emote then
            emote = item
            break
        end
    end

    local AnimationOptions = emote.options
    if AnimationOptions then
        if AnimationOptions.SyncOffsetFront then
            SyncOffsetFront = AnimationOptions.SyncOffsetFront + 0.0
        end
        if AnimationOptions.SyncOffsetSide then
            SyncOffsetSide = AnimationOptions.SyncOffsetSide + 0.0
        end
        if AnimationOptions.SyncOffsetHeight then
            SyncOffsetHeight = AnimationOptions.SyncOffsetHeight + 0.0
        end
        if AnimationOptions.SyncOffsetHeading then
            SyncOffsetHeading = AnimationOptions.SyncOffsetHeading + 0.0
        end

        if (AnimationOptions.Attachto) then
            local bone = AnimationOptions.bone or -1 -- No bone
            local xPos = AnimationOptions.xPos or 0.0
            local yPos = AnimationOptions.yPos or 0.0
            local zPos = AnimationOptions.zPos or 0.0
            local xRot = AnimationOptions.xRot or 0.0
            local yRot = AnimationOptions.yRot or 0.0
            local zRot = AnimationOptions.zRot or 0.0
            local playerBone = GetPedBoneIndex(pedInFront, bone)
            AttachEntityToEntity(PlayerPedId(), pedInFront, playerBone, xPos, yPos, zPos, xRot, yRot, zRot, false, false, false, true, 1, true)
        end
    end
    local coords = GetOffsetFromEntityInWorldCoords(pedInFront, SyncOffsetSide, SyncOffsetFront, SyncOffsetHeight)
    local heading = GetEntityHeading(pedInFront)
    SetEntityHeading(PlayerPedId(), heading - SyncOffsetHeading)
    SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, 0)
    if emote.freezPlayer then
        FreezeEntityPosition(PlayerPedId(), true)
    end

    if type(emote) == 'string' then
        return
    end

    emote.type = 'shared-synced'
    Main.SyncedPlayer = player
    Main.PlayAnimation(emote)
    emote.type = 'shared'
end)

RegisterNetEvent("haze-animations:client:playSynced", function(emote, player)
    Main.ClearTasks()
    Wait(300)

    local targetEmote
    for i = 1, #(Main.ConfigShared) do
        local item = Main.ConfigShared[i]
        if item.keyword == emote then
            emote = item
            targetEmote = item.target
            break
        end
    end

    for i = 1, #(Main.ConfigShared) do
        local item = Main.ConfigShared[i]
        if item.keyword == targetEmote then
            targetEmote = item
            break
        end
    end

    Main.SyncedPlayer = player

    local plyServerId = GetPlayerFromServerId(player)
    if targetEmote and targetEmote.options and targetEmote.options.Attachto then
        local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())
        local bone = targetEmote.options.bone or -1 -- No bone
        local xPos = targetEmote.options.xPos or 0.0
        local yPos = targetEmote.options.yPos or 0.0
        local zPos = targetEmote.options.zPos or 0.0
        local xRot = targetEmote.options.xRot or 0.0
        local yRot = targetEmote.options.yRot or 0.0
        local zRot = targetEmote.options.zRot or 0.0
        local playerBone = GetPedBoneIndex(pedInFront, bone)
        if targetEmote.freezPlayer then
            FreezeEntityPosition(pedInFront, true)
        end
        AttachEntityToEntity(PlayerPedId(), pedInFront, playerBone, xPos, yPos, zPos, xRot, yRot, zRot, false, false, false, true, 1, true)

        if targetEmote.freezPlayer then
            FreezeEntityPosition(pedInFront, true)
            FreezeEntityPosition(PlayerPedId(), true)
            CreateThread(function()
                while Main.SyncedPlayer == player do
                    Wait(100)
                end
                FreezeEntityPosition(pedInFront, false)
            end)
        end
    end


    if type(targetEmote) == 'string' then
        return
    end

    targetEmote.type = 'shared-synced'
    Main.PlayAnimation(targetEmote)
    targetEmote.type = 'shared'
end)

Main.ClearTasks = function()
    ClearPedTasks(PlayerPedId())
    Main.Data.CanCancelAnim = false
    Main.Data.CurrentAnim = nil

    for i = 1, #(Main.Entities) do
        DeleteEntity(Main.Entities[i])
    end
    Main.Entities = {}

    if Main.AnimationPositioning then
        Main.AnimationPositioning = nil
    end

    if Main.AnimationPositioningPed then
        DeleteEntity(Main.AnimationPositioningPed)
        Main.AnimationPositioningPed = nil
    end

    if Main.SyncedPlayer then
        DetachEntity(PlayerPedId(), true, false)
        TriggerEvent("haze-animations:server:stopSynced", Main.SyncedPlayer)
        Main.SyncedPlayer = nil
    end

    if LocalPlayer.state.ptfx then
        Main.StopPtfx()
    end

    local coords = Main.AnimationPositioningCoords
    if coords then
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
        SetEntityHeading(PlayerPedId(), coords.h)
        Main.AnimationPositioningCoords = nil
    end
end

Main.StartPtfx = function()
    LocalPlayer.state:set('ptfx', true, true)
end

Main.StopPtfx = function()
    LocalPlayer.state:set('ptfx', false, true)
end

Main.PlayerParticles = {}
AddStateBagChangeHandler('ptfx', nil, function(bagName, key, value, _unused, replicated)
    local plyId = tonumber(bagName:gsub('player:', ''), 10)

    if (Main.PlayerParticles[plyId] and value) or (not Main.PlayerParticles[plyId] and not value) then return end

    local ply = GetPlayerFromServerId(plyId)
    if ply == 0 then return end

    local plyPed = GetPlayerPed(ply)
    if not DoesEntityExist(plyPed) then return end

    local stateBag = Player(plyId).state
    if value then
        local asset = stateBag.ptfxAsset
        local name = stateBag.ptfxName
        local offset = stateBag.ptfxOffset
        local rot = stateBag.ptfxRot
        local boneIndex = stateBag.ptfxBone and GetPedBoneIndex(plyPed, stateBag.ptfxBone) or GetEntityBoneIndexByName(name, "VFX")
        local scale = stateBag.ptfxScale or 1
        local color = stateBag.ptfxColor
        local propNet = stateBag.ptfxPropNet
        local entityTarget = plyPed
        
        if propNet then
            local propObj = NetToObj(propNet)
            if DoesEntityExist(propObj) then
                entityTarget = propObj
            end
        end
        
        while not HasNamedPtfxAssetLoaded(asset) do
            RequestNamedPtfxAsset(asset)
            Wait(10)
        end
        UseParticleFxAsset(asset)
        
        Main.PlayerParticles[plyId] = StartNetworkedParticleFxLoopedOnEntityBone(name, entityTarget, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneIndex, scale + 0.0, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)
        if color then
            if color[1] and type(color[1]) == 'table' then
                local randomIndex = math.random(1, #color)
                color = color[randomIndex]
            end
            SetParticleFxLoopedAlpha(Main.PlayerParticles[plyId], color.A)
            SetParticleFxLoopedColour(Main.PlayerParticles[plyId], color.R / 255, color.G / 255, color.B / 255, false)
        end
    else
        if Main.PlayerParticles[plyId] then
            StopParticleFxLooped(Main.PlayerParticles[plyId], false)
            RemoveParticleFx(Main.PlayerParticles[plyId])
            RemoveNamedPtfxAsset(stateBag.ptfxAsset)
            Main.PlayerParticles[plyId] = nil
        end
    end
end)

RegisterCommand('animacje', Main.OpenMenu)
RegisterNuiCallback('closeui', Main.CloseUi)
RegisterNuiCallback('action', Main.NuiCallback)
RegisterNuiCallback('focus', Main.FocusCallback)

RegisterCommand('zamknijanimacje', Main.CloseAnimation)
RegisterKeyMapping("zamknijanimacje", "Zamknij Animacje", "keyboard", "ESCAPE")

































































-- Anim function
local crouchingCooldown = false
local isCrouching = false

local clearCrouch = function()
    local ped = PlayerPedId()
    SetPedMaxMoveBlendRatio(ped, 1.0)
    ResetPedMovementClipset(ped, 0.55)
    ResetPedStrafeClipset(ped)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanPlayAmbientBaseAnims(ped, true)
    ResetPedWeaponMovementClipset(ped)
    RemoveAnimDict('move_ped_crouched')
    isCrouching = false
end

local crouchLoop = function()
    repeat RequestAnimSet('move_ped_crouched')
        Wait(1)
    until HasAnimSetLoaded('move_ped_crouched')
    local ped = PlayerPedId()
    SetPedUsingActionMode(ped, false, -1, 'DEFAULT_ACTION')
    SetPedMovementClipset(ped, 'move_ped_crouched', 0.55)
    SetPedStrafeClipset(ped, 'move_ped_crouched_strafing')
    SetWeaponAnimationOverride(ped, 'Ballistic')
end

local startCrouching = function()
    if (IsPedInAnyVehicle(PlayerPedId(), true)) or (IsNuiFocused()) then
        return
    end
    DisableControlAction(0,36,true)

    isCrouching = not isCrouching
    if(isCrouching) then
        crouchLoop()
    else
        clearCrouch()
    end
end

ESX.RegisterInput('crouch', 'Kucanie', 'keyboard', 'LCONTROL', startCrouching)


Main.StopAll = function()
    TriggerEvent('haze-base:TaskClear')
    if ragdoll then return Main.TriggerRagdoll(false) end
    if Main.Data.CanCancelAnim == false then return end
    if Main.Data.DostosujOpen == true then return end

    if Main.Data.CurrentAnim == nil then return end

    Main.Data.CurrentAnim = nil

    if loop.status == true then
        StopLoop()
    elseif ragdoll then
        Main.TriggerRagdoll(false)
    else
        local playerPed = PlayerPedId()
        ClearPedTasks(playerPed)
        if loop.status then
            loop.status = nil
            if prop and type(prop) ~= "table" then
                if loop.dettach then
                    DetachEntity(prop, true, false)
                else
                    DeleteObject(prop)
                end
                prop = nil
            end
        elseif type(prop) == "table" then
            DeleteObject(prop.obj)
            prop = nil
            if prop2 then
                DeleteObject(prop2)
                prop2 = nil
            end
            for _, item in ipairs(prop3) do DeleteObject(item.obj) end
        end
    end
    Main.Data.PlayingAnim = false
    Main.ClearTasks()
    TriggerEvent("esx_animations:TaskClear")
end

Main.SyncRequestCallback = function(cb, targetId, data)
    local send = false
    local elements = {
        {
            unselectable = true,
            icon = "fas fa-info-circle",
            title = "Zaproszenie do animacji",
        },
        {
            icon = "fas fa-check",
            title = "Gracz chce cię zaprosić do animacji " .. data.label,
            description = Player(targetId).state.ESXPlayerName .. ' (' .. targetId .. ' #' .. Player(targetId).state.ESXPlayerUID .. ')',
            value = true,
        },
        {
            icon = "fas fa-check",
            title = "Anuluj",
            value = false,
        },
      }
      
      ESX.OpenContext("right" , elements, function(menu, element) 
        cb(element.value)
        send = true
        ESX.CloseContext()
    end, function(menu)
        if send == false then
            cb(false)
        end
    end)
end

Main.StopSynced = function(playerId)
    if Main.SyncedPlayer and Main.SyncedPlayer == playerId then
        Main.ClearTasks()
        Main.SyncedPlayer = nil
    end
end

RegisterNetEvent('haze-animations:client:stopSynced', Main.StopSynced)

RegisterCommand('anulujanimacje', Main.StopAll)
RegisterKeyMapping("anulujanimacje", "Anuluj Animacje", "keyboard", "x")




RegisterCommand("e", function(source, args)

    if args[1] == 'upadek' then
        Main.TriggerRagdoll(true)
        Main.Data.CanCancelAnim = true
        Main.Data.CurrentAnim = 'upadek'
    end

    local key = args[1]
    if not key then
        return ESX.ShowNotification('Nie ma takiej animacji')
    end

    for i=1, #Config.Animations do
        local animations = Config.Animations[i]
        for j=1, #animations.items do
            local anim = animations.items[j]
            if anim.keyword == key then
                Main.PlayAnimation(anim)
                break
            end
        end
    end
end)



CreateThread(function()
    while not ESX.PlayerLoaded do
        Wait(1000)
    end
    for i=1, #Config.Animations do
        local category = Config.Animations[i]

        for j=1, #category.items do
            local animation = category.items[j]
            if not animation.hide then
                TriggerEvent('chat:addSuggestion', '/e ' .. animation.keyword, 'Wywołaj animacje', {
                    { name = animation.keyword, help = animation.label },
                })
            end
        end
    end
end)











































RegisterCommand("anim_handsup", function()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) and not IsEntityDead(ped) then
        RequestAnimDict("random@mugging3")
        while not HasAnimDictLoaded("random@mugging3") do Wait(100) end
        if IsEntityPlayingAnim(ped, "random@mugging3", "handsup_standing_base",
                               3) then
            StopAnimTask(ped, "random@mugging3", "handsup_standing_base", 1.0)
        else
            TaskPlayAnim(ped, "random@mugging3", "handsup_standing_base", 2.0,
                         2.5, -1, 49, 0, 0, 0, 0)
        end
    end
    CreateThread(function()
        while IsEntityPlayingAnim(ped, "random@mugging3",
                                  "handsup_standing_base", 3) do
            Wait(0)
            DisablePlayerFiring(player, true)
        end
    end)
end)

Main.StartPointing = function()
    local ped = PlayerPedId()
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do Wait(0) end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    TaskMoveNetworkByName(ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

Main.StopPointing = function(bool)
    local ped = PlayerPedId()
    if not IsPedInjured(ped) and not bool then ClearPedSecondaryTask(ped) end
    RequestTaskMoveNetworkStateTransition(ped, "Stop")
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
end

RegisterCommand("anim_pointing", function()
    if not mp_pointing and IsPedOnFoot(PlayerPedId()) then
        Main.StartPointing()
        mp_pointing = true
        while mp_pointing do
            Wait(0)
            local ped = PlayerPedId()
            if not IsTaskMoveNetworkActive(ped) and mp_pointing then
                mp_pointing = false
                Main.StopPointing(true)
            end
            if IsTaskMoveNetworkActive(ped) then
                if not IsPedOnFoot(ped) then
                    mp_pointing = false
                    Main.StopPointing()
                else
                    local camPitch = GetGameplayCamRelativePitch()
                    if camPitch < -70.0 then
                        camPitch = -70.0
                    elseif camPitch > 42.0 then
                        camPitch = 42.0
                    end
                    camPitch = (camPitch + 70.0) / 112.0

                    local camHeading = GetGameplayCamRelativeHeading()
                    local cosCamHeading = Cos(camHeading)
                    local sinCamHeading = Sin(camHeading)
                    if camHeading < -180.0 then
                        camHeading = -180.0
                    elseif camHeading > 180.0 then
                        camHeading = 180.0
                    end
                    camHeading = (camHeading + 180.0) / 360.0

                    local blocked = 0
                    local nn = 0

                    local coords = GetOffsetFromEntityInWorldCoords(ped,
                                                                    (cosCamHeading *
                                                                        -0.2) -
                                                                        (sinCamHeading *
                                                                            (0.4 *
                                                                                camHeading +
                                                                                0.3)),
                                                                    (sinCamHeading *
                                                                        -0.2) +
                                                                        (cosCamHeading *
                                                                            (0.4 *
                                                                                camHeading +
                                                                                0.3)),
                                                                    0.6)
                    local ray = Cast_3dRayPointToPoint(coords.x, coords.y,
                                                       coords.z - 0.2, coords.x,
                                                       coords.y, coords.z + 0.2,
                                                       0.4, 95, ped, 7);
                    nn, blocked, coords, coords = GetRaycastResult(ray)

                    SetTaskMoveNetworkSignalFloat(ped, "Pitch", camPitch)
                    SetTaskMoveNetworkSignalFloat(ped, "Heading",
                                                  camHeading * -1.0 + 1.0)
                    SetTaskMoveNetworkSignalBool(ped, "isBlocked", blocked)
                    SetTaskMoveNetworkSignalBool(ped, "isFirstPerson",
                                                 GetCamViewModeForContext(
                                                     GetCamActiveViewModeContext()) ==
                                                     4)

                end
            end
        end
    elseif mp_pointing or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
        mp_pointing = false
        Main.StopPointing()
    end
end)



RegisterKeyMapping("anim_handsup", "Podnieś Ręce", "keyboard", "OEM_3")
RegisterKeyMapping('anim_pointing', 'Pokazuj Palcem', 'keyboard', 'B')

ESX.RegisterClientCallback('haze-animations:callback:client:syncRequest', Main.SyncRequestCallback)
RegisterNetEvent('haze-animations:client:syncPlayerAnim', Main.SyncPlayerAnim)



Main.TriggerRagdoll = function(a)
    ragdoll = a
    while ragdoll do
        Wait(0)
        SetPedToRagdoll(PlayerPedId(), 2000, 2000, 0, 0, 0, 0)
    end
end



RegisterNetEvent('woro-hud:updateColor', function(data)
    SendNUIMessage({action = "updateColor", data = data})
end)

Main.ToggleAll = function(data)
    if type(data) == 'boolean' then
        Main.Data.CanCancelAnim = data
    end
end

Main.StartCancelAnim = function()
    Main.Data.CurrentAnim = {}
end

exports('toggleCancelAnim', Main.ToggleAll)
exports('StartCancelAnim', Main.StartCancelAnim)