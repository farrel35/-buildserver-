local inRadialMenu = false

local jobIndex = nil
local vehicleIndex = nil

local DynamicMenuItems = {}
local FinalMenuItems = {}
-- Functions

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

local function deepcopy(orig) -- modified the deep copy function from http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if not orig.canOpen or orig.canOpen() then
            local toRemove = {}
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                if type(orig_value) == 'table' then
                    if not orig_value.canOpen or orig_value.canOpen() then
                        copy[deepcopy(orig_key)] = deepcopy(orig_value)
                    else
                        toRemove[orig_key] = true
                    end
                else
                    copy[deepcopy(orig_key)] = deepcopy(orig_value)
                end
            end
            for i=1, #toRemove do table.remove(copy, i) --[[ Using this to make sure all indexes get re-indexed and no empty spaces are in the radialmenu ]] end
            if copy and next(copy) then setmetatable(copy, deepcopy(getmetatable(orig))) end
        end
    elseif orig_type ~= 'function' then
        copy = orig
    end
    return copy
end

local function getNearestVeh()
    local pos = GetEntityCoords(PlayerPedId())
    local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
    local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
    return vehicleHandle
end

local function AddOption(data, id)
    local menuID = id ~= nil and id or (#DynamicMenuItems + 1)
    DynamicMenuItems[menuID] = deepcopy(data)
    return menuID
end

local function RemoveOption(id)
    DynamicMenuItems[id] = nil
end

local function SetupJobMenu()
    local JobMenu = {
        id = 'jobinteractions',
        title = 'Work',
        icon = 'briefcase',
        items = {}
    }
    if Config.JobInteractions[ESX.PlayerData.job.name] and next(Config.JobInteractions[ESX.PlayerData.job.name]) then
        JobMenu.items = Config.JobInteractions[ESX.PlayerData.job.name]
    end

    if #JobMenu.items == 0 then
        if jobIndex then
            RemoveOption(jobIndex)
            jobIndex = nil
        end
    else
        jobIndex = AddOption(JobMenu, jobIndex)
    end
end

local function SetupSubItems()
    SetupJobMenu()
end

local function selectOption(t, t2)
    for _, v in pairs(t) do
        if v.items then
            local found, hasAction, val = selectOption(v.items, t2)
            if found then return true, hasAction, val end
        else
            if v.id == t2.id and ((v.event and v.event == t2.event) or v.action) and (not v.canOpen or v.canOpen()) then
                return true, v.action, v
            end
        end
    end
    return false
end

local function IsPoliceOrEMS()
    return (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "ambulance")
end

local function IsDowned()
    return (ESX.PlayerData.metadata["isdead"] or ESX.PlayerData.metadata["inlaststand"])
end

local function SetupRadialMenu()
    FinalMenuItems = {}

    
    FinalMenuItems = deepcopy(Config.MenuItems)
    for _, v in pairs(DynamicMenuItems) do
        FinalMenuItems[#FinalMenuItems+1] = v
    end
    -- SetupSubItems()
    SetupJobMenu()
end

local function setRadialState(bool, sendMessage, delay)
    if bool then
        TriggerEvent('qb-radialmenu:client:onRadialmenuOpen')
        SetupRadialMenu()
    else
        TriggerEvent('qb-radialmenu:client:onRadialmenuClose')
    end

    SetNuiFocus(bool, bool)
    if sendMessage then
        SendNUIMessage({
            action = "ui",
            radial = bool,
            items = FinalMenuItems
        })
    end
    if delay then Wait(500) end
    inRadialMenu = bool
end

-- Command

RegisterCommand('radialmenu', function()
    if not IsPauseMenuActive() and not inRadialMenu then
        setRadialState(true, true)
        SetCursorLocation(0.5, 0.5)
    end
end)

RegisterKeyMapping('radialmenu', _U("general.command_description"), 'keyboard', 'F1')

-- NUI Callbacks

RegisterNUICallback('closeRadial', function(data, cb)
    setRadialState(false, false, data.delay)
    cb('ok')
end)

RegisterNUICallback('selectItem', function(inData, cb)
    local itemData = inData.itemData
    local found, action, data = selectOption(FinalMenuItems, itemData)
    if data and found then
        if action then
            action(data)
        elseif data.type == 'client' then
            TriggerEvent(data.event, data)
        elseif data.type == 'server' then
            TriggerServerEvent(data.event, data)
        elseif data.type == 'command' then
            ExecuteCommand(data.event)
        elseif data.type == 'qbcommand' then
            TriggerServerEvent('QBCore:CallCommand', data.event, data)
        end
    end
    cb('ok')
end)

exports('AddOption', AddOption)
exports('RemoveOption', RemoveOption)
