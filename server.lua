local activePanics = {}
local ESX = nil

TriggerEvent(
    "platinlife:getSharedObject",
    function(obj)
        ESX = obj
    end
)

RegisterNetEvent("panicbutton:panic")
AddEventHandler(
    "panicbutton:panic",
    function(panicInfo)
        local _source = source
        local xPlayer2 = ESX.GetPlayerFromId(_source)
        local string = xPlayer2.getIdentifier()
        MySQL.Async.fetchAll(
            "SELECT * FROM users WHERE identifier = @identifier",
            {["@identifier"] = string},
            function(result)
                panicInfo.firstname = result[1].firstname
                panicInfo.lastname = result[1].lastname
                activePanics[_source] = panicInfo

                local players = ESX.GetPlayers()
                for i, v in pairs(players) do
                    local xPlayer = ESX.GetPlayerFromId(v)
                    if table.contains(Config.AllowedJobs, xPlayer.getJob().name) then
                        xPlayer.triggerEvent(
                            "panicbutton:updatepanics",
                            activePanics,
                            math.random(0, 15),
                            math.random(0, 15)
                        )
                    end
                end
            end
        )
    end
)

RegisterNetEvent("panicbutton:nopanic")
AddEventHandler(
    "panicbutton:nopanic",
    function()
        activePanics[source].hasPanicbutton = false
        if not activePanics[source].hasPhone then
            activePanics[source].canArrive = true
        end
        local players = ESX.GetPlayers()
        for i, v in pairs(players) do
            local xPlayer = ESX.GetPlayerFromId(v)
            if table.contains(Config.AllowedJobs, xPlayer.getJob().name) then
                xPlayer.triggerEvent("panicbutton:updatepanics", activePanics, math.random(0, 15), math.random(0, 15))
                xPlayer.triggerEvent("panicbutton:lostbutton", source, math.random(10000, 20000))
            end
        end
    end
)

RegisterNetEvent("panicbutton:nophone")
AddEventHandler(
    "panicbutton:nophone",
    function()
        activePanics[source].noPhone = false
        if not activePanics[source].hasPanicbutton then
            activePanics[source].canArrive = true
        end

        print(activePanics[source].firstname)
        local players = ESX.GetPlayers()
        for i, v in pairs(players) do
            local xPlayer = ESX.GetPlayerFromId(v)
            if table.contains(Config.AllowedJobs, xPlayer.getJob().name) then
                xPlayer.triggerEvent("panicbutton:updatepanics", activePanics, math.random(0, 15), math.random(0, 15))
                xPlayer.triggerEvent(
                    "panicbutton:lostphone",
                    activePanics[source].firstname,
                    activePanics[source].lastname,
                    source
                )
            end
        end
    end
)
RegisterNetEvent("panicbutton:updatePos")
AddEventHandler(
    "panicbutton:updatePos",
    function(coords)
        activePanics[source].lastPos = coords
        local players = ESX.GetPlayers()
        for i, v in pairs(players) do
            local xPlayer = ESX.GetPlayerFromId(v)
            if table.contains(Config.AllowedJobs, xPlayer.getJob().name) then
                xPlayer.triggerEvent("panicbutton:updatepanics", activePanics, math.random(0, 15), math.random(0, 15))
            end
        end
    end
)

RegisterNetEvent("panicbutton:unitsarrived")
AddEventHandler(
    "panicbutton:unitsarrived",
    function(id)
        activePanics[id].unitsArrived = true
        activePanics[id].canArrive = false
        local players = ESX.GetPlayers()
        for i, v in pairs(players) do
            local xPlayer = ESX.GetPlayerFromId(v)
            if table.contains(Config.AllowedJobs, xPlayer.getJob().name) then
                xPlayer.triggerEvent("panicbutton:lostphone", unitsArrived, id)
            end
        end
    end
)

function PanicInfo(firstname, lastname, hasPanicbutton, hasPhone, lastPos, unitsArrived, id, canArrive)
    return {
        firstname = firstname,
        lastname = lastname,
        hasPanicbutton = hasPanicbutton,
        hasPhone = hasPhone,
        lastPos = lastPos,
        unitsArrived = unitsArrived,
        id = id,
        canArrive = canArrive,
        blip = nil
    }
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.empty(self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

function hasItem(itemName)
    local inventory = ESX.GetPlayerData().inventory
    local count = 0
    for i = 1, #inventory, 1 do
        if inventory[i].name == itemName then
            count = inventory[i].count
        end
    end
    if count > 0 then
        return true
    else
        return false
    end
end
