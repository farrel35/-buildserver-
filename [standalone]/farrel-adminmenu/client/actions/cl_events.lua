BlipsEnabled, NamesEnabled, GodmodeEnabled, AllPlayerBlips, BlipData = false, false, false, {}, {}

-- [ Events ] --

RegisterNetEvent("Admin:Godmode", function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/toggle-godmode', Result['player'])
end)

RegisterNetEvent('Admin:Toggle:Noclip', function(Result)
    if not isAdmin then return end

    SendNUIMessage({
        Action = 'Close',
    })
    SendNUIMessage({
        Action = "SetItemEnabled",
        Name = 'noclip',
        State = not noClipEnabled
    })
    if noClipEnabled then
        toggleFreecam(false)
    else
        toggleFreecam(true)
    end
end)

RegisterNetEvent('Admin:Fix:Vehicle', function(Result)
    if not isAdmin then return end

    SendNUIMessage({
        Action = 'Close',
    })
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        SetVehicleFixed(GetVehiclePedIsIn(PlayerPedId(), true))
    else
        local Vehicle, Distance = ESX.Game.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
        SetVehicleFixed(Vehicle)
    end 
end)

RegisterNetEvent('Admin:Delete:Vehicle', function(Result)
    if not isAdmin then return end
    
    SendNUIMessage({
        Action = 'Close',
    })
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), true))
    else
        local Vehicle, Distance = ESX.Game.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
        DeleteVehicle(Vehicle)
    end
end)

RegisterNetEvent('Admin:Spawn:Vehicle', function(Result)
    if not isAdmin then return end

    SendNUIMessage({
        Action = 'Close',
    })
    -- TriggerEvent('QBCore:Command:SpawnVehicle', Result['model'])
    ESX.Game.SpawnVehicle(Result['model'], GetEntityCoords(PlayerPedId()), 0, function(callback_vehicle)
        SetVehRadioStation(callback_vehicle, "OFF")
        SetVehicleFixed(callback_vehicle)
        SetVehicleDeformationFixed(callback_vehicle)
        SetVehicleUndriveable(callback_vehicle, false)
        SetVehicleEngineOn(callback_vehicle, true, true)

        TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
    end)
end)

RegisterNetEvent('Admin:Teleport:Marker', function(Result)
     if not isAdmin then return end

    SendNUIMessage({
        Action = 'Close',
    })
    TriggerEvent('esx:tpm')
end)

RegisterNetEvent('Admin:Teleport:Coords', function(Result)
     if not isAdmin then return end

    if Result['x-coord'] ~= '' and Result['y-coord'] ~= '' and Result['z-coord'] ~= '' then
        SendNUIMessage({
            Action = 'Close',
        })
        SetEntityCoords(PlayerPedId(), tonumber(Result['x-coord']), tonumber(Result['y-coord']), tonumber(Result['z-coord']))
    end
end)

RegisterNetEvent('Admin:Teleport', function(Result)
     if not isAdmin then return end

    SendNUIMessage({
        Action = 'Close',
    })
    TriggerServerEvent('farrel-adminmenu/server/teleport-player', Result['player'], Result['type'])
end)

RegisterNetEvent("Admin:Chat:Say", function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/chat-say', Result['message'])
end)

RegisterNetEvent('Admin:Open:Clothing', function(Result)
    if not isAdmin then return end

    SendNUIMessage({
        Action = 'Close',
    })
    TriggerServerEvent('farrel-adminmenu/server/open-clothing', Result['player'])
end)

RegisterNetEvent('Admin:Revive', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/revive-target', Result['player'])
end)

RegisterNetEvent('Admin:Remove:Stress', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/remove-stress', Result['player'])
end)

RegisterNetEvent('Admin:Change:Model', function(Result)
    if not isAdmin then return end

    if Result['model'] ~= '' then
        local Model = GetHashKey(Result['model'])
        if IsModelValid(Model) then
            TriggerServerEvent('farrel-adminmenu/server/set-model', Result['player'], Model)
        end
    end
end)

RegisterNetEvent('Admin:Change:Clone', function(Result)
    if not isAdmin then return end

    cloneModel(Result['player'])
end)

RegisterNetEvent('Admin:Reset:Model', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/reset-model', Result['player'])
end)

RegisterNetEvent('Admin:Armor', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/set-armor', Result['player'])
end)

RegisterNetEvent('Admin:Food:Drink', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/set-food-drink', Result['player'])
end)

RegisterNetEvent('Admin:Request:Job', function(Result)
    if not isAdmin then return end

    if Result['job'] ~= '' then
        TriggerServerEvent('farrel-adminmenu/server/request-job', Result['player'], Result['job'])
    end
end)

RegisterNetEvent("Admin:Drunk", function(Result)
    if not isAdmin then return end


    TriggerServerEvent('farrel-adminmenu/server/drunk', Result['player'])
end)

RegisterNetEvent("Admin:Animal:Attack", function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/animal-attack', Result['player'])
end)

RegisterNetEvent('Admin:Set:Fire', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/set-fire', Result['player'])
end)

RegisterNetEvent('Admin:Fling:Player', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/fling-player', Result['player'])
end)

RegisterNetEvent('Admin:GiveItem', function(Result)
    if not isAdmin then return end
    
    TriggerServerEvent('farrel-adminmenu/server/give-item', Result['player'], Result['item'], Result['amount'])
end)

RegisterNetEvent('Admin:Ban', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/ban-player', Result['player'], Result['expire'], Result['reason'], "Online")
end)

RegisterNetEvent('Admin:BanOffline', function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/ban-player', Result['steamhex'], Result['expire'], Result['reason'], "Offline")
end)

RegisterNetEvent('Admin:Unban', function(Result)
    if not isAdmin then return end
    
   TriggerServerEvent("farrel-adminmenu/server/unban-player", Result['player'])
end)

RegisterNetEvent('Admin:Kick', function(Result)
     if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/kick-player', Result['player'], Result['reason'])
end)

RegisterNetEvent("Admin:Copy:Coords", function(Result)
    if not isAdmin then return end

    local CoordsType = Result['type']
    local CoordsLayout = nil

    local Coords = GetEntityCoords(PlayerPedId())
    local Heading = GetEntityHeading(PlayerPedId())
    local X = roundDecimals(Coords.x, 2)
    local Y = roundDecimals(Coords.y, 2)
    local Z = roundDecimals(Coords.z, 2)
    local H = roundDecimals(Heading, 2)
    if CoordsType == 'vector3(0.0, 0.0, 0.0)' then
        CoordsLayout = 'vector3('..X..', '..Y..', '..Z..')'
    elseif CoordsType == 'vector4(0.0, 0.0, 0.0, 0.0)' then
        CoordsLayout = 'vector4('..X..', '..Y..', '..Z..', '..H..')'
    elseif CoordsType == '0.0, 0.0, 0.0' then
        CoordsLayout = ''..X..', '..Y..', '..Z..''
    elseif CoordsType == '0.0, 0.0, 0.0, 0.0' then
        CoordsLayout = ''..X..', '..Y..', '..Z..', '..H..''
    elseif CoordsType == 'X = 0.0, Y = 0.0, Z = 0.0' then
        CoordsLayout = 'X = '..X..', Y = '..Y..', Z = '..Z..''
    elseif CoordsType == 'x = 0.0, y = 0.0, z = 0.0' then
        CoordsLayout = 'x = '..X..', y = '..Y..', z = '..Z..''
    elseif CoordsType == 'X = 0.0, Y = 0.0, Z = 0.0, H = 0.0' then
        CoordsLayout = 'X = '..X..', Y = '..Y..', Z = '..Z..', H = '..H
    elseif CoordsType == 'x = 0.0, y = 0.0, z = 0.0, h = 0.0' then
        CoordsLayout = 'x = '..X..', y = '..Y..', z = '..Z..', h = '..H
    elseif CoordsType == '["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0' then
        CoordsLayout = '["X"] = '..X..', ["Y"] = '..Y..', ["Z"] = '..Z
    elseif CoordsType == '["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0' then
        CoordsLayout = '["x"] = '..X..', ["y"] = '..Y..', ["z"] = '..Z
    elseif CoordsType == '["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0, ["H"] = 0.0' then
        CoordsLayout = '["X"] = '..X..', ["Y"] = '..Y..', ["Z"] = '..Z..', ["H"] = '..H
    elseif CoordsType == '["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0, ["h"] = 0.0' then
        CoordsLayout = '["x"] = '..X..', ["y"] = '..Y..', ["z"] = '..Z..', ["h"] = '..H
    end
    SendNUIMessage({
        Action = 'Copy',
        String = CoordsLayout
    })
end)

RegisterNetEvent("Admin:Sound:Player", function(Result)
    if not isAdmin then return end

    TriggerServerEvent('farrel-adminmenu/server/play-sound', Result['player'], Result['sound'])
end)

RegisterNetEvent('Admin:Toggle:PlayerBlips', function()
    if not isAdmin then return end

    BlipsEnabled = not BlipsEnabled

    TriggerServerEvent('farrel-adminmenu/server/toggle-blips')

    SendNUIMessage({
        Action = "SetItemEnabled",
        Name = 'playerblips',
        State = BlipsEnabled
    })

    if not BlipsEnabled then
        DeletePlayerBlips()
    end
end)

RegisterNetEvent('Admin:Toggle:PlayerNames', function()
    if not isAdmin then return end

    NamesEnabled = not NamesEnabled

    SendNUIMessage({
        Action = "SetItemEnabled",
        Name = 'playernames',
        State = NamesEnabled
    })

    if NamesEnabled then
        local Players = GetPlayersInArea(nil, 15.0)

        CreateThread(function()
            while NamesEnabled do
                Wait(2000)
                Players = GetPlayersInArea(nil, 15.0)
            end
        end)

        CreateThread(function()
            while NamesEnabled do
                for k, v in pairs(Players) do
                    local Ped = GetPlayerPed(GetPlayerFromServerId(tonumber(v['ServerId'])))
                    local PedCoords = GetPedBoneCoords(Ped, 0x796e)
                    local PedHealth = GetEntityHealth(Ped) / GetEntityMaxHealth(Ped) * 100
                    local PedArmor = GetPedArmour(Ped)
                    
                    DrawText3D(vector3(PedCoords.x, PedCoords.y, PedCoords.z + 0.5), ('[%s] - %s ~n~'.._U("health")..': %s - '.._U("armor")..': %s'):format(v['ServerId'], v['Name'], math.floor(PedHealth), math.floor(PedArmor)))
                end
                
                Wait(1)
            end
        end)
    end
end)

RegisterNetEvent('Admin:Toggle:Spectate', function(Result)
    if not isAdmin then return end

    if not isSpectateEnabled then
        TriggerServerEvent('farrel-adminmenu/server/start-spectate', Result['player'])
    else
        toggleSpectate(storedTargetPed)
        preparePlayerForSpec(false)
        TriggerServerEvent('farrel-adminmenu/server/stop-spectate')
    end
end)

RegisterNetEvent("Admin:OpenInv", function(Result)
     if not isAdmin then return end

    SendNUIMessage({
        Action = 'Close',
    })
    
    exports.ox_inventory:openInventory('player', Result['player'])
end)

RegisterNetEvent("Admin:GiveVehicle", function(Result)
    if not isAdmin then return end
    
    SendNUIMessage({
        Action = 'Close',
    })

    if  Result['plate'] == nil or  Result['plate'] == "" then
        Result['plate'] = exports['esx_vehicleshop']:GeneratePlate()
    end

    TriggerServerEvent("farrel-adminmenu/server/give-vehicle", Result['player'], Result['model'], Result['plate'], "Online")
end)

RegisterNetEvent("Admin:GiveVehicleOffline", function(Result)
    if not isAdmin then return end
    
    SendNUIMessage({
        Action = 'Close',
    })

    if  Result['plate'] == nil or  Result['plate'] == "" then
        Result['plate'] = exports['esx_vehicleshop']:GeneratePlate()
    end

   TriggerServerEvent("farrel-adminmenu/server/give-vehicle", Result['steamhex'], Result['model'], Result['plate'], "Offline")
end)

-- [ Triggered Events ] --

RegisterNetEvent("farrel-adminmenu/client/toggle-godmode", function()
    GodmodeEnabled = not GodmodeEnabled

    local Msg = GodmodeEnabled and _U("enabled") or _U("disabled")
    local MsgType = GodmodeEnabled and 'success' or 'error'
    ESX.ShowNotification('Godmode '..Msg, MsgType)

    if GodmodeEnabled then
        while GodmodeEnabled do
            Wait(0)
            SetPlayerInvincible(PlayerId(), true)
        end
        SetPlayerInvincible(PlayerId(), false)
    else
        SetPlayerInvincible(PlayerId(), false)
    end
end)

RegisterNetEvent('farrel-adminmenu/client/teleport-player', function(Coords)
    local Entity = PlayerPedId()    
    SetPedCoordsKeepVehicle(Entity, Coords.x, Coords.y, Coords.z)
end)

RegisterNetEvent('farrel-adminmenu/client/set-model', function(Model)
    ESX.Streaming.RequestModel(Model, function()
        SetPlayerModel(PlayerId(), Model)
        SetPedRandomComponentVariation(PlayerPedId(), true)
        SetModelAsNoLongerNeeded(Model)
    end)
end)

RegisterNetEvent('farrel-adminmenu/client/reset-model', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        local characterModel

        if skin['sex'] == 0 then
            characterModel = `mp_m_freemode_01`
        else
            characterModel = `mp_f_freemode_01`
        end

        ESX.Streaming.RequestModel(characterModel, function()
            SetPlayerModel(PlayerId(), characterModel)
            SetPedRandomComponentVariation(PlayerPedId(), true)
            SetModelAsNoLongerNeeded(characterModel)
        end)
        TriggerEvent('skinchanger:loadSkin', skin) 
    end)
end)

RegisterNetEvent('farrel-adminmenu/client/armor-up', function()
    SetPedArmour(PlayerPedId(), 100.0)
end)

RegisterNetEvent("farrel-adminmenu/client/play-sound", function(Sound)
    local Soundfile = nil
    if Sound == 'Fart' then
        Soundfile = 'FartNoise2'
    elseif Sound == 'Wet Fart' then
        Soundfile = 'FartNoise'
    end

    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, Soundfile, 0.3)
end)

RegisterNetEvent('farrel-adminmenu/client/fling-player', function()
    local Ped = PlayerPedId()
    if GetVehiclePedIsUsing(Ped) ~= 0 then
        ApplyForceToEntity(GetVehiclePedIsUsing(Ped), 1, 0.0, 0.0, 100000.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
    else
        ApplyForceToEntity(Ped, 1, 9500.0, 3.0, 7100.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
    end
end)

RegisterNetEvent('farrel-adminmenu/client/DeletePlayerBlips', function()
    if not isAdmin then return end

    DeletePlayerBlips()
end)

RegisterNetEvent('farrel-adminmenu/client/UpdatePlayerBlips', function(Data)
    if not isAdmin then return end

    BlipData = Data
end)

RegisterNetEvent("farrel-adminmenu/client/drunk", function()
    drunkThread()
end)

RegisterNetEvent("farrel-adminmenu/client/animal-attack", function()
    startWildAttack()
end)

RegisterNetEvent("farrel-adminmenu/client/set-fire", function()
    local playerPed = PlayerPedId()
    StartEntityFire(playerPed)
end)
