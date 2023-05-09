
function UpdateMenu()
    local Bans = GetBans()
    local Players = GetPlayers()
    local Menu = GetListMenu()
    
    SendNUIMessage({
        Action = 'Update',
        Debug = Config.Settings['Debug'],
        Bans = Bans,
        AllPlayers = Players,
        AdminItems = Menu,
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

function DoesItemExistInTable(FilteredListMenu, Category, CommandItem)
    for i=1, #FilteredListMenu do
        local Item = FilteredListMenu[i]
        if Item['Id'] == CommandItem['Id'] then
            return true
        end
    end
    return false
end

function GetListMenu()
    print('get rank')
    ESX.TriggerServerCallback('farrel-adminmenu/server/get-playerrank', function(rank)
        playerRank = rank
    end) 

	Wait(500)
    local Prom = promise:new()
    local FilteredListMenu = {}

    if next(Config.AdminMenus) ~= nil then
        for i = 1, #Config.AdminMenus do 
            local Category = Config.AdminMenus[i]
            FilteredListMenu[Category['Id']] = {
                ['Id'] = Category['Id'],
                ['Name'] = Category['Name'],
                ['Items'] = {},
            }
            for u = 1, #Category['Items'] do 
                local CommandItem = Category['Items'][u]
                local Command = Category['Id']
                if CommandItem['Groups'] ~= nil then
                    for j = 1, #CommandItem['Groups'] do
                        local Group = playerRank
                        local CommandGroup = CommandItem['Groups'][j]:lower()
                        if Group and (Bool ~= nil and CommandGroup == Group and Bool) or (Bool == nil and CommandGroup == Group) or CommandGroup == 'all' then 
                            if not DoesItemExistInTable(FilteredListMenu[Command]['Items'], Category, CommandItem) then
                                FilteredListMenu[Command]['Items'][#FilteredListMenu[Command]['Items'] + 1] = CommandItem
                                
                            end
                        end
                    end
                else
                    if not DoesItemExistInTable(FilteredListMenu[Command]['Items'], Category, CommandItem) then
                        FilteredListMenu[Command]['Items'][#FilteredListMenu[Command]['Items'] + 1] = CommandItem
                    end
                end
            end
        end
    else
        print('No commands found to filter, check the Config.AdminMenus for typos.')
    end
    
    Prom:resolve(FilteredListMenu)

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
