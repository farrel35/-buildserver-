local droneHash = 'frogger'
local speed = 120.0
local blipsDrone = {}
local drone = {
    active = false,
    vehicleHandle = 0,
    driverHandle = 0,
    cameraEnabled = false,
    cameraHandle = 0,
    nightVisionEnabled = false,
    thermalEnabled = false,
    landing = false,
    tablet = 0,
}
local fov_max = 80.0
local fov_min = 5.0 -- max zoom level (smaller fov is more zoom)
local zoomspeed = 3.0 -- camera zoom speed
local fov = (fov_max+fov_min)*0.5

CreateThread(function()
    while (true) do
        if (drone.active) then
            local coords = GetEntityCoords(PlayerPedId(), true)
            local droneCoords = GetEntityCoords(drone.vehicleHandle, true)
            local distance = #(coords - droneCoords)

            SetTextFont(2)
            SetTextScale(0.5, 0.5)
            SetTextWrap(0.0, 1.0)
            SetTextCentre(false)
            SetTextDropshadow(2, 2, 0, 0, 0)
            SetTextEdge(1, 0, 0, 0, 205)
            SetTextEntry("STRING")
            AddTextComponentString("Distance " .. math.floor(distance))
            DrawText(0.2, 0.95)

            if (distance <= 1000.0) then
                if not NetworkHasControlOfEntity(drone.driverHandle) then
                    NetworkRequestControlOfEntity(drone.driverHandle)
                elseif not NetworkHasControlOfEntity(drone.vehicleHandle) then
                    NetworkRequestControlOfEntity(drone.vehicleHandle)
                end
            else
                ESX.ShowNotification("You have lost control of the drone, after going out of range")
                for i = 5,1,-1 do 
                    ESX.ShowNotification("Will be lost in " .. i)
                    Wait(1000)
                end
                deleteDrone()
            end
            
            SetVehicleSilent(drone.vehicleHandle, true)
            SetEntityNoCollisionEntity(PlayerPedId(), drone.vehicleHandle, 1)
            DisableControlAction(0, 172, true)
            DisableControlAction(1, 172, true)
            DisableControlAction(0, 300, true)
            DisableControlAction(0, 27, true)
            DisableControlAction(1, 27, true)
            DisableControlAction(0, 188, true)
            DisableControlAction(1, 188, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 209, true)
            DisableControlAction(0, 210, true)
            DisableControlAction(0, 174, true)
            DisableControlAction(0, 175, true)
            DisableControlAction(0, 173, true)
            DisableControlAction(0, 121, true)
            local pressed = false
            

            local targetHeading = GetEntityHeading(drone.vehicleHandle)
            local offSet = GetEntityCoords(drone.vehicleHandle)
            local zChange = 0
            --offSet.x = 0.0
           -- offSet.y = 0.0
           -- offSet.z = 0.0
            -- Moving Up
            if IsDisabledControlPressed(0, 209) then
                drone.landing = false
                --local offSet2 = GetOffsetFromEntityInWorldCoords(drone.vehicleHandle, 0.0, 0.0, 3.0)
                --offSet = offSet2
                zChange = 100.0
                pressed = true 
            end

            -- Moving Down
            if IsDisabledControlPressed(0, 210) then
                --local offSet2 = GetOffsetFromEntityInWorldCoords(drone.vehicleHandle, 0.0, 0.0, -3.0)
                --offSet = offSet2
                zChange = -100.0
                pressed = true
            end
            DisableControlAction(0, 32)
            DisableControlAction(0, 33)
            DisableControlAction(0, 34)
            DisableControlAction(0, 35)
            if (IsDisabledControlPressed(0, 32)) then
                local offSet2 = GetOffsetFromEntityInWorldCoords(drone.vehicleHandle, 0.0, 100.0, 0.0)
                offSet = offSet2
                pressed = true
            end

            -- Backward
            if (IsDisabledControlPressed(0, 33)) then
                local offSet2 = GetOffsetFromEntityInWorldCoords(drone.vehicleHandle, 0.0, -100.0, 0.0)
                offSet = offSet2
                pressed = true
            end

            -- Left
            if (IsDisabledControlPressed(0, 34)) then
                targetHeading = targetHeading + 90.0
                
                pressed = true
            end

            -- Right
            if (IsDisabledControlPressed(0, 35)) then
                targetHeading = targetHeading - 90.0

                if targetHeading <= 0 then
                    targetHeading = 300
                end
                
                pressed = true
            end

            if not drone.landing then
                TaskHeliMission(drone.driverHandle, drone.vehicleHandle, nil, nil, offSet.x, offSet.y, offSet.z + zChange, 4, speed, 1.0, targetHeading, -1, -1, -1, 0)
            end
            
            -- Land
            if (IsDisabledControlJustPressed(0, 121)) then
                drone.landing = true
                local offSet = GetOffsetFromEntityInWorldCoords(drone.driverHandle, 0.0, 3.0, 0.0)
                TaskHeliMission(drone.driverHandle, drone.vehicleHandle, 0, 0, offSet.x, offSet.y, offSet.z + 2.0, 20, speed, 10.0, GetEntityHeading(drone.driverHandle), -1, -1, -1, 32)
                pressed = true
            end

            -- Camera
            if IsControlJustPressed(0, 101) then
                if (drone.cameraEnabled) then
                    if (drone.nightVisionEnabled) then
                        SetNightvision(false)
                        drone.nightVisionEnabled = false
                    else
                        SetNightvision(true)
                        drone.nightVisionEnabled = true
                    end
                end
            end

            if IsControlJustPressed(0, 51) then
                if (drone.cameraEnabled) then
                    if (drone.thermalEnabled) then
                        SetSeethrough(false)
                        drone.thermalEnabled = false
                    else
                        SetSeethrough(true)
                        drone.thermalEnabled = true
                    end
                end
            end

            if IsDisabledControlJustPressed(0, 24) then
                toggleCamera()
            end
            pressed = false
        end
        Wait(0)
    end
end)

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(0, 209, true))
    ButtonMessage("Up")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(0, 35, true))
    ButtonMessage("Turn Right")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(0, 34, true)) -- The button to display
    ButtonMessage("Turn Left") -- the message to display next to it
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(0, 33, true))
    ButtonMessage("Backward")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(0, 32, true))
    ButtonMessage("Forward")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    Button(GetControlInstructionalButton(0, 24, true))
    ButtonMessage("Camera Stream")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    Button(GetControlInstructionalButton(0, 101, true))
    ButtonMessage("Night Vision")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(7)
    Button(GetControlInstructionalButton(0, 51, true))
    ButtonMessage("Thermal Imaging")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(8)
    Button(GetControlInstructionalButton(0, 121, true))
    ButtonMessage("Land")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

CreateThread(function()
    form = setupScaleform("instructional_buttons")
    while true do
        if (drone.active) then
            DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
        end
        Wait(0)
    end
end)

function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

function newDrone()
    local modelHash = droneHash
    loadModel(modelHash)
    local pedModel = 's_m_m_bouncer_01'
    loadModel(pedModel)
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0)
    local heading = GetEntityHeading(ped)
    drone.vehicleHandle = CreateVehicle(droneHash, coords, heading, true)
    while not DoesEntityExist(drone.vehicleHandle) do Wait(0) end
    SetModelAsNoLongerNeeded(modelHash)
    Wait(1000)
    FreezeEntityPosition(ped, true)
    SetEntityAsMissionEntity(drone.vehicleHandle, true, true)
    local netVeh = NetworkGetNetworkIdFromEntity(drone.vehicleHandle)
    NetworkSetNetworkIdDynamic(netVeh, true)
    SetNetworkIdCanMigrate(netVeh, true)
    SetNetworkIdExistsOnAllMachines(netVeh, true)
    drone.driverHandle = CreatePed(4, pedModel, coords, heading, true)
    while not DoesEntityExist(drone.driverHandle) do Wait(0) end
    SetModelAsNoLongerNeeded(pedModel)
    SetEntityInvincible(drone.driverHandle, true)
    SetEntityVisible(drone.driverHandle, false)
    FreezeEntityPosition(drone.driverHandle, true)
    SetPedAlertness(drone.driverHandle, 0.0)
    TaskWarpPedIntoVehicle(drone.driverHandle, drone.vehicleHandle, -1)
    while not IsPedInVehicle(drone.driverHandle, drone.vehicleHandle) do
        Wait(0)
    end
    createBlip(drone.driverHandle)
    drone.active = true
    ESX.ShowNotification("Drone created")
end

function createBlip(id)
	local ped = id
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then 
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Drone Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName("Drone")
		EndTextCommandSetBlipName(blip)
	end
end

function deleteDrone()
    Wait(500)
    drone.active = false
    DeletePed(drone.driverHandle)
    SetEntityAsMissionEntity(drone.vehicleHandle, 0, 0)
    DeleteEntity(drone.vehicleHandle)
    SetModelAsNoLongerNeeded(droneHash)
    if drone.cameraEnabled then
        toggleCamera()
    end
    FreezeEntityPosition(PlayerPedId(), false)
    ESX.ShowNotification("Drone removed")
end

function toggleCamera()
    local ped = PlayerPedId()
    

    if (drone.cameraEnabled) then
        if DoesEntityExist(drone.tablet) then
            DeleteEntity(drone.tablet)
            ClearPedTasks(ped)
        end
        local easeTime = 500 * math.ceil(GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(drone.vehicleHandle), true) / 10)
        RenderScriptCams(0, 0, easeTime, 1, 0)
        ClearTimecycleModifier()
        if (DoesCamExist(drone.cameraHandle)) then
            DestroyCam(drone.cameraHandle)
        end
        drone.cameraEnabled = false

        if (drone.nightVisionEnabled) then
            SetNightvision(false)
            drone.nightVisionEnabled = false
        end
        if (drone.thermalEnabled) then
            SetSeethrough(false)
            drone.thermalEnabled = false
        end
    else
        local modelHash = 'prop_cs_tablet'
        loadModel(modelHash)
        drone.tablet = CreateObject(modelHash, GetEntityCoords(ped), true)
        AttachEntityToEntity(drone.tablet, ped, GetPedBoneIndex(ped, 28422), -0.03, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@idle_a")
        while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@idle_a") do
            Wait(0)
        end
        TaskPlayAnim(ped, "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        drone.cameraEnabled = true
        drone.cameraHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        --local boneIndex = GetEntityBoneIndexByName(drone.vehicleHandle, "chassis")
        local change = {}
        change.x = 0.0
        change.y = 0.0
        change.z = 0.0
        AttachCamToEntity(drone.cameraHandle, drone.vehicleHandle, 0.0, 0.1, -0.1, true)
        --AttachCamToVehicleBone(drone.cameraHandle, drone.vehicleHandle, boneIndex, false, 0.0, 0.0, 0.0, -0.3, 0.0, 1.2, true)
        CreateThread(function()
            while DoesCamExist(drone.cameraHandle) do
                HandleZoom(drone.cameraHandle)
                local rotation = GetEntityRotation(drone.vehicleHandle, 1)
                
                if IsDisabledControlPressed(0, 172) then
                    change.x = change.x + 1.0
                end
                if IsDisabledControlPressed(0, 173) then
                    change.x = change.x - 1.0
                end
                if IsDisabledControlPressed(0, 174) then
                    change.z = change.z + 1.0
                end
                if IsDisabledControlPressed(0, 175) then
                    change.z = change.z - 1.0
                end
                
                SetCamRot(drone.cameraHandle, rotation.x + change.x, rotation.y + change.y, rotation.z + change.z, 1)
                
                if not IsEntityPlayingAnim(ped, "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3) then
                    TaskPlayAnim(ped, "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
                end
                
                Wait(0)
            end
            ClearPedTasks(ped)
        end)
        local easeTime = 100 * math.ceil(GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(drone.vehicleHandle), true) / 10)

        RenderScriptCams(1, 1, easeTime, 1, 1)

        Wait(easeTime)

        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(0.7)
    end
end

function HandleZoom(cam)
	if IsControlJustPressed(0,241) then -- Scrollup
		fov = math.max(fov - zoomspeed, fov_min)
	end
	if IsControlJustPressed(0,242) then
		fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown		
	end
	local current_fov = GetCamFov(cam)
	if math.abs(fov-current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
		fov = current_fov
	end
	SetCamFov(cam, current_fov + (fov - current_fov)*0.05) -- Smoothing of camera zoom
end
