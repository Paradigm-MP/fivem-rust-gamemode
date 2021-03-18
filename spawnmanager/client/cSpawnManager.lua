cSpawnManager = class()

function cSpawnManager:__init()

    Events:Subscribe("Loadingscreen/Finished", self, self.LoadingScreenFinished)
    Network:Subscribe("Player/Spawn", self, self.SpawnPlayer)

end

function cSpawnManager:SpawnPlayer(args)

    Camera:Reset()

    LocalPlayer:Spawn({
        pos = args.position,
        model = args.model,
        callback = function()
            -- LocalPlayer:GetPed():GiveWeapon(GetHashKey("weapon_stone_hatchet"), 1, true)
            math.randomseed(LocalPlayer:GetPlayer():GetUniqueId())

            -- Give ped random attributes
            local ped = LocalPlayer:GetPed()

            -- Skin color
            SetPedHeadBlendData(ped.ped_id, 0, 0, 0, 15, 0, 0, 0, 0, math.random(), false)

            -- SetPedFaceFeature
            -- SetPedHairColor
            SetPedHairColor(ped.ped_id, math.random(63), math.random(63))
            SetPedEyeColor(ped.ped_id, math.random(30))

            for i = 0, 20 do
                SetPedFaceFeature(ped.ped_id, i, math.random() * 2 - 1)
            end
            -- 

            -- Hair
            local id1 = 2
            local id2 = math.random(GetNumberOfPedDrawableVariations(ped.ped_id, id1))
            local id3 = math.random(GetNumberOfPedTextureVariations(ped.ped_id, id1, id2))
            SetPedComponentVariation(ped.ped_id, 
                id1,
                id2, 
                id3,
                math.random(0, 3)
            )
      
            -- Top
            SetPedComponentVariation(ped.ped_id, 
                11,
                15, 
                0,
                0
            )

            -- Undershirt
            SetPedComponentVariation(ped.ped_id, 
                8,
                15, 
                0,
                0
            )

            -- Shirt
            SetPedComponentVariation(ped.ped_id, 
                3,
                15, 
                0,
                0
            )

            -- Pants
            SetPedComponentVariation(ped.ped_id, 
                4,
                21, 
                0,
                0
            )

            -- Feet
            SetPedComponentVariation(ped.ped_id, 
                6,
                34, 
                0,
                0
            )

            -- Reset randomseed
            math.randomseed(GetGameTimer())
        end
    })
    
end

function cSpawnManager:LoadingScreenFinished()
    Network:Send("Loadingscreen/Finished")
end

cSpawnManager = cSpawnManager()