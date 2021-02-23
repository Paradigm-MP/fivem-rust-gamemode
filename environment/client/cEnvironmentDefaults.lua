EnvironmentDefaults = class()

function EnvironmentDefaults:__init()
    World:DisablePedSpawning()
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
    World:SetBlackout(true)
end

EnvironmentDefaults = EnvironmentDefaults()