PlayerVisualsList = class()

function PlayerVisualsList:__init()
    self.visuals = 
    {
        ["rock"] = 
        {
            bone = PedBoneEnum.RightHand,
            model = "prop_rock_5_e", -- It is kinda huge but I didn't find any smaller rocks
            offset = vector3(0, 0, -0.25),
            rotation = vector3(0, 0, 0)
        }
    }
end

function PlayerVisualsList:Get(name)
    return self.visuals[name]
end

PlayerVisualsList = PlayerVisualsList()