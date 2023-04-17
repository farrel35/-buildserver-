
function IsPlayerAdmin(ServerId)
    local xPlayer = ESX.GetPlayerFromId(ServerId)
    if xPlayer.group == 'admin' then
        return true
    end
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
