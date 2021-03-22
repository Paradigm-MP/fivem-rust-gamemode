MeleeActionDefinitions = class()

function MeleeActionDefinitions:__init()
    self.definitions = 
    {
        ["rock"] = 
        {
            duration = 2000, -- Animation duration
            animDict = "melee@large_wpn@streamed_core",
            animName = "ground_attack_on_spot",
            animFlag = AnimationFlags.ANIM_FLAG_CANCELABLE,
            animTime = 0,
            method = MeleeActionRock,
            tool_length = 0.4,
            detection_delay = 500
        },
        ["stone_hatchet"] = 
        {
            duration = 1000, -- Animation duration
            animDict = "anim@melee@machete@streamed_core@",
            animName = "plyr_walking_attack_a",
            animFlag = AnimationFlags.ANIM_FLAG_CANCELABLE,
            animTime = 0.15,
            method = MeleeActionStoneHatchet,
            tool_length = 0.5
        }
    }
end

function MeleeActionDefinitions:Get(name)
    return self.definitions[name]
end

MeleeActionDefinitions = MeleeActionDefinitions()