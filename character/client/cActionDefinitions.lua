MeleeActionDefinitions = 
{
    -- TODO: key should probably be an enum to represent items, such as a Rock or Stone Hatchet
    ["Stone Hatchet"] = 
    {
        duration = 1, -- Animation duration
        animName = "anim@melee@machete@streamed_core@",
        animDict = "plyr_walking_attack_a",
        animFlag = AnimationFlags.ANIM_FLAG_CANCELABLE,
        animTime = 0.15,
        delay_between = 1, -- Time in seconds to wait between uses
        method = MeleeActionStoneHatchet,
    }
}

