LoggedIn, Group = false, nil
 
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	SetTimeout(1250, function()
        RefreshMenu('All')
        ESX.TriggerServerCallback('mc-adminmenu/server/get-permission', function(PGroup)
            Group = PGroup
        end)
        LoggedIn = true
    end)
end)
RegisterCommand('gperm', function(source, args, RawCommand) 
    RefreshMenu('All')
    ESX.TriggerServerCallback('mc-adminmenu/server/get-permission', function(PGroup)
        Group = PGroup
    end)
end, false)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(xPlayer)
    ESX.TriggerServerCallback('mc-adminmenu/server/get-permission', function(PGroup)
        Group = PGroup
    end)
    LoggedIn = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    SetTimeout(1250, function()
        RefreshMenu('All')
        ESX.TriggerServerCallback('mc-adminmenu/server/get-permission', function(PGroup)
            Group = PGroup
        end)
        LoggedIn = true
    end)
end)

-- [ Code ] --

-- [ Threads ] --

CreateThread(function()
    while true do
        Wait(4)
        if LoggedIn then
            if BlipsEnabled then
                if BlipData ~= nil then
                    DeletePlayerBlips()
                    local ServerId = GetPlayerServerId(PlayerId())
                    for k, v in pairs(BlipData) do
                        if tonumber(v.ServerId) ~= tonumber(ServerId) then
                            local PlayerPed = GetPlayerPed(GetPlayerFromServerId(v.ServerId))
                            local PlayerBlip = AddBlipForEntity(PlayerPed) 
                            SetBlipSprite(PlayerBlip, 1)
                            SetBlipColour(PlayerBlip, 0)
                            SetBlipScale(PlayerBlip, 0.75)
                            SetBlipAsShortRange(PlayerBlip, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString('['..v.ServerId..'] '..v.Name)
                            EndTextCommandSetBlipName(PlayerBlip)
                            table.insert(AllPlayerBlips, PlayerBlip)
                        end
                    end    
                end
                Wait(5000)
            else
                if AllPlayerBlips ~= nil then
                    DeletePlayerBlips()
                    Wait(450)
                end
            end
        else
            Wait(450)
        end
    end
end)

-- [ Mapping ] --

RegisterKeyMapping('adminmenu', _U('keymapping_desc'), 'keyboard', Config.Settings['DefaultOpenKeybind'])
RegisterCommand('adminmenu', function(source, args, RawCommand) TriggerServerEvent('mc-admin/server/try-open-menu', true) end, false)

-- [ Events ] --

RegisterNetEvent('mc-admin/client/try-open-menu', function(KeyPress)
    if not IsPlayerAdmin() then return end
    -- if KeyPress then if not CanBind() then return end end

    local Players = GetPlayers()

    SetCursorLocation(0.87, 0.15)
    SetNuiFocus(true, true)
    SendNUIMessage({
        Action = 'Open',
        Debug = Config.Settings['Debug'],
        AllPlayers = Players,
        AdminItems = Config.AdminMenus,
        Favorited = Config.FavoritedItems,
    })
end)

RegisterNetEvent('mc-admin/client/force-close', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        Action = 'Close',
    })
end)

RegisterNetEvent("mc-admin/client/reset-menu", function()
    if not IsPlayerAdmin() then return end

    ResetMenuKvp()
end)

-- [ NUI Callbacks ] --

RegisterNUICallback('Admin/ToggleFavorite', function(Data, Cb)
    Config.FavoritedItems[Data.Id] = Data.Toggle
    SetKvp("mc-adminmenu-favorites", json.encode(Config.FavoritedItems), "Favorites")
    Cb('Ok')
end)

RegisterNUICallback("Admin/Close", function(Data, Cb)
   SetNuiFocus(false, false)
   Cb('Ok')
end)

RegisterNUICallback("Admin/DevMode", function(Data, Cb)
    local Bool = Data.Toggle
    ToggleDevMode(Bool)
    Cb('Ok')
end)

RegisterNUICallback('Admin/TriggerAction', function(Data, Cb) 
    if IsPlayerAdmin() then
        if Data.EventType == nil then Data.EventType = 'Client' end
        if Data.Event ~= nil and Data.EventType ~= nil then
            if Data.EventType == 'Client' then
                TriggerEvent(Data.Event, Data.Result)
            else
                TriggerServerEvent(Data.Event, Data.Result)
            end
        end
    end
    Cb('Ok')
end)