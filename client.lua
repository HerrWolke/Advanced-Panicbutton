local ped = nil
local coords = nil
local isOnCooldown = false
local canSendPos = true
local msHolding = 0
local allowedJob = false
local lastListOfPanics = {}
local isDead = false
local posWait = false

TriggerEvent(
    "platinlife:getSharedObject",
    function(obj)
        ESX = obj
    end
)

Citizen.CreateThread(
    function()
        while ESX.GetPlayerData().job.name == nil do
            Wait(20)
        end

        if table.contains(Config.AllowedJobs, ESX.GetPlayerData().job.name) then
            allowedJob = true
        end

        while true do
            ped = GetPlayerPed(-1)
            coords = GetEntityCoords(ped)

            if allowedJob then
                if ((not isOnCooldown) and IsControlPressed(0, 19) and IsControlPressed(0, 301)) then
                    if (msHolding >= 200) then
                        msHolding = 0
                        if hasItem("panicbutton") then
                            TriggerServerEvent(
                                "panicbutton:panic",
                                PanicInfo(
                                    "",
                                    "",
                                    true,
                                    hasItem("phone"),
                                    coords,
                                    false,
                                    GetPlayerServerId(GetPlayerIndex()),
                                    false
                                )
                            )

                            SendNUIMessage(
                                {
                                    value = "triggerOwn"
                                }
                            )
                            playAlarm()
                        end
                    else
                        msHolding = msHolding + 2
                    end
                else
                    msHolding = 0
                end
                Wait(2)
            else
                Wait(1000)
            end
        end
    end
)

RegisterNetEvent("platinlife:setJob")
AddEventHandler(
    "platinlife:setJob",
    function(job2)
        if table.contains(Config.AllowedJobs, ESX.GetPlayerData().job.name) then
            allowedJob = true
        else
            allowedJob = false
        end
    end
)

Citizen.CreateThread(
    function()
        while table.empty(lastListOfPanics) do
            Wait(39)
        end
        while not lastListOfPanics[GetPlayerServerId(GetPlayerIndex())].canArrive do
            TriggerServerEvent("panicbutton:updatePos", coords)
            if
                (not hasItem("phone") and lastListOfPanics[GetPlayerServerId(GetPlayerIndex())].hasPhone and
                    not lastListOfPanics[GetPlayerServerId(GetPlayerIndex())].hasPanicbutton)
             then
                TriggerServerEvent("panicbutton:nophone")
            elseif (not hasItem("panicbutton") and lastListOfPanics[GetPlayerServerId(GetPlayerIndex())].hasPanicbutton) then
                TriggerServerEvent("panicbutton:nopanic")
            end
            Wait(5000)
        end
    end
)

RegisterNetEvent("visn_are:SetDeathStatus")
AddEventHandler(
    "visn_are:SetDeathStatus",
    function(deathStatus)
        print(deathStatus)
        isDead = deathStatus
    end
)

function playAlarm()
    Citizen.CreateThread(
        function()
            while table.empty(lastListOfPanics) do
                SendNUIMessage(
                    {
                        value = "triggerAlarm"
                    }
                )
                Wait(20000)
            end
           
        end
    )
end

RegisterNetEvent("panicbutton:updatepanics")
AddEventHandler(
    "panicbutton:updatepanics",
    function(panics, randomX, randomY)
        if not posWait then
            if not table.empty(lastListOfPanics) then
                for k, v in pairs(lastListOfPanics) do
                    if not v.canArrive and not panics[k].canArrive then
                        print("rem")
                        RemoveBlip(v.blip)
                    end
                end
            end

            for _, v in pairs(panics) do
                if v.hasPanicbutton then
                    print("create")
                    local x, y, z = table.unpack(v.lastPos)
                    v.blip = createNewBlip(x, y, z, v.firstname, v.lastname)
                elseif v.hasPhone then
                    print("create2")
                    local x, y, z = table.unpack(v.lastPos)
                    v.blip = createNewBlipInaccurate(x, y, z, v.firstname, v.lastname, randomX, randomY)
                end
            end
        end

        if posWait then
            for k, v in pairs(lastListOfPanics) do
                panics[k].blip = v.blip
            end
        end

        lastListOfPanics = panics
    end
)

RegisterNetEvent("panicbutton:lostbutton")
AddEventHandler(
    "panicbutton:lostbutton",
    function(id, random)
        ShowAboveRadarMessage("Die Verbindung zum Funksender des Panicbuttons wurde ~r~verloren!")
        ShowAboveRadarMessage("Versuche Ortung per Telefon. Dies kann einige Sekunden dauern...")
        posWait = true
        Wait(random)
        posWait = false
        if (lastListOfPanics[id].hasPhone) then
            ShowAboveRadarMessage(
                "Ortung per Telefon ~g~erfolgreich. ~w~Eine etwas ungenauere Position wird nun übermittelt!"
            )
        else
            ShowAboveRadarMessage(
                "Ortung per Telefon ~r~unerfolgreich.  ~w~Positionsupdates können nicht mehr durchgeführt werden!"
            )
            if allowedJob and not isDead and not isOnCooldown then
                haveIArrived(id)
            end
        end
    end
)

RegisterNetEvent("panicbutton:lostphone")
AddEventHandler(
    "platinlife:lostphone",
    function(firstname, lastname, id)
        ShowAboveRadarMessage("Ortung per Telefon ~r~unterbrochen.")
        ShowAboveRadarMessage(
            "~w~Die letzte Position des Officers " .. lastname .. " " .. firstname .. " " .. " wurde markiert!"
        )
        if allowedJob and not isDead and not isOnCooldown then
            haveIArrived(id)
        end
    end
)

function createNewBlip(x, y, z, firstname, lastname)
    local blip = AddBlipForCoord(x, y, z)

    SetBlipSprite(blip, 161)

    SetBlipScale(blip, 1.5)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Panic " .. firstname .. " " .. lastname)
    EndTextCommandSetBlipName(blip)

    SetBlipRoute(blip, true)
    SetWaypointOff()
    return blip
end

function createNewBlipInaccurate(x, y, z, firstname, lastname, randomX, randomY)
    local blip = AddBlipForCoord(x + randomX, y + randomY, z)
    SetBlipSprite(blip, 161)

    SetBlipScale(blip, 2.0)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Panic " .. firstname .. " " .. lastname)
    EndTextCommandSetBlipName(blip)

    SetBlipRoute(blip, true)
    SetWaypointOff()
    return blip
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

function ShowAboveRadarMessage(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0, 1)
end

function haveIArrived(id2)
    Citizen.CreateThread(
        function()
            local unitsArrived = false
            local _id2 = id2
            while not unitsArrived do
                local distance = #(lastListOfPanics[_id2].lastPos - coords)
                if distance <= Config.ArriveDistance then
                    TriggerServerEvent("panicbutton:unitsArrived", _id2)
                end
                Wait(100)
            end
        end
    )
end
