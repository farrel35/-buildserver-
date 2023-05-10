
local savedCoords   = {}
SpectateData = {}

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local player = source
    local identifier = ESX.GetIdentifier(player)

    deferrals.defer()
    deferrals.update(string.format(" Hello %s. Checking ban status!", playerName))
    Wait(1000)
    local data = MySQL.Sync.fetchAll('SELECT * FROM bans WHERE steam = ?', {identifier})

    if data ~= nil then
        if(data[1] == nil) then
            deferrals.done()
        else
            local timeremaining = (disp_time(tonumber(data[1].expire)))
            if(os.time() > tonumber(data[1].expire)) then
                deferrals.done()
                MySQL.update('DELETE FROM bans WHERE steam = ?' , {identifier})
            else
                deferrals.done(string.format(_U("banned", data[1].banid, data[1].reason, os.date("%Y-%m-%d %H:%M",data[1].expire), data[1].bannedby)))
            end
        end
    end
end)

ESX.RegisterServerCallback('farrel-adminmenu/server/get-permission', function(source, Cb)
    local admin = IsPlayerAdmin(source)
    Cb(admin)
end)

ESX.RegisterServerCallback('farrel-adminmenu/server/get-playerrank', function(source, Cb)
    local rank = getPlayerRank(source)
    Cb(rank)
end)

ESX.RegisterServerCallback('farrel-adminmenu/server/get-active-players-in-radius', function(Source, Cb, Coords, Radius)
	local Coords, Radius = Coords ~= nil and vector3(Coords.x, Coords.y, Coords.z) or GetEntityCoords(GetPlayerPed(Source)), Radius ~= nil and Radius or 5.0
    local ActivePlayers = {}
	for k, v in pairs(ESX.GetPlayers()) do
        local TargetCoords = GetEntityCoords(GetPlayerPed(v))
        local TargetDistance = #(TargetCoords - Coords)
        if TargetDistance <= Radius then
            ActivePlayers[#ActivePlayers + 1] = {
                ['ServerId'] = v,
                ['Name'] = GetPlayerName(v)
            }
        end
	end
	Cb(ActivePlayers)
end)
ESX.RegisterServerCallback('farrel-adminmenu/server/get-logs', function(source, Cb)
    local LogsList = {}
    local LogsData = MySQL.query.await('SELECT * FROM logs', {})
    if LogsData and LogsData[1] ~= nil then
        for k, v in pairs(LogsData) do
            LogsList[#LogsList + 1] = {
                Type = v.type ~= nil and v.type or _U('no_type'),
                Steam = v.steam ~= nil and v.steam  or _U('no_desc'),
                Name = v.name ~= nil and v.name or _U('no_name'),
                Desc = v.log ~= nil and v.log or _U('no_Desc'),
                Date = v.date ~= nil and v.date or _U('no_date'),
                Data = v.data ~= nil and v.data or _U('no_data'),
            }
        end
    end
    Cb(LogsList)
end)
ESX.RegisterServerCallback('farrel-adminmenu/server/get-bans', function(source, Cb)
    local BanList = {}
    local BansData = MySQL.Sync.fetchAll('SELECT * FROM bans', {})
    if BansData and BansData[1] ~= nil then
        for k, v in pairs(BansData) do
            BanList[#BanList + 1] = {
                Text = v.banid .. " - " .. v.steam .. " - " .. v.name,
                BanId = v.banid,
                Name = v.name,
                Reason = v.reason,
                Expires = os.date('*t', tonumber(v.expire)),
                BannedOn = os.date('*t', tonumber(v.bannedon)),
                BannedOnN = v.bannedon,
                BannedBy = v.bannedby,
            }
        end
    end
    Cb(BanList)
end)

ESX.RegisterServerCallback('farrel-adminmenu/server/get-players', function(source, Cb)
    local PlayerList = {}
    for k, v in pairs(ESX.GetPlayers()) do
        local Steam = GetIdentifier(v, "steam")
        local License = GetIdentifier(v, "license")
        PlayerList[#PlayerList + 1] = {
            ServerId = v,
            Name = GetPlayerName(v),
            Steam = Steam ~= nil and Steam or 'Not Found',
            License = License  ~= nil and License or Steam
        }
    end
    Cb(PlayerList)
end)

ESX.RegisterServerCallback("farrel-adminmenu/server/create-log", function(source, Cb, Type, Log, Data)
    if Type == nil or Log == nil then return end

    CreateLog(source, Type, Log, Data)
end)

RegisterNetEvent("farrel-adminmenu/server/ban-player", function(ServerId, Expires, Reason, Type)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end
    
    if Type == "Online" then
        local License = GetIdentifier(ServerId, 'license')
        local Steam = GetIdentifier(ServerId, 'steam')
        local BanData = MySQL.query.await('SELECT * FROM bans WHERE steam = ?', {Steam})
        if BanData and BanData[1] ~= nil then
            for k, v in pairs(BanData) do
                TriggerClientEvent('esx:showNotification', src, _U('already_banned',GetPlayerName(ServerId), v.reason), 'error')
            end
        else
            local Expiring, ExpireDate = GetBanTime(Expires)
            local Time = os.time()
            local BanId = "BAN-"..math.random(0, 99999)
            MySQL.insert('INSERT INTO bans (banid, name, steam, license, discord, ip, reason, bannedby, expire, bannedon) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
                BanId,
                GetPlayerName(ServerId),
                Steam,
                License,
                GetIdentifier(ServerId, 'discord'),
                GetIdentifier(ServerId, 'ip'),
                Reason,
                GetPlayerName(src),
                ExpireDate,
                Time,
            })
            TriggerClientEvent('esx:showNotification', src, _U('success_banned', GetPlayerName(ServerId), Reason), 'success')
            local ExpireHours = tonumber(Expiring['hour']) < 10 and "0"..Expiring['hour'] or Expiring['hour']
            local ExpireMinutes = tonumber(Expiring['min']) < 10 and "0"..Expiring['min'] or Expiring['min']
            local ExpiringDate = Expiring['day'] .. '/' .. Expiring['month'] .. '/' .. Expiring['year'] .. ' | '..ExpireHours..':'..ExpireMinutes
            if Expires == "Permanent" then
                DropPlayer(ServerId,  _U('perm_banned', Reason))
            else
                DropPlayer(ServerId, _U('banned', BanId, Reason, Expires, GetPlayerName(src)))
            end
        end
    else
        local Steam = ServerId
        local BanData = MySQL.query.await('SELECT * FROM bans WHERE steam = ?', {Steam})
        if BanData and BanData[1] ~= nil then
            for k, v in pairs(BanData) do
                TriggerClientEvent('esx:showNotification', src, _U('already_banned', ServerId, v.reason), 'error')
            end
        else
            local Expiring, ExpireDate = GetBanTime(Expires)
            local Time = os.time()
            local BanId = "BAN-"..math.random(0, 99999)
            MySQL.insert('INSERT INTO bans (banid, name, steam, reason, bannedby, expire, bannedon) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                BanId,
                ServerId,
                Steam,
                Reason,
                GetPlayerName(src),
                ExpireDate,
                Time,
            })
            TriggerClientEvent('esx:showNotification', src, _U('success_banned', ServerId, Reason), 'success')
        end
    end
end)

RegisterNetEvent("farrel-adminmenu/server/unban-player", function(BanId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local BanData = MySQL.query.await('SELECT * FROM bans WHERE banid = ?', {BanId})
    if BanData and BanData[1] ~= nil then
        MySQL.query('DELETE FROM bans WHERE banid = ?', {BanId})
        TriggerClientEvent('esx:showNotification', src, _U('unbanned'), 'success')
    else
        TriggerClientEvent('esx:showNotification', src, _U('not_banned'), 'error')
    end
end)

RegisterNetEvent("farrel-adminmenu/server/kick-player", function(ServerId, Reason)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end
    
    DropPlayer(ServerId, Reason)
    TriggerClientEvent('esx:showNotification', src, _U('kicked'), 'success')
end)

RegisterNetEvent("farrel-adminmenu/server/give-item", function(ServerId, ItemName, ItemAmount)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    xPlayer.addInventoryItem(ItemName, ItemAmount)
    TriggerClientEvent('esx:showNotification', src, _U('gaveitem', ItemAmount, ItemName), 'success')
    
end)

RegisterNetEvent("farrel-adminmenu/server/request-job", function(ServerId, JobName)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    xPlayer.setJob(JobName, 0)
    TriggerClientEvent('esx:showNotification', src, _U('setjob', JobName), 'success')
end)

RegisterNetEvent('farrel-adminmenu/server/start-spectate', function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    -- Check if Person exists
    local Target = GetPlayerPed(ServerId)
    if not Target then
        return TriggerClientEvent('esx:showNotification', src, _U('not_found'), 'error')
    end

    -- Make Check for Spectating
    local SteamIdentifier = GetIdentifier(src, "steam")
    if SpectateData[SteamIdentifier] ~= nil then
        SpectateData[SteamIdentifier]['Spectating'] = true
    else
        SpectateData[SteamIdentifier] = {}
        SpectateData[SteamIdentifier]['Spectating'] = true
    end

    local tgtCoords = GetEntityCoords(Target)
    TriggerClientEvent('Mercy/client/specPlayer', src, ServerId, tgtCoords)
end)

RegisterNetEvent('farrel-adminmenu/server/stop-spectate', function()
    local src = source
    if not IsPlayerAdmin(src) then return end

    local SteamIdentifier = GetIdentifier(src, "steam")
    if SpectateData[SteamIdentifier] ~= nil and SpectateData[SteamIdentifier]['Spectating'] then
        SpectateData[SteamIdentifier]['Spectating'] = false
    end
end)

RegisterNetEvent("farrel-adminmenu/server/drunk", function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('farrel-adminmenu/client/drunk', ServerId)
end)

RegisterNetEvent("farrel-adminmenu/server/animal-attack", function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('farrel-adminmenu/client/animal-attack', ServerId)
end)

RegisterNetEvent("farrel-adminmenu/server/set-fire", function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('farrel-adminmenu/client/set-fire', ServerId)
end)

RegisterNetEvent("farrel-adminmenu/server/fling-player", function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('farrel-adminmenu/client/fling-player', ServerId)
end)

RegisterNetEvent("farrel-adminmenu/server/play-sound", function(ServerId, SoundId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('farrel-adminmenu/client/play-sound', ServerId, SoundId)
end)

-- Utility Actions

RegisterNetEvent("farrel-adminmenu/server/toggle-blips", function()
    local src = source
    if not IsPlayerAdmin(src) then return end

    local BlipData = {}
    for k, v in pairs(ESX.GetPlayers()) do
        BlipData[#BlipData + 1] = {
            ServerId = v,
            Name = GetPlayerName(v),
            Coords = GetEntityCoords(GetPlayerPed(v)),
        }
    end
    TriggerClientEvent('farrel-adminmenu/client/UpdatePlayerBlips', src, BlipData)
end)

RegisterNetEvent("farrel-adminmenu/server/teleport-player", function(ServerId, Type)
    local src = source

    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    local Msg = ""
    if Type == 'Goto' then
        Msg = _U('teleportedgoto') 
        local xCoords = GetEntityCoords(GetPlayerPed(src))
        local TCoords = GetEntityCoords(GetPlayerPed(ServerId))
        savedCoords[source] = xCoords
        TriggerClientEvent('farrel-adminmenu/client/teleport-player', src, TCoords)
        TriggerClientEvent('esx:showNotification', src, _U('teleported', Msg), 'success')
    elseif Type == 'Goback' then
        Msg = _U('teleportedgoback') 
        local playerCoords = savedCoords[source]
        if playerCoords then
            TriggerClientEvent('farrel-adminmenu/client/teleport-player', src, playerCoords)
            TriggerClientEvent('esx:showNotification', src, _U('teleported', Msg), 'success')
            savedCoords[source] = nil
        else
            TriggerClientEvent('esx:showNotification', src, _U("teleportednocoords"), 'error')
        end
    elseif Type == 'Bring' then
        Msg = _U('teleportedbring')
        local Coords = GetEntityCoords(GetPlayerPed(src))
        local TCoords = GetEntityCoords(GetPlayerPed(ServerId))
        savedCoords[ServerId] = TCoords
        TriggerClientEvent('farrel-adminmenu/client/teleport-player', ServerId, Coords)
        TriggerClientEvent('esx:showNotification', src, _U('teleported', Msg), 'success')
    elseif Type == 'Bringback' then
        Msg = _U('teleportedbringback')
        local playerCoords = savedCoords[ServerId]
        if playerCoords then
            TriggerClientEvent('farrel-adminmenu/client/teleport-player', ServerId, savedCoords[ServerId])
            TriggerClientEvent('esx:showNotification', src, _U('teleported', Msg), 'success')
            savedCoords[ServerId] = nil
        else
            TriggerClientEvent('esx:showNotification', src, _U("teleportednocoords"), 'error')
        end
    end
    
end)

RegisterNetEvent("farrel-adminmenu/server/chat-say", function(Message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = "<div class=chat-message server'><strong>".._U('announcement').." | </strong> {0}</div>",
        args = {Message}
    })
end)

-- Player Actions

RegisterNetEvent("farrel-adminmenu/server/toggle-godmode", function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end
    TriggerClientEvent('farrel-adminmenu/client/toggle-godmode', ServerId)
end)

RegisterNetEvent("farrel-adminmenu/server/set-food-drink", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    if xPlayer ~= nil then
        TriggerClientEvent('esx_status:add', src, 'hunger', 1000000)
        TriggerClientEvent('esx_status:add', src, 'thirst', 1000000)
        TriggerClientEvent('esx:showNotification', src, _U('gave_needs'), 'success')
    end
end)

RegisterNetEvent("farrel-adminmenu/server/remove-stress", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    if xPlayer ~= nil then
        xPlayer.Functions.SetMetaData('stress', 0)
        TriggerClientEvent('hud:client:UpdateStress', ServerId, 0)
        xPlayer.Functions.Save()
        TriggerClientEvent('esx:showNotification', src, _U('removed_stress'), 'success')
    end
end)

RegisterNetEvent("farrel-adminmenu/server/set-armor", function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    if xPlayer ~= nil then
        SetPedArmour(GetPlayerPed(ServerId), 100)
        TriggerClientEvent('esx:showNotification', src, _U('gave_armor'), 'success')
    end
end)

RegisterNetEvent("farrel-adminmenu/server/reset-model", function(ServerId)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    TriggerClientEvent("farrel-adminmenu/client/reset-model", ServerId)
end)

RegisterNetEvent("farrel-adminmenu/server/set-model", function(ServerId, Model)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('farrel-adminmenu/client/set-model', ServerId, Model)
end)

RegisterNetEvent("farrel-adminmenu/server/revive-in-distance", function()
    local src = source
    if not IsPlayerAdmin(src) then return end

    local Coords, Radius = GetEntityCoords(GetPlayerPed(src)), 5.0
	for k, v in pairs(ESX.GetPlayers()) do
		local Player = ESX.GetPlayerFromId(v)
		if Player ~= nil then
			local TargetCoords = GetEntityCoords(GetPlayerPed(v))
			local TargetDistance = #(TargetCoords - Coords)
			if TargetDistance <= Radius then
                -- TriggerClientEvent('hospital:client:Revive', v, true)
                TriggerClientEvent('esx_ambulancejob:revive', v)
			end
		end
	end
end)

RegisterNetEvent("farrel-adminmenu/server/revive-target", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    -- TriggerClientEvent('hospital:client:Revive', ServerId, true)
    TriggerClientEvent('esx_ambulancejob:revive', ServerId)

    
    TriggerClientEvent('esx:showNotification', src, _U('revived'), 'success')
end)

RegisterNetEvent("farrel-adminmenu/server/open-clothing", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('esx_skin:openSaveableMenu', src)
    TriggerClientEvent('esx:showNotification', src, _U('gave_clothing'), 'success')
end)

RegisterNetEvent('farrel-adminmenu/server/give-vehicle', function(Steamhex, Model, Plate, Type)
    local src = source
    if not Steamhex or Steamhex == "" then return end
    if not IsPlayerAdmin(src) then return end

    local plateData = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {Plate})
    if plateData and plateData[1] ~= nil then
        for k, v in pairs(plateData) do
            TriggerClientEvent('esx:showNotification', src, _U('duplicateplate', v.owner), 'error')
        end
    else
        if Type == "Online" then
            local xPlayer = ESX.GetPlayerFromId(src)
            local tPlayer = ESX.GetPlayerFromId(Steamhex)

            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)', {tPlayer.identifier, Plate, json.encode({model = joaat(Model), plate = Plate}), true
            }, function(rowsChanged)
                xPlayer.showNotification(_U("givevehicle", GetPlayerName(Steamhex), Plate))
                tPlayer.showNotification(_U("receivevehicle", Plate))
            end)
        else
            local xPlayer = ESX.GetPlayerFromId(src)

            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)', {Steamhex, Plate, json.encode({model = joaat(Model), plate = Plate}), true
            }, function(rowsChanged)
                xPlayer.showNotification(_U("givevehicle", Steamhex, Plate))
            end)
        end
    end
end)

function disp_time(time)
    local t = (os.difftime(time, os.time()))
    local d = math.floor(t / 86400)
    local h = math.floor((t % 86400) / 3600)
    local m = math.floor((t % 3600) / 60)
    local s = math.floor((t % 60))
    return {days = d , hours = h , minutes = m, seconds = s}
end