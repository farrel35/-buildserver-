-- Make sure all Vehicles are Stored on restart
MySQL.ready(function()
	if Config.Main.ParkVehicles then
		ParkVehicles()
	else
		print('farrel-garage: Parking Vehicles on restart is currently set to false.')
	end
end)

function ParkVehicles()
	MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = true WHERE `stored` = @stored', {
		['@stored'] = false
	}, function(rowsChanged)
		if rowsChanged > 0 then
			print(('farrel-garage: %s vehicle(s) have been stored!'):format(rowsChanged))
		end
	end)
end

-- Add Command for Getting Properties
if Config.Main.Commands then
	ESX.RegisterCommand('getgarages', 'user', function(xPlayer, args, showError)
		xPlayer.triggerEvent('farrel-garage:getPropertiesC')
	end, true, {help = 'Get Private Garages', validate = false})
end

-- Add Print Command for Getting Properties
RegisterServerEvent('farrel-garage:printGetProperties')
AddEventHandler('farrel-garage:printGetProperties', function()
	print('Getting Properties')
end)

-- Get Owned Properties
ESX.RegisterServerCallback('farrel-garage:getOwnedProperties', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local properties = {}

	MySQL.Async.fetchAll('SELECT * FROM owned_properties WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function(data)
		for _,v in pairs(data) do
			table.insert(properties, v.name)
		end
		cb(properties)
	end)
end)

-- Start of Car Code
ESX.RegisterServerCallback('farrel-garage:getOwnedCars', function(source, cb, garageName)
	local ownedCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored AND garage = @garage', { -- job = NULL
		['@owner'] = xPlayer.identifier,
		['@Type'] = 'car',
		['@job'] = 'civ',
		['@stored'] = true,
		['@garage'] = garageName
	}, function(data)
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate, vehiclename = v.vehicle_name})
		end
		cb(ownedCars)
	end)
end)

ESX.RegisterServerCallback('farrel-garage:getOutOwnedCars', function(source, cb)
	local ownedCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored', { -- job = NULL
		['@owner'] = xPlayer.identifier,
		['@Type'] = 'car',
		['@job'] = 'civ',
		['@stored'] = false
	}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate, vehiclename = v.vehicle_name})
		end
		cb(ownedCars)
	end)
end)

ESX.RegisterServerCallback('farrel-garage:checkMoneyCars', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.Cars.PoundP then
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('farrel-garage:payCar')
AddEventHandler('farrel-garage:payCar', function(price)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(price)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. ESX.Math.GroupDigits(price))
end)
-- End of Car Code

-- Store Vehicles
ESX.RegisterServerCallback('farrel-garage:storeVehicle', function (source, cb, vehicleProps, garageName)
	local ownedCars = {}
	local vehplate = vehicleProps.plate:match("^%s*(.-)%s*$")
	local vehiclemodel = vehicleProps.model
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND @plate = plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = vehicleProps.plate
	}, function (result)
		if result[1] ~= nil then
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage WHERE owner = @owner AND plate = @plate', {
					['@owner'] = xPlayer.identifier,
					['@vehicle'] = json.encode(vehicleProps),
					['@garage'] = garageName,
					['@plate'] = vehicleProps.plate
				}, function (rowsChanged)
					if rowsChanged == 0 then
						print(('farrel-garage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
					end
					cb(true)
				end)
			else
				if Config.Main.KickCheaters then
					if Config.Main.CustomKickMsg then
						print(('farrel-garage: %s attempted to Cheat! Tried Storing: %s | Original Vehicle: %s '):format(xPlayer.identifier, vehiclemodel, originalvehprops.model))

						DropPlayer(source, _U('custom_kick'))
						cb(false)
					else
						print(('farrel-garage: %s attempted to Cheat! Tried Storing: %s | Original Vehicle: %s '):format(xPlayer.identifier, vehiclemodel, originalvehprops.model))

						DropPlayer(source, 'You have been Kicked from the Server for Possible Garage Cheating!!!')
						cb(false)
					end
				else
					print(('farrel-garage: %s attempted to Cheat! Tried Storing: %s | Original Vehicle: %s '):format(xPlayer.identifier, vehiclemodel, originalvehprops.model))
					cb(false)
				end
			end
		else
			print(('farrel-garage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
			cb(false)
		end
	end)
end)

RegisterServerEvent('farrel-garage:setrwt')
AddEventHandler('farrel-garage:setrwt', function(props, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE owned_vehicles SET rwt = @rwt WHERE plate = @plate', {
		['@rwt'] = json.encode(props),
		['@plate'] = plate
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print(('farrel-garage: %s exploited the garage!'):format(xPlayer.identifier))
		end
	end)
end)
-- Modify State of Vehicles
RegisterServerEvent('farrel-garage:setVehicleState')
AddEventHandler('farrel-garage:setVehicleState', function(plate, state, vehicleName)
	local xPlayer = ESX.GetPlayerFromId(source)

	if vehicleName ~= nil then
		MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = @stored, vehicle_name = @vehicleName WHERE plate = @plate', {
			['@stored'] = state,
			['@vehicleName'] = vehicleName,
			['@plate'] = plate
		}, function(rowsChanged)
			if rowsChanged == 0 then
				print(('farrel-garage: %s exploited the garage!'):format(xPlayer.identifier))
			end
		end)
	else
		MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = @stored WHERE plate = @plate', {
			['@stored'] = state,
			['@plate'] = plate
		}, function(rowsChanged)
			if rowsChanged == 0 then
				print(('farrel-garage: %s exploited the garage!'):format(xPlayer.identifier))
			end
		end)
	end
end)

ESX.RegisterServerCallback('farrel-garage:getVehiclesInfo', function(source, cb)
	MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
		local vehicles = {}

		for i=1, #result, 1 do
			table.insert(vehicles, {
				model = result[i].model,
				price = result[i].price,
				name = result[i].name,
			})
		end
		Vehicles = vehicles
		cb(Vehicles)
	end)
end)

ESX.RegisterServerCallback('farrel-garage:getSelectedVehicle', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles where plate = @plate ', {
		['@plate'] = plate
	}, function(result)
		local vehicles = {}

		for i=1, #result, 1 do
			table.insert(vehicles, {
				vehicle = result[i].vehicle,
				plate = result[i].plate,
				rwt = result[i].rwt
			})
		end

		Vehicles = vehicles
		cb(Vehicles)
	end)
end)