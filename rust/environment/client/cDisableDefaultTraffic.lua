DisableDefaultTraffic = class()

function DisableDefaultTraffic:__init()
    World:DisablePedSpawning()
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
end

DisableDefaultTraffic = DisableDefaultTraffic()