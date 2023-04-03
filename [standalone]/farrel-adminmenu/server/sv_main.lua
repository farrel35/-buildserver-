
SpectateData = {}

-- [ Code ] --

-- [ Callbacks ] --

ESX.RegisterServerCallback('mc-adminmenu/server/get-permission', function(source, Cb)
    local Group = ESX.IsPlayerAdmin(source)
    Cb(Group)
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

ESX.RegisterServerCallback('mc-admin/server/get-bans', function(source, Cb)
    local BanList = {}
    local BansData = MySQL.Sync.fetchAll('SELECT * FROM bans', {})
    if BansData and BansData[1] ~= nil then
        for k, v in pairs(BansData) do
            local TPlayer = GetPlayerFromLicense(v.license)
            if TPlayer ~= nil then
                BanList[#BanList + 1] = {
                    Text = v.name.." ("..v.banid..")",
                    BanId = v.banid,
                    Source = TPlayer.Source,
                    Name = v.name,
                    Reason = v.reason,
                    Expires = os.date('*t', tonumber(v.expire)),
                    BannedOn = os.date('*t', tonumber(v.bannedon)),
                    BannedOnN = v.bannedon,
                    BannedBy = v.bannedby,
                    License = v.license,
                    Discord = v.discord,
                }
            end
        end
    end
    Cb(BanList)
end)

ESX.RegisterServerCallback('mc-admin/server/get-logs', function(source, Cb)
    local LogsList = {}
    local LogsData = MySQL.query.await('SELECT * FROM logs', {})
    if LogsData and LogsData[1] ~= nil then
        for k, v in pairs(LogsData) do
            LogsList[#LogsList + 1] = {
                Type = v.Type ~= nil and v.Type or _U('logs.no_type'),
                Steam = v.Steam ~= nil and v.Steam  or _U('logs.no_desc'),
                Desc = v.Log ~= nil and v.Log or _U('logs.no_Desc'),
                Date = v.Date ~= nil and v.Date or _U('logs.no_date'),
                Cid = v.Cid ~= nil and v.Cid or _U('logs.no_cid'),
                Data = v.Data ~= nil and v.Data or _U('logs.no_data'),
            }
        end
    end
    Cb(LogsList)
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

ESX.RegisterServerCallback('mc-admin/server/get-player-data', function(source, Cb, LicenseData)
    local PlayerInfo = {}
    for license, _ in pairs(LicenseData) do
        local TPlayer = GetPlayerFromLicense(license)
        if TPlayer ~= nil then
            PlayerInfo = {
                Name = TPlayer.PlayerData.name,
                Steam = ESX.GetIdentifier(TPlayer.PlayerData.source, "steam"),
                CharName = TPlayer.PlayerData.charfirstname..' '..TPlayer.PlayerData.charlastname,
                Source = TPlayer.PlayerData.source,
                CitizenId = TPlayer.identifier
            }
        end
        Cb(PlayerInfo)
    end
end)

ESX.RegisterServerCallback('mc-admin/server/get-date-difference', function(source, Cb, Bans, Type)
    local FilteredBans, BanAmount = GetDateDifference(Type, Bans) 
    Cb(FilteredBans, BanAmount)
end)

ESX.RegisterServerCallback("mc-admin/server/create-log", function(source, Cb, Type, Log, Data)
    if Type == nil or Log == nil then return end

    local Player = ESX.GetPlayerFromId(source)
    local Steam = ESX.GetIdentifier(source, "steam")
    if Player ~= nil then
        MySQL.insert('INSERT INTO logs (Type, Steam, Log, Cid, Data) VALUES (?, ?, ?, ?, ?)', {
            Type,
            Steam,
            Log,
            Player.identifier ~= nil and Player.identifier or "Not found",
            Data,
        })
    end
end)

-- [ Events ] --

RegisterNetEvent("mc-admin/server/try-open-menu", function(KeyPress)
    local src = source
    if not AdminCheck(src) then return end
    
    TriggerClientEvent('mc-admin/client/try-open-menu', src, KeyPress)
end)

-- User Actions

RegisterNetEvent("mc-admin/server/unban-player", function(BanId)
    local src = source
    if not AdminCheck(src) then return end

    local BanData = MySQL.query.await('SELECT * FROM bans WHERE banid = ?', {BanId})
    if BanData and BanData[1] ~= nil then
        MySQL.query('DELETE FROM bans WHERE banid = ?', {BanId})
        TriggerClientEvent('QBCore:Notify', src, _U('unbanned'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, _U('not_banned'), 'error')
    end
end)

RegisterNetEvent("mc-admin/server/ban-player", function(ServerId, Expires, Reason)
    local src = source
    if not AdminCheck(src) then return end

    local License = ESX.GetIdentifier(ServerId, 'license')
    local BanData = MySQL.query.await('SELECT * FROM bans WHERE license = ?', {License})
    if BanData and BanData[1] ~= nil then
        for k, v in pairs(BanData) do
            TriggerClientEvent('QBCore:Notify', src, _U('already_banned', {player = GetPlayerName(ServerId), reason = v.reason}), 'error')
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
        TriggerClientEvent('QBCore:Notify', src, _U('success_banned', {player = GetPlayerName(ServerId), reason = Reason}), 'success')
        local ExpireHours = tonumber(Expiring['hour']) < 10 and "0"..Expiring['hour'] or Expiring['hour']
        local ExpireMinutes = tonumber(Expiring['min']) < 10 and "0"..Expiring['min'] or Expiring['min']
        local ExpiringDate = Expiring['day'] .. '/' .. Expiring['month'] .. '/' .. Expiring['year'] .. ' | '..ExpireHours..':'..ExpireMinutes
        if Expires == "Permanent" then
            DropPlayer(ServerId,  _U('perm_banned', {reason = Reason}))
        else
            DropPlayer(ServerId, _U('banned', {reason = Reason, expires = ExpiringDate}))
        end
    end
end)

RegisterNetEvent("mc-admin/server/kick-player", function(ServerId, Reason)
    local src = source
    if not AdminCheck(src) then return end

    DropPlayer(ServerId, Reason)
    TriggerClientEvent('QBCore:Notify', src, _U('banned'), 'success')
end)

RegisterNetEvent("mc-admin/server/give-item", function(ServerId, ItemName, ItemAmount)
    local src = source
    if not AdminCheck(src) then return end

    local TPlayer = ESX.GetPlayerFromId(ServerId)
    TPlayer.Functions.AddItem(ItemName, ItemAmount, 'Admin-Menu-Give')
    TriggerClientEvent('QBCore:Notify', src, _U('gaveitem', {amount = ItemAmount, name = ItemName}), 'success')
end)

RegisterNetEvent("mc-admin/server/request-job", function(ServerId, JobName)
    local src = source
    if not AdminCheck(src) then return end

    local TPlayer = ESX.GetPlayerFromId(ServerId)
    TPlayer.Functions.SetJob(JobName, 1, 'Admin-Menu-Give-Job')
    TriggerClientEvent('QBCore:Notify', src, _U('setjob', {jobname = JobName}), 'success')
end)

RegisterNetEvent('mc-admin/server/start-spectate', function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    -- Check if Person exists
    local Target = GetPlayerPed(ServerId)
    if not Target then
        return TriggerClientEvent('QBCore:Notify', src, _U('not_found'), 'error')
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
    if not AdminCheck(src) then return end

    local SteamIdentifier = ESX.GetIdentifier(src, "steam")
    if SpectateData[SteamIdentifier] ~= nil and SpectateData[SteamIdentifier]['Spectating'] then
        SpectateData[SteamIdentifier]['Spectating'] = false
    end
end)

RegisterNetEvent("mc-admin/server/drunk", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    TriggerClientEvent('mc-admin/client/drunk', ServerId)
end)

RegisterNetEvent("mc-admin/server/animal-attack", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    TriggerClientEvent('mc-admin/client/animal-attack', ServerId)
end)

RegisterNetEvent("mc-admin/server/set-fire", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    TriggerClientEvent('mc-admin/client/set-fire', ServerId)
end)

RegisterNetEvent("mc-admin/server/fling-player", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    TriggerClientEvent('mc-admin/client/fling-player', ServerId)
end)

RegisterNetEvent("mc-admin/server/play-sound", function(ServerId, SoundId)
    local src = source
    if not AdminCheck(src) then return end

    TriggerClientEvent('mc-admin/client/play-sound', ServerId, SoundId)
end)

-- Utility Actions

RegisterNetEvent("mc-admin/server/toggle-blips", function()
    local src = source
    if not AdminCheck(src) then return end

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
    if not AdminCheck(src) then return end

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
    TriggerClientEvent('QBCore:Notify', src, _U('teleported', {tpmsg = Msg}), 'success')
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
    if not AdminCheck(src) then return end

    local TPlayer = ESX.GetPlayerFromId(ServerId)
    if TPlayer ~= nil then
        TPlayer.Functions.SetMetaData('thirst', 100)
        TPlayer.Functions.SetMetaData('hunger', 100)
        TriggerClientEvent('hud:client:UpdateNeeds', ServerId, 100, 100)
        TPlayer.Functions.Save()
        TriggerClientEvent('QBCore:Notify', src, _U('gave_needs'), 'success')
    end
end)

RegisterNetEvent("mc-admin/server/remove-stress", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    local TPlayer = ESX.GetPlayerFromId(ServerId)
    if TPlayer ~= nil then
        TPlayer.Functions.SetMetaData('stress', 0)
        TriggerClientEvent('hud:client:UpdateStress', ServerId, 0)
        TPlayer.Functions.Save()
        TriggerClientEvent('QBCore:Notify', src, _U('removed_stress'), 'success')
    end
end)

RegisterNetEvent("mc-admin/server/set-armor", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    local TPlayer = ESX.GetPlayerFromId(ServerId)
    if TPlayer ~= nil then
        SetPedArmour(GetPlayerPed(ServerId), 100)
        TriggerClientEvent('QBCore:Notify', src, _U('gave_armor'), 'success')
    end
end)

RegisterNetEvent("mc-admin/server/reset-skin", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    local TPlayer = ESX.GetPlayerFromId(ServerId)
    local ClothingData = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { TPlayer.identifier, 1 })
    if ClothingData[1] ~= nil then
        TriggerClientEvent("qb-clothes:loadSkin", ServerId, false, ClothingData[1].model, ClothingData[1].skin)
    else
        TriggerClientEvent("qb-clothes:loadSkin", ServerId, true)
    end
end)

RegisterNetEvent("mc-admin/server/set-model", function(ServerId, Model)
    local src = source
    if not AdminCheck(src) then return end

    TriggerClientEvent('mc-admin/client/set-model', ServerId, Model)
end)

RegisterNetEvent("mc-admin/server/revive-in-distance", function()
    local src = source
    if not AdminCheck(src) then return end

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
    if not AdminCheck(src) then return end

    TriggerClientEvent('hospital:client:Revive', ServerId, true)
    TriggerClientEvent('QBCore:Notify', src, _U('revived'), 'success')
end)

RegisterNetEvent("mc-admin/server/open-clothing", function(ServerId)
    local src = source
    if not AdminCheck(src) then return end

    TriggerClientEvent('qb-clothing:client:openMenu', ServerId)
    TriggerClientEvent('QBCore:Notify', src, _U('gave_clothing'), 'success')
end)

