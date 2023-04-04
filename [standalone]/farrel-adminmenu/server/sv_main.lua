
SpectateData = {}

ESX.RegisterServerCallback('mc-adminmenu/server/get-permission', function(source, Cb)
    local admin = IsPlayerAdmin(source)
    Cb(admin)
end)

ESX.RegisterServerCallback('mc-admin/server/get-active-players-in-radius', function(Source, Cb, Coords, Radius)
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


ESX.RegisterServerCallback('mc-admin/server/get-players', function(source, Cb)
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

RegisterNetEvent("mc-admin/server/ban-player", function(ServerId, Expires, Reason)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local License = ESX.GetIdentifier(ServerId, 'license')
    local BanData = MySQL.query.await('SELECT * FROM bans WHERE license = ?', {License})
    if BanData and BanData[1] ~= nil then
        for k, v in pairs(BanData) do
            -- TriggerClientEvent('esx:showNotification', src, _U('already_banned', {player = GetPlayerName(ServerId), reason = v.reason}), 'error')
        end
    else
        local Expiring, ExpireDate = GetBanTime(Expires)
        local Time = os.time()
        local BanId = "BAN-"..math.random(11111, 99999)
        MySQL.insert('INSERT INTO bans (banid, name, license, discord, ip, reason, bannedby, expire, bannedon) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            BanId,
            GetPlayerName(ServerId),
            License,
            ESX.GetIdentifier(ServerId, 'discord'),
            ESX.GetIdentifier(ServerId, 'ip'),
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
            print(reason)
            DropPlayer(ServerId, _U('banned', Reason, Expires))
        end
    end
end)

RegisterNetEvent("mc-admin/server/kick-player", function(ServerId, Reason)
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    DropPlayer(ServerId, Reason)
    TriggerClientEvent('esx:showNotification', src, _U('kicked'), 'success')
end)

RegisterNetEvent("mc-admin/server/give-item", function(ServerId, ItemName, ItemAmount)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    xPlayer.addInventoryItem(ItemName, ItemAmount, 'Admin-Menu-Give')
    TriggerClientEvent('esx:showNotification', src, _U('gaveitem', ItemAmount, ItemName), 'success')
end)

RegisterNetEvent("mc-admin/server/request-job", function(ServerId, JobName)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    xPlayer.setJob(JobName, 0)
    TriggerClientEvent('esx:showNotification', src, _U('setjob', JobName), 'success')
end)

RegisterNetEvent('mc-admin/server/start-spectate', function(ServerId)
    local src = source
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

RegisterNetEvent('mc-admin/server/stop-spectate', function()
    local src = source
    if not IsPlayerAdmin(src) then return end

    local SteamIdentifier = ESX.GetIdentifier(src, "steam")
    if SpectateData[SteamIdentifier] ~= nil and SpectateData[SteamIdentifier]['Spectating'] then
        SpectateData[SteamIdentifier]['Spectating'] = false
    end
end)

RegisterNetEvent("mc-admin/server/drunk", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('mc-admin/client/drunk', ServerId)
end)

RegisterNetEvent("mc-admin/server/animal-attack", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('mc-admin/client/animal-attack', ServerId)
end)

RegisterNetEvent("mc-admin/server/set-fire", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('mc-admin/client/set-fire', ServerId)
end)

RegisterNetEvent("mc-admin/server/fling-player", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('mc-admin/client/fling-player', ServerId)
end)

RegisterNetEvent("mc-admin/server/play-sound", function(ServerId, SoundId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('mc-admin/client/play-sound', ServerId, SoundId)
end)

-- Utility Actions

RegisterNetEvent("mc-admin/server/toggle-blips", function()
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
    TriggerClientEvent('mc-admin/client/UpdatePlayerBlips', src, BlipData)
end)


RegisterNetEvent("mc-admin/server/teleport-player", function(ServerId, Type)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local Msg = ""
    if Type == 'Goto' then
        Msg = _U('teleportedto') 
        local TCoords = GetEntityCoords(GetPlayerPed(ServerId))
        TriggerClientEvent('mc-admin/client/teleport-player', src, TCoords)
    elseif Type == 'Bring' then
        Msg = _U('teleportedbrought')
        local Coords = GetEntityCoords(GetPlayerPed(src))
        TriggerClientEvent('mc-admin/client/teleport-player', ServerId, Coords)
    end
    TriggerClientEvent('esx:showNotification', src, _U('teleported', {tpmsg = Msg}), 'success')
end)

RegisterNetEvent("mc-admin/server/chat-say", function(Message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = "<div class=chat-message server'><strong>".._U('announcement').." | </strong> {0}</div>",
        args = {Message}
    })
end)

-- Player Actions

RegisterNetEvent("mc-admin/server/toggle-godmode", function(ServerId)
    TriggerClientEvent('mc-admin/client/toggle-godmode', ServerId)
end)

RegisterNetEvent("mc-admin/server/set-food-drink", function(ServerId)
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

RegisterNetEvent("mc-admin/server/remove-stress", function(ServerId)
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

RegisterNetEvent("mc-admin/server/set-armor", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    if xPlayer ~= nil then
        SetPedArmour(GetPlayerPed(ServerId), 100)
        TriggerClientEvent('esx:showNotification', src, _U('gave_armor'), 'success')
    end
end)

RegisterNetEvent("mc-admin/server/reset-skin", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local xPlayer = ESX.GetPlayerFromId(ServerId)
    local ClothingData = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { xPlayer.identifier, 1 })
    if ClothingData[1] ~= nil then
        TriggerClientEvent("qb-clothes:loadSkin", ServerId, false, ClothingData[1].model, ClothingData[1].skin)
    else
        TriggerClientEvent("qb-clothes:loadSkin", ServerId, true)
    end
end)

RegisterNetEvent("mc-admin/server/set-model", function(ServerId, Model)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('mc-admin/client/set-model', ServerId, Model)
end)

RegisterNetEvent("mc-admin/server/revive-in-distance", function()
    local src = source
    if not IsPlayerAdmin(src) then return end

    local Coords, Radius = GetEntityCoords(GetPlayerPed(src)), 5.0
	for k, v in pairs(ESX.GetPlayers()) do
		local Player = ESX.GetPlayerFromId(v)
		if Player ~= nil then
			local TargetCoords = GetEntityCoords(GetPlayerPed(v))
			local TargetDistance = #(TargetCoords - Coords)
			if TargetDistance <= Radius then
                TriggerClientEvent('hospital:client:Revive', v, true)
			end
		end
	end
end)

RegisterNetEvent("mc-admin/server/revive-target", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('hospital:client:Revive', ServerId, true)
    TriggerClientEvent('esx:showNotification', src, _U('revived'), 'success')
end)

RegisterNetEvent("mc-admin/server/open-clothing", function(ServerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    TriggerClientEvent('qb-clothing:client:openMenu', ServerId)
    TriggerClientEvent('esx:showNotification', src, _U('gave_clothing'), 'success')
end)

