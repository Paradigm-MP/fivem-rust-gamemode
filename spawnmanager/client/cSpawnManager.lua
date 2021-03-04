cSpawnManager = class()

function cSpawnManager:__init()

    Events:Subscribe("Loadingscreen/Finished", self, self.LoadingScreenFinished)

end

function cSpawnManager:LoadingScreenFinished()

    Camera:Reset()

    LocalPlayer:Spawn({
        pos = vector3(-441, 890, 237),
        model = "mp_m_freemode_01",
        callback = function()
            LocalPlayer:GetPed():GiveWeapon(GetHashKey("weapon_stone_hatchet"), 1, true)
            -- math.randomseed(LocalPlayer:GetPlayer():GetUniqueId())

            -- Give ped random attributes
            local ped = LocalPlayer:GetPed()

            -- SetPedDefaultComponentVariation Default clothes

            for i = 0, 12 do
                ped:SetHeadOverlay(
                    i,
                    math.random(0, GetPedHeadOverlayNum(i)),
                    math.random()
                )

            end

            -- Skin color
            SetPedHeadBlendData(ped.ped_id, 0, 0, 0, 15, 0, 0, 0, 0, math.random(), false)

            -- SetPedFaceFeature
            -- SetPedHairColor
            -- SetPedEyeColor
            -- 

            -- Hair
            local id1 = 2
            local id2 = math.random(GetNumberOfPedDrawableVariations(ped.ped_id, 2))
            local id3 = math.random(GetNumberOfPedTextureVariations(ped.ped_id, 2))
            SetPedComponentVariation(ped.ped_id, 
                id1,
                id2, 
                id3,
                math.random(0, 3)
            )
                
            SetPedComponentVariation(ped.ped_id, 
                3,
                15, 
                15,
                0
            )

            -- Reset randomseed
            math.randomseed(GetGameTimer())
        end
    })
    
end

cSpawnManager = cSpawnManager()