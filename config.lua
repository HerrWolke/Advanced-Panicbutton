Config = {}

Config.AllowedJobs = {
    "fire", "police", "ambulance", "mechanic"
}

Config.ArriveDistance = 20

--dont touch anything other than dictName and animName if you dont know what you are doing
Config.Animation = {
    play = true,
    --ms
    playtime = 1500,
    --has to be double
    fadeIn = 32.0,
    fadeOut = 32.0,
    dictName = "reaction@intimidation@cop@unarmed",
    animName = "intro",

}

--Time in seconds
Config.PressTime = 2

--see https://docs.fivem.net/docs/game-references/controls/#controls for reference
--Both are needed in order for the panicbutton to function!

--M
Config.Button = 301
--Alt
Config.Modifier = 19