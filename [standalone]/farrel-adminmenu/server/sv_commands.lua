

-- [ Code ] --

-- [ Commands ] --

-- Mercy.Commands.Add('newmenu', _U("keymapping_desc"), {}, false, function(source)
--     local src = source
--     TriggerClientEvent('mc-admin/client/try-open-menu', src, false)
-- end, 'admin')

-- Mercy.Commands.Add('resetmenu', _U("reset_data"), {}, false, function(source)
--     TriggerClientEvent('mc-admin/client/reset-menu', -1, false)
-- end, 'admin')

-- Console

RegisterCommand('AdminPanelKick', function(source, args, rawCommand)
    if source == 0 then
        local ServerId = tonumber(args[1])
        table.remove(args, 1)
        local Msg = table.concat(args, " ")
        DropPlayer(ServerId, _U('kicked', {reason = Msg}))
    end
end, false)

RegisterCommand('AdminPanelAddItem', function(source, args, rawCommand)
    if source == 0 then
        local ServerId, ItemName, ItemAmount = tonumber(args[1]), tostring(args[2]), tonumber(args[3])
        local Player = ESX.GetPlayerFromId(ServerId)
        if Player ~= nil then
            Player.Functions.AddItem(ItemName, ItemAmount, false, false)
            print(_U('gaveitem', {amount = ItemAmount, name = ItemName}))
        end
    end
end, false)

RegisterCommand('AdminPanelAddMoney', function(source, args, rawCommand)
    if source == 0 then
        local ServerId, Amount = tonumber(args[1]), tonumber(args[2])
        local Player = ESX.GetPlayerFromId(ServerId)
        if Player ~= nil then
            Player.Functions.AddMoney('cash', Amount)
        end
    end
end, false)

RegisterCommand('AdminPanelSetJob', function(source, args, rawCommand)
    if source == 0 then
        local ServerId, JobName, Grade = tonumber(args[1]), tostring(args[2]), tonumber(args[3])
        local Player = ESX.GetPlayerFromId(ServerId)
        if Player ~= nil then
            Player.Functions.SetJob(JobName, Grade)
            print(_U('setjob', {jobname = JobName}))
        end
    end
end, false)

RegisterCommand('AdminPanelRevive', function(source, args, rawCommand)
    if source == 0 then
        local ServerId = tonumber(args[1])
        TriggerClientEvent('hospital:client:Revive', ServerId, true)
        print(_U('revived'))
    end
end, false)