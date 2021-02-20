cSpawnManager = class()

function cSpawnManager:__init()

    Events:Subscribe("Loadingscreen/Finished", self, self.LoadingScreenFinished)

end

function cSpawnManager:LoadingScreenFinished()

    Camera:Reset()

    LocalPlayer:Spawn({
        pos = vector3(-441, 890, 237),
        model = "a_m_m_beach_02",
        callback = function()
            LocalPlayer:GetPed():GiveWeapon(GetHashKey("weapon_stone_hatchet"), 1, true)
        end
    })
    
end

cSpawnManager = cSpawnManager()