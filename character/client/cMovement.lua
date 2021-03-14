Movement = class()

function Movement:__init()

    LocalPlayer:GetPlayer():DisableFiring(true)

    LocalPlayer:RestrictAction(Control.NextCamera, true)
    LocalPlayer:RestrictAction(Control.Cover, true)
    Camera:LockCameraMode(CameraViewMode.FirstPerson)

    -- Increase run speed a bit since they'll be running a lot
    LocalPlayer:GetPlayer():SetRunSprintMultiplier(1.25)

    self:StartStaminaLoop()

    self.action_timers = 
    {
        attack = Timer()
    }

    Keymap:Register("mouse_left", "mouse_button", "attack", function(args)
        if args.down and not Inventory:IsOpen() then
            self:TryToAttack()
        end
    end)

    if IsTest then
        self:TestCommands()
    end

end

function Movement:TryToAttack()
    -- TODO: put the attack timer on a per-weapon basis
    if self.action_timers.attack:GetSeconds() < 1 then return end

    self.action_timers.attack:Restart()

    -- TODO: animations should be on a per-weapon basis
    LocalPlayer:GetPed():PlayAnim({
        animDict = "anim@melee@machete@streamed_core@",
        animName = "plyr_walking_attack_a",
        flag = AnimationFlags.ANIM_FLAG_CANCELABLE,
        animTime = 0.15
    })

    local detection = MeleeActionStoneHatchet(LocalPlayer:GetPed())
    detection:DetectHits()

    Citizen.CreateThread(function()
        Wait(800)
        detection:StopDetecting()
    end)

end

function Movement:StartStaminaLoop()
    -- Give the player infinite stamina
    Citizen.CreateThread(function()
        while true do
            LocalPlayer:GetPlayer():ResetStamina()
            Wait(1500)
        end
    end)
end

function Movement:TestCommands()

    RegisterCommand('anim', function()
        LocalPlayer:GetPed():PlayAnim({
            animDict = "anim@melee@machete@streamed_core@",
            animName = "plyr_walking_attack_a",
            flag = AnimationFlags.ANIM_FLAG_CANCELABLE,
            animTime = 0.15
        })
    end)

end

Movement = Movement()