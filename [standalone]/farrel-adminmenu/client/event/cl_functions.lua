local DRUNK_ANIM_SET = "move_m@drunk@verydrunk"
local DRUNK_DRIVING_EFFECTS = {
    1, -- brake
    7, --turn left + accelerate
    8, -- turn right + accelerate
    23, -- accelerate
    4, -- turn left 90 + braking
    5, -- turn right 90 + braking
}

-- [ Functions ] --

function ToggleDevMode(Bool)
    if Bool then
        SetPlayerInvincible(PlayerId(), true)
    else
        SetPlayerInvincible(PlayerId(), false)
    end
end

function UpdateMenu()
    local Bans = GetBans()
    local Players = GetPlayers()
    SendNUIMessage({
        Action = 'Update',
        Debug = Config.Settings['Debug'],
        Bans = Bans,
        AllPlayers = Players,
        AdminItems = Config.AdminMenus,
        Favorited = Config.FavoritedItems,
    })
end

function SetKvp(Name, Data, Type)
    SetResourceKvp(Name, Data)
    RefreshMenu(Type)
end

function ResetMenuKvp()
    SetResourceKvp("farrel-adminmenu-favorites", "[]")
    Config.FavoritedItems = {}
    RefreshMenu('All')
end

function RefreshMenu(Type)
    if Type == 'Favorites' then
        -- Favorites
        if GetResourceKvpString("farrel-adminmenu-favorites") == nil or GetResourceKvpString("farrel-adminmenu-favorites") == "[]" then
            Config.FavoritedItems = GenerateFavorites()
            SetResourceKvp("farrel-adminmenu-favorites", json.encode(Config.FavoritedItems))
        else
            Config.FavoritedItems = json.decode(GetResourceKvpString("farrel-adminmenu-favorites"))
        end
    elseif Type == 'All' then
        if GetResourceKvpString("farrel-adminmenu-favorites") == nil or GetResourceKvpString("farrel-adminmenu-favorites") == "[]" then
            Config.FavoritedItems = GenerateFavorites()
            SetResourceKvp("farrel-adminmenu-favorites", json.encode(Config.FavoritedItems))
        else
            Config.FavoritedItems = json.decode(GetResourceKvpString("farrel-adminmenu-favorites"))
        end
    end
    UpdateMenu()
end

function DebugLog(Message)
    if Config.Settings['Debug'] then
        print('[DEBUG]: ', Message)
    end
end

function DrawText3D(Coords, Text)
    local OnScreen, _X, _Y = World3dToScreen2d(Coords.x, Coords.y, Coords.z)
    SetTextScale(0.3, 0.3)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 0, 0, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(Text)
    DrawText(_X, _Y)
end

function roundDecimals(num, decimals)
	local mult = math.pow(10, decimals or 0)
	return math.floor(num * mult + 0.5) / 100
end

function DeletePlayerBlips()
    if AllPlayerBlips ~= nil then
        for k, v in pairs(AllPlayerBlips) do
            RemoveBlip(v) 
        end
        AllPlayerBlips = {}
    end
end

-- Get
function GetInventoryItems()
    local Inventory = {}
    if GetResourceState('ox_inventory') == 'started' then
        for k, v in pairs(exports.ox_inventory:Items()) do
            Inventory[#Inventory + 1] = {
                Text = k,
                Label = ' ['..v.label..']'
            }
            table.sort(Inventory, function(a, b)
                 return a.Text > b.Text
            end)
        end
    end
    
    return Inventory
end

function GetJobs()
    local Jobs = {}
    ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(jobs)
        for k, v in pairs(jobs) do
            Jobs[#Jobs + 1] = {
                Text = v.name
            }
        end
    end)

    return Jobs
end

function GetPlayersInArea(Coords, Radius)
	local Prom = promise:new()
	ESX.TriggerServerCallback('farrel-adminmenu/server/get-active-players-in-radius', function(Players)
		Prom:resolve(Players)
	end, Coords, Radius)
	return Citizen.Await(Prom)
end

function GetBans()
    local Prom = promise:new()
    ESX.TriggerServerCallback("farrel-adminmenu/server/get-bans", function(Bans)
        Prom:resolve(Bans)
    end)
    return Citizen.Await(Prom)
end

function GetPlayers()
    local Prom = promise:new()
    ESX.TriggerServerCallback("farrel-adminmenu/server/get-players", function(Players)
        Prom:resolve(Players)
    end)
    return Citizen.Await(Prom)
end


-- -- Generate

function GenerateFavorites()
    local Retval = {}
    for _, Menu in pairs(Config.AdminMenus) do
        for k, v in pairs(Menu.Items) do
            Retval[v.Id] = false
        end
    end
    return Retval
end

-- Troll

-- Drunk

local function getRandomDrunkCarTask()
    math.randomseed(GetGameTimer())

    return DRUNK_DRIVING_EFFECTS[math.random(#DRUNK_DRIVING_EFFECTS)]
end

-- NOTE: We might want to check if a player already has an effect
function drunkThread()
    local playerPed = PlayerPedId()
    local isDrunk = true

    RequestAnimSet(DRUNK_ANIM_SET)
    while not HasAnimSetLoaded(DRUNK_ANIM_SET) do
        Wait(5)
    end

    SetPedMovementClipset(playerPed, DRUNK_ANIM_SET)
    ShakeGameplayCam("DRUNK_SHAKE", 3.0)
    SetPedIsDrunk(playerPed, true)
    SetTransitionTimecycleModifier("spectator5", 10.00)

    CreateThread(function()
        while isDrunk do
            local vehPedIsIn = GetVehiclePedIsIn(playerPed)
            local isPedInVehicleAndDriving = (vehPedIsIn ~= 0) and (GetPedInVehicleSeat(vehPedIsIn, -1) == playerPed)

            if isPedInVehicleAndDriving then
                local randomTask = getRandomDrunkCarTask()
                TaskVehicleTempAction(playerPed, vehPedIsIn, randomTask, 500)
            end

            Wait(5000)
        end
    end)

    Wait(30 * 1000)
    isDrunk = false
    SetTransitionTimecycleModifier("default", 10.00)
    StopGameplayCamShaking(true)
    ResetPedMovementClipset(playerPed)
    RemoveAnimSet(DRUNK_ANIM_SET)
end

-- Wild attack

local attackAnimalHashes = {
    GetHashKey("a_c_chimp"),
    GetHashKey("a_c_rottweiler"),
    GetHashKey("a_c_coyote")
}
local animalGroupHash = GetHashKey("Animal")
local playerGroupHash = GetHashKey("PLAYER")

function startWildAttack()
    -- Consts
    local playerPed = PlayerPedId()
    local animalHash = attackAnimalHashes[math.random(#attackAnimalHashes)]
    local coordsBehindPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 100, -15.0, 0)
    local playerHeading = GetEntityHeading(playerPed)
    local belowGround, groundZ, vec3OnFloor = GetGroundZAndNormalFor_3dCoord(coordsBehindPlayer.x, coordsBehindPlayer.y, coordsBehindPlayer.z)

    -- Requesting model
    RequestModel(animalHash)
    while not HasModelLoaded(animalHash) do
        Wait(5)
    end
    SetModelAsNoLongerNeeded(animalHash)

    -- Creating Animal & setting player as enemy
    local animalPed = CreatePed(1, animalHash, coordsBehindPlayer.x, coordsBehindPlayer.y, groundZ, playerHeading, true, false)
    SetPedFleeAttributes(animalPed, 0, 0)
    SetPedRelationshipGroupHash(animalPed, animalGroupHash)
    TaskSetBlockingOfNonTemporaryEvents(animalPed, true)
    TaskCombatHatedTargetsAroundPed(animalPed, 30.0, 0)
    ClearPedTasks(animalPed)
    TaskPutPedDirectlyIntoMelee(animalPed, playerPed, 0.0, -1.0, 0.0, 0)
    SetRelationshipBetweenGroups(5, animalGroupHash, playerGroupHash)
    SetRelationshipBetweenGroups(5, playerGroupHash, animalGroupHash)
end

function cloneModel(pedId)
    local ped = GetPlayerPed(GetPlayerFromServerId(pedId))
    local me = PlayerPedId()

    hat = GetPedPropIndex(ped, 0)
    hat_texture = GetPedPropTextureIndex(ped, 0)

    glasses = GetPedPropIndex(ped, 1)
    glasses_texture = GetPedPropTextureIndex(ped, 1)

    ear = GetPedPropIndex(ped, 2)
    ear_texture = GetPedPropTextureIndex(ped, 2)

    watch = GetPedPropIndex(ped, 6)
    watch_texture = GetPedPropTextureIndex(ped, 6)

    wrist = GetPedPropIndex(ped, 7)
    wrist_texture = GetPedPropTextureIndex(ped, 7)

    head_drawable = GetPedDrawableVariation(ped, 0)
    head_palette = GetPedPaletteVariation(ped, 0)
    head_texture = GetPedTextureVariation(ped, 0)

    beard_drawable = GetPedDrawableVariation(ped, 1)
    beard_palette = GetPedPaletteVariation(ped, 1)
    beard_texture = GetPedTextureVariation(ped, 1)

    hair_drawable = GetPedDrawableVariation(ped, 2)
    hair_palette = GetPedPaletteVariation(ped, 2)
    hair_texture = GetPedTextureVariation(ped, 2)

    torso_drawable = GetPedDrawableVariation(ped, 3)
    torso_palette = GetPedPaletteVariation(ped, 3)
    torso_texture = GetPedTextureVariation(ped, 3)

    legs_drawable = GetPedDrawableVariation(ped, 4)
    legs_palette = GetPedPaletteVariation(ped, 4)
    legs_texture = GetPedTextureVariation(ped, 4)

    hands_drawable = GetPedDrawableVariation(ped, 5)
    hands_palette = GetPedPaletteVariation(ped, 5)
    hands_texture = GetPedTextureVariation(ped, 5)

    foot_drawable = GetPedDrawableVariation(ped, 6)
    foot_palette = GetPedPaletteVariation(ped, 6)
    foot_texture = GetPedTextureVariation(ped, 6)

    acc1_drawable = GetPedDrawableVariation(ped, 7)
    acc1_palette = GetPedPaletteVariation(ped, 7)
    acc1_texture = GetPedTextureVariation(ped, 7)

    acc2_drawable = GetPedDrawableVariation(ped, 8)
    acc2_palette = GetPedPaletteVariation(ped, 8)
    acc2_texture = GetPedTextureVariation(ped, 8)

    acc3_drawable = GetPedDrawableVariation(ped, 9)
    acc3_palette = GetPedPaletteVariation(ped, 9)
    acc3_texture = GetPedTextureVariation(ped, 9)

    mask_drawable = GetPedDrawableVariation(ped, 10)
    mask_palette = GetPedPaletteVariation(ped, 10)
    mask_texture = GetPedTextureVariation(ped, 10)

    aux_drawable = GetPedDrawableVariation(ped, 11)
    aux_palette = GetPedPaletteVariation(ped, 11)   
    aux_texture = GetPedTextureVariation(ped, 11)

    SetPedPropIndex(me, 0, hat, hat_texture, 1)
    SetPedPropIndex(me, 1, glasses, glasses_texture, 1)
    SetPedPropIndex(me, 2, ear, ear_texture, 1)
    SetPedPropIndex(me, 6, watch, watch_texture, 1)
    SetPedPropIndex(me, 7, wrist, wrist_texture, 1)

    SetPedComponentVariation(me, 0, head_drawable, head_texture, head_palette)
    SetPedComponentVariation(me, 1, beard_drawable, beard_texture, beard_palette)
    SetPedComponentVariation(me, 2, hair_drawable, hair_texture, hair_palette)
    SetPedComponentVariation(me, 3, torso_drawable, torso_texture, torso_palette)
    SetPedComponentVariation(me, 4, legs_drawable, legs_texture, legs_palette)
    SetPedComponentVariation(me, 5, hands_drawable, hands_texture, hands_palette)
    SetPedComponentVariation(me, 6, foot_drawable, foot_texture, foot_palette)
    SetPedComponentVariation(me, 7, acc1_drawable, acc1_texture, acc1_palette)
    SetPedComponentVariation(me, 8, acc2_drawable, acc2_texture, acc2_palette)
    SetPedComponentVariation(me, 9, acc3_drawable, acc3_texture, acc3_palette)
    SetPedComponentVariation(me, 10, mask_drawable, mask_texture, mask_palette)
    SetPedComponentVariation(me, 11, aux_drawable, aux_texture, aux_palette)
end