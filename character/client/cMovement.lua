Movement = class()

function Movement:__init()

    self:RestrictDefaultActions()

    -- Increase run speed a bit since they'll be running a lot
    LocalPlayer:GetPlayer():SetRunSprintMultiplier(1.25)

    self:StartStaminaLoop()

    self.can_attack = true

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
    if not self.can_attack then return end

    -- TODO: separation of attacks based on type of item, eg. gun or melee

    local equipped_item_name = LocalPlayer:GetPlayer():GetValue("EquippedItem")
    if not equipped_item_name then return end

    local action_definition = MeleeActionDefinitions:Get(equipped_item_name)
    if not action_definition then return end

    local melee_action = action_definition.method(LocalPlayer:GetPed(), function()
        self.can_attack = true
    end)
    
    melee_action:PlayAnim()
    melee_action:DetectHits()
    self.can_attack = false

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
            animDict = "melee@large_wpn@streamed_core",
            animName = "ground_attack_on_spot",
            flag = AnimationFlags.ANIM_FLAG_CANCELABLE,
            animTime = 0
        })
    end)

end

Movement = Movement()