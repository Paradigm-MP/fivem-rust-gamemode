sSpawnManager = class()

function sSpawnManager:__init()


    Network:Subscribe("Loadingscreen/Finished", self, self.LoadingscreenFinished)

end

function sSpawnManager:LoadingscreenFinished(args)
    if args.player:GetValue("Spawned") then return end
    args.player:Spawn({
        position = vector3(-441, 890, 237),
        model = "mp_m_freemode_01"
    })
end

sSpawnManager = sSpawnManager()