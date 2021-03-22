PlayerVisualsList = class()

function PlayerVisualsList:__init()
    self.visuals = 
    {
        ["rock"] = 
        {
            bone = PedBoneEnum.RightHand,
            model = "prop_rock_5_e",
            offset = vector3(0, 0, -0.325),
            rotation = vector3(0, 45, 0),
            idle = {
                animDict = "anim@heists@box_carry@",
                animName = "idle",
                flag = AnimationFlags.ANIM_FLAG_REPEAT + AnimationFlags.ANIM_FLAG_CANCELABLE,
                duration = -1
            }
        }
    }
end

function PlayerVisualsList:Get(name)
    return self.visuals[name]
end

PlayerVisualsList = PlayerVisualsList()