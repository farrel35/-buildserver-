

function getIdentity(source)
	local identifier 
	for k,v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, 'steam:') then
			identifier = string.gsub(v, 'steam:', '')
		end
	end

	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			dateofbirth = identity['dateofbirth'],
			sex = identity['sex'],
			height = identity['height'],
			permission_level = identity['permission_level']
		}
	else
		return nil
	end
end

RegisterCommand('clear', function(source, args, rawCommand)
    TriggerClientEvent('chat:client:ClearChat', source)
end, false)

RegisterCommand('ooc', function(source, args, rawCommand)
    local msg = rawCommand:sub(4)
    if player ~= false then
        local user = GetPlayerName(source)
            TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message ooc"><b>OOC | {0}:</b> {1}</div>',
            args = { user, msg }
        })
    end
end, false)

RegisterCommand('iklan', function(source, args, rawCommand)
    local msg = rawCommand:sub(6)
    local xPlayer = ESX.GetPlayerFromId(source)
    if player ~= false then
        local name = getIdentity(source)
            TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message jual"><b>IKLAN | {0}:</b> {1}</div>',
            args = { name.firstname .. " " .. name.lastname, msg }
        })
        TriggerClientEvent('tasknotify:SendAlert', source, 'red','Membayar $10.000',10000)
        xPlayer.removeAccountMoney('money', 10000)
    end
end, false)
RegisterCommand('ems', function(source, args, rawCommand)
    local msg = rawCommand:sub(4)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade
    local name = getIdentity(source)
        if player ~= false then
            local user = GetPlayerName(source)
            if job == 'ambulance' then
                TriggerClientEvent('chat:addMessage', -1, {
                template = '<div class="chat-message ems"><b>EMS | {0}:</b> {1}</div>',
                args = { name.firstname .. " " .. name.lastname, msg }
            })
        else 
            TriggerClientEvent('tasknotify:SendAlert', source, 'red','Anda bukan EMS!!!',10000)
        end
    end
end, false)

RegisterCommand('pol', function(source, args, rawCommand)
    
    local msg = rawCommand:sub(4)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade
    local name = getIdentity(source)
        if player ~= false then
            local user = GetPlayerName(source)
            print(user)
            if job == 'police' then
                TriggerClientEvent('chat:addMessage', -1, {
                template = '<div class="chat-message polisi"><b>POLISI | {0}:</b> {1}</div>',
                args = { name.firstname .. " " .. name.lastname, msg }
            })
        else 
            TriggerClientEvent('tasknotify:SendAlert', source, 'red','Anda bukan POLISI!!!',10000)
        end
    end
end, false)

RegisterCommand('mech', function(source, args, rawCommand)
    
    local msg = rawCommand:sub(5)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade
    local name = getIdentity(source)
        if player ~= false then
            local user = GetPlayerName(source)
            if job == 'mechanic' then
                TriggerClientEvent('chat:addMessage', -1, {
                template = '<div class="chat-message mekanik"><b>MEKANIK | {0}:</b> {1}</div>',
                args = { name.firstname .. " " .. name.lastname, msg }
            })
        else 
            TriggerClientEvent('tasknotify:SendAlert', source, 'red','Anda bukan MEKANIK!!!',10000)
        end
    end
end, false)

RegisterCommand('taxi', function(source, args, rawCommand)
    
    local msg = rawCommand:sub(5)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade
    local name = getIdentity(source)
        if player ~= false then
            local user = GetPlayerName(source)
            if job == 'taxi' then
                TriggerClientEvent('chat:addMessage', -1, {
                template = '<div class="chat-message taxi"><b>TAXI | {0}:</b> {1}</div>',
                args = { name.firstname .. " " .. name.lastname, msg }
            })
        else 
            TriggerClientEvent('tasknotify:SendAlert', source, 'red','Anda bukan TAXI!!!',10000)
        end
    end
end, false)

RegisterCommand('do', function(source, args, rawCommand)
    local name = getIdentity(source)
    local msg = rawCommand:sub(3)
    TriggerClientEvent('sendProximityMessageDo', -1, source, name.firstname .. " " .. name.lastname, msg)
end)


RegisterCommand('showsociety', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job.grade_name == 'boss' then
		local society = GetSociety(xPlayer.job.name)

		if society ~= nil then
			TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
				money = account.money
			end)
		else
			money = 0
		end
        --TriggerClientEvent('esx:showNotification', _source, 'You currently have ~g~$~g~' .. money .. ' ~s~in the society account~g~ ')
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Uang perusahaan $' .. money})															
    end
end,false)

TriggerEvent('esx_society:getSocieties', function(societies) 
	RegisteredSocieties = societies
end)

function GetSociety(name)
  for i=1, #RegisteredSocieties, 1 do
    if RegisteredSocieties[i].name == name then
      return RegisteredSocieties[i]
    end
  end
end