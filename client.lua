local ped = nil
local coords = nil
local isOnCooldown = false
local canSendPos = true
local msHolding = 0
local allowedJob = false
local lastListOfPanics = {}
local isDead = false
local posWait = false
local stopAlarms = false

-- RegisterCommand(
--     "p",
--     function(source, args)
--         RequestAnimDict(args[1])
--         while (not HasAnimDictLoaded(args[1])) do
--             Citizen.Wait(10)
--         end
--         TaskPlayAnim(PlayerPedId(), args[1], args[2], 8.0, -8, 3000, 49, 0, 0, 0, 0)

--         -- local playerPed = GetPlayerPed(-1)
--         -- local boneIndex2 = GetPedBoneIndex(playerPed, 0x68FB)

--         -- local coords     = GetEntityCoords(playerPed)
--         -- ESX.Game.SpawnObject('prop_tool_pickaxe', {
--         -- 	x = coords.x,
--         -- 	y = coords.y,
--         -- 	z = coords.z
--         -- }, function(box)
--         -- 	prop = box
--         -- AttachEntityToEntity(box, playerPed, boneIndex2, 0.05, 0.02, 0.0, 0.0, 0.0, 180.0, true, true, false, false, 1, true)

--         -- end)
--     end
-- )

-- RegisterCommand(
--     "del",
--     function()
--         DeleteObject(prop)
--     end
-- )

TriggerEvent(
    "platinlife:getSharedObject",
    function(obj)
        ESX = obj
    end
)

Citizen.CreateThread(
    function()
        while ESX.GetPlayerData().job == nil do
            Wait(20)
        end

        if table.contains(Config.AllowedJobs, ESX.GetPlayerData().job.name) then
            allowedJob = true
        end

        RequestAnimDict(Config.Animation.dictName)
        while (not HasAnimDictLoaded(Config.Animation.dictName)) do
            Citizen.Wait(10)
        end

        while true do
            ped = GetPlayerPed(-1)
            coords = GetEntityCoords(ped)
            local x, y = table.unpack(coords)

            if allowedJob then
                if ((not isOnCooldown) and IsControlPressed(0, Config.Modifier) and IsControlPressed(0, Config.Button)) then
                    if (msHolding >= Config.PressTime * 100) then
                        DisableControlAction(0, Config.Button, true)

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
                                ),
                                GetEntityHealth(ped)
                            )

                            SendNUIMessage(
                                {
                                    value = "triggerOwn"
                                }
                            )

                            startCooldown()
                            DisableControlAction(0, 301, false)
                        end
                    else
                        if msHolding == 0 and Config.Animation.play then
                            TaskPlayAnim(
                                PlayerPedId(),
                                Config.Animation.dictName,
                                Config.Animation.animName,
                                Config.Animation.fadeIn,
                                Config.Animation.fadeOut,
                                Config.Animation.playtime,
                                49,
                                0,
                                0,
                                0,
                                0
                            )
                        end

                        msHolding = msHolding + 2
                    end
                else
                    msHolding = 0
                end

                if table.empty(lastListOfPanics) then
                    lastListOfPanics = {}
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
        if table.contains(Config.AllowedJobs, job2.name) then
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

        while lastListOfPanics[GetPlayerServerId(GetPlayerIndex())] ~= nil and
            not lastListOfPanics[GetPlayerServerId(GetPlayerIndex())].canArrive do
            TriggerServerEvent("panicbutton:updatePos", coords)
            if (not hasItem("phone") and lastListOfPanics[GetPlayerServerId(GetPlayerIndex())].hasPhone) then
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
        isDead = deathStatus
    end
)

function playAlarm(streetName, streetName2)
    Citizen.CreateThread(
        function()
            if isOnCooldown then
                Wait(15000)
            end

            if not isOnCooldown then
                SendNUIMessage(
                    {
                        value = "play",
                        sound = "./audio/code_99.wav"
                    }
                )
                Wait(2200)
                SendNUIMessage(
                    {
                        value = "play",
                        sound = "./audio/at.wav"
                    }
                )
                Wait(1000)
                SendNUIMessage(
                    {
                        value = "street",
                        streetname = "STREET_" .. (streetName:upper()):gsub("%s+", "_")
                    }
                )
                print("STREET_" .. (streetName:upper()):gsub("%s+", "_"))
                Wait(2100)
                if streetName2 ~= 0 and streetName2 ~= "" then
                    SendNUIMessage(
                        {
                            value = "play",
                            sound = "./audio/close-to.wav"
                        }
                    )
                    Wait(1200)
                    SendNUIMessage(
                        {
                            value = "street",
                            streetname = "STREET_" .. (streetName2:upper()):gsub("%s+", "_")
                        }
                    )
                    -- end

                    Wait(5000)
                end
            end

            while not table.empty(lastListOfPanics) and not stopAlarms and
                not (table.length(lastListOfPanics) == 1 and table.first(lastListOfPanics).unitsArrived) do
                SendNUIMessage(
                    {
                        value = "triggerAlarm"
                    }
                )
                Wait(20000)
            end
            stopAlarms = false
        end
    )
end

RegisterNetEvent("panicbutton:updatepanics")
AddEventHandler(
    "panicbutton:updatepanics",
    function(panics, randomX, randomY, firsttime, health)
        if firsttime ~= -1 then
            local pos = panics[firsttime].lastPos
            local firstname = panics[firsttime].firstname
            local lastname = panics[firsttime].lastname
            local x, y, z = table.unpack(pos)

            local streetName, streetName2 = GetStreetNameAtCoord(x, y, z)

            if streetName2 ~= nil and streetName2 ~= 0 and streetName2 ~= "" then
                streetName2 = GetStreetNameFromHashKey(streetName2)
            end
            local streetName = GetStreetNameFromHashKey(streetName)

            if streetName2 == nil or streetName2 == 0 or streetName2 == "" then
                ShowAboveRadarMessage(
                    "~o~Panicbutton~w~ von " ..
                        firstname .. " " .. lastname .. " bei ~r~" .. streetName .. "~w~ ausgelöst!"
                )
            else
                ShowAboveRadarMessage(
                    "~o~Panicbutton~w~ von " ..
                        firstname ..
                            " " ..
                                lastname .. " bei ~r~" .. streetName .. " ~w~ X ~r~ " .. streetName2 .. "~w~ ausgelöst!"
                )
            end

            playAlarm(streetName, streetName2, health)
        end

        if not posWait then
            if not table.empty(lastListOfPanics) then
                for k, v in pairs(lastListOfPanics) do
                    if (not v.canArrive and (panics[k] == nil or not panics[k].canArrive)) or panics[k] == nil then
                        RemoveBlip(v.blip)
                    end
                end
            end

            for _, v in pairs(panics) do
                if v.hasPanicbutton then
                    local x, y, z = table.unpack(v.lastPos)
                    v.blip = createNewBlip(x, y, z, v.firstname, v.lastname)
                elseif v.hasPhone then
                    local x, y, z = table.unpack(v.lastPos)
                    v.blip = createNewBlipInaccurate(x, y, z, v.firstname, v.lastname, randomX, randomY)
                end
            end
        end

        if posWait then
            for k, v in pairs(lastListOfPanics) do
                if (v ~= nil) then
                    panics[k].blip = v.blip
                end
            end
        end

        lastListOfPanics = panics
    end
)

RegisterNetEvent("panicbutton:stopalarm")
AddEventHandler(
    "panicbutton:stopalarm",
    function(firstname, lastname)
        stopAlarms = true
        ShowAboveRadarMessage(
            "Alle Alarmsounds wurde vom Beamten " .. firstname .. " " .. lastname .. " ~r~deaktiviert."
        )
    end
)

RegisterNetEvent("panicbutton:canelingpanics")
AddEventHandler(
    "panicbutton:canelingpanics",
    function(firstname, lastname)
        ShowAboveRadarMessage(
            "Alle Panicbuttons wurde vom Beamten " .. firstname .. " " .. lastname .. " ~r~deaktiviert."
        )
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
            print(allowedJob and not isDead and not isOnCooldown)
            if allowedJob and not isDead and not isOnCooldown then
                haveIArrived(id)
            end
        end
    end
)

RegisterNetEvent("panicbutton:unitsarrived_cl")
AddEventHandler(
    "panicbutton:unitsarrived_cl",
    function(id)
        ShowAboveRadarMessage(
            "Einheiten eingetroffen beim Panicbutton von " ..
                lastListOfPanics[id].firstname .. " " .. lastListOfPanics[id].lastname
        )
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

    SetWaypointOff()
    SetBlipRoute(blip, true)

    return blip
end

function createNewBlipInaccurate(x, y, z, firstname, lastname, randomX, randomY)
    local blip = AddBlipForCoord(x + randomX, y + randomY, z)
    SetBlipSprite(blip, 161)

    SetBlipScale(blip, 3.0)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Panic " .. firstname .. " " .. lastname)
    EndTextCommandSetBlipName(blip)

    SetWaypointOff()
    SetBlipRoute(blip, true)

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

function table.first(self)
    for _, v in pairs(self) do
        return v
    end
end

function table.length(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
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
            local _id2 = id2

            while not lastListOfPanics[_id2].unitsArrived and not isDead and not isOnCooldown do
                print(not lastListOfPanics[_id2].unitsArrived and not isDead and not isOnCooldown)
                local distance = #(lastListOfPanics[_id2].lastPos - coords)
                print(distance)
                if distance <= Config.ArriveDistance then
                    TriggerServerEvent("panicbutton:unitsArrived", _id2)
                end
                Wait(100)
            end
        end
    )
end

function startCooldown()
    isOnCooldown = true
    Citizen.CreateThread(
        function()
            Wait(4000)
            while lastListOfPanics[GetPlayerServerId(GetPlayerIndex())] ~= nil do
                Wait(2000)
            end
            isOnCooldown = false
        end
    )
end

RegisterCommand(
    "stopallpanics",
    function()
        if allowedJob then
            TriggerServerEvent("panicbutton:stopallpanics", GetPlayerServerId(GetPlayerIndex()))
        end
    end
)

RegisterCommand(
    "stopalarms",
    function()
        if allowedJob then
            TriggerServerEvent("panicbutton:stopalarms", GetPlayerServerId(GetPlayerIndex()))
        end
    end
)

RegisterCommand(
    "stoppanic",
    function()
        if isOnCooldown then
            TriggerServerEvent("panicbutton:stoppanic", GetPlayerServerId(GetPlayerIndex()))
        end
    end
)
