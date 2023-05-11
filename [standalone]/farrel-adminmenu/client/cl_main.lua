LoggedIn, isAdmin = false, nil
 
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    RefreshMenu('All')
    ESX.TriggerServerCallback('farrel-adminmenu/server/get-permission', function(admin)
        isAdmin = admin
    end)

    LoggedIn = true
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
    ESX.TriggerServerCallback('farrel-adminmenu/server/get-permission', function(admin)
        isAdmin = admin
    end)

    LoggedIn = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    RefreshMenu('All')
    ESX.TriggerServerCallback('farrel-adminmenu/server/get-permission', function(admin)
        isAdmin = admin
    end)
    
    LoggedIn = true
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
                            local PlayerPed = GetPlayerPed(GetPlayerFromServerId(tonumber(v.ServerId)))
                            local PlayerBlip = AddBlipForEntity(PlayerPed) 
                            SetBlipSprite(PlayerBlip, 1)
                            SetBlipColour(PlayerBlip, 0)
                            SetBlipScale(PlayerBlip, 0.75)
                            ShowHeadingIndicatorOnBlip(PlayerBlip, true) -- Player Blip indicator
                            SetBlipRotation(PlayerBlip, math.ceil(GetEntityHeading(ped))) -- update rotation
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
RegisterCommand('adminmenu', function(source, args, RawCommand) 
    if isAdmin == nil then 
		print('get admin again')
        RefreshMenu('All')
        ESX.TriggerServerCallback('farrel-adminmenu/server/get-permission', function(admin)
            isAdmin = admin
        end)
        LoggedIn = true
        
		Wait(500)
	end

    TriggerEvent('farrel-adminmenu/client/try-open-menu') 
end, false)

-- [ Events ] --

RegisterNetEvent('farrel-adminmenu/client/try-open-menu', function()
    if not isAdmin then return end
    print('get rank')
    ESX.TriggerServerCallback('farrel-adminmenu/server/get-playerrank', function(rank)
        playerRank = rank
    end) 

	Wait(100)

    local Bans = GetBans()
    local Players = GetPlayers()
    local Menu = GetListMenu()
    local Logs = GetLogs()

    SetCursorLocation(0.87, 0.15)
    SetNuiFocus(true, true)
    SendNUIMessage({
        Action = 'Open',
        Debug = Config.Settings['Debug'],
        Bans = Bans,
        AllPlayers = Players,
        Logs = Logs,
        AdminItems = Menu,
        Favorited = Config.FavoritedItems,
        BanTypes = Config.BanTimeCategories,
    })

end)

RegisterNetEvent('farrel-adminmenu/client/force-close', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        Action = 'Close',
    })
end)

RegisterNetEvent("farrel-adminmenu/client/reset-menu", function()
    if not isAdmin then return end

    ResetMenuKvp()
end)

-- [ NUI Callbacks ] --

RegisterNUICallback('Admin/ToggleFavorite', function(Data, Cb)
    Config.FavoritedItems[Data.Id] = Data.Toggle
    SetKvp("farrel-adminmenu-favorites", json.encode(Config.FavoritedItems), "Favorites")
    Cb('Ok')
end)

RegisterNUICallback("Admin/UnbanPlayer", function(Data, Cb)
    TriggerServerEvent('farrel-adminmenu/server/unban-player', Data.PData.BanId)
    SetTimeout(500, function()
        UpdateMenu()
    end)
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

RegisterNUICallback("Admin/GetDateDifference", function(Data, Cb)
    ESX.TriggerServerCallback('farrel-adminmenu/server/get-date-difference', function(FBans, CAmount)
        Cb({
            Bans = FBans, 
            Amount = CAmount,
        })
    end, Data.BanList, Data.CType)
end)

RegisterNUICallback('Admin/TriggerAction', function(Data, Cb) 
    if isAdmin then
        if Data.EventType == nil then Data.EventType = 'Client' end
        if Data.Event ~= nil and Data.EventType ~= nil then
            if Data.EventType == 'Client' then
                TriggerEvent(Data.Event, Data.Result)
            elseif Data.EventType == 'Command' then
                ExecuteCommand(Data.Event .. " " .. Data.Result.player)
            else
                TriggerServerEvent(Data.Event, Data.Result)
            end
        end
    end
    Cb('Ok')
end)