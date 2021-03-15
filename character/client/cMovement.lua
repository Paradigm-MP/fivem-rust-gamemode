Movement = class()

function Movement:__init()

    self:RestrictDefaultActions()

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

function Movement:RestrictDefaultActions()
    
    LocalPlayer:GetPlayer():DisableFiring(true)

    LocalPlayer:RestrictAction(Control.NextCamera, true)
    LocalPlayer:RestrictAction(Control.Cover, true)
    LocalPlayer:RestrictAction(Control.WeaponWheelUpDown, true)
    LocalPlayer:RestrictAction(Control.WeaponWheelLeftRight, true)
    LocalPlayer:RestrictAction(Control.WeaponWheelNext, true)
    LocalPlayer:RestrictAction(Control.WeaponWheelPrev, true)
    LocalPlayer:RestrictAction(Control.SelectNextWeapon, true)
    LocalPlayer:RestrictAction(Control.SelectPrevWeapon, true)
    LocalPlayer:RestrictAction(Control.CharacterWheel, true)
    LocalPlayer:RestrictAction(Control.SelectWeapon, true)
    LocalPlayer:RestrictAction(Control.WeaponSpecial, true)
    LocalPlayer:RestrictAction(Control.WeaponSpecial2, true)
    LocalPlayer:RestrictAction(Control.DropWeapon, true)
    LocalPlayer:RestrictAction(Control.DropAmmo, true)
    LocalPlayer:RestrictAction(Control.SpecialAbilityPC, true)
    LocalPlayer:RestrictAction(Control.Attack2, true)
    LocalPlayer:RestrictAction(Control.PrevWeapon, true)
    LocalPlayer:RestrictAction(Control.NextWeapon, true)
    LocalPlayer:RestrictAction(Control.MeleeAttack1, true)
    LocalPlayer:RestrictAction(Control.MeleeAttack2, true)
    LocalPlayer:RestrictAction(Control.Phone, true)
    LocalPlayer:RestrictAction(Control.SpecialAbility, true)
    LocalPlayer:RestrictAction(Control.SpecialAbilitySecondary, true)
    LocalPlayer:RestrictAction(Control.Attack, true)
    LocalPlayer:RestrictAction(Control.MeleeAttackLight, true)
    LocalPlayer:RestrictAction(Control.MeleeAttackHeavy, true)
    LocalPlayer:RestrictAction(Control.MeleeAttackAlternate, true)
    LocalPlayer:RestrictAction(Control.MeleeBlock, true)

    Camera:LockCameraMode(CameraViewMode.FirstPerson)

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