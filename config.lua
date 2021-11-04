Config = {}

Config.Lang = "de"

_U = Langs[Config.Lang]

--Jobs that are allowed to use the panic button
Config.AllowedJobs = {
    "fire",
    "police",
    "ambulance",
    "mechanic"
}

--Jobs notified if a panic button is activated
Config.NotifiJobs = {
    "fire",
    "ambulance",
    "police"
}

--Wether or not the officer should be located with a more inacurrate location via his phone if the panic button is removed from him
Config.AllowPingingWithPhone = true

--Actual min = min + buffer
--Actual max = max + buffer
--Buffer keeps the random from becoming 0 meaning no randomness in position (unwanted)

--default -50, 30, 20
--you can set everything to zero, then the 100% accurate position of the player will be shown
Config.PhonePingingRandomX = {
    min = -50,
    max = 30,
    buffer = 20
}

--default -25,10,10
Config.PhonePingingRandomY = {
    min = -25,
    max = 10,
    buffer = 10
}

--Size for the blip when phone tracking is on (size is bigger so player could be anywhere in that area)
Config.BlipInaccurateSize = 4.0

--Distance to the panic button that is needed to trigger that units have arrived
Config.ArriveDistance = 20

--Weather or not to play the alarm beeping sound (the sound can also manualy be cannceled ingame by the allowed jobs)
Config.PlayAlarm = true

--Would replay the beeping sound every 20 seconds, but thats pretty annoying and not realistic
Config.EnableAlarmRepeat = false

--Min 6 seconds (lower will still work but then you will have overlapping of the sound)
Config.RepeatAlarmDelay = 20

--dont touch anything other than dictName and animName if you dont know what you are doing
Config.Animation = {
    play = true,
    --ms
    playtime = 1500,
    --has to be double
    fadeIn = 32.0,
    fadeOut = 32.0,
    dictName = "reaction@intimidation@cop@unarmed",
    animName = "intro"
}

--Time in seconds
--Time needed to hold panic button until it activates
Config.PressTime = 2

--see https://docs.fivem.net/docs/game-references/controls/#controls for reference
--Both are needed in order for the panicbutton to function!

--M
Config.Button = 301
--Alt
Config.Modifier = 19
