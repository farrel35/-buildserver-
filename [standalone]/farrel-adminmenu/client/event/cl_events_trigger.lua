GodmodeEnabled, BlipData = false, {}

-- [ Triggered Events ] --

RegisterNetEvent("farrel-adminmenu/client/toggle-godmode", function()
    GodmodeEnabled = not GodmodeEnabled

    local Msg = GodmodeEnabled and _U("enabled") or _U("disabled")
    local MsgType = GodmodeEnabled and 'success' or 'error'
    ESX.ShowNotification('Godmode '..Msg, MsgType)

    while GodmodeEnabled do
        Wait(1)
        SetPlayerInvincible(PlayerId(), true)
    end
    SetTimeout(250, function()
        SetPlayerInvincible(PlayerId(), false)
    end)
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

RegisterNetEvent('farrel-adminmenu/client/DeletePlayerBlips', function()
    if not isAdmin then return end

    DeletePlayerBlips()
end)

RegisterNetEvent('farrel-adminmenu/client/UpdatePlayerBlips', function(Data)
    if not isAdmin then return end

    BlipData = Data
end)

