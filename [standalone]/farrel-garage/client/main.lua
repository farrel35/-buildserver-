local CurrentActionData, PlayerData, userProperties, this_Garage, vehInstance, BlipList, PrivateBlips, JobBlips = {}, {}, {}, {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, WasInPound, WasinJPound = false, false, false
local LastZone, CurrentAction, CurrentActionMsg
local garageName
local Vehicles = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	if Config.Pvt.Garages then
		ESX.TriggerServerCallback('farrel-garage:getOwnedProperties', function(properties)
			userProperties = properties
			DeletePrivateBlips()
			RefreshPrivateBlips()
		end)
	end

	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('farrel-garage:getPropertiesC')
AddEventHandler('farrel-garage:getPropertiesC', function(xPlayer)
	if Config.Pvt.Garages then
		ESX.TriggerServerCallback('farrel-garage:getOwnedProperties', function(properties)
			userProperties = properties
			DeletePrivateBlips()
			RefreshPrivateBlips()
		end)

		ESX.ShowNotification(_U('get_properties'))
		TriggerServerEvent('farrel-garage:printGetProperties')
	end
end)

local function has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- Start of Car Code
RegisterNetEvent('farrel-garage:ListOwnedCarsMenu')
AddEventHandler('farrel-garage:ListOwnedCarsMenu', function()
	if Vehicles == nil then 
		print('get price again')
		ESX.TriggerServerCallback('farrel-garage:getVehiclesInfo', function(vehicles)
			Vehicles = vehicles
		end)
		Wait(500)
	end

	ESX.TriggerServerCallback('farrel-garage:getOwnedCars', function(ownedCars)
		if #ownedCars == 0 then
			ESX.ShowNotification(_U('garage_no_cars'))
		else
			local menu = {
				{
					is_header = true,
					header = "Garasi - " .. garageName
				},
				{
					search = true,
					disabled = false
				},
			}	
			for _,v in pairs(ownedCars) do
				local vehicleName = v.vehiclename
				local plate = v.plate
				
				if vehicleName == nil or vehicleName == "" then 
					vehicleName = 'Unknown'
				end

				menu[#menu + 1] = {
					header = vehicleName,
					subheader = plate,
					searchable = true,
					action = function()
						SpawnVehicle(v.vehicle, v.plate)
					end
				}
			end
		   	ESX.CreateMenu(menu)
		end
	end, garageName)
end)

function getDamage(vehicle)
	local tyres = {}
	tyres[1] = {burst = IsVehicleTyreBurst(vehicle, 0, false), id = 0}
	tyres[2] = {burst = IsVehicleTyreBurst(vehicle, 1, false), id = 1}
	tyres[3] = {burst = IsVehicleTyreBurst(vehicle, 4, false), id = 4}
	tyres[4] = {burst = IsVehicleTyreBurst(vehicle, 5, false), id = 5}

	local doors = {}
	for i = 0, 5, 1 do
		doors[tostring(i)] = IsVehicleDoorDamaged(vehicle, i)
	end

	local windows = {}
	for i = 0, 13 do
		windows[tostring(i)] = IsVehicleWindowIntact(vehicle, i)
	end

	return
	{
		tyres	= tyres,
		doors	= doors,
		windows	= windows,
		engineHealth	= ESX.Math.Round(GetVehicleEngineHealth(vehicle), 1),	
		bodyHealth	= ESX.Math.Round(GetVehicleBodyHealth(vehicle), 1)
	}
end

RegisterNetEvent('farrel-garage:StoreOwnedCarsMenu')
AddEventHandler('farrel-garage:StoreOwnedCarsMenu', function()
	local playerPed  = PlayerPedId()

	if IsPedInAnyVehicle(playerPed,  false) then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		local current = 	GetPlayersLastVehicle(PlayerPedId(), true)
		local engineHealth = GetVehicleEngineHealth(current)
		local vehicleDamage = getDamage(vehicle)
		local plate = vehicleProps.plate

		ESX.TriggerServerCallback('farrel-garage:storeVehicle', function(valid)
			if valid then
				StoreVehicle(vehicle, vehicleProps, vehicleDamage)
			else
				ESX.ShowNotification(_U('cannot_store_vehicle'))
			end
		end, vehicleProps, garageName)
	else
		ESX.ShowNotification(_U('no_vehicle_to_enter'))
	end
end)

function ReturnOwnedCarsMenu()
	if Vehicles == nil then 
		print('get price again')
		ESX.TriggerServerCallback('farrel-garage:getVehiclesInfo', function(vehicles)
			Vehicles = vehicles
		end)
		Wait(500)
	end
	ESX.TriggerServerCallback('farrel-garage:getOutOwnedCars', function(ownedCars)
		local menu = {
			{
				is_header = true,
				header = "Asuransi"
			},
			{
				search = true,
				disabled = false
			},
		}	
		for _,v in pairs(ownedCars) do
			local vehicleName = v.vehiclename
			local plate = v.plate
			local vehiclePrice 	= 50000

			for i=1, #Vehicles, 1 do
				if vehicleName == Vehicles[i].name then
					vehiclePrice = Vehicles[i].price * 10
				end
			end

			price = ESX.Math.GroupDigits(vehiclePrice)

			if vehicleName == nil or vehicleName == "" then 
				vehicleName = 'Unknown'
			end

			menu[#menu + 1] = {
				header = vehicleName,
				subheader = plate,
				footer = "$" .. price,
				searchable = true,
				action = function()
					SpawnVehiclePound(v.vehicle, v.plate, vehiclePrice)
				end
			}
		end
	   		ESX.CreateMenu(menu)
	end)
end
-- End of Car Code

-- Store Vehicles
function StoreVehicle(vehicle, vehicleProps, vehicleDamage)
	for k,v in pairs (vehInstance) do
		if ESX.Math.Trim(v.plate) == ESX.Math.Trim(vehicleProps.plate) then
			table.remove(vehInstance, k)
		end
	end

	DeleteEntity(vehicle)
	TriggerServerEvent('farrel-garage:setVehicleState', vehicleProps.plate, true)
	TriggerServerEvent("farrel-garage:setrwt", vehicleDamage, vehicleProps.plate)
	ESX.ShowNotification(_U('vehicle_in_garage'))
end

-- Spawn Vehicles
function SpawnVehicle(vehicle, plate)
	if Vehicles == nil then 
		print('get price again')
		ESX.TriggerServerCallback('farrel-garage:getVehiclesInfo', function(vehicles)
			Vehicles = vehicles
		end)
		Wait(500)
	end
	for i=1, #Vehicles, 1 do
		if vehicle.model == GetHashKey(Vehicles[i].model) then
			vehicleName  = Vehicles[i].name
		end
	end
	ESX.TriggerServerCallback('farrel-garage:getSelectedVehicle',function(veh)
		for _,v in pairs(veh) do
			if v.rwt == nil or v.rwt == "" then 
				rwt = json.decode(v.vehicle)
			else
				rwt = json.decode(v.rwt)
			end
			
			ESX.Game.SpawnVehicle(vehicle.model, GetEntityCoords(PlayerPedId()), this_Garage.Heading, function(callback_vehicle)
				ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
				SetVehRadioStation(callback_vehicle, "OFF")
				SetVehicleFixed(callback_vehicle)
				SetVehicleDeformationFixed(callback_vehicle)
				SetVehicleUndriveable(callback_vehicle, false)
				SetVehicleEngineOn(callback_vehicle, true, true)

				if rwt.tyres ~= nil then
					for i,tyre in pairs(rwt.tyres) do
						if tyre.burst then
							print("Roda " .. tyre.id)
							SetVehicleTyreBurst(callback_vehicle, tyre.id, 0, 1000.0)
						end
					end
				end
		
				if rwt.doors ~= nil then
					for i,door in pairs(rwt.doors) do
						if door then
							print("Pintu " .. tonumber(i))
							SetVehicleDoorBroken(callback_vehicle, tonumber(i), true)
						end
					end
				end
		
				if rwt.windows ~= nil then
					for i,window in pairs(rwt.windows) do
						if window == false then
							-- print("Kaca" .. tonumber(i))
							SmashVehicleWindow(callback_vehicle, tonumber(i))
						end
					end
				end
				
				SetVehicleEngineHealth(callback_vehicle, rwt.engineHealth) -- Might not be needed
				SetVehicleBodyHealth(callback_vehicle, rwt.bodyHealth) -- Might not be needed
				local carplate = GetVehicleNumberPlateText(callback_vehicle)
				table.insert(vehInstance, {vehicleentity = callback_vehicle, plate = carplate})
				TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
			end)
		end
	end, plate)
	TriggerServerEvent('farrel-garage:setVehicleState', plate, false, vehicleName)
end

function SpawnVehiclePound(vehicle, plate, price)
	local doesVehicleExist = false

	for k,v in pairs (vehInstance) do
		if ESX.Math.Trim(v.plate) == ESX.Math.Trim(plate) then
			if DoesEntityExist(v.vehicleentity) then
				doesVehicleExist = true
			else
				table.remove(vehInstance, k)
				doesVehicleExist = false
			end
		end
	end

	if not doesVehicleExist and not DoesAPlayerDrivesVehicle(plate) then
		ESX.TriggerServerCallback('farrel-garage:checkMoneyCars', function(hasEnoughMoney)
			if hasEnoughMoney then
				if vehicle == nil then
				else
					SpawnVehicle(vehicle, plate)
					TriggerServerEvent('farrel-garage:payCar', price)
				end
			else
				ESX.ShowNotification(_U('not_enough_money'))
			end
		end)
	else
		ESX.ShowNotification(_U('cant_take_out'))
	end
end
-- Check Vehicles
function DoesAPlayerDrivesVehicle(plate)
	local isVehicleTaken = false
	local players = ESX.Game.GetPlayers()
	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])
		if target ~= PlayerPedId() then
			local plate1 = GetVehicleNumberPlateText(GetVehiclePedIsIn(target, true))
			local plate2 = GetVehicleNumberPlateText(GetVehiclePedIsIn(target, false))
			if plate == plate1 or plate == plate2 then
				isVehicleTaken = true
				break
			end
		end
	end
	return isVehicleTaken
end

-- Entered Marker
AddEventHandler('farrel-garage:hasEnteredMarker', function(zone)
	if zone == 'car_garage_point' then
		CurrentAction = 'car_garage_point'
		ESX.showTextUI(_U('press_to_enter'))
	elseif zone == 'car_pound_point' then
		CurrentAction = 'car_pound_point'
		CurrentActionMsg = _U('press_to_impound')
		CurrentActionData = {}
	end
end)

-- Exited Marker
AddEventHandler('farrel-garage:hasExitedMarker', function()
	ESX.hideTextUI()
	CurrentAction = nil
end)

-- Resource Stop
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		ESX.UI.Menu.CloseAll()
	end
end)

-- Enter / Exit marker events & Draw Markers
CreateThread(function()
	while true do
		Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		if Config.Cars.Garages then
			for k,v in pairs(Config.CarGarages) do
				local distance = #(playerCoords - v.Marker)
				local distance2 = #(playerCoords - v.Deleter)
				
				if distance < Config.Main.DrawDistance then
					letSleep = false

					if Config.Cars.Markers.Points.Type ~= -1 then
						DrawMarker(Config.Cars.Markers.Points.Type, v.Marker, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Cars.Markers.Points.x, Config.Cars.Markers.Points.y, Config.Cars.Markers.Points.z, Config.Cars.Markers.Points.r, Config.Cars.Markers.Points.g, Config.Cars.Markers.Points.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.Cars.Markers.Points.x then
						garageName, isInMarker, this_Garage, currentZone = k, true, v, 'car_garage_point'
					end
				end

				-- if distance2 < Config.Main.DrawDistance then
				-- 	letSleep = false

				-- 	if Config.Cars.Markers.Delete.Type ~= -1 then
				-- 		DrawMarker(Config.Cars.Markers.Delete.Type, v.Deleter, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Cars.Markers.Delete.x, Config.Cars.Markers.Delete.y, Config.Cars.Markers.Delete.z, Config.Cars.Markers.Delete.r, Config.Cars.Markers.Delete.g, Config.Cars.Markers.Delete.b, 100, false, true, 2, false, nil, nil, false)
				-- 	end

				-- 	if distance2 < Config.Cars.Markers.Delete.x then
				-- 		garageName, isInMarker, this_Garage, currentZone = k, true, v, 'car_store_point'
				-- 	end
				-- end
			end

			for k,v in pairs(Config.CarPounds) do
				local distance = #(playerCoords - v.Marker)

				if distance < Config.Main.DrawDistance then
					letSleep = false

					if Config.Cars.Markers.Pounds.Type ~= -1 then
						DrawMarker(Config.Cars.Markers.Pounds.Type, v.Marker, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Cars.Markers.Pounds.x, Config.Cars.Markers.Pounds.y, Config.Cars.Markers.Pounds.z, Config.Cars.Markers.Pounds.r, Config.Cars.Markers.Pounds.g, Config.Cars.Markers.Pounds.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.Cars.Markers.Pounds.x then
						isInMarker, this_Garage, currentZone = true, v, 'car_pound_point'
					end
				end
			end
		end

		if Config.Pvt.Garages then
			for k,v in pairs(Config.PrivateCarGarages) do
				if not v.Private or has_value(userProperties, v.Private) then
					local distance = #(playerCoords - v.Marker)
					local distance2 = #(playerCoords - v.Deleter)

					if distance < Config.Main.DrawDistance then
						letSleep = false

						if Config.Pvt.Markers.Points.Type ~= -1 then
							DrawMarker(Config.Pvt.Markers.Points.Type, v.Marker, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Pvt.Markers.Points.x, Config.Pvt.Markers.Points.y, Config.Pvt.Markers.Points.z, Config.Pvt.Markers.Points.r, Config.Pvt.Markers.Points.g, Config.Pvt.Markers.Points.b, 100, false, true, 2, false, nil, nil, false)
						end

						if distance < Config.Pvt.Markers.Points.x then
							isInMarker, this_Garage, currentZone = true, v, 'car_garage_point'
						end
					end

					if distance2 < Config.Main.DrawDistance then
						letSleep = false

						if Config.Pvt.Markers.Delete.Type ~= -1 then
							DrawMarker(Config.Pvt.Markers.Delete.Type, v.Deleter, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Pvt.Markers.Delete.x, Config.Pvt.Markers.Delete.y, Config.Pvt.Markers.Delete.z, Config.Pvt.Markers.Delete.r, Config.Pvt.Markers.Delete.g, Config.Pvt.Markers.Delete.b, 100, false, true, 2, false, nil, nil, false)
						end

						if distance2 < Config.Pvt.Markers.Delete.x then
							isInMarker, this_Garage, currentZone = true, v, 'car_store_point'
						end
					end
				end
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker, LastZone = true, currentZone
			LastZone = currentZone
			TriggerEvent('farrel-garage:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('farrel-garage:hasExitedMarker', LastZone)
		end

		if letSleep then
			Wait(1000)
		end
	end
end)

-- -- Key Controls
-- CreateThread(function()
-- 	while true do
-- 		Wait(0)
-- 		local playerPed = PlayerPedId()
-- 		local playerVeh = GetVehiclePedIsIn(playerPed, false)
-- 		local model = GetEntityModel(playerVeh)

-- 		if CurrentAction then
-- 			ESX.showTextUI(CurrentActionMsg)

-- 			if IsControlJustReleased(0, 38) then
-- 				if CurrentAction == 'car_garage_point' then
-- 					ListOwnedCarsMenu()
-- 				elseif CurrentAction == 'car_store_point' then
-- 					if IsThisModelACar(model) or IsThisModelABicycle(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model) then
-- 						if (GetPedInVehicleSeat(playerVeh, -1) == playerPed) then
-- 							StoreOwnedCarsMenu()
-- 						else
-- 							ESX.ShowNotification(_U('driver_seat'))
-- 						end
-- 					else
-- 						ESX.ShowNotification(_U('not_correct_veh'))
-- 					end
-- 				elseif CurrentAction == 'car_pound_point' then
-- 					ReturnOwnedCarsMenu()
-- 				end

-- 				CurrentAction = nil
-- 			end
-- 		else
-- 			ESX.hideTextUI()
-- 			Wait(500)
-- 		end
-- 	end
-- end)

-- Create Blips
CreateThread(function()
	if Config.Cars.Garages and Config.Cars.Blips then
		for k,v in pairs(Config.CarGarages) do
			print(v.Marker)
			local blip = AddBlipForCoord(v.Marker)

			SetBlipSprite (blip, Config.Blips.Garages.Sprite)
			SetBlipColour (blip, Config.Blips.Garages.Color)
			SetBlipDisplay(blip, Config.Blips.Garages.Display)
			SetBlipScale  (blip, Config.Blips.Garages.Scale)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('blip_garage'))
			EndTextCommandSetBlipName(blip)
			table.insert(BlipList, blip)
		end

		for k,v in pairs(Config.CarPounds) do
			local blip = AddBlipForCoord(v.Marker)

			SetBlipSprite (blip, Config.Blips.Pounds.Sprite)
			SetBlipColour (blip, Config.Blips.Pounds.Color)
			SetBlipDisplay(blip, Config.Blips.Pounds.Display)
			SetBlipScale  (blip, Config.Blips.Pounds.Scale)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('blip_pound'))
			EndTextCommandSetBlipName(blip)
			table.insert(BlipList, blip)
		end
	end
end)

-- Handles Private Blips
function DeletePrivateBlips()
	if PrivateBlips[1] ~= nil then
		for i=1, #PrivateBlips, 1 do
			RemoveBlip(PrivateBlips[i])
			PrivateBlips[i] = nil
		end
	end
end

function RefreshPrivateBlips()
	for zoneKey,zoneValues in pairs(Config.PrivateCarGarages) do
		if zoneValues.Private and has_value(userProperties, zoneValues.Private) then
			local blip = AddBlipForCoord(zoneValues.Marker)

			SetBlipSprite (blip, Config.Blips.PGarages.Sprite)
			SetBlipColour (blip, Config.Blips.PGarages.Color)
			SetBlipDisplay(blip, Config.Blips.PGarages.Display)
			SetBlipScale  (blip, Config.Blips.PGarages.Scale)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('blip_garage_private'))
			EndTextCommandSetBlipName(blip)
			table.insert(PrivateBlips, blip)
		end
	end
end

function DrawTxt(text, x, y)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

-- CreateThread(function()
--     while true do
-- 		Wait(0)

		
-- 		veheng = GetVehicleEngineHealth(GetVehiclePedIsUsing(PlayerPedId()))
-- 		vehbody = GetVehicleBodyHealth(GetVehiclePedIsUsing(PlayerPedId()))
-- 		if IsPedInAnyVehicle(PlayerPedId(), 1) then
-- 			vehenground = tonumber(string.format("%.2f", veheng))
-- 			vehbodround = tonumber(string.format("%.2f", vehbody))

-- 			DrawTxt("~r~Engine Health: ~s~"..vehenground, 0.015, 0.76)

-- 			DrawTxt("~r~Body Health: ~s~"..vehbodround, 0.015, 0.73)

-- 			DrawTxt("~r~Vehicle Fuel: ~s~"..tonumber(string.format("%.2f", GetVehicleFuelLevel(GetVehiclePedIsUsing(PlayerPedId())))), 0.015, 0.70)
-- 		end
--     end
-- end)

local function UpdateRadialMenu()
	print(CurrentAction)
    local inGarage = CurrentAction
    if inGarage ~= nil then
		if IsPedInAnyVehicle(PlayerPedId(), 1) then
			MenuItemId = exports['farrel-radialmenu']:AddOption({
				id = 'open_garage_menu',
				title = 'Masukan Kendaraan',
				icon = 'warehouse',
				type = 'client',
				event = 'farrel-garage:StoreOwnedCarsMenu',
				shouldClose = true
			}, MenuItemId)
		else
			MenuItemId = exports['farrel-radialmenu']:AddOption({
				id = 'open_garage_menu',
				title = 'Garasi',
				icon = 'warehouse',
				type = 'client',
				event = 'farrel-garage:ListOwnedCarsMenu',
				shouldClose = true
			}, MenuItemId)
		end
	else
        if MenuItemId ~= nil then
            exports['farrel-radialmenu']:RemoveOption(MenuItemId)
            MenuItemId = nil
        end
    end
end

RegisterNetEvent('qb-radialmenu:client:onRadialmenuOpen', function()
    UpdateRadialMenu()
end)
