
local savedCoords   = {}
SpectateData = {}

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local player = source
    local identifier = ESX.GetIdentifier(player)

    deferrals.defer()
    deferrals.update(string.format(" Hello %s. Checking ban status!", playerName))
    Wait(1000)
    local data = MySQL.Sync.fetchAll('SELECT * FROM bans WHERE identifier = ?', {identifier})

    if data ~= nil then
        if(data[1] == nil) then
            deferrals.done()
        else
            local timeremaining = (disp_time(tonumber(data[1].expire)))
            if(os.time() > tonumber(data[1].expire)) then
                deferrals.done()
                MySQL.update('DELETE FROM bans WHERE identifier = ?' , {identifier})
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

ESX.RegisterServerCallback('farrel-adminmenu/server/get-bans', function(source, Cb)
    local BanList = {}
    local BansData = MySQL.Sync.fetchAll('SELECT * FROM bans', {})
    if BansData and BansData[1] ~= nil then
        for k, v in pairs(BansData) do
                BanList[#BanList + 1] = {
                    Text = v.banid .. " - " .. v.identifier .. " - " .. v.name,
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
        PlayerList[#PlayerList + 1] = {
            ServerId = v,
            Name = GetPlayerName(v),
            Steam = ESX.GetIdentifier(v, "steam"),
            License = ESX.GetIdentifier(v, "license")
        }
    end
    Cb(PlayerList)
end)

RegisterNetEvent("farrel-adminmenu/server/ban-player", function(ServerId, Expires, Reason)
    local src = source
    if not ServerId or ServerId == "" then return end
    if not IsPlayerAdmin(src) then return end
    
    local identifier = ESX.GetIdentifier(ServerId)
    local BanData = MySQL.query.await('SELECT * FROM bans WHERE identifier = ?', {identifier})
    if BanData and BanData[1] ~= nil then
        for k, v in pairs(BanData) do
            TriggerClientEvent('esx:showNotification', src, _U('already_banned',GetPlayerName(ServerId), v.reason), 'error')
        end
    else
        local Expiring, ExpireDate = GetBanTime(Expires)
        local Time = os.time()
        local BanId = "BAN-"..math.random(0, 99999)
        MySQL.insert('INSERT INTO bans (banid, name, identifier, reason, bannedby, expire, bannedon) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            BanId,
            GetPlayerName(ServerId),
            identifier,
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
    local SteamIdentifier = ESX.GetIdentifier(src, "steam")
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

    local SteamIdentifier = ESX.GetIdentifier(src, "steam")
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
            TriggerClientEvent('esx:showNotification', src, "No saved coords player", 'error')
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
            TriggerClientEvent('esx:showNotification', src, "No saved coords player", 'error')
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
        xPlayer.Functions.SetMetaData('thirst', 100)
        xPlayer.Functions.SetMetaData('hunger', 100)
        TriggerClientEvent('hud:client:UpdateNeeds', ServerId, 100, 100)
        xPlayer.Functions.Save()
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

    TriggerClientEvent('qb-clothing:client:openMenu', ServerId)
    TriggerClientEvent('esx:showNotification', src, _U('gave_clothing'), 'success')
end)

RegisterNetEvent('farrel-adminmenu/server/give-vehicle', function(Steamhex, Model, Plate, Type)
    local src = source
    if not Steamhex or Steamhex == "" then return end
    if not IsPlayerAdmin(src) then return end
    
    if Type == "Online" then
        local xPlayer = ESX.GetPlayerFromId(src)
        local tPlayer = ESX.GetPlayerFromId(Steamhex)

        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)', {tPlayer.identifier, Plate, json.encode({model = joaat(Model), plate = Plate}), true
        }, function(rowsChanged)
            xPlayer.showNotification("Berhasil give kendaraan ke " .. GetPlayerName(Steamhex) .. " dengan plat " .. Plate)
            tPlayer.showNotification("Menerima kendaraan dari admin dengan plat " .. Plate)
        end)
    else
        local xPlayer = ESX.GetPlayerFromId(src)

        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)', {Steamhex, Plate, json.encode({model = joaat(Model), plate = Plate}), true
        }, function(rowsChanged)
            xPlayer.showNotification("Berhasil give kendaraan")
        end)
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
  
RegisterCommand('gban', function(source, args, rawCommand)
    -- TriggerClientEvent('chat:client:ClearChat', source)
    local player = source
    local steamIdentifier
    local steamid  = false
    local license  = false
    local discord  = false
    local xbl      = false
    local liveid   = false
    local ip       = false
    for k,v in pairs(GetPlayerIdentifiers(player))do
      if string.sub(v, 1, string.len("steam:")) == "steam:" then
        steamid = v
      elseif string.sub(v, 1, string.len("license:")) == "license:" then
        license = v
      elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
        xbl  = v
      elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
        ip = v
      elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
        discord = v
      elseif string.sub(v, 1, string.len("live:")) == "live:" then
        liveid = v
      end
    end

    local data = MySQL.Sync.fetchAll('SELECT * FROM bans WHERE license = ?', { steamid})
    local timeremaining = (disp_time(tonumber(data[1].expire)))
    print(', you are banned from this server! \n Your ban will be expired in '..timeremaining.days..' days, '..timeremaining.hours..' hours and '..timeremaining.seconds ..' seconds! ('..os.date("%Y-%m-%d %H:%M",data[1].expire)..') ')
end, false)