function getPlayerRank(ServerId)
    local xPlayer = ESX.GetPlayerFromId(ServerId)
    
    return xPlayer.group
end

function IsPlayerAdmin(ServerId)
    local GroupRank = getPlayerRank(ServerId)

    if GroupRank == "admin" or GroupRank == "moderator" then
        return true
    end
end

function GetBanTimeCategory(Name)
    local Retval = nil
    for CatId, Cat in pairs(Config.BanTimeCategories) do
        if Cat['Name'] == Name then
            Retval = Cat
        end
    end
    return Retval
end

function CalculateLeftOverTimes(Type, Amount)
    local AmountAbove = 0
    if Type == 'Hours' then
        for i=1, Amount do
            if i > 24 then
                AmountAbove = AmountAbove + 1
            end
        end
    elseif Type == 'Minutes' then
        for i=1, Amount do
            if i > 60 then
                AmountAbove = AmountAbove + 1
            end
        end
    end
    return AmountAbove
end

function GetDateDifference(Type, Bans)
    if Type == nil then return end

    local FilteredBans = {}
    local CategoryBans = {}
    local Category = GetBanTimeCategory(Type)

    -- Cats
    CategoryBans['all'] = 0
    for CatId, Cat in pairs(Config.BanTimeCategories) do
        CategoryBans[Cat['Name']] = 0
    end

    -- Filter Bans
    if Bans ~= nil then
        for _, Ban in pairs(Bans) do
            -- Calculate Time
            Reference = os.time{day=Ban.BannedOn.day, year=Ban.BannedOn.year, month=Ban.BannedOn.month, hour= Ban.BannedOn.hour, min= Ban.BannedOn.min, sec=Ban.BannedOn.sec}
            DaysFrom = os.difftime(os.time(), Reference) / 86400 
            HoursFrom = os.difftime(os.time(), Reference) / 3600 
            MinsFrom = os.difftime(os.time(), Reference) % 3600 / 60
            Days = math.floor(DaysFrom)
            Hours = math.floor(HoursFrom)
            Minutes =  math.ceil(MinsFrom)

            -- Format Time
            if Hours >= 24 then 
                local LeftOverHours = CalculateLeftOverTimes('Hours', Hours)
                Days = Days + 1
                Hours = LeftOverHours
            end
            if Minutes > 59 then 
                local LeftOverMins = CalculateLeftOverTimes('Minutes', Minutes)
                Hours = Hours + 1
                Minutes = LeftOverMins
            end

            if Type ~= 'all' then
                if Category ~= nil and #Category['Times'] < 3 then
                    local FirstTime = Category['Times'][1]
                    local SecondTime = Category['Times'][2]
                    if FirstTime ~= nil and SecondTime ~= nil then 
                        -- Check Times
                        if FirstTime['Type'] == 'Days' then
                            if (SecondTime['Type'] == 'Days' and (SecondTime['Value'] > FirstTime['Value']) and (SecondTime['Value'] ~= FirstTime['Value'])) then
                                if ((Days > 0 and Days >= FirstTime['Value']) and (Days <= SecondTime['Value'])) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                end
                            end
                        elseif FirstTime['Type'] == 'Hours' then
                            if SecondTime['Type'] == 'Days' then
                                if (Days == 0 and Hours > 0 and Hours >= FirstTime['Value'] and Hours <= 23) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                elseif (Days > 0 and Days == SecondTime['Value']) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                end
                            elseif (SecondTime['Type'] == 'Hours' and (SecondTime['Value'] > FirstTime['Value']) and (SecondTime['Value'] ~= FirstTime['Value'])) then
                                if (Days == 0 and Hours > 0 and Hours >= FirstTime['Value'] and Hours <= SecondTime['Value']) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                end
                            end
                        elseif FirstTime['Type'] == 'Minutes' then
                            if SecondTime['Type'] == 'Days' then
                                if (Minutes > 0 and Minutes >= FirstTime['Value'] and Days > 0 and Days <= SecondTime['Value']) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                end
                            elseif SecondTime['Type'] == 'Hours' then
                                if (Hours == 0 and Minutes > 0 and Minutes >= FirstTime['Value'] and Minutes <= 59) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                elseif (Hours > 0 and Hours == SecondTime['Value']) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                end
                            elseif (SecondTime['Type'] == 'Minutes' and (SecondTime['Value'] > FirstTime['Value']) and (SecondTime['Value'] ~= FirstTime['Value'])) then
                                if (Minutes > 0 and Minutes >= FirstTime['Value'] and Minutes <= SecondTime['Value']) then
                                    FilteredBans[#FilteredBans + 1] = Ban
                                    CategoryBans[Type] = CategoryBans[Type] + 1
                                end
                            end
                        end
                    -- 1 Time
                    elseif FirstTime ~= nil and SecondTime == nil then
                        if FirstTime['Type'] == 'Days' then
                            if (Days > 0 and Days == FirstTime['Value']) then
                                FilteredBans[#FilteredBans + 1] = Ban
                                CategoryBans[Type] = CategoryBans[Type] + 1
                            end
                        elseif FirstTime['Type'] == 'Hours' then
                            if (Hours > 0 and Hours <= FirstTime['Value'] and Days == 0) then
                                FilteredBans[#FilteredBans + 1] = Ban
                                CategoryBans[Type] = CategoryBans[Type] + 1
                            end
                        elseif FirstTime['Type'] == 'Minutes' then
                            if (Minutes > 0 and Minutes <= FirstTime['Value'] and Days == 0) then
                                FilteredBans[#FilteredBans + 1] = Ban
                                CategoryBans[Type] = CategoryBans[Type] + 1
                            end
                        end
                    end
                end
            else
                FilteredBans[#FilteredBans + 1] = Ban
                CategoryBans['all'] = CategoryBans['all'] + 1
            end
        end
    end
    return FilteredBans, CategoryBans
end

function GetBanTime(Expires)
    local Time = os.time()
    local Expiring = nil
    local ExpD = nil
    if Expires == '1 Hour' then
        Expiring = os.date("*t", Time + 3600)
        ExpD = tonumber(Time + 3600)
    elseif Expires == '6 Hours' then
        Expiring = os.date("*t", Time + 21600)
        ExpD = tonumber(Time + 21600)
    elseif Expires == '12 Hours' then
        Expiring = os.date("*t", Time + 43200)
        ExpD = tonumber(Time + 43200)
    elseif Expires == '1 Day' then
        Expiring = os.date("*t", Time + 86400)
        ExpD = tonumber(Time + 86400)
    elseif Expires == '3 Days' then
        Expiring = os.date("*t", Time + 259200)
        ExpD = tonumber(Time + 259200)
    elseif Expires == '1 Week' then
        Expiring = os.date("*t", Time + 604800)
        ExpD = tonumber(Time + 604800)
    elseif Expires == 'Permanent' then
        Expiring = os.date("*t", Time + 315360000) -- 10 Years
        ExpD = tonumber(Time + 315360000)
    end
    return Expiring, ExpD
end

function GetIdentifier(Source, Type)
    local Identifier = nil
    local Prom = promise:new()
    for k,v in pairs(GetPlayerIdentifiers(Source))do
        if string.sub(v, 1, string.len("steam:")) == "steam:" and Type == 'steam' then
            Identifier = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" and Type == 'license' then
            Identifier = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" and Type == 'xbl' then
            Identifier = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" and Type == 'ip' then
            Identifier = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" and Type == 'discord' then
            Identifier = v
        elseif string.sub(v, 1, string.len("live:")) == "live:" and Type == 'live' then
            Identifier = v
        end
    end
    Prom:resolve(Identifier)
    return Citizen.Await(Prom)
end

function CreateLog(Source, Type, Log, Data)
    local source = Source

    if Type == nil or Log == nil then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    local Name = GetPlayerName(source)
    local Steam = GetIdentifier(source, "steam")
    
    if xPlayer ~= nil then
        MySQL.insert('INSERT INTO logs (type, name, steam, log, data) VALUES (?, ?, ?, ?, ?)', {
            Type,
            Name,
            Steam,
            Log,
            Data,
        })
    end
end